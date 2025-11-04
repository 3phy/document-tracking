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

// ✅ Verify token
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
$user_role = $payload['role'];

try {
    // ✅ Get user's department
    $user_dept_query = "SELECT department_id FROM users WHERE id = :user_id";
    $user_dept_stmt = $db->prepare($user_dept_query);
    $user_dept_stmt->bindParam(':user_id', $user_id);
    $user_dept_stmt->execute();
    $user_dept = $user_dept_stmt->fetch(PDO::FETCH_ASSOC);
    $user_department_id = $user_dept ? $user_dept['department_id'] : null;

    // ✅ Build base query (includes upload_dept + cancel info)
    if ($user_role === 'admin') {
        $query = "
            SELECT 
                d.*, 
                u.name AS uploaded_by_name, 
                r.name AS received_by_name, 
                cb.name AS canceled_by_name,
                dept.name AS department_name, 
                curr_dept.name AS current_department_name,
                upload_dept.name AS upload_department_name
            FROM documents d
            LEFT JOIN users u ON d.uploaded_by = u.id
            LEFT JOIN users r ON d.received_by = r.id
            LEFT JOIN users cb ON d.canceled_by = cb.id
            LEFT JOIN departments dept ON d.department_id = dept.id
            LEFT JOIN departments curr_dept ON d.current_department_id = curr_dept.id
            LEFT JOIN departments upload_dept ON d.upload_department_id = upload_dept.id
            ORDER BY d.uploaded_at DESC
        ";
    } else {
        if ($user_department_id) {
            $query = "
                SELECT 
                    d.*, 
                    u.name AS uploaded_by_name, 
                    r.name AS received_by_name, 
                    cb.name AS canceled_by_name,
                    dept.name AS department_name, 
                    curr_dept.name AS current_department_name,
                    upload_dept.name AS upload_department_name
                FROM documents d
                LEFT JOIN users u ON d.uploaded_by = u.id
                LEFT JOIN users r ON d.received_by = r.id
                LEFT JOIN users cb ON d.canceled_by = cb.id
                LEFT JOIN departments dept ON d.department_id = dept.id
                LEFT JOIN departments curr_dept ON d.current_department_id = curr_dept.id
                LEFT JOIN departments upload_dept ON d.upload_department_id = upload_dept.id
                WHERE d.current_department_id = :dept_id 
                      OR d.department_id = :dept_id 
                      OR d.uploaded_by = :user_id
                ORDER BY d.uploaded_at DESC
            ";
        } else {
            $query = "
                SELECT 
                    d.*, 
                    u.name AS uploaded_by_name, 
                    r.name AS received_by_name, 
                    cb.name AS canceled_by_name,
                    dept.name AS department_name, 
                    curr_dept.name AS current_department_name,
                    upload_dept.name AS upload_department_name
                FROM documents d
                LEFT JOIN users u ON d.uploaded_by = u.id
                LEFT JOIN users r ON d.received_by = r.id
                LEFT JOIN users cb ON d.canceled_by = cb.id
                LEFT JOIN departments dept ON d.department_id = dept.id
                LEFT JOIN departments curr_dept ON d.current_department_id = curr_dept.id
                LEFT JOIN departments upload_dept ON d.upload_department_id = upload_dept.id
                WHERE d.uploaded_by = :user_id
                ORDER BY d.uploaded_at DESC
            ";
        }
    }

    $stmt = $db->prepare($query);

    if ($user_role !== 'admin') {
        $stmt->bindParam(':user_id', $user_id);
        if ($user_department_id) {
            $stmt->bindParam(':dept_id', $user_department_id);
        }
    }

    $stmt->execute();
    $documents = $stmt->fetchAll(PDO::FETCH_ASSOC);

// ✅ Normalize statuses and cancellation display
foreach ($documents as &$doc) {
    $status = strtolower(trim($doc['status'] ?? ''));

    // Normalize any cancel/reject variants
    if (in_array($status, ['cancelled', 'canceled', 'reject', 'rejected'])) {
        $status = 'rejected';
    } elseif (empty($status)) {
        $status = 'pending'; // default fallback
    }

    // Set for frontend
    $doc['status'] = $status;
    $doc['display_status'] = ucfirst($status);

    // Ensure tooltip info is returned
    $doc['cancel_note'] = $doc['cancel_note'] ?? null;
    $doc['canceled_by_name'] = $doc['canceled_by_name'] ?? null;
    $doc['canceled_at'] = $doc['canceled_at'] ?? null;
}



    echo json_encode([
        'success' => true,
        'documents' => $documents
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
