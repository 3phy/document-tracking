<?php
/**
 * Environment Configuration Loader
 * Loads configuration from .env file or uses defaults
 */
class Env {
    private static $config = [];
    private static $loaded = false;

    /**
     * Load environment variables from .env file
     */
    public static function load() {
        if (self::$loaded) {
            return;
        }

        $envFile = __DIR__ . '/../../.env';
        
        if (file_exists($envFile)) {
            $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
            foreach ($lines as $line) {
                // Skip comments
                if (strpos(trim($line), '#') === 0) {
                    continue;
                }
                
                // Parse KEY=VALUE format
                if (strpos($line, '=') !== false) {
                    list($key, $value) = explode('=', $line, 2);
                    $key = trim($key);
                    $value = trim($value);
                    
                    // Remove quotes if present
                    $value = trim($value, '"\'');
                    
                    self::$config[$key] = $value;
                }
            }
        }
        
        self::$loaded = true;
    }

    /**
     * Get environment variable
     * @param string $key
     * @param mixed $default
     * @return mixed
     */
    public static function get($key, $default = null) {
        self::load();
        
        // Check loaded config first
        if (isset(self::$config[$key])) {
            return self::$config[$key];
        }
        
        // Check actual environment variable
        $value = getenv($key);
        if ($value !== false) {
            return $value;
        }
        
        return $default;
    }
}

// Auto-load on include
Env::load();
?>

