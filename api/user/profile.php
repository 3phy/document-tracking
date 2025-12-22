<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/jwt.php';

$database = new Database();
$db = $database->getConnection();
$jwt = new JWT();

header('Content-Type: application/json');

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

$user_id = $payload['user_id'];

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Get user profile
    try {
        $query = "SELECT u.id, u.name, u.email, u.role, u.department_id, d.name as department_name 
                  FROM users u 
                  LEFT JOIN departments d ON u.department_id = d.id 
                  WHERE u.id = ?";
        $stmt = $db->prepare($query);
        $stmt->execute([$user_id]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user) {
            echo json_encode([
                'success' => true,
                'user' => $user
            ]);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'User not found']);
        }
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Database error']);
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Update user profile
    $data = json_decode(file_get_contents("php://input"), true);

    if (!isset($data['name']) || !isset($data['email'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Name and email are required']);
        exit();
    }

    $name = trim($data['name']);
    $email = trim($data['email']);
    $password = isset($data['password']) && !empty($data['password']) ? $data['password'] : null;
    $current_password = isset($data['current_password']) ? $data['current_password'] : null;

    // Validate email
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid email format']);
        exit();
    }

    // Validate name
    if (empty($name)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Name cannot be empty']);
        exit();
    }

    try {
        // Check if email already exists for another user
        $email_check = $db->prepare("SELECT id FROM users WHERE email = ? AND id != ?");
        $email_check->execute([$email, $user_id]);
        
        if ($email_check->rowCount() > 0) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Email already exists']);
            exit();
        }

        // If password is being changed, verify current password
        if ($password) {
            if (!$current_password) {
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'Current password is required to change password']);
                exit();
            }

            // Verify current password
            $check_user = $db->prepare("SELECT password FROM users WHERE id = ?");
            $check_user->execute([$user_id]);
            $user_data = $check_user->fetch(PDO::FETCH_ASSOC);

            if (!$user_data || !password_verify($current_password, $user_data['password'])) {
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => 'Current password is incorrect']);
                exit();
            }

            // Update with password
            $hashed_password = password_hash($password, PASSWORD_DEFAULT);
            $update = $db->prepare("UPDATE users SET name = ?, email = ?, password = ?, updated_at = NOW() WHERE id = ?");
            $update->execute([$name, $email, $hashed_password, $user_id]);
        } else {
            // Update without password
            $update = $db->prepare("UPDATE users SET name = ?, email = ?, updated_at = NOW() WHERE id = ?");
            $update->execute([$name, $email, $user_id]);
        }

        // Get updated user info
        $query = "SELECT u.id, u.name, u.email, u.role, u.department_id, d.name as department_name 
                  FROM users u 
                  LEFT JOIN departments d ON u.department_id = d.id 
                  WHERE u.id = ?";
        $stmt = $db->prepare($query);
        $stmt->execute([$user_id]);
        $updated_user = $stmt->fetch(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'message' => 'Profile updated successfully',
            'user' => $updated_user
        ]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to update profile']);
    }
} else {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
}
?>

