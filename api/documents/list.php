<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/auth.php';
require_once '../config/response.php';

/* ===========================
   DEBUG (REMOVE IN PROD)
=========================== */
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

/* ===========================
   METHOD CHECK
=========================== */
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::methodNotAllowed();
}

/* ===========================
   AUTH
=========================== */
$payload = Auth::requireAuth();
$user_id   = (int)$payload['user_id'];
$user_role = $payload['role'];

/* ===========================
   DB CONNECTION
=========================== */
try {
    $db = (new Database())->getConnection();
} catch (Throwable $e) {
    error_log('DB ERROR: ' . $e->getMessage());
    Response::error('Database connection failed', 500);
}

/* ===========================
   MAIN
=========================== */
try {
    // Get user's department
    $stmt = $db->prepare("SELECT department_id FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    $user_department_id = $stmt->fetchColumn();

    if ($user_role === 'admin') {

        $stmt = $db->prepare("
            SELECT
                d.*,
                u.name AS uploaded_by_name,
                r.name AS received_by_name,
                cb.name AS canceled_by_name,
                dept.name AS department_name,
                curr.name AS current_department_name,
                upload.name AS upload_department_name
            FROM documents d
            LEFT JOIN users u ON d.uploaded_by = u.id
            LEFT JOIN users r ON d.received_by = r.id
            LEFT JOIN users cb ON d.canceled_by = cb.id
            LEFT JOIN departments dept ON d.department_id = dept.id
            LEFT JOIN departments curr ON d.current_department_id = curr.id
            LEFT JOIN departments upload ON d.upload_department_id = upload.id
            ORDER BY d.uploaded_at DESC
        ");
        $stmt->execute();

    } else {

        if ($user_department_id) {
            $stmt = $db->prepare("
                SELECT DISTINCT
                    d.*,
                    u.name AS uploaded_by_name,
                    r.name AS received_by_name,
                    cb.name AS canceled_by_name,
                    dept.name AS department_name,
                    curr.name AS current_department_name,
                    upload.name AS upload_department_name
                FROM documents d
                LEFT JOIN users u ON d.uploaded_by = u.id
                LEFT JOIN users r ON d.received_by = r.id
                LEFT JOIN users cb ON d.canceled_by = cb.id
                LEFT JOIN departments dept ON d.department_id = dept.id
                LEFT JOIN departments curr ON d.current_department_id = curr.id
                LEFT JOIN departments upload ON d.upload_department_id = upload.id
                LEFT JOIN document_forwarding_history dfh ON d.id = dfh.document_id
                WHERE (
                    d.current_department_id = ?
                    OR d.department_id = ?
                    OR d.upload_department_id = ?
                    OR d.uploaded_by = ?
                    OR dfh.from_department_id = ?
                    OR dfh.to_department_id = ?
                )
                ORDER BY d.uploaded_at DESC
            ");
            $stmt->execute([
                $user_department_id,
                $user_department_id,
                $user_department_id,
                $user_id,
                $user_department_id,
                $user_department_id
            ]);
        } else {
            $stmt = $db->prepare("
                SELECT
                    d.*,
                    u.name AS uploaded_by_name
                FROM documents d
                LEFT JOIN users u ON d.uploaded_by = u.id
                WHERE d.uploaded_by = ?
                ORDER BY d.uploaded_at DESC
            ");
            $stmt->execute([$user_id]);
        }
    }

    $documents = $stmt->fetchAll(PDO::FETCH_ASSOC);

    /* ===========================
       STATUS NORMALIZATION
    =========================== */
    $allowed = ['outgoing', 'pending', 'received', 'rejected'];

    foreach ($documents as &$doc) {
        $status = strtolower(trim((string)($doc['status'] ?? '')));
        if (!in_array($status, $allowed)) {
            $status = 'pending';
        }
        $doc['status'] = $status;
        $doc['display_status'] = ucfirst($status);

        $doc['cancel_note'] = $doc['cancel_note'] ?? null;
        $doc['canceled_by_name'] = $doc['canceled_by_name'] ?? null;
        $doc['canceled_at'] = $doc['canceled_at'] ?? null;
        
        // Ensure received_at is included
        $doc['received_at'] = $doc['received_at'] ?? null;
        $doc['received_by_name'] = $doc['received_by_name'] ?? null;
    }

    Response::success([
        'documents' => $documents
    ]);

} catch (Throwable $e) {
    error_log('LIST.PHP ERROR: ' . $e->getMessage());
    Response::serverError('Failed to fetch documents');
}
