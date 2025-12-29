<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/jwt.php';
require_once '../config/response.php';
require_once '../utils/activity_logger.php';

$database = new Database();
$db = $database->getConnection();
$jwt = new JWT();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::methodNotAllowed();
}

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['email']) || !isset($data['password'])) {
    Response::error('Email and password are required', 400);
}

$email = trim($data['email']);
$password = $data['password'];

// Basic email validation
if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    Response::error('Invalid email format', 400);
}

try {
    $query = "SELECT id, name, email, password, role, is_active FROM users WHERE email = :email";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':email', $email);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user['is_active']) {
            Response::error('Account is deactivated', 401);
        }
        
        if (password_verify($password, $user['password'])) {
            unset($user['password']);
            
            $payload = [
                'user_id' => $user['id'],
                'email' => $user['email'],
                'role' => $user['role'],
                'exp' => time() + (24 * 60 * 60) // 24 hours
            ];
            
            $token = $jwt->encode($payload);

            // Activity log (best-effort)
            ActivityLogger::log($db, (int)$user['id'], 'login', 'Logged in');
            
            Response::success([
                'token' => $token,
                'user' => $user
            ], 'Login successful');
        } else {
            Response::error('Invalid credentials', 401);
        }
    } else {
        Response::error('Invalid credentials', 401);
    }
} catch (Exception $e) {
    Response::serverError('Login failed', $e);
}
?>
