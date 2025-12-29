<?php
/**
 * CORS Configuration
 * Handles Cross-Origin Resource Sharing headers
 */

// Handle OPTIONS FIRST - before any includes
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    $allowed_origins = ['http://localhost:3000', 'http://127.0.0.1:3000'];
    $allow_origin = in_array($origin, $allowed_origins) ? $origin : $allowed_origins[0];
    
    header("Access-Control-Allow-Origin: $allow_origin");
    header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH");
    header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-Confirm-Token, Accept");
    header("Access-Control-Allow-Credentials: true");
    header("Access-Control-Max-Age: 3600");
    http_response_code(200);
    exit(0);
}

// Now load env for other requests
require_once __DIR__ . '/env.php';

class CORS {
    /**
     * Set CORS headers based on environment configuration
     * @param bool $skipContentType Skip setting Content-Type header (useful for file uploads)
     */
    public static function setHeaders($skipContentType = false) {
        $allowedOrigins = Env::get('CORS_ALLOWED_ORIGINS', 'http://localhost:3000');
        $origins = array_map('trim', explode(',', $allowedOrigins));
        
        // Get the origin from the request
        $origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : '';
        
        // Check if origin is allowed
        if (in_array($origin, $origins) || in_array('*', $origins)) {
            header("Access-Control-Allow-Origin: " . ($origin ?: '*'));
        } else {
            // Default to first allowed origin if request origin doesn't match
            header("Access-Control-Allow-Origin: " . $origins[0]);
        }
        
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH");
        header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-Confirm-Token, Accept");
        header("Access-Control-Allow-Credentials: true");
        header("Access-Control-Max-Age: 3600");
        
        // Only set Content-Type if not skipping (for file uploads)
        if (!$skipContentType) {
        header("Content-Type: application/json; charset=UTF-8");
        }
    }
}

// Auto-set headers for non-OPTIONS requests
CORS::setHeaders();
?>
