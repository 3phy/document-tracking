<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/auth.php';
require_once '../config/response.php';
require_once '../utils/activity_logger.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::methodNotAllowed();
}

$database = new Database();
$db = $database->getConnection();
$payload = Auth::requireAuth();

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['document_id'], $input['to_department_id'])) {
    Response::error('Document ID and destination department are required', 400);
}

try {
    $documentId = (int)$input['document_id'];
    $toDeptId   = (int)$input['to_department_id'];
    $userId     = (int)$payload['user_id'];

    /* ======================================================
       1. GET USER DEPARTMENT
    ====================================================== */
    $userStmt = $db->prepare("SELECT department_id FROM users WHERE id = ?");
    $userStmt->execute([$userId]);
    $user = $userStmt->fetch(PDO::FETCH_ASSOC);

    if (!$user || !$user['department_id']) {
        Response::error('User must belong to a department', 400);
    }

    $userDeptId = (int)$user['department_id'];

    /* ======================================================
       2. GET DOCUMENT
    ====================================================== */
    $docStmt = $db->prepare("SELECT * FROM documents WHERE id = ?");
    $docStmt->execute([$documentId]);
    $doc = $docStmt->fetch(PDO::FETCH_ASSOC);

    if (!$doc) {
        Response::notFound('Document not found');
    }

    /* ======================================================
       3. BUSINESS RULE VALIDATIONS
    ====================================================== */

    // ❌ Sender cannot forward own document
    if ((int)$doc['uploaded_by'] === $userId) {
        Response::error('You cannot forward your own document', 403);
    }

    // ❌ Must be currently in user's department
    if ((int)$doc['current_department_id'] !== $userDeptId) {
        Response::error('Document is not in your department', 403);
    }

    // ❌ Must be received before forwarding
    if ($doc['status'] !== 'received') {
        Response::error('Document must be received before forwarding', 400);
    }

    // ❌ Cannot forward to own department
    if ($toDeptId === $userDeptId) {
        Response::error('You cannot forward to your own department', 400);
    }

    // ❌ Cannot forward back to source/upload department
    if (!empty($doc['upload_department_id']) && $toDeptId == $doc['upload_department_id']) {
        Response::error('You cannot forward back to the source department', 400);
    }

    /* ======================================================
       4. BLOCK DEPARTMENTS ALREADY IN ROUTING HISTORY
    ====================================================== */

    // Collect routing path (departments that already touched the document)
    $pathStmt = $db->prepare("
        SELECT DISTINCT from_department_id AS dept FROM document_forwarding_history WHERE document_id = ?
        UNION
        SELECT DISTINCT to_department_id AS dept FROM document_forwarding_history WHERE document_id = ?
    ");
    $pathStmt->execute([$documentId, $documentId]);

    $routingPath = array_map(
        fn($row) => (int)$row['dept'],
        $pathStmt->fetchAll(PDO::FETCH_ASSOC)
    );

    // Also include source & current department
    if (!empty($doc['upload_department_id'])) {
        $routingPath[] = (int)$doc['upload_department_id'];
    }
    $routingPath[] = (int)$doc['current_department_id'];

    if (in_array($toDeptId, array_unique($routingPath))) {
        Response::error('You cannot forward to a department already in the routing path', 400);
    }

    /* ======================================================
       5. UPDATE DOCUMENT (FORWARD TO NEXT DEPARTMENT)
       IMPORTANT:
       - We DO NOT delete previous history
       - We ONLY update department_id (receiving department) when forwarding
       - current_department_id stays the same until the document is received
       - department_id represents the receiving/destination department
    ====================================================== */
    $updateStmt = $db->prepare("
        UPDATE documents
        SET 
            department_id = ?,
            status = 'outgoing',
            updated_at = NOW()
        WHERE id = ?
    ");
    $updateStmt->execute([$toDeptId, $documentId]);

    /* ======================================================
       6. INSERT FORWARDING HISTORY (AUDIT TRAIL)
    ====================================================== */
    $historyStmt = $db->prepare("
        INSERT INTO document_forwarding_history
        (document_id, from_department_id, to_department_id, forwarded_by)
        VALUES (?, ?, ?, ?)
    ");
    $historyStmt->execute([
        $documentId,
        $userDeptId,
        $toDeptId,
        $userId
    ]);

    ActivityLogger::log(
        $db,
        $userId,
        'forward_document',
        "Forwarded document (ID: {$documentId}) from dept {$userDeptId} to dept {$toDeptId}"
    );

    /* ======================================================
       7. SUCCESS RESPONSE
    ====================================================== */
    Response::success([
        'message' => 'Document forwarded successfully',
        'document_id' => $documentId,
        'from_department_id' => $userDeptId,
        'to_department_id' => $toDeptId
    ]);

} catch (Exception $e) {
    Response::serverError('Forwarding failed', $e);
}
