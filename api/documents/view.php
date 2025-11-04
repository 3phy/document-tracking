<?php
require_once '../config/database.php';
require_once '../config/jwt.php';

$database = new Database();
$db = $database->getConnection();
$jwt = new JWT();

$headers = getallheaders();
$auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';
if (!empty($auth_header) && preg_match('/Bearer\s(\S+)/', $auth_header, $matches)) {
    $token = $matches[1];
    $payload = $jwt->decode($token);
    if (!$payload || $payload['exp'] < time()) {
        http_response_code(401);
        echo "Unauthorized";
        exit();
    }
}

$document_id = isset($_GET['id']) ? intval($_GET['id']) : 0;
if (!$document_id) {
    http_response_code(400);
    echo "Missing document ID";
    exit();
}

$query = "SELECT file_path, filename FROM documents WHERE id = :id LIMIT 1";
$stmt = $db->prepare($query);
$stmt->bindParam(':id', $document_id);
$stmt->execute();
$doc = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$doc) {
    http_response_code(404);
    echo "Document not found.";
    exit();
}

// Normalize file path (fix ../../ problem)
$relativePath = str_replace(['../', './', '\\'], '', $doc['file_path']);
$file_path = realpath(__DIR__ . '/../../' . $relativePath);


if (!$file_path || !file_exists($file_path)) {
    http_response_code(404);
    echo "File not found on server.";
    exit();
}


$ext = strtolower(pathinfo($file_path, PATHINFO_EXTENSION));
switch ($ext) {
    case 'pdf':
        header('Content-Type: application/pdf');
        break;
    case 'jpg':
    case 'jpeg':
        header('Content-Type: image/jpeg');
        break;
    case 'png':
        header('Content-Type: image/png');
        break;
    default:
        header('Content-Type: application/octet-stream');
}

header('Content-Disposition: inline; filename="' . basename($doc['filename']) . '"');
readfile($file_path);
?>
