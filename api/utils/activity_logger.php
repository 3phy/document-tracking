<?php
/**
 * Activity Logger
 * Centralized user activity logging with backward-compatible storage optimization.
 *
 * - Always logs: user_id, action, description, created_at (DB default)
 * - If present, also logs: ip_address, ip_address_bin, user_agent_id/user_agent
 * - Dedupe user agents into user_agents table when available
 */
class ActivityLogger
{
    private static $columnCache = [];

    private static function getClientIp(): ?string
    {
        // Prefer first forwarded IP if behind proxy
        $forwarded = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? '';
        if (!empty($forwarded)) {
            $parts = explode(',', $forwarded);
            $ip = trim($parts[0]);
            if ($ip !== '') return self::normalizeIp($ip);
        }

        $ip = $_SERVER['HTTP_CLIENT_IP'] ?? '';
        if (!empty($ip)) return self::normalizeIp(trim($ip));

        $ip = $_SERVER['REMOTE_ADDR'] ?? '';
        return $ip ? self::normalizeIp(trim($ip)) : null;
    }

    private static function normalizeIp(?string $ip): ?string
    {
        if (!$ip) return null;

        // IPv6 loopback → standard IPv4 loopback for nicer display
        if ($ip === '::1') return '127.0.0.1';

        // IPv4-mapped IPv6 (e.g. ::ffff:127.0.0.1) → IPv4
        if (str_starts_with($ip, '::ffff:')) {
            $maybeV4 = substr($ip, 7);
            if (filter_var($maybeV4, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)) {
                return $maybeV4;
            }
        }

        // Return as-is if valid IPv4/IPv6, otherwise null
        if (filter_var($ip, FILTER_VALIDATE_IP)) return $ip;
        return null;
    }

    private static function columnExists(PDO $db, string $table, string $column): bool
    {
        $key = $table . '.' . $column;
        if (array_key_exists($key, self::$columnCache)) {
            return self::$columnCache[$key];
        }

        $stmt = $db->prepare("
            SELECT 1
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = ?
              AND COLUMN_NAME = ?
            LIMIT 1
        ");
        $stmt->execute([$table, $column]);
        $exists = (bool)$stmt->fetchColumn();
        self::$columnCache[$key] = $exists;
        return $exists;
    }

    private static function ensureUserAgentId(PDO $db, ?string $userAgent): ?int
    {
        if (!$userAgent) return null;

        // Only use normalized UA table if schema supports it
        if (!self::columnExists($db, 'user_activities', 'user_agent_id')) return null;

        // Best-effort: user_agents table might not exist yet
        try {
            $hash = hash('sha256', $userAgent);
            $ins = $db->prepare("INSERT IGNORE INTO user_agents (user_agent_hash, user_agent) VALUES (?, ?)");
            $ins->execute([$hash, $userAgent]);

            $sel = $db->prepare("SELECT id FROM user_agents WHERE user_agent_hash = ? LIMIT 1");
            $sel->execute([$hash]);
            $id = $sel->fetchColumn();
            return $id ? (int)$id : null;
        } catch (Exception $e) {
            return null;
        }
    }

    /**
     * Log an activity event. Never throws (best-effort).
     */
    public static function log(PDO $db, int $userId, string $action, ?string $description = null): void
    {
        try {
            $ip = self::getClientIp();
            $ua = $_SERVER['HTTP_USER_AGENT'] ?? null;

            $cols = ['user_id', 'action', 'description'];
            $placeholders = ['?', '?', '?'];
            $values = [$userId, $action, $description];

            // IP string column (legacy)
            if (self::columnExists($db, 'user_activities', 'ip_address')) {
                $cols[] = 'ip_address';
                $placeholders[] = '?';
                $values[] = $ip;
            }

            // IP binary column (optimized)
            if (self::columnExists($db, 'user_activities', 'ip_address_bin')) {
                $cols[] = 'ip_address_bin';
                // MySQL/MariaDB function supports IPv4/IPv6
                $placeholders[] = 'INET6_ATON(?)';
                $values[] = $ip;
            }

            // User agent normalized (preferred)
            $uaId = self::ensureUserAgentId($db, $ua);
            if ($uaId !== null && self::columnExists($db, 'user_activities', 'user_agent_id')) {
                $cols[] = 'user_agent_id';
                $placeholders[] = '?';
                $values[] = $uaId;

                // If legacy column exists, keep it NULL to save space
                if (self::columnExists($db, 'user_activities', 'user_agent')) {
                    $cols[] = 'user_agent';
                    $placeholders[] = '?';
                    $values[] = null;
                }
            } elseif (self::columnExists($db, 'user_activities', 'user_agent')) {
                // Legacy storage (stores large UA strings repeatedly)
                $cols[] = 'user_agent';
                $placeholders[] = '?';
                $values[] = $ua;
            }

            $sql = "INSERT INTO user_activities (" . implode(', ', $cols) . ") VALUES (" . implode(', ', $placeholders) . ")";
            $stmt = $db->prepare($sql);
            $stmt->execute($values);
        } catch (Exception $e) {
            // Best-effort; do not fail the request
        }
    }
}


