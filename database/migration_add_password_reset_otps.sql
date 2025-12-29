-- Password Reset OTP Table (Forgot Password)
-- Stores hashed OTPs and short-lived reset tokens.

CREATE TABLE IF NOT EXISTS password_reset_otps (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  purpose VARCHAR(50) NOT NULL DEFAULT 'password_reset',
  otp_hash VARCHAR(255) NOT NULL,
  otp_expires_at DATETIME NOT NULL,
  reset_token_hash VARCHAR(255) DEFAULT NULL,
  token_expires_at DATETIME DEFAULT NULL,
  verified_at DATETIME DEFAULT NULL,
  used_at DATETIME DEFAULT NULL,
  attempts INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_created (user_id, created_at),
  INDEX idx_token (reset_token_hash),
  CONSTRAINT fk_password_reset_otps_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


