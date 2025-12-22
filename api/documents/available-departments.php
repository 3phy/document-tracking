<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/auth.php';
require_once '../config/response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::methodNotAllowed();
}

$database = new Database();
$db = $database->getConnection();
$payload = Auth::requireAuth();

$document_id = isset($_GET['document_id']) ? (int)$_GET['document_id'] : 0;

if ($document_id <= 0) {
    Response::error('Document ID is required', 400);
}

try {
    $userId = (int)$payload['user_id'];
    
    // Get user's department
    $userStmt = $db->prepare("SELECT department_id FROM users WHERE id = ?");
    $userStmt->execute([$userId]);
    $user = $userStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$user || !$user['department_id']) {
        Response::error('User must belong to a department', 400);
    }
    
    $userDeptId = (int)$user['department_id'];
    
    // Get document
    $docStmt = $db->prepare("SELECT * FROM documents WHERE id = ?");
    $docStmt->execute([$document_id]);
    $doc = $docStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$doc) {
        Response::notFound('Document not found');
    }
    
    // Verify document is in user's department and received
    if ((int)$doc['current_department_id'] !== $userDeptId) {
        Response::error('Document is not in your department', 403);
    }
    
    if ($doc['status'] !== 'received') {
        Response::error('Document must be received before forwarding', 400);
    }
    
    // Get all active departments
    $deptStmt = $db->prepare("SELECT id, name FROM departments WHERE is_active = 1 ORDER BY name");
    $deptStmt->execute();
    $allDepartments = $deptStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Get departments already in routing path
    $pathStmt = $db->prepare("
        SELECT DISTINCT from_department_id AS dept FROM document_forwarding_history WHERE document_id = ?
        UNION
        SELECT DISTINCT to_department_id AS dept FROM document_forwarding_history WHERE document_id = ?
    ");
    $pathStmt->execute([$document_id, $document_id]);
    
    $routingPath = array_map(
        fn($row) => (int)$row['dept'],
        $pathStmt->fetchAll(PDO::FETCH_ASSOC)
    );
    
    // Add source and current department to excluded list
    if (!empty($doc['upload_department_id'])) {
        $routingPath[] = (int)$doc['upload_department_id'];
    }
    $routingPath[] = (int)$doc['current_department_id'];
    $routingPath[] = $userDeptId; // Can't forward to own department
    
    $routingPath = array_unique($routingPath);
    
    // Filter out departments already in path
    $availableDepartments = array_filter($allDepartments, function($dept) use ($routingPath) {
        return !in_array((int)$dept['id'], $routingPath);
    });
    
    // Re-index array
    $availableDepartments = array_values($availableDepartments);
    
    Response::success([
        'departments' => $availableDepartments,
        'excluded_departments' => $routingPath
    ]);
    
} catch (Exception $e) {
    Response::serverError('Failed to fetch available departments', $e);
}
?>

