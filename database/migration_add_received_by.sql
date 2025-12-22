-- Migration to add received_by field to document_forwarding_history
-- This tracks who actually received the document at each department
-- Run this script to add the received_by tracking capability

USE document_tracking;

-- Add received_by column (ignore error if column already exists)
-- Note: If column exists, you'll get an error but script will continue
ALTER TABLE document_forwarding_history 
ADD COLUMN received_by INT NULL AFTER forwarded_by;

-- Add received_at column
ALTER TABLE document_forwarding_history 
ADD COLUMN received_at TIMESTAMP NULL AFTER forwarded_at;

-- Add foreign key constraint (ignore error if constraint already exists)
ALTER TABLE document_forwarding_history
ADD CONSTRAINT fk_received_by FOREIGN KEY (received_by) REFERENCES users(id) ON DELETE SET NULL;

-- Add indexes (ignore error if index already exists)
CREATE INDEX idx_received_by ON document_forwarding_history(received_by);
CREATE INDEX idx_received_at ON document_forwarding_history(received_at);

SELECT 'Migration completed successfully! received_by field added to document_forwarding_history.' as message;

