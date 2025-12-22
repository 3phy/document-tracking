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
    
    // Get filter parameters
    $date_from = isset($_GET['date_from']) ? $_GET['date_from'] : null;
    $date_to = isset($_GET['date_to']) ? $_GET['date_to'] : null;
    $status = isset($_GET['status']) ? $_GET['status'] : null;
    $user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;
    
    // Build query with filters
    $query = "SELECT d.title, d.description, d.status, d.barcode, d.uploaded_at, d.received_at, 
                     u.name as uploaded_by_name, r.name as received_by_name, dept.name as department_name 
              FROM documents d 
              LEFT JOIN users u ON d.uploaded_by = u.id 
              LEFT JOIN users r ON d.received_by = r.id 
              LEFT JOIN departments dept ON d.department_id = dept.id 
              LEFT JOIN document_forwarding_history dfh ON d.id = dfh.document_id
              WHERE 1=1";
    
    $params = [];
    
    // For department_head, only show documents that have been passed to their department
    if ($user_role === 'department_head' && $user_dept_id) {
        $query .= " AND (
                    d.department_id = :dept_id 
                    OR d.current_department_id = :dept_id 
                    OR dfh.to_department_id = :dept_id
                    OR dfh.from_department_id = :dept_id
                  )";
        $params[':dept_id'] = $user_dept_id;
    }
    
    if ($date_from) {
        $query .= " AND DATE(d.uploaded_at) >= :date_from";
        $params[':date_from'] = $date_from;
    }
    
    if ($date_to) {
        $query .= " AND DATE(d.uploaded_at) <= :date_to";
        $params[':date_to'] = $date_to;
    }
    
    if ($status && $status !== 'all') {
        $query .= " AND d.status = :status";
        $params[':status'] = $status;
    }
    
    if ($user_id && $user_id !== 'all') {
        $query .= " AND d.uploaded_by = :user_id";
        $params[':user_id'] = $user_id;
    }
    
    $query .= " GROUP BY d.id ORDER BY d.uploaded_at DESC";
    
    $stmt = $db->prepare($query);
    
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    
    $stmt->execute();
    $reports = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Set headers for CSV download
    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="document-report-' . date('Y-m-d') . '.csv"');
    
    // Create CSV output
    $output = fopen('php://output', 'w');
    
    // Add CSV headers
    fputcsv($output, [
        'Title',
        'Description', 
        'Sended To',
        'Status',
        'Barcode',
        'Created By',
        'Received By',
        'Upload Date',
        'Received Date'
    ]);
    
    // Add data rows
    foreach ($reports as $report) {
        fputcsv($output, [
            $report['title'],
            $report['description'],
            $report['department_name'] ?: 'No Department',
            $report['status'],
            $report['barcode'],
            $report['uploaded_by_name'],
            $report['received_by_name'],
            $report['uploaded_at'],
            $report['received_at']
        ]);
    }
    
    fclose($output);
    exit();
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database error']);
}
?>
