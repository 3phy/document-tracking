-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: document_tracking
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `department_routing_preferences`
--

DROP TABLE IF EXISTS `department_routing_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `department_routing_preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `department_id` int(11) NOT NULL,
  `can_route_through` int(11) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_preference` (`department_id`,`can_route_through`),
  KEY `idx_department_routing_preferences_dept` (`department_id`),
  KEY `idx_department_routing_preferences_through` (`can_route_through`),
  CONSTRAINT `department_routing_preferences_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `department_routing_preferences_ibfk_2` FOREIGN KEY (`can_route_through`) REFERENCES `departments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `department_routing_preferences`
--

LOCK TABLES `department_routing_preferences` WRITE;
/*!40000 ALTER TABLE `department_routing_preferences` DISABLE KEYS */;
INSERT INTO `department_routing_preferences` VALUES (1,3,4,1,'2025-11-04 09:53:40'),(2,1,4,1,'2025-11-04 09:53:40'),(3,2,4,1,'2025-11-04 09:53:40'),(4,5,4,1,'2025-11-04 09:53:40'),(5,6,4,1,'2025-11-04 09:53:40'),(6,4,1,1,'2025-11-04 09:53:40'),(7,4,2,1,'2025-11-04 09:53:40'),(8,4,3,1,'2025-11-04 09:53:40'),(9,4,5,1,'2025-11-04 09:53:40'),(10,4,6,1,'2025-11-04 09:53:40');
/*!40000 ALTER TABLE `department_routing_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `departments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,'Human Resources','',1,'2025-09-21 07:54:59','2025-12-22 10:25:21'),(2,'Finance','Financial department for accounting and budgeting',0,'2025-09-21 07:54:59','2025-09-21 08:36:14'),(3,'IT Department','',1,'2025-09-21 07:54:59','2025-12-22 10:25:27'),(4,'Operations','Operations department for daily business operations',0,'2025-09-21 07:54:59','2025-09-21 08:30:16'),(5,'Marketing','Marketing department for promotional activities',0,'2025-09-21 07:54:59','2025-09-21 08:30:23'),(6,'Legal','Legal department for compliance and contracts',0,'2025-09-21 07:54:59','2025-09-21 08:30:36'),(7,'MIS Department','',1,'2025-09-21 08:33:13','2025-12-22 10:25:30'),(8,'Sample','Sample-edit',0,'2025-09-21 08:40:04','2025-09-21 08:40:16'),(9,'Sample Department','',1,'2025-11-05 02:07:26','2025-12-22 10:25:32'),(10,'Sample2','',1,'2025-12-22 10:24:29','2025-12-22 10:25:34');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `document_forwarding_history`
--

DROP TABLE IF EXISTS `document_forwarding_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_forwarding_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `document_id` int(11) NOT NULL,
  `from_department_id` int(11) NOT NULL,
  `to_department_id` int(11) NOT NULL,
  `forwarded_by` int(11) NOT NULL,
  `received_by` int(11) DEFAULT NULL,
  `forwarded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `received_at` timestamp NULL DEFAULT NULL,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `from_department_id` (`from_department_id`),
  KEY `to_department_id` (`to_department_id`),
  KEY `forwarded_by` (`forwarded_by`),
  KEY `idx_document_id` (`document_id`),
  KEY `idx_forwarded_at` (`forwarded_at`),
  KEY `idx_received_by` (`received_by`),
  KEY `idx_received_at` (`received_at`),
  CONSTRAINT `document_forwarding_history_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `documents` (`id`) ON DELETE CASCADE,
  CONSTRAINT `document_forwarding_history_ibfk_2` FOREIGN KEY (`from_department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `document_forwarding_history_ibfk_3` FOREIGN KEY (`to_department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `document_forwarding_history_ibfk_4` FOREIGN KEY (`forwarded_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_received_by` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `document_forwarding_history`
--

LOCK TABLES `document_forwarding_history` WRITE;
/*!40000 ALTER TABLE `document_forwarding_history` DISABLE KEYS */;
INSERT INTO `document_forwarding_history` VALUES (2,10,3,1,3,NULL,'2025-11-04 17:05:01',NULL,NULL),(3,11,3,1,3,NULL,'2025-11-04 17:18:40',NULL,NULL),(4,22,7,1,1,NULL,'2025-11-05 00:46:00',NULL,NULL),(5,22,7,3,1,NULL,'2025-11-05 01:06:29',NULL,NULL),(6,23,3,1,3,NULL,'2025-11-05 01:07:31',NULL,NULL),(7,23,1,7,2,NULL,'2025-11-05 01:08:10',NULL,NULL),(8,26,3,1,3,NULL,'2025-11-05 01:20:51',NULL,NULL),(9,31,7,3,3,3,'2025-12-22 04:19:51','2025-12-22 04:19:51',NULL),(10,31,3,1,3,NULL,'2025-12-22 05:21:30',NULL,NULL),(11,26,1,9,2,NULL,'2025-12-22 07:28:26',NULL,NULL),(12,35,1,7,2,NULL,'2025-12-22 07:57:18',NULL,NULL),(13,37,7,3,1,3,'2025-12-22 10:59:54','2025-12-22 11:36:03',NULL),(14,37,3,1,3,2,'2025-12-22 11:36:12','2025-12-22 11:36:42',NULL),(15,37,1,9,2,4,'2025-12-22 11:42:05','2025-12-22 11:47:02',NULL),(16,38,7,3,1,3,'2025-12-22 11:47:32','2025-12-22 11:47:58',NULL),(17,38,3,1,3,2,'2025-12-22 11:48:03','2025-12-22 11:48:18',NULL),(18,38,1,9,2,NULL,'2025-12-22 11:48:23',NULL,NULL),(19,39,7,9,1,4,'2025-12-22 11:51:25','2025-12-22 11:51:47',NULL),(20,39,9,1,4,2,'2025-12-22 11:51:51','2025-12-22 11:55:45',NULL),(21,39,1,3,2,NULL,'2025-12-22 11:55:48',NULL,NULL),(22,40,7,3,1,3,'2025-12-22 12:03:35','2025-12-22 12:07:45',NULL),(23,40,3,1,3,2,'2025-12-22 12:08:28','2025-12-22 12:08:50',NULL),(24,40,1,9,2,4,'2025-12-22 12:17:37','2025-12-22 12:19:20',NULL),(25,41,7,1,1,6,'2025-12-22 12:35:20','2025-12-28 16:54:20',NULL),(26,41,1,3,6,NULL,'2025-12-28 16:54:45',NULL,NULL),(27,42,7,3,1,NULL,'2025-12-28 20:18:16',NULL,NULL),(28,43,7,3,1,NULL,'2025-12-28 20:22:44',NULL,NULL),(29,44,7,1,1,6,'2025-12-28 20:23:59','2025-12-28 21:51:53',NULL),(30,45,7,1,1,6,'2025-12-28 21:01:38','2025-12-28 21:08:21',NULL),(31,45,1,3,6,3,'2025-12-28 21:08:47','2025-12-28 21:53:22',NULL),(32,46,1,7,6,NULL,'2025-12-28 22:41:59',NULL,NULL),(33,48,1,7,6,NULL,'2025-12-28 22:41:59',NULL,NULL),(34,50,3,7,3,NULL,'2025-12-28 23:02:55',NULL,NULL),(35,52,3,7,3,NULL,'2025-12-28 23:02:55',NULL,NULL),(36,54,1,3,6,NULL,'2025-12-28 23:06:45',NULL,NULL),(37,56,1,3,6,NULL,'2025-12-28 23:06:45',NULL,NULL),(38,58,3,1,3,NULL,'2025-12-28 23:07:09',NULL,NULL),(39,59,1,7,6,NULL,'2025-12-28 23:11:37',NULL,NULL),(40,60,1,7,6,NULL,'2025-12-28 23:11:37',NULL,NULL),(41,61,1,3,6,NULL,'2025-12-28 23:12:17',NULL,NULL),(42,62,1,3,6,NULL,'2025-12-28 23:12:17',NULL,NULL),(43,63,1,9,6,NULL,'2025-12-28 23:13:57',NULL,NULL),(44,64,1,9,6,NULL,'2025-12-28 23:13:57',NULL,NULL),(45,65,1,7,6,NULL,'2025-12-28 23:14:43',NULL,NULL),(46,67,1,7,6,NULL,'2025-12-28 23:14:43',NULL,NULL),(47,69,7,1,1,NULL,'2025-12-28 23:18:08',NULL,NULL),(48,71,7,1,1,NULL,'2025-12-28 23:18:08',NULL,NULL),(49,73,3,7,3,NULL,'2025-12-28 23:18:42',NULL,NULL),(50,75,3,7,3,NULL,'2025-12-28 23:18:42',NULL,NULL),(51,77,1,7,6,NULL,'2025-12-28 23:21:27',NULL,NULL),(52,79,1,7,6,NULL,'2025-12-28 23:21:27',NULL,NULL),(53,81,3,9,3,NULL,'2025-12-28 23:24:22',NULL,NULL),(54,83,3,9,3,NULL,'2025-12-28 23:24:22',NULL,NULL),(55,85,3,9,3,NULL,'2025-12-28 23:24:54',NULL,NULL),(56,87,3,9,3,NULL,'2025-12-28 23:24:54',NULL,NULL),(57,89,3,1,3,NULL,'2025-12-28 23:26:48',NULL,NULL),(58,91,3,1,3,NULL,'2025-12-28 23:26:48',NULL,NULL),(59,93,1,3,6,NULL,'2025-12-28 23:31:04',NULL,NULL),(60,95,1,3,6,NULL,'2025-12-28 23:31:04',NULL,NULL),(61,97,1,7,6,NULL,'2025-12-29 12:42:59',NULL,NULL),(62,99,1,7,6,NULL,'2025-12-29 12:43:00',NULL,NULL),(63,101,1,3,6,NULL,'2025-12-29 12:43:35',NULL,NULL),(64,103,1,3,6,NULL,'2025-12-29 12:43:36',NULL,NULL),(65,105,7,3,1,NULL,'2025-12-29 12:46:16',NULL,NULL),(66,107,7,3,1,NULL,'2025-12-29 12:46:16',NULL,NULL),(67,109,1,3,6,NULL,'2025-12-29 12:52:09',NULL,NULL),(68,111,1,3,6,NULL,'2025-12-29 12:52:09',NULL,NULL),(69,113,1,7,6,NULL,'2025-12-29 12:56:48',NULL,NULL),(70,115,1,7,6,NULL,'2025-12-29 12:59:11',NULL,NULL),(71,117,1,7,6,NULL,'2025-12-29 13:04:59',NULL,NULL),(72,118,1,3,6,NULL,'2025-12-29 13:05:00',NULL,NULL),(73,119,1,7,6,NULL,'2025-12-29 13:05:00',NULL,NULL),(74,120,1,3,6,NULL,'2025-12-29 13:05:00',NULL,NULL),(75,121,1,3,6,NULL,'2025-12-29 13:05:23',NULL,NULL),(76,122,1,7,6,NULL,'2025-12-29 13:05:23',NULL,NULL),(77,123,1,3,6,NULL,'2025-12-29 13:05:23',NULL,NULL),(78,124,1,7,6,NULL,'2025-12-29 13:05:23',NULL,NULL);
/*!40000 ALTER TABLE `document_forwarding_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `document_routing`
--

DROP TABLE IF EXISTS `document_routing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `document_routing` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `document_id` int(11) NOT NULL,
  `from_department_id` int(11) DEFAULT NULL,
  `to_department_id` int(11) DEFAULT NULL,
  `intermediate_department_id` int(11) DEFAULT NULL,
  `received_by` int(11) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `document_id` (`document_id`),
  KEY `from_department_id` (`from_department_id`),
  KEY `to_department_id` (`to_department_id`),
  KEY `received_by` (`received_by`),
  KEY `fk_intermediate_department` (`intermediate_department_id`),
  CONSTRAINT `document_routing_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `documents` (`id`) ON DELETE CASCADE,
  CONSTRAINT `document_routing_ibfk_2` FOREIGN KEY (`from_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `document_routing_ibfk_3` FOREIGN KEY (`to_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `document_routing_ibfk_4` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_intermediate_department` FOREIGN KEY (`intermediate_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `document_routing`
--

LOCK TABLES `document_routing` WRITE;
/*!40000 ALTER TABLE `document_routing` DISABLE KEYS */;
/*!40000 ALTER TABLE `document_routing` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `filename` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` int(11) NOT NULL,
  `file_type` varchar(100) NOT NULL,
  `barcode` varchar(100) NOT NULL,
  `status` enum('outgoing','pending','received','rejected') NOT NULL DEFAULT 'pending',
  `cancel_note` text DEFAULT NULL,
  `canceled_by` int(11) DEFAULT NULL,
  `canceled_at` timestamp NULL DEFAULT NULL,
  `department_id` int(11) NOT NULL,
  `source_department_id` int(11) DEFAULT NULL,
  `current_department_id` int(11) DEFAULT NULL,
  `upload_department_id` int(11) DEFAULT NULL,
  `uploaded_by` int(11) NOT NULL,
  `received_by` int(11) DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `received_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_barcode_department` (`barcode`,`department_id`),
  KEY `received_by` (`received_by`),
  KEY `idx_documents_status` (`status`),
  KEY `idx_documents_uploaded_by` (`uploaded_by`),
  KEY `idx_documents_barcode` (`barcode`),
  KEY `idx_documents_uploaded_at` (`uploaded_at`),
  KEY `idx_documents_department_id` (`department_id`),
  KEY `fk_current_department` (`current_department_id`),
  KEY `fk_documents_canceled_by` (`canceled_by`),
  KEY `idx_documents_source_department_id` (`source_department_id`),
  CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `documents_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `documents_ibfk_3` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `documents_ibfk_4` FOREIGN KEY (`current_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_current_department` FOREIGN KEY (`current_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_documents_canceled_by` FOREIGN KEY (`canceled_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_source_department` FOREIGN KEY (`source_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
INSERT INTO `documents` VALUES (10,'1','1','DOC17622748702281_Request for re-Inspection.pdf','uploads/DOC17622748702281_Request for re-Inspection.pdf',192969,'pdf','DOC17622748702281','',NULL,NULL,NULL,3,7,1,7,1,3,'2025-11-04 16:47:50','2025-11-04 17:04:54','2025-11-04 16:47:50','2025-12-22 10:45:58'),(11,'2','2','DOC17622766853307_Request for re-Inspection.pdf','uploads/DOC17622766853307_Request for re-Inspection.pdf',192969,'pdf','DOC17622766853307','','kasi',3,'2025-11-04 17:37:09',3,7,1,7,1,3,'2025-11-04 17:18:05','2025-11-04 17:18:34','2025-11-04 17:18:05','2025-12-22 10:45:58'),(12,'1','1','DOC17622778795112_Request for re-Inspection.pdf','uploads/DOC17622778795112_Request for re-Inspection.pdf',192969,'pdf','DOC17622778795112','outgoing',NULL,NULL,NULL,3,3,3,3,3,NULL,'2025-11-04 17:37:59',NULL,'2025-11-04 17:37:59','2025-12-22 10:45:58'),(13,'1','1','DOC17622778912279_Request for re-Inspection.pdf','uploads/DOC17622778912279_Request for re-Inspection.pdf',192969,'pdf','DOC17622778912279','','no',1,'2025-11-04 17:38:19',7,3,3,3,3,NULL,'2025-11-04 17:38:11',NULL,'2025-11-04 17:38:11','2025-12-22 10:45:58'),(14,'1','1','DOC17622780208904_Request for re-Inspection.pdf','uploads/DOC17622780208904_Request for re-Inspection.pdf',192969,'pdf','DOC17622780208904','','no',3,'2025-11-04 17:40:30',3,7,7,7,1,NULL,'2025-11-04 17:40:20',NULL,'2025-11-04 17:40:20','2025-12-22 10:45:58'),(15,'1','1','DOC17622784622126_Untitled Diagram.drawio.png','uploads/DOC17622784622126_Untitled Diagram.drawio.png',68312,'png','DOC17622784622126','','no',3,'2025-11-04 17:47:49',3,7,7,7,1,NULL,'2025-11-04 17:47:42',NULL,'2025-11-04 17:47:42','2025-12-22 10:45:58'),(16,'1','1','DOC17622784979690_Untitled Diagram.drawio.png','uploads/DOC17622784979690_Untitled Diagram.drawio.png',68312,'png','DOC17622784979690','','no',3,'2025-11-04 17:48:23',3,7,7,7,1,NULL,'2025-11-04 17:48:17',NULL,'2025-11-04 17:48:17','2025-12-22 10:45:58'),(17,'1','1','DOC17622786759356_Screenshot 2025-11-04 180524.png','uploads/DOC17622786759356_Screenshot 2025-11-04 180524.png',8910,'png','DOC17622786759356','rejected','no',3,'2025-11-04 17:51:20',3,7,7,7,1,NULL,'2025-11-04 17:51:15',NULL,'2025-11-04 17:51:15','2025-12-22 10:45:58'),(18,'1','1','DOC17622815276329_JABES AR.docx','uploads/DOC17622815276329_JABES AR.docx',87996,'docx','DOC17622815276329','outgoing',NULL,NULL,NULL,3,7,7,7,1,NULL,'2025-11-04 18:38:47',NULL,'2025-11-04 18:38:47','2025-12-22 10:45:58'),(19,'1','1','DOC17622815962958_DOC17622780208904_Request for re-Inspection (1).pdf','uploads/DOC17622815962958_DOC17622780208904_Request for re-Inspection (1).pdf',192969,'pdf','DOC17622815962958','outgoing',NULL,NULL,NULL,3,7,7,7,1,NULL,'2025-11-04 18:39:56',NULL,'2025-11-04 18:39:56','2025-12-22 10:45:58'),(20,'11','1','DOC17622848822116_DOC17622780208904_Request for re-Inspection (1).pdf','uploads/DOC17622848822116_DOC17622780208904_Request for re-Inspection (1).pdf',192969,'pdf','DOC17622848822116','outgoing',NULL,NULL,NULL,7,3,3,3,3,NULL,'2025-11-04 19:34:42',NULL,'2025-11-04 19:34:42','2025-12-22 10:45:58'),(21,'13','1','DOC17622848947078_DOC17622780208904_Request for re-Inspection.pdf','uploads/DOC17622848947078_DOC17622780208904_Request for re-Inspection.pdf',192969,'pdf','DOC17622848947078','rejected','wala',1,'2025-11-06 09:34:52',7,3,3,3,3,NULL,'2025-11-04 19:34:54',NULL,'2025-11-04 19:34:54','2025-12-22 10:45:58'),(22,'1','1','DOC17622849682888_DOC17622780208904_Request for re-Inspection.pdf','uploads/DOC17622849682888_DOC17622780208904_Request for re-Inspection.pdf',192969,'pdf','DOC17622849682888','rejected','sad',1,'2025-11-19 15:19:43',7,3,3,3,3,2,'2025-11-04 19:36:08','2025-11-05 00:46:51','2025-11-04 19:36:08','2025-12-22 10:45:58'),(23,'1','1','DOC17623048171983_DOC17622780208904_Request for re-Inspection.pdf','uploads/DOC17623048171983_DOC17622780208904_Request for re-Inspection.pdf',192969,'pdf','DOC17623048171983','pending',NULL,NULL,NULL,3,7,7,7,1,2,'2025-11-05 01:06:57','2025-11-05 01:07:42','2025-11-05 01:06:57','2025-12-22 10:45:58'),(24,'1','1','DOC17623051559930_DOC17622780208904_Request for re-Inspection (1).pdf','uploads/DOC17623051559930_DOC17622780208904_Request for re-Inspection (1).pdf',192969,'pdf','DOC17623051559930','outgoing',NULL,NULL,NULL,3,7,7,7,1,NULL,'2025-11-05 01:12:35',NULL,'2025-11-05 01:12:35','2025-12-22 10:45:58'),(25,'sample nanaman','1','DOC17623054838856_DOC17622780208904_Request for re-Inspection.pdf','uploads/DOC17623054838856_DOC17622780208904_Request for re-Inspection.pdf',192969,'pdf','DOC17623054838856','outgoing',NULL,NULL,NULL,3,7,7,7,1,NULL,'2025-11-05 01:18:03',NULL,'2025-11-05 01:18:03','2025-12-22 10:45:58'),(26,'sadsad','asdsa','DOC17623056237904_DOC17622815962958_preview.pdf','uploads/DOC17623056237904_DOC17622815962958_preview.pdf',195842,'pdf','DOC17623056237904','pending',NULL,NULL,NULL,3,7,9,7,1,2,'2025-11-05 01:20:23','2025-11-05 01:21:09','2025-11-05 01:20:23','2025-12-22 10:45:58'),(27,'1','1','DOC17623067423026_DOC17622780208904_Request for re-Inspection (1).pdf','uploads/DOC17623067423026_DOC17622780208904_Request for re-Inspection (1).pdf',192969,'pdf','DOC17623067423026','received',NULL,NULL,NULL,3,1,3,1,2,3,'2025-11-05 01:39:02','2025-11-05 02:47:00','2025-11-05 01:39:02','2025-12-22 10:45:58'),(28,'1','1','DOC17623104597146_NETWORK-CHECKING1.pdf','uploads/DOC17623104597146_NETWORK-CHECKING1.pdf',77223,'pdf','DOC17623104597146','received',NULL,NULL,NULL,9,7,7,7,1,1,'2025-11-05 02:40:59','2025-11-05 02:43:02','2025-11-05 02:40:59','2025-12-22 10:45:58'),(29,'121','121','DOC17623110092244_NETWORK-CHECKING1.pdf','uploads/DOC17623110092244_NETWORK-CHECKING1.pdf',77223,'pdf','DOC17623110092244','received',NULL,NULL,NULL,3,7,3,7,1,3,'2025-11-05 02:50:09','2025-11-05 02:50:26','2025-11-05 02:50:09','2025-12-22 10:45:58'),(30,'12','12','DOC17623112128523_NETWORK-CHECKING1.pdf','uploads/DOC17623112128523_NETWORK-CHECKING1.pdf',77223,'pdf','DOC17623112128523','outgoing',NULL,NULL,NULL,3,7,7,7,1,NULL,'2025-11-05 02:53:32',NULL,'2025-11-05 02:53:32','2025-12-22 10:45:58'),(31,'1','1','Untitled Diagram.drawio (6).png','uploads/DOC17663715571755_Untitled_Diagram.drawio__6_.png',322582,'png','DOC17663715571755','rejected','asd',2,'2025-12-22 05:27:38',1,7,1,7,1,3,'2025-12-22 02:45:57','2025-12-22 04:19:51','2025-12-22 02:45:57','2025-12-22 10:45:58'),(32,'1s','1s','Untitled Diagram.drawio (6).png','uploads/DOC17663813059600_Untitled_Diagram.drawio__6_.png',322582,'png','DOC17663813059600','pending',NULL,NULL,NULL,1,7,1,7,1,NULL,'2025-12-22 05:28:25',NULL,'2025-12-22 05:28:25','2025-12-22 10:45:58'),(33,'1s','1s','Untitled Diagram.drawio (6).png','uploads/DOC17663813073193_Untitled_Diagram.drawio__6_.png',322582,'png','DOC17663813073193','pending',NULL,NULL,NULL,1,7,1,7,1,NULL,'2025-12-22 05:28:27',NULL,'2025-12-22 05:28:27','2025-12-22 10:45:58'),(34,'sad','dassad','Untitled Diagram.drawio (6).png','uploads/DOC17663813224085_Untitled_Diagram.drawio__6_.png',322582,'png','DOC17663813224085','pending',NULL,NULL,NULL,3,7,3,7,1,NULL,'2025-12-22 05:28:42',NULL,'2025-12-22 05:28:42','2025-12-22 10:45:58'),(35,'13232','123213','Untitled Diagram.drawio (6).png','uploads\\documents\\Untitled_Diagram.drawio__6__20251222_085718_4fe50620.png',0,'','DC7548F150B042FB','pending',NULL,NULL,NULL,7,1,7,1,2,NULL,'2025-12-22 07:57:18',NULL,'2025-12-22 07:57:18','2025-12-22 10:45:58'),(36,'1s3s','1ss','DOC17664001639642_Untitled Diagram.drawio (6) (1).png','../../uploads/DOC17664001639642_Untitled Diagram.drawio (6) (1).png',322582,'png','DOC17664001639642','rejected','no depatment',1,'2025-12-28 17:27:17',7,3,3,NULL,3,NULL,'2025-12-22 10:42:43',NULL,'2025-12-22 10:42:43','2025-12-28 17:27:17'),(37,'123','123','Untitled Diagram.drawio (6) (1).png','uploads\\documents\\Untitled_Diagram.drawio__6___1__20251222_115954_94354c7b.png',0,'','6427A13D94B1840D','received',NULL,NULL,NULL,9,NULL,9,7,1,4,'2025-12-22 10:59:54','2025-12-22 11:47:02','2025-12-22 10:59:54','2025-12-22 11:47:02'),(38,'Trial 1','Trial 1','Copy-of-CHAPTER-1.pdf','uploads\\documents\\Copy-of-CHAPTER-1_20251222_124732_a2111af2.pdf',0,'','9747659AEEFB426F','rejected','trial failed',4,'2025-12-22 11:50:34',9,NULL,1,7,1,2,'2025-12-22 11:47:32','2025-12-22 11:48:18','2025-12-22 11:47:32','2025-12-22 11:50:34'),(39,'Trial 2','Trial 2','Untitled Diagram.drawio (6) (1).png','uploads\\documents\\Untitled_Diagram.drawio__6___1__20251222_125125_eed46eff.png',0,'','8F59DADF39DE039D','rejected','Trial 2 - Cancellation Checking',3,'2025-12-22 11:56:16',3,NULL,1,7,1,2,'2025-12-22 11:51:25','2025-12-22 11:55:45','2025-12-22 11:51:25','2025-12-22 11:56:16'),(40,'Trial 3','Camera Scanner checking','Untitled Diagram.drawio (6) (1).png','uploads\\documents\\Untitled_Diagram.drawio__6___1__20251222_130335_6f63680d.png',0,'','C6776B6B791CB9BC','received',NULL,NULL,NULL,9,NULL,9,7,1,4,'2025-12-22 12:03:35','2025-12-22 12:19:20','2025-12-22 12:03:35','2025-12-22 12:19:20'),(41,'Trial 4','Reports Trial for Department Heads','Untitled Diagram.drawio (6) (1).png','uploads\\documents\\Untitled_Diagram.drawio__6___1__20251222_133520_c8814a58.png',0,'','FFAA0B5A9E78CFCE','outgoing',NULL,NULL,NULL,3,NULL,1,7,1,6,'2025-12-22 12:35:20','2025-12-28 16:54:20','2025-12-22 12:35:20','2025-12-28 16:54:45'),(42,'Trial 5','Footer with Barcode','Trial Document.pdf','uploads\\documents\\Trial_Document_20251228_211816_621cd56d.pdf',0,'','AA5C17009405B500','pending',NULL,NULL,NULL,3,NULL,3,7,1,NULL,'2025-12-28 20:18:16',NULL,'2025-12-28 20:18:16','2025-12-28 20:18:16'),(43,'Trial 5.1','Footer 0.3','Trial Document (1).pdf','uploads\\documents\\Trial_Document__1__20251228_212244_16d78749.pdf',0,'','A2237799380B0750','pending',NULL,NULL,NULL,3,NULL,3,7,1,NULL,'2025-12-28 20:22:44',NULL,'2025-12-28 20:22:44','2025-12-28 20:22:44'),(44,'Trial 5.2','Footer 0.1','Trial Document (2).pdf','uploads\\documents\\Trial_Document__2__20251228_212359_e0cde511.pdf',0,'','23F66A1D55637E95','received',NULL,NULL,NULL,1,NULL,1,7,1,6,'2025-12-28 20:23:59','2025-12-28 21:51:53','2025-12-28 20:23:59','2025-12-28 21:51:53'),(45,'Trial 5.3','Barcodes and Qr Code Relocation','Trial Document.pdf','uploads\\documents\\Trial_Document_20251228_220138_33f364b2.pdf',0,'','143E6EEAB22DE993','received',NULL,NULL,NULL,3,NULL,3,7,1,3,'2025-12-28 21:01:38','2025-12-28 21:53:22','2025-12-28 21:01:38','2025-12-28 21:53:22'),(46,'COMSA FS_Bulletin Board and CS EXPO 2025','','COMSA FS_Bulletin Board 2025.docx.pdf','uploads\\documents\\COMSA_FS_Bulletin_Board_2025.docx_20251228_234159_021fc330.pdf',0,'','6FC889D3560B71E9','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-28 22:41:59',NULL,'2025-12-28 22:41:59','2025-12-28 22:41:59'),(48,'COMSA FS_CS EXPO 2025.docx','','COMSA FS_CS EXPO 2025.docx.pdf','uploads\\documents\\COMSA_FS_CS_EXPO_2025.docx_20251228_234159_008634cb.pdf',0,'','76DC345D0D3B07B1','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-28 22:41:59',NULL,'2025-12-28 22:41:59','2025-12-28 22:41:59'),(50,'doc','','doc.pdf','uploads\\documents\\doc_20251229_000255_b4d5eb0e.pdf',0,'','489C9DD12BD1B9DC','pending',NULL,NULL,NULL,7,NULL,7,3,3,NULL,'2025-12-28 23:02:55',NULL,'2025-12-28 23:02:55','2025-12-28 23:02:55'),(52,'Trial Document (1) (1)','','Trial Document (1) (1).pdf','uploads\\documents\\Trial_Document__1___1__20251229_000255_986937fa.pdf',0,'','C419BB5CBA43D02D','pending',NULL,NULL,NULL,7,NULL,7,3,3,NULL,'2025-12-28 23:02:55',NULL,'2025-12-28 23:02:55','2025-12-28 23:02:55'),(54,'doc','','doc.pdf','uploads\\documents\\doc_20251229_000645_065ace20.pdf',0,'','597143371D9D7202','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-28 23:06:45',NULL,'2025-12-28 23:06:45','2025-12-28 23:06:45'),(56,'Trial Document (1) (1)','','Trial Document (1) (1).pdf','uploads\\documents\\Trial_Document__1___1__20251229_000645_5edaba98.pdf',0,'','9CC43F21C1020E03','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-28 23:06:45',NULL,'2025-12-28 23:06:45','2025-12-28 23:06:45'),(58,'Trial Document (1)','','Trial Document (1).pdf','uploads\\documents\\Trial_Document__1__20251229_000709_e9eb3183.pdf',0,'','4501F576D5F0587C','pending',NULL,NULL,NULL,1,NULL,1,3,3,NULL,'2025-12-28 23:07:09',NULL,'2025-12-28 23:07:09','2025-12-28 23:07:09'),(59,'COMSA FS_Bulletin Board 2025.docx','','COMSA FS_Bulletin Board 2025.docx.pdf','uploads\\documents\\COMSA_FS_Bulletin_Board_2025.docx_20251229_001137_6218b89f.pdf',0,'','4FBA89A012BF6B7E','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-28 23:11:37',NULL,'2025-12-28 23:11:37','2025-12-28 23:11:37'),(60,'COMSA FS_CS EXPO 2025.docx','','COMSA FS_CS EXPO 2025.docx.pdf','uploads\\documents\\COMSA_FS_CS_EXPO_2025.docx_20251229_001137_5ae50159.pdf',0,'','962883BA20D4DDE0','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-28 23:11:37',NULL,'2025-12-28 23:11:37','2025-12-28 23:11:37'),(61,'COMSA FS_Bulletin Board 2025.docx','','COMSA FS_Bulletin Board 2025.docx.pdf','uploads\\documents\\COMSA_FS_Bulletin_Board_2025.docx_20251229_001217_b5c5f9aa.pdf',0,'','B939A0146BA49DBF','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-28 23:12:17',NULL,'2025-12-28 23:12:17','2025-12-28 23:12:17'),(62,'COMSA FS_CS EXPO 2025.docx','','COMSA FS_CS EXPO 2025.docx.pdf','uploads\\documents\\COMSA_FS_CS_EXPO_2025.docx_20251229_001217_c3db133f.pdf',0,'','99DB606B1AB3595E','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-28 23:12:17',NULL,'2025-12-28 23:12:17','2025-12-28 23:12:17'),(63,'COMSA FS_Bulletin Board 2025.docx','','COMSA FS_Bulletin Board 2025.docx.pdf','uploads\\documents\\COMSA_FS_Bulletin_Board_2025.docx_20251229_001357_f2d7ce24.pdf',0,'','5231354CF066564D','pending',NULL,NULL,NULL,9,NULL,9,1,6,NULL,'2025-12-28 23:13:57',NULL,'2025-12-28 23:13:57','2025-12-28 23:13:57'),(64,'COMSA FS_CS EXPO 2025.docx','','COMSA FS_CS EXPO 2025.docx.pdf','uploads\\documents\\COMSA_FS_CS_EXPO_2025.docx_20251229_001357_9f0e8100.pdf',0,'','4E752B7192818DA7','pending',NULL,NULL,NULL,9,NULL,9,1,6,NULL,'2025-12-28 23:13:57',NULL,'2025-12-28 23:13:57','2025-12-28 23:13:57'),(65,'COMSA FS_Bulletin Board 2025.docx','','COMSA FS_Bulletin Board 2025.docx.pdf','uploads\\documents\\COMSA_FS_Bulletin_Board_2025.docx_20251229_001443_1c075ac8.pdf',0,'','35932B63521DECD6','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-28 23:14:43',NULL,'2025-12-28 23:14:43','2025-12-28 23:14:43'),(67,'COMSA FS_CS EXPO 2025.docx','','COMSA FS_CS EXPO 2025.docx.pdf','uploads\\documents\\COMSA_FS_CS_EXPO_2025.docx_20251229_001443_c5b71a53.pdf',0,'','1C11CC1D73CD07A5','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-28 23:14:43',NULL,'2025-12-28 23:14:43','2025-12-28 23:14:43'),(69,'BARANGAN - OS Lab Activity 3','','BARANGAN - OS Lab Activity 3.pdf','uploads\\documents\\BARANGAN_-_OS_Lab_Activity_3_20251229_001808_5f31b2ee.pdf',0,'','3CAB07A550E3D26A','pending',NULL,NULL,NULL,1,NULL,1,7,1,NULL,'2025-12-28 23:18:08',NULL,'2025-12-28 23:18:08','2025-12-28 23:18:08'),(71,'BARANGAN - OS Lab Activity 2','','BARANGAN - OS Lab Activity 2.pdf','uploads\\documents\\BARANGAN_-_OS_Lab_Activity_2_20251229_001808_0793a9c9.pdf',0,'','37A6B23C44C12DC9','pending',NULL,NULL,NULL,1,NULL,1,7,1,NULL,'2025-12-28 23:18:08',NULL,'2025-12-28 23:18:08','2025-12-28 23:18:08'),(73,'BARANGAN - OS Lab Activity 3','','BARANGAN - OS Lab Activity 3.pdf','uploads\\documents\\BARANGAN_-_OS_Lab_Activity_3_20251229_001842_bcd2618a.pdf',0,'','069B9C01F19E5A1F','pending',NULL,NULL,NULL,7,NULL,7,3,3,NULL,'2025-12-28 23:18:42',NULL,'2025-12-28 23:18:42','2025-12-28 23:18:42'),(75,'BARANGAN - OS Lab Activity 2','','BARANGAN - OS Lab Activity 2.pdf','uploads\\documents\\BARANGAN_-_OS_Lab_Activity_2_20251229_001842_8963c8fc.pdf',0,'','FD094EA42511005C','pending',NULL,NULL,NULL,7,NULL,7,3,3,NULL,'2025-12-28 23:18:42',NULL,'2025-12-28 23:18:42','2025-12-28 23:18:42'),(77,'BARANGAN-Midterm (1)','','BARANGAN-Midterm (1).pdf','uploads\\documents\\BARANGAN-Midterm__1__20251229_002127_a5be7967.pdf',0,'','132BF518ACEF0C70','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-28 23:21:27',NULL,'2025-12-28 23:21:27','2025-12-28 23:21:27'),(79,'BARANGAN-Midterm','','BARANGAN-Midterm.pdf','uploads\\documents\\BARANGAN-Midterm_20251229_002127_935ce86b.pdf',0,'','4612C088C0663988','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-28 23:21:27',NULL,'2025-12-28 23:21:27','2025-12-28 23:21:27'),(81,'BARANGAN-Midterm (1)','','BARANGAN-Midterm (1).pdf','uploads\\documents\\BARANGAN-Midterm__1__20251229_002422_1dc6c921.pdf',0,'','18218F6F8DB5D01C','pending',NULL,NULL,NULL,9,NULL,9,3,3,NULL,'2025-12-28 23:24:22',NULL,'2025-12-28 23:24:22','2025-12-28 23:24:22'),(83,'BARANGAN-Midterm','','BARANGAN-Midterm.pdf','uploads\\documents\\BARANGAN-Midterm_20251229_002422_d6dbc6c5.pdf',0,'','4DA941A4B99E8A03','pending',NULL,NULL,NULL,9,NULL,9,3,3,NULL,'2025-12-28 23:24:22',NULL,'2025-12-28 23:24:22','2025-12-28 23:24:22'),(85,'BARANGAN-Midterm (1)','','BARANGAN-Midterm (1).pdf','uploads\\documents\\BARANGAN-Midterm__1__20251229_002454_2d84f62b.pdf',0,'','501E7ACAF5729FC4','pending',NULL,NULL,NULL,9,NULL,9,3,3,NULL,'2025-12-28 23:24:54',NULL,'2025-12-28 23:24:54','2025-12-28 23:24:54'),(87,'BARANGAN-Midterm','','BARANGAN-Midterm.pdf','uploads\\documents\\BARANGAN-Midterm_20251229_002454_2cfae972.pdf',0,'','269469B9443D83C8','pending',NULL,NULL,NULL,9,NULL,9,3,3,NULL,'2025-12-28 23:24:54',NULL,'2025-12-28 23:24:54','2025-12-28 23:24:54'),(89,'1','','Trial Document (1) (1).pdf','uploads\\documents\\Trial_Document__1___1__20251229_002648_6a83b5f8.pdf',0,'','FEB3C3646A0F7ED3','pending',NULL,NULL,NULL,1,NULL,1,3,3,NULL,'2025-12-28 23:26:48',NULL,'2025-12-28 23:26:48','2025-12-28 23:26:48'),(91,'2','','Trial Document (2).pdf','uploads\\documents\\Trial_Document__2__20251229_002648_97987034.pdf',0,'','300416E478DF557A','pending',NULL,NULL,NULL,1,NULL,1,3,3,NULL,'2025-12-28 23:26:48',NULL,'2025-12-28 23:26:48','2025-12-28 23:26:48'),(93,'3','','COMSA FS_Bulletin Board 2025.docx.pdf','uploads\\documents\\COMSA_FS_Bulletin_Board_2025.docx_20251229_003104_add1c741.pdf',0,'','00C7F8DE1DBF1CB0','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-28 23:31:04',NULL,'2025-12-28 23:31:04','2025-12-28 23:31:04'),(95,'4','','COMSA FS_CS EXPO 2025.docx.pdf','uploads\\documents\\COMSA_FS_CS_EXPO_2025.docx_20251229_003104_bb049fb4.pdf',0,'','74BFD6060AF1A431','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-28 23:31:04',NULL,'2025-12-28 23:31:04','2025-12-28 23:31:04'),(97,'BARANGAN - OS Lab Activity 2','','BARANGAN - OS Lab Activity 2.pdf','uploads\\documents\\BARANGAN_-_OS_Lab_Activity_2_20251229_134259_c742a21b.pdf',0,'','2BBF3164B004C00F','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-29 12:42:59',NULL,'2025-12-29 12:42:59','2025-12-29 12:42:59'),(99,'COMSA CONSTITUTION AND BYLAWS - LATEST EDITION (1)','','COMSA CONSTITUTION AND BYLAWS - LATEST EDITION (1).pdf','uploads\\documents\\COMSA_CONSTITUTION_AND_BYLAWS_-_LATEST_EDITION__1__20251229_134300_a1fe09f8.pdf',0,'','43240160DB0894E6','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-29 12:43:00',NULL,'2025-12-29 12:43:00','2025-12-29 12:43:00'),(101,'Trial Document (2)','','Trial Document (2).pdf','uploads\\documents\\Trial_Document__2__20251229_134335_fa2d49fa.pdf',0,'','3FF6B6259397C6F4','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-29 12:43:35',NULL,'2025-12-29 12:43:35','2025-12-29 12:43:35'),(103,'Trial Document (1)','','Trial Document (1).pdf','uploads\\documents\\Trial_Document__1__20251229_134336_a78477bf.pdf',0,'','6D14D66C0D5268D8','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-29 12:43:36',NULL,'2025-12-29 12:43:36','2025-12-29 12:43:36'),(105,'Trial Document (2)','','Trial Document (2).pdf','uploads\\documents\\Trial_Document__2__20251229_134616_90f71567.pdf',0,'','2427F23545DB019F','pending',NULL,NULL,NULL,3,NULL,3,7,1,NULL,'2025-12-29 12:46:16',NULL,'2025-12-29 12:46:16','2025-12-29 12:46:16'),(107,'Trial Document (1)','','Trial Document (1).pdf','uploads\\documents\\Trial_Document__1__20251229_134616_851a347e.pdf',0,'','04021FF5F15ED4DC','pending',NULL,NULL,NULL,3,NULL,3,7,1,NULL,'2025-12-29 12:46:16',NULL,'2025-12-29 12:46:16','2025-12-29 12:46:16'),(109,'1','','doc.pdf','uploads\\documents\\doc_20251229_135209_028245bc.pdf',0,'','6BC8FCAEA5FF40AA','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-29 12:52:09',NULL,'2025-12-29 12:52:09','2025-12-29 12:52:09'),(111,'2','','Trial Document (1) (1).pdf','uploads\\documents\\Trial_Document__1___1__20251229_135209_38a88575.pdf',0,'','B74EB6BB79FE3EB9','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-29 12:52:09',NULL,'2025-12-29 12:52:09','2025-12-29 12:52:09'),(113,'doc1','','doc.pdf','uploads\\documents\\doc_20251229_135647_ca143b8e.pdf',0,'','FD5E798E3A066002','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-29 12:56:48',NULL,'2025-12-29 12:56:48','2025-12-29 12:56:48'),(115,'doc1','','doc.pdf','uploads\\documents\\doc_20251229_135911_db150d62.pdf',0,'','E5BAB89AE50DDE02','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-29 12:59:11',NULL,'2025-12-29 12:59:11','2025-12-29 12:59:11'),(117,'doc1','','doc.pdf','uploads\\documents\\doc_20251229_140459_daac6f46.pdf',0,'','5510BBCF27CF61F0','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-29 13:04:59',NULL,'2025-12-29 13:04:59','2025-12-29 13:04:59'),(118,'doc1','','doc.pdf','uploads\\documents\\doc_20251229_140459_daac6f46.pdf',0,'','5510BBCF27CF61F0','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-29 13:05:00',NULL,'2025-12-29 13:05:00','2025-12-29 13:05:00'),(119,'doc2','','Trial Document (1) (1).pdf','uploads\\documents\\Trial_Document__1___1__20251229_140500_dee53a68.pdf',0,'','6E4C5D0120B760C8','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-29 13:05:00',NULL,'2025-12-29 13:05:00','2025-12-29 13:05:00'),(120,'doc2','','Trial Document (1) (1).pdf','uploads\\documents\\Trial_Document__1___1__20251229_140500_dee53a68.pdf',0,'','6E4C5D0120B760C8','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-29 13:05:00',NULL,'2025-12-29 13:05:00','2025-12-29 13:05:00'),(121,'doc222','','doc.pdf','uploads\\documents\\doc_20251229_140523_23a2d73f.pdf',0,'','D670A425F8266C96','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-29 13:05:23',NULL,'2025-12-29 13:05:23','2025-12-29 13:05:23'),(122,'doc222','','doc.pdf','uploads\\documents\\doc_20251229_140523_23a2d73f.pdf',0,'','D670A425F8266C96','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-29 13:05:23',NULL,'2025-12-29 13:05:23','2025-12-29 13:05:23'),(123,'Trial Document (1) (1)','','Trial Document (1) (1).pdf','uploads\\documents\\Trial_Document__1___1__20251229_140523_5b7aab3e.pdf',0,'','B707FFD594CD24A8','pending',NULL,NULL,NULL,3,NULL,3,1,6,NULL,'2025-12-29 13:05:23',NULL,'2025-12-29 13:05:23','2025-12-29 13:05:23'),(124,'Trial Document (1) (1)','','Trial Document (1) (1).pdf','uploads\\documents\\Trial_Document__1___1__20251229_140523_5b7aab3e.pdf',0,'','B707FFD594CD24A8','pending',NULL,NULL,NULL,7,NULL,7,1,6,NULL,'2025-12-29 13:05:23',NULL,'2025-12-29 13:05:23','2025-12-29 13:05:23');
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_otps`
--

DROP TABLE IF EXISTS `password_reset_otps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password_reset_otps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `purpose` varchar(50) NOT NULL DEFAULT 'password_reset',
  `otp_hash` varchar(255) NOT NULL,
  `otp_expires_at` datetime NOT NULL,
  `reset_token_hash` varchar(255) DEFAULT NULL,
  `token_expires_at` datetime DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `used_at` datetime DEFAULT NULL,
  `attempts` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_created` (`user_id`,`created_at`),
  KEY `idx_token` (`reset_token_hash`),
  CONSTRAINT `fk_password_reset_otps_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_otps`
--

LOCK TABLES `password_reset_otps` WRITE;
/*!40000 ALTER TABLE `password_reset_otps` DISABLE KEYS */;
INSERT INTO `password_reset_otps` VALUES (1,3,'password_reset','$2y$10$nUDedE55Xylx9KwPF90Nxu5IqI8w.dYvAtFwWG5pTE09qc17h0Mum','2025-12-28 17:11:39',NULL,NULL,NULL,NULL,0,'2025-12-29 00:01:39'),(2,3,'password_reset','$2y$10$QrQcnpbdtdbYVUOAMaGNd.QJvVoBTcl7R8Opw99LUMZv8QBURaaLq','2025-12-28 17:24:01',NULL,NULL,NULL,NULL,0,'2025-12-29 00:14:01'),(3,3,'password_reset','$2y$10$aoKqmhATDGqdxOHn2nLHHeOAg9sZX6qc6opdxfQ2pA54jOwkWef/u','2025-12-28 17:26:01',NULL,NULL,NULL,NULL,0,'2025-12-29 00:16:01'),(4,3,'password_reset','$2y$10$zPYp0CfIZqzt2j0MUCUFquyKj4Sl4sWfQb3AT59LqyI5AqPvY6PDm','2025-12-28 17:29:09',NULL,NULL,NULL,NULL,0,'2025-12-29 00:19:09'),(5,3,'password_reset','$2y$10$luXDZBdgW/gg14DNZi2b1eDwuu4vJqF9oVRe9MDEvLFu2Ylu68wfi','2025-12-28 17:30:39',NULL,NULL,NULL,NULL,0,'2025-12-29 00:20:39'),(6,3,'password_reset','$2y$10$FYrmWpKj2M5X.KyQwgAnUu7heQqhB0TCViCpnrtJE1H2lH9wek8L.','2025-12-28 17:31:51',NULL,NULL,NULL,NULL,0,'2025-12-29 00:21:51'),(7,3,'password_reset','$2y$10$yHEzQ47dWrPdYUfxpCKQw.VxmmCOB0z5lEMsMGjmW1UTzcOXuVNXu','2025-12-28 17:33:37',NULL,NULL,NULL,NULL,0,'2025-12-29 00:23:37'),(8,3,'password_reset','$2y$10$XH242waMECwod/FR8QquS.UegdIJfQyhBbGSj7/p5VWCRgPWctTV2','2025-12-29 00:35:20','$2y$10$3yZg.Kxu4hDtFnb/fFjwuelFtFVt6jCz.OAEyzMlO73iYWy01YuDm','2025-12-29 00:40:33','2025-12-29 00:25:33','2025-12-29 00:25:42',0,'2025-12-29 00:25:20'),(9,3,'password_reset','$2y$10$C0Xx1/6FVBglRYRclSjXp.9I2Pwcrifpk7c.l0w8UQH3pQfJQabEa','2025-12-29 00:36:28','$2y$10$TwdSBsMDnhQ1JU29yzVgHeUcwixZxmSBfUrAyiIdmfZMuCpmLOkI6','2025-12-29 00:41:40','2025-12-29 00:26:40','2025-12-29 00:26:46',0,'2025-12-29 00:26:28'),(10,3,'password_reset','$2y$10$RZgYZoshiYJsxLaA72nUuO1PmKitUAkPtYopkO6tSJ.NPqUm4yPaK','2025-12-29 00:39:55',NULL,NULL,NULL,NULL,0,'2025-12-29 00:29:55'),(11,3,'password_reset','$2y$10$Wv.gWhhOcPxq8JNcpPnjkO4YNRyy3vWXpeQxpKXbpkmeo6erq/d/e','2025-12-29 00:43:02',NULL,NULL,NULL,NULL,0,'2025-12-29 00:33:02');
/*!40000 ALTER TABLE `password_reset_otps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_logs`
--

DROP TABLE IF EXISTS `system_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level` enum('error','warning','info','debug') NOT NULL,
  `message` text NOT NULL,
  `context` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`context`)),
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_system_logs_level` (`level`),
  KEY `idx_system_logs_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_logs`
--

LOCK TABLES `system_logs` WRITE;
/*!40000 ALTER TABLE `system_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_settings`
--

LOCK TABLES `system_settings` WRITE;
/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
INSERT INTO `system_settings` VALUES (1,'system_name','Document Tracking System','Name of the system','2025-09-21 08:38:29'),(2,'max_file_size','10','Maximum file size in MB','2025-09-21 08:38:29'),(3,'allowed_file_types','pdf,doc,docx,xls,xlsx,jpg,jpeg,png','Allowed file extensions','2025-09-21 08:38:29'),(4,'auto_backup','1','Enable automatic backup','2025-09-21 08:38:29'),(5,'backup_frequency','daily','Backup frequency','2025-09-21 08:38:29'),(6,'email_notifications','1','Enable email notifications','2025-09-21 08:38:29'),(7,'session_timeout','30','Session timeout in minutes','2025-09-21 08:38:29');
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_activities`
--

DROP TABLE IF EXISTS `user_activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_activities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `action` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `ip_address_bin` varbinary(16) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `user_agent_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_activities_user_id` (`user_id`),
  KEY `idx_user_activities_created_at` (`created_at`),
  KEY `idx_user_activities_user_created` (`user_id`,`created_at`),
  KEY `idx_user_activities_action_created` (`action`,`created_at`),
  KEY `idx_user_activities_created` (`created_at`),
  KEY `idx_user_activities_user_agent_id` (`user_agent_id`),
  CONSTRAINT `user_activities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=192 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_activities`
--

LOCK TABLES `user_activities` WRITE;
/*!40000 ALTER TABLE `user_activities` DISABLE KEYS */;
INSERT INTO `user_activities` VALUES (1,1,'create_department','Created department: Sample',NULL,NULL,NULL,NULL,'2025-09-21 08:40:04'),(2,1,'update_department','Updated department from \'Sample\' to \'Sample\'',NULL,NULL,NULL,NULL,'2025-09-21 08:40:11'),(3,1,'delete_department','Deleted department: Sample',NULL,NULL,NULL,NULL,'2025-09-21 08:40:16'),(4,1,'send_document','Sent document \'sample 3\' to IT Department department',NULL,NULL,NULL,NULL,'2025-09-21 08:44:07'),(5,3,'receive_document','Received document \'sample 3\' from Admin User',NULL,NULL,NULL,NULL,'2025-09-21 08:49:46'),(6,1,'send_document','Sent document \'Sample 4\' to Human Resources department',NULL,NULL,NULL,NULL,'2025-09-21 08:52:06'),(7,2,'receive_document','Received document \'Sample 4\' from Admin User',NULL,NULL,NULL,NULL,'2025-09-21 08:54:35'),(8,1,'send_document','Sent document \'weweew\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 15:46:47'),(9,2,'send_document','Sent document \'iuwar\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 17:52:03'),(10,2,'send_document','Sent document \'iuwar\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 17:52:06'),(11,2,'send_document','Sent document \'iuwar\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 17:52:09'),(12,2,'send_document','Sent document \'iuwar\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 17:52:15'),(13,2,'send_document','Sent document \'iuwar\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 17:52:58'),(14,2,'send_document','Sent document \'iuwar\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 17:53:02'),(15,2,'send_document','Sent document \'iuwar\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:01:17'),(16,2,'send_document','Sent document \'iuwar\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:02:30'),(17,2,'send_document','Sent document \'iuwar\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:02:32'),(18,2,'send_document','Sent document \'iuwar\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:11:02'),(19,2,'send_document','Sent document \'iuwar\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:11:06'),(20,2,'send_document','Sent document \'iuwar\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:17:25'),(21,2,'send_document','Sent document \'iuwar\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:17:43'),(22,2,'send_document','Sent document \'iuwar\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:17:48'),(23,2,'send_document','Sent document \'iuwar\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:17:51'),(24,2,'send_document','Sent document \'iuwar\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:32:54'),(25,2,'send_document','Sent document \'iuwar\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:33:15'),(26,2,'send_document','Sent document \'iuwar\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:34:05'),(27,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:35:36'),(28,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:41:21'),(29,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:41:36'),(30,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:44:53'),(31,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:45:39'),(32,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:45:42'),(33,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:46:11'),(34,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:46:14'),(35,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:46:19'),(36,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:46:22'),(37,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:46:25'),(38,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:46:31'),(39,2,'send_document','Sent document \'tuktuk\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:46:35'),(40,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:46:38'),(41,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:50:10'),(42,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:50:43'),(43,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:51:01'),(44,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:58:46'),(45,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:58:56'),(46,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:59:42'),(47,2,'send_document','Sent document \'iuwar\' to IT Department department',NULL,NULL,NULL,NULL,'2025-10-04 18:59:46'),(48,2,'send_document','Sent document \'tuktuk\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-10-04 19:00:13'),(49,1,'receive_document','Received document \'tuktuk\' from Staff User',NULL,NULL,NULL,NULL,'2025-11-04 12:26:45'),(50,1,'forward_document','Forwarded document \'tuktuk\' to Human Resources department',NULL,NULL,NULL,NULL,'2025-11-04 13:16:05'),(51,1,'upload_document','Uploaded document \'1\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-04 16:47:50'),(52,3,'receive_document','Received document \'1\' from Admin User',NULL,NULL,NULL,NULL,'2025-11-04 17:04:54'),(53,3,'forward_document','Forwarded document \'1\' to Human Resources department',NULL,NULL,NULL,NULL,'2025-11-04 17:05:01'),(54,2,'cancel_document','Cancelled document \'1\' - marked as rejected',NULL,NULL,NULL,NULL,'2025-11-04 17:11:31'),(55,1,'upload_document','Uploaded document \'2\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-04 17:18:05'),(56,3,'receive_document','Received document \'2\' from Admin User',NULL,NULL,NULL,NULL,'2025-11-04 17:18:34'),(57,3,'forward_document','Forwarded document \'2\' to Human Resources department',NULL,NULL,NULL,NULL,'2025-11-04 17:18:40'),(58,3,'cancel_document','Cancelled document \'2\' - marked as rejected',NULL,NULL,NULL,NULL,'2025-11-04 17:37:09'),(59,3,'upload_document','Uploaded document \'1\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-04 17:37:59'),(60,3,'upload_document','Uploaded document \'1\' and sent to department ID 7',NULL,NULL,NULL,NULL,'2025-11-04 17:38:11'),(61,1,'cancel_document','Cancelled document \'1\' - marked as rejected',NULL,NULL,NULL,NULL,'2025-11-04 17:38:19'),(62,1,'upload_document','Uploaded document \'1\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-04 17:40:20'),(63,3,'cancel_document','Cancelled document \'1\' - marked as rejected',NULL,NULL,NULL,NULL,'2025-11-04 17:40:30'),(64,1,'upload_document','Uploaded document \'1\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-04 17:47:42'),(65,3,'cancel_document','Cancelled document \'1\' - marked as rejected',NULL,NULL,NULL,NULL,'2025-11-04 17:47:49'),(66,1,'upload_document','Uploaded document \'1\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-04 17:48:17'),(67,3,'cancel_document','Cancelled document \'1\' - marked as rejected',NULL,NULL,NULL,NULL,'2025-11-04 17:48:23'),(68,1,'upload_document','Uploaded document \'1\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-04 17:51:15'),(69,3,'cancel_document','Cancelled document \'1\' - marked as rejected',NULL,NULL,NULL,NULL,'2025-11-04 17:51:20'),(70,1,'upload_document','Uploaded document \'1\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-04 18:38:47'),(71,1,'upload_document','Uploaded document \'1\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-04 18:39:56'),(72,3,'upload_document','Uploaded document \'1\' and sent to department ID 7',NULL,NULL,NULL,NULL,'2025-11-04 19:36:08'),(73,1,'receive_document','Received document \'1\' from Jb',NULL,NULL,NULL,NULL,'2025-11-05 00:42:11'),(74,1,'forward_document','Forwarded document \'1\' to Human Resources department',NULL,NULL,NULL,NULL,'2025-11-05 00:46:00'),(75,2,'receive_document','Received document \'1\' from Jb',NULL,NULL,NULL,NULL,'2025-11-05 00:46:51'),(76,1,'forward_document','Forwarded document \'1\' to IT Department department',NULL,NULL,NULL,NULL,'2025-11-05 01:06:29'),(77,1,'upload_document','Uploaded document \'1\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-05 01:06:57'),(78,3,'forward_document','Forwarded document \'1\' to Human Resources department',NULL,NULL,NULL,NULL,'2025-11-05 01:07:31'),(79,2,'forward_document','Forwarded document \'1\' to MIS Department department',NULL,NULL,NULL,NULL,'2025-11-05 01:08:10'),(80,1,'upload_document','Uploaded document \'1\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-05 01:12:35'),(81,1,'upload_document','Uploaded document \'sample nanaman\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-05 01:18:03'),(82,1,'upload_document','Uploaded document \'sadsad\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-05 01:20:23'),(83,3,'receive_document','Received document \'sadsad\' from Admin User',NULL,NULL,NULL,NULL,'2025-11-05 01:20:42'),(84,3,'forward_document','Forwarded document \'sadsad\' to Human Resources department',NULL,NULL,NULL,NULL,'2025-11-05 01:20:51'),(85,2,'receive_document','Received document \'sadsad\' from Admin User',NULL,NULL,NULL,NULL,'2025-11-05 01:21:09'),(86,2,'upload_document','Uploaded document \'1\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-05 01:39:02'),(87,1,'create_department','Created department: Sample Department',NULL,NULL,NULL,NULL,'2025-11-05 02:07:26'),(88,1,'upload_document','Uploaded document \'1\' and sent to department ID 9',NULL,NULL,NULL,NULL,'2025-11-05 02:40:59'),(89,1,'upload_document','Uploaded document \'121\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-05 02:50:09'),(90,1,'upload_document','Uploaded document \'12\' and sent to department ID 3',NULL,NULL,NULL,NULL,'2025-11-05 02:53:32'),(91,1,'cancel_document','Cancelled document \'13\' - marked as rejected',NULL,NULL,NULL,NULL,'2025-11-06 09:34:52'),(92,1,'cancel_document','Cancelled document \'1\' - marked as rejected',NULL,NULL,NULL,NULL,'2025-11-19 15:19:43'),(93,1,'upload_document','Uploaded document \'1\' to IT Department department',NULL,NULL,NULL,NULL,'2025-12-22 02:45:57'),(94,3,'receive_document','Received document \'1\' at final destination',NULL,NULL,NULL,NULL,'2025-12-22 04:19:51'),(95,2,'cancel_document','Cancelled document \'1\' - marked as rejected',NULL,NULL,NULL,NULL,'2025-12-22 05:27:38'),(96,1,'upload_document','Uploaded document \'1s\' to Human Resources department',NULL,NULL,NULL,NULL,'2025-12-22 05:28:25'),(97,1,'upload_document','Uploaded document \'1s\' to Human Resources department',NULL,NULL,NULL,NULL,'2025-12-22 05:28:27'),(98,1,'upload_document','Uploaded document \'sad\' to IT Department department',NULL,NULL,NULL,NULL,'2025-12-22 05:28:42'),(99,2,'upload_document','Uploaded document \'13232\'',NULL,NULL,NULL,NULL,'2025-12-22 07:57:18'),(100,1,'create_department','Created department: Sample2',NULL,NULL,NULL,NULL,'2025-12-22 10:24:29'),(101,1,'update_department','Updated department from \'IT Department\' to \'IT Department\'',NULL,NULL,NULL,NULL,'2025-12-22 10:24:48'),(102,1,'update_department','Updated department from \'Human Resources\' to \'Human Resources\'',NULL,NULL,NULL,NULL,'2025-12-22 10:25:21'),(103,1,'update_department','Updated department from \'IT Department\' to \'IT Department\'',NULL,NULL,NULL,NULL,'2025-12-22 10:25:27'),(104,1,'update_department','Updated department from \'MIS Department\' to \'MIS Department\'',NULL,NULL,NULL,NULL,'2025-12-22 10:25:30'),(105,1,'update_department','Updated department from \'Sample Department\' to \'Sample Department\'',NULL,NULL,NULL,NULL,'2025-12-22 10:25:32'),(106,1,'update_department','Updated department from \'Sample2\' to \'Sample2\'',NULL,NULL,NULL,NULL,'2025-12-22 10:25:34'),(107,3,'upload_document','Uploaded document \'1s3s\' and sent to department ID 7',NULL,NULL,NULL,NULL,'2025-12-22 10:42:43'),(108,1,'upload_document','Uploaded document \'123\'',NULL,NULL,NULL,NULL,'2025-12-22 10:59:54'),(109,3,'receive_document','Received document \'123\'',NULL,NULL,NULL,NULL,'2025-12-22 11:36:03'),(110,2,'receive_document','Received document \'123\'',NULL,NULL,NULL,NULL,'2025-12-22 11:36:42'),(111,4,'receive_document','Received document \'123\'',NULL,NULL,NULL,NULL,'2025-12-22 11:47:02'),(112,1,'upload_document','Uploaded document \'Trial 1\'',NULL,NULL,NULL,NULL,'2025-12-22 11:47:32'),(113,3,'receive_document','Received document \'Trial 1\'',NULL,NULL,NULL,NULL,'2025-12-22 11:47:58'),(114,2,'receive_document','Received document \'Trial 1\'',NULL,NULL,NULL,NULL,'2025-12-22 11:48:18'),(115,4,'cancel_document','Cancelled document \'Trial 1\' - marked as rejected',NULL,NULL,NULL,NULL,'2025-12-22 11:50:34'),(116,1,'upload_document','Uploaded document \'Trial 2\'',NULL,NULL,NULL,NULL,'2025-12-22 11:51:25'),(117,4,'receive_document','Received document \'Trial 2\'',NULL,NULL,NULL,NULL,'2025-12-22 11:51:47'),(118,2,'receive_document','Received document \'Trial 2\'',NULL,NULL,NULL,NULL,'2025-12-22 11:55:45'),(119,3,'cancel_document','Cancelled document \'Trial 2\' - marked as rejected',NULL,NULL,NULL,NULL,'2025-12-22 11:56:16'),(120,1,'upload_document','Uploaded document \'Trial 3\'',NULL,NULL,NULL,NULL,'2025-12-22 12:03:35'),(121,3,'receive_document','Received document \'Trial 3\'',NULL,NULL,NULL,NULL,'2025-12-22 12:07:45'),(122,2,'receive_document','Received document \'Trial 3\'',NULL,NULL,NULL,NULL,'2025-12-22 12:08:50'),(123,4,'receive_document','Received document \'Trial 3\'',NULL,NULL,NULL,NULL,'2025-12-22 12:19:20'),(124,1,'upload_document','Uploaded document \'Trial 4\'',NULL,NULL,NULL,NULL,'2025-12-22 12:35:20'),(125,1,'create_staff','Created staff \'Lycka\' (ID: 6, role: department_head)','::1','\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',NULL,1,'2025-12-28 16:52:20'),(126,1,'toggle_staff_status','Staff member (ID: 2) deactivated','::1','\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',NULL,1,'2025-12-28 16:52:24'),(127,6,'login','Logged in','127.0.0.1','\0\0',NULL,3,'2025-12-28 16:53:55'),(128,6,'receive_document','Received document \'Trial 4\' (ID: 41)','127.0.0.1','\0\0',NULL,3,'2025-12-28 16:54:20'),(129,6,'forward_document','Forwarded document (ID: 41) from dept 1 to dept 3','127.0.0.1','\0\0',NULL,3,'2025-12-28 16:54:45'),(130,1,'cancel_document','Cancelled document \'1s3s\' (ID: 36) - marked as rejected','127.0.0.1','\0\0',NULL,1,'2025-12-28 17:27:18'),(131,1,'upload_document','Uploaded document \'Trial 5\' (ID: 42)','127.0.0.1','\0\0',NULL,1,'2025-12-28 20:18:16'),(132,1,'upload_document','Uploaded document \'Trial 5.1\' (ID: 43)','127.0.0.1','\0\0',NULL,1,'2025-12-28 20:22:44'),(133,1,'download_document','Downloaded document \'Trial 5.1\' (ID: 43)','127.0.0.1','\0\0',NULL,1,'2025-12-28 20:23:20'),(134,1,'upload_document','Uploaded document \'Trial 5.2\' (ID: 44)','127.0.0.1','\0\0',NULL,1,'2025-12-28 20:23:59'),(135,1,'upload_document','Uploaded document \'Trial 5.3\' (ID: 45)','127.0.0.1','\0\0',NULL,1,'2025-12-28 21:01:38'),(136,6,'receive_document','Received document \'Trial 5.3\' (ID: 45)','127.0.0.1','\0\0',NULL,3,'2025-12-28 21:08:22'),(137,6,'forward_document','Forwarded document (ID: 45) from dept 1 to dept 3','127.0.0.1','\0\0',NULL,3,'2025-12-28 21:08:47'),(138,6,'login','Logged in','127.0.0.1','\0\0',NULL,1,'2025-12-28 21:19:19'),(139,1,'login','Logged in','127.0.0.1','\0\0',NULL,3,'2025-12-28 21:22:41'),(140,6,'receive_document','Received document \'Trial 5.2\' (ID: 44)','127.0.0.1','\0\0',NULL,1,'2025-12-28 21:51:53'),(141,3,'login','Logged in','127.0.0.1','\0\0',NULL,1,'2025-12-28 21:53:07'),(142,3,'receive_document','Received document \'Trial 5.3\' (ID: 45)','127.0.0.1','\0\0',NULL,1,'2025-12-28 21:53:22'),(143,3,'download_document','Downloaded document \'Trial 5.3\' (ID: 45)','127.0.0.1','\0\0',NULL,1,'2025-12-28 22:05:39'),(144,6,'login','Logged in','127.0.0.1','\0\0',NULL,1,'2025-12-28 22:29:24'),(145,6,'upload_document','Uploaded document \'COMSA FS_Bulletin Board and CS EXPO 2025\' (ID: 46, File: COMSA FS_Bulletin Board 2025.docx.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-28 22:41:59'),(146,6,'upload_document','Uploaded document \'COMSA FS_CS EXPO 2025.docx\' (ID: 48, File: COMSA FS_CS EXPO 2025.docx.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-28 22:41:59'),(147,3,'upload_document','Uploaded document \'doc\' (ID: 50, File: doc.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:02:55'),(148,3,'upload_document','Uploaded document \'Trial Document (1) (1)\' (ID: 52, File: Trial Document (1) (1).pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:02:55'),(149,6,'upload_document','Uploaded document \'doc\' (ID: 54, File: doc.pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:06:45'),(150,6,'upload_document','Uploaded document \'Trial Document (1) (1)\' (ID: 56, File: Trial Document (1) (1).pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:06:45'),(151,3,'upload_document','Uploaded document \'Trial Document (1)\' (ID: 58, File: Trial Document (1).pdf) to department ID: 1','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:07:09'),(152,6,'upload_document','Uploaded document \'COMSA FS_Bulletin Board 2025.docx\' (ID: 59, File: COMSA FS_Bulletin Board 2025.docx.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:11:37'),(153,6,'upload_document','Uploaded document \'COMSA FS_CS EXPO 2025.docx\' (ID: 60, File: COMSA FS_CS EXPO 2025.docx.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:11:37'),(154,6,'upload_document','Uploaded document \'COMSA FS_Bulletin Board 2025.docx\' (ID: 61, File: COMSA FS_Bulletin Board 2025.docx.pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:12:17'),(155,6,'upload_document','Uploaded document \'COMSA FS_CS EXPO 2025.docx\' (ID: 62, File: COMSA FS_CS EXPO 2025.docx.pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:12:17'),(156,6,'upload_document','Uploaded document \'COMSA FS_Bulletin Board 2025.docx\' (ID: 63, File: COMSA FS_Bulletin Board 2025.docx.pdf) to department ID: 9','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:13:57'),(157,6,'upload_document','Uploaded document \'COMSA FS_CS EXPO 2025.docx\' (ID: 64, File: COMSA FS_CS EXPO 2025.docx.pdf) to department ID: 9','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:13:57'),(158,6,'upload_document','Uploaded document \'COMSA FS_Bulletin Board 2025.docx\' (ID: 65, File: COMSA FS_Bulletin Board 2025.docx.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:14:43'),(159,6,'upload_document','Uploaded document \'COMSA FS_CS EXPO 2025.docx\' (ID: 67, File: COMSA FS_CS EXPO 2025.docx.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:14:43'),(160,1,'upload_document','Uploaded document \'BARANGAN - OS Lab Activity 3\' (ID: 69, File: BARANGAN - OS Lab Activity 3.pdf) to department ID: 1','127.0.0.1','\0\0',NULL,3,'2025-12-28 23:18:08'),(161,1,'upload_document','Uploaded document \'BARANGAN - OS Lab Activity 2\' (ID: 71, File: BARANGAN - OS Lab Activity 2.pdf) to department ID: 1','127.0.0.1','\0\0',NULL,3,'2025-12-28 23:18:08'),(162,3,'upload_document','Uploaded document \'BARANGAN - OS Lab Activity 3\' (ID: 73, File: BARANGAN - OS Lab Activity 3.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:18:42'),(163,3,'upload_document','Uploaded document \'BARANGAN - OS Lab Activity 2\' (ID: 75, File: BARANGAN - OS Lab Activity 2.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:18:42'),(164,6,'upload_document','Uploaded document \'BARANGAN-Midterm (1)\' (ID: 77, File: BARANGAN-Midterm (1).pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:21:27'),(165,6,'upload_document','Uploaded document \'BARANGAN-Midterm\' (ID: 79, File: BARANGAN-Midterm.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:21:27'),(166,3,'upload_document','Uploaded document \'BARANGAN-Midterm (1)\' (ID: 81, File: BARANGAN-Midterm (1).pdf) to department ID: 9','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:24:22'),(167,3,'upload_document','Uploaded document \'BARANGAN-Midterm\' (ID: 83, File: BARANGAN-Midterm.pdf) to department ID: 9','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:24:22'),(168,3,'upload_document','Uploaded document \'BARANGAN-Midterm (1)\' (ID: 85, File: BARANGAN-Midterm (1).pdf) to department ID: 9','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:24:54'),(169,3,'upload_document','Uploaded document \'BARANGAN-Midterm\' (ID: 87, File: BARANGAN-Midterm.pdf) to department ID: 9','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:24:55'),(170,3,'upload_document','Uploaded document \'1\' (ID: 89, File: Trial Document (1) (1).pdf) to department ID: 1','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:26:48'),(171,3,'upload_document','Uploaded document \'2\' (ID: 91, File: Trial Document (2).pdf) to department ID: 1','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:26:48'),(172,6,'upload_document','Uploaded document \'3\' (ID: 93, File: COMSA FS_Bulletin Board 2025.docx.pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:31:04'),(173,6,'upload_document','Uploaded document \'4\' (ID: 95, File: COMSA FS_CS EXPO 2025.docx.pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-28 23:31:04'),(174,6,'upload_document','Uploaded document \'BARANGAN - OS Lab Activity 2\' (ID: 97, File: BARANGAN - OS Lab Activity 2.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-29 12:42:59'),(175,6,'upload_document','Uploaded document \'COMSA CONSTITUTION AND BYLAWS - LATEST EDITION (1)\' (ID: 99, File: COMSA CONSTITUTION AND BYLAWS - LATEST EDITION (1).pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-29 12:43:00'),(176,6,'upload_document','Uploaded document \'Trial Document (2)\' (ID: 101, File: Trial Document (2).pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-29 12:43:36'),(177,6,'upload_document','Uploaded document \'Trial Document (1)\' (ID: 103, File: Trial Document (1).pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-29 12:43:36'),(178,1,'upload_document','Uploaded document \'Trial Document (2)\' (ID: 105, File: Trial Document (2).pdf) to department ID: 3','127.0.0.1','\0\0',NULL,3,'2025-12-29 12:46:16'),(179,1,'upload_document','Uploaded document \'Trial Document (1)\' (ID: 107, File: Trial Document (1).pdf) to department ID: 3','127.0.0.1','\0\0',NULL,3,'2025-12-29 12:46:16'),(180,6,'upload_document','Uploaded document \'1\' (ID: 109, File: doc.pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-29 12:52:09'),(181,6,'upload_document','Uploaded document \'2\' (ID: 111, File: Trial Document (1) (1).pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-29 12:52:10'),(182,6,'upload_document','Uploaded document \'doc1\' (ID: 113, File: doc.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-29 12:56:48'),(183,6,'upload_document','Uploaded document \'doc1\' (ID: 115, File: doc.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-29 12:59:11'),(184,6,'upload_document','Uploaded document \'doc1\' (ID: 117, File: doc.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-29 13:04:59'),(185,6,'upload_document','Uploaded document \'doc1\' (ID: 118, File: doc.pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-29 13:05:00'),(186,6,'upload_document','Uploaded document \'doc2\' (ID: 119, File: Trial Document (1) (1).pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-29 13:05:00'),(187,6,'upload_document','Uploaded document \'doc2\' (ID: 120, File: Trial Document (1) (1).pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-29 13:05:00'),(188,6,'upload_document','Uploaded document \'doc222\' (ID: 121, File: doc.pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-29 13:05:23'),(189,6,'upload_document','Uploaded document \'doc222\' (ID: 122, File: doc.pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-29 13:05:23'),(190,6,'upload_document','Uploaded document \'Trial Document (1) (1)\' (ID: 123, File: Trial Document (1) (1).pdf) to department ID: 3','127.0.0.1','\0\0',NULL,1,'2025-12-29 13:05:23'),(191,6,'upload_document','Uploaded document \'Trial Document (1) (1)\' (ID: 124, File: Trial Document (1) (1).pdf) to department ID: 7','127.0.0.1','\0\0',NULL,1,'2025-12-29 13:05:23');
/*!40000 ALTER TABLE `user_activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_agents`
--

DROP TABLE IF EXISTS `user_agents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_agents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_agent_hash` char(64) NOT NULL,
  `user_agent` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_agents_hash` (`user_agent_hash`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_agents`
--

LOCK TABLES `user_agents` WRITE;
/*!40000 ALTER TABLE `user_agents` DISABLE KEYS */;
INSERT INTO `user_agents` VALUES (1,'62d18984722ed057781bce4342a009271fd0bf4799981a048ca348f09af03584','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36','2025-12-28 16:52:20'),(3,'5b2920236e2fe135ff730881b0a56661712a0d643178e5e3911441c8fe3b6f9d','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) document-tracking-system/1.0.0 Chrome/118.0.5993.159 Electron/27.3.11 Safari/537.36','2025-12-28 16:53:55');
/*!40000 ALTER TABLE `user_agents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','staff','department_head') DEFAULT 'staff',
  `department_id` int(11) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_users_department_id` (`department_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Admin User','admin@doctrack.com','$2y$10$iRZcGKxg.d6gR75QrlhxD.DrKPLLQowtV.17mZHnzi1lkfcsn4kRC','admin',7,1,'2025-09-21 07:54:59','2025-12-28 16:40:42'),(2,'Staff User','staff@doctrack.com','$2y$10$iRZcGKxg.d6gR75QrlhxD.DrKPLLQowtV.17mZHnzi1lkfcsn4kRC','department_head',1,0,'2025-09-21 07:54:59','2025-12-28 16:52:24'),(3,'Jb','barangan.jb.bscs@gmail.com','$2y$10$T.LgTZ0rAlQYXZM6BkAB.uz/.UHUwmfJiSxrWBTrH5/kvqVCaCP3u','staff',3,1,'2025-09-21 08:32:53','2025-12-28 16:42:56'),(4,'sample','sample@gmail.com','$2y$10$tlU7vU8kJxlzAOUJLrsTju33/rilKC2xcKJGSQ9LAycOQ4/sD8uo.','staff',9,0,'2025-11-05 02:39:28','2025-12-28 16:40:52'),(6,'Lycka','baylon.lj.bscs@gmail.com','$2y$10$OjeKT1e9b8YGRjvmZuGcceVTxHHEae8QX67qNRZs3AG5w1gADwc.m','department_head',1,1,'2025-12-28 16:52:20','2025-12-28 16:52:20');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-29 21:11:33
