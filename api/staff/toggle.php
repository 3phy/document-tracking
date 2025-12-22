<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/jwt.php';

$database = new Database();
$db = $database->getConnection();
$jwt = new JWT();

if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

// Verify token
$headers = getallheaders();
$auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';

if (empty($auth_header) || !preg_match('/Bearer\s(\S+)/', $auth_header, $matches)) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'No token provided']);
    exit();
}

$token = $matches[1];
$payload = $jwt->decode($token);

if (!$payload || $payload['exp'] < time()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Invalid or expired token']);
    exit();
}

// Get user ID from URL
$user_id = isset($_GET['id']) ? $_GET['id'] : null;

if (!$user_id) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'User ID is required']);
    exit();
}

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['is_active'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'is_active status is required']);
    exit();
}

$is_active = (bool)$data['is_active'];

try {
    // Get user's current role and department from database (more reliable than JWT token)
    $user_query = "SELECT role, department_id FROM users WHERE id = ?";
    $user_stmt = $db->prepare($user_query);
    $user_stmt->execute([$payload['user_id']]);
    $user_data = $user_stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user_data) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'User not found']);
        exit();
    }
    
    $user_role = strtolower(trim($user_data['role']));
    $user_dept_id = $user_data['department_id'] ? (int)$user_data['department_id'] : null;
    
    // Check if user is admin or department_head
    if (!in_array($user_role, ['admin', 'department_head'])) {
        http_response_code(403);
        echo json_encode(['success' => false, 'message' => 'Access denied. Admin or Department Head privileges required.']);
        exit();
    }
    
    // For department_head, verify they have a department
    if ($user_role === 'department_head' && !$user_dept_id) {
        http_response_code(403);
        echo json_encode(['success' => false, 'message' => 'Department head must be assigned to a department']);
        exit();
    }

    // Check if user exists and get their data
    $check_query = "SELECT id, is_active, role, department_id FROM users WHERE id = :user_id";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->bindParam(':user_id', $user_id);
    $check_stmt->execute();
    
    if ($check_stmt->rowCount() === 0) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'User not found']);
        exit();
    }
    
    $target_user = $check_stmt->fetch(PDO::FETCH_ASSOC);
    
    // For department_head, restrict toggles
    if ($user_role === 'department_head') {
        $user_dept_id = $user_data ? (int)$user_data['department_id'] : null;
        
        if (!$user_dept_id) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'Department head must be assigned to a department']);
            exit();
        }
        
        // Can only toggle staff in their department
        if ((int)$target_user['department_id'] !== $user_dept_id) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'You can only toggle status for staff in your own department']);
            exit();
        }
        
        // Cannot toggle admins or other department heads
        if (in_array($target_user['role'], ['admin', 'department_head'])) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'You cannot toggle status for administrators or department heads']);
            exit();
        }
    }
    
    // Update user status
    $query = "UPDATE users SET is_active = :is_active WHERE id = :user_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':is_active', $is_active, PDO::PARAM_BOOL);
    $stmt->bindParam(':user_id', $user_id);
    
    if ($stmt->execute()) {
        $status_text = $is_active ? 'activated' : 'deactivated';
        echo json_encode([
            'success' => true,
            'message' => "Staff member {$status_text} successfully"
        ]);
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to update staff member status']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database error']);
}
?>
