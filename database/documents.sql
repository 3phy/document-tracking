-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 04, 2025 at 07:44 PM
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
(19, '1', '1', 'DOC17622815962958_DOC17622780208904_Request for re-Inspection (1).pdf', 'uploads/DOC17622815962958_DOC17622780208904_Request for re-Inspection (1).pdf', 192969, 'pdf', 'DOC17622815962958', 'outgoing', NULL, NULL, NULL, 3, 7, 7, 1, NULL, '2025-11-04 18:39:56', NULL, '2025-11-04 18:39:56', '2025-11-04 18:39:56');

--
-- Indexes for dumped tables
--

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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

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
  ADD CONSTRAINT `fk_current_department` FOREIGN KEY (`current_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_documents_canceled_by` FOREIGN KEY (`canceled_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
