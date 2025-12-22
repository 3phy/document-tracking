<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/jwt.php';

$database = new Database();
$db = $database->getConnection();
$jwt = new JWT();

// ✅ Collect headers & GET token (for preview)
$headers = function_exists('getallheaders') ? getallheaders() : [];
$auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';
$tokenFromGet = isset($_GET['token']) ? $_GET['token'] : null;

// ✅ Extract token from either Bearer header or ?token query
$token = null;
if (!empty($tokenFromGet)) {
    $token = $tokenFromGet;
} elseif (!empty($auth_header) && preg_match('/Bearer\s(\S+)/', $auth_header, $matches)) {
    $token = $matches[1];
}

// ✅ If still no token, block access
if (empty($token)) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Unauthorized: No token provided.']);
    exit();
}

// ✅ Decode token
$payload = $jwt->decode($token);
if (!$payload || !isset($payload['exp']) || $payload['exp'] < time()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Invalid or expired token']);
    exit();
}

$user_id = $payload['user_id'];
$user_role = $payload['role'];

// ✅ Get document ID
$document_id = isset($_GET['id']) ? intval($_GET['id']) : 0;
if (!$document_id) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Document ID is required']);
    exit();
}

// ✅ Check if this is a preview request
$isPreview = isset($_GET['preview']) && $_GET['preview'] == '1';

try {
    // ✅ Get user department
    $deptQuery = "SELECT department_id FROM users WHERE id = :user_id";
    $deptStmt = $db->prepare($deptQuery);
    $deptStmt->bindParam(':user_id', $user_id);
    $deptStmt->execute();
    $dept = $deptStmt->fetch(PDO::FETCH_ASSOC);
    $userDeptId = $dept ? $dept['department_id'] : null;

    // ✅ Fetch document (respect permissions)
    if ($user_role === 'admin') {
        $query = "SELECT * FROM documents WHERE id = :document_id";
    } elseif ($userDeptId) {
        $query = "SELECT * FROM documents WHERE id = :document_id 
                  AND (department_id = :dept_id OR uploaded_by = :user_id)";
    } else {
        $query = "SELECT * FROM documents WHERE id = :document_id AND uploaded_by = :user_id";
    }

    $stmt = $db->prepare($query);
    $stmt->bindParam(':document_id', $document_id);
    if ($user_role !== 'admin') {
        $stmt->bindParam(':user_id', $user_id);
        if ($userDeptId) $stmt->bindParam(':dept_id', $userDeptId);
    }
    $stmt->execute();
    $document = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$document) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Document not found or access denied']);
        exit();
    }

    // Resolve file path (handle both relative and absolute paths)
    $file_path = $document['file_path'];
    
    // If path is relative, resolve it relative to project root
    if (!file_exists($file_path)) {
        $relativePath = str_replace(['../', './', '\\'], ['', '', '/'], $file_path);
        $file_path = realpath(__DIR__ . '/../../' . $relativePath);
    }
    
    if (!$file_path || !file_exists($file_path)) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'File not found on server: ' . $document['file_path']]);
        exit();
    }
    
    $filename = $document['filename'] ?: basename($file_path);

    // ✅ Detect MIME type
    $mimeType = mime_content_type($file_path) ?: 'application/octet-stream';

    // ✅ Clean output buffer
    while (ob_get_level()) {
        ob_end_clean();
    }

    // ✅ Send correct headers depending on mode
    if ($isPreview) {
        // 👁 Inline preview in browser
        header('Content-Type: ' . $mimeType);
        header('Content-Disposition: inline; filename="' . basename($filename) . '"');
    } else {
        // 💾 Regular download
        header('Content-Description: File Transfer');
        header('Content-Type: ' . $mimeType);
        header('Content-Disposition: attachment; filename="' . basename($filename) . '"');
        header('Content-Length: ' . filesize($file_path));
        header('Cache-Control: must-revalidate');
        header('Pragma: public');
        header('Expires: 0');
    }

    // ✅ Stream file contents
    readfile($file_path);
    exit();

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Server error: ' . $e->getMessage()]);
    exit();
}
?>
