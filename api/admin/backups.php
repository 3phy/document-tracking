<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/jwt.php';

$database = new Database();
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
    $backupDir = __DIR__ . '/../../backups';
    $backups = [];
    
    if (is_dir($backupDir)) {
        $files = scandir($backupDir);
        foreach ($files as $file) {
            if ($file !== '.' && $file !== '..' && pathinfo($file, PATHINFO_EXTENSION) === 'sql') {
                $filePath = $backupDir . '/' . $file;
                $backups[] = [
                    'filename' => $file,
                    'size' => filesize($filePath),
                    'created_at' => date('Y-m-d H:i:s', filemtime($filePath))
                ];
            }
        }
        
        // Sort by creation date (newest first)
        usort($backups, function($a, $b) {
            return strtotime($b['created_at']) - strtotime($a['created_at']);
        });
    }
    
    echo json_encode([
        'success' => true,
        'backups' => $backups
    ]);
} catch (Exception $e) {
    http_response_code(500);
    error_log("Backup history error: " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Failed to fetch backup history']);
}
?>

