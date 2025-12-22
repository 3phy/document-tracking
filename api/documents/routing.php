<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/auth.php';
require_once '../config/response.php';

try {
    $database = new Database();
    $db = $database->getConnection();
} catch (Exception $e) {
    error_log("Database connection failed in routing: " . $e->getMessage());
    Response::error('Database connection failed', 500);
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::methodNotAllowed();
}

// Verify token using Auth helper
$payload = Auth::requireAuth();

$user_id = $payload['user_id'];

try {
    // Get user's department
    $user_dept_query = "SELECT department_id FROM users WHERE id = :user_id";
    $user_dept_stmt = $db->prepare($user_dept_query);
    $user_dept_stmt->bindParam(':user_id', $user_id);
    $user_dept_stmt->execute();
    $user_dept = $user_dept_stmt->fetch(PDO::FETCH_ASSOC);
    $user_department_id = $user_dept ? $user_dept['department_id'] : null;

    if (!$user_department_id) {
        // Return empty routing info if user has no department
        Response::success([
            'user_department_id' => null,
            'routing_info' => []
        ], 'User has no department assigned - no routing available');
    }

    // Check if routing table exists
    try {
        $table_check = $db->query("SHOW TABLES LIKE 'document_routing'");
        $routing_table_exists = $table_check ? $table_check->rowCount() > 0 : false;
    } catch (Exception $e) {
        error_log("Error checking routing table: " . $e->getMessage());
        $routing_table_exists = false;
    }
    
    $routing_rules = [];
    
    if ($routing_table_exists) {
        // Check if intermediate_department_id column exists
        $column_check = $db->query("SHOW COLUMNS FROM document_routing LIKE 'intermediate_department_id'");
        $has_intermediate_column = $column_check && $column_check->rowCount() > 0;
        
        // Get routing information for the user's department
        if ($has_intermediate_column) {
            $routing_query = "SELECT 
                                dr.from_department_id,
                                dr.to_department_id,
                                dr.intermediate_department_id,
                                from_dept.name as from_department_name,
                                to_dept.name as to_department_name,
                                inter_dept.name as intermediate_department_name
                              FROM document_routing dr
                              LEFT JOIN departments from_dept ON dr.from_department_id = from_dept.id
                              LEFT JOIN departments to_dept ON dr.to_department_id = to_dept.id
                              LEFT JOIN departments inter_dept ON dr.intermediate_department_id = inter_dept.id
                              WHERE dr.from_department_id = :user_dept_id AND dr.is_active = 1
                              ORDER BY to_dept.name";
        } else {
            // Fallback for older table structure without intermediate_department_id
            $routing_query = "SELECT 
                                dr.from_department_id,
                                dr.to_department_id,
                                NULL as intermediate_department_id,
                                from_dept.name as from_department_name,
                                to_dept.name as to_department_name,
                                NULL as intermediate_department_name
                              FROM document_routing dr
                              LEFT JOIN departments from_dept ON dr.from_department_id = from_dept.id
                              LEFT JOIN departments to_dept ON dr.to_department_id = to_dept.id
                              WHERE dr.from_department_id = :user_dept_id AND dr.is_active = 1
                              ORDER BY to_dept.name";
        }
        
        try {
            $routing_stmt = $db->prepare($routing_query);
            $routing_stmt->bindParam(':user_dept_id', $user_department_id, PDO::PARAM_INT);
            $routing_stmt->execute();
            $routing_rules = $routing_stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (Exception $queryError) {
            error_log("Error fetching routing rules: " . $queryError->getMessage());
            $routing_rules = [];
        }
    }

    // Format routing information
    $routing_info = [];
    foreach ($routing_rules as $rule) {
        $path = [$rule['from_department_name']];
        if ($rule['intermediate_department_name']) {
            $path[] = $rule['intermediate_department_name'];
        }
        $path[] = $rule['to_department_name'];
        
        $routing_info[] = [
            'to_department_id' => $rule['to_department_id'],
            'to_department_name' => $rule['to_department_name'],
            'routing_path' => $path,
            'has_intermediate' => !empty($rule['intermediate_department_name']),
            'intermediate_department_name' => $rule['intermediate_department_name']
        ];
    }

    Response::success([
        'user_department_id' => $user_department_id,
        'routing_info' => $routing_info
    ]);
} catch (Exception $e) {
    Response::serverError('Failed to fetch routing information', $e);
}
?>

