<?php
require_once __DIR__ . '/env.php';

class Database {
    private $host;
    private $db_name;
    private $username;
    private $password;
    private $conn;

    public function __construct() {
        $this->host = Env::get('DB_HOST', 'localhost');
        $this->db_name = Env::get('DB_NAME', 'document_tracking');
        $this->username = Env::get('DB_USERNAME', 'root');
        $this->password = Env::get('DB_PASSWORD', '');
    }

    public function getConnection() {
        $this->conn = null;
        
        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                $this->username,
                $this->password,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false
                ]
            );
        } catch(PDOException $exception) {
            // Log error but don't expose sensitive information
            error_log("Database connection error: " . $exception->getMessage());
            throw new Exception("Database connection failed");
        }
        
        return $this->conn;
    }
}
?>
