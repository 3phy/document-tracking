<?php
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/response.php';

$database = new Database();
$db = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::methodNotAllowed();
}

$data = json_decode(file_get_contents("php://input"), true);
if (!isset($data['email']) || !isset($data['otp'])) {
    Response::error('Email and OTP are required', 400);
}

$email = trim($data['email']);
$otp = trim((string)$data['otp']);

if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    Response::error('Invalid email format', 400);
}
if (!preg_match('/^\d{6}$/', $otp)) {
    Response::error('Invalid OTP format', 400);
}

/**
 * Ensure password reset OTP table exists (keeps feature self-contained)
 */
function ensurePasswordResetOtpTable(PDO $db) {
    $db->exec("
        CREATE TABLE IF NOT EXISTS password_reset_otps (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            purpose VARCHAR(50) NOT NULL DEFAULT 'password_reset',
            otp_hash VARCHAR(255) NOT NULL,
            otp_expires_at DATETIME NOT NULL,
            reset_token_hash VARCHAR(255) DEFAULT NULL,
            token_expires_at DATETIME DEFAULT NULL,
            verified_at DATETIME DEFAULT NULL,
            used_at DATETIME DEFAULT NULL,
            attempts INT NOT NULL DEFAULT 0,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_user_created (user_id, created_at),
            INDEX idx_token (reset_token_hash),
            CONSTRAINT fk_password_reset_otps_user
                FOREIGN KEY (user_id) REFERENCES users(id)
                ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ");
}

try {
    ensurePasswordResetOtpTable($db);

    // Lookup user (generic error to avoid enumeration)
    $stmt = $db->prepare("SELECT id, is_active FROM users WHERE email = :email LIMIT 1");
    $stmt->execute([':email' => $email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$user || !$user['is_active']) {
        Response::error('Invalid OTP', 400);
    }

    // Find recent unverified OTPs (email delivery can be delayed; user may have multiple OTPs)
    $otpStmt = $db->prepare("
        SELECT id, otp_hash, attempts, otp_expires_at
        FROM password_reset_otps
        WHERE user_id = :user_id
          AND purpose = 'password_reset'
          AND used_at IS NULL
          AND verified_at IS NULL
          AND otp_expires_at >= NOW()
        ORDER BY created_at DESC
        LIMIT 5
    ");
    $otpStmt->execute([':user_id' => $user['id']]);
    $maxAttempts = 5;
    $matchedRow = null;
    $latestRowId = null;
    $latestAttempts = null;

    while ($row = $otpStmt->fetch(PDO::FETCH_ASSOC)) {
        if ($latestRowId === null) {
            $latestRowId = (int)$row['id'];
            $latestAttempts = (int)$row['attempts'];
        }

        if ((int)$row['attempts'] >= $maxAttempts) {
            continue;
        }

        if (password_verify($otp, $row['otp_hash'])) {
            $matchedRow = $row;
            break;
        }
    }

    if (!$matchedRow) {
        // Increment attempts only on the latest OTP row (limits brute force without locking out older rows)
        if ($latestRowId !== null) {
            if ($latestAttempts !== null && $latestAttempts >= $maxAttempts) {
                Response::error('OTP attempts exceeded. Please request a new OTP.', 429);
            }
            $upd = $db->prepare("UPDATE password_reset_otps SET attempts = attempts + 1 WHERE id = :id");
            $upd->execute([':id' => $latestRowId]);
            Response::error('Invalid or expired OTP', 400);
        }

        Response::error('Invalid or expired OTP', 400);
    }

    // OTP verified -> mint a short-lived reset token
    $resetToken = bin2hex(random_bytes(32));
    $resetTokenHash = password_hash($resetToken, PASSWORD_DEFAULT);

    $verify = $db->prepare("
        UPDATE password_reset_otps
        SET verified_at = NOW(),
            reset_token_hash = :reset_token_hash,
            token_expires_at = DATE_ADD(NOW(), INTERVAL 15 MINUTE)
        WHERE id = :id
    ");
    $verify->execute([
        ':reset_token_hash' => $resetTokenHash,
        ':id' => $matchedRow['id']
    ]);

    Response::success([
        'reset_token' => $resetToken,
        'expires_in_seconds' => 15 * 60
    ], 'OTP verified');
} catch (Exception $e) {
    Response::serverError('OTP verification failed', $e);
}


