<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/jwt.php';

$database = new Database();
$db = $database->getConnection();
$jwt = new JWT();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit();
}

// ✅ Verify token
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

$document_id = isset($_GET['document_id']) ? intval($_GET['document_id']) : 0;
if (!$document_id) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Document ID is required']);
    exit();
}

try {
    // ✅ Fetch document with department + cancellation info
    $docQuery = "
        SELECT 
            d.*, 
            ud.name  AS upload_department_name,
            cd.name  AS current_department_name,
            dd.name  AS destination_department_name,
            u.name   AS uploaded_by_name,
            rcv.name AS received_by_name,
            cb.name  AS canceled_by_name
        FROM documents d
        LEFT JOIN departments ud ON d.upload_department_id = ud.id
        LEFT JOIN departments cd ON d.current_department_id = cd.id
        LEFT JOIN departments dd ON d.department_id = dd.id
        LEFT JOIN users u   ON d.uploaded_by  = u.id
        LEFT JOIN users rcv ON d.received_by  = rcv.id
        LEFT JOIN users cb  ON d.canceled_by  = cb.id
        WHERE d.id = ?";
    $docStmt = $db->prepare($docQuery);
    $docStmt->execute([$document_id]);
    $document = $docStmt->fetch(PDO::FETCH_ASSOC);
    if (!$document) {
        echo json_encode(['success' => false, 'message' => 'Document not found']);
        exit();
    }

    // ✅ Fetch forwarding history
    $histQuery = "
        SELECT f.*, df.name AS from_department_name, dt.name AS to_department_name, u.name AS forwarded_by_name
        FROM document_forwarding_history f
        LEFT JOIN departments df ON f.from_department_id = df.id
        LEFT JOIN departments dt ON f.to_department_id   = dt.id
        LEFT JOIN users u ON f.forwarded_by = u.id
        WHERE f.document_id = ?
        ORDER BY f.forwarded_at ASC";
    $histStmt = $db->prepare($histQuery);
    $histStmt->execute([$document_id]);
    $forwardingHistory = $histStmt->fetchAll(PDO::FETCH_ASSOC);

    // ✅ Build routing details
    $routingDetails = [];

    // Source department (creator)
    $routingDetails[] = [
        'department_name' => $document['upload_department_name'] ?: 'Unknown Department',
        'action'          => 'created',
        'timestamp'       => $document['uploaded_at'],
        'user_name'       => $document['uploaded_by_name'] ?: 'System',
        'status'          => ucfirst($document['status']),
        'note'            => $document['cancel_note'],
        'canceled_by'     => $document['canceled_by_name'],
        'canceled_at'     => $document['canceled_at']
    ];

    // Intermediate forwards
    foreach ($forwardingHistory as $f) {
        $routingDetails[] = [
            'department_name' => $f['to_department_name'] ?: 'Unknown Department',
            'action'          => 'forwarded',
            'timestamp'       => $f['forwarded_at'],
            'user_name'       => $f['forwarded_by_name'] ?: 'System',
            'status'          => 'Pending'
        ];
    }

    // Destination / final department node (if received)
    if (strtolower($document['status']) === 'received') {
        $routingDetails[] = [
            'department_name' => $document['destination_department_name'] ?: 'Destination Department',
            'action'          => 'received',
            'timestamp'       => $document['received_at'] ?: end($forwardingHistory)['forwarded_at'] ?? $document['uploaded_at'],
            'user_name'       => $document['received_by_name'] ?: 'Admin User',
            'status'          => 'Received'
        ];
    }

    echo json_encode([
        'success' => true,
        'document' => [
            'id'          => $document['id'],
            'title'       => $document['title'],
            'status'      => $document['status'],
            'cancel_note' => $document['cancel_note'],
            'canceled_by' => $document['canceled_by_name'],
            'canceled_at' => $document['canceled_at']
        ],
        'routing_details' => $routingDetails
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
