-- Migration to fix barcode unique constraint for multi-department routing
-- This allows the same barcode to exist multiple times with different department_id values
-- Run this migration to enable multi-department document routing
--
-- Date: 2025-12-29
-- Issue: UNIQUE(barcode) constraint prevents same file from being routed to multiple departments
-- Fix: Replace with composite UNIQUE(barcode, department_id) constraint

USE document_tracking;

-- Drop the existing UNIQUE constraint on barcode alone
-- Check if the constraint exists first to avoid errors
SET @dbname = DATABASE();
SET @tablename = 'documents';
SET @constraint_name = 'barcode';

SET @preparedStatement = (SELECT IF(
    (
        SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE
            (TABLE_SCHEMA = @dbname)
            AND (TABLE_NAME = @tablename)
            AND (CONSTRAINT_NAME = @constraint_name)
            AND (CONSTRAINT_TYPE = 'UNIQUE')
    ) > 0,
    CONCAT('ALTER TABLE ', @tablename, ' DROP INDEX ', @constraint_name),
    'SELECT 1'
));
PREPARE alterIfExists FROM @preparedStatement;
EXECUTE alterIfExists;
DEALLOCATE PREPARE alterIfExists;

-- Add composite UNIQUE constraint on (barcode, department_id)
-- This allows the same barcode to exist multiple times as long as department_id differs
SET @new_constraint_name = 'uniq_barcode_department';

SET @preparedStatement = (SELECT IF(
    (
        SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE
            (TABLE_SCHEMA = @dbname)
            AND (TABLE_NAME = @tablename)
            AND (CONSTRAINT_NAME = @new_constraint_name)
            AND (CONSTRAINT_TYPE = 'UNIQUE')
    ) > 0,
    'SELECT 1',
    CONCAT('ALTER TABLE ', @tablename, ' ADD UNIQUE KEY ', @new_constraint_name, ' (barcode, department_id)')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

SELECT 'Migration completed successfully! Barcode constraint changed from UNIQUE(barcode) to UNIQUE(barcode, department_id).' as message;

