-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: FDB
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
-- Table structure for table `address_book`
--

DROP TABLE IF EXISTS `address_book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `address_book` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `owner` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `address_book`
--

LOCK TABLES `address_book` WRITE;
/*!40000 ALTER TABLE `address_book` DISABLE KEYS */;
/*!40000 ALTER TABLE `address_book` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_report_messages`
--

DROP TABLE IF EXISTS `admin_report_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_report_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_id` int(11) NOT NULL,
  `sender_type` varchar(50) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `sender_name` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  CONSTRAINT `admin_report_messages_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `admin_reports` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_report_messages`
--

LOCK TABLES `admin_report_messages` WRITE;
/*!40000 ALTER TABLE `admin_report_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_report_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_report_nearby_players`
--

DROP TABLE IF EXISTS `admin_report_nearby_players`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_report_nearby_players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `player_name` varchar(255) NOT NULL,
  `player_license` varchar(255) NOT NULL,
  `distance` float NOT NULL,
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  CONSTRAINT `admin_report_nearby_players_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `admin_reports` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_report_nearby_players`
--

LOCK TABLES `admin_report_nearby_players` WRITE;
/*!40000 ALTER TABLE `admin_report_nearby_players` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_report_nearby_players` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_reports`
--

DROP TABLE IF EXISTS `admin_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_type` varchar(50) NOT NULL,
  `reporter_id` int(11) NOT NULL,
  `reporter_name` varchar(255) NOT NULL,
  `reporter_license` varchar(255) NOT NULL,
  `reporter_discord` varchar(255) DEFAULT NULL,
  `reporter_coords` varchar(255) NOT NULL,
  `reported_player_id` int(11) DEFAULT NULL,
  `reported_player_name` varchar(255) DEFAULT NULL,
  `reported_player_license` varchar(255) DEFAULT NULL,
  `reported_player_discord` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `status` varchar(50) DEFAULT 'open',
  `assigned_admin_id` int(11) DEFAULT NULL,
  `assigned_admin_name` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_reports`
--

LOCK TABLES `admin_reports` WRITE;
/*!40000 ALTER TABLE `admin_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backpacks`
--

DROP TABLE IF EXISTS `backpacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `backpacks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` varchar(50) NOT NULL,
  `stash` varchar(100) NOT NULL,
  `owner` varchar(50) NOT NULL,
  `model` varchar(50) NOT NULL,
  `coords` text DEFAULT NULL,
  `rotation` float DEFAULT 0,
  `durability` int(11) DEFAULT 100,
  `state` varchar(20) DEFAULT 'item',
  `metadata` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backpacks`
--

LOCK TABLES `backpacks` WRITE;
/*!40000 ALTER TABLE `backpacks` DISABLE KEYS */;
/*!40000 ALTER TABLE `backpacks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bans`
--

DROP TABLE IF EXISTS `bans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `license` varchar(50) DEFAULT NULL,
  `discord` varchar(50) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `expire` int(11) DEFAULT NULL,
  `bannedby` varchar(255) NOT NULL DEFAULT 'Anticheat',
  PRIMARY KEY (`id`),
  KEY `license` (`license`),
  KEY `discord` (`discord`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bans`
--

LOCK TABLES `bans` WRITE;
/*!40000 ALTER TABLE `bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `bans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crime_history`
--

DROP TABLE IF EXISTS `crime_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crime_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `crime_id` varchar(50) NOT NULL,
  `success` tinyint(1) NOT NULL DEFAULT 0,
  `reward_type` varchar(10) NOT NULL DEFAULT 'item',
  `reward_value` varchar(255) NOT NULL DEFAULT '',
  `witness` tinyint(1) NOT NULL DEFAULT 0,
  `evidence` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_crime_history_citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=169 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crime_history`
--

LOCK TABLES `crime_history` WRITE;
/*!40000 ALTER TABLE `crime_history` DISABLE KEYS */;
INSERT INTO `crime_history` VALUES (1,'EOZ28811','npc_robbery',0,'item','0',0,0,'2026-08-10 17:19:33'),(2,'EOZ28811','npc_robbery',0,'item','0',1,0,'2026-08-10 20:50:15'),(3,'EOZ28811','npc_robbery',1,'item','10',0,0,'2026-08-10 21:20:07'),(4,'EOZ28811','npc_robbery',0,'item','0',0,0,'2026-08-10 21:41:57'),(5,'EOZ28811','npc_robbery',1,'item','0',1,0,'2026-08-10 21:42:28'),(6,'EOZ28811','npc_robbery',0,'item','0',1,0,'2026-08-10 21:42:50'),(7,'EOZ28811','npc_robbery',1,'item','0',0,0,'2026-08-10 21:43:10'),(8,'EOZ28811','npc_robbery',1,'item','0',1,0,'2026-08-10 22:36:57'),(9,'EOZ28811','npc_robbery',1,'item','0',0,0,'2026-08-11 09:32:54'),(10,'EOZ28811','grave_robbery',0,'item','0',0,0,'2026-08-11 11:20:46'),(11,'EOZ28811','grave_robbery',0,'item','0',0,0,'2026-08-11 11:21:35'),(12,'EOZ28811','grave_robbery',1,'item','0',0,0,'2026-08-11 11:21:51'),(13,'EOZ28811','grave_robbery',1,'item','0',0,0,'2026-08-11 12:04:40'),(14,'EOZ28811','grave_robbery',1,'item','0',0,0,'2026-08-11 12:06:05'),(15,'EOZ28811','grave_robbery',0,'item','0',0,0,'2026-08-11 12:08:32'),(16,'EOZ28811','grave_robbery',1,'item','0',0,0,'2026-08-11 12:18:17'),(17,'EOZ28811','grave_robbery',1,'item','0',0,0,'2026-08-11 12:19:12'),(18,'EOZ28811','grave_robbery',0,'item','0',0,0,'2026-08-11 12:20:44'),(19,'EOZ28811','grave_robbery',1,'item','0',0,0,'2026-08-11 12:33:23'),(20,'EOZ28811','grave_robbery',1,'item','0',0,0,'2026-08-11 12:33:46'),(21,'EOZ28811','grave_robbery',1,'item','0',0,0,'2026-08-11 12:33:54'),(22,'WCT10843','npc_robbery',1,'item','0',1,0,'2026-08-11 17:02:56'),(23,'EOZ28811','npc_robbery',0,'item','0',1,0,'2026-08-11 17:51:31'),(24,'EOZ28811','npc_robbery',0,'item','0',0,0,'2026-08-11 19:02:23'),(25,'EOZ28811','store_robbery',0,'item','0',1,0,'2026-08-11 19:05:20'),(26,'WTQ34275','npc_robbery',0,'item','0',0,0,'2026-08-11 20:21:50'),(27,'WTQ34275','grave_robbery',0,'item','0',0,0,'2026-08-11 21:31:09'),(28,'WTQ34275','grave_robbery',1,'item','0',0,1,'2026-08-11 21:31:24'),(29,'WTQ34275','npc_robbery',1,'item','0',0,0,'2026-08-11 21:32:25'),(30,'WTQ34275','store_robbery',0,'item','0',0,0,'2026-08-11 21:32:41'),(31,'EOZ28811','store_robbery',1,'item','0',0,0,'2026-08-12 00:15:20'),(32,'EOZ28811','store_robbery',1,'item','0',0,0,'2026-08-12 00:20:51'),(33,'EOZ28811','npc_robbery',0,'item','0',0,0,'2026-08-12 00:24:16'),(34,'EOZ28811','store_robbery',1,'item','0',0,0,'2026-08-12 00:49:54'),(35,'EOZ28811','store_robbery',0,'item','0',0,0,'2026-08-12 00:57:54'),(36,'EOZ28811','store_robbery',1,'item','0',0,0,'2026-08-12 01:16:09'),(37,'EOZ28811','store_robbery',0,'item','0',0,0,'2026-08-12 01:16:52'),(38,'EOZ28811','npc_robbery',1,'item','0',0,0,'2026-08-12 01:30:41'),(39,'EOZ28811','npc_robbery',1,'item','0',1,0,'2026-08-12 01:36:46'),(40,'EOZ28811','store_robbery',1,'item','0',0,0,'2026-08-12 08:00:46'),(41,'EOZ28811','store_robbery',1,'item','0',0,0,'2026-08-12 08:23:34'),(42,'EOZ28811','store_robbery',1,'item','0',0,0,'2026-08-12 08:39:48'),(43,'EOZ28811','store_robbery',1,'item','0',0,0,'2026-08-12 08:46:33'),(44,'EOZ28811','store_robbery',0,'item','0',0,0,'2026-08-12 08:52:42'),(45,'EOZ28811','store_robbery',0,'item','0',0,0,'2026-08-12 10:45:52'),(46,'EOZ28811','store_robbery',0,'item','0',0,0,'2026-08-12 10:46:38'),(47,'EOZ28811','store_robbery',1,'item','0',0,0,'2026-08-12 11:02:32'),(48,'EOZ28811','store_robbery',1,'item','0',0,0,'2026-08-12 11:15:51'),(49,'WTQ34275','store_robbery',0,'item','0',0,0,'2026-08-12 11:41:07'),(50,'WTQ34275','store_robbery',1,'item','0',0,0,'2026-08-12 12:42:50'),(51,'WTQ34275','store_robbery',1,'item','0',0,0,'2026-08-12 12:44:20'),(52,'WTQ34275','store_robbery',1,'item','0',0,0,'2026-08-12 13:09:35'),(53,'WTQ34275','store_robbery',1,'item','0',0,0,'2026-08-12 13:18:50'),(54,'WTQ34275','store_robbery',0,'item','0',0,0,'2026-08-12 13:35:22'),(55,'WTQ34275','store_robbery',1,'item','0',0,0,'2026-08-12 13:37:17'),(56,'WTQ34275','store_robbery',1,'item','0',0,0,'2026-08-12 13:42:55'),(57,'WTQ34275','store_robbery',0,'item','0',0,0,'2026-08-12 13:43:43'),(58,'WTQ34275','store_robbery',0,'item','0',0,0,'2026-08-12 13:45:14'),(59,'WTQ34275','store_robbery',0,'item','0',0,0,'2026-08-12 13:46:19'),(60,'WTQ34275','store_robbery',1,'item','0',0,0,'2026-08-12 14:03:17'),(61,'WTQ34275','store_robbery',0,'item','0',0,0,'2026-08-12 14:19:40'),(62,'WTQ34275','store_robbery',1,'item','0',0,0,'2026-08-12 14:20:40'),(63,'WTQ34275','store_robbery',1,'item','0',0,0,'2026-08-12 15:15:26'),(64,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 17:36:29'),(65,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 17:36:33'),(66,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 17:36:38'),(67,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 17:36:43'),(68,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 17:36:47'),(69,'EOZ28811','door_lockpick',0,'item','0',0,1,'2026-08-12 17:36:52'),(70,'EOZ28811','door_lockpick',1,'item','0',0,0,'2026-08-12 17:36:56'),(71,'EOZ28811','store_burglary',1,'item','0',0,0,'2026-08-12 17:41:51'),(72,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 19:53:37'),(73,'EOZ28811','door_lockpick',0,'item','0',0,1,'2026-08-12 19:53:48'),(74,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 19:54:09'),(75,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 19:54:26'),(76,'EOZ28811','door_lockpick',0,'item','0',1,0,'2026-08-12 19:54:33'),(77,'EOZ28811','npc_robbery',0,'item','0',0,0,'2026-08-12 21:11:14'),(78,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 22:06:22'),(79,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 22:06:28'),(80,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 22:06:38'),(81,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 22:06:56'),(82,'EOZ28811','door_lockpick',0,'item','0',0,1,'2026-08-12 22:07:01'),(83,'EOZ28811','door_lockpick',0,'item','0',0,1,'2026-08-12 22:07:08'),(84,'EOZ28811','door_lockpick',0,'item','0',0,1,'2026-08-12 22:07:22'),(85,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 22:07:29'),(86,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 22:07:35'),(87,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 22:07:42'),(88,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-12 22:07:52'),(89,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-13 10:37:59'),(90,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-13 10:38:05'),(91,'EOZ28811','door_lockpick',0,'item','0',1,0,'2026-08-13 10:38:16'),(92,'EOZ28811','door_lockpick',0,'item','0',1,0,'2026-08-13 10:38:21'),(93,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-13 10:38:26'),(94,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-13 10:41:50'),(95,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-13 10:43:20'),(96,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-13 10:43:27'),(97,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-13 10:43:33'),(98,'EOZ28811','door_lockpick',0,'item','0',0,0,'2026-08-13 10:43:39'),(99,'EOZ28811','npc_robbery',0,'item','0',0,0,'2026-08-13 16:14:52'),(100,'EOZ28811','store_robbery',1,'cash','30',0,0,'2026-08-16 11:49:42'),(101,'EOZ28811','store_robbery',0,'item','',0,0,'2026-08-17 13:59:11'),(102,'EOZ28811','store_robbery',1,'item','ammo_revolver',0,0,'2026-08-17 14:26:31'),(103,'EOZ28811','store_robbery',1,'cash','44',0,0,'2026-08-17 14:33:44'),(104,'EOZ28811','store_robbery',1,'item','bread',0,0,'2026-08-17 14:58:28'),(105,'EOZ28811','store_robbery',1,'cash','43',0,0,'2026-08-17 15:31:17'),(106,'EOZ28811','store_robbery',1,'cash','35',0,0,'2026-08-17 16:37:17'),(107,'EOZ28811','store_robbery',1,'item','ammo_revolver',0,0,'2026-08-17 16:43:50'),(108,'EOZ28811','store_robbery',1,'item','apple',0,0,'2026-08-17 17:26:15'),(109,'EOZ28811','store_robbery',1,'cash','36',0,0,'2026-08-17 17:39:08'),(110,'EOZ28811','store_robbery',1,'cash','38',0,0,'2026-08-17 20:55:19'),(111,'EOZ28811','store_robbery',1,'cash','29',0,0,'2026-08-17 21:15:31'),(112,'EOZ28811','store_robbery',1,'cash','39',0,0,'2026-08-17 21:25:18'),(113,'EOZ28811','npc_robbery',1,'item','phone',0,0,'2026-08-18 00:23:03'),(114,'EOZ28811','store_robbery',1,'cash','34',0,0,'2026-08-18 00:51:16'),(115,'EOZ28811','store_robbery',1,'cash','39',0,0,'2026-08-18 07:59:56'),(116,'EOZ28811','store_robbery',1,'cash','25',0,0,'2026-08-18 08:29:01'),(117,'EOZ28811','store_robbery',1,'cash','39',0,0,'2026-08-18 08:29:38'),(118,'EOZ28811','store_robbery',1,'cash','23',0,0,'2026-08-18 09:10:23'),(119,'EOZ28811','store_robbery',1,'cash','16',0,0,'2026-08-18 11:07:39'),(120,'EOZ28811','store_robbery',1,'cash','20',0,0,'2026-08-20 06:37:42'),(121,'EOZ28811','store_robbery',1,'item','cannedbeans',0,0,'2026-08-20 14:15:26'),(122,'EOZ28811','grave_robbery',1,'item','pocket_watch_silver',0,0,'2026-08-20 14:29:11'),(123,'EOZ28811','grave_robbery',0,'item','',0,0,'2026-08-20 14:30:50'),(124,'EOZ28811','grave_robbery',0,'item','',0,0,'2026-08-20 14:30:55'),(125,'EOZ28811','grave_robbery',0,'item','',1,0,'2026-08-20 14:31:01'),(126,'EOZ28811','grave_robbery',1,'item','pocket_watch_silver',0,0,'2026-08-20 14:31:11'),(127,'EOZ28811','grave_robbery',1,'item','tooth_gold',0,0,'2026-08-20 14:31:21'),(128,'EOZ28811','npc_robbery',1,'item','phone',0,1,'2026-08-20 14:32:57'),(129,'WTQ34275','npc_robbery',1,'item','rolex',0,0,'2026-08-21 08:33:17'),(130,'EOZ28811','grave_robbery',1,'item','robbery_ledger',0,0,'2026-08-22 08:37:41'),(131,'EOZ28811','grave_robbery',0,'item','',0,0,'2026-08-22 08:37:53'),(132,'EOZ28811','grave_robbery',1,'item','pocket_watch_silver',0,0,'2026-08-22 08:37:58'),(133,'EOZ28811','grave_robbery',1,'item','silver_ring',0,0,'2026-08-22 08:38:05'),(134,'EOZ28811','grave_robbery',1,'item','necklace_pearl_rou',0,0,'2026-08-22 08:38:11'),(135,'EOZ28811','grave_robbery',1,'item','cigar',0,0,'2026-08-22 08:38:20'),(136,'EOZ28811','grave_robbery',1,'item','pocket_watch_silver',0,1,'2026-08-23 08:07:58'),(137,'EOZ28811','grave_robbery',1,'item','tooth_gold',1,1,'2026-08-23 09:12:43'),(138,'EOZ28811','grave_robbery',1,'item','silver_ring',1,0,'2026-08-23 09:16:15'),(139,'EOZ28811','grave_robbery',1,'item','pocket_watch_silver',0,0,'2026-08-23 11:34:20'),(140,'EOZ28811','grave_robbery',1,'item','silver_ring',0,0,'2026-08-23 11:39:51'),(141,'EOZ28811','grave_robbery',1,'item','silver_ring',0,0,'2026-08-23 11:41:17'),(142,'EOZ28811','grave_robbery',1,'item','silver_ring',1,0,'2026-08-23 11:41:46'),(143,'EOZ28811','grave_robbery',1,'item','necklace_pearl_rou',0,0,'2026-08-23 16:03:36'),(144,'EOZ28811','grave_robbery',1,'item','silver_ring',0,1,'2026-08-23 19:03:51'),(145,'EOZ28811','grave_robbery',1,'item','gold_bar',0,0,'2026-08-23 19:04:10'),(146,'EOZ28811','grave_robbery',1,'item','robbery_ledger',0,0,'2026-08-23 19:05:07'),(147,'EOZ28811','grave_robbery',1,'item','tooth_gold',0,1,'2026-08-23 19:05:18'),(148,'EOZ28811','grave_robbery',1,'item','necklace_pearl_rou',1,0,'2026-08-23 19:05:48'),(149,'EOZ28811','grave_robbery',1,'item','silver_ring',0,0,'2026-08-23 19:06:21'),(150,'EOZ28811','grave_robbery',1,'item','silver_ring',1,0,'2026-08-24 07:27:40'),(151,'EOZ28811','grave_robbery',1,'item','gold_bar',0,0,'2026-08-24 07:27:53'),(152,'EOZ28811','grave_robbery',1,'item','tooth_gold',0,0,'2026-08-24 07:28:02'),(153,'EOZ28811','grave_robbery',1,'item','silver_ring',0,0,'2026-08-24 07:31:27'),(154,'EOZ28811','grave_robbery',1,'item','silver_ring',0,0,'2026-08-24 07:31:47'),(155,'EOZ28811','grave_robbery',1,'item','pocket_watch_silver',0,1,'2026-08-24 07:34:45'),(156,'EOZ28811','grave_robbery',1,'item','silver_ring',0,0,'2026-08-24 07:34:51'),(157,'EOZ28811','grave_robbery',1,'item','coin_penny_1787',0,1,'2026-08-24 07:34:58'),(158,'EOZ28811','store_robbery',1,'item','apple',0,0,'2026-08-24 07:36:50'),(159,'EOZ28811','grave_robbery',1,'item','necklace_pearl_rou',0,0,'2026-08-26 21:05:07'),(160,'EOZ28811','grave_robbery',1,'item','tooth_gold',0,0,'2026-08-26 21:05:17'),(161,'EOZ28811','grave_robbery',1,'item','necklace_pearl_rou',0,0,'2026-08-26 21:28:17'),(162,'EOZ28811','grave_robbery',1,'item','silver_ring',0,1,'2026-08-26 21:28:23'),(163,'EOZ28811','grave_robbery',1,'item','silver_ring',0,0,'2026-08-26 21:28:30'),(164,'EOZ28811','store_robbery',1,'item','pocketwatch',0,0,'2026-08-27 07:33:59'),(165,'EOZ28811','npc_robbery',1,'item','phone',0,1,'2026-08-27 08:12:12'),(166,'EOZ28811','npc_robbery',1,'item','rolex',0,0,'2026-08-28 00:24:19'),(167,'EOZ28811','store_robbery',1,'cash','45',0,0,'2026-08-30 09:47:16'),(168,'RJC15944','npc_robbery',1,'item','rolex',0,0,'2026-09-07 11:41:17');
/*!40000 ALTER TABLE `crime_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `favorites_animations`
--

DROP TABLE IF EXISTS `favorites_animations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `favorites_animations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `favorites` longtext NOT NULL DEFAULT '[]',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorites_animations`
--

LOCK TABLES `favorites_animations` WRITE;
/*!40000 ALTER TABLE `favorites_animations` DISABLE KEYS */;
/*!40000 ALTER TABLE `favorites_animations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fdb_barber`
--

DROP TABLE IF EXISTS `fdb_barber`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fdb_barber` (
  `charid` varchar(255) NOT NULL,
  `hairstyle` longtext NOT NULL DEFAULT '',
  `overlays` longtext NOT NULL DEFAULT '',
  `permanentoverlay` longtext NOT NULL DEFAULT '',
  `outfit_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fdb_barber`
--

LOCK TABLES `fdb_barber` WRITE;
/*!40000 ALTER TABLE `fdb_barber` DISABLE KEYS */;
INSERT INTO `fdb_barber` VALUES ('NJY98862','{\"beards_mustache\":{\"texture\":0,\"model\":0},\"beards_chin\":{\"texture\":{\"tint2\":21,\"tint0\":21,\"palette\":1,\"tint1\":21},\"model\":3},\"beard\":{\"texture\":0,\"model\":0},\"beards_chops\":{\"texture\":0,\"model\":0},\"beards_complete\":{\"texture\":0,\"model\":0},\"hair\":{\"texture\":{\"tint2\":70,\"tint0\":23,\"palette\":1,\"tint1\":54},\"model\":7}}','[{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"eyebrows\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"eyeliners\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"lipsticks\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"shadows\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"blush\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0}]','[{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"scars\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"scars2\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"scars3\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"acne\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"beardstabble\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"paintedmasks\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"ageing\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"blush2\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"complex\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"disc\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"foundation\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"freckles\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"grime\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"visibility\":0,\"palette_color_secondary\":0,\"tx_material\":0,\"opacity\":1.0,\"var\":0,\"tx_id\":1768042157,\"palette_color_primary\":0,\"tx_opacity\":1.0,\"tx_color_type\":0,\"name\":\"hairstabble\",\"tx_id_index\":4,\"palette\":1064202495,\"tx_unk\":0,\"tx_normal\":0,\"palette_color_tertiary\":0,\"palette_id\":1},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"moles\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0},{\"palette_color_secondary\":0,\"opacity\":1.0,\"tx_material\":0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_color_type\":0,\"name\":\"spots\",\"palette\":0,\"palette_color_tertiary\":0,\"visibility\":0,\"tx_normal\":0,\"tx_unk\":0,\"tx_opacity\":1.0}]',0),('RJC15944','{\"beards_chops\":{\"texture\":0,\"model\":0},\"beards_mustache\":{\"texture\":0,\"model\":0},\"beard\":{\"texture\":0,\"model\":0},\"beards_complete\":{\"texture\":0,\"model\":0},\"beards_chin\":{\"texture\":0,\"model\":0},\"hair\":{\"texture\":0,\"model\":0}}','[{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"eyebrows\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"eyeliners\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"lipsticks\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"shadows\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"blush\"}]','[{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"scars\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"scars2\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"scars3\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"acne\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"beardstabble\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"paintedmasks\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"ageing\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"blush2\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"complex\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"disc\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"foundation\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"freckles\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"grime\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"hairstabble\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"moles\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"spots\"}]',0);
/*!40000 ALTER TABLE `fdb_barber` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fdb_barber_preset`
--

DROP TABLE IF EXISTS `fdb_barber_preset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fdb_barber_preset` (
  `charid` varchar(255) NOT NULL,
  `outfit_id` int(11) NOT NULL,
  `price` float NOT NULL,
  `name` varchar(255) NOT NULL,
  `hairstyle` longtext NOT NULL DEFAULT '',
  `overlays` longtext NOT NULL DEFAULT '',
  `gender` longtext NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fdb_barber_preset`
--

LOCK TABLES `fdb_barber_preset` WRITE;
/*!40000 ALTER TABLE `fdb_barber_preset` DISABLE KEYS */;
INSERT INTO `fdb_barber_preset` VALUES ('NJY98862',0,0,'Base','{\"beards_chops\":{\"model\":0,\"texture\":0},\"beards_complete\":{\"model\":0,\"texture\":0},\"beards_mustache\":{\"model\":0,\"texture\":0},\"hair\":{\"model\":7,\"texture\":{\"tint0\":23,\"palette\":1,\"tint1\":54,\"tint2\":70}},\"beards_chin\":{\"model\":3,\"texture\":{\"tint0\":21,\"palette\":1,\"tint1\":21,\"tint2\":21}},\"beard\":{\"model\":0,\"texture\":0}}','[{\"opacity\":1.0,\"tx_unk\":0,\"visibility\":0,\"tx_color_type\":0,\"name\":\"eyebrows\",\"tx_normal\":0,\"palette_color_tertiary\":0,\"tx_opacity\":1.0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_material\":0,\"palette\":0,\"palette_color_secondary\":0},{\"opacity\":1.0,\"tx_unk\":0,\"visibility\":0,\"tx_color_type\":0,\"name\":\"eyeliners\",\"tx_normal\":0,\"palette_color_tertiary\":0,\"tx_opacity\":1.0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_material\":0,\"palette\":0,\"palette_color_secondary\":0},{\"opacity\":1.0,\"tx_unk\":0,\"visibility\":0,\"tx_color_type\":0,\"name\":\"lipsticks\",\"tx_normal\":0,\"palette_color_tertiary\":0,\"tx_opacity\":1.0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_material\":0,\"palette\":0,\"palette_color_secondary\":0},{\"opacity\":1.0,\"tx_unk\":0,\"visibility\":0,\"tx_color_type\":0,\"name\":\"shadows\",\"tx_normal\":0,\"palette_color_tertiary\":0,\"tx_opacity\":1.0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_material\":0,\"palette\":0,\"palette_color_secondary\":0},{\"opacity\":1.0,\"tx_unk\":0,\"visibility\":0,\"tx_color_type\":0,\"name\":\"blush\",\"tx_normal\":0,\"palette_color_tertiary\":0,\"tx_opacity\":1.0,\"tx_id\":1,\"palette_color_primary\":0,\"var\":0,\"tx_material\":0,\"palette\":0,\"palette_color_secondary\":0}]','Male'),('RJC15944',0,0,'Base','{\"beards_chops\":{\"texture\":0,\"model\":0},\"beards_mustache\":{\"texture\":0,\"model\":0},\"beard\":{\"texture\":0,\"model\":0},\"beards_complete\":{\"texture\":0,\"model\":0},\"beards_chin\":{\"texture\":0,\"model\":0},\"hair\":{\"texture\":0,\"model\":0}}','[{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"eyebrows\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"eyeliners\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"lipsticks\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"shadows\"},{\"palette_color_secondary\":0,\"var\":0,\"tx_id\":1,\"palette\":0,\"palette_color_primary\":0,\"visibility\":0,\"tx_color_type\":0,\"tx_normal\":0,\"opacity\":1.0,\"tx_opacity\":1.0,\"tx_unk\":0,\"palette_color_tertiary\":0,\"tx_material\":0,\"name\":\"blush\"}]','Male');
/*!40000 ALTER TABLE `fdb_barber_preset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fdb_clothes`
--

DROP TABLE IF EXISTS `fdb_clothes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fdb_clothes` (
  `charid` varchar(200) NOT NULL,
  `clothes` longtext NOT NULL,
  `outfit_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fdb_clothes`
--

LOCK TABLES `fdb_clothes` WRITE;
/*!40000 ALTER TABLE `fdb_clothes` DISABLE KEYS */;
INSERT INTO `fdb_clothes` VALUES ('NJY98862','{\"beards_chin\":{\"model\":0,\"texture\":0},\"-822935952\":{\"model\":0,\"texture\":0},\"-87047232\":{\"model\":0,\"texture\":0},\"pants\":{\"model\":87,\"texture\":{\"tint1\":254,\"tint0\":54,\"tint2\":52,\"palette\":1}},\"lduvmjua_0x2b388a05\":{\"model\":0,\"texture\":0},\"xvnliuia_0x625d7b14\":{\"model\":0,\"texture\":0},\"718708483\":{\"model\":0,\"texture\":0},\"outfits\":{\"model\":0,\"texture\":0},\"teeth\":{\"model\":0,\"texture\":0},\"jmwhzgaa_0x106fe11f\":{\"model\":0,\"texture\":0},\"118125201\":{\"model\":0,\"texture\":0},\"coats_closed\":{\"model\":0,\"texture\":0},\"neckerchiefs\":{\"model\":0,\"texture\":0},\"armor\":{\"model\":0,\"texture\":0},\"vests\":{\"model\":0,\"texture\":0},\"spats\":{\"model\":0,\"texture\":0},\"loadouts\":{\"model\":0,\"texture\":0},\"bloiioka_0x1e9e019b\":{\"model\":0,\"texture\":0},\"beards_chops\":{\"model\":0,\"texture\":0},\"holsters_crossdraw\":{\"model\":0,\"texture\":{\"tint1\":0,\"tint0\":0,\"tint2\":0,\"palette\":1}},\"-363708904\":{\"model\":0,\"texture\":0},\"beards_mustache\":{\"model\":0,\"texture\":0},\"holsters_right\":{\"model\":0,\"texture\":{\"tint1\":0,\"tint0\":0,\"tint2\":0,\"palette\":1}},\"2049190526\":{\"model\":0,\"texture\":0},\"jjpzgvmc_0x22d33ac2\":{\"model\":0,\"texture\":0},\"eyebrows\":{\"model\":0,\"texture\":0},\"masks\":{\"model\":0,\"texture\":0},\"neckwear\":{\"model\":0,\"texture\":0},\"gore_lower\":{\"model\":0,\"texture\":0},\"eyewear\":{\"model\":0,\"texture\":0},\"pants_accessories\":{\"model\":0,\"texture\":0},\"464404356\":{\"model\":0,\"texture\":0},\"coats\":{\"model\":0,\"texture\":0},\"88372018\":{\"model\":0,\"texture\":0},\"heads\":{\"model\":0,\"texture\":0},\"hats\":{\"model\":0,\"texture\":0},\"hair_accessories\":{\"model\":0,\"texture\":0},\"1022160959\":{\"model\":0,\"texture\":0},\"tyyeqpea_0x5ad6c8a1\":{\"model\":0,\"texture\":0},\"lvpmxtsa_0xb57244a4\":{\"model\":0,\"texture\":0},\"hynnzeba_0x534c424e\":{\"model\":0,\"texture\":0},\"kqmlmpca_0x294e561e\":{\"model\":0,\"texture\":0},\"jewelry_necklaces\":{\"model\":0,\"texture\":0},\"jewelry_rings\":{\"model\":0,\"texture\":0},\"ankle_bindings\":{\"model\":0,\"texture\":0},\"nrpnskza_0x3cadebb7\":{\"model\":0,\"texture\":0},\"lputhoya_0x7b78114c\":{\"model\":0,\"texture\":0},\"satchels\":{\"model\":2,\"texture\":{\"tint1\":0,\"tint0\":0,\"tint2\":0,\"palette\":1}},\"unionsuits_full\":{\"model\":0,\"texture\":0},\"holsters_knife\":{\"model\":0,\"texture\":{\"tint1\":10,\"tint0\":10,\"tint2\":10,\"palette\":1}},\"ondqcrka_0xbc4255e3\":{\"model\":0,\"texture\":0},\"jewelry_bracelets\":{\"model\":0,\"texture\":0},\"ammo_pistols\":{\"model\":0,\"texture\":{\"tint1\":0,\"tint0\":0,\"tint2\":0,\"palette\":1}},\"eyecaps\":{\"model\":0,\"texture\":0},\"cgvqvdaa_0xd4968e65\":{\"model\":0,\"texture\":0},\"shirts_full\":{\"model\":3,\"texture\":{\"tint1\":49,\"tint0\":42,\"tint2\":21,\"palette\":1}},\"dresses\":{\"model\":0,\"texture\":0},\"holsters_quivers\":{\"model\":0,\"texture\":{\"tint1\":0,\"tint0\":0,\"tint2\":0,\"palette\":1}},\"accessories\":{\"model\":0,\"texture\":0},\"1080070465\":{\"model\":0,\"texture\":0},\"vfnqsfba_0x95ad5e2a\":{\"model\":0,\"texture\":0},\"609538240\":{\"model\":0,\"texture\":0},\"suspenders\":{\"model\":0,\"texture\":0},\"eyelashes\":{\"model\":0,\"texture\":0},\"ogdexlma_0xe8b5e43d\":{\"model\":0,\"texture\":0},\"face_props\":{\"model\":0,\"texture\":0},\"-1163401704\":{\"model\":0,\"texture\":0},\"neckties\":{\"model\":0,\"texture\":0},\"vest_accessories\":{\"model\":0,\"texture\":0},\"boots\":{\"model\":333,\"texture\":{\"tint1\":0,\"tint0\":0,\"tint2\":0,\"palette\":1}},\"-1373389517\":{\"model\":0,\"texture\":0},\"kpmcfucb_0xeb4b82d1\":{\"model\":0,\"texture\":0},\"rheovufa_0x4a8a0b53\":{\"model\":0,\"texture\":0},\"-1783753551\":{\"model\":0,\"texture\":0},\"belts\":{\"model\":3,\"texture\":{\"tint1\":0,\"tint0\":0,\"tint2\":0,\"palette\":1}},\"najrjqia_0x37b57629\":{\"model\":0,\"texture\":0},\"satchel_straps\":{\"model\":0,\"texture\":0},\"coats_heavy\":{\"model\":0,\"texture\":0},\"kkawrfba_0x202a8054\":{\"model\":0,\"texture\":0},\"777116858\":{\"model\":0,\"texture\":0},\"-1132439862\":{\"model\":0,\"texture\":0},\"boot_accessories\":{\"model\":0,\"texture\":0},\"-801920077\":{\"model\":0,\"texture\":0},\"wemtvpaa_0xa8fcd30e\":{\"model\":0,\"texture\":0},\"-705203924\":{\"model\":0,\"texture\":0},\"overalls_full\":{\"model\":0,\"texture\":0},\"bodies_upper\":{\"model\":0,\"texture\":0},\"badges\":{\"model\":0,\"texture\":{\"tint1\":21,\"tint0\":21,\"tint2\":21,\"palette\":1}},\"jewelry_earrings\":{\"model\":0,\"texture\":0},\"sqwapmca_0x5b0f410e\":{\"model\":0,\"texture\":0},\"gunbelts\":{\"model\":19,\"texture\":{\"tint1\":14,\"tint0\":15,\"tint2\":110,\"palette\":1}},\"brhyqiua_0x1af71626\":{\"model\":0,\"texture\":0},\"wrist_bindings\":{\"model\":0,\"texture\":0},\"coat_accessories\":{\"model\":0,\"texture\":0},\"bctrhzba_0xcb350942\":{\"model\":0,\"texture\":0},\"gore_head\":{\"model\":0,\"texture\":0},\"arbhwiba_0x2f725b6c\":{\"model\":0,\"texture\":0},\"unionsuit_legs\":{\"model\":0,\"texture\":0},\"ponchos\":{\"model\":0,\"texture\":0},\"holsters_center\":{\"model\":0,\"texture\":0},\"gauntlets\":{\"model\":0,\"texture\":0},\"beards_complete\":{\"model\":0,\"texture\":0},\"masks_large\":{\"model\":0,\"texture\":0},\"shirts_full_overpants\":{\"model\":0,\"texture\":0},\"upigupqa_0x5a536e23\":{\"model\":0,\"texture\":0},\"jewelry_rings_left\":{\"model\":0,\"texture\":0},\"headwear\":{\"model\":0,\"texture\":0},\"gore_upper\":{\"model\":0,\"texture\":0},\"dlzdyqba_0xd82c8dd3\":{\"model\":0,\"texture\":0},\"idntoqja_0xe85a1a4d\":{\"model\":0,\"texture\":0},\"hat_accessories\":{\"model\":0,\"texture\":0},\"gunbelt_accs\":{\"model\":0,\"texture\":1},\"jewelry_rings_right\":{\"model\":0,\"texture\":0},\"overalls_modular_lowers\":{\"model\":0,\"texture\":0},\"cloaks\":{\"model\":0,\"texture\":0},\"belt_buckles\":{\"model\":0,\"texture\":0},\"916904447\":{\"model\":0,\"texture\":0},\"-1816970959\":{\"model\":0,\"texture\":0},\"hyohcica_0xa1071d52\":{\"model\":0,\"texture\":0},\"holsters_left\":{\"model\":15,\"texture\":{\"tint1\":0,\"tint0\":0,\"tint2\":0,\"palette\":1}},\"1572501618\":{\"model\":0,\"texture\":0},\"gloves\":{\"model\":0,\"texture\":0},\"aprons\":{\"model\":0,\"texture\":0},\"skirts\":{\"model\":0,\"texture\":{\"tint1\":0,\"tint0\":0,\"tint2\":0,\"palette\":1}},\"eyes\":{\"model\":0,\"texture\":0},\"bodies_lower\":{\"model\":0,\"texture\":0},\"overalls_modular_uppers\":{\"model\":0,\"texture\":0},\"hair\":{\"model\":0,\"texture\":0},\"chaps\":{\"model\":0,\"texture\":0}}',0),('NJY98862','[]',1),('RJC15944','{\"1080070465\":{\"model\":0,\"texture\":0},\"boots\":{\"model\":0,\"texture\":0},\"118125201\":{\"model\":0,\"texture\":0},\"spats\":{\"model\":0,\"texture\":0},\"satchel_straps\":{\"model\":0,\"texture\":0},\"holsters_left\":{\"model\":0,\"texture\":0},\"609538240\":{\"model\":0,\"texture\":0},\"jjpzgvmc_0x22d33ac2\":{\"model\":0,\"texture\":0},\"shirts_full_overpants\":{\"model\":0,\"texture\":0},\"jewelry_bracelets\":{\"model\":0,\"texture\":0},\"loadouts\":{\"model\":0,\"texture\":0},\"boot_accessories\":{\"model\":0,\"texture\":0},\"dresses\":{\"model\":0,\"texture\":0},\"coats\":{\"model\":0,\"texture\":0},\"nrpnskza_0x3cadebb7\":{\"model\":0,\"texture\":0},\"beards_complete\":{\"model\":0,\"texture\":0},\"cloaks\":{\"model\":0,\"texture\":0},\"pants_accessories\":{\"model\":0,\"texture\":0},\"neckwear\":{\"model\":0,\"texture\":0},\"xvnliuia_0x625d7b14\":{\"model\":0,\"texture\":0},\"upigupqa_0x5a536e23\":{\"model\":0,\"texture\":0},\"hair\":{\"model\":0,\"texture\":0},\"88372018\":{\"model\":0,\"texture\":0},\"sqwapmca_0x5b0f410e\":{\"model\":0,\"texture\":0},\"gunbelt_accs\":{\"model\":0,\"texture\":0},\"idntoqja_0xe85a1a4d\":{\"model\":0,\"texture\":0},\"masks\":{\"model\":0,\"texture\":0},\"cgvqvdaa_0xd4968e65\":{\"model\":0,\"texture\":0},\"hat_accessories\":{\"model\":0,\"texture\":0},\"eyelashes\":{\"model\":0,\"texture\":0},\"-1373389517\":{\"model\":0,\"texture\":0},\"holsters_right\":{\"model\":0,\"texture\":0},\"777116858\":{\"model\":0,\"texture\":0},\"lduvmjua_0x2b388a05\":{\"model\":0,\"texture\":0},\"hats\":{\"model\":0,\"texture\":0},\"unionsuits_full\":{\"model\":0,\"texture\":0},\"beards_chops\":{\"model\":0,\"texture\":0},\"gore_upper\":{\"model\":0,\"texture\":0},\"tyyeqpea_0x5ad6c8a1\":{\"model\":8,\"texture\":{\"tint1\":16,\"palette\":1,\"tint0\":16,\"tint2\":16}},\"jewelry_earrings\":{\"model\":0,\"texture\":0},\"masks_large\":{\"model\":0,\"texture\":0},\"rheovufa_0x4a8a0b53\":{\"model\":0,\"texture\":0},\"1572501618\":{\"model\":0,\"texture\":0},\"chaps\":{\"model\":0,\"texture\":0},\"coat_accessories\":{\"model\":0,\"texture\":0},\"coats_heavy\":{\"model\":0,\"texture\":0},\"-1163401704\":{\"model\":0,\"texture\":0},\"bloiioka_0x1e9e019b\":{\"model\":0,\"texture\":0},\"vests\":{\"model\":0,\"texture\":0},\"holsters_center\":{\"model\":0,\"texture\":0},\"bodies_lower\":{\"model\":0,\"texture\":0},\"kkawrfba_0x202a8054\":{\"model\":0,\"texture\":0},\"-801920077\":{\"model\":0,\"texture\":0},\"ponchos\":{\"model\":0,\"texture\":0},\"gauntlets\":{\"model\":0,\"texture\":0},\"lvpmxtsa_0xb57244a4\":{\"model\":0,\"texture\":0},\"arbhwiba_0x2f725b6c\":{\"model\":0,\"texture\":0},\"916904447\":{\"model\":0,\"texture\":0},\"jewelry_rings_left\":{\"model\":0,\"texture\":0},\"-363708904\":{\"model\":0,\"texture\":0},\"kpmcfucb_0xeb4b82d1\":{\"model\":0,\"texture\":0},\"-705203924\":{\"model\":0,\"texture\":0},\"skirts\":{\"model\":0,\"texture\":0},\"vfnqsfba_0x95ad5e2a\":{\"model\":0,\"texture\":0},\"eyes\":{\"model\":0,\"texture\":0},\"hair_accessories\":{\"model\":0,\"texture\":0},\"jewelry_necklaces\":{\"model\":0,\"texture\":0},\"-822935952\":{\"model\":0,\"texture\":0},\"belt_buckles\":{\"model\":0,\"texture\":0},\"bodies_upper\":{\"model\":0,\"texture\":0},\"overalls_full\":{\"model\":0,\"texture\":0},\"wemtvpaa_0xa8fcd30e\":{\"model\":0,\"texture\":0},\"718708483\":{\"model\":11,\"texture\":{\"tint1\":8,\"palette\":1,\"tint0\":11,\"tint2\":9}},\"armor\":{\"model\":0,\"texture\":0},\"neckties\":{\"model\":0,\"texture\":0},\"overalls_modular_uppers\":{\"model\":0,\"texture\":0},\"pants\":{\"model\":0,\"texture\":0},\"najrjqia_0x37b57629\":{\"model\":0,\"texture\":0},\"holsters_knife\":{\"model\":0,\"texture\":0},\"vest_accessories\":{\"model\":0,\"texture\":0},\"outfits\":{\"model\":0,\"texture\":0},\"ogdexlma_0xe8b5e43d\":{\"model\":0,\"texture\":0},\"gore_head\":{\"model\":0,\"texture\":0},\"jewelry_rings\":{\"model\":0,\"texture\":0},\"jewelry_rings_right\":{\"model\":0,\"texture\":0},\"2049190526\":{\"model\":0,\"texture\":0},\"464404356\":{\"model\":0,\"texture\":0},\"eyecaps\":{\"model\":0,\"texture\":0},\"overalls_modular_lowers\":{\"model\":0,\"texture\":0},\"unionsuit_legs\":{\"model\":0,\"texture\":0},\"gloves\":{\"model\":0,\"texture\":0},\"wrist_bindings\":{\"model\":0,\"texture\":0},\"satchels\":{\"model\":0,\"texture\":0},\"neckerchiefs\":{\"model\":0,\"texture\":0},\"eyebrows\":{\"model\":0,\"texture\":0},\"dlzdyqba_0xd82c8dd3\":{\"model\":0,\"texture\":0},\"face_props\":{\"model\":0,\"texture\":0},\"brhyqiua_0x1af71626\":{\"model\":0,\"texture\":0},\"kqmlmpca_0x294e561e\":{\"model\":0,\"texture\":0},\"teeth\":{\"model\":0,\"texture\":0},\"lputhoya_0x7b78114c\":{\"model\":0,\"texture\":0},\"1022160959\":{\"model\":0,\"texture\":0},\"belts\":{\"model\":0,\"texture\":0},\"beards_chin\":{\"model\":0,\"texture\":0},\"ammo_pistols\":{\"model\":0,\"texture\":0},\"holsters_crossdraw\":{\"model\":0,\"texture\":0},\"coats_closed\":{\"model\":0,\"texture\":0},\"suspenders\":{\"model\":0,\"texture\":0},\"bctrhzba_0xcb350942\":{\"model\":0,\"texture\":0},\"gunbelts\":{\"model\":0,\"texture\":0},\"heads\":{\"model\":0,\"texture\":0},\"-1816970959\":{\"model\":0,\"texture\":0},\"-1132439862\":{\"model\":0,\"texture\":0},\"ankle_bindings\":{\"model\":0,\"texture\":0},\"jmwhzgaa_0x106fe11f\":{\"model\":0,\"texture\":0},\"beards_mustache\":{\"model\":0,\"texture\":0},\"shirts_full\":{\"model\":0,\"texture\":0},\"aprons\":{\"model\":0,\"texture\":0},\"eyewear\":{\"model\":0,\"texture\":0},\"accessories\":{\"model\":0,\"texture\":0},\"holsters_quivers\":{\"model\":0,\"texture\":0},\"badges\":{\"model\":0,\"texture\":0},\"hyohcica_0xa1071d52\":{\"model\":0,\"texture\":0},\"gore_lower\":{\"model\":0,\"texture\":0},\"-1783753551\":{\"model\":0,\"texture\":0},\"hynnzeba_0x534c424e\":{\"model\":3,\"texture\":{\"tint1\":0,\"palette\":1,\"tint0\":0,\"tint2\":0}},\"headwear\":{\"model\":0,\"texture\":0},\"ondqcrka_0xbc4255e3\":{\"model\":0,\"texture\":0},\"-87047232\":{\"model\":0,\"texture\":0}}',0);
/*!40000 ALTER TABLE `fdb_clothes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fdb_creator`
--

DROP TABLE IF EXISTS `fdb_creator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fdb_creator` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charid` varchar(200) NOT NULL,
  `peddata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`peddata`)),
  `informations` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`informations`)),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fdb_creator`
--

LOCK TABLES `fdb_creator` WRITE;
/*!40000 ALTER TABLE `fdb_creator` DISABLE KEYS */;
INSERT INTO `fdb_creator` VALUES (11,'NJY98862','{\"eyes\":1,\"height\":1.001,\"waist\":1,\"head\":1,\"expressions\":{\"ForeArms_Size\":1.0,\"Arms_Size\":1.0},\"lowerbody\":1,\"teeth\":1,\"skintone\":1,\"pedmodel\":{\"outfit\":0,\"model\":\"mp_male\"},\"gender\":\"Male\",\"upperbody\":1,\"body\":1}','{\"birthmonth\":\"08\",\"birthyear\":\"1873\",\"lore\":\"\",\"birthday\":\"22\"}'),(12,'RJC15944','{\"head\":1,\"pedmodel\":{\"model\":\"mp_male\",\"outfit\":0},\"body\":1,\"eyes\":1,\"upperbody\":1,\"lowerbody\":1,\"height\":1.0,\"gender\":\"Male\",\"waist\":1,\"teeth\":1,\"skintone\":1,\"expressions\":{\"Neck_Depth\":1.0,\"Neck_Width\":1.0}}','{\"birthday\":\"22\",\"lore\":\"\",\"birthyear\":\"1873\",\"birthmonth\":\"08\"}');
/*!40000 ALTER TABLE `fdb_creator` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fdb_outfits`
--

DROP TABLE IF EXISTS `fdb_outfits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fdb_outfits` (
  `charid` varchar(200) NOT NULL,
  `outfit_id` int(11) NOT NULL,
  `price` float NOT NULL,
  `name` varchar(255) NOT NULL,
  `clothes` longtext NOT NULL DEFAULT '',
  `singleitems` longtext NOT NULL DEFAULT '',
  `gender` varchar(200) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fdb_outfits`
--

LOCK TABLES `fdb_outfits` WRITE;
/*!40000 ALTER TABLE `fdb_outfits` DISABLE KEYS */;
INSERT INTO `fdb_outfits` VALUES ('NJY98862',1,2,'Outfit 1','[]','{}','male');
/*!40000 ALTER TABLE `fdb_outfits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fdb_wearable`
--

DROP TABLE IF EXISTS `fdb_wearable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fdb_wearable` (
  `charid` varchar(200) NOT NULL,
  `outfit_id` int(11) NOT NULL,
  `skin` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fdb_wearable`
--

LOCK TABLES `fdb_wearable` WRITE;
/*!40000 ALTER TABLE `fdb_wearable` DISABLE KEYS */;
/*!40000 ALTER TABLE `fdb_wearable` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `illegal_grave_state`
--

DROP TABLE IF EXISTS `illegal_grave_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `illegal_grave_state` (
  `grave_id` varchar(64) NOT NULL,
  `last_robbed_at` datetime NOT NULL,
  `next_available_at` datetime NOT NULL,
  PRIMARY KEY (`grave_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `illegal_grave_state`
--

LOCK TABLES `illegal_grave_state` WRITE;
/*!40000 ALTER TABLE `illegal_grave_state` DISABLE KEYS */;
INSERT INTO `illegal_grave_state` VALUES ('-1452429411_-2324_8196_1232','2026-08-11 12:04:40','2026-08-11 19:16:40'),('-18225084_-2423_8164_1221','2026-08-22 08:38:20','2026-08-22 13:26:20'),('-18225084_-2462_8170_1217','2026-08-20 14:31:11','2026-08-20 16:55:11'),('-1935971033_-2405_8135_1225','2026-08-22 08:38:05','2026-08-22 11:02:05'),('-1948972927_-2394_8103_1222','2026-08-22 08:37:58','2026-08-22 11:01:58'),('-1948972927_-2470_8186_1214','2026-08-20 14:31:21','2026-08-20 18:31:21'),('-2146427795_-2383_8229_1227','2026-08-11 11:21:51','2026-08-11 15:21:51'),('249142917_-2418_8110_1219','2026-08-22 08:37:41','2026-08-22 13:25:41'),('569469665_-2448_8134_1215','2026-08-22 08:38:11','2026-08-22 14:14:11'),('grave_-1129732883_-2314_8175_1232','2026-08-23 19:04:10','2026-08-23 23:52:10'),('grave_-1452429411_-2324_8196_1232','2026-08-23 19:05:07','2026-08-23 23:53:07'),('grave_-1782099441_-2275_8277_1231','2026-08-23 19:06:21','2026-08-24 00:42:21'),('grave_-18225084_-2361_8363_1223','2026-08-24 07:28:02','2026-08-24 09:52:02'),('grave_-18225084_-2423_8164_1221','2026-08-26 21:05:17','2026-08-27 02:41:17'),('grave_-18225084_-2462_8170_1217','2026-08-26 21:05:07','2026-08-26 23:29:07'),('grave_-1935971033_-2405_8135_1225','2026-08-26 21:28:17','2026-08-27 01:28:17'),('grave_-1935971033_12839_-12445_786','2026-08-24 07:34:45','2026-08-24 13:10:45'),('grave_-1948972927_-2341_8347_1226','2026-08-24 07:27:53','2026-08-24 13:03:53'),('grave_-1948972927_-2425_8243_1221','2026-08-24 07:31:47','2026-08-24 12:19:47'),('grave_-977506060_-2337_8223_1231','2026-08-23 19:05:48','2026-08-23 21:29:48'),('grave_-977506060_-2353_8163_1231','2026-08-23 19:03:51','2026-08-24 00:39:51'),('grave_-977506060_12782_-12402_788','2026-08-24 07:34:58','2026-08-24 11:34:58'),('grave_100385349_-2297_8339_1230','2026-08-24 07:27:40','2026-08-24 10:39:40'),('grave_100385349_-2402_8192_1225','2026-08-26 21:28:30','2026-08-27 01:28:30'),('grave_249142917_-2349_8249_1231','2026-08-23 19:05:18','2026-08-23 21:29:18'),('grave_249142917_-2393_8172_1227','2026-08-26 21:28:23','2026-08-27 02:16:23'),('grave_249142917_-2418_8110_1219','2026-08-24 07:31:27','2026-08-24 09:55:27'),('grave_249142917_12823_-12461_784','2026-08-24 07:34:51','2026-08-24 09:58:51'),('grave_78404028_-3016_7927_1171','2026-08-23 16:03:36','2026-08-23 20:03:36'),('grave_78404028_-3035_7916_1170','2026-08-23 11:39:50','2026-08-23 17:15:50'),('grave_78404028_-3046_7906_1169','2026-08-23 08:07:58','2026-08-23 12:55:58'),('grave_78404028_-3058_7906_1168','2026-08-23 11:41:46','2026-08-23 15:41:46'),('grave_unknown_-3053_7907_1178','2026-08-23 11:41:17','2026-08-23 17:17:17');
/*!40000 ALTER TABLE `illegal_grave_state` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `illegal_heists`
--

DROP TABLE IF EXISTS `illegal_heists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `illegal_heists` (
  `id` varchar(64) NOT NULL,
  `name` varchar(100) NOT NULL,
  `graph` longtext NOT NULL,
  `active` tinyint(1) DEFAULT 1,
  `created_by` varchar(64) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `illegal_heists`
--

LOCK TABLES `illegal_heists` WRITE;
/*!40000 ALTER TABLE `illegal_heists` DISABLE KEYS */;
INSERT INTO `illegal_heists` VALUES ('grave_robbery_heist','Roubo de T├║mulo','{\"nodes\":{\"node_trigger\":{\"data\":{\"distance\":3.5,\"uiPosition\":{\"x\":777.7929119306834,\"y\":93.67521961899638},\"models\":\"p_gravestone01ax, p_gravestone01x, p_gravestone02x\",\"prompt\":\"Saquear T├║mulo\"},\"type\":\"trigger_model\"},\"node_minigame\":{\"data\":{\"animDict\":\"amb_work@world_human_gravedig@working@male_b@base\",\"attachRotX\":274.19,\"attachOffsetX\":0,\"minigameDuration\":5000,\"animName\":\"base\",\"uiPosition\":{\"x\":784.3468258988314,\"y\":324.74460321846507},\"failMessage\":\"Voc├¬ foi interrompido!\",\"attachRotZ\":378.4,\"minigameType\":\"tierbar\",\"attachOffsetZ\":-0.089,\"attachOffsetY\":-0.19,\"propModel\":\"p_shovel02x\",\"attachRotY\":483.89},\"type\":\"minigame_action\"},\"node_check\":{\"data\":{\"uiPosition\":{\"x\":783.0120757757551,\"y\":206.51452382538538},\"amount\":1,\"failMessage\":\"Voc├¬ precisa de uma p├í.\",\"item\":\"shovel\"},\"type\":\"check_requirements\"},\"node_reward\":{\"data\":{\"uiPosition\":{\"x\":786.8041033037825,\"y\":694.2527834229303},\"crimeType\":\"grave_robbery\",\"successMessage\":\"Voc├¬ revirou o t├║mulo e encontrou algo!\",\"cooldownPrefix\":\"grave\"},\"type\":\"crime_reward_and_cooldown\"},\"node_anim\":{\"data\":{\"animDict\":\"amb_misc@world_human_kneel@kneel@female_b@base\",\"durationMs\":3000,\"uiPosition\":{\"x\":787.1057290041779,\"y\":451.18002531732147},\"animName\":\"base\"},\"type\":\"play_animation\"},\"node_spawn\":{\"data\":{\"uiPosition\":{\"x\":793.6534451407846,\"y\":557.9437660968227},\"props\":[{\"offsetZ\":-1,\"offsetForward\":0.6,\"offsetX\":0,\"model\":\"mp005_p_dirtpile_tall_unburied\",\"heading\":0}]},\"type\":\"spawn_prop\"}},\"edges\":[{\"target\":\"node_check\",\"source\":\"node_trigger\"},{\"target\":\"node_minigame\",\"source\":\"node_check\"},{\"target\":\"node_anim\",\"source\":\"node_minigame\"},{\"target\":\"node_spawn\",\"source\":\"node_anim\"},{\"target\":\"node_reward\",\"source\":\"node_spawn\"}]}',1,NULL,'2026-08-27 00:49:27','2026-08-27 09:41:10'),('novo_assalto','Novo Assalto','{\"edges\":[{\"source\":\"node_2\",\"target\":\"node_1\"},{\"source\":\"node_1\",\"target\":\"node_3\"}],\"nodes\":{\"node_1\":{\"data\":{\"props\":[{\"offsetForward\":0,\"offsetZ\":-1,\"coords\":{\"y\":792.15,\"x\":-299.36,\"z\":117.29},\"model\":\"p_crate01x\",\"heading\":0},{\"coords\":{\"y\":788.12,\"x\":-299.21,\"z\":117.23},\"heading\":0,\"model\":\"p_crate01x\"},{\"coords\":{\"y\":790.92,\"x\":-296.36,\"z\":117.06},\"heading\":0,\"model\":\"p_crate01x\"}],\"offsetY\":1,\"offsetX\":0,\"heading\":0,\"uiPosition\":{\"y\":556,\"x\":1569}},\"type\":\"spawn_prop\"},\"node_3\":{\"data\":{\"uiPosition\":{\"y\":719,\"x\":1548},\"peds\":[{\"coords\":{\"y\":789.72,\"x\":-320.55,\"z\":116.06},\"animName\":\"\",\"animDict\":\"\",\"taskType\":\"\",\"pedModel\":\"g_m_m_bountyhunters_01\",\"heading\":0,\"distance\":0},{\"coords\":{\"y\":788.02,\"x\":-325.33,\"z\":115.74},\"pedModel\":\"g_m_m_bountyhunters_01\",\"heading\":0,\"taskType\":\"guard\"},{\"coords\":{\"y\":787.05,\"x\":-322.04,\"z\":115.98},\"pedModel\":\"u_m_m_valbarkeep_01\",\"heading\":0,\"taskType\":\"guard\"}]},\"type\":\"spawn_ped\"},\"node_2\":{\"data\":{\"uiPosition\":{\"y\":419,\"x\":1142}},\"type\":\"start\"}}}',1,NULL,'2026-08-25 11:43:31','2026-08-25 21:32:34'),('novo_assalto1','Novo Assalto','{\"edges\":[{\"source\":\"node_2\",\"target\":\"node_3\"}],\"nodes\":{\"node_2\":{\"type\":\"start\",\"data\":{\"uiPosition\":{\"y\":298.65421575966789,\"x\":574.4050640742142}}},\"node_3\":{\"type\":\"spawn_prop\",\"data\":{\"uiPosition\":{\"y\":379,\"x\":1057},\"props\":[{\"model\":\"p_crate01x\",\"offsetForward\":1,\"offsetZ\":0,\"coords\":{\"x\":-321.79,\"y\":788.59,\"z\":115.97},\"heading\":0},{\"model\":\"p_crate01x\",\"offsetForward\":2,\"offsetZ\":0,\"coords\":{\"x\":-323.08,\"y\":787.69,\"z\":115.89},\"heading\":62},{\"model\":\"p_crate01x\",\"offsetForward\":3,\"offsetZ\":0,\"coords\":{\"x\":-319.94,\"y\":786.96,\"z\":116.03},\"heading\":0}]}}}}',1,NULL,'2026-08-24 15:23:49','2026-08-25 00:40:04'),('test_heist_isolated','Assalto de Teste Isolado','{\r\n        \"nodes\": {\r\n            \"node_start\": { \"type\": \"start\", \"data\": {} },\r\n            \"node_door\": { \r\n                \"type\": \"open_door\", \r\n                \"data\": { \r\n                    \"coords\": {\"x\": -300.0, \"y\": 800.0, \"z\": 118.0}, \r\n                    \"minTime\": 5, \r\n                    \"prompt\": \"Arrombar Porta\" \r\n                } \r\n            },\r\n            \"node_register\": { \r\n                \"type\": \"crack_register\", \r\n                \"data\": { \r\n                    \"coords\": {\"x\": -298.0, \"y\": 800.0, \"z\": 118.0}, \r\n                    \"heading\": 101.4, \r\n                    \"minTime\": 3, \r\n                    \"reward\": \"money\", \r\n                    \"prompt\": \"Roubar Caixa\" \r\n                } \r\n            }\r\n        },\r\n        \"edges\": [\r\n            { \"source\": \"node_start\", \"target\": \"node_door\" },\r\n            { \"source\": \"node_door\", \"target\": \"node_register\" }\r\n        ]\r\n    }',1,NULL,'2026-08-27 00:47:46','2026-08-27 00:47:46');
/*!40000 ALTER TABLE `illegal_heists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `illegal_store_risk_spawns`
--

DROP TABLE IF EXISTS `illegal_store_risk_spawns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `illegal_store_risk_spawns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `store_id` int(11) NOT NULL,
  `type` enum('dog','guard') NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `heading` float DEFAULT NULL,
  `reaction` varchar(50) DEFAULT 'combat',
  PRIMARY KEY (`id`),
  KEY `store_id` (`store_id`),
  CONSTRAINT `illegal_store_risk_spawns_ibfk_1` FOREIGN KEY (`store_id`) REFERENCES `illegal_stores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `illegal_store_risk_spawns`
--

LOCK TABLES `illegal_store_risk_spawns` WRITE;
/*!40000 ALTER TABLE `illegal_store_risk_spawns` DISABLE KEYS */;
INSERT INTO `illegal_store_risk_spawns` VALUES (1,1,'dog',-315,800,118,90,'combat'),(2,1,'guard',-318,802,118,0,'combat'),(3,1,'guard',-316,805,118,45,'combat'),(4,1,'guard',-314,798,118,90,'combat');
/*!40000 ALTER TABLE `illegal_store_risk_spawns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `illegal_stores`
--

DROP TABLE IF EXISTS `illegal_stores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `illegal_stores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `coords_x` float NOT NULL,
  `coords_y` float NOT NULL,
  `coords_z` float NOT NULL,
  `door_x` float DEFAULT NULL,
  `door_y` float DEFAULT NULL,
  `door_z` float DEFAULT NULL,
  `register_x` float DEFAULT NULL,
  `register_y` float DEFAULT NULL,
  `register_z` float DEFAULT NULL,
  `register_heading` float DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `illegal_stores`
--

LOCK TABLES `illegal_stores` WRITE;
/*!40000 ALTER TABLE `illegal_stores` DISABLE KEYS */;
INSERT INTO `illegal_stores` VALUES (1,'Valentine General Store',-322.25,804.05,117.93,-319.7,796.53,116.94,-323.5,804.5,117.93,0,1,'2026-08-21 09:22:54'),(2,'Valentine Gunsmith',-278.43,775.12,119.52,-276.5,774.5,119.52,-280.181,778.873,119.504,301.133,1,'2026-08-21 09:22:54'),(3,'Valentine Doctor',-245.92,781.08,118.47,-247.5,781.5,118.47,-288.21,805.11,119.386,358.567,1,'2026-08-21 09:22:54');
/*!40000 ALTER TABLE `illegal_stores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventories`
--

DROP TABLE IF EXISTS `inventories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`items`)),
  PRIMARY KEY (`identifier`),
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventories`
--

LOCK TABLES `inventories` WRITE;
/*!40000 ALTER TABLE `inventories` DISABLE KEYS */;
INSERT INTO `inventories` VALUES (1,'medic_medic','[]');
/*!40000 ALTER TABLE `inventories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `management_funds`
--

DROP TABLE IF EXISTS `management_funds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `management_funds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_name` varchar(50) NOT NULL,
  `amount` int(100) NOT NULL,
  `type` enum('boss','gang') NOT NULL DEFAULT 'boss',
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_name` (`job_name`),
  KEY `type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `management_funds`
--

LOCK TABLES `management_funds` WRITE;
/*!40000 ALTER TABLE `management_funds` DISABLE KEYS */;
INSERT INTO `management_funds` VALUES (1,'vallaw',0,'boss'),(2,'rholaw',0,'boss'),(3,'blklaw',0,'boss'),(4,'strlaw',0,'boss'),(5,'stdenlaw',0,'boss'),(6,'medic',0,'boss');
/*!40000 ALTER TABLE `management_funds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_audit_logs`
--

DROP TABLE IF EXISTS `mdt_audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdt_audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action` varchar(50) NOT NULL,
  `target_type` varchar(50) DEFAULT NULL,
  `target_id` varchar(100) DEFAULT NULL,
  `target_name` varchar(100) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `performed_by` varchar(50) NOT NULL,
  `performed_by_name` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_action` (`action`),
  KEY `idx_performed_by` (`performed_by`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_audit_logs`
--

LOCK TABLES `mdt_audit_logs` WRITE;
/*!40000 ALTER TABLE `mdt_audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `mdt_audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_bolos`
--

DROP TABLE IF EXISTS `mdt_bolos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdt_bolos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `last_seen` varchar(255) DEFAULT NULL,
  `officer` varchar(100) NOT NULL,
  `officer_cid` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_bolos`
--

LOCK TABLES `mdt_bolos` WRITE;
/*!40000 ALTER TABLE `mdt_bolos` DISABLE KEYS */;
/*!40000 ALTER TABLE `mdt_bolos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_charge_attachments`
--

DROP TABLE IF EXISTS `mdt_charge_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdt_charge_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charge_id` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `attached_by` varchar(50) NOT NULL,
  `attached_by_name` varchar(100) NOT NULL,
  `attached_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_charge_report` (`charge_id`,`report_id`),
  KEY `idx_charge_id` (`charge_id`),
  KEY `idx_report_id` (`report_id`),
  CONSTRAINT `mdt_charge_attachments_ibfk_1` FOREIGN KEY (`charge_id`) REFERENCES `mdt_issued_charges` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mdt_charge_attachments_ibfk_2` FOREIGN KEY (`report_id`) REFERENCES `mdt_reports` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_charge_attachments`
--

LOCK TABLES `mdt_charge_attachments` WRITE;
/*!40000 ALTER TABLE `mdt_charge_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `mdt_charge_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_charge_templates`
--

DROP TABLE IF EXISTS `mdt_charge_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdt_charge_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `fine` int(11) DEFAULT 0,
  `jailtime` int(11) DEFAULT 0,
  `category` varchar(50) DEFAULT 'misdemeanor',
  `created_by` varchar(50) DEFAULT NULL,
  `created_by_name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_charge_templates`
--

LOCK TABLES `mdt_charge_templates` WRITE;
/*!40000 ALTER TABLE `mdt_charge_templates` DISABLE KEYS */;
INSERT INTO `mdt_charge_templates` VALUES (1,'Assault','Physical assault on another person',50,2,'felony',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10'),(2,'Battery','Unlawful physical force against another',75,3,'felony',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10'),(3,'Theft','Stealing property valued under $50',25,0,'misdemeanor',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10'),(4,'Grand Theft','Stealing property valued $50 or more',100,6,'felony',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10'),(5,'Trespassing','Unauthorized entry onto private property',15,0,'misdemeanor',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10'),(6,'Public Intoxication','Being drunk in public',10,0,'infraction',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10'),(7,'Disorderly Conduct','Disturbing the peace',20,0,'misdemeanor',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10'),(8,'Vandalism','Willful destruction of property',30,0,'misdemeanor',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10'),(9,'Fraud','Deception for personal gain',150,12,'felony',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10'),(10,'Murder','Unlawful killing of another person',0,60,'felony',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10'),(11,'Horse Theft','Stealing a horse or other mount',200,24,'felony',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10'),(12,'Bank Robbery','Robbery of a banking institution',500,48,'felony',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10'),(13,'Resisting Arrest','Resisting or fleeing from law enforcement',50,1,'misdemeanor',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10'),(14,'Obstruction of Justice','Interfering with law enforcement duties',40,0,'misdemeanor',NULL,NULL,'2026-08-04 11:38:10','2026-08-04 11:38:10');
/*!40000 ALTER TABLE `mdt_charge_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_citizen_profiles`
--

DROP TABLE IF EXISTS `mdt_citizen_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdt_citizen_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `profile_picture` varchar(512) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenid` (`citizenid`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_citizen_profiles`
--

LOCK TABLES `mdt_citizen_profiles` WRITE;
/*!40000 ALTER TABLE `mdt_citizen_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `mdt_citizen_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_fines`
--

DROP TABLE IF EXISTS `mdt_fines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdt_fines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `citizen_name` varchar(100) NOT NULL,
  `issued_charge_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`issued_charge_ids`)),
  `total_amount` int(11) NOT NULL DEFAULT 0,
  `due_date` timestamp NULL DEFAULT NULL,
  `status` enum('unpaid','paid','overdue') DEFAULT 'unpaid',
  `issued_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `paid_at` timestamp NULL DEFAULT NULL,
  `officer_name` varchar(100) DEFAULT NULL,
  `officer_cid` varchar(50) DEFAULT NULL,
  `paid_to_officer` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_status` (`status`),
  KEY `idx_due_date` (`due_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_fines`
--

LOCK TABLES `mdt_fines` WRITE;
/*!40000 ALTER TABLE `mdt_fines` DISABLE KEYS */;
/*!40000 ALTER TABLE `mdt_fines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_issued_charges`
--

DROP TABLE IF EXISTS `mdt_issued_charges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdt_issued_charges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `citizen_name` varchar(100) NOT NULL,
  `charge_template_id` int(11) DEFAULT NULL,
  `charge_name` varchar(255) NOT NULL,
  `charge_description` text DEFAULT NULL,
  `fine` int(11) DEFAULT 0,
  `jailtime` int(11) DEFAULT 0,
  `time_served` int(11) DEFAULT 0,
  `is_served` tinyint(1) DEFAULT 0,
  `officer` varchar(100) NOT NULL,
  `officer_cid` varchar(50) DEFAULT NULL,
  `report_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `served_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_officer` (`officer`),
  KEY `idx_is_served` (`is_served`),
  KEY `charge_template_id` (`charge_template_id`),
  CONSTRAINT `mdt_issued_charges_ibfk_1` FOREIGN KEY (`charge_template_id`) REFERENCES `mdt_charge_templates` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_issued_charges`
--

LOCK TABLES `mdt_issued_charges` WRITE;
/*!40000 ALTER TABLE `mdt_issued_charges` DISABLE KEYS */;
/*!40000 ALTER TABLE `mdt_issued_charges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_records`
--

DROP TABLE IF EXISTS `mdt_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdt_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `crime` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `fine` int(11) DEFAULT 0,
  `jailtime` int(11) DEFAULT 0,
  `officer` varchar(100) NOT NULL,
  `officer_cid` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_records`
--

LOCK TABLES `mdt_records` WRITE;
/*!40000 ALTER TABLE `mdt_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `mdt_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_report_comments`
--

DROP TABLE IF EXISTS `mdt_report_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdt_report_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_id` int(11) NOT NULL,
  `author` varchar(100) NOT NULL,
  `author_cid` varchar(50) DEFAULT NULL,
  `content` text NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_report_id` (`report_id`),
  CONSTRAINT `mdt_report_comments_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `mdt_reports` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_report_comments`
--

LOCK TABLES `mdt_report_comments` WRITE;
/*!40000 ALTER TABLE `mdt_report_comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `mdt_report_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_reports`
--

DROP TABLE IF EXISTS `mdt_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdt_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `type` varchar(50) DEFAULT 'incident',
  `description` text DEFAULT NULL,
  `officers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`officers`)),
  `suspects` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`suspects`)),
  `evidence` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`evidence`)),
  `officer` varchar(100) NOT NULL,
  `officer_cid` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`),
  KEY `idx_officer` (`officer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_reports`
--

LOCK TABLES `mdt_reports` WRITE;
/*!40000 ALTER TABLE `mdt_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `mdt_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_roles`
--

DROP TABLE IF EXISTS `mdt_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdt_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `label` varchar(100) NOT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissions`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_roles`
--

LOCK TABLES `mdt_roles` WRITE;
/*!40000 ALTER TABLE `mdt_roles` DISABLE KEYS */;
INSERT INTO `mdt_roles` VALUES (1,'admin','Administrator','{\"canCreateRecords\": true, \"canDeleteRecords\": true, \"canManageWarrants\": true, \"isAdmin\": true}','2026-08-04 11:38:10'),(2,'supervisor','Supervisor','{\"canCreateRecords\": true, \"canDeleteRecords\": true, \"canManageWarrants\": true, \"isAdmin\": false}','2026-08-04 11:38:10'),(3,'officer','Officer','{\"canCreateRecords\": true, \"canDeleteRecords\": false, \"canManageWarrants\": false, \"isAdmin\": false}','2026-08-04 11:38:10');
/*!40000 ALTER TABLE `mdt_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_staff`
--

DROP TABLE IF EXISTS `mdt_staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdt_staff` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `role` varchar(50) DEFAULT 'officer',
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissions`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenid` (`citizenid`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_staff`
--

LOCK TABLES `mdt_staff` WRITE;
/*!40000 ALTER TABLE `mdt_staff` DISABLE KEYS */;
/*!40000 ALTER TABLE `mdt_staff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mdt_warrants`
--

DROP TABLE IF EXISTS `mdt_warrants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mdt_warrants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `reason` text NOT NULL,
  `status` enum('active','served','expired') DEFAULT 'active',
  `officer` varchar(100) NOT NULL,
  `officer_cid` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mdt_warrants`
--

LOCK TABLES `mdt_warrants` WRITE;
/*!40000 ALTER TABLE `mdt_warrants` DISABLE KEYS */;
/*!40000 ALTER TABLE `mdt_warrants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medical_history_core`
--

DROP TABLE IF EXISTS `medical_history_core`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `medical_history_core` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `event_type` varchar(50) NOT NULL,
  `body_part` varchar(50) DEFAULT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details`)),
  `performed_by` varchar(50) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medical_history_core`
--

LOCK TABLES `medical_history_core` WRITE;
/*!40000 ALTER TABLE `medical_history_core` DISABLE KEYS */;
/*!40000 ALTER TABLE `medical_history_core` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ox_doorlock`
--

DROP TABLE IF EXISTS `ox_doorlock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ox_doorlock` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `data` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ox_doorlock`
--

LOCK TABLES `ox_doorlock` WRITE;
/*!40000 ALTER TABLE `ox_doorlock` DISABLE KEYS */;
/*!40000 ALTER TABLE `ox_doorlock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_ammo`
--

DROP TABLE IF EXISTS `player_ammo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `player_ammo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) NOT NULL,
  `ammo_revolver` int(3) NOT NULL DEFAULT 0,
  `ammo_revolver_express` int(3) NOT NULL DEFAULT 0,
  `ammo_revolver_express_explosive` int(3) NOT NULL DEFAULT 0,
  `ammo_revolver_high_velocity` int(3) NOT NULL DEFAULT 0,
  `ammo_revolver_split_point` int(3) NOT NULL DEFAULT 0,
  `ammo_pistol` int(3) NOT NULL DEFAULT 0,
  `ammo_pistol_express` int(3) NOT NULL DEFAULT 0,
  `ammo_pistol_express_explosive` int(3) NOT NULL DEFAULT 0,
  `ammo_pistol_high_velocity` int(3) NOT NULL DEFAULT 0,
  `ammo_pistol_split_point` int(3) NOT NULL DEFAULT 0,
  `ammo_repeater` int(3) NOT NULL DEFAULT 0,
  `ammo_repeater_express` int(3) NOT NULL DEFAULT 0,
  `ammo_repeater_express_explosive` int(3) NOT NULL DEFAULT 0,
  `ammo_repeater_high_velocity` int(3) NOT NULL DEFAULT 0,
  `ammo_repeater_split_point` int(3) NOT NULL DEFAULT 0,
  `ammo_rifle` int(3) NOT NULL DEFAULT 0,
  `ammo_rifle_express` int(3) NOT NULL DEFAULT 0,
  `ammo_rifle_express_explosive` int(3) NOT NULL DEFAULT 0,
  `ammo_rifle_high_velocity` int(3) NOT NULL DEFAULT 0,
  `ammo_rifle_split_point` int(3) NOT NULL DEFAULT 0,
  `ammo_shotgun` int(3) NOT NULL DEFAULT 0,
  `ammo_shotgun_buckshot_incendiary` int(3) NOT NULL DEFAULT 0,
  `ammo_shotgun_slug` int(3) NOT NULL DEFAULT 0,
  `ammo_shotgun_slug_explosive` int(3) NOT NULL DEFAULT 0,
  `ammo_rifle_elephant` int(3) NOT NULL DEFAULT 0,
  `ammo_22` int(3) NOT NULL DEFAULT 0,
  `ammo_22_tranquilizer` int(3) NOT NULL DEFAULT 0,
  `ammo_arrow` int(3) NOT NULL DEFAULT 0,
  `ammo_arrow_small_game` int(3) NOT NULL DEFAULT 0,
  `ammo_arrow_fire` int(3) NOT NULL DEFAULT 0,
  `ammo_arrow_poison` int(3) NOT NULL DEFAULT 0,
  `ammo_arrow_dynamite` int(3) NOT NULL DEFAULT 0,
  `ammo_molotov` int(3) NOT NULL DEFAULT 0,
  `ammo_tomahawk` int(3) NOT NULL DEFAULT 0,
  `ammo_tomahawk_ancient` int(3) NOT NULL DEFAULT 0,
  `ammo_dynamite` int(3) NOT NULL DEFAULT 0,
  `ammo_poisonbottle` int(3) NOT NULL DEFAULT 0,
  `ammo_throwing_knives` int(3) NOT NULL DEFAULT 0,
  `ammo_throwing_knives_drain` int(3) NOT NULL DEFAULT 0,
  `ammo_throwing_knives_poison` int(3) NOT NULL DEFAULT 0,
  `ammo_bolas` int(3) NOT NULL DEFAULT 0,
  `ammo_bolas_hawkmoth` int(3) NOT NULL DEFAULT 0,
  `ammo_bolas_intertwined` int(3) NOT NULL DEFAULT 0,
  `ammo_bolas_ironspiked` int(3) NOT NULL DEFAULT 0,
  `ammo_hatchet` int(3) NOT NULL DEFAULT 0,
  `ammo_hatchet_hunter` int(3) NOT NULL DEFAULT 0,
  `ammo_hatchet_cleaver` int(3) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `citizenid` (`citizenid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_ammo`
--

LOCK TABLES `player_ammo` WRITE;
/*!40000 ALTER TABLE `player_ammo` DISABLE KEYS */;
INSERT INTO `player_ammo` VALUES (1,'YLE29252',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),(2,'YOK42874',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),(3,'EKT65559',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),(4,'NJY98862',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),(5,'RJC15944',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
/*!40000 ALTER TABLE `player_ammo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_criminal`
--

DROP TABLE IF EXISTS `player_criminal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `player_criminal` (
  `citizenid` varchar(50) NOT NULL,
  `xp` int(11) NOT NULL DEFAULT 0,
  `heat` int(11) NOT NULL DEFAULT 0,
  `reputation` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_criminal`
--

LOCK TABLES `player_criminal` WRITE;
/*!40000 ALTER TABLE `player_criminal` DISABLE KEYS */;
INSERT INTO `player_criminal` VALUES ('EOZ28811',1775,0,0),('RJC15944',15,0,0),('WCT10843',15,0,0),('WTQ34275',325,58,0);
/*!40000 ALTER TABLE `player_criminal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_horses`
--

DROP TABLE IF EXISTS `player_horses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `player_horses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stable` varchar(50) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `horseid` varchar(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `horse` varchar(50) DEFAULT NULL,
  `dirt` int(11) DEFAULT 0,
  `horsexp` int(11) DEFAULT 0,
  `components` longtext NOT NULL DEFAULT '{}',
  `metadata` longtext NOT NULL DEFAULT '{}',
  `gender` varchar(11) NOT NULL,
  `wild` varchar(11) DEFAULT NULL,
  `active` tinyint(4) DEFAULT 0,
  `born` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_horses`
--

LOCK TABLES `player_horses` WRITE;
/*!40000 ALTER TABLE `player_horses` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_horses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_jobs`
--

DROP TABLE IF EXISTS `player_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `player_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `job` varchar(50) DEFAULT NULL,
  `grade` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_jobs`
--

LOCK TABLES `player_jobs` WRITE;
/*!40000 ALTER TABLE `player_jobs` DISABLE KEYS */;
INSERT INTO `player_jobs` VALUES (1,'EOZ28811','doctor_stdenis',0),(2,'EOZ28811','medic',3),(3,'RJC15944','medic',3);
/*!40000 ALTER TABLE `player_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_weapons`
--

DROP TABLE IF EXISTS `player_weapons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `player_weapons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `serial` varchar(16) NOT NULL,
  `citizenid` varchar(9) NOT NULL,
  `components` varchar(4096) NOT NULL DEFAULT '{}',
  `components_before` varchar(4096) NOT NULL DEFAULT '{}',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_weapons`
--

LOCK TABLES `player_weapons` WRITE;
/*!40000 ALTER TABLE `player_weapons` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_weapons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_weapons_custom`
--

DROP TABLE IF EXISTS `player_weapons_custom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `player_weapons_custom` (
  `gunsiteid` varchar(20) NOT NULL,
  `propid` varchar(20) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `item` varchar(50) NOT NULL,
  `propdata` longtext NOT NULL,
  PRIMARY KEY (`gunsiteid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_weapons_custom`
--

LOCK TABLES `player_weapons_custom` WRITE;
/*!40000 ALTER TABLE `player_weapons_custom` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_weapons_custom` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player_wounds_core`
--

DROP TABLE IF EXISTS `player_wounds_core`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `player_wounds_core` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `body_part` varchar(50) NOT NULL,
  `severity` float NOT NULL DEFAULT 0,
  `bleeding` float NOT NULL DEFAULT 0,
  `pain` float NOT NULL DEFAULT 0,
  `weapon_hash` varchar(50) DEFAULT NULL,
  `weapon_name` varchar(100) DEFAULT NULL,
  `damage_type` varchar(50) DEFAULT NULL,
  `wound_description` text DEFAULT NULL,
  `is_scar` tinyint(1) DEFAULT 0,
  `scar_time` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizen_body_part_scar` (`citizenid`,`body_part`,`is_scar`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player_wounds_core`
--

LOCK TABLES `player_wounds_core` WRITE;
/*!40000 ALTER TABLE `player_wounds_core` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_wounds_core` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `playeroutfit`
--

DROP TABLE IF EXISTS `playeroutfit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `playeroutfit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `clothes` longtext CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `playeroutfit`
--

LOCK TABLES `playeroutfit` WRITE;
/*!40000 ALTER TABLE `playeroutfit` DISABLE KEYS */;
/*!40000 ALTER TABLE `playeroutfit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `players`
--

DROP TABLE IF EXISTS `players`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) NOT NULL,
  `cid` int(11) DEFAULT NULL,
  `license` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `outlawstatus` int(11) NOT NULL DEFAULT 0,
  `money` text NOT NULL,
  `charinfo` text DEFAULT NULL,
  `job` text NOT NULL,
  `gang` text DEFAULT NULL,
  `position` text NOT NULL,
  `metadata` text NOT NULL,
  `inventory` longtext DEFAULT NULL,
  `weight` int(11) NOT NULL DEFAULT 0,
  `slots` int(11) NOT NULL DEFAULT 0,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`citizenid`),
  KEY `id` (`id`),
  KEY `last_updated` (`last_updated`),
  KEY `license` (`license`)
) ENGINE=InnoDB AUTO_INCREMENT=738 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `players`
--

LOCK TABLES `players` WRITE;
/*!40000 ALTER TABLE `players` DISABLE KEYS */;
INSERT INTO `players` VALUES (612,'NJY98862',1,'license:cce9dc36b31e207663245cc74c32ce6261846c99','Farrofa DeBacon',0,'{\"cash\":50,\"bloodmoney\":0,\"gold\":0,\"rhobank\":0,\"armbank\":0,\"valbank\":0,\"bank\":0,\"blkbank\":0}','{\"cid\":1,\"gender\":0,\"account\":\"US02FDBCore7759921874\",\"birthdate\":\"1873-08-22\",\"firstname\":\"Farrofa\",\"lastname\":\"DeBacon\",\"nationality\":\"Saint-denis\"}','{\"type\":\"none\",\"payment\":3,\"label\":\"Civilian\",\"grade\":{\"level\":0,\"name\":\"Freelancer\",\"isboss\":false},\"name\":\"unemployed\",\"onduty\":false,\"isboss\":false}','{\"isboss\":false,\"grade\":{\"level\":0,\"name\":\"Unaffiliated\",\"isboss\":false},\"name\":\"none\",\"label\":\"No Gang\"}','{\"x\":2666.848388671875,\"y\":-1155.99560546875,\"z\":51.15087890625}','{\"jailitems\":[],\"status\":[],\"cleanliness\":100,\"isdead\":false,\"walletid\":\"FDB-91392808\",\"ishandcuffed\":false,\"stress\":0,\"health\":457,\"criminalrecord\":{\"hasRecord\":false},\"rep\":[],\"poison\":0,\"equipmentSlots\":[],\"armor\":0,\"callsign\":\"NO CALLSIGN\",\"injail\":0,\"thirst\":100,\"illness\":0,\"fingerprint\":\"JK938R97RpN1966\",\"bloodtype\":\"O+\",\"hunger\":100,\"bladder\":66}','[{\"amount\":50,\"type\":\"item\",\"slot\":1,\"info\":[],\"name\":\"dollar\"}]',35000,12,'2026-09-06 23:01:11'),(626,'RJC15944',2,'license:cce9dc36b31e207663245cc74c32ce6261846c99','Farrofa DeBacon',0,'{\"bank\":375,\"valbank\":0,\"gold\":0,\"cash\":46.0,\"bloodmoney\":0,\"rhobank\":0,\"armbank\":0,\"blkbank\":0}','{\"lastname\":\"dfSDF\",\"firstname\":\"fARROFA\",\"cid\":2,\"birthdate\":\"1873-08-22\",\"gender\":0,\"nationality\":\"Blackwater\",\"account\":\"US03FDBCore6994557391\"}','{\"label\":\"Medic\",\"name\":\"medic\",\"onduty\":true,\"grade\":{\"isboss\":false,\"name\":\"Surgeon\",\"level\":3,\"payment\":75},\"type\":\"medic\",\"isboss\":false,\"payment\":75}','{\"grade\":{\"isboss\":false,\"name\":\"Unaffiliated\",\"level\":0},\"name\":\"none\",\"label\":\"No Gang\",\"isboss\":false}','{\"x\":-289.1867980957031,\"y\":805.5296630859375,\"z\":119.3758544921875}','{\"jailitems\":[],\"health\":550,\"bloodtype\":\"O-\",\"fingerprint\":\"Bi099s53Ysu3886\",\"equipmentSlots\":[],\"ishandcuffed\":false,\"hunger\":100,\"bladder\":16,\"callsign\":\"NO CALLSIGN\",\"isWet\":false,\"injail\":0,\"isdead\":false,\"stress\":0,\"poison\":0,\"illness\":0,\"armor\":0,\"thirst\":100,\"criminalrecord\":{\"hasRecord\":false},\"status\":[],\"walletid\":\"FDB-26202804\",\"alcohol\":0,\"rep\":[],\"cleanliness\":100}','[{\"name\":\"water\",\"amount\":8,\"info\":[],\"slot\":1,\"type\":\"item\"},{\"name\":\"bread\",\"amount\":16,\"info\":{\"lastUpdate\":1788953069,\"quality\":85.6},\"slot\":2,\"type\":\"item\"},{\"name\":\"dollar\",\"amount\":46,\"info\":[],\"slot\":3,\"type\":\"item\"},{\"name\":\"empty_bottle\",\"amount\":1,\"info\":[],\"slot\":4,\"type\":\"item\"}]',35000,12,'2026-09-09 12:16:01');
/*!40000 ALTER TABLE `players` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `playerskins`
--

DROP TABLE IF EXISTS `playerskins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `playerskins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `skin` varchar(8000) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `clothes` varchar(8000) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `citizenid` (`citizenid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `playerskins`
--

LOCK TABLES `playerskins` WRITE;
/*!40000 ALTER TABLE `playerskins` DISABLE KEYS */;
INSERT INTO `playerskins` VALUES (13,'NJY98862','{\"sex\":0}','[]'),(14,'RJC15944','{\"sex\":0}','[]');
/*!40000 ALTER TABLE `playerskins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `robbed_stores`
--

DROP TABLE IF EXISTS `robbed_stores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `robbed_stores` (
  `store_name` varchar(100) NOT NULL,
  `last_robbed_at` datetime NOT NULL,
  `next_available_at` datetime NOT NULL,
  PRIMARY KEY (`store_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `robbed_stores`
--

LOCK TABLES `robbed_stores` WRITE;
/*!40000 ALTER TABLE `robbed_stores` DISABLE KEYS */;
INSERT INTO `robbed_stores` VALUES ('Valentine General Store','2026-08-17 16:37:17','2026-08-17 19:01:17'),('Valentine Gunsmith','2026-08-17 15:31:17','2026-08-17 16:19:17');
/*!40000 ALTER TABLE `robbed_stores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `executed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `version` (`version`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES (1,'001','001_create_migrations_table_and_core_indexes.sql','2026-08-04 11:38:45'),(2,'002','002_add_player_indices.sql','2026-08-04 11:38:45');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shop_stock`
--

DROP TABLE IF EXISTS `shop_stock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shop_stock` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `shop_name` varchar(50) NOT NULL,
  `item_name` varchar(50) NOT NULL,
  `stock` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `shop_name_item_name` (`shop_name`,`item_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shop_stock`
--

LOCK TABLES `shop_stock` WRITE;
/*!40000 ALTER TABLE `shop_stock` DISABLE KEYS */;
/*!40000 ALTER TABLE `shop_stock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `telegrams`
--

DROP TABLE IF EXISTS `telegrams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `telegrams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) NOT NULL,
  `recipient` varchar(255) NOT NULL,
  `sender` varchar(255) NOT NULL,
  `sendername` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `sentDate` varchar(25) NOT NULL,
  `message` varchar(455) NOT NULL,
  `status` varchar(1) NOT NULL DEFAULT '0',
  `birdstatus` tinyint(2) NOT NULL DEFAULT 0,
  `fromPostOffice` tinyint(1) NOT NULL DEFAULT 0,
  `pickedUp` tinyint(1) NOT NULL DEFAULT 0,
  `mailbox` varchar(20) NOT NULL DEFAULT 'personal',
  `jobTarget` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `telegrams`
--

LOCK TABLES `telegrams` WRITE;
/*!40000 ALTER TABLE `telegrams` DISABLE KEYS */;
/*!40000 ALTER TABLE `telegrams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wasvendel_doorlocks`
--

DROP TABLE IF EXISTS `wasvendel_doorlocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wasvendel_doorlocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `data` longtext NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=129 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wasvendel_doorlocks`
--

LOCK TABLES `wasvendel_doorlocks` WRITE;
/*!40000 ALTER TABLE `wasvendel_doorlocks` DISABLE KEYS */;
INSERT INTO `wasvendel_doorlocks` VALUES (1,'Porta','{\"name\": \"Porta\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -275.34, \"y\": 802.67, \"z\": 119.42}, \"double\": false, \"panels\": [{\"hash\": 1988748538, \"x\": -275.34, \"y\": 802.67, \"z\": 119.42, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(2,'Delegacia de Valentine','{\"name\": \"Delegacia de Valentine\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -275.85, \"y\": 812.02, \"z\": 118.41}, \"double\": false, \"panels\": [{\"hash\": 395506985, \"x\": -275.85, \"y\": 812.02, \"z\": 118.41, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(3,'Delegacia de Valentine','{\"show3d\":false,\"panels\":[{\"model\":0,\"hash\":1508776842,\"x\":-270.77,\"z\":118.39,\"y\":810.02,\"heading\":0.0}],\"promptRadius\":2.5,\"accessItem\":false,\"showPrompt\":true,\"name\":\"Delegacia de Valentine\",\"locked\":true,\"lockedOnStart\":true,\"category\":\"Delegacia\",\"closedRatio\":0.0,\"double\":false,\"jobAccess\":[{\"grade\":0,\"name\":\"sheriff_rhodes\"}],\"charAccess\":[],\"lockpickItem\":\"lockpick\",\"prompt\":{\"x\":-270.77,\"y\":810.02,\"z\":118.39},\"canLockpick\":true}','2026-08-13 00:35:15','2026-08-20 19:10:51'),(4,'Delegacia de Valentine','{\"name\": \"Delegacia de Valentine\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -275.03, \"y\": 809.27, \"z\": 118.36}, \"double\": false, \"panels\": [{\"hash\": 535323366, \"x\": -275.03, \"y\": 809.27, \"z\": 118.36, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(5,'Delegacia de Valentine','{\"name\": \"Delegacia de Valentine\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -273.47, \"y\": 809.96, \"z\": 118.36}, \"double\": false, \"panels\": [{\"hash\": 295355979, \"x\": -273.47, \"y\": 809.96, \"z\": 118.36, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(6,'Delegacia de Valentine','{\"name\": \"Delegacia de Valentine\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -272.06, \"y\": 808.25, \"z\": 118.36}, \"double\": false, \"panels\": [{\"hash\": 193903155, \"x\": -272.06, \"y\": 808.25, \"z\": 118.36, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(7,'Delegacia de Rhodes','{\"name\": \"Delegacia de Rhodes\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1359.71, \"y\": -1305.97, \"z\": 76.76}, \"double\": false, \"panels\": [{\"hash\": 349074475, \"x\": 1359.71, \"y\": -1305.97, \"z\": 76.76, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(8,'Delegacia de Rhodes','{\"name\": \"Delegacia de Rhodes\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1359.12, \"y\": -1297.56, \"z\": 76.78}, \"double\": false, \"panels\": [{\"hash\": 1614494720, \"x\": 1359.12, \"y\": -1297.56, \"z\": 76.78, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(9,'Delegacia de Rhodes','{\"name\": \"Delegacia de Rhodes\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1357.44, \"y\": -1301.78, \"z\": 77.71}, \"double\": false, \"panels\": [{\"hash\": 1878514758, \"x\": 1357.44, \"y\": -1301.78, \"z\": 77.71, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(10,'Delegacia de St Denis','{\"name\": \"Delegacia de St Denis\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"marshall\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2502.42, \"y\": -1307.85, \"z\": 47.95}, \"double\": false, \"panels\": [{\"hash\": 1711767580, \"x\": 2502.42, \"y\": -1307.85, \"z\": 47.95, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(11,'Delegacia de St Denis','{\"name\": \"Delegacia de St Denis\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"marshall\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2499.75, \"y\": -1309.87, \"z\": 47.95}, \"double\": false, \"panels\": [{\"hash\": 1995743734, \"x\": 2499.75, \"y\": -1309.87, \"z\": 47.95, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(12,'Delegacia de St Denis','{\"name\": \"Delegacia de St Denis\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"marshall\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2503.63, \"y\": -1309.87, \"z\": 47.95}, \"double\": false, \"panels\": [{\"hash\": 2515591150, \"x\": 2503.63, \"y\": -1309.87, \"z\": 47.95, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(13,'Delegacia de St Denis','{\"name\": \"Delegacia de St Denis\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"marshall\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2498.5, \"y\": -1307.85, \"z\": 47.95}, \"double\": false, \"panels\": [{\"hash\": 3365520707, \"x\": 2498.5, \"y\": -1307.85, \"z\": 47.95, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(14,'Delegacia de Strawberry','{\"name\": \"Delegacia de Strawberry\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -1814.58, \"y\": -353.71, \"z\": 161.43}, \"double\": false, \"panels\": [{\"hash\": 902070893, \"x\": -1814.58, \"y\": -353.71, \"z\": 161.43, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(15,'Delegacia de Strawberry','{\"name\": \"Delegacia de Strawberry\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -1811.4, \"y\": -352.19, \"z\": 161.39}, \"double\": false, \"panels\": [{\"hash\": 1207903970, \"x\": -1811.4, \"y\": -352.19, \"z\": 161.39, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(16,'Delegacia de Strawberry','{\"name\": \"Delegacia de Strawberry\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -1806.6751708984, \"y\": -350.31280517578, \"z\": 163.6475982666}, \"double\": false, \"panels\": [{\"hash\": 1821044729, \"x\": -1806.6751708984, \"y\": -350.31280517578, \"z\": 163.6475982666, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(17,'Delegacia de Strawberry','{\"name\": \"Delegacia de Strawberry\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -1812.6691894531, \"y\": -345.08489990234, \"z\": 163.6475982666}, \"double\": false, \"panels\": [{\"hash\": 1514359658, \"x\": -1812.6691894531, \"y\": -345.08489990234, \"z\": 163.6475982666, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(18,'Delegacia de Blackwater','{\"name\": \"Delegacia de Blackwater\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -756.92, \"y\": -1269.25, \"z\": 44.03}, \"double\": true, \"panels\": [{\"hash\": 3410720590, \"x\": -756.92, \"y\": -1269.25, \"z\": 44.03, \"heading\": 0.0}, {\"hash\": 3821185084, \"x\": -756.92, \"y\": -1269.25, \"z\": 44.03, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(19,'Delegacia de Blackwater','{\"name\": \"Delegacia de Blackwater\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -768.86, \"y\": -1269.28, \"z\": 44.04}, \"double\": false, \"panels\": [{\"hash\": 2810801921, \"x\": -768.86, \"y\": -1269.28, \"z\": 44.04, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(20,'Delegacia de Blackwater','{\"name\": \"Delegacia de Blackwater\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -763.53, \"y\": -1262.97, \"z\": 44.06}, \"double\": false, \"panels\": [{\"hash\": 2167775834, \"x\": -763.53, \"y\": -1262.97, \"z\": 44.06, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(21,'Delegacia de Blackwater','{\"name\": \"Delegacia de Blackwater\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"sheriff_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -765.56, \"y\": -1264.12, \"z\": 44.02}, \"double\": false, \"panels\": [{\"hash\": 2514996158, \"x\": -765.56, \"y\": -1264.12, \"z\": 44.02, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(22,'Delegacia de Armadillo','{\"name\": \"Delegacia de Armadillo\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -3620.73, \"y\": -2600.75, \"z\": -13.34}, \"double\": false, \"panels\": [{\"hash\": 4016307508, \"x\": -3620.73, \"y\": -2600.75, \"z\": -13.34, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(23,'Delegacia de Armadillo','{\"name\": \"Delegacia de Armadillo\", \"category\": \"Delegacia\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -3619.08, \"y\": -2604.84, \"z\": -13.34}, \"double\": false, \"panels\": [{\"hash\": 4235597664, \"x\": -3619.08, \"y\": -2604.84, \"z\": -13.34, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(24,'Banco de Rhodes','{\"name\":\"Banco de Rhodes\",\"prompt\":{\"x\":1295.75,\"y\":-1297.93,\"z\":77.04},\"accessItem\":\"lockpick\",\"show3d\":true,\"double\":true,\"panels\":[{\"model\":0,\"heading\":0,\"y\":-1297.93,\"x\":1295.75,\"hash\":3088209306,\"z\":77.04},{\"model\":0,\"heading\":0,\"y\":-1297.93,\"x\":1295.75,\"hash\":3317756151,\"z\":77.04}],\"category\":\"Banco\",\"showPrompt\":true,\"lockedOnStart\":false,\"promptRadius\":2.5,\"lockpickItem\":\"lockpick\",\"jobAccess\":[],\"closedRatio\":0,\"charAccess\":[],\"canLockpick\":true,\"locked\":false}','2026-08-13 00:35:15','2026-08-13 01:05:09'),(25,'Banco de Rhodes','{\"name\":\"Banco de Rhodes\",\"prompt\":{\"x\":1285.63,\"y\":-1303.4,\"z\":77.04},\"accessItem\":\"lockpick\",\"show3d\":true,\"double\":false,\"panels\":[{\"model\":0,\"heading\":0,\"y\":-1303.4,\"x\":1285.63,\"hash\":2058564250,\"z\":77.04}],\"category\":\"Banco\",\"showPrompt\":true,\"lockedOnStart\":false,\"promptRadius\":2.5,\"lockpickItem\":\"lockpick\",\"jobAccess\":[],\"closedRatio\":0,\"charAccess\":[],\"canLockpick\":true,\"locked\":false}','2026-08-13 00:35:15','2026-08-13 01:05:21'),(26,'Banco de Rhodes','{\"name\":\"Banco de Rhodes\",\"prompt\":{\"x\":1295.49,\"y\":-1305.03,\"z\":77.04},\"accessItem\":\"lockpick\",\"show3d\":true,\"double\":false,\"panels\":[{\"model\":0,\"heading\":0,\"y\":-1305.03,\"x\":1295.49,\"hash\":1634148892,\"z\":77.04}],\"category\":\"Banco\",\"showPrompt\":true,\"lockedOnStart\":false,\"promptRadius\":2.5,\"lockpickItem\":\"lockpick\",\"jobAccess\":[],\"closedRatio\":0,\"charAccess\":[],\"canLockpick\":true,\"locked\":false}','2026-08-13 00:35:15','2026-08-13 01:05:26'),(27,'Banco de Rhodes','{\"name\":\"Banco de Rhodes\",\"prompt\":{\"x\":1279.34,\"y\":-1310.57,\"z\":77.04},\"accessItem\":\"lockpick\",\"show3d\":true,\"double\":false,\"panels\":[{\"model\":0,\"heading\":0,\"y\":-1310.57,\"x\":1279.34,\"hash\":3142122679,\"z\":77.04}],\"category\":\"Banco\",\"showPrompt\":true,\"lockedOnStart\":false,\"promptRadius\":2.5,\"lockpickItem\":\"lockpick\",\"jobAccess\":[],\"closedRatio\":0,\"charAccess\":[],\"canLockpick\":true,\"locked\":false}','2026-08-13 00:35:15','2026-08-13 01:05:33'),(28,'Banco de Rhodes','{\"name\":\"Banco de Rhodes\",\"prompt\":{\"x\":1278.46,\"y\":-1311.7,\"z\":76.89},\"accessItem\":\"lockpick\",\"show3d\":true,\"double\":false,\"panels\":[{\"model\":0,\"heading\":0,\"y\":-1311.7,\"x\":1278.46,\"hash\":2513778780,\"z\":76.89}],\"category\":\"Banco\",\"showPrompt\":true,\"lockedOnStart\":false,\"promptRadius\":2.5,\"lockpickItem\":\"lockpick\",\"jobAccess\":[],\"closedRatio\":0,\"charAccess\":[],\"canLockpick\":true,\"locked\":false}','2026-08-13 00:35:15','2026-08-13 01:05:37'),(29,'Banco de Rhodes','{\"name\":\"Banco de Rhodes\",\"prompt\":{\"x\":1283.08,\"y\":-1308.89,\"z\":77.04},\"accessItem\":\"lockpick\",\"show3d\":true,\"double\":false,\"panels\":[{\"model\":0,\"heading\":0,\"y\":-1308.89,\"x\":1283.08,\"hash\":3483244267,\"z\":77.04}],\"category\":\"Banco\",\"showPrompt\":true,\"lockedOnStart\":false,\"promptRadius\":2.5,\"lockpickItem\":\"lockpick\",\"jobAccess\":[],\"closedRatio\":0,\"charAccess\":[],\"canLockpick\":true,\"locked\":false}','2026-08-13 00:35:15','2026-08-13 01:04:53'),(30,'Banco de St Denis','{\"name\":\"Banco de St Denis\",\"prompt\":{\"x\":2647.94,\"y\":-1300.3,\"z\":52.25},\"accessItem\":\"lockpick\",\"show3d\":false,\"double\":true,\"panels\":[{\"model\":0,\"heading\":0,\"y\":-1300.3,\"x\":2647.94,\"hash\":1634115439,\"z\":52.25},{\"model\":0,\"heading\":0,\"y\":-1300.3,\"x\":2647.94,\"hash\":965922748,\"z\":52.25}],\"category\":\"Banco\",\"showPrompt\":true,\"lockedOnStart\":false,\"promptRadius\":2.5,\"lockpickItem\":\"lockpick\",\"jobAccess\":[],\"closedRatio\":0,\"charAccess\":[],\"canLockpick\":true,\"locked\":false}','2026-08-13 00:35:15','2026-08-13 01:05:44'),(31,'Banco de St Denis','{\"name\": \"Banco de St Denis\", \"category\": \"Banco\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2643.84, \"y\": -1300.6, \"z\": 52.25}, \"double\": false, \"panels\": [{\"hash\": 1751238140, \"x\": 2643.84, \"y\": -1300.6, \"z\": 52.25, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(32,'Banco de Blackwater','{\"name\": \"Banco de Blackwater\", \"category\": \"Banco\", \"locked\": false, \"lockedOnStart\": false, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -817.09, \"y\": -1278.29, \"z\": 43.64}, \"double\": false, \"panels\": [{\"hash\": 2817192481, \"x\": -817.09, \"y\": -1278.29, \"z\": 43.64, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(33,'Banco de Blackwater','{\"name\": \"Banco de Blackwater\", \"category\": \"Banco\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -816.18, \"y\": -1276.68, \"z\": 43.64}, \"double\": false, \"panels\": [{\"hash\": 2117902999, \"x\": -816.18, \"y\": -1276.68, \"z\": 43.64, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(34,'Banco de Blackwater','{\"name\": \"Banco de Blackwater\", \"category\": \"Banco\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -817.47, \"y\": -1273.84, \"z\": 43.65}, \"double\": false, \"panels\": [{\"hash\": 1462330364, \"x\": -817.47, \"y\": -1273.84, \"z\": 43.65, \"heading\": 0.0}]}','2026-08-13 00:35:15','2026-08-13 00:35:15'),(35,'Banco de Valentine','{\"double\":true,\"promptRadius\":2.5,\"locked\":false,\"lockpickItem\":\"lockpick\",\"jobAccess\":[],\"showPrompt\":true,\"panels\":[{\"heading\":0.0,\"z\":118.7,\"hash\":3886827663,\"model\":0,\"x\":-308.11,\"y\":779.62},{\"heading\":0.0,\"z\":118.7,\"hash\":2642457609,\"model\":0,\"x\":-308.11,\"y\":779.62}],\"accessItem\":false,\"name\":\"Banco de Valentine\",\"show3d\":false,\"lockedOnStart\":false,\"canLockpick\":true,\"charAccess\":[],\"prompt\":{\"z\":118.7,\"y\":779.62,\"x\":-308.11},\"category\":\"Banco\",\"closedRatio\":0.0}','2026-08-13 00:35:15','2026-08-27 11:15:49'),(36,'Banco de Valentine','{\"double\":false,\"promptRadius\":2.5,\"locked\":true,\"lockpickItem\":\"lockpick\",\"jobAccess\":[],\"showPrompt\":true,\"panels\":[{\"heading\":0,\"z\":117.72,\"hash\":2343746133,\"model\":0,\"x\":-301.94,\"y\":771.75}],\"accessItem\":false,\"name\":\"Banco de Valentine\",\"show3d\":true,\"lockedOnStart\":true,\"canLockpick\":true,\"charAccess\":[],\"prompt\":{\"z\":117.72,\"y\":771.75,\"x\":-301.94},\"category\":\"Banco\",\"closedRatio\":0}','2026-08-13 00:35:15','2026-08-27 11:13:44'),(37,'Banco de Valentine','{\"panels\":[{\"z\":117.72,\"y\":774.67,\"model\":0,\"hash\":1340831050,\"x\":-311.75,\"heading\":0.0}],\"showPrompt\":true,\"name\":\"Banco de Valentine\",\"promptRadius\":2.5,\"lockpickItem\":\"lockpick\",\"double\":false,\"charAccess\":[],\"jobAccess\":[],\"prompt\":{\"z\":117.72,\"y\":774.67,\"x\":-311.75},\"show3d\":false,\"category\":\"Banco\",\"closedRatio\":0.0,\"locked\":true,\"lockedOnStart\":true,\"accessItem\":false,\"canLockpick\":true}','2026-08-13 00:35:15','2026-08-18 11:27:50'),(38,'Banco de Valentine','{\"panels\":[{\"z\":117.7,\"y\":770.12,\"model\":0,\"hash\":3718620420,\"x\":-311.06,\"heading\":0.0}],\"showPrompt\":true,\"name\":\"Banco de Valentine\",\"promptRadius\":2.5,\"lockpickItem\":\"lockpick\",\"double\":false,\"charAccess\":[],\"jobAccess\":[],\"prompt\":{\"z\":117.7,\"y\":770.12,\"x\":-311.06},\"show3d\":false,\"category\":\"Banco\",\"closedRatio\":0.0,\"locked\":true,\"lockedOnStart\":true,\"accessItem\":false,\"canLockpick\":true}','2026-08-13 00:35:16','2026-08-18 11:27:50'),(39,'Banco de Valentine','{\"panels\":[{\"z\":117.69,\"y\":767.6,\"model\":0,\"hash\":334467483,\"x\":-302.93,\"heading\":0.0}],\"showPrompt\":true,\"name\":\"Banco de Valentine\",\"promptRadius\":2.5,\"lockpickItem\":\"lockpick\",\"double\":false,\"charAccess\":[],\"jobAccess\":[],\"prompt\":{\"z\":117.69,\"y\":767.6,\"x\":-302.93},\"show3d\":false,\"category\":\"Banco\",\"closedRatio\":0.0,\"locked\":true,\"lockedOnStart\":true,\"accessItem\":false,\"canLockpick\":true}','2026-08-13 00:35:16','2026-08-18 11:27:50'),(40,'Banco de Valentine','{\"panels\":[{\"z\":117.7,\"y\":766.34,\"model\":0,\"hash\":576950805,\"x\":-307.76,\"heading\":0.0}],\"showPrompt\":true,\"name\":\"Banco de Valentine\",\"promptRadius\":2.5,\"lockpickItem\":\"lockpick\",\"double\":false,\"charAccess\":[],\"jobAccess\":[],\"prompt\":{\"z\":117.7,\"y\":766.34,\"x\":-307.76},\"show3d\":false,\"category\":\"Banco\",\"closedRatio\":0.0,\"locked\":true,\"lockedOnStart\":true,\"accessItem\":false,\"canLockpick\":true}','2026-08-13 00:35:16','2026-08-18 11:27:50'),(41,'Banco de Valentine','{\"panels\":[{\"z\":117.73,\"y\":762.98,\"model\":0,\"hash\":2307914732,\"x\":-301.51,\"heading\":0.0}],\"showPrompt\":true,\"name\":\"Banco de Valentine\",\"promptRadius\":2.5,\"lockpickItem\":\"lockpick\",\"double\":false,\"charAccess\":[],\"jobAccess\":[],\"prompt\":{\"z\":117.73,\"y\":762.98,\"x\":-301.51},\"show3d\":false,\"category\":\"Banco\",\"closedRatio\":0.0,\"locked\":true,\"lockedOnStart\":true,\"accessItem\":false,\"canLockpick\":true}','2026-08-13 00:35:16','2026-08-18 11:27:50'),(42,'Banco de Armadillo','{\"name\": \"Banco de Armadillo\", \"category\": \"Banco\", \"locked\": false, \"lockedOnStart\": false, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -3665.44, \"y\": -2620.98, \"z\": -13.57}, \"double\": false, \"panels\": [{\"hash\": 3101287960, \"x\": -3665.44, \"y\": -2620.98, \"z\": -13.57, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(43,'Banco de Armadillo','{\"name\": \"Banco de Armadillo\", \"category\": \"Banco\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -3661.68, \"y\": -2627.45, \"z\": -13.59}, \"double\": false, \"panels\": [{\"hash\": 3550475905, \"x\": -3661.68, \"y\": -2627.45, \"z\": -13.59, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(44,'Banco de Armadillo','{\"name\": \"Banco de Armadillo\", \"category\": \"Banco\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -3662.61, \"y\": -2638.93, \"z\": -13.58}, \"double\": false, \"panels\": [{\"hash\": 1366165179, \"x\": -3662.61, \"y\": -2638.93, \"z\": -13.58, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(45,'M├â┬⌐dico Valentine','{\"name\": \"M├â┬⌐dico Valentine\", \"category\": \"M├â┬⌐dico\", \"locked\": false, \"lockedOnStart\": false, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -282.81, \"y\": 803.85, \"z\": 118.39}, \"double\": false, \"panels\": [{\"hash\": 3588026089, \"x\": -282.81, \"y\": 803.85, \"z\": 118.39, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(46,'M├â┬⌐dico Valentine','{\"show3d\":false,\"name\":\"M├â┬⌐dico Valentine\",\"promptRadius\":2.5,\"panels\":[{\"hash\":4067537969,\"heading\":0.0,\"model\":0,\"x\":-286.65,\"y\":809.76,\"z\":118.39}],\"double\":false,\"closedRatio\":0.0,\"prompt\":{\"x\":-286.65,\"y\":809.76,\"z\":118.39},\"jobAccess\":[],\"charAccess\":[],\"category\":\"M├â┬⌐dico\",\"showPrompt\":true,\"accessItem\":false,\"locked\":false,\"lockedOnStart\":true,\"lockpickItem\":\"lockpick\",\"canLockpick\":true}','2026-08-13 00:35:16','2026-09-09 11:21:56'),(47,'M├â┬⌐dico Valentine','{\"canLockpick\":true,\"charAccess\":[],\"locked\":true,\"lockedOnStart\":true,\"name\":\"M├â┬⌐dico Valentine\",\"promptRadius\":2.5,\"panels\":[{\"x\":-281.18,\"z\":118.39,\"model\":0,\"y\":815.41,\"heading\":0.0,\"hash\":3439738919}],\"jobAccess\":[],\"prompt\":{\"x\":-281.18,\"z\":118.39,\"y\":815.41},\"showPrompt\":true,\"lockpickItem\":\"lockpick\",\"category\":\"M├â┬⌐dico\",\"accessItem\":false,\"show3d\":false,\"closedRatio\":0.0,\"double\":false}','2026-08-13 00:35:16','2026-09-07 21:06:26'),(48,'M├â┬⌐dico Valentine','{\"canLockpick\":true,\"charAccess\":[],\"locked\":true,\"lockedOnStart\":true,\"name\":\"M├â┬⌐dico Valentine\",\"promptRadius\":2.5,\"panels\":[{\"x\":-290.72,\"z\":118.41,\"model\":0,\"y\":813.29,\"heading\":0.0,\"hash\":925575409}],\"jobAccess\":[],\"prompt\":{\"x\":-290.72,\"z\":118.41,\"y\":813.29},\"showPrompt\":true,\"lockpickItem\":\"lockpick\",\"category\":\"M├â┬⌐dico\",\"accessItem\":false,\"show3d\":false,\"closedRatio\":0.0,\"double\":false}','2026-08-13 00:35:16','2026-09-07 21:06:26'),(49,'M├â┬⌐dico Strawberry','{\"name\": \"M├â┬⌐dico Strawberry\", \"category\": \"M├â┬⌐dico\", \"locked\": false, \"lockedOnStart\": false, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -1802.68, \"y\": -429.22, \"z\": 158.83}, \"double\": false, \"panels\": [{\"hash\": 2543619259, \"x\": -1802.68, \"y\": -429.22, \"z\": 158.83, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(50,'M├â┬⌐dico St Denis','{\"name\": \"M├â┬⌐dico St Denis\", \"category\": \"M├â┬⌐dico\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"doctor_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2723.96, \"y\": -1227.64, \"z\": 50.37}, \"double\": false, \"panels\": [{\"hash\": 586229709, \"x\": 2723.96, \"y\": -1227.64, \"z\": 50.37, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(51,'M├â┬⌐dico St Denis','{\"name\": \"M├â┬⌐dico St Denis\", \"category\": \"M├â┬⌐dico\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"doctor_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2727.65, \"y\": -1229.83, \"z\": 50.36}, \"double\": false, \"panels\": [{\"hash\": 1289094734, \"x\": 2727.65, \"y\": -1229.83, \"z\": 50.36, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(52,'M├â┬⌐dico St Denis','{\"name\": \"M├â┬⌐dico St Denis\", \"category\": \"M├â┬⌐dico\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"doctor_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2726.5541992188, \"y\": -1234.8221435547, \"z\": 49.363960266113}, \"double\": true, \"panels\": [{\"hash\": 82263429, \"x\": 2726.5541992188, \"y\": -1234.8221435547, \"z\": 49.363960266113, \"heading\": 0.0}, {\"hash\": 994323006, \"x\": 2726.5541992188, \"y\": -1234.8221435547, \"z\": 49.363960266113, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(53,'M├â┬⌐dico St Denis','{\"name\": \"M├â┬⌐dico St Denis\", \"category\": \"M├â┬⌐dico\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"doctor_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2725.785, \"y\": -1221.405, \"z\": 50.34967}, \"double\": false, \"panels\": [{\"hash\": 1104407261, \"x\": 2725.785, \"y\": -1221.405, \"z\": 50.34967, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(54,'Saloon Blackwater','{\"name\": \"Saloon Blackwater\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -810.5, \"y\": -1319.62, \"z\": 43.67}, \"double\": true, \"panels\": [{\"hash\": 3311897912, \"x\": -810.5, \"y\": -1319.62, \"z\": 43.67, \"heading\": 0.0}, {\"hash\": 3526207172, \"x\": -810.5, \"y\": -1319.62, \"z\": 43.67, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(55,'Saloon Blackwater','{\"name\": \"Saloon Blackwater\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -810.63, \"y\": -1312.85, \"z\": 43.68}, \"double\": false, \"panels\": [{\"hash\": 2452247196, \"x\": -810.63, \"y\": -1312.85, \"z\": 43.68, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(56,'Saloon Blackwater','{\"name\": \"Saloon Blackwater\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -810.47, \"y\": -1327.6, \"z\": 43.67}, \"double\": false, \"panels\": [{\"hash\": 2320881007, \"x\": -810.47, \"y\": -1327.6, \"z\": 43.67, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(57,'Saloon Blackwater','{\"name\": \"Saloon Blackwater\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -824.05, \"y\": -1322.25, \"z\": 43.68}, \"double\": false, \"panels\": [{\"hash\": 815031507, \"x\": -824.05, \"y\": -1322.25, \"z\": 43.68, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(58,'Saloon Blackwater','{\"name\": \"Saloon Blackwater\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -822.9203, \"y\": -1316.562, \"z\": 43.69122}, \"double\": false, \"panels\": [{\"hash\": 1523300673, \"x\": -822.9203, \"y\": -1316.562, \"z\": 43.69122, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(59,'Saloon Blackwater','{\"name\": \"Saloon Blackwater\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -818.2964, \"y\": -1324.128, \"z\": 47.87748}, \"double\": false, \"panels\": [{\"hash\": 254520182, \"x\": -818.2964, \"y\": -1324.128, \"z\": 47.87748, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(60,'Saloon St Denis','{\"name\": \"Saloon St Denis\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2628.55, \"y\": -1221.17, \"z\": 53.4}, \"double\": true, \"panels\": [{\"hash\": 3895438792, \"x\": 2628.55, \"y\": -1221.17, \"z\": 53.4, \"heading\": 0.0}, {\"hash\": 804086151, \"x\": 2628.55, \"y\": -1221.17, \"z\": 53.4, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(61,'Saloon St Denis','{\"name\": \"Saloon St Denis\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2639.64, \"y\": -1219.97, \"z\": 59.61}, \"double\": true, \"panels\": [{\"hash\": 2999855503, \"x\": 2639.64, \"y\": -1219.97, \"z\": 59.61, \"heading\": 0.0}, {\"hash\": 2693793043, \"x\": 2639.64, \"y\": -1219.97, \"z\": 59.61, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(62,'Saloon St Denis','{\"name\": \"Saloon St Denis\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2636.45, \"y\": -1219.69, \"z\": 59.61}, \"double\": true, \"panels\": [{\"hash\": 3461406868, \"x\": 2636.45, \"y\": -1219.69, \"z\": 59.61, \"heading\": 0.0}, {\"hash\": 1275780106, \"x\": 2636.45, \"y\": -1219.69, \"z\": 59.61, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(63,'Saloon St Denis','{\"name\": \"Saloon St Denis\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2633.21, \"y\": -1219.85, \"z\": 59.61}, \"double\": true, \"panels\": [{\"hash\": 3856177940, \"x\": 2633.21, \"y\": -1219.85, \"z\": 59.61, \"heading\": 0.0}, {\"hash\": 3371065664, \"x\": 2633.21, \"y\": -1219.85, \"z\": 59.61, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(64,'Saloon Saloon Faubourg','{\"name\": \"Saloon Saloon Faubourg\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_faubourg\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2793.796, \"y\": -1174.267, \"z\": 47.93112}, \"double\": true, \"panels\": [{\"hash\": 2653589767, \"x\": 2793.796, \"y\": -1174.267, \"z\": 47.93112, \"heading\": 0.0}, {\"hash\": 2960930218, \"x\": 2793.796, \"y\": -1174.267, \"z\": 47.93112, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(65,'Saloon Saloon Faubourg','{\"name\": \"Saloon Saloon Faubourg\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_faubourg\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2803.587, \"y\": -1164.254, \"z\": 47.92804}, \"double\": false, \"panels\": [{\"hash\": 4220752030, \"x\": 2803.587, \"y\": -1164.254, \"z\": 47.92804, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(66,'Saloon Saloon Vanhorn','{\"name\": \"Saloon Saloon Vanhorn\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_kala\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2951.994, \"y\": 523.2606, \"z\": 45.48371}, \"double\": true, \"panels\": [{\"hash\": 244699522, \"x\": 2951.994, \"y\": 523.2606, \"z\": 45.48371, \"heading\": 0.0}, {\"hash\": 3225924839, \"x\": 2951.994, \"y\": 523.2606, \"z\": 45.48371, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(67,'Saloon Saloon Vanhorn','{\"name\": \"Saloon Saloon Vanhorn\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_kala\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2943.0595703125, \"y\": 516.47387695313, \"z\": 44.363765716553}, \"double\": false, \"panels\": [{\"hash\": 3704712698, \"x\": 2943.0595703125, \"y\": 516.47387695313, \"z\": 44.363765716553, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(68,'Saloon Saloon Vanhorn','{\"name\": \"Saloon Saloon Vanhorn\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_kala\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2938.0739746094, \"y\": 528.40545654297, \"z\": 44.363243103027}, \"double\": false, \"panels\": [{\"hash\": 2869660271, \"x\": 2938.0739746094, \"y\": 528.40545654297, \"z\": 44.363243103027, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(69,'Saloon Saloon Vanhorn','{\"name\": \"Saloon Saloon Vanhorn\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_kala\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2985.8999023438, \"y\": 569.33062744141, \"z\": 46.872211456299}, \"double\": false, \"panels\": [{\"hash\": 1102743282, \"x\": 2985.8999023438, \"y\": 569.33062744141, \"z\": 46.872211456299, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(70,'Saloon Saloon Vanhorn','{\"name\": \"Saloon Saloon Vanhorn\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_kala\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 3025.131, \"y\": 555.2164, \"z\": 44.70932}, \"double\": false, \"panels\": [{\"hash\": 3375224492, \"x\": 3025.131, \"y\": 555.2164, \"z\": 44.70932, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(71,'Saloon Saloon Vanhorn','{\"name\": \"Saloon Saloon Vanhorn\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_kala\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 3019.7863769531, \"y\": 567.87213134766, \"z\": 43.711101531982}, \"double\": false, \"panels\": [{\"hash\": 2641204994, \"x\": 3019.7863769531, \"y\": 567.87213134766, \"z\": 43.711101531982, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(72,'Saloon Saloon Vanhorn','{\"name\": \"Saloon Saloon Vanhorn\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_kala\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 3019.7863769531, \"y\": 567.87213134766, \"z\": 43.711101531982}, \"double\": false, \"panels\": [{\"hash\": 2641204994, \"x\": 3019.7863769531, \"y\": 567.87213134766, \"z\": 43.711101531982, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(73,'Saloon Saloon Vanhorn','{\"name\": \"Saloon Saloon Vanhorn\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_kala\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 3027.9602050781, \"y\": 567.66424560547, \"z\": 43.712707519531}, \"double\": false, \"panels\": [{\"hash\": 877945562, \"x\": 3027.9602050781, \"y\": 567.66424560547, \"z\": 43.712707519531, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(74,'Saloon Saloon Vanhorn','{\"name\": \"Saloon Saloon Vanhorn\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_kala\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2975.2006835938, \"y\": 571.22668457031, \"z\": 46.872211456299}, \"double\": false, \"panels\": [{\"hash\": 1997650502, \"x\": 2975.2006835938, \"y\": 571.22668457031, \"z\": 46.872211456299, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(75,'Saloon Saloon Vanhorn','{\"name\": \"Saloon Saloon Vanhorn\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_kala\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2944.819, \"y\": 540.518, \"z\": 49.48433}, \"double\": true, \"panels\": [{\"hash\": 993198975, \"x\": 2944.819, \"y\": 540.518, \"z\": 49.48433, \"heading\": 0.0}, {\"hash\": 821030649, \"x\": 2944.819, \"y\": 540.518, \"z\": 49.48433, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(76,'Saloon Tumbleweed','{\"name\": \"Saloon Tumbleweed\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_tumbleweed\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -5514.29, \"y\": -2917.19, \"z\": 1.66}, \"double\": true, \"panels\": [{\"hash\": 223504277, \"x\": -5514.29, \"y\": -2917.19, \"z\": 1.66, \"heading\": 0.0}, {\"hash\": 4292889829, \"x\": -5514.29, \"y\": -2917.19, \"z\": 1.66, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(77,'Saloon Tumbleweed','{\"name\": \"Saloon Tumbleweed\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_tumbleweed\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -5514.38, \"y\": -2913.12, \"z\": 1.64}, \"double\": false, \"panels\": [{\"hash\": 1322586500, \"x\": -5514.38, \"y\": -2913.12, \"z\": 1.64, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(78,'Saloon Tumbleweed','{\"name\": \"Saloon Tumbleweed\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_tumbleweed\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -5515.13, \"y\": -2901.66, \"z\": -1.75}, \"double\": false, \"panels\": [{\"hash\": 2094297354, \"x\": -5515.13, \"y\": -2901.66, \"z\": -1.75, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(79,'Saloon Tumbleweed','{\"name\": \"Saloon Tumbleweed\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_tumbleweed\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -5518.68, \"y\": -2912.57, \"z\": -1.75}, \"double\": false, \"panels\": [{\"hash\": 1892085175, \"x\": -5518.68, \"y\": -2912.57, \"z\": -1.75, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(80,'Saloon Rhodes','{\"name\": \"Saloon Rhodes\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1352.77, \"y\": -1376.93, \"z\": 80.5}, \"double\": true, \"panels\": [{\"hash\": 834296435, \"x\": 1352.77, \"y\": -1376.93, \"z\": 80.5, \"heading\": 0.0}, {\"hash\": 1124531468, \"x\": 1352.77, \"y\": -1376.93, \"z\": 80.5, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(81,'Saloon Rhodes','{\"panels\":[{\"heading\":0,\"z\":80.5,\"hash\":3728169477,\"y\":-1379.95,\"x\":1334.68,\"model\":0},{\"heading\":0,\"z\":80.5,\"hash\":3392483841,\"y\":-1379.95,\"x\":1334.68,\"model\":0}],\"lockpickItem\":\"lockpick\",\"double\":true,\"prompt\":{\"z\":80.5,\"x\":1334.68,\"y\":-1379.95},\"promptRadius\":2.5,\"charAccess\":[],\"name\":\"Saloon Rhodes\",\"show3d\":true,\"accessItem\":false,\"lockedOnStart\":true,\"closedRatio\":0,\"jobAccess\":[{\"name\":\"saloon_rhodes\",\"grade\":0}],\"canLockpick\":true,\"showPrompt\":true,\"category\":\"Saloon\",\"locked\":true}','2026-08-13 00:35:16','2026-08-13 00:43:24'),(82,'Saloon Rhodes','{\"name\": \"Saloon Rhodes\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1330.58, \"y\": -1367.99, \"z\": 80.49}, \"double\": false, \"panels\": [{\"hash\": 3047627494, \"x\": 1330.58, \"y\": -1367.99, \"z\": 80.49, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(83,'Saloon Rhodes','{\"name\": \"Saloon Rhodes\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1336.14, \"y\": -1371.55, \"z\": 84.29}, \"double\": true, \"panels\": [{\"hash\": 3434364936, \"x\": 1336.14, \"y\": -1371.55, \"z\": 84.29, \"heading\": 0.0}, {\"hash\": 3215894013, \"x\": 1336.14, \"y\": -1371.55, \"z\": 84.29, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(84,'Saloon Rhodes','{\"name\": \"Saloon Rhodes\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1331.831, \"y\": -1369.349, \"z\": 80.48315}, \"double\": false, \"panels\": [{\"hash\": 2046695029, \"x\": 1331.831, \"y\": -1369.349, \"z\": 80.48315, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(85,'Saloon Rhodes','{\"name\": \"Saloon Rhodes\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1334.692, \"y\": -1377.216, \"z\": 80.49891}, \"double\": false, \"panels\": [{\"hash\": 2812328251, \"x\": 1334.692, \"y\": -1377.216, \"z\": 80.49891, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(86,'Saloon Rhodes','{\"name\": \"Saloon Rhodes\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1338.827, \"y\": -1379.375, \"z\": 84.28136}, \"double\": false, \"panels\": [{\"hash\": 2446974165, \"x\": 1338.827, \"y\": -1379.375, \"z\": 84.28136, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(87,'Saloon Valentine','{\"name\": \"Saloon Valentine\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_val\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -315.94, \"y\": 818.58, \"z\": 118.98}, \"double\": false, \"panels\": [{\"hash\": 261929195, \"x\": -315.94, \"y\": 818.58, \"z\": 118.98, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(88,'Saloon Valentine','{\"name\": \"Saloon Valentine\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_val\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -306.82, \"y\": 820.26, \"z\": 118.98}, \"double\": false, \"panels\": [{\"hash\": 583884620, \"x\": -306.82, \"y\": 820.26, \"z\": 118.98, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(89,'Saloon Valentine','{\"name\": \"Saloon Valentine\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_val\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -316.84, \"y\": 816.85, \"z\": 121.98}, \"double\": false, \"panels\": [{\"hash\": 968874193, \"x\": -316.84, \"y\": 816.85, \"z\": 121.98, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(90,'Saloon Valentine','{\"name\": \"Saloon Valentine\", \"category\": \"Saloon\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"saloon_val\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -306.72, \"y\": 820.53, \"z\": 121.97}, \"double\": false, \"panels\": [{\"hash\": 1154795503, \"x\": -306.72, \"y\": 820.53, \"z\": 121.97, \"heading\": 0.0}]}','2026-08-13 00:35:16','2026-08-13 00:35:16'),(91,'Pris├â┬úo','{\"name\": \"Pris├â┬úo\", \"category\": \"Pris├â┬úo\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"marshall\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 3326.77, \"y\": -706.36, \"z\": 44.32}, \"double\": true, \"panels\": [{\"hash\": 1121239638, \"x\": 3326.77, \"y\": -706.36, \"z\": 44.32, \"heading\": 0.0}, {\"hash\": 2617210026, \"x\": 3326.77, \"y\": -706.36, \"z\": 44.32, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(92,'Pris├â┬úo','{\"name\": \"Pris├â┬úo\", \"category\": \"Pris├â┬úo\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"marshall\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 3332.76, \"y\": -701.05, \"z\": 44.02}, \"double\": true, \"panels\": [{\"hash\": 906662604, \"x\": 3332.76, \"y\": -701.05, \"z\": 44.02, \"heading\": 0.0}, {\"hash\": 3984556459, \"x\": 3332.76, \"y\": -701.05, \"z\": 44.02, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(93,'Armeiro Rhodes','{\"name\": \"Armeiro Rhodes\", \"category\": \"Armeiro\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"armurier_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1325.14, \"y\": -1324.22, \"z\": 77.89}, \"double\": false, \"panels\": [{\"hash\": 1410133961, \"x\": 1325.14, \"y\": -1324.22, \"z\": 77.89, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(94,'Armeiro Rhodes','{\"name\": \"Armeiro Rhodes\", \"category\": \"Armeiro\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"armurier_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1325.931, \"y\": -1318.827, \"z\": 77.94665}, \"double\": false, \"panels\": [{\"hash\": 393076024, \"x\": 1325.931, \"y\": -1318.827, \"z\": 77.94665, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(95,'Armeiro Rhodes','{\"name\": \"Armeiro Rhodes\", \"category\": \"Armeiro\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"armurier_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1329.8211669922, \"y\": -1329.1970214844, \"z\": 76.891494750977}, \"double\": false, \"panels\": [{\"hash\": 743565308, \"x\": 1329.8211669922, \"y\": -1329.1970214844, \"z\": 76.891494750977, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(96,'Armeiro Rhodes','{\"name\": \"Armeiro Rhodes\", \"category\": \"Armeiro\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"armurier_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1319.5262451172, \"y\": -1324.3895263672, \"z\": 76.891494750977}, \"double\": false, \"panels\": [{\"hash\": 934926308, \"x\": 1319.5262451172, \"y\": -1324.3895263672, \"z\": 76.891494750977, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(97,'Armeiro Saint Denis','{\"name\": \"Armeiro Saint Denis\", \"category\": \"Armeiro\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"armurier_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2719.8837890625, \"y\": -1281.5419921875, \"z\": 48.637580871582}, \"double\": true, \"panels\": [{\"hash\": 1057071735, \"x\": 2719.8837890625, \"y\": -1281.5419921875, \"z\": 48.637580871582, \"heading\": 0.0}, {\"hash\": 3283200993, \"x\": 2719.8837890625, \"y\": -1281.5419921875, \"z\": 48.637580871582, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(98,'Armeiro Saint Denis','{\"name\": \"Armeiro Saint Denis\", \"category\": \"Armeiro\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"armurier_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2710.5659179688, \"y\": -1291.2041015625, \"z\": 48.632297515869}, \"double\": false, \"panels\": [{\"hash\": 841127028, \"x\": 2710.5659179688, \"y\": -1291.2041015625, \"z\": 48.632297515869, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(99,'Mercado Rhodes','{\"category\":\"Mercado\",\"lockedOnStart\":true,\"lockpickItem\":\"lockpick\",\"name\":\"Mercado Rhodes\",\"closedRatio\":0.0,\"prompt\":{\"x\":1325.2160644531,\"z\":75.99486541748,\"y\":-1294.3470458984},\"charAccess\":[],\"showPrompt\":true,\"jobAccess\":[{\"name\":\"store_rhodes\",\"grade\":0}],\"promptRadius\":2.5,\"panels\":[{\"x\":1325.2160644531,\"model\":0,\"y\":-1294.3470458984,\"hash\":972368328,\"z\":75.99486541748,\"heading\":0.0}],\"show3d\":false,\"canLockpick\":true,\"accessItem\":false,\"double\":false,\"locked\":true}','2026-08-13 00:35:17','2026-08-24 21:23:01'),(100,'Mercado Rhodes','{\"name\": \"Mercado Rhodes\", \"category\": \"Mercado\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"store_rhodes\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1332.6689453125, \"y\": -1291.1726074219, \"z\": 76.009201049805}, \"double\": false, \"panels\": [{\"hash\": 1060413677, \"x\": 1332.6689453125, \"y\": -1291.1726074219, \"z\": 76.009201049805, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(101,'Mercado Strawberry','{\"name\": \"Mercado Strawberry\", \"category\": \"Mercado\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"store_straw\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -1794.4954833984, \"y\": -381.68154907227, \"z\": 159.314453125}, \"double\": false, \"panels\": [{\"hash\": 1595373759, \"x\": -1794.4954833984, \"y\": -381.68154907227, \"z\": 159.314453125, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(102,'Mercado Strawberry','{\"name\": \"Mercado Strawberry\", \"category\": \"Mercado\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"store_straw\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -1787.3168945313, \"y\": -387.2438659668, \"z\": 159.31578063965}, \"double\": false, \"panels\": [{\"hash\": 1854467923, \"x\": -1787.3168945313, \"y\": -387.2438659668, \"z\": 159.31578063965, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(103,'Mercado Stdenis','{\"name\": \"Mercado Stdenis\", \"category\": \"Mercado\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"store_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2830.0, \"y\": -1319.157, \"z\": 45.74673}, \"double\": true, \"panels\": [{\"hash\": 4114891219, \"x\": 2830.0, \"y\": -1319.157, \"z\": 45.74673, \"heading\": 0.0}, {\"hash\": 1051874490, \"x\": 2830.0, \"y\": -1319.157, \"z\": 45.74673, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(104,'Mercado Stdenis','{\"name\": \"Mercado Stdenis\", \"category\": \"Mercado\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"store_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2824.116, \"y\": -1314.147, \"z\": 45.75566}, \"double\": true, \"panels\": [{\"hash\": 4234072328, \"x\": 2824.116, \"y\": -1314.147, \"z\": 45.75566, \"heading\": 0.0}, {\"hash\": 3986240381, \"x\": 2824.116, \"y\": -1314.147, \"z\": 45.75566, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(105,'Mercado Blackwater','{\"panels\":[{\"x\":-790.3356,\"heading\":0.0,\"model\":0,\"hash\":2796645535,\"z\":42.94269,\"y\":-1322.739}],\"canLockpick\":true,\"showPrompt\":true,\"closedRatio\":0.0,\"charAccess\":[],\"locked\":true,\"lockpickItem\":\"lockpick\",\"name\":\"Mercado Blackwater\",\"prompt\":{\"x\":-790.3356,\"z\":42.94269,\"y\":-1322.739},\"category\":\"Mercado\",\"lockedOnStart\":true,\"promptRadius\":2.5,\"show3d\":false,\"double\":false,\"jobAccess\":[{\"name\":\"store_bla\",\"grade\":0}],\"accessItem\":false}','2026-08-13 00:35:17','2026-08-13 18:23:21'),(106,'Mercado Blackwater','{\"name\": \"Mercado Blackwater\", \"category\": \"Mercado\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"store_bla\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -775.6486, \"y\": -1321.515, \"z\": 42.90887}, \"double\": false, \"panels\": [{\"hash\": 3042576856, \"x\": -775.6486, \"y\": -1321.515, \"z\": 42.90887, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(107,'Mercado Blackwater','{\"panels\":[{\"x\":-781.6522,\"heading\":0.0,\"model\":0,\"hash\":2046989122,\"z\":47.10576,\"y\":-1320.372}],\"canLockpick\":true,\"showPrompt\":true,\"closedRatio\":0.0,\"charAccess\":[],\"locked\":true,\"lockpickItem\":\"lockpick\",\"name\":\"Mercado Blackwater\",\"prompt\":{\"x\":-781.6522,\"z\":47.10576,\"y\":-1320.372},\"category\":\"Mercado\",\"lockedOnStart\":true,\"promptRadius\":2.5,\"show3d\":false,\"double\":false,\"jobAccess\":[{\"name\":\"store_bla\",\"grade\":0}],\"accessItem\":false}','2026-08-13 00:35:17','2026-08-13 18:23:21'),(108,'Forja Dogwater','{\"name\": \"Forja Dogwater\", \"category\": \"Forja\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"forge\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -871.6291, \"y\": -1293.029, \"z\": 43.10454}, \"double\": true, \"panels\": [{\"hash\": 752949299, \"x\": -871.6291, \"y\": -1293.029, \"z\": 43.10454, \"heading\": 0.0}, {\"hash\": 1538487767, \"x\": -871.6291, \"y\": -1293.029, \"z\": 43.10454, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(109,'Forja Dogwater','{\"name\": \"Forja Dogwater\", \"category\": \"Forja\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"forge\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -876.828, \"y\": -1288.957, \"z\": 43.10406}, \"double\": false, \"panels\": [{\"hash\": 1318509470, \"x\": -876.828, \"y\": -1288.957, \"z\": 43.10406, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(110,'Fazenda Dogwater','{\"name\": \"Fazenda Dogwater\", \"category\": \"Fazenda\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"fermier\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -1646.2409667969, \"y\": -1367.1358642578, \"z\": 83.465660095215}, \"double\": false, \"panels\": [{\"hash\": 1606546482, \"x\": -1646.2409667969, \"y\": -1367.1358642578, \"z\": 83.465660095215, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(111,'Fazenda Dogwater','{\"name\": \"Fazenda Dogwater\", \"category\": \"Fazenda\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"fermier\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -1637.7155761719, \"y\": -1352.6480712891, \"z\": 83.466453552246}, \"double\": false, \"panels\": [{\"hash\": 2310818050, \"x\": -1637.7155761719, \"y\": -1352.6480712891, \"z\": 83.466453552246, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(112,'Fazenda Dogwater','{\"name\": \"Fazenda Dogwater\", \"category\": \"Fazenda\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"fermier\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -1649.2072753906, \"y\": -1359.2379150391, \"z\": 83.464546203613}, \"double\": false, \"panels\": [{\"hash\": 818583340, \"x\": -1649.2072753906, \"y\": -1359.2379150391, \"z\": 83.464546203613, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(113,'M├â┬⌐dico Dogwater','{\"name\": \"M├â┬⌐dico Dogwater\", \"category\": \"M├â┬⌐dico\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"fermier\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -1646.2409667969, \"y\": -1367.1358642578, \"z\": 83.465660095215}, \"double\": false, \"panels\": [{\"hash\": 1606546482, \"x\": -1646.2409667969, \"y\": -1367.1358642578, \"z\": 83.465660095215, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(114,'Jornal St Denis','{\"name\": \"Jornal St Denis\", \"category\": \"Jornal\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"presse\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2626.15, \"y\": -1338.11, \"z\": 49.17}, \"double\": true, \"panels\": [{\"hash\": 3438582231, \"x\": 2626.15, \"y\": -1338.11, \"z\": 49.17, \"heading\": 0.0}, {\"hash\": 461125209, \"x\": 2626.15, \"y\": -1338.11, \"z\": 49.17, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(115,'Jornal St Denis','{\"name\": \"Jornal St Denis\", \"category\": \"Jornal\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"presse\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2604.73, \"y\": -1348.04, \"z\": 49.13}, \"double\": true, \"panels\": [{\"hash\": 2353368182, \"x\": 2604.73, \"y\": -1348.04, \"z\": 49.13, \"heading\": 0.0}, {\"hash\": 1913870354, \"x\": 2604.73, \"y\": -1348.04, \"z\": 49.13, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(116,'Jornal DrugMercado','{\"name\": \"Jornal DrugMercado\", \"category\": \"Jornal\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"apothicaire_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2633.294, \"y\": -1346.697, \"z\": 49.0757}, \"double\": true, \"panels\": [{\"hash\": 2718326542, \"x\": 2633.294, \"y\": -1346.697, \"z\": 49.0757, \"heading\": 0.0}, {\"hash\": 2100663661, \"x\": 2633.294, \"y\": -1346.697, \"z\": 49.0757, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(117,'Jornal DrugMercado','{\"name\": \"Jornal DrugMercado\", \"category\": \"Jornal\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"apothicaire_stdenis\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2626.61, \"y\": -1347.58, \"z\": 48.04}, \"double\": false, \"panels\": [{\"hash\": 828250887, \"x\": 2626.61, \"y\": -1347.58, \"z\": 48.04, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(118,'Taxidermista','{\"name\": \"Taxidermista\", \"category\": \"Taxidermista\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"all\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -1682.649, \"y\": -341.3071, \"z\": 173.9155}, \"double\": false, \"panels\": [{\"hash\": 1963415953, \"x\": -1682.649, \"y\": -341.3071, \"z\": 173.9155, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(119,'Taxidermista','{\"name\": \"Taxidermista\", \"category\": \"Taxidermista\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"all\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": -1679.373, \"y\": -336.7736, \"z\": 173.9922}, \"double\": false, \"panels\": [{\"hash\": 2847752952, \"x\": -1679.373, \"y\": -336.7736, \"z\": 173.9922, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(120,'Destilaria','{\"name\": \"Destilaria\", \"category\": \"Destilaria\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"distillerie\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1459.719, \"y\": -1579.794, \"z\": 72.01608}, \"double\": false, \"panels\": [{\"hash\": 3327934361, \"x\": 1459.719, \"y\": -1579.794, \"z\": 72.01608, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(121,'Destilaria','{\"name\": \"Destilaria\", \"category\": \"Destilaria\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"distillerie\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 1449.75, \"y\": -1575.804, \"z\": 71.99829}, \"double\": false, \"panels\": [{\"hash\": 3014302262, \"x\": 1449.75, \"y\": -1575.804, \"z\": 71.99829, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(122,'Apartamento Chin├â┬¬s','{\"name\": \"Apartamento Chin├â┬¬s\", \"category\": \"Apartamento Chin├â┬¬s\", \"locked\": true, \"lockedOnStart\": true, \"showPrompt\": true, \"show3d\": false, \"canLockpick\": true, \"lockpickItem\": \"lockpick\", \"accessItem\": false, \"jobAccess\": [\"all\"], \"charAccess\": [], \"closedRatio\": 0.0, \"promptRadius\": 2.5, \"prompt\": {\"x\": 2711.83, \"y\": -1293.481, \"z\": 60.4574}, \"double\": false, \"panels\": [{\"hash\": 1180868565, \"x\": 2711.83, \"y\": -1293.481, \"z\": 60.4574, \"heading\": 0.0}]}','2026-08-13 00:35:17','2026-08-13 00:35:17'),(123,'Vallentire Store','{\"show3d\":true,\"name\":\"Vallentire Store\",\"promptRadius\":2,\"panels\":[{\"hash\":706990067,\"model\":-1957055091,\"heading\":0,\"modelName\":\"p_door_val_genstore\",\"x\":-319.24,\"y\":797.03,\"z\":116.89}],\"double\":false,\"closedRatio\":0,\"prompt\":{\"x\":-319.7,\"y\":796.53,\"z\":116.94},\"jobAccess\":[],\"charAccess\":[],\"category\":\"Mercado\",\"showPrompt\":true,\"accessItem\":\"store_key_valentine\",\"locked\":true,\"lockedOnStart\":true,\"lockpickItem\":\"lockpick\",\"canLockpick\":true}','2026-08-13 13:06:57','2026-09-09 12:05:44'),(124,'Vallentire Store','{\"lockpickItem\":\"LOCKPICK\",\"canLockpick\":true,\"name\":\"Vallentire Store\",\"accessItem\":\"store_key_valentine\",\"promptRadius\":2,\"closedRatio\":0,\"lockedOnStart\":true,\"charAccess\":[],\"show3d\":true,\"double\":false,\"category\":\"Mercado\",\"showPrompt\":true,\"prompt\":{\"x\":-329.39,\"y\":804.52,\"z\":116.69},\"panels\":[{\"x\":-328.84,\"y\":805.3,\"z\":116.88,\"heading\":0,\"hash\":4004877412,\"modelName\":\"p_door_val_genstore2\",\"model\":-164490887}],\"jobAccess\":[],\"locked\":true}','2026-08-13 13:10:13','2026-08-16 14:01:52'),(125,'Armeiro Vallentine 01','{\"lockpickItem\":\"lockpick\",\"lockedOnStart\":true,\"charAccess\":[],\"show3d\":true,\"promptRadius\":2,\"accessItem\":\"store_master_key\",\"locked\":true,\"category\":\"Armeiro\",\"double\":false,\"closedRatio\":0,\"name\":\"Armeiro Vallentine 01\",\"showPrompt\":true,\"jobAccess\":[],\"prompt\":{\"x\":-282.95,\"y\":784.44,\"z\":118.51},\"panels\":[{\"hash\":475159788,\"heading\":0,\"modelName\":\"p_door04x\",\"x\":-283.54,\"y\":784.41,\"model\":-542955242,\"z\":118.53}],\"canLockpick\":true}','2026-08-15 00:13:14','2026-08-28 03:08:48'),(126,'Armeiro Vallentine 02','{\"show3d\":true,\"name\":\"Armeiro Vallentine 02\",\"promptRadius\":2,\"panels\":[{\"hash\":2042647667,\"model\":-542955242,\"heading\":0,\"modelName\":\"p_door04x\",\"x\":-276.66,\"y\":776.6,\"z\":118.55}],\"double\":false,\"closedRatio\":0,\"prompt\":{\"x\":-277.28,\"y\":776.59,\"z\":118.58},\"jobAccess\":[],\"charAccess\":[],\"category\":\"Armeiro\",\"showPrompt\":true,\"accessItem\":\"store_master_key\",\"locked\":true,\"lockedOnStart\":true,\"lockpickItem\":\"lockpick\",\"canLockpick\":true}','2026-08-15 00:15:05','2026-09-09 12:05:44'),(127,'hotel V','{\"lockpickItem\":false,\"panels\":[{\"z\":116.45,\"modelName\":\"p_door33x\",\"y\":776.74,\"heading\":0,\"hash\":1879307167,\"x\":-326.29,\"model\":1650744725}],\"closedRatio\":0,\"lockedOnStart\":true,\"category\":\"Apartamento Chin├â┬¬s\",\"prompt\":{\"z\":116.49,\"x\":-326.93,\"y\":776.64},\"name\":\"hotel V\",\"canLockpick\":true,\"accessItem\":\"lockpick\",\"locked\":true,\"double\":false,\"jobAccess\":[],\"show3d\":true,\"promptRadius\":2,\"showPrompt\":true,\"charAccess\":[]}','2026-08-20 17:59:13','2026-08-29 10:52:04'),(128,'Door','{\"double\":true,\"promptRadius\":2,\"locked\":true,\"lockpickItem\":false,\"jobAccess\":[],\"showPrompt\":true,\"panels\":[{\"modelName\":\"p_door_val_bank00_rx\",\"heading\":0,\"z\":117.73,\"hash\":3886827663,\"model\":169503210,\"x\":-306.89,\"y\":780.12},{\"modelName\":\"p_door_val_bank00_lx\",\"heading\":0,\"z\":117.73,\"hash\":2642457609,\"model\":160636303,\"x\":-309.05,\"y\":779.73}],\"accessItem\":\"lockpick\",\"name\":\"Door\",\"show3d\":true,\"lockedOnStart\":true,\"canLockpick\":false,\"charAccess\":[],\"prompt\":{\"z\":117.78,\"y\":779.92,\"x\":-308.07},\"category\":\"\",\"closedRatio\":0}','2026-08-27 11:14:43','2026-08-27 11:15:32');
/*!40000 ALTER TABLE `wasvendel_doorlocks` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-09 10:58:57
