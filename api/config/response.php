<?php
require_once __DIR__ . '/env.php';

/**
 * Response Helper
 * Provides standardized JSON response functions
 */
class Response {
    /**
     * Send success response
     * @param mixed $data Response data
     * @param string $message Optional message
     * @param int $code HTTP status code
     */
    public static function success($data = null, $message = null, $code = 200) {
        http_response_code($code);
        
        $response = ['success' => true];
        
        if ($message !== null) {
            $response['message'] = $message;
        }
        
        if ($data !== null) {
            if (is_array($data) && isset($data[0])) {
                // If it's a list, add it directly
                $response = array_merge($response, $data);
            } else {
                // Otherwise merge into response
                $response = array_merge($response, is_array($data) ? $data : ['data' => $data]);
            }
        }
        
        echo json_encode($response);
        exit();
    }

    /**
     * Send error response
     * @param string $message Error message
     * @param int $code HTTP status code
     * @param array $errors Optional additional error details
     */
    public static function error($message, $code = 400, $errors = null) {
        http_response_code($code);
        
        $response = [
            'success' => false,
            'message' => $message
        ];
        
        if ($errors !== null) {
            $response['errors'] = $errors;
        }
        
        echo json_encode($response);
        exit();
    }

    /**
     * Send method not allowed response
     */
    public static function methodNotAllowed() {
        self::error('Method not allowed', 405);
    }

    /**
     * Send unauthorized response
     */
    public static function unauthorized($message = 'Unauthorized') {
        self::error($message, 401);
    }

    /**
     * Send forbidden response
     */
    public static function forbidden($message = 'Forbidden') {
        self::error($message, 403);
    }

    /**
     * Send not found response
     */
    public static function notFound($message = 'Resource not found') {
        self::error($message, 404);
    }

    /**
     * Send server error response
     * @param string $message Error message (sanitized for production)
     * @param Exception $exception Optional exception for logging
     */
    public static function serverError($message = 'Internal server error', $exception = null) {
        if ($exception !== null) {
            error_log("Server error: " . $exception->getMessage());
            error_log("Stack trace: " . $exception->getTraceAsString());
        }
        
        // In production, don't expose error details
        try {
            $isDevelopment = Env::get('APP_ENV', 'production') === 'development';
            $errorMessage = $isDevelopment && $exception ? $exception->getMessage() : $message;
        } catch (Exception $e) {
            // If Env fails, just use the message
            $errorMessage = $message;
        }
        
        self::error($errorMessage, 500);
    }
}
?>

