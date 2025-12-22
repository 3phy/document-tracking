<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../config/auth.php';
require_once '../config/response.php';

$database = new Database();
$db = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::methodNotAllowed();
}

// Verify token and require admin
$payload = Auth::requireAuth();
Auth::requireAdmin($payload);

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

if (!$input || !isset($input['from_department_id']) || !isset($input['to_department_id'])) {
    Response::error('From and to department IDs are required', 400);
}

$from_department_id = $input['from_department_id'];
$to_department_id = $input['to_department_id'];

try {
    // Check if routing table exists
    $table_check = $db->query("SHOW TABLES LIKE 'document_routing'");
    $routing_table_exists = $table_check->rowCount() > 0;
    
    if (!$routing_table_exists) {
        Response::error('Routing system not initialized. Please run migration script.', 400);
    }
    
    // Check if departments exist
    $dept_check = "SELECT id, name FROM departments WHERE id IN (?, ?) AND is_active = 1";
    $dept_stmt = $db->prepare($dept_check);
    $dept_stmt->execute([$from_department_id, $to_department_id]);
    $departments = $dept_stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (count($departments) !== 2) {
        Response::error('One or both departments not found or inactive', 400);
    }
    
    // Prevent routing from a department to itself
    if ($from_department_id == $to_department_id) {
        Response::error('Cannot create routing from a department to itself', 400);
    }
    
    // Check if routing already exists
    $existing_check = "SELECT id FROM document_routing WHERE from_department_id = ? AND to_department_id = ?";
    $existing_stmt = $db->prepare($existing_check);
    $existing_stmt->execute([$from_department_id, $to_department_id]);
    $existing = $existing_stmt->fetch();
    
    if ($existing) {
        Response::error('Routing already exists for this path', 400);
    }
    
    // Find intermediate department using routing preferences
    $intermediate_department_id = null;
    
    // Check if there's a department that both can route through
    $preference_query = "SELECT drp1.can_route_through as intermediate_dept_id, d.name as intermediate_dept_name
                        FROM department_routing_preferences drp1
                        JOIN department_routing_preferences drp2 ON drp1.can_route_through = drp2.can_route_through
                        JOIN departments d ON drp1.can_route_through = d.id
                        WHERE drp1.department_id = ? AND drp2.department_id = ? 
                        AND drp1.is_active = 1 AND drp2.is_active = 1
                        LIMIT 1";
    
    $preference_stmt = $db->prepare($preference_query);
    $preference_stmt->execute([$from_department_id, $to_department_id]);
    $preference = $preference_stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($preference) {
        $intermediate_department_id = $preference['intermediate_dept_id'];
    }
    
    // Create the routing rule
    $insert_query = "INSERT INTO document_routing (from_department_id, to_department_id, intermediate_department_id) 
                     VALUES (?, ?, ?)";
    $insert_stmt = $db->prepare($insert_query);
    $result = $insert_stmt->execute([$from_department_id, $to_department_id, $intermediate_department_id]);
    
    if ($result) {
        // Get department names for response
        $from_dept_name = '';
        $to_dept_name = '';
        $intermediate_dept_name = '';
        
        foreach ($departments as $dept) {
            if ($dept['id'] == $from_department_id) {
                $from_dept_name = $dept['name'];
            }
            if ($dept['id'] == $to_department_id) {
                $to_dept_name = $dept['name'];
            }
        }
        
        if ($intermediate_department_id) {
            $intermediate_query = "SELECT name FROM departments WHERE id = ?";
            $intermediate_stmt = $db->prepare($intermediate_query);
            $intermediate_stmt->execute([$intermediate_department_id]);
            $intermediate_dept = $intermediate_stmt->fetch(PDO::FETCH_ASSOC);
            $intermediate_dept_name = $intermediate_dept['name'];
        }
        
        $routing_path = [$from_dept_name];
        if ($intermediate_dept_name) {
            $routing_path[] = $intermediate_dept_name;
        }
        $routing_path[] = $to_dept_name;
        
        Response::success([
            'routing' => [
                'from_department_id' => $from_department_id,
                'to_department_id' => $to_department_id,
                'intermediate_department_id' => $intermediate_department_id,
                'routing_path' => $routing_path,
                'path_string' => implode(' → ', $routing_path)
            ]
        ], 'Routing created successfully');
    } else {
        Response::error('Failed to create routing', 500);
    }
    
} catch (Exception $e) {
    Response::serverError('Failed to create routing', $e);
}
?>
