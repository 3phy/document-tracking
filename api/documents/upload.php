<?php
// api/documents/upload.php
// Upload a document and send it to the selected department.

require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/jwt.php';
require_once __DIR__ . '/../config/env.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// ✅ Auth
$headers = getallheaders();
$token = $headers['Authorization'] ?? ($headers['authorization'] ?? '');
$token = str_replace('Bearer ', '', $token);

if (!$token) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'No token provided']);
    exit;
}

try {
    $jwt = new JWT();
    $payload = $jwt->decode($token);
    
    if (!$payload || (isset($payload['exp']) && $payload['exp'] < time())) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Invalid or expired token']);
        exit;
    }
    
    $userId = (int)$payload['user_id'];
} catch (Exception $e) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Invalid token']);
    exit;
}

// ✅ Validate inputs
$title = trim($_POST['title'] ?? '');
$description = trim($_POST['description'] ?? '');
$toDepartmentId = (int)($_POST['department_id'] ?? 0);

if ($title === '' || $toDepartmentId <= 0 || !isset($_FILES['file'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'title, department_id, and file are required']);
    exit;
}

$file = $_FILES['file'];
if (!isset($file['tmp_name']) || $file['error'] !== UPLOAD_ERR_OK) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'File upload error']);
    exit;
}

// ✅ Storage
$uploadDir = realpath(__DIR__ . '/../../uploads');
if ($uploadDir === false) {
    $base = __DIR__ . '/../../uploads';
    if (!is_dir($base) && !mkdir($base, 0777, true)) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to create uploads directory']);
        exit;
    }
    $uploadDir = realpath($base);
}

$docsDir = $uploadDir . DIRECTORY_SEPARATOR . 'documents';
if (!is_dir($docsDir) && !mkdir($docsDir, 0777, true)) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed to create documents upload directory']);
    exit;
}

$originalName = basename($file['name']);
$ext = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));

// Basic allow-list (matches your frontend accept)
$allowed = ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'];
if (!in_array($ext, $allowed, true)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'File type not allowed']);
    exit;
}

$safeBase = preg_replace('/[^a-zA-Z0-9._-]/', '_', pathinfo($originalName, PATHINFO_FILENAME));
$storedName = $safeBase . '_' . date('Ymd_His') . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
$storedPath = $docsDir . DIRECTORY_SEPARATOR . $storedName;

if (!move_uploaded_file($file['tmp_name'], $storedPath)) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed to save uploaded file']);
    exit;
}

// Store relative path for view/download endpoints (relative to project root)
$relativePath = 'uploads' . DIRECTORY_SEPARATOR . 'documents' . DIRECTORY_SEPARATOR . $storedName;

// ✅ DB
try {
    $database = new Database();
    $db = $database->getConnection();

    // Uploader department (source/upload department)
    $userStmt = $db->prepare('SELECT department_id FROM users WHERE id = ?');
    $userStmt->execute([$userId]);
    $user = $userStmt->fetch(PDO::FETCH_ASSOC);
    $uploadDepartmentId = $user ? (int)$user['department_id'] : 0;

    if ($uploadDepartmentId <= 0) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'User must be assigned to a department to upload']);
        exit;
    }

    // Barcode
    $barcode = strtoupper(bin2hex(random_bytes(8)));

    // Insert document (matches your SQL schema)
    $insert = $db->prepare(
        "INSERT INTO documents (title, description, filename, file_path, barcode, department_id, current_department_id, uploaded_by, status, upload_department_id, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?, NOW(), NOW())"
    );
    $insert->execute([
        $title,
        $description,
        $originalName,
        $relativePath,
        $barcode,
        $toDepartmentId,
        $toDepartmentId,
        $userId,
        $uploadDepartmentId,
    ]);

    $documentId = (int)$db->lastInsertId();

    // Log initial touch as history (source dept stays seeing it)
    try {
        $hist = $db->prepare(
            "INSERT INTO document_forwarding_history (document_id, from_department_id, to_department_id, forwarded_by, forwarded_at)
             VALUES (?, ?, ?, ?, NOW())"
        );
        $hist->execute([$documentId, $uploadDepartmentId, $toDepartmentId, $userId]);
    } catch (Exception $e) {
        error_log('Upload history insert failed: ' . $e->getMessage());
    }

    // Activity log (optional)
    try {
        $act = $db->prepare("INSERT INTO user_activities (user_id, action, description, created_at) VALUES (?, ?, ?, NOW())");
        $act->execute([$userId, 'upload_document', "Uploaded document '{$title}'"]);
    } catch (Exception $e) {}

    echo json_encode([
        'success' => true,
        'message' => 'Document uploaded successfully',
        'document' => [
            'id' => $documentId,
            'title' => $title,
            'barcode' => $barcode,
            'filename' => $originalName,
            'file_path' => $relativePath,
            'status' => 'pending',
            'department_id' => $toDepartmentId,
            'current_department_id' => $toDepartmentId,
            'upload_department_id' => $uploadDepartmentId,
        ]
    ]);
} catch (Exception $e) {
    error_log('Upload failed: ' . $e->getMessage());
    error_log('Upload stack trace: ' . $e->getTraceAsString());
    http_response_code(500);
    $errorMessage = 'Upload failed';
    // In development, show more details
    if (Env::get('APP_ENV', 'production') === 'development') {
        $errorMessage = 'Upload failed: ' . $e->getMessage();
    }
    echo json_encode(['success' => false, 'message' => $errorMessage]);
}
