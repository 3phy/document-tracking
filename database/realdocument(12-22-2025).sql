-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 22, 2025 at 04:35 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

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
(8, 'Sample', 'Sample-edit', 0, '2025-09-21 08:40:04', '2025-09-21 08:40:16'),
(9, 'Sample Department', 'Sample', 1, '2025-11-05 02:07:26', '2025-11-05 02:07:26');

-- --------------------------------------------------------

--
-- Table structure for table `department_routing_preferences`
--

CREATE TABLE `department_routing_preferences` (
  `id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL,
  `can_route_through` int(11) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `department_routing_preferences`
--

INSERT INTO `department_routing_preferences` (`id`, `department_id`, `can_route_through`, `is_active`, `created_at`) VALUES
(1, 3, 4, 1, '2025-11-04 09:53:40'),
(2, 1, 4, 1, '2025-11-04 09:53:40'),
(3, 2, 4, 1, '2025-11-04 09:53:40'),
(4, 5, 4, 1, '2025-11-04 09:53:40'),
(5, 6, 4, 1, '2025-11-04 09:53:40'),
(6, 4, 1, 1, '2025-11-04 09:53:40'),
(7, 4, 2, 1, '2025-11-04 09:53:40'),
(8, 4, 3, 1, '2025-11-04 09:53:40'),
(9, 4, 5, 1, '2025-11-04 09:53:40'),
(10, 4, 6, 1, '2025-11-04 09:53:40');

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
  `status` enum('outgoing','pending','received','rejected') DEFAULT 'outgoing',
  `cancel_note` text DEFAULT NULL,
  `canceled_by` int(11) DEFAULT NULL,
  `canceled_at` timestamp NULL DEFAULT NULL,
  `department_id` int(11) NOT NULL,
  `current_department_id` int(11) DEFAULT NULL,
  `upload_department_id` int(11) DEFAULT NULL,
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

INSERT INTO `documents` (`id`, `title`, `description`, `filename`, `file_path`, `file_size`, `file_type`, `barcode`, `status`, `cancel_note`, `canceled_by`, `canceled_at`, `department_id`, `current_department_id`, `upload_department_id`, `uploaded_by`, `received_by`, `uploaded_at`, `received_at`, `created_at`, `updated_at`) VALUES
(1, 'sample', 'sample', 'DOC17584413624906_user.png', 'uploads/DOC17584413624906_user.png', 25515, 'png', 'DOC17584413624906', 'received', NULL, NULL, NULL, 3, NULL, NULL, 1, 2, '2025-09-21 07:56:02', '2025-09-21 08:07:49', '2025-09-21 07:56:02', '2025-11-04 18:35:19'),
(2, 'Sample 2', 'Sample2', 'DOC17584438562318_power-supply.docx', 'uploads/DOC17584438562318_power-supply.docx', 205520, 'docx', 'DOC17584438562318', 'received', NULL, NULL, NULL, 3, NULL, NULL, 1, 3, '2025-09-21 08:37:36', '2025-09-21 08:39:36', '2025-09-21 08:37:36', '2025-11-04 18:35:19'),
(3, 'sample 3', 'sample 3', 'DOC17584442319080_CRIM PASSERS.jpeg', 'uploads/DOC17584442319080_CRIM PASSERS.jpeg', 129735, 'jpeg', 'DOC17584442319080', 'received', NULL, NULL, NULL, 3, NULL, NULL, 1, 3, '2025-09-21 08:43:51', '2025-09-21 08:49:46', '2025-09-21 08:43:51', '2025-11-04 18:35:19'),
(4, 'Sample 4', 'Sample 4', 'DOC17584446761976_soldering-joint (1).docx', 'uploads/DOC17584446761976_soldering-joint (1).docx', 22634, 'docx', 'DOC17584446761976', 'received', NULL, NULL, NULL, 1, NULL, NULL, 1, 2, '2025-09-21 08:51:16', '2025-09-21 08:54:35', '2025-09-21 08:51:16', '2025-11-04 18:35:19'),
(5, 'asdas', 'dsadsa', 'DOC17584450626616_user.png', 'uploads/DOC17584450626616_user.png', 25515, 'png', 'DOC17584450626616', 'pending', NULL, NULL, NULL, 3, 3, NULL, 1, NULL, '2025-09-21 08:57:42', NULL, '2025-09-21 08:57:42', '2025-11-04 18:35:19'),
(6, 'dsad', 'asdsd', 'DOC17584451028137_user.png', 'uploads/DOC17584451028137_user.png', 25515, 'png', 'DOC17584451028137', 'pending', NULL, NULL, NULL, 1, 1, NULL, 3, NULL, '2025-09-21 08:58:22', NULL, '2025-09-21 08:58:22', '2025-11-04 18:35:19'),
(7, 'weweew', 'qweqeqw', 'DOC17595927509658_BSCS3C-GClassCodes.txt', 'uploads/DOC17595927509658_BSCS3C-GClassCodes.txt', 173, 'txt', 'DOC17595927509658', 'pending', NULL, NULL, NULL, 3, NULL, NULL, 1, NULL, '2025-10-04 15:45:50', NULL, '2025-10-04 15:45:50', '2025-11-04 18:35:19'),
(8, 'iuwar', 'awuedawbhuj', 'DOC17596001258915_OPERSYST_OBTL_2025-LEC-Ver.7.0.pdf', 'uploads/DOC17596001258915_OPERSYST_OBTL_2025-LEC-Ver.7.0.pdf', 852125, 'pdf', 'DOC17596001258915', 'pending', NULL, NULL, NULL, 3, 1, NULL, 2, NULL, '2025-10-04 17:48:45', NULL, '2025-10-04 17:48:45', '2025-11-04 18:35:19'),
(9, 'tuktuk', 'tinghtinh', 'DOC17596029304648_Moon.jpg', 'uploads/DOC17596029304648_Moon.jpg', 153503, 'jpg', 'DOC17596029304648', 'pending', NULL, NULL, NULL, 7, 1, NULL, 2, 1, '2025-10-04 18:35:30', '2025-11-04 12:26:45', '2025-10-04 18:35:30', '2025-11-04 18:35:19'),
(10, '1', '1', 'DOC17622748702281_Request for re-Inspection.pdf', 'uploads/DOC17622748702281_Request for re-Inspection.pdf', 192969, 'pdf', 'DOC17622748702281', '', NULL, NULL, NULL, 3, 1, 7, 1, 3, '2025-11-04 16:47:50', '2025-11-04 17:04:54', '2025-11-04 16:47:50', '2025-11-04 18:35:19'),
(11, '2', '2', 'DOC17622766853307_Request for re-Inspection.pdf', 'uploads/DOC17622766853307_Request for re-Inspection.pdf', 192969, 'pdf', 'DOC17622766853307', '', 'kasi', 3, '2025-11-04 17:37:09', 3, 1, 7, 1, 3, '2025-11-04 17:18:05', '2025-11-04 17:18:34', '2025-11-04 17:18:05', '2025-11-04 18:35:19'),
(12, '1', '1', 'DOC17622778795112_Request for re-Inspection.pdf', 'uploads/DOC17622778795112_Request for re-Inspection.pdf', 192969, 'pdf', 'DOC17622778795112', 'outgoing', NULL, NULL, NULL, 3, 3, 3, 3, NULL, '2025-11-04 17:37:59', NULL, '2025-11-04 17:37:59', '2025-11-04 18:35:19'),
(13, '1', '1', 'DOC17622778912279_Request for re-Inspection.pdf', 'uploads/DOC17622778912279_Request for re-Inspection.pdf', 192969, 'pdf', 'DOC17622778912279', '', 'no', 1, '2025-11-04 17:38:19', 7, 3, 3, 3, NULL, '2025-11-04 17:38:11', NULL, '2025-11-04 17:38:11', '2025-11-04 18:35:19'),
(14, '1', '1', 'DOC17622780208904_Request for re-Inspection.pdf', 'uploads/DOC17622780208904_Request for re-Inspection.pdf', 192969, 'pdf', 'DOC17622780208904', '', 'no', 3, '2025-11-04 17:40:30', 3, 7, 7, 1, NULL, '2025-11-04 17:40:20', NULL, '2025-11-04 17:40:20', '2025-11-04 18:35:19'),
(15, '1', '1', 'DOC17622784622126_Untitled Diagram.drawio.png', 'uploads/DOC17622784622126_Untitled Diagram.drawio.png', 68312, 'png', 'DOC17622784622126', '', 'no', 3, '2025-11-04 17:47:49', 3, 7, 7, 1, NULL, '2025-11-04 17:47:42', NULL, '2025-11-04 17:47:42', '2025-11-04 18:35:19'),
(16, '1', '1', 'DOC17622784979690_Untitled Diagram.drawio.png', 'uploads/DOC17622784979690_Untitled Diagram.drawio.png', 68312, 'png', 'DOC17622784979690', '', 'no', 3, '2025-11-04 17:48:23', 3, 7, 7, 1, NULL, '2025-11-04 17:48:17', NULL, '2025-11-04 17:48:17', '2025-11-04 18:35:19'),
(17, '1', '1', 'DOC17622786759356_Screenshot 2025-11-04 180524.png', 'uploads/DOC17622786759356_Screenshot 2025-11-04 180524.png', 8910, 'png', 'DOC17622786759356', 'rejected', 'no', 3, '2025-11-04 17:51:20', 3, 7, 7, 1, NULL, '2025-11-04 17:51:15', NULL, '2025-11-04 17:51:15', '2025-11-04 18:35:19'),
(18, '1', '1', 'DOC17622815276329_JABES AR.docx', 'uploads/DOC17622815276329_JABES AR.docx', 87996, 'docx', 'DOC17622815276329', 'outgoing', NULL, NULL, NULL, 3, 7, 7, 1, NULL, '2025-11-04 18:38:47', NULL, '2025-11-04 18:38:47', '2025-11-04 18:38:47'),
(19, '1', '1', 'DOC17622815962958_DOC17622780208904_Request for re-Inspection (1).pdf', 'uploads/DOC17622815962958_DOC17622780208904_Request for re-Inspection (1).pdf', 192969, 'pdf', 'DOC17622815962958', 'outgoing', NULL, NULL, NULL, 3, 7, 7, 1, NULL, '2025-11-04 18:39:56', NULL, '2025-11-04 18:39:56', '2025-11-04 18:39:56'),
(20, '11', '1', 'DOC17622848822116_DOC17622780208904_Request for re-Inspection (1).pdf', 'uploads/DOC17622848822116_DOC17622780208904_Request for re-Inspection (1).pdf', 192969, 'pdf', 'DOC17622848822116', 'outgoing', NULL, NULL, NULL, 7, 3, 3, 3, NULL, '2025-11-04 19:34:42', NULL, '2025-11-04 19:34:42', '2025-11-04 19:34:42'),
(21, '13', '1', 'DOC17622848947078_DOC17622780208904_Request for re-Inspection.pdf', 'uploads/DOC17622848947078_DOC17622780208904_Request for re-Inspection.pdf', 192969, 'pdf', 'DOC17622848947078', 'rejected', 'wala', 1, '2025-11-06 09:34:52', 7, 3, 3, 3, NULL, '2025-11-04 19:34:54', NULL, '2025-11-04 19:34:54', '2025-11-06 09:34:52'),
(22, '1', '1', 'DOC17622849682888_DOC17622780208904_Request for re-Inspection.pdf', 'uploads/DOC17622849682888_DOC17622780208904_Request for re-Inspection.pdf', 192969, 'pdf', 'DOC17622849682888', 'rejected', 'sad', 1, '2025-11-19 15:19:43', 7, 3, 3, 3, 2, '2025-11-04 19:36:08', '2025-11-05 00:46:51', '2025-11-04 19:36:08', '2025-11-19 15:19:43'),
(23, '1', '1', 'DOC17623048171983_DOC17622780208904_Request for re-Inspection.pdf', 'uploads/DOC17623048171983_DOC17622780208904_Request for re-Inspection.pdf', 192969, 'pdf', 'DOC17623048171983', 'pending', NULL, NULL, NULL, 3, 7, 7, 1, 2, '2025-11-05 01:06:57', '2025-11-05 01:07:42', '2025-11-05 01:06:57', '2025-11-05 01:08:10'),
(24, '1', '1', 'DOC17623051559930_DOC17622780208904_Request for re-Inspection (1).pdf', 'uploads/DOC17623051559930_DOC17622780208904_Request for re-Inspection (1).pdf', 192969, 'pdf', 'DOC17623051559930', 'outgoing', NULL, NULL, NULL, 3, 7, 7, 1, NULL, '2025-11-05 01:12:35', NULL, '2025-11-05 01:12:35', '2025-11-05 01:12:35'),
(25, 'sample nanaman', '1', 'DOC17623054838856_DOC17622780208904_Request for re-Inspection.pdf', 'uploads/DOC17623054838856_DOC17622780208904_Request for re-Inspection.pdf', 192969, 'pdf', 'DOC17623054838856', 'outgoing', NULL, NULL, NULL, 3, 7, 7, 1, NULL, '2025-11-05 01:18:03', NULL, '2025-11-05 01:18:03', '2025-11-05 01:18:03'),
(26, 'sadsad', 'asdsa', 'DOC17623056237904_DOC17622815962958_preview.pdf', 'uploads/DOC17623056237904_DOC17622815962958_preview.pdf', 195842, 'pdf', 'DOC17623056237904', 'received', NULL, NULL, NULL, 3, 1, 7, 1, 2, '2025-11-05 01:20:23', '2025-11-05 01:21:09', '2025-11-05 01:20:23', '2025-11-05 01:21:09'),
(27, '1', '1', 'DOC17623067423026_DOC17622780208904_Request for re-Inspection (1).pdf', 'uploads/DOC17623067423026_DOC17622780208904_Request for re-Inspection (1).pdf', 192969, 'pdf', 'DOC17623067423026', 'received', NULL, NULL, NULL, 3, 3, 1, 2, 3, '2025-11-05 01:39:02', '2025-11-05 02:47:00', '2025-11-05 01:39:02', '2025-11-05 02:47:00'),
(28, '1', '1', 'DOC17623104597146_NETWORK-CHECKING1.pdf', 'uploads/DOC17623104597146_NETWORK-CHECKING1.pdf', 77223, 'pdf', 'DOC17623104597146', 'received', NULL, NULL, NULL, 9, 7, 7, 1, 1, '2025-11-05 02:40:59', '2025-11-05 02:43:02', '2025-11-05 02:40:59', '2025-11-05 02:43:02'),
(29, '121', '121', 'DOC17623110092244_NETWORK-CHECKING1.pdf', 'uploads/DOC17623110092244_NETWORK-CHECKING1.pdf', 77223, 'pdf', 'DOC17623110092244', 'received', NULL, NULL, NULL, 3, 3, 7, 1, 3, '2025-11-05 02:50:09', '2025-11-05 02:50:26', '2025-11-05 02:50:09', '2025-11-05 02:50:26'),
(30, '12', '12', 'DOC17623112128523_NETWORK-CHECKING1.pdf', 'uploads/DOC17623112128523_NETWORK-CHECKING1.pdf', 77223, 'pdf', 'DOC17623112128523', 'outgoing', NULL, NULL, NULL, 3, 7, 7, 1, NULL, '2025-11-05 02:53:32', NULL, '2025-11-05 02:53:32', '2025-11-05 02:53:32'),
(31, '1', '1', 'Untitled Diagram.drawio (6).png', 'uploads/DOC17663715571755_Untitled_Diagram.drawio__6_.png', 322582, 'png', 'DOC17663715571755', 'pending', NULL, NULL, NULL, 3, 3, 7, 1, NULL, '2025-12-22 02:45:57', NULL, '2025-12-22 02:45:57', '2025-12-22 02:45:57');

-- --------------------------------------------------------

--
-- Table structure for table `document_forwarding_history`
--

CREATE TABLE `document_forwarding_history` (
  `id` int(11) NOT NULL,
  `document_id` int(11) NOT NULL,
  `from_department_id` int(11) NOT NULL,
  `to_department_id` int(11) NOT NULL,
  `forwarded_by` int(11) NOT NULL,
  `received_by` int(11) DEFAULT NULL,
  `forwarded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `received_at` timestamp NULL DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `document_forwarding_history`
--

INSERT INTO `document_forwarding_history` (`id`, `document_id`, `from_department_id`, `to_department_id`, `forwarded_by`, `received_by`, `forwarded_at`, `received_at`, `notes`) VALUES
(1, 9, 7, 1, 1, NULL, '2025-11-04 13:16:05', NULL, NULL),
(2, 10, 3, 1, 3, NULL, '2025-11-04 17:05:01', NULL, NULL),
(3, 11, 3, 1, 3, NULL, '2025-11-04 17:18:40', NULL, NULL),
(4, 22, 7, 1, 1, NULL, '2025-11-05 00:46:00', NULL, NULL),
(5, 22, 7, 3, 1, NULL, '2025-11-05 01:06:29', NULL, NULL),
(6, 23, 3, 1, 3, NULL, '2025-11-05 01:07:31', NULL, NULL),
(7, 23, 1, 7, 2, NULL, '2025-11-05 01:08:10', NULL, NULL),
(8, 26, 3, 1, 3, NULL, '2025-11-05 01:20:51', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `document_routing`
--

CREATE TABLE `document_routing` (
  `id` int(11) NOT NULL,
  `document_id` int(11) NOT NULL,
  `from_department_id` int(11) DEFAULT NULL,
  `to_department_id` int(11) DEFAULT NULL,
  `intermediate_department_id` int(11) DEFAULT NULL,
  `received_by` int(11) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(1, 'Admin User', 'admin@doctrack.com', '$2y$10$iRZcGKxg.d6gR75QrlhxD.DrKPLLQowtV.17mZHnzi1lkfcsn4kRC', 'admin', 7, 1, '2025-09-21 07:54:59', '2025-11-04 09:59:31'),
(2, 'Staff User', 'staff@doctrack.com', '$2y$10$iRZcGKxg.d6gR75QrlhxD.DrKPLLQowtV.17mZHnzi1lkfcsn4kRC', 'staff', 1, 1, '2025-09-21 07:54:59', '2025-09-21 08:53:15'),
(3, 'Jb', 'barangan.jb.bscs@gmail.com', '$2y$10$fUGz4pwsXutTNelFkV46fOtfSsSvBdIZ5nWBFj/kx.tlz4JNcneTu', 'staff', 3, 1, '2025-09-21 08:32:53', '2025-09-21 08:39:07'),
(4, 'sample', 'sample@gmail.com', '$2y$10$tlU7vU8kJxlzAOUJLrsTju33/rilKC2xcKJGSQ9LAycOQ4/sD8uo.', 'staff', 9, 1, '2025-11-05 02:39:28', '2025-11-05 02:39:28');

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
(48, 2, 'send_document', 'Sent document \'tuktuk\' to MIS Department department', NULL, NULL, '2025-10-04 19:00:13'),
(49, 1, 'receive_document', 'Received document \'tuktuk\' from Staff User', NULL, NULL, '2025-11-04 12:26:45'),
(50, 1, 'forward_document', 'Forwarded document \'tuktuk\' to Human Resources department', NULL, NULL, '2025-11-04 13:16:05'),
(51, 1, 'upload_document', 'Uploaded document \'1\' and sent to department ID 3', NULL, NULL, '2025-11-04 16:47:50'),
(52, 3, 'receive_document', 'Received document \'1\' from Admin User', NULL, NULL, '2025-11-04 17:04:54'),
(53, 3, 'forward_document', 'Forwarded document \'1\' to Human Resources department', NULL, NULL, '2025-11-04 17:05:01'),
(54, 2, 'cancel_document', 'Cancelled document \'1\' - marked as rejected', NULL, NULL, '2025-11-04 17:11:31'),
(55, 1, 'upload_document', 'Uploaded document \'2\' and sent to department ID 3', NULL, NULL, '2025-11-04 17:18:05'),
(56, 3, 'receive_document', 'Received document \'2\' from Admin User', NULL, NULL, '2025-11-04 17:18:34'),
(57, 3, 'forward_document', 'Forwarded document \'2\' to Human Resources department', NULL, NULL, '2025-11-04 17:18:40'),
(58, 3, 'cancel_document', 'Cancelled document \'2\' - marked as rejected', NULL, NULL, '2025-11-04 17:37:09'),
(59, 3, 'upload_document', 'Uploaded document \'1\' and sent to department ID 3', NULL, NULL, '2025-11-04 17:37:59'),
(60, 3, 'upload_document', 'Uploaded document \'1\' and sent to department ID 7', NULL, NULL, '2025-11-04 17:38:11'),
(61, 1, 'cancel_document', 'Cancelled document \'1\' - marked as rejected', NULL, NULL, '2025-11-04 17:38:19'),
(62, 1, 'upload_document', 'Uploaded document \'1\' and sent to department ID 3', NULL, NULL, '2025-11-04 17:40:20'),
(63, 3, 'cancel_document', 'Cancelled document \'1\' - marked as rejected', NULL, NULL, '2025-11-04 17:40:30'),
(64, 1, 'upload_document', 'Uploaded document \'1\' and sent to department ID 3', NULL, NULL, '2025-11-04 17:47:42'),
(65, 3, 'cancel_document', 'Cancelled document \'1\' - marked as rejected', NULL, NULL, '2025-11-04 17:47:49'),
(66, 1, 'upload_document', 'Uploaded document \'1\' and sent to department ID 3', NULL, NULL, '2025-11-04 17:48:17'),
(67, 3, 'cancel_document', 'Cancelled document \'1\' - marked as rejected', NULL, NULL, '2025-11-04 17:48:23'),
(68, 1, 'upload_document', 'Uploaded document \'1\' and sent to department ID 3', NULL, NULL, '2025-11-04 17:51:15'),
(69, 3, 'cancel_document', 'Cancelled document \'1\' - marked as rejected', NULL, NULL, '2025-11-04 17:51:20'),
(70, 1, 'upload_document', 'Uploaded document \'1\' and sent to department ID 3', NULL, NULL, '2025-11-04 18:38:47'),
(71, 1, 'upload_document', 'Uploaded document \'1\' and sent to department ID 3', NULL, NULL, '2025-11-04 18:39:56'),
(72, 3, 'upload_document', 'Uploaded document \'1\' and sent to department ID 7', NULL, NULL, '2025-11-04 19:36:08'),
(73, 1, 'receive_document', 'Received document \'1\' from Jb', NULL, NULL, '2025-11-05 00:42:11'),
(74, 1, 'forward_document', 'Forwarded document \'1\' to Human Resources department', NULL, NULL, '2025-11-05 00:46:00'),
(75, 2, 'receive_document', 'Received document \'1\' from Jb', NULL, NULL, '2025-11-05 00:46:51'),
(76, 1, 'forward_document', 'Forwarded document \'1\' to IT Department department', NULL, NULL, '2025-11-05 01:06:29'),
(77, 1, 'upload_document', 'Uploaded document \'1\' and sent to department ID 3', NULL, NULL, '2025-11-05 01:06:57'),
(78, 3, 'forward_document', 'Forwarded document \'1\' to Human Resources department', NULL, NULL, '2025-11-05 01:07:31'),
(79, 2, 'forward_document', 'Forwarded document \'1\' to MIS Department department', NULL, NULL, '2025-11-05 01:08:10'),
(80, 1, 'upload_document', 'Uploaded document \'1\' and sent to department ID 3', NULL, NULL, '2025-11-05 01:12:35'),
(81, 1, 'upload_document', 'Uploaded document \'sample nanaman\' and sent to department ID 3', NULL, NULL, '2025-11-05 01:18:03'),
(82, 1, 'upload_document', 'Uploaded document \'sadsad\' and sent to department ID 3', NULL, NULL, '2025-11-05 01:20:23'),
(83, 3, 'receive_document', 'Received document \'sadsad\' from Admin User', NULL, NULL, '2025-11-05 01:20:42'),
(84, 3, 'forward_document', 'Forwarded document \'sadsad\' to Human Resources department', NULL, NULL, '2025-11-05 01:20:51'),
(85, 2, 'receive_document', 'Received document \'sadsad\' from Admin User', NULL, NULL, '2025-11-05 01:21:09'),
(86, 2, 'upload_document', 'Uploaded document \'1\' and sent to department ID 3', NULL, NULL, '2025-11-05 01:39:02'),
(87, 1, 'create_department', 'Created department: Sample Department', NULL, NULL, '2025-11-05 02:07:26'),
(88, 1, 'upload_document', 'Uploaded document \'1\' and sent to department ID 9', NULL, NULL, '2025-11-05 02:40:59'),
(89, 1, 'upload_document', 'Uploaded document \'121\' and sent to department ID 3', NULL, NULL, '2025-11-05 02:50:09'),
(90, 1, 'upload_document', 'Uploaded document \'12\' and sent to department ID 3', NULL, NULL, '2025-11-05 02:53:32'),
(91, 1, 'cancel_document', 'Cancelled document \'13\' - marked as rejected', NULL, NULL, '2025-11-06 09:34:52'),
(92, 1, 'cancel_document', 'Cancelled document \'1\' - marked as rejected', NULL, NULL, '2025-11-19 15:19:43'),
(93, 1, 'upload_document', 'Uploaded document \'1\' to IT Department department', NULL, NULL, '2025-12-22 02:45:57');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `department_routing_preferences`
--
ALTER TABLE `department_routing_preferences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_preference` (`department_id`,`can_route_through`),
  ADD KEY `idx_department_routing_preferences_dept` (`department_id`),
  ADD KEY `idx_department_routing_preferences_through` (`can_route_through`);

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
  ADD KEY `fk_current_department` (`current_department_id`),
  ADD KEY `fk_documents_canceled_by` (`canceled_by`);

--
-- Indexes for table `document_forwarding_history`
--
ALTER TABLE `document_forwarding_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `from_department_id` (`from_department_id`),
  ADD KEY `to_department_id` (`to_department_id`),
  ADD KEY `forwarded_by` (`forwarded_by`),
  ADD KEY `idx_document_id` (`document_id`),
  ADD KEY `idx_forwarded_at` (`forwarded_at`),
  ADD KEY `idx_received_by` (`received_by`),
  ADD KEY `idx_received_at` (`received_at`);

--
-- Indexes for table `document_routing`
--
ALTER TABLE `document_routing`
  ADD PRIMARY KEY (`id`),
  ADD KEY `document_id` (`document_id`),
  ADD KEY `from_department_id` (`from_department_id`),
  ADD KEY `to_department_id` (`to_department_id`),
  ADD KEY `received_by` (`received_by`),
  ADD KEY `fk_intermediate_department` (`intermediate_department_id`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `department_routing_preferences`
--
ALTER TABLE `department_routing_preferences`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `document_forwarding_history`
--
ALTER TABLE `document_forwarding_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `document_routing`
--
ALTER TABLE `document_routing`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `user_activities`
--
ALTER TABLE `user_activities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `department_routing_preferences`
--
ALTER TABLE `department_routing_preferences`
  ADD CONSTRAINT `department_routing_preferences_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `department_routing_preferences_ibfk_2` FOREIGN KEY (`can_route_through`) REFERENCES `departments` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `documents_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `documents_ibfk_3` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `documents_ibfk_4` FOREIGN KEY (`current_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_current_department` FOREIGN KEY (`current_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_documents_canceled_by` FOREIGN KEY (`canceled_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `document_forwarding_history`
--
ALTER TABLE `document_forwarding_history`
  ADD CONSTRAINT `document_forwarding_history_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `documents` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `document_forwarding_history_ibfk_2` FOREIGN KEY (`from_department_id`) REFERENCES `departments` (`id`),
  ADD CONSTRAINT `document_forwarding_history_ibfk_3` FOREIGN KEY (`to_department_id`) REFERENCES `departments` (`id`),
  ADD CONSTRAINT `document_forwarding_history_ibfk_4` FOREIGN KEY (`forwarded_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_received_by` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `document_routing`
--
ALTER TABLE `document_routing`
  ADD CONSTRAINT `document_routing_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `documents` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `document_routing_ibfk_2` FOREIGN KEY (`from_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `document_routing_ibfk_3` FOREIGN KEY (`to_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `document_routing_ibfk_4` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_intermediate_department` FOREIGN KEY (`intermediate_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL;

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
