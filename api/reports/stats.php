<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/jwt.php';

$database = new Database();
$db = $database->getConnection();
$jwt = new JWT();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
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
    
    // Get user's department_id for department_head
    $dept_filter = "";
    $dept_params = [];
    
    if ($user_role === 'department_head') {
        
        // Filter for documents that have been passed to this department
        $dept_filter = " AND (
            d.department_id = :dept_id 
            OR d.current_department_id = :dept_id_curr 
            OR d.upload_department_id = :dept_id_upload
            OR EXISTS (
                SELECT 1 FROM document_forwarding_history dfh 
                WHERE dfh.document_id = d.id 
                AND (dfh.to_department_id = :dept_id_history_to OR dfh.from_department_id = :dept_id_history_from)
            )
        )";
        $dept_params[':dept_id'] = $user_dept_id;
        $dept_params[':dept_id_curr'] = $user_dept_id;
        $dept_params[':dept_id_upload'] = $user_dept_id;
        $dept_params[':dept_id_history_to'] = $user_dept_id;
        $dept_params[':dept_id_history_from'] = $user_dept_id;
    }
    
    $stats = [];
    
    // Total documents
    $total_query = "SELECT COUNT(DISTINCT d.id) as total 
                    FROM documents d 
                    WHERE 1=1" . $dept_filter;
    $stmt = $db->prepare($total_query);
    foreach ($dept_params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->execute();
    $stats['totalDocuments'] = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // Outgoing documents
    $outgoing_query = "SELECT COUNT(DISTINCT d.id) as count 
                       FROM documents d 
                       WHERE d.status = 'outgoing'" . $dept_filter;
    $stmt = $db->prepare($outgoing_query);
    foreach ($dept_params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->execute();
    $stats['outgoingCount'] = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // Pending documents
    $pending_query = "SELECT COUNT(DISTINCT d.id) as count 
                      FROM documents d 
                      WHERE d.status = 'pending'" . $dept_filter;
    $stmt = $db->prepare($pending_query);
    foreach ($dept_params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->execute();
    $stats['pendingCount'] = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // Received documents
    $received_query = "SELECT COUNT(DISTINCT d.id) as count 
                       FROM documents d 
                       WHERE d.status = 'received'" . $dept_filter;
    $stmt = $db->prepare($received_query);
    foreach ($dept_params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->execute();
    $stats['receivedCount'] = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // Rejected/Cancelled documents
    $rejected_query = "SELECT COUNT(DISTINCT d.id) as count 
                       FROM documents d 
                       WHERE d.status = 'rejected'" . $dept_filter;
    $stmt = $db->prepare($rejected_query);
    foreach ($dept_params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->execute();
    $stats['rejectedCount'] = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    // Completion rate
    $completion_rate = 0;
    if ($stats['totalDocuments'] > 0) {
        $completion_rate = round(($stats['receivedCount'] / $stats['totalDocuments']) * 100, 2);
    }
    $stats['completionRate'] = $completion_rate;
    
    echo json_encode([
        'success' => true,
        'stats' => $stats
    ]);
} catch (Exception $e) {
    http_response_code(500);
    error_log("Stats API Error: " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
