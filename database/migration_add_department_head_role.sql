-- Migration: Add 'department_head' role to users table
-- This updates the enum to include the new department_head role

ALTER TABLE `users` 
MODIFY COLUMN `role` ENUM('admin', 'staff', 'department_head') DEFAULT 'staff';

