<?php
require_once __DIR__ . '/env.php';

class JWT {
    private $secret_key;
    private $algorithm = "HS256";

    public function __construct() {
        $this->secret_key = Env::get('JWT_SECRET_KEY', 'mysupersecretkey');
        
        if (empty($this->secret_key) || $this->secret_key === 'mysupersecretkey') {
            error_log("WARNING: Using default JWT secret key. Change this in production!");
        }
    }

    public function encode($payload) {
        if (empty($this->secret_key)) {
            throw new Exception("JWT secret key is not configured");
        }

        $header = json_encode(['typ' => 'JWT', 'alg' => $this->algorithm]);
        $payload_json = json_encode($payload);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception("Failed to encode JWT payload");
        }
        
        $base64_header = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64_payload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload_json));
        
        $signature = hash_hmac('sha256', $base64_header . "." . $base64_payload, $this->secret_key, true);
        $base64_signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
        
        return $base64_header . "." . $base64_payload . "." . $base64_signature;
    }

    public function decode($jwt) {
        if (empty($jwt)) {
            return false;
        }

        $token_parts = explode('.', $jwt);
        
        if (count($token_parts) != 3) {
            return false;
        }
        
        // Decode with error handling
        $header_decoded = base64_decode(str_replace(['-', '_'], ['+', '/'], $token_parts[0]), true);
        $payload_decoded = base64_decode(str_replace(['-', '_'], ['+', '/'], $token_parts[1]), true);
        $signature_decoded = base64_decode(str_replace(['-', '_'], ['+', '/'], $token_parts[2]), true);
        
        // Check if base64 decoding was successful
        if ($header_decoded === false || $payload_decoded === false || $signature_decoded === false) {
            return false;
        }
        
        // Verify signature
        $expected_signature = hash_hmac('sha256', $token_parts[0] . "." . $token_parts[1], $this->secret_key, true);
        
        if (!hash_equals($signature_decoded, $expected_signature)) {
            return false;
        }
        
        $payload = json_decode($payload_decoded, true);
        
        // Check if JSON decoding was successful
        if (json_last_error() !== JSON_ERROR_NONE) {
            return false;
        }
        
        return $payload;
    }
}
?>
