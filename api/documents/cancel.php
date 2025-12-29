<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/jwt.php';
require_once '../utils/activity_logger.php';

$database = new Database();
$db = $database->getConnection();
$jwt = new JWT();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

// ✅ Verify token
$auth_header = '';
if (function_exists('getallheaders')) {
    $headers = getallheaders();
    $auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';
} else {
    $auth_header = isset($_SERVER['HTTP_AUTHORIZATION']) ? $_SERVER['HTTP_AUTHORIZATION'] : '';
}

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

// ✅ Parse JSON input
$input = json_decode(file_get_contents('php://input'), true);
if (!$input || !isset($input['document_id'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Document ID is required']);
    exit();
}

$document_id = intval($input['document_id']);
$note = isset($input['note']) ? trim($input['note']) : null;

try {
    // ✅ Get user department
    $deptQuery = "SELECT department_id FROM users WHERE id = ?";
    $deptStmt = $db->prepare($deptQuery);
    $deptStmt->execute([$payload['user_id']]);
    $dept = $deptStmt->fetch(PDO::FETCH_ASSOC);
    $userDeptId = $dept ? $dept['department_id'] : null;

    if (!$userDeptId) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'You must be assigned to a department to cancel documents']);
        exit();
    }

    // ✅ Get document
    $checkQuery = "
        SELECT d.*, u.name AS uploaded_by_name 
        FROM documents d
        LEFT JOIN users u ON d.uploaded_by = u.id
        WHERE d.id = ?
    ";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->execute([$document_id]);
    $document = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if (!$document) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Document not found']);
        exit();
    }

    // ✅ Cannot cancel own uploaded document
    if ((int)$document['uploaded_by'] === (int)$payload['user_id']) {
        http_response_code(403);
        echo json_encode(['success' => false, 'message' => 'You cannot cancel your own document']);
        exit();
    }

    // ✅ Ensure cancellable status
    if (!in_array(strtolower($document['status']), ['pending', 'outgoing', 'received'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Document cannot be cancelled in its current state']);
        exit();
    }

    // ✅ Only the current department can cancel the document
    $canCancel = ((int)$document['current_department_id'] === (int)$userDeptId);

    if (!$canCancel) {
        http_response_code(403);
        echo json_encode(['success' => false, 'message' => 'You are not authorized to cancel this document. Only the current department can cancel documents.']);
        exit();
    }

    // ✅ Update document to rejected (not "cancelled")
    $updateQuery = "
        UPDATE documents
        SET 
            status = 'rejected',
            cancel_note = :note,
            canceled_by = :user_id,
            canceled_at = NOW(),
            updated_at = NOW()
        WHERE id = :document_id
    ";
    $updateStmt = $db->prepare($updateQuery);
    $updateStmt->bindParam(':note', $note);
    $updateStmt->bindParam(':user_id', $payload['user_id']);
    $updateStmt->bindParam(':document_id', $document_id);
    $updateStmt->execute();

    ActivityLogger::log(
        $db,
        (int)$payload['user_id'],
        'cancel_document',
        "Cancelled document '{$document['title']}' (ID: {$document_id}) - marked as rejected"
    );

    // ✅ Return fresh document state to frontend
    echo json_encode([
        'success' => true,
        'message' => 'Document cancelled successfully and marked as rejected.',
        'document' => [
            'id' => $document_id,
            'status' => 'rejected',
            'display_status' => 'Rejected',
            'cancel_note' => $note,
            'canceled_by' => $payload['user_id'],
            'canceled_at' => date('Y-m-d H:i:s')
        ]
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}
?>
