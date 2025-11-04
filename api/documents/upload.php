<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/jwt.php';

$database = new Database();
$db = $database->getConnection();
$jwt = new JWT();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
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

$user_id = $payload['user_id'];

// ✅ Validate inputs
if (!isset($_POST['title']) || !isset($_FILES['file']) || !isset($_POST['department_id'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Title, file, and department are required']);
    exit();
}

$title = $_POST['title'];
$description = isset($_POST['description']) ? $_POST['description'] : '';
$department_id = $_POST['department_id'];
$file = $_FILES['file'];

// ✅ Validate file
$allowed_types = ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'];
$file_extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));

if (!in_array($file_extension, $allowed_types)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid file type']);
    exit();
}

if ($file['size'] > 10 * 1024 * 1024) { // 10MB limit
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'File too large']);
    exit();
}

// ✅ Get uploader’s department
$dept_query = "SELECT department_id FROM users WHERE id = :user_id LIMIT 1";
$dept_stmt = $db->prepare($dept_query);
$dept_stmt->bindParam(':user_id', $user_id);
$dept_stmt->execute();
$current_department_id = $dept_stmt->fetchColumn();

if (!$current_department_id) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'You need to be assigned to a department before uploading documents. Please contact your administrator.'
    ]);
    exit();
}

// ✅ Generate barcode
$barcode = 'DOC' . time() . rand(1000, 9999);

// ✅ Upload directory path (filesystem)
$upload_dir = realpath(__DIR__ . '/../../uploads');

// ✅ Create uploads folder if missing
if (!$upload_dir) {
    $upload_dir = __DIR__ . '/../../uploads';
    mkdir($upload_dir, 0777, true);
}

// ✅ Generate safe file name
$filename = $barcode . '_' . basename($file['name']);
$save_path = $upload_dir . DIRECTORY_SEPARATOR . $filename;

// ✅ Move file to uploads directory
if (move_uploaded_file($file['tmp_name'], $save_path)) {
    try {
        // ✅ Store relative path only (for web access)
        $file_path = 'uploads/' . $filename;

        // ✅ Optional: detect routing rule
        $table_check = $db->query("SHOW TABLES LIKE 'document_routing'");
        $routing_table_exists = $table_check->rowCount() > 0;
        $routing_rule = null;

        if ($routing_table_exists) {
            $routing_query = "SELECT intermediate_department_id FROM document_routing 
                              WHERE from_department_id = :from_dept 
                              AND to_department_id = :to_dept 
                              AND is_active = 1";
            $routing_stmt = $db->prepare($routing_query);
            $routing_stmt->bindParam(':from_dept', $current_department_id);
            $routing_stmt->bindParam(':to_dept', $department_id);
            $routing_stmt->execute();
            $routing_rule = $routing_stmt->fetch(PDO::FETCH_ASSOC);
        }

        // ✅ Document starts as outgoing from uploader’s department
        $initial_status = 'outgoing';
        $upload_department_id = $current_department_id;

        $query = "INSERT INTO documents 
            (title, description, filename, file_path, file_size, file_type, barcode, 
             department_id, current_department_id, upload_department_id, uploaded_by, status, uploaded_at) 
            VALUES 
            (:title, :description, :filename, :file_path, :file_size, :file_type, :barcode, 
             :department_id, :current_department_id, :upload_department_id, :uploaded_by, :status, NOW())";

        $stmt = $db->prepare($query);
        $stmt->bindParam(':title', $title);
        $stmt->bindParam(':description', $description);
        $stmt->bindParam(':filename', $filename);
        $stmt->bindParam(':file_path', $file_path);
        $stmt->bindParam(':file_size', $file['size']);
        $stmt->bindParam(':file_type', $file_extension);
        $stmt->bindParam(':barcode', $barcode);
        $stmt->bindParam(':department_id', $department_id);
        $stmt->bindParam(':current_department_id', $current_department_id);
        $stmt->bindParam(':upload_department_id', $upload_department_id);
        $stmt->bindParam(':uploaded_by', $user_id);
        $stmt->bindParam(':status', $initial_status);

        if ($stmt->execute()) {
            // ✅ Log upload activity
            try {
                $logQuery = "INSERT INTO user_activities (user_id, action, description) VALUES (?, ?, ?)";
                $logStmt = $db->prepare($logQuery);
                $logStmt->execute([
                    $user_id,
                    'upload_document',
                    "Uploaded document '{$title}' and sent to department ID {$department_id}"
                ]);
            } catch (Exception $logError) {
                error_log("Could not log activity: " . $logError->getMessage());
            }

            echo json_encode([
                'success' => true,
                'message' => 'Document uploaded successfully',
                'barcode' => $barcode,
                'routing_info' => $routing_rule ? [
                    'has_intermediate' => !empty($routing_rule['intermediate_department_id']),
                    'intermediate_department_id' => $routing_rule['intermediate_department_id']
                ] : null
            ]);
        } else {
            unlink($save_path);
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to save document to database']);
        }

    } catch (Exception $e) {
        unlink($save_path);
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
    }
} else {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed to upload file']);
}
?>
