<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/auth.php';
require_once '../config/jwt.php';
require_once '../config/response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::methodNotAllowed();
}

try {
    $database = new Database();
    $db = $database->getConnection();
} catch (Exception $e) {
    error_log("Database connection failed in confirm-password: " . $e->getMessage());
    Response::error('Database connection failed', 500);
}

// Require login
$authPayload = Auth::requireAuth();

$data = json_decode(file_get_contents("php://input"), true);

if (!is_array($data)) {
    Response::error('Invalid request body', 400);
}

$password = $data['password'] ?? null;
$purpose = $data['purpose'] ?? null;

if (!is_string($password) || trim($password) === '') {
    Response::error('Password is required', 400);
}

// Only allow explicit purposes to avoid clients minting overly-broad confirmations
$allowedPurposes = ['reports_export', 'activities_export', 'backup_download'];
if (!is_string($purpose) || !in_array($purpose, $allowedPurposes, true)) {
    Response::error('Invalid purpose', 400);
}

try {
    $stmt = $db->prepare("SELECT id, password, is_active FROM users WHERE id = :id LIMIT 1");
    $stmt->bindValue(':id', (int)$authPayload['user_id'], PDO::PARAM_INT);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        Response::unauthorized('User not found');
    }
    if (!(int)$user['is_active']) {
        Response::unauthorized('Account is deactivated');
    }

    if (!password_verify($password, $user['password'])) {
        Response::error('Invalid password', 401);
    }

    $jwt = new JWT();
    $ttlSeconds = 5 * 60; // 5 minutes
    $now = time();

    $confirmPayload = [
        'type' => 'password_confirm',
        'user_id' => (int)$authPayload['user_id'],
        'purpose' => $purpose,
        'iat' => $now,
        'exp' => $now + $ttlSeconds
    ];

    $confirmToken = $jwt->encode($confirmPayload);

    Response::success([
        'confirm_token' => $confirmToken,
        'expires_at' => date('c', $confirmPayload['exp'])
    ], 'Password confirmed');
} catch (Exception $e) {
    Response::serverError('Failed to confirm password', $e);
}


