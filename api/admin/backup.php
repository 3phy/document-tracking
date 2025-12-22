<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/jwt.php';
require_once '../config/env.php';

$database = new Database();
$jwt = new JWT();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
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
    // Get database credentials
    $db_host = Env::get('DB_HOST', 'localhost');
    $db_name = Env::get('DB_NAME', 'document_tracking');
    $db_username = Env::get('DB_USERNAME', 'root');
    $db_password = Env::get('DB_PASSWORD', '');
    
    // Create backups directory if it doesn't exist
    $backupDir = __DIR__ . '/../../backups';
    if (!is_dir($backupDir)) {
        if (!mkdir($backupDir, 0755, true)) {
            throw new Exception('Failed to create backups directory');
        }
    }
    
    // Generate backup filename
    $timestamp = date('Y-m-d_H-i-s');
    $backupFilename = "backup_{$db_name}_{$timestamp}.sql";
    $backupPath = $backupDir . '/' . $backupFilename;
    
    // Build mysqldump command
    // Try to find mysqldump in common locations (Windows XAMPP)
    $mysqldump = 'mysqldump';
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        // Common XAMPP paths
        $possiblePaths = [
            'C:\\xampp\\mysql\\bin\\mysqldump.exe',
            'C:\\Program Files\\xampp\\mysql\\bin\\mysqldump.exe',
            'C:\\wamp\\bin\\mysql\\mysql' . substr(phpversion(), 0, 3) . '\\bin\\mysqldump.exe',
        ];
        
        foreach ($possiblePaths as $path) {
            if (file_exists($path)) {
                $mysqldump = $path;
                break;
            }
        }
    }
    
    // Escape the command properly
    $command = sprintf(
        '%s --host=%s --user=%s --password=%s %s > %s',
        escapeshellarg($mysqldump),
        escapeshellarg($db_host),
        escapeshellarg($db_username),
        escapeshellarg($db_password),
        escapeshellarg($db_name),
        escapeshellarg($backupPath)
    );
    
    // Execute backup command
    $output = [];
    $returnVar = 0;
    exec($command . ' 2>&1', $output, $returnVar);
    
    if ($returnVar !== 0 || !file_exists($backupPath)) {
        $errorMsg = implode("\n", $output);
        error_log("Backup failed: " . $errorMsg);
        throw new Exception('Failed to create database backup. Please ensure mysqldump is installed and accessible. Error: ' . $errorMsg);
    }
    
    // Check if backup file was created and has content
    if (filesize($backupPath) === 0) {
        unlink($backupPath);
        throw new Exception('Backup file is empty. Please check database connection and permissions.');
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Database backup created successfully',
        'filename' => $backupFilename,
        'path' => $backupPath,
        'size' => filesize($backupPath),
        'created_at' => date('Y-m-d H:i:s')
    ]);
} catch (Exception $e) {
    http_response_code(500);
    error_log("Backup error: " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>

