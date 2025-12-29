<?php
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../config/response.php';
require_once '../../utils/mailer.php';

$database = new Database();
$db = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::methodNotAllowed();
}

$data = json_decode(file_get_contents("php://input"), true);
if (!isset($data['email'])) {
    Response::error('Email is required', 400);
}

$email = trim($data['email']);
if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    Response::error('Invalid email format', 400);
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

    // Always respond with a generic success message to avoid email enumeration
    $genericMessage = 'If that email exists, an OTP was sent.';

    // Lookup user
    $stmt = $db->prepare("SELECT id, name, email, is_active FROM users WHERE email = :email LIMIT 1");
    $stmt->execute([':email' => $email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user || !$user['is_active']) {
        Response::success(null, $genericMessage);
    }

    // Basic rate limit: 1 OTP per 60 seconds per user
    // IMPORTANT: compute cooldown using DB time (NOW()) to avoid PHP/MySQL timezone mismatch issues.
    $rateLimitSeconds = 60;
    $rateStmt = $db->prepare("
        SELECT
            created_at,
            TIMESTAMPDIFF(SECOND, NOW(), DATE_ADD(created_at, INTERVAL 60 SECOND)) AS retry_after_seconds
        FROM password_reset_otps
        WHERE user_id = :user_id AND purpose = 'password_reset'
        ORDER BY created_at DESC
        LIMIT 1
    ");
    $rateStmt->execute([':user_id' => $user['id']]);
    $last = $rateStmt->fetch(PDO::FETCH_ASSOC);
    if ($last && isset($last['retry_after_seconds'])) {
        $retryAfter = (int)$last['retry_after_seconds'];
        if ($retryAfter > 0) {
            // Safety: never show crazy huge numbers to the user even if server time is skewed
            $retryAfter = max(1, min($rateLimitSeconds, $retryAfter));
            header('Retry-After: ' . $retryAfter);
            Response::error('Please wait a moment before requesting another OTP.', 429, [
                'retry_after_seconds' => $retryAfter
            ]);
        }
    }

    // Generate OTP
    $otp = (string)random_int(100000, 999999);
    $expiresMinutes = 10;
    $otpHash = password_hash($otp, PASSWORD_DEFAULT);

    // Store OTP (compute expiry using DB time to avoid PHP/MySQL timezone mismatch)
    $ins = $db->prepare("
        INSERT INTO password_reset_otps (user_id, purpose, otp_hash, otp_expires_at)
        VALUES (:user_id, 'password_reset', :otp_hash, DATE_ADD(NOW(), INTERVAL 10 MINUTE))
    ");
    $ins->execute([
        ':user_id' => $user['id'],
        ':otp_hash' => $otpHash
    ]);

    // Send email
    Mailer::sendPasswordResetOtp($user['email'], $user['name'], $otp, $expiresMinutes);

    Response::success(null, $genericMessage);
} catch (Exception $e) {
    Response::serverError('Failed to send OTP', $e);
}


