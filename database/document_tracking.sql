-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 04, 2025 at 10:13 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `document_tracking`
--

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`id`, `name`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Human Resources', 'HR department for employee management and policies', 1, '2025-09-21 07:54:59', '2025-09-21 07:54:59'),
(2, 'Finance', 'Financial department for accounting and budgeting', 0, '2025-09-21 07:54:59', '2025-09-21 08:36:14'),
(3, 'IT Department', 'Information Technology department for technical support', 1, '2025-09-21 07:54:59', '2025-09-21 07:54:59'),
(4, 'Operations', 'Operations department for daily business operations', 0, '2025-09-21 07:54:59', '2025-09-21 08:30:16'),
(5, 'Marketing', 'Marketing department for promotional activities', 0, '2025-09-21 07:54:59', '2025-09-21 08:30:23'),
(6, 'Legal', 'Legal department for compliance and contracts', 0, '2025-09-21 07:54:59', '2025-09-21 08:30:36'),
(7, 'MIS Department', 'Management Information Service', 1, '2025-09-21 08:33:13', '2025-09-21 08:35:35'),
(8, 'Sample', 'Sample-edit', 0, '2025-09-21 08:40:04', '2025-09-21 08:40:16');

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

CREATE TABLE `documents` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `filename` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` int(11) NOT NULL,
  `file_type` varchar(100) NOT NULL,
  `barcode` varchar(100) NOT NULL,
  `status` enum('outgoing','pending','received') DEFAULT 'outgoing',
  `department_id` int(11) NOT NULL,
  `current_department_id` int(11) DEFAULT NULL,
  `uploaded_by` int(11) NOT NULL,
  `received_by` int(11) DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `received_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `documents`
--

INSERT INTO `documents` (`id`, `title`, `description`, `filename`, `file_path`, `file_size`, `file_type`, `barcode`, `status`, `department_id`, `current_department_id`, `uploaded_by`, `received_by`, `uploaded_at`, `received_at`, `created_at`, `updated_at`) VALUES
(1, 'sample', 'sample', 'DOC17584413624906_user.png', '../../uploads/DOC17584413624906_user.png', 25515, 'png', 'DOC17584413624906', 'received', 3, NULL, 1, 2, '2025-09-21 07:56:02', '2025-09-21 08:07:49', '2025-09-21 07:56:02', '2025-09-21 08:07:49'),
(2, 'Sample 2', 'Sample2', 'DOC17584438562318_power-supply.docx', '../../uploads/DOC17584438562318_power-supply.docx', 205520, 'docx', 'DOC17584438562318', 'received', 3, NULL, 1, 3, '2025-09-21 08:37:36', '2025-09-21 08:39:36', '2025-09-21 08:37:36', '2025-09-21 08:39:36'),
(3, 'sample 3', 'sample 3', 'DOC17584442319080_CRIM PASSERS.jpeg', '../../uploads/DOC17584442319080_CRIM PASSERS.jpeg', 129735, 'jpeg', 'DOC17584442319080', 'received', 3, NULL, 1, 3, '2025-09-21 08:43:51', '2025-09-21 08:49:46', '2025-09-21 08:43:51', '2025-09-21 08:49:46'),
(4, 'Sample 4', 'Sample 4', 'DOC17584446761976_soldering-joint (1).docx', '../../uploads/DOC17584446761976_soldering-joint (1).docx', 22634, 'docx', 'DOC17584446761976', 'received', 1, NULL, 1, 2, '2025-09-21 08:51:16', '2025-09-21 08:54:35', '2025-09-21 08:51:16', '2025-09-21 08:54:35'),
(5, 'asdas', 'dsadsa', 'DOC17584450626616_user.png', '../../uploads/DOC17584450626616_user.png', 25515, 'png', 'DOC17584450626616', 'outgoing', 3, NULL, 1, NULL, '2025-09-21 08:57:42', NULL, '2025-09-21 08:57:42', '2025-09-21 08:57:42'),
(6, 'dsad', 'asdsd', 'DOC17584451028137_user.png', '../../uploads/DOC17584451028137_user.png', 25515, 'png', 'DOC17584451028137', 'outgoing', 1, NULL, 3, NULL, '2025-09-21 08:58:22', NULL, '2025-09-21 08:58:22', '2025-09-21 08:58:22'),
(7, 'weweew', 'qweqeqw', 'DOC17595927509658_BSCS3C-GClassCodes.txt', '../../uploads/DOC17595927509658_BSCS3C-GClassCodes.txt', 173, 'txt', 'DOC17595927509658', 'pending', 3, NULL, 1, NULL, '2025-10-04 15:45:50', NULL, '2025-10-04 15:45:50', '2025-10-04 15:46:47'),
(8, 'iuwar', 'awuedawbhuj', 'DOC17596001258915_OPERSYST_OBTL_2025-LEC-Ver.7.0.pdf', '../../uploads/DOC17596001258915_OPERSYST_OBTL_2025-LEC-Ver.7.0.pdf', 852125, 'pdf', 'DOC17596001258915', 'pending', 3, 1, 2, NULL, '2025-10-04 17:48:45', NULL, '2025-10-04 17:48:45', '2025-10-04 18:59:46'),
(9, 'tuktuk', 'tinghtinh', 'DOC17596029304648_Moon.jpg', '../../uploads/DOC17596029304648_Moon.jpg', 153503, 'jpg', 'DOC17596029304648', 'pending', 7, 1, 2, NULL, '2025-10-04 18:35:30', NULL, '2025-10-04 18:35:30', '2025-10-04 19:00:13');

-- --------------------------------------------------------

--
-- Table structure for table `system_logs`
--

CREATE TABLE `system_logs` (
  `id` int(11) NOT NULL,
  `level` enum('error','warning','info','debug') NOT NULL,
  `message` text NOT NULL,
  `context` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`context`)),
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_settings`
--

CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `system_settings`
--

INSERT INTO `system_settings` (`id`, `setting_key`, `setting_value`, `description`, `updated_at`) VALUES
(1, 'system_name', 'Document Tracking System', 'Name of the system', '2025-09-21 08:38:29'),
(2, 'max_file_size', '10', 'Maximum file size in MB', '2025-09-21 08:38:29'),
(3, 'allowed_file_types', 'pdf,doc,docx,xls,xlsx,jpg,jpeg,png', 'Allowed file extensions', '2025-09-21 08:38:29'),
(4, 'auto_backup', '1', 'Enable automatic backup', '2025-09-21 08:38:29'),
(5, 'backup_frequency', 'daily', 'Backup frequency', '2025-09-21 08:38:29'),
(6, 'email_notifications', '1', 'Enable email notifications', '2025-09-21 08:38:29'),
(7, 'session_timeout', '30', 'Session timeout in minutes', '2025-09-21 08:38:29');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','staff') DEFAULT 'staff',
  `department_id` int(11) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `department_id`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Admin User', 'admin@doctrack.com', '$2y$10$iRZcGKxg.d6gR75QrlhxD.DrKPLLQowtV.17mZHnzi1lkfcsn4kRC', 'admin', NULL, 1, '2025-09-21 07:54:59', '2025-09-21 07:54:59'),
(2, 'Staff User', 'staff@doctrack.com', '$2y$10$iRZcGKxg.d6gR75QrlhxD.DrKPLLQowtV.17mZHnzi1lkfcsn4kRC', 'staff', 1, 1, '2025-09-21 07:54:59', '2025-09-21 08:53:15'),
(3, 'Jb', 'barangan.jb.bscs@gmail.com', '$2y$10$fUGz4pwsXutTNelFkV46fOtfSsSvBdIZ5nWBFj/kx.tlz4JNcneTu', 'staff', 3, 1, '2025-09-21 08:32:53', '2025-09-21 08:39:07');

-- --------------------------------------------------------

--
-- Table structure for table `user_activities`
--

CREATE TABLE `user_activities` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_activities`
--

INSERT INTO `user_activities` (`id`, `user_id`, `action`, `description`, `ip_address`, `user_agent`, `created_at`) VALUES
(1, 1, 'create_department', 'Created department: Sample', NULL, NULL, '2025-09-21 08:40:04'),
(2, 1, 'update_department', 'Updated department from \'Sample\' to \'Sample\'', NULL, NULL, '2025-09-21 08:40:11'),
(3, 1, 'delete_department', 'Deleted department: Sample', NULL, NULL, '2025-09-21 08:40:16'),
(4, 1, 'send_document', 'Sent document \'sample 3\' to IT Department department', NULL, NULL, '2025-09-21 08:44:07'),
(5, 3, 'receive_document', 'Received document \'sample 3\' from Admin User', NULL, NULL, '2025-09-21 08:49:46'),
(6, 1, 'send_document', 'Sent document \'Sample 4\' to Human Resources department', NULL, NULL, '2025-09-21 08:52:06'),
(7, 2, 'receive_document', 'Received document \'Sample 4\' from Admin User', NULL, NULL, '2025-09-21 08:54:35'),
(8, 1, 'send_document', 'Sent document \'weweew\' to IT Department department', NULL, NULL, '2025-10-04 15:46:47'),
(9, 2, 'send_document', 'Sent document \'iuwar\' to MIS Department department', NULL, NULL, '2025-10-04 17:52:03'),
(10, 2, 'send_document', 'Sent document \'iuwar\' to IT Department department', NULL, NULL, '2025-10-04 17:52:06'),
(11, 2, 'send_document', 'Sent document \'iuwar\' to MIS Department department', NULL, NULL, '2025-10-04 17:52:09'),
(12, 2, 'send_document', 'Sent document \'iuwar\' to IT Department department', NULL, NULL, '2025-10-04 17:52:15'),
(13, 2, 'send_document', 'Sent document \'iuwar\' to MIS Department department', NULL, NULL, '2025-10-04 17:52:58'),
(14, 2, 'send_document', 'Sent document \'iuwar\' to IT Department department', NULL, NULL, '2025-10-04 17:53:02'),
(15, 2, 'send_document', 'Sent document \'iuwar\' to IT Department department', NULL, NULL, '2025-10-04 18:01:17'),
(16, 2, 'send_document', 'Sent document \'iuwar\' to MIS Department department', NULL, NULL, '2025-10-04 18:02:30'),
(17, 2, 'send_document', 'Sent document \'iuwar\' to IT Department department', NULL, NULL, '2025-10-04 18:02:32'),
(18, 2, 'send_document', 'Sent document \'iuwar\' to IT Department department', NULL, NULL, '2025-10-04 18:11:02'),
(19, 2, 'send_document', 'Sent document \'iuwar\' to MIS Department department', NULL, NULL, '2025-10-04 18:11:06'),
(20, 2, 'send_document', 'Sent document \'iuwar\' to IT Department department', NULL, NULL, '2025-10-04 18:17:25'),
(21, 2, 'send_document', 'Sent document \'iuwar\' to IT Department department', NULL, NULL, '2025-10-04 18:17:43'),
(22, 2, 'send_document', 'Sent document \'iuwar\' to MIS Department department', NULL, NULL, '2025-10-04 18:17:48'),
(23, 2, 'send_document', 'Sent document \'iuwar\' to IT Department department', NULL, NULL, '2025-10-04 18:17:51'),
(24, 2, 'send_document', 'Sent document \'iuwar\' to IT Department department', NULL, NULL, '2025-10-04 18:32:54'),
(25, 2, 'send_document', 'Sent document \'iuwar\' to IT Department department', NULL, NULL, '2025-10-04 18:33:15'),
(26, 2, 'send_document', 'Sent document \'iuwar\' to IT Department department', NULL, NULL, '2025-10-04 18:34:05'),
(27, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:35:36'),
(28, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:41:21'),
(29, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:41:36'),
(30, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:44:53'),
(31, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:45:39'),
(32, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:45:42'),
(33, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:46:11'),
(34, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:46:14'),
(35, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:46:19'),
(36, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:46:22'),
(37, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:46:25'),
(38, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:46:31'),
(39, 2, 'send_document', 'Sent document \'tuktuk\' to IT Department department', NULL, NULL, '2025-10-04 18:46:35'),
(40, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:46:38'),
(41, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:50:10'),
(42, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:50:43'),
(43, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:51:01'),
(44, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:58:46'),
(45, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:58:56'),
(46, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 18:59:42'),
(47, 2, 'send_document', 'Sent document \'iuwar\' to IT Department department', NULL, NULL, '2025-10-04 18:59:46'),
(48, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 19:00:13');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `barcode` (`barcode`),
  ADD KEY `received_by` (`received_by`),
  ADD KEY `idx_documents_status` (`status`),
  ADD KEY `idx_documents_uploaded_by` (`uploaded_by`),
  ADD KEY `idx_documents_barcode` (`barcode`),
  ADD KEY `idx_documents_uploaded_at` (`uploaded_at`),
  ADD KEY `idx_documents_department_id` (`department_id`),
  ADD KEY `fk_current_department` (`current_department_id`);

--
-- Indexes for table `system_logs`
--
ALTER TABLE `system_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_system_logs_level` (`level`),
  ADD KEY `idx_system_logs_timestamp` (`timestamp`);

--
-- Indexes for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_users_department_id` (`department_id`);

--
-- Indexes for table `user_activities`
--
ALTER TABLE `user_activities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_activities_user_id` (`user_id`),
  ADD KEY `idx_user_activities_created_at` (`created_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `system_logs`
--
ALTER TABLE `system_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_settings`
--
ALTER TABLE `system_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user_activities`
--
ALTER TABLE `user_activities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `documents_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `documents_ibfk_3` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `documents_ibfk_4` FOREIGN KEY (`current_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_current_department` FOREIGN KEY (`current_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `user_activities`
--
ALTER TABLE `user_activities`
  ADD CONSTRAINT `user_activities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
