<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/auth.php';
require_once '../config/response.php';

try {
    $database = new Database();
    $db = $database->getConnection();
} catch (Exception $e) {
    error_log("Database connection failed in verify: " . $e->getMessage());
    Response::error('Database connection failed', 500);
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::methodNotAllowed();
}

// Verify token using Auth helper
$payload = Auth::requireAuth();

try {
    $query = "SELECT u.id, u.name, u.email, u.role, u.is_active, u.department_id, d.name as department_name 
              FROM users u 
              LEFT JOIN departments d ON u.department_id = d.id 
              WHERE u.id = :user_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':user_id', $payload['user_id']);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user['is_active']) {
            Response::error('Account is deactivated', 401);
        }
        
        Response::success(['user' => $user]);
    } else {
        Response::error('User not found', 401);
    }
} catch (Exception $e) {
    Response::serverError('Failed to verify user', $e);
}
?>
