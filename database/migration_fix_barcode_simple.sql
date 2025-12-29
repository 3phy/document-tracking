-- Simple SQL migration to fix barcode unique constraint
-- NO INFORMATION_SCHEMA queries - safe for all MySQL users
-- Run this in phpMyAdmin or MySQL command line

USE document_tracking;

-- Step 1: Check what indexes exist on barcode column first
-- Run this to see the current index name:
SHOW INDEXES FROM documents WHERE Column_name = 'barcode';

-- Step 2: Drop the existing UNIQUE constraint on barcode
-- Replace 'barcode' with the actual Key_name from Step 1 if different
ALTER TABLE documents DROP INDEX barcode;

-- If Step 2 fails with "Unknown key 'barcode'", try these alternatives:
-- ALTER TABLE documents DROP INDEX idx_barcode;
-- ALTER TABLE documents DROP INDEX `barcode`;

-- Step 3: Add composite UNIQUE constraint on (barcode, department_id)
-- This allows same barcode with different department_id values
ALTER TABLE documents
ADD UNIQUE KEY uniq_barcode_department (barcode, department_id);

-- Step 4: Verify the new constraint was created
SHOW INDEXES FROM documents WHERE Key_name = 'uniq_barcode_department';

