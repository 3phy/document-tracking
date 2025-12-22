<?php
require_once __DIR__ . '/env.php';

/**
 * CORS Configuration
 * Handles Cross-Origin Resource Sharing headers
 */
class CORS {
    /**
     * Set CORS headers based on environment configuration
     */
    public static function setHeaders() {
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
        
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
        header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
        header("Access-Control-Allow-Credentials: true");
        header("Content-Type: application/json; charset=UTF-8");
        
        // Handle preflight requests
        if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
            http_response_code(200);
            exit();
        }
    }
}

// Auto-set headers
CORS::setHeaders();
?>
