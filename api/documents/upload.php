<?php
// api/documents/upload.php
// Upload one or more documents and send them to selected departments.
// Supports drag-and-drop multiple file uploads with automatic barcode/QR embedding.

// Use the same CORS pattern as other working endpoints (like list.php)
// cors.php handles OPTIONS before any includes, then sets headers for other requests
// Skip Content-Type for file uploads (will be set later for JSON response)
require_once __DIR__ . '/../config/cors.php';

// Re-set CORS headers with skipContentType for file uploads
CORS::setHeaders(true);

// Now require other dependencies
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/jwt.php';
require_once __DIR__ . '/../utils/activity_logger.php';
// document_processor.php removed - barcode/QR embedding disabled

// Set Content-Type to JSON for responses (not for the request body)
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

// ✅ Validate inputs
$description = trim($_POST['description'] ?? '');

// Support both single department_id (backward compatibility) and multiple department_ids
$departmentIds = [];

// CRITICAL: Parse department IDs from POST data
// Handle multiple formats to ensure all selected departments are captured
error_log("DEBUG: ========== DEPARTMENT IDs PARSING START ==========");
error_log("DEBUG: Checking _POST keys: " . implode(', ', array_keys($_POST)));
error_log("DEBUG: Raw _POST['department_ids'] exists: " . (isset($_POST['department_ids']) ? 'YES' : 'NO'));

// Check for new array format first (department_ids[] from FormData)
// Handle multiple possible formats PHP might receive the data in
if (isset($_POST['department_ids'])) {
    if (is_array($_POST['department_ids'])) {
        // FormData array notation: formData.append('department_ids[]', id) creates an array
        $departmentIds = $_POST['department_ids'];
        error_log("DEBUG: Received as array with " . count($departmentIds) . " items");
        error_log("DEBUG: Raw _POST['department_ids']: " . print_r($_POST['department_ids'], true));
        
        // Flatten nested arrays if any (shouldn't happen, but handle it)
        $flattened = [];
        foreach ($departmentIds as $item) {
            if (is_array($item)) {
                $flattened = array_merge($flattened, $item);
            } else {
                $flattened[] = $item;
            }
        }
        $departmentIds = $flattened;
        error_log("DEBUG: After flattening: " . count($departmentIds) . " items");
        error_log("DEBUG: Values: " . implode(', ', $departmentIds));
        error_log("DEBUG: Types: " . implode(', ', array_map('gettype', $departmentIds)));
    } elseif (is_string($_POST['department_ids'])) {
        // Legacy JSON string format (backward compatibility)
        $deptIdsRaw = trim($_POST['department_ids']);
        error_log("DEBUG: Received as string: '{$deptIdsRaw}'");
        
        // Try to decode as JSON
        $decoded = json_decode($deptIdsRaw, true);
        if (json_last_error() === JSON_ERROR_NONE && is_array($decoded) && !empty($decoded)) {
            $departmentIds = $decoded;
            error_log("DEBUG: Decoded JSON string to array with " . count($departmentIds) . " departments: " . implode(', ', $departmentIds));
        } else {
            // Try as comma-separated string
            $parts = explode(',', $deptIdsRaw);
            foreach ($parts as $part) {
                $part = trim($part);
                if (!empty($part) && is_numeric($part)) {
                    $departmentIds[] = (int)$part;
                }
            }
            error_log("DEBUG: Parsed comma-separated string to " . count($departmentIds) . " departments: " . implode(', ', $departmentIds));
        }
    }
} elseif (isset($_POST['department_id'])) {
    // Legacy single department format (backward compatibility)
    $singleDeptId = (int)($_POST['department_id'] ?? 0);
    if ($singleDeptId > 0) {
        $departmentIds = [$singleDeptId];
        error_log("DEBUG: Using legacy single department format: {$singleDeptId}");
    }
}

// CRITICAL: Also check for indexed array format (department_ids[0], department_ids[1], etc.)
// Some PHP configurations or form submissions might use this format
if (empty($departmentIds)) {
    $indexedDeptIds = [];
    $index = 0;
    while (isset($_POST["department_ids[{$index}]"])) {
        $deptId = $_POST["department_ids[{$index}]"];
        if (is_numeric($deptId)) {
            $indexedDeptIds[] = (int)$deptId;
        }
        $index++;
    }
    if (!empty($indexedDeptIds)) {
        $departmentIds = $indexedDeptIds;
        error_log("DEBUG: Found indexed array format with " . count($departmentIds) . " departments: " . implode(', ', $departmentIds));
    }
}

// CRITICAL: Force type normalization - ensure all are integers
// This prevents any string/number type issues that could cause routing problems
$departmentIds = array_map('intval', $departmentIds);

// Filter and validate department IDs - ensure they're all integers > 0
// CRITICAL: This ensures we have a clean array of unique, valid department IDs
$validatedIds = [];
foreach ($departmentIds as $id) {
    $id = (int)$id;
    if ($id > 0 && !in_array($id, $validatedIds)) {
        $validatedIds[] = $id;
    }
}
$departmentIds = $validatedIds;

error_log("DEBUG: After validation: " . count($departmentIds) . " unique department IDs");
error_log("DEBUG: ============================================");

error_log("INFO: ========== FINAL DEPARTMENT VALIDATION ==========");
error_log("INFO: Final validated department list: " . implode(', ', $departmentIds) . " (total: " . count($departmentIds) . ")");
error_log("INFO: Department IDs array contents: " . print_r($departmentIds, true));
error_log("INFO: =================================================");

if (empty($departmentIds)) {
    error_log("ERROR: No valid departments found after parsing");
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'At least one department must be selected']);
    exit;
}

if (count($departmentIds) < 2) {
    error_log("WARNING: Only " . count($departmentIds) . " department(s) in final list. Expected multiple departments if user selected multiple.");
}

error_log("INFO: Final department list to process: " . implode(', ', $departmentIds) . " (total: " . count($departmentIds) . ")");

// ✅ Handle multiple files (new format) or single file (backward compatibility)
$files = [];
$titles = [];

// Check for multiple files format
// When FormData.append('files[]', file) is used, PHP receives it as $_FILES['files']
// with array structure: $_FILES['files']['name'][0], $_FILES['files']['name'][1], etc.
if (isset($_FILES['files']) && is_array($_FILES['files']['name'])) {
    // Multiple files format
    $fileCount = count($_FILES['files']['name']);
    error_log("Processing {$fileCount} files");
    for ($i = 0; $i < $fileCount; $i++) {
        if (isset($_FILES['files']['error'][$i]) && $_FILES['files']['error'][$i] === UPLOAD_ERR_OK) {
            $files[] = [
                'name' => $_FILES['files']['name'][$i],
                'type' => $_FILES['files']['type'][$i] ?? '',
                'tmp_name' => $_FILES['files']['tmp_name'][$i],
                'error' => $_FILES['files']['error'][$i],
                'size' => $_FILES['files']['size'][$i] ?? 0
            ];
            // Get title for this file
            $fileTitle = '';
            if (isset($_POST['titles']) && is_array($_POST['titles']) && isset($_POST['titles'][$i])) {
                $fileTitle = trim($_POST['titles'][$i]);
            }
            $titles[] = $fileTitle;
            error_log("File {$i}: {$files[count($files)-1]['name']}, Title: {$fileTitle}");
        } else {
            $errorCode = $_FILES['files']['error'][$i] ?? 'unknown';
            error_log("File {$i} upload error: {$errorCode}");
        }
    }
} elseif (isset($_FILES['file'])) {
    // Single file format (backward compatibility)
    if ($_FILES['file']['error'] === UPLOAD_ERR_OK) {
        $files[] = $_FILES['file'];
        $titles[] = isset($_POST['title']) ? trim($_POST['title']) : '';
    }
}

if (empty($files)) {
    // Debug information
    $debugInfo = [
        'files_received' => isset($_FILES['files']),
        'files_structure' => isset($_FILES['files']) ? 'array' : 'not set',
        'file_received' => isset($_FILES['file']),
        'files_count' => isset($_FILES['files']) && is_array($_FILES['files']['name']) ? count($_FILES['files']['name']) : 0,
        '_files_keys' => array_keys($_FILES),
    ];
    error_log('No files received. Debug info: ' . json_encode($debugInfo));
    
    http_response_code(400);
    echo json_encode([
        'success' => false, 
        'message' => 'At least one file is required',
        'debug' => $debugInfo // Remove this in production
    ]);
    exit;
}

// ✅ Storage setup
$uploadDir = realpath(__DIR__ . '/../../uploads');
if ($uploadDir === false) {
    $base = __DIR__ . '/../../uploads';
    if (!is_dir($base) && !mkdir($base, 0777, true)) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to create uploads directory']);
        exit;
    }
    $uploadDir = realpath($base);
}

$docsDir = $uploadDir . DIRECTORY_SEPARATOR . 'documents';
if (!is_dir($docsDir) && !mkdir($docsDir, 0777, true)) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed to create documents upload directory']);
    exit;
}

// Basic allow-list
$allowed = ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'];

// ✅ DB connection
try {
    $database = new Database();
    $db = $database->getConnection();

    // Uploader department (source/upload department)
    $userStmt = $db->prepare('SELECT department_id FROM users WHERE id = ?');
    $userStmt->execute([$userId]);
    $user = $userStmt->fetch(PDO::FETCH_ASSOC);
    $uploadDepartmentId = $user ? (int)$user['department_id'] : 0;

    if ($uploadDepartmentId <= 0) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'User must be assigned to a department to upload']);
        exit;
    }

    // CRITICAL: Create a working copy of department IDs to ensure it's not modified during processing
    // Exclude uploader's own department ID from routing destinations
    // The uploader's department ID must remain excluded by default
    $workingDepartmentIds = array_filter($departmentIds, function($deptId) use ($uploadDepartmentId) {
        return (int)$deptId !== $uploadDepartmentId;
    });
    $workingDepartmentIds = array_values($workingDepartmentIds); // Re-index array after filtering
    
    // CRITICAL: Ensure we're using the filtered array for all processing
    $departmentIds = $workingDepartmentIds;
    
    error_log("INFO: After excluding uploader's department ({$uploadDepartmentId}), remaining department IDs: " . implode(', ', $departmentIds) . " (total: " . count($departmentIds) . ")");
    error_log("INFO: Department IDs array structure: " . print_r($departmentIds, true));
    
    // Validate that at least one department remains after exclusion
    if (empty($departmentIds)) {
        error_log("ERROR: No valid departments remaining after excluding uploader's department ({$uploadDepartmentId})");
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'At least one department (other than your own) must be selected']);
        exit;
    }
    
    // CRITICAL: Verify we have multiple departments if expected
    if (count($departmentIds) === 0) {
        error_log("ERROR: Department IDs array is empty after filtering!");
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'No valid departments to route documents to']);
        exit;
    }

    // CRITICAL: DO NOT prepare statements here - they will be prepared fresh inside the loop
    // This prevents PDO from retaining bound values across iterations
    // Prepared statements will be created fresh for each department iteration

    $createdDocuments = [];
    $errors = [];

    // Validate arrays before processing
    if (empty($files)) {
        error_log("ERROR: Files array is empty!");
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'No files to upload']);
        exit;
    }
    
    if (empty($departmentIds)) {
        error_log("ERROR: Department IDs array is empty!");
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'No departments selected']);
        exit;
    }
    
    // CRITICAL: Log received departments BEFORE database insert loop
    error_log("BACKEND RECEIVED DEPARTMENTS: " . json_encode($departmentIds));
    error_log("BACKEND RECEIVED DEPARTMENTS COUNT: " . count($departmentIds));
    error_log("BACKEND RECEIVED DEPARTMENTS DETAILS: " . print_r($departmentIds, true));
    
    // Log total expected records
    $totalFiles = count($files);
    $totalDepartments = count($departmentIds);
    $expectedRecords = $totalFiles * $totalDepartments;
    
    error_log("INFO: ========================================");
    error_log("INFO: UPLOAD PROCESS STARTING");
    error_log("INFO: ========================================");
    error_log("INFO: Files to process: {$totalFiles}");
    error_log("INFO: File names: " . implode(', ', array_map(function($f) { return $f['name'] ?? 'unknown'; }, $files)));
    error_log("INFO: Departments to process: {$totalDepartments}");
    error_log("INFO: Department IDs: " . implode(', ', $departmentIds));
    error_log("INFO: Expected tracking records: {$expectedRecords} ({$totalFiles} files × {$totalDepartments} departments)");
    error_log("INFO: ========================================");

    // Process each file - CRITICAL: This outer loop must iterate through ALL files
    $fileCounter = 0;
    foreach ($files as $fileIndex => $file) {
        $fileCounter++;
        error_log("INFO: ===== Processing FILE {$fileCounter} of {$totalFiles} =====");
        error_log("INFO: ===== Processing file " . ($fileIndex + 1) . " of {$totalFiles} =====");
        if (!isset($file['tmp_name']) || $file['error'] !== UPLOAD_ERR_OK) {
            $errors[] = "File upload error for file: " . ($file['name'] ?? 'unknown');
            continue;
        }

        $originalName = basename($file['name']);
        $ext = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));

        if (!in_array($ext, $allowed, true)) {
            $errors[] = "File type not allowed: {$originalName}";
            continue;
        }

        // Generate unique barcode for this file (same barcode for all departments receiving this file)
        $barcode = strtoupper(bin2hex(random_bytes(8)));

        // Store file with unique name
        $safeBase = preg_replace('/[^a-zA-Z0-9._-]/', '_', pathinfo($originalName, PATHINFO_FILENAME));
        $storedName = $safeBase . '_' . date('Ymd_His') . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
        $storedPath = $docsDir . DIRECTORY_SEPARATOR . $storedName;

        if (!move_uploaded_file($file['tmp_name'], $storedPath)) {
            $errors[] = "Failed to save file: {$originalName}";
            continue;
        }

        // Get title for this file (default to filename without extension)
        $fileTitle = $titles[$fileIndex] ?? '';
        if (empty($fileTitle)) {
            $lastDotIndex = strrpos($originalName, '.');
            $fileTitle = $lastDotIndex > 0 ? substr($originalName, 0, $lastDotIndex) : $originalName;
        }

        // Embed barcode and QR code on first page (we'll get document ID after insert)
        // For now, we'll process the file and embed barcode, then update with document ID later
        // Actually, we need to create the document first to get the ID for QR code
        
        // Create document records for each department (same file, same barcode)
        $fileDocumentIds = [];
        $relativePath = 'uploads' . DIRECTORY_SEPARATOR . 'documents' . DIRECTORY_SEPARATOR . $storedName;

        // Ensure we process ALL selected departments
        // Log before loop to confirm we have all departments
        error_log("INFO: File '{$originalName}' will be sent to " . count($departmentIds) . " department(s): " . implode(', ', $departmentIds));
        
        // CRITICAL: This inner loop must iterate through ALL departments for EACH file
        // This creates the cartesian product: every file × every department
        // NO department should be skipped - each iteration MUST create a record
        $processedDeptIds = []; // Track which department IDs were actually processed
        
        // CRITICAL: Verify departmentIds array is still intact and not modified
        $deptIdsForThisFile = $departmentIds; // Use a local copy to ensure it's not modified
        $expectedDeptCount = count($deptIdsForThisFile);
        
        error_log("INFO: ========== Starting department loop for file '{$originalName}' ==========");
        error_log("INFO: Department IDs array to process: " . print_r($deptIdsForThisFile, true));
        error_log("INFO: Department IDs to process: " . implode(', ', $deptIdsForThisFile));
        error_log("INFO: Total departments expected: {$expectedDeptCount}");
        
        // CRITICAL: Loop through each selected department ID - use ID as authoritative identifier for routing
        // This loop MUST process ALL department IDs, not just the first one
        foreach ($deptIdsForThisFile as $arrayIndex => $departmentId) {
            // Convert to integer to ensure we're using the actual department ID value
            $originalDeptId = $departmentId; // Keep original for logging
            $departmentId = (int)$departmentId; // Ensure it's an integer
            
            // Validate department ID is a positive integer
            if ($departmentId <= 0) {
                error_log("ERROR: Invalid department ID at array index {$arrayIndex}: '{$originalDeptId}' (converted to {$departmentId}) - skipping");
                continue;
            }
            
            // Check if this department ID has already been processed for this file (prevent duplicates)
            if (in_array($departmentId, $processedDeptIds)) {
                error_log("WARNING: Department ID {$departmentId} already processed for file '{$originalName}' - skipping duplicate");
                continue;
            }
            
            error_log("INFO: ========== Routing file '{$originalName}' to Department ID: {$departmentId} ==========");
            error_log("INFO: Array index: {$arrayIndex}, Department ID (authoritative): {$departmentId}");
            
            // CRITICAL: Log on every iteration - this must show different department IDs
            error_log("BACKEND INSERT → File={$originalName}, DeptID={$departmentId}");
            
            // CRITICAL: Use local variable from loop - do NOT reuse from outside
            $deptId = (int)$departmentId; // Explicit local copy with type casting
            
            $recordCreated = false;
            try {
                // CRITICAL: Prepare a FRESH statement for each department iteration
                // This prevents PDO from retaining bound values from previous iterations
                $insert = $db->prepare(
                    "INSERT INTO documents (title, description, filename, file_path, barcode, department_id, current_department_id, uploaded_by, status, upload_department_id, created_at, updated_at)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?, NOW(), NOW())"
                );
                
                if (!$insert) {
                    $errorInfo = $db->errorInfo();
                    throw new Exception("Failed to prepare INSERT statement: " . ($errorInfo[2] ?? 'Unknown error'));
                }
                
                error_log("INFO: Creating routing record: File '{$originalName}' → Department ID: {$deptId}");
                
                // CRITICAL: Execute with fresh statement and local $deptId variable
                // This ensures each department gets its own isolated insert operation
                $executeResult = $insert->execute([
                    $fileTitle,
                    $description,
                    $originalName,
                    $relativePath, // Same file path for all departments receiving this file
                    $barcode, // Same barcode for all departments receiving this file
                    $deptId, // Use local department ID as destination identifier
                    $deptId, // Current department is the destination
                    $userId,
                    $uploadDepartmentId,
                ]);

                if (!$executeResult) {
                    $errorInfo = $insert->errorInfo();
                    $errorMsg = "Database insert failed for Department ID {$deptId}: " . ($errorInfo[2] ?? 'Unknown error');
                    error_log("ERROR: {$errorMsg}");
                    error_log("ERROR: SQL Error Info: " . print_r($errorInfo, true));
                    // CRITICAL: Stop execution if insert fails
                    throw new Exception("Upload failed: Could not create document for department ID {$deptId}. " . ($errorInfo[2] ?? 'Unknown database error'));
                }

                $documentId = (int)$db->lastInsertId();
                if ($documentId <= 0) {
                    throw new Exception("Failed to get document ID after insert for Department ID {$deptId} (lastInsertId returned: {$documentId})");
                }
                
                error_log("INFO: ✓✓✓ SUCCESS: Document ID {$documentId} created for File '{$originalName}' → Department ID: {$deptId} ✓✓✓");
                $fileDocumentIds[] = $documentId;
                $recordCreated = true;
                
                // Track this department ID as processed - use local $deptId variable
                $processedDeptIds[] = $deptId;
                error_log("INFO: Department ID {$deptId} added to processed list. Processed so far: " . implode(', ', $processedDeptIds));
                
                // CRITICAL: Destroy the prepared statement to ensure no value retention
                $insert = null;

                // Log initial forwarding history using local $deptId variable
                try {
                    // CRITICAL: Prepare fresh statement for history insert too
                    $histInsert = $db->prepare(
                        "INSERT INTO document_forwarding_history (document_id, from_department_id, to_department_id, forwarded_by, forwarded_at)
                         VALUES (?, ?, ?, ?, NOW())"
                    );
                    $histInsert->execute([$documentId, $uploadDepartmentId, $deptId, $userId]);
                    error_log("INFO: Forwarding history logged: Document {$documentId} from Department {$uploadDepartmentId} to Department ID {$deptId}");
                    $histInsert = null; // Destroy to prevent reuse
                } catch (Exception $e) {
                    error_log('WARNING: Upload history insert failed for document ' . $documentId . ' to Department ID ' . $deptId . ': ' . $e->getMessage());
                    // Don't fail the whole process if history logging fails
                }

                // Activity log using local $deptId variable
                try {
                    ActivityLogger::log($db, $userId, 'upload_document', "Uploaded document '{$fileTitle}' (ID: {$documentId}, File: {$originalName}) to department ID: {$deptId}");
                } catch (Exception $e) {
                    error_log('WARNING: Activity log failed for document ' . $documentId . ' to Department ID ' . $deptId . ': ' . $e->getMessage());
                    // Don't fail the whole process if activity logging fails
                }

                // Store document record with local $deptId as destination identifier
                $createdDocuments[] = [
                    'id' => $documentId,
                    'title' => $fileTitle,
                    'barcode' => $barcode,
                    'filename' => $originalName,
                    'file_path' => $relativePath,
                    'status' => 'pending',
                    'department_id' => $deptId, // Use local department ID as authoritative identifier
                    'current_department_id' => $deptId, // Current department is the destination
                    'upload_department_id' => $uploadDepartmentId,
                ];
                error_log("INFO: Document record stored: ID {$documentId}, File '{$originalName}', Department ID: {$deptId}");
            } catch (Exception $e) {
                error_log("ERROR: ========== FAILED to create document for File '{$originalName}' → Department ID: {$deptId} ==========");
                error_log("ERROR: Exception message: " . $e->getMessage());
                error_log("ERROR: Exception details: " . $e->getTraceAsString());
                // CRITICAL: Stop execution if insert fails
                http_response_code(500);
                echo json_encode([
                    'success' => false,
                    'message' => "Upload failed: Could not create document for department ID {$deptId}. " . $e->getMessage()
                ]);
                exit;
            }
            
            if (!$recordCreated) {
                error_log("ERROR: Department ID {$deptId} was NOT processed successfully for file '{$originalName}'");
                // CRITICAL: Stop execution if record was not created
                http_response_code(500);
                echo json_encode([
                    'success' => false,
                    'message' => "Upload failed: Department ID {$deptId} was not processed successfully for file '{$originalName}'"
                ]);
                exit;
            } else {
                error_log("INFO: ✓ Department ID {$deptId} processed successfully for file '{$originalName}'");
            }
        }
        
        // CRITICAL: Verify all departments were processed for this file using actual department IDs
        // Use the local copy to ensure we're checking against the correct array
        $expectedDeptIds = $deptIdsForThisFile;
        $missingDeptIds = array_diff($expectedDeptIds, $processedDeptIds);
        
        error_log("INFO: ========== Department Processing Summary for File '{$originalName}' ==========");
        error_log("INFO: Expected Department IDs (from array): " . implode(', ', $expectedDeptIds));
        error_log("INFO: Processed Department IDs: " . implode(', ', $processedDeptIds));
        error_log("INFO: Expected count: " . count($expectedDeptIds) . ", Processed count: " . count($processedDeptIds));
        
        if (!empty($missingDeptIds)) {
            error_log("ERROR: MISSING! These Department IDs were NOT processed: " . implode(', ', $missingDeptIds));
            error_log("ERROR: This indicates a bug - all selected departments must receive the file!");
        }
        
        // CRITICAL: Hard assertion - must match expected count
        if (count($processedDeptIds) !== count($expectedDeptIds)) {
            $errorMsg = "CRITICAL ERROR: Department routing mismatch for file '{$originalName}'. Expected " . count($expectedDeptIds) . " departments but only processed " . count($processedDeptIds) . ". Expected: " . implode(', ', $expectedDeptIds) . " | Processed: " . implode(', ', $processedDeptIds);
            error_log("ERROR: " . $errorMsg);
            error_log("ERROR: This is a critical error - not all selected departments received the file!");
            throw new Exception($errorMsg);
        } else {
            error_log("INFO: ✓ File '{$originalName}' complete: " . count($processedDeptIds) . " records created for Department IDs: " . implode(', ', $processedDeptIds));
        }
        error_log("INFO: Progress: {$fileCounter}/{$totalFiles} files processed, " . count($createdDocuments) . " total records created so far");
        error_log("INFO: Expected so far: " . ($fileCounter * $totalDepartments) . " records");
    }

    // Final verification
    $actualRecords = count($createdDocuments);
    error_log("INFO: ===== Upload Summary =====");
    error_log("INFO: Files processed: {$totalFiles}");
    error_log("INFO: Departments per file: {$totalDepartments}");
    error_log("INFO: Expected records: {$expectedRecords}");
    error_log("INFO: Actual records created: {$actualRecords}");
    
    if ($actualRecords !== $expectedRecords) {
        error_log("WARNING: Record count mismatch! Expected {$expectedRecords} but created {$actualRecords}");
    } else {
        error_log("INFO: SUCCESS - All expected records created correctly!");
    }

    // If no documents were created, return error
    if (empty($createdDocuments)) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to create document records. ' . implode(' ', $errors)
        ]);
        exit;
    }

    // Return success with all created documents
    $fileCount = count($files);
    $deptCount = count($departmentIds);
    $totalRecords = count($createdDocuments);
    
    echo json_encode([
        'success' => true,
        'message' => "{$fileCount} file" . ($fileCount > 1 ? 's' : '') . " uploaded successfully to {$deptCount} department" . ($deptCount > 1 ? 's' : '') . " ({$totalRecords} tracking records created)",
        'documents' => $createdDocuments,
        'file_count' => $fileCount,
        'department_count' => $deptCount,
        'document_count' => $totalRecords
    ]);
} catch (Exception $e) {
    error_log('Upload failed: ' . $e->getMessage());
    error_log('Upload stack trace: ' . $e->getTraceAsString());
    http_response_code(500);
    $errorMessage = 'Upload failed';
    // In development, show more details
    if (Env::get('APP_ENV', 'production') === 'development') {
        $errorMessage = 'Upload failed: ' . $e->getMessage();
    }
    echo json_encode(['success' => false, 'message' => $errorMessage]);
}
