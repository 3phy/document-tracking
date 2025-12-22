<?php
/**
 * Authentication Middleware Helper
 * Provides reusable authentication functions for API endpoints
 */
require_once __DIR__ . '/jwt.php';
require_once __DIR__ . '/database.php';

class Auth {
    /**
     * Get and verify JWT token from request headers
     * @return array|false Returns payload array on success, false on failure
     */
    public static function verifyToken() {
        $auth_header = '';
        
        // Try getallheaders() first (works on Apache)
        if (function_exists('getallheaders')) {
            $headers = getallheaders();
            $auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';
        }
        
        // Fallback to $_SERVER (works on Nginx and other servers)
        if (empty($auth_header)) {
            $auth_header = isset($_SERVER['HTTP_AUTHORIZATION']) 
                ? $_SERVER['HTTP_AUTHORIZATION'] 
                : '';
        }
        
        // Also check REDIRECT_HTTP_AUTHORIZATION (some PHP configurations)
        if (empty($auth_header)) {
            $auth_header = isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION']) 
                ? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] 
                : '';
        }

        if (empty($auth_header) || !preg_match('/Bearer\s(\S+)/', $auth_header, $matches)) {
            return false;
        }

        $token = $matches[1];
        $jwt = new JWT();
        $payload = $jwt->decode($token);

        if (!$payload) {
            return false;
        }

        // Check expiration
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            return false;
        }

        return $payload;
    }

    /**
     * Require authentication and return user payload
     * Sends 401 response and exits if authentication fails
     * @return array User payload
     */
    public static function requireAuth() {
        $payload = self::verifyToken();
        
        if (!$payload) {
            http_response_code(401);
            echo json_encode(['success' => false, 'message' => 'Invalid or expired token']);
            exit();
        }

        return $payload;
    }

    /**
     * Verify user is active in database
     * @param PDO $db Database connection
     * @param int $user_id User ID
     * @return array|false User data if active, false otherwise
     */
    public static function verifyUserActive($db, $user_id) {
        try {
            $query = "SELECT id, name, email, role, is_active, department_id 
                      FROM users 
                      WHERE id = :user_id";
            $stmt = $db->prepare($query);
            $stmt->bindParam(':user_id', $user_id);
            $stmt->execute();

            if ($stmt->rowCount() > 0) {
                $user = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if (!$user['is_active']) {
                    return false;
                }
                
                return $user;
            }
            
            return false;
        } catch (Exception $e) {
            error_log("Error verifying user: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Require admin role
     * Sends 403 response and exits if user is not admin
     * @param array $payload JWT payload
     */
    public static function requireAdmin($payload) {
        if (!isset($payload['role']) || $payload['role'] !== 'admin') {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'Admin access required']);
            exit();
        }
    }
}
?>

