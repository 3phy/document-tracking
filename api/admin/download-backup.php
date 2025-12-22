<?php
require_once '../config/cors.php';
require_once '../config/jwt.php';

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

// Check if user is admin
if ($payload['role'] !== 'admin') {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Admin access required']);
    exit();
}

try {
    $filename = isset($_GET['file']) ? basename($_GET['file']) : '';
    
    if (empty($filename)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Filename is required']);
        exit();
    }
    
    // Security: Only allow .sql files
    if (pathinfo($filename, PATHINFO_EXTENSION) !== 'sql') {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid file type']);
        exit();
    }
    
    $backupDir = __DIR__ . '/../../backups';
    $filePath = $backupDir . '/' . $filename;
    
    if (!file_exists($filePath)) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Backup file not found']);
        exit();
    }
    
    // Set headers for file download
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    header('Content-Length: ' . filesize($filePath));
    header('Cache-Control: must-revalidate');
    header('Pragma: public');
    
    // Output file
    readfile($filePath);
    exit();
} catch (Exception $e) {
    http_response_code(500);
    error_log("Download backup error: " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Failed to download backup file']);
}
?>

