<?php
/**
 * Authentication Middleware Helper
 * Provides reusable authentication functions for API endpoints
 */
require_once __DIR__ . '/jwt.php';
require_once __DIR__ . '/database.php';

class Auth {
    /**
     * Get a request header value (case-insensitive), with fallbacks for servers that
     * don't populate getallheaders().
     * @param string $name
     * @return string|null
     */
    private static function getHeaderValue($name) {
        $value = null;

        // Try getallheaders() first (works on Apache)
        if (function_exists('getallheaders')) {
            $headers = getallheaders();
            foreach ($headers as $k => $v) {
                if (strcasecmp($k, $name) === 0) {
                    $value = $v;
                    break;
                }
            }
        }

        // Fallback to $_SERVER
        if ($value === null) {
            $serverKey = 'HTTP_' . strtoupper(str_replace('-', '_', $name));
            if (isset($_SERVER[$serverKey])) {
                $value = $_SERVER[$serverKey];
            }
        }

        return $value !== null ? trim((string)$value) : null;
    }

    /**
     * Get and verify JWT token from request headers
     * @return array|false Returns payload array on success, false on failure
     */
    public static function verifyToken() {
        $auth_header = '';
        
        // Try getallheaders() first (works on Apache)
        if (function_exists('getallheaders')) {
            $headers = getallheaders();
            $auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';
        }
        
        // Fallback to $_SERVER (works on Nginx and other servers)
        if (empty($auth_header)) {
            $auth_header = isset($_SERVER['HTTP_AUTHORIZATION']) 
                ? $_SERVER['HTTP_AUTHORIZATION'] 
                : '';
        }
        
        // Also check REDIRECT_HTTP_AUTHORIZATION (some PHP configurations)
        if (empty($auth_header)) {
            $auth_header = isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION']) 
                ? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] 
                : '';
        }

        if (empty($auth_header) || !preg_match('/Bearer\s(\S+)/', $auth_header, $matches)) {
            return false;
        }

        $token = $matches[1];
        $jwt = new JWT();
        $payload = $jwt->decode($token);

        if (!$payload) {
            return false;
        }

        // Check expiration
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            return false;
        }

        return $payload;
    }

    /**
     * Verify a short-lived password-confirmation token provided in X-Confirm-Token header.
     * @param array $authPayload The already-validated main JWT payload from Authorization header.
     * @param string $requiredPurpose Purpose string to bind confirmation to an action.
     * @return array|false Returns confirm-token payload on success, false on failure.
     */
    public static function verifyPasswordConfirmation($authPayload, $requiredPurpose) {
        if (!isset($authPayload['user_id'])) {
            return false;
        }

        $confirmToken = self::getHeaderValue('X-Confirm-Token');
        if (empty($confirmToken)) {
            return false;
        }

        $jwt = new JWT();
        $payload = $jwt->decode($confirmToken);
        if (!$payload) {
            return false;
        }

        // Basic claims
        if (!isset($payload['exp']) || $payload['exp'] < time()) {
            return false;
        }
        if (!isset($payload['type']) || $payload['type'] !== 'password_confirm') {
            return false;
        }
        if (!isset($payload['user_id']) || (int)$payload['user_id'] !== (int)$authPayload['user_id']) {
            return false;
        }
        if (!isset($payload['purpose']) || $payload['purpose'] !== $requiredPurpose) {
            return false;
        }

        return $payload;
    }

    /**
     * Require password confirmation, otherwise send a 403 and exit.
     * @param array $authPayload Main JWT payload
     * @param string $requiredPurpose
     */
    public static function requirePasswordConfirmation($authPayload, $requiredPurpose) {
        $ok = self::verifyPasswordConfirmation($authPayload, $requiredPurpose);
        if (!$ok) {
            http_response_code(403);
            echo json_encode([
                'success' => false,
                'message' => 'Password confirmation required'
            ]);
            exit();
        }
        return $ok;
    }

    /**
     * Require authentication and return user payload
     * Sends 401 response and exits if authentication fails
     * @return array User payload
     */
    public static function requireAuth() {
        $payload = self::verifyToken();
        
        if (!$payload) {
            http_response_code(401);
            echo json_encode(['success' => false, 'message' => 'Invalid or expired token']);
            exit();
        }

        return $payload;
    }

    /**
     * Verify user is active in database
     * @param PDO $db Database connection
     * @param int $user_id User ID
     * @return array|false User data if active, false otherwise
     */
    public static function verifyUserActive($db, $user_id) {
        try {
            $query = "SELECT id, name, email, role, is_active, department_id 
                      FROM users 
                      WHERE id = :user_id";
            $stmt = $db->prepare($query);
            $stmt->bindParam(':user_id', $user_id);
            $stmt->execute();

            if ($stmt->rowCount() > 0) {
                $user = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if (!$user['is_active']) {
                    return false;
                }
                
                return $user;
            }
            
            return false;
        } catch (Exception $e) {
            error_log("Error verifying user: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Require admin role
     * Sends 403 response and exits if user is not admin
     * @param array $payload JWT payload
     */
    public static function requireAdmin($payload) {
        if (!isset($payload['role']) || $payload['role'] !== 'admin') {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'Admin access required']);
            exit();
        }
    }
}
?>

