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
    if (!isset($_FILES['backup_file']) || $_FILES['backup_file']['error'] !== UPLOAD_ERR_OK) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'No backup file uploaded']);
        exit();
    }
    
    $uploadedFile = $_FILES['backup_file'];
    
    // Validate file type
    if (pathinfo($uploadedFile['name'], PATHINFO_EXTENSION) !== 'sql') {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid file type. Only .sql files are allowed']);
        exit();
    }
    
    // Get database credentials
    $db_host = Env::get('DB_HOST', 'localhost');
    $db_name = Env::get('DB_NAME', 'document_tracking');
    $db_username = Env::get('DB_USERNAME', 'root');
    $db_password = Env::get('DB_PASSWORD', '');
    
    // Create temporary file for the uploaded backup
    $tempFile = sys_get_temp_dir() . '/' . uniqid('restore_') . '.sql';
    
    if (!move_uploaded_file($uploadedFile['tmp_name'], $tempFile)) {
        throw new Exception('Failed to save uploaded file');
    }
    
    // Try to find mysql in common locations (Windows XAMPP)
    $mysql = 'mysql';
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        // Common XAMPP paths
        $possiblePaths = [
            'C:\\xampp\\mysql\\bin\\mysql.exe',
            'C:\\Program Files\\xampp\\mysql\\bin\\mysql.exe',
            'C:\\wamp\\bin\\mysql\\mysql' . substr(phpversion(), 0, 3) . '\\bin\\mysql.exe',
        ];
        
        foreach ($possiblePaths as $path) {
            if (file_exists($path)) {
                $mysql = $path;
                break;
            }
        }
    }
    
    // Build mysql command to restore
    // Read the SQL file and execute it via PDO instead of command line for better compatibility
    $sqlContent = file_get_contents($tempFile);
    if ($sqlContent === false) {
        throw new Exception('Failed to read backup file');
    }
    
    // Clean up temp file
    unlink($tempFile);
    
    // Execute SQL statements
    $db = $database->getConnection();
    
    // Disable foreign key checks temporarily
    $db->exec('SET FOREIGN_KEY_CHECKS=0');
    
    // Split SQL file into individual statements
    $statements = array_filter(
        array_map('trim', explode(';', $sqlContent)),
        function($stmt) {
            return !empty($stmt) && !preg_match('/^--/', $stmt) && !preg_match('/^\/\*/', $stmt);
        }
    );
    
    try {
        $db->beginTransaction();
        
        foreach ($statements as $statement) {
            if (!empty(trim($statement))) {
                $db->exec($statement);
            }
        }
        
        $db->commit();
    } catch (Exception $e) {
        $db->rollBack();
        throw new Exception('Failed to restore database: ' . $e->getMessage());
    } finally {
        // Re-enable foreign key checks
        $db->exec('SET FOREIGN_KEY_CHECKS=1');
    }
    
    // Clean up temp file
    if (file_exists($tempFile)) {
        unlink($tempFile);
    }
    
    if ($returnVar !== 0) {
        $errorMsg = implode("\n", $output);
        error_log("Restore failed: " . $errorMsg);
        throw new Exception('Failed to restore database. Please ensure mysql is installed and the backup file is valid.');
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Database restored successfully'
    ]);
} catch (Exception $e) {
    http_response_code(500);
    error_log("Restore error: " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>

