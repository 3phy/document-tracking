-- Direct SQL migration to fix barcode unique constraint
-- Use this if you prefer direct SQL without conditional checks
-- Run this in phpMyAdmin or MySQL command line

USE document_tracking;

-- Step 1: Drop the existing UNIQUE constraint on barcode
-- Note: If you get an error that the index doesn't exist, skip this step
-- The index name might be different in your database
ALTER TABLE documents DROP INDEX barcode;

-- Alternative Step 1: If above fails, try these common index names:
-- ALTER TABLE documents DROP INDEX idx_barcode;
-- ALTER TABLE documents DROP INDEX `barcode`;

-- Step 2: Add composite UNIQUE constraint on (barcode, department_id)
-- This allows same barcode with different department_id values
ALTER TABLE documents
ADD UNIQUE KEY uniq_barcode_department (barcode, department_id);

-- Verification: Show all barcode-related indexes
SHOW INDEXES FROM documents WHERE Column_name = 'barcode' OR Key_name LIKE '%barcode%';

