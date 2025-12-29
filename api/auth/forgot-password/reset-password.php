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
if (!isset($data['email']) || !isset($data['reset_token']) || !isset($data['new_password'])) {
    Response::error('Email, reset token, and new password are required', 400);
}

$email = trim($data['email']);
$resetToken = trim((string)$data['reset_token']);
$newPassword = (string)$data['new_password'];

if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    Response::error('Invalid email format', 400);
}
if (strlen($resetToken) < 20) {
    Response::error('Invalid reset token', 400);
}
if (strlen($newPassword) < 8) {
    Response::error('Password must be at least 8 characters', 400);
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

    // Lookup user (generic error)
    $stmt = $db->prepare("SELECT id, is_active FROM users WHERE email = :email LIMIT 1");
    $stmt->execute([':email' => $email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$user || !$user['is_active']) {
        Response::error('Invalid reset token', 400);
    }

    // Get latest verified reset request
    $req = $db->prepare("
        SELECT id, reset_token_hash, token_expires_at
        FROM password_reset_otps
        WHERE user_id = :user_id
          AND purpose = 'password_reset'
          AND verified_at IS NOT NULL
          AND used_at IS NULL
          AND token_expires_at IS NOT NULL
          AND token_expires_at >= NOW()
        ORDER BY verified_at DESC
        LIMIT 1
    ");
    $req->execute([':user_id' => $user['id']]);
    $row = $req->fetch(PDO::FETCH_ASSOC);
    if (!$row) {
        Response::error('Invalid or expired reset token', 400);
    }

    if (!password_verify($resetToken, $row['reset_token_hash'])) {
        Response::error('Invalid reset token', 400);
    }

    // Update password
    $passwordHash = password_hash($newPassword, PASSWORD_DEFAULT);
    $upd = $db->prepare("UPDATE users SET password = :password, updated_at = NOW() WHERE id = :id");
    $upd->execute([
        ':password' => $passwordHash,
        ':id' => $user['id']
    ]);

    // Mark reset request used
    $mark = $db->prepare("UPDATE password_reset_otps SET used_at = NOW() WHERE id = :id");
    $mark->execute([':id' => $row['id']]);

    Response::success(null, 'Password reset successfully');
} catch (Exception $e) {
    Response::serverError('Password reset failed', $e);
}


