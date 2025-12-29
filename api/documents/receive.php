<?php
// api/documents/receive.php
// Receive a document by scanning its barcode/QR.
// Receiving should NOT remove it from the department list — list.php includes touched docs via history.

require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/jwt.php';
require_once __DIR__ . '/../utils/activity_logger.php';

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

$input = json_decode(file_get_contents('php://input'), true);
$barcode = trim($input['barcode'] ?? '');

if ($barcode === '') {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Barcode is required']);
    exit;
}

try {
    $database = new Database();
    $db = $database->getConnection();

    // User department
    $u = $db->prepare("SELECT department_id FROM users WHERE id = ?");
    $u->execute([$userId]);
    $user = $u->fetch(PDO::FETCH_ASSOC);
    $userDept = $user ? (int)$user['department_id'] : 0;

    if ($userDept <= 0) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'User must belong to a department']);
        exit;
    }

    // Handle QR code format: "Document ID: {id}" or direct barcode value
    $doc = null;
    
    // Check if QR code contains "Document ID: " format
    if (preg_match('/Document\s+ID:\s*(\d+)/i', $barcode, $matches)) {
        $documentId = (int)$matches[1];
        // Find document by ID
        $stmt = $db->prepare("SELECT * FROM documents WHERE id = ? LIMIT 1");
        $stmt->execute([$documentId]);
        $doc = $stmt->fetch(PDO::FETCH_ASSOC);
    } else {
        // Try to find by barcode directly
        $stmt = $db->prepare("SELECT * FROM documents WHERE barcode = ? LIMIT 1");
        $stmt->execute([$barcode]);
        $doc = $stmt->fetch(PDO::FETCH_ASSOC);
    }

    if (!$doc) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Document not found']);
        exit;
    }

    // Must be pending in your department (check department_id - the receiving department)
    // current_department_id will be updated when received, so we check department_id instead
    if ((int)$doc['department_id'] !== $userDept) {
        http_response_code(403);
        echo json_encode(['success' => false, 'message' => 'Document is not pending in your department']);
        exit;
    }

    // Already received
    if (strtolower($doc['status']) === 'received') {
        echo json_encode(['success' => true, 'message' => 'Document already received', 'document' => ['id' => (int)$doc['id']]]);
        exit;
    }

    // Update status -> received AND update current_department_id to the receiving department
    // This is when the document actually moves to the receiving department
    $upd = $db->prepare("UPDATE documents SET status='received', current_department_id=?, received_by=?, received_at=NOW(), updated_at=NOW() WHERE id=?");
    $upd->execute([$userDept, $userId, (int)$doc['id']]);

    // Update forwarding history to mark as received
    try {
        // Find the most recent forwarding entry for this document to this department
        $histCheck = $db->prepare(
            "SELECT id FROM document_forwarding_history 
             WHERE document_id = ? AND to_department_id = ? 
             ORDER BY forwarded_at DESC LIMIT 1"
        );
        $histCheck->execute([(int)$doc['id'], $userDept]);
        $histEntry = $histCheck->fetch(PDO::FETCH_ASSOC);
        
        if ($histEntry) {
            // Update existing entry with received_by and received_at
            $histUpdate = $db->prepare(
                "UPDATE document_forwarding_history 
                 SET received_by = ?, received_at = NOW() 
                 WHERE id = ?"
            );
            $histUpdate->execute([$userId, (int)$histEntry['id']]);
        } else {
            // Create new entry if none exists
            $fromDept = !empty($doc['upload_department_id']) ? (int)$doc['upload_department_id'] : $userDept;
            $hist = $db->prepare(
                "INSERT INTO document_forwarding_history 
                 (document_id, from_department_id, to_department_id, forwarded_by, received_by, forwarded_at, received_at)
                 VALUES (?, ?, ?, ?, ?, NOW(), NOW())"
            );
            $hist->execute([(int)$doc['id'], $fromDept, $userDept, $userId, $userId]);
        }
    } catch (Exception $e) {
        error_log('Receive history update failed: ' . $e->getMessage());
    }

    ActivityLogger::log($db, $userId, 'receive_document', "Received document '{$doc['title']}' (ID: " . (int)$doc['id'] . ")");

    echo json_encode([
        'success' => true,
        'message' => 'Document received successfully',
        'document' => [
            'id' => (int)$doc['id'],
            'status' => 'received'
        ]
    ]);
} catch (Exception $e) {
    error_log('Receive failed: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Receive failed']);
}
