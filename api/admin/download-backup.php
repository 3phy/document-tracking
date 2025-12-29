<?php
require_once '../config/cors.php';
require_once '../config/auth.php';
require_once '../config/response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::methodNotAllowed();
}

// Require auth + admin + password confirmation
$payload = Auth::requireAuth();
Auth::requireAdmin($payload);
Auth::requirePasswordConfirmation($payload, 'backup_download');

try {
    $filename = isset($_GET['file']) ? basename($_GET['file']) : '';
    
    if (empty($filename)) {
        Response::error('Filename is required', 400);
    }
    
    // Security: Only allow .sql files
    if (pathinfo($filename, PATHINFO_EXTENSION) !== 'sql') {
        Response::error('Invalid file type', 400);
    }
    
    $backupDir = __DIR__ . '/../../backups';
    $filePath = $backupDir . '/' . $filename;
    
    if (!file_exists($filePath)) {
        Response::notFound('Backup file not found');
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
    error_log("Download backup error: " . $e->getMessage());
    Response::serverError('Failed to download backup file', $e);
}
?>

