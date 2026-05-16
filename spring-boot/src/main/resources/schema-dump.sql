CREATE DATABASE  IF NOT EXISTS `bomiq_sdm` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `bomiq_sdm`;
-- MySQL dump 10.13  Distrib 8.0.45, for macos15 (x86_64)
--
-- Host: localhost    Database: bomiq_sdm
-- ------------------------------------------------------
-- Server version	8.2.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `bom_attachment`
--

DROP TABLE IF EXISTS `bom_attachment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bom_attachment` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `bom_header_id` bigint unsigned NOT NULL,
  `attachment_type` enum('DRAWING','DATASHEET','TEST_REPORT','PHOTO','CAD','OTHER') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_size_bytes` bigint unsigned DEFAULT NULL,
  `mime_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `uploaded_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uploaded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `bom_header_id` (`bom_header_id`),
  CONSTRAINT `bom_attachment_ibfk_1` FOREIGN KEY (`bom_header_id`) REFERENCES `bom_header` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bom_attachment`
--

LOCK TABLES `bom_attachment` WRITE;
/*!40000 ALTER TABLE `bom_attachment` DISABLE KEYS */;
/*!40000 ALTER TABLE `bom_attachment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bom_change_log`
--

DROP TABLE IF EXISTS `bom_change_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bom_change_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `bom_header_id` bigint unsigned NOT NULL,
  `change_type` enum('CREATE','UPDATE','STATUS_CHANGE','APPROVE','RELEASE','OBSOLETE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `field_changed` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `old_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `new_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `changed_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `change_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ecn_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `changed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `bom_header_id` (`bom_header_id`),
  CONSTRAINT `bom_change_log_ibfk_1` FOREIGN KEY (`bom_header_id`) REFERENCES `bom_header` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bom_change_log`
--

LOCK TABLES `bom_change_log` WRITE;
/*!40000 ALTER TABLE `bom_change_log` DISABLE KEYS */;
INSERT INTO `bom_change_log` VALUES (1,1,'STATUS_CHANGE','bom_status','IN_REVIEW','RELEASED','mgr.approval@bomiq.com','Design review complete. All RPN items resolved.','ECN-2024-0042','2026-05-13 18:19:41'),(2,4,'UPDATE','bom_revision','A','B','smt.eng@bomiq.com','Updated DDR routing constraint from ±5mil to ±10mil per SI analysis.','ECN-2024-0039','2026-05-13 18:19:41'),(3,4,'UPDATE','bom_revision','B','C','smt.eng@bomiq.com','Added conformal coat process step to CPU section notes.','ECN-2024-0041','2026-05-13 18:19:41');
/*!40000 ALTER TABLE `bom_change_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bom_header`
--

DROP TABLE IF EXISTS `bom_header`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bom_header` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `bom_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `bom_revision` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'A',
  `bom_title` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `bom_type` enum('ENGINEERING','MANUFACTURING','SERVICE','SALES','PLANNING') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ENGINEERING',
  `bom_status` enum('DRAFT','IN_REVIEW','APPROVED','RELEASED','OBSOLETE','SUPERSEDED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'DRAFT',
  `effective_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `engineering_change_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `change_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `total_material_cost` decimal(18,4) DEFAULT NULL,
  `total_labor_cost` decimal(18,4) DEFAULT NULL,
  `total_overhead_cost` decimal(18,4) DEFAULT NULL,
  `total_bom_cost` decimal(18,4) DEFAULT NULL,
  `currency_code` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'USD',
  `costing_date` date DEFAULT NULL,
  `weight_kg` decimal(12,4) DEFAULT NULL,
  `volume_cm3` decimal(14,4) DEFAULT NULL,
  `target_assembly_time_min` int DEFAULT NULL,
  `assembly_location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quality_plan_ref` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `risk_level` enum('LOW','MEDIUM','HIGH','CRITICAL') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approval_required_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approved_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `released_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `released_at` datetime DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `parent_bom_id` bigint unsigned DEFAULT NULL,
  `level_in_hierarchy` int DEFAULT '1',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bom_number` (`bom_number`),
  KEY `idx_bom_header_product` (`product_id`),
  KEY `idx_bom_header_status` (`bom_status`),
  KEY `idx_bom_header_parent` (`parent_bom_id`),
  CONSTRAINT `bom_header_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`),
  CONSTRAINT `bom_header_ibfk_2` FOREIGN KEY (`parent_bom_id`) REFERENCES `bom_header` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bom_header`
--

LOCK TABLES `bom_header` WRITE;
/*!40000 ALTER TABLE `bom_header` DISABLE KEYS */;
INSERT INTO `bom_header` VALUES (1,'BOM-EC5000-001','C','EdgeConnect 5000 — Top-Level Manufacturing BOM',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,487.2500,NULL,NULL,NULL,'USD',NULL,1.4200,NULL,45,'Assembly Line A',NULL,'MEDIUM',NULL,NULL,NULL,NULL,NULL,'Full build including all subassemblies. Requires ESD-safe workstation.',NULL,1,'eng.team@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(2,'BOM-EC5100-001','A','EdgeConnect 5100 Heavy-Duty — Top-Level BOM',2,'ENGINEERING','IN_REVIEW','2024-06-01',NULL,NULL,NULL,612.8000,NULL,NULL,NULL,'USD',NULL,1.8900,NULL,60,'Assembly Line B',NULL,'HIGH',NULL,NULL,NULL,NULL,NULL,'ATEX Zone 2 rated variant. Pending regulatory sign-off.',NULL,1,'eng.team@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(3,'BOM-EC5200-001','A','EdgeConnect 5200 Rail — Top-Level BOM',3,'ENGINEERING','DRAFT',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'USD',NULL,NULL,NULL,NULL,NULL,NULL,'HIGH',NULL,NULL,NULL,NULL,NULL,'EN50155 rail variant. Design phase.',NULL,1,'eng.team@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(4,'BOM-EC5000-MB','B','EC-5000 Main Processing Board Subassembly',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,198.4000,NULL,NULL,NULL,'USD',NULL,0.3800,NULL,20,'SMT Line 1',NULL,'MEDIUM',NULL,NULL,NULL,NULL,NULL,'ARM Cortex-A55 SoC based main board. 4-layer PCB.',1,2,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(5,'BOM-EC5000-CM','B','EC-5000 Cellular Modem Subassembly',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,89.7500,NULL,NULL,NULL,'USD',NULL,0.0950,NULL,10,'SMT Line 2',NULL,'MEDIUM',NULL,NULL,NULL,NULL,NULL,'Cat-M1/NB-IoT/4G-LTE module with SIM management.',1,2,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(6,'BOM-EC5000-WL','A','EC-5000 Wi-Fi & BLE Wireless Subassembly',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,42.6000,NULL,NULL,NULL,'USD',NULL,0.0550,NULL,8,'SMT Line 2',NULL,'LOW',NULL,NULL,NULL,NULL,NULL,'Wi-Fi 6 (802.11ax) + BLE 5.3 combo module assembly.',1,2,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(7,'BOM-EC5000-IO','C','EC-5000 I/O Expansion Board Subassembly',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,67.3000,NULL,NULL,NULL,'USD',NULL,0.1200,NULL,12,'SMT Line 1',NULL,'LOW',NULL,NULL,NULL,NULL,NULL,'RS-485/RS-232, DI/DO, 4-20mA analog I/O expansion board.',1,2,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(8,'BOM-EC5000-PSU','B','EC-5000 Internal Power Supply Subassembly',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,55.2000,NULL,NULL,NULL,'USD',NULL,0.1800,NULL,10,'SMT Line 3',NULL,'MEDIUM',NULL,NULL,NULL,NULL,NULL,'Wide input 9-36VDC switching regulator with protection circuits.',1,2,'pwr.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(9,'BOM-EC5000-ENC','A','EC-5000 Enclosure & Mechanical Subassembly',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,34.0000,NULL,NULL,NULL,'USD',NULL,0.5900,NULL,15,'Mech Assembly',NULL,'LOW',NULL,NULL,NULL,NULL,NULL,'IP67 die-cast aluminum enclosure with DIN-rail mount.',1,2,'mech.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(10,'BOM-EC5000-MB-CPU','B','EC-5000 Main Board CPU Section',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,112.0000,NULL,NULL,NULL,'USD',NULL,0.0800,NULL,8,'SMT Line 1',NULL,'HIGH',NULL,NULL,NULL,NULL,NULL,'SoC, LPDDR4 RAM, eMMC flash, crystal oscillator section.',4,3,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(11,'BOM-EC5000-MB-PWR','A','EC-5000 Main Board Power Rail Section',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,38.5000,NULL,NULL,NULL,'USD',NULL,0.0400,NULL,5,'SMT Line 1',NULL,'MEDIUM',NULL,NULL,NULL,NULL,NULL,'DC-DC buck/boost converters, LDOs, bulk decoupling.',4,3,'pwr.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(12,'BOM-EC5000-MB-ETH','A','EC-5000 Main Board Ethernet Section',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,28.9000,NULL,NULL,NULL,'USD',NULL,0.0250,NULL,4,'SMT Line 1',NULL,'MEDIUM',NULL,NULL,NULL,NULL,NULL,'Gigabit Ethernet PHY, magnetics, RJ45 connector.',4,3,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(13,'BOM-EC5000-IO-DIO','A','EC-5000 I/O Board Digital I/O Section',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,22.4000,NULL,NULL,NULL,'USD',NULL,0.0350,NULL,5,'SMT Line 1',NULL,'LOW',NULL,NULL,NULL,NULL,NULL,'Optocoupler-isolated 8x DI + 4x DO with surge protection.',7,3,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(14,'BOM-EC5000-IO-AIO','A','EC-5000 I/O Board Analog I/O Section',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,19.6000,NULL,NULL,NULL,'USD',NULL,0.0200,NULL,4,'SMT Line 1',NULL,'LOW',NULL,NULL,NULL,NULL,NULL,'4-channel 4-20mA input, 2-channel 0-10V output.',7,3,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(15,'BOM-EC5000-IO-SER','A','EC-5000 I/O Board Serial Comm Section',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,18.7000,NULL,NULL,NULL,'USD',NULL,0.0200,NULL,4,'SMT Line 1',NULL,'LOW',NULL,NULL,NULL,NULL,NULL,'RS-485 (x2) and RS-232 (x1) half/full-duplex transceivers.',7,3,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(16,'BOM-EC5000-CBL','A','EC-5000 Cable & Harness Kit',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,12.8000,NULL,NULL,NULL,'USD',NULL,0.0850,NULL,8,'Mech Assembly',NULL,'LOW',NULL,NULL,NULL,NULL,NULL,'Internal cable harnesses: USB, power, I/O board interconnect.',1,2,'mech.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(17,'BOM-EC5000-FW','C','EC-5000 Firmware & Software Load BOM',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,0.0000,NULL,NULL,NULL,'USD',NULL,0.0000,NULL,5,'Flash Station',NULL,'LOW',NULL,NULL,NULL,NULL,NULL,'Factory firmware load: bootloader v2.1, OS v5.4, app v3.2.1.',1,2,'fw.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(18,'BOM-EC5000-LBL','A','EC-5000 Labeling & Documentation Kit',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,3.2000,NULL,NULL,NULL,'USD',NULL,0.0150,NULL,3,'Pack Station',NULL,'LOW',NULL,NULL,NULL,NULL,NULL,'Regulatory labels, CE mark, serial number, QR code, calibration cert.',1,2,'mfg.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(19,'BOM-EC5000-PKG','B','EC-5000 Retail & Shipping Packaging BOM',1,'MANUFACTURING','RELEASED','2024-01-15',NULL,NULL,NULL,8.5000,NULL,NULL,NULL,'USD',NULL,0.3200,NULL,5,'Pack Station',NULL,'LOW',NULL,NULL,NULL,NULL,NULL,'Custom foam insert, recycled cardboard outer, quick-start guide.',1,2,'mfg.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(20,'BOM-EP100W-001','B','EdgePower 100W DIN-Rail PSU — Manufacturing BOM',4,'MANUFACTURING','RELEASED','2024-03-01',NULL,NULL,NULL,124.6000,NULL,NULL,NULL,'USD',NULL,0.8800,NULL,30,'SMT Line 3',NULL,'MEDIUM',NULL,NULL,NULL,NULL,NULL,'Wide-input 85-264VAC, 24VDC/4.2A output PSU.',NULL,1,'pwr.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25');
/*!40000 ALTER TABLE `bom_header` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bom_line_item`
--

DROP TABLE IF EXISTS `bom_line_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bom_line_item` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `bom_header_id` bigint unsigned NOT NULL,
  `line_sequence` int NOT NULL,
  `component_id` bigint unsigned NOT NULL,
  `quantity` decimal(14,6) NOT NULL DEFAULT '1.000000',
  `uom_id` bigint unsigned DEFAULT NULL,
  `reference_designator` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `find_number` int DEFAULT NULL,
  `sub_bom_id` bigint unsigned DEFAULT NULL,
  `item_type` enum('STANDARD','PHANTOM','REFERENCE','SELECT','VARIANT') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'STANDARD',
  `procurement_type` enum('BUY','MAKE','CONSIGNED','PHANTOM') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unit_cost` decimal(18,4) DEFAULT NULL,
  `extended_cost` decimal(18,4) DEFAULT NULL,
  `lead_time_days` int DEFAULT NULL,
  `scrap_factor_pct` decimal(6,2) DEFAULT NULL,
  `yield_factor_pct` decimal(6,2) DEFAULT '100.00',
  `effective_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `engineering_change_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position_description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assembly_instruction` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `inspection_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `substitution_allowed` tinyint(1) DEFAULT '0',
  `substitute_component_id` bigint unsigned DEFAULT NULL,
  `critical_component` tinyint(1) DEFAULT '0',
  `preferred_supplier_id` bigint unsigned DEFAULT NULL,
  `supplier_part_no` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_bom_seq` (`bom_header_id`,`line_sequence`),
  KEY `uom_id` (`uom_id`),
  KEY `sub_bom_id` (`sub_bom_id`),
  KEY `substitute_component_id` (`substitute_component_id`),
  KEY `preferred_supplier_id` (`preferred_supplier_id`),
  KEY `idx_bom_line_bom` (`bom_header_id`),
  KEY `idx_bom_line_component` (`component_id`),
  CONSTRAINT `bom_line_item_ibfk_1` FOREIGN KEY (`bom_header_id`) REFERENCES `bom_header` (`id`),
  CONSTRAINT `bom_line_item_ibfk_2` FOREIGN KEY (`component_id`) REFERENCES `component` (`id`),
  CONSTRAINT `bom_line_item_ibfk_3` FOREIGN KEY (`uom_id`) REFERENCES `unit_of_measure` (`id`),
  CONSTRAINT `bom_line_item_ibfk_4` FOREIGN KEY (`sub_bom_id`) REFERENCES `bom_header` (`id`),
  CONSTRAINT `bom_line_item_ibfk_5` FOREIGN KEY (`substitute_component_id`) REFERENCES `component` (`id`),
  CONSTRAINT `bom_line_item_ibfk_6` FOREIGN KEY (`preferred_supplier_id`) REFERENCES `supplier` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bom_line_item`
--

LOCK TABLES `bom_line_item` WRITE;
/*!40000 ALTER TABLE `bom_line_item` DISABLE KEYS */;
INSERT INTO `bom_line_item` VALUES (1,4,10,1,1.000000,1,'U1',10,NULL,'STANDARD',NULL,48.5000,48.5000,NULL,0.50,100.00,NULL,NULL,NULL,NULL,'Apply thermal paste before heatsink attachment. ESD precautions mandatory.',NULL,0,NULL,1,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(2,4,20,2,2.000000,1,'U2,U3',20,NULL,'STANDARD',NULL,18.2000,36.4000,NULL,0.25,100.00,NULL,NULL,NULL,NULL,'Route DDR signals as differential pairs, length-matched ±10mil.',NULL,0,NULL,1,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(3,4,30,3,1.000000,1,'U4',30,NULL,'STANDARD',NULL,12.7500,12.7500,NULL,0.25,100.00,NULL,NULL,NULL,NULL,'Flash programming at SMT stage before conformal coat.',NULL,0,NULL,1,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(4,4,40,6,1.000000,1,'U5',40,NULL,'STANDARD',NULL,4.2000,4.2000,NULL,0.50,100.00,NULL,NULL,NULL,NULL,'Impedance control required on MDI pairs.',NULL,0,NULL,0,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(5,4,50,11,48.000000,1,'C1-C48',50,NULL,'STANDARD',NULL,0.0080,0.3800,NULL,2.00,100.00,NULL,NULL,NULL,NULL,'Bulk decoupling. Place within 0.5mm of power pins.',NULL,0,NULL,0,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(6,4,60,12,12.000000,1,'C49-C60',60,NULL,'STANDARD',NULL,0.0420,0.5000,NULL,1.00,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(7,4,70,13,24.000000,1,'R1-R24',70,NULL,'STANDARD',NULL,0.0030,0.0720,NULL,2.00,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(8,4,80,14,1.000000,1,'J1',80,NULL,'STANDARD',NULL,2.8000,2.8000,NULL,0.50,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(9,4,90,16,1.000000,1,'PCB1',90,NULL,'STANDARD',NULL,22.0000,22.0000,NULL,0.25,100.00,NULL,NULL,NULL,NULL,'Incoming inspection: dimensional check + netlist test.',NULL,0,NULL,1,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(10,4,100,9,2.000000,1,'U6,U7',100,NULL,'STANDARD',NULL,3.4000,6.8000,NULL,0.50,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(11,4,110,10,3.000000,1,'U8-U10',110,NULL,'STANDARD',NULL,0.6500,1.9500,NULL,0.50,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(12,5,10,4,1.000000,1,'MOD1',10,NULL,'STANDARD',NULL,28.4000,28.4000,NULL,0.50,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,1,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(13,5,20,11,12.000000,1,'C1-C12',20,NULL,'STANDARD',NULL,0.0080,0.0960,NULL,2.00,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(14,5,30,13,8.000000,1,'R1-R8',30,NULL,'STANDARD',NULL,0.0030,0.0240,NULL,2.00,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(15,6,10,5,1.000000,1,'MOD2',10,NULL,'STANDARD',NULL,14.8000,14.8000,NULL,NULL,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,1,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(16,6,20,11,8.000000,1,'C1-C8',20,NULL,'STANDARD',NULL,0.0080,0.0640,NULL,NULL,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(17,7,10,17,1.000000,1,'PCB1',10,NULL,'STANDARD',NULL,8.5000,8.5000,NULL,NULL,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,1,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(18,7,20,7,2.000000,1,'U1,U2',20,NULL,'STANDARD',NULL,1.8500,3.7000,NULL,NULL,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(19,7,30,8,8.000000,1,'U3-U10',30,NULL,'STANDARD',NULL,0.9500,7.6000,NULL,NULL,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(20,7,40,15,4.000000,1,'J1-J4',40,NULL,'STANDARD',NULL,8.5000,34.0000,NULL,NULL,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,1,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(21,9,10,18,1.000000,1,'ENC1',10,NULL,'STANDARD',NULL,28.0000,28.0000,NULL,NULL,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,1,NULL,NULL,NULL,'mech.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(22,16,10,20,3.000000,1,'CBL1-3',10,NULL,'STANDARD',NULL,1.2000,3.6000,NULL,NULL,100.00,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,0,NULL,NULL,NULL,'mech.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25');
/*!40000 ALTER TABLE `bom_line_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `component`
--

DROP TABLE IF EXISTS `component`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `component` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `part_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `part_revision` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'A',
  `part_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `part_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `material_class_id` bigint unsigned DEFAULT NULL,
  `preferred_supplier_id` bigint unsigned DEFAULT NULL,
  `alternate_supplier_id` bigint unsigned DEFAULT NULL,
  `uom_id` bigint unsigned DEFAULT NULL,
  `unit_cost` decimal(18,4) DEFAULT NULL,
  `standard_cost` decimal(18,4) DEFAULT NULL,
  `currency_code` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'USD',
  `weight_grams` decimal(12,4) DEFAULT NULL,
  `length_mm` decimal(12,4) DEFAULT NULL,
  `width_mm` decimal(12,4) DEFAULT NULL,
  `height_mm` decimal(12,4) DEFAULT NULL,
  `color_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `material_grade` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tensile_strength_mpa` decimal(10,2) DEFAULT NULL,
  `thermal_rating_c` decimal(8,2) DEFAULT NULL,
  `voltage_rating_v` decimal(10,2) DEFAULT NULL,
  `current_rating_a` decimal(10,2) DEFAULT NULL,
  `ip_rating` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `operating_temp_min_c` decimal(8,2) DEFAULT NULL,
  `operating_temp_max_c` decimal(8,2) DEFAULT NULL,
  `shelf_life_days` int DEFAULT NULL,
  `storage_conditions` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hazmat_class` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rohs_compliant` tinyint(1) DEFAULT NULL,
  `reach_compliant` tinyint(1) DEFAULT NULL,
  `country_of_origin` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hs_tariff_code` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `drawing_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `drawing_revision` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `datasheet_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `manufacturer_part_no` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `manufacturer_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lifecycle_status` enum('ACTIVE','OBSOLETE','NRND','NEW','PROTOTYPE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `procurement_type` enum('BUY','MAKE','CONSIGNED','PHANTOM') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'BUY',
  `abc_classification` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `minimum_order_qty` decimal(12,4) DEFAULT NULL,
  `reorder_point` decimal(12,4) DEFAULT NULL,
  `safety_stock` decimal(12,4) DEFAULT NULL,
  `inspection_level` enum('NONE','INCOMING','FULL') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `part_number` (`part_number`),
  KEY `material_class_id` (`material_class_id`),
  KEY `alternate_supplier_id` (`alternate_supplier_id`),
  KEY `uom_id` (`uom_id`),
  KEY `idx_component_pn` (`part_number`),
  KEY `idx_component_supplier` (`preferred_supplier_id`),
  CONSTRAINT `component_ibfk_1` FOREIGN KEY (`material_class_id`) REFERENCES `material_class` (`id`),
  CONSTRAINT `component_ibfk_2` FOREIGN KEY (`preferred_supplier_id`) REFERENCES `supplier` (`id`),
  CONSTRAINT `component_ibfk_3` FOREIGN KEY (`alternate_supplier_id`) REFERENCES `supplier` (`id`),
  CONSTRAINT `component_ibfk_4` FOREIGN KEY (`uom_id`) REFERENCES `unit_of_measure` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `component`
--

LOCK TABLES `component` WRITE;
/*!40000 ALTER TABLE `component` DISABLE KEYS */;
INSERT INTO `component` VALUES (1,'PN-SOC-001','A','ARM Cortex-A55 SoC 1.8GHz Quad-Core','Industrial-grade SoC with integrated Gigabit Ethernet MAC, USB 3.0, PCIe 2.0, CAN 2.0',3,1,NULL,1,48.5000,NULL,'USD',14.0000,14.0000,14.0000,1.6000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,85.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'AM6442BZCEAAP1','Texas Instruments','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(2,'PN-MEM-001','A','LPDDR4 4GB RAM Module','4GB x32 LPDDR4 SDRAM, 3200Mbps, 96-ball BGA',2,2,NULL,1,18.2000,NULL,'USD',0.8000,9.0000,9.0000,1.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,85.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'MT53E512M32D2NP-046','Micron','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(3,'PN-FLS-001','A','32GB eMMC 5.1 Industrial Flash','32GB eMMC 5.1 HS400, industrial grade, -40°C to 85°C',2,2,NULL,1,12.7500,NULL,'USD',0.6000,11.5000,13.0000,1.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,85.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'FEMDNN032G-88A19','Samsung','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(4,'PN-MOD-4G','A','Cat-M1/NB-IoT/LTE-M Cellular Module','Multi-band LTE module, USB 2.0 + UART host interface, embedded SIM ready, FCC/CE certified',11,8,NULL,1,28.4000,NULL,'USD',6.5000,30.0000,24.0000,3.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,85.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'EG21-G-MINIPCIE','Quectel','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(5,'PN-MOD-WB','A','Wi-Fi 6 + BLE 5.3 Combo Module','802.11ax 2.4/5GHz + BLE 5.3, PCIe/SDIO/UART interface, FCC/CE/IC certified',11,8,NULL,1,14.8000,NULL,'USD',3.2000,18.0000,14.0000,2.4000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,85.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'WB5X-SDIO','Laird Connectivity','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(6,'PN-PHY-001','A','Gigabit Ethernet PHY Transceiver','IEEE 802.3 1000BASE-T/100BASE-TX, RGMII interface, EEE compliant, industrial temp',4,1,NULL,1,4.2000,NULL,'USD',0.5000,7.0000,7.0000,0.9000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,85.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'DP83867ISRGZ','Texas Instruments','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(7,'PN-TR-485','A','RS-485/422 Half/Full Duplex Transceiver','±15kV ESD, 50Mbps, 1/8-unit-load, industrial -40 to 125°C',4,1,NULL,1,1.8500,NULL,'USD',0.1000,5.0000,4.0000,0.9000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,125.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'THVD1450DSGR','Texas Instruments','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(8,'PN-OPT-001','A','High-Speed Digital Optocoupler 10Mbps','10Mbps CMOS output, 2500Vrms isolation, 8-SOIC, wide temp',2,2,NULL,1,0.9500,NULL,'USD',0.1000,5.0000,4.0000,1.5000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,85.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'TLP2362(TP,E)','Toshiba','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(9,'PN-BUCK-001','A','Synchronous Step-Down DC-DC Controller 4A','4A, 4.5-60V input, adjustable output, 95% efficiency, EN/AECQ100',5,1,NULL,1,3.4000,NULL,'USD',0.1000,3.0000,3.0000,0.9000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,125.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'TPS54360BDDAR','Texas Instruments','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(10,'PN-LDO-001','A','300mA Ultra-Low Noise LDO Regulator','300mA, 1.5-5.5V input, adjustable, 6μVrms noise, 5-SOT23',5,2,NULL,1,0.6500,NULL,'USD',0.0200,1.6000,1.6000,0.6000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,125.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'LD39020PU33R','STMicroelectronics','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(11,'PN-CAP-100N','A','100nF 50V X7R MLCC 0402','100nF ±10% 50V X7R ceramic capacitor 0402 (1005 metric)',8,5,NULL,1,0.0080,NULL,'USD',0.0010,1.0000,0.5000,0.5000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-55.00,125.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'GRM155R71H104KE14D','Murata','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(12,'PN-CAP-10U','A','10µF 25V X5R MLCC 0805','10µF ±20% 25V X5R ceramic capacitor 0805 (2012 metric)',8,5,NULL,1,0.0420,NULL,'USD',0.0040,2.0000,1.2500,0.9500,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-55.00,85.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'GRM21BR61E106KA73L','Murata','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(13,'PN-RES-10K','A','10KΩ ±1% 0.1W Thick Film Resistor 0402','10kΩ ±1% 100mW AEC-Q200 0402 thick film',7,4,NULL,1,0.0030,NULL,'USD',0.0010,1.0000,0.5000,0.3500,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-55.00,155.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'RC0402FR-0710KL','Yageo','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(14,'PN-CONN-RJ45','A','Industrial RJ45 Jack with Magnetics','Shielded RJ45 integrated 10/100/1000 magnetics, IP20, right-angle THT',10,3,NULL,1,2.8000,NULL,'USD',5.0000,16.0000,14.0000,13.5000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,85.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'74990111121','Würth Elektronik','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(15,'PN-CONN-M12','A','M12 A-Code 8-Pin Industrial Connector Panel Mount','IP67 M12 8-pin A-code panel mount socket, stainless steel, screw terminal',10,6,NULL,1,8.5000,NULL,'USD',32.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,85.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'T4110512041-000','Phoenix Contact','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(16,'PN-PCB-MB','A','EC-5000 Main Processing Board Bare PCB','4-layer 155x100mm FR4 PCB, 1oz copper, ENIG finish, impedance controlled',13,NULL,NULL,1,22.0000,NULL,'USD',48.0000,155.0000,100.0000,1.6000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'PCB-EC5000-MB-R2','Spectrum PCB','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(17,'PN-PCB-IO','A','EC-5000 I/O Expansion Board Bare PCB','2-layer 80x60mm FR4 PCB, 1oz copper, HASL finish',13,NULL,NULL,1,8.5000,NULL,'USD',18.0000,80.0000,60.0000,1.6000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'PCB-EC5000-IO-R1','Spectrum PCB','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'smt.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(18,'PN-ENC-001','A','IP67 Die-Cast Aluminum Enclosure 175x125x60mm','IP67 die-cast aluminum, DIN-rail mounting integrated, M3 stainless inserts, powder coated gray RAL7035',14,NULL,NULL,1,28.0000,NULL,'USD',520.0000,175.0000,125.0000,60.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,85.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'EC-DC-175-125-60-AL','Bopla','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'mech.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(19,'PN-XFMR-001','A','100W Power Transformer 85-264VAC:24VDC','Universal input switching transformer, 100W, potted, UL/CE approved',5,NULL,NULL,1,14.2000,NULL,'USD',185.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-20.00,70.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'TX-100W-24V','Talema','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'pwr.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(20,'PN-CBL-FLAT','A','200mm 10-way IDC Flat Cable Assembly','200mm 10-way 1.27mm pitch IDC flat cable, UL2651 28AWG gray',15,9,NULL,1,1.2000,NULL,'USD',4.0000,200.0000,13.0000,3.0000,NULL,NULL,NULL,NULL,NULL,NULL,NULL,-40.00,85.00,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,'FC10-200MM-GRY','Belden','ACTIVE','BUY',NULL,NULL,NULL,NULL,NULL,'mech.eng@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25');
/*!40000 ALTER TABLE `component` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material_class`
--

DROP TABLE IF EXISTS `material_class`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `material_class` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `class_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `class_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_class_id` bigint unsigned DEFAULT NULL,
  `hazmat_flag` tinyint(1) DEFAULT '0',
  `rohs_flag` tinyint(1) DEFAULT '0',
  `reach_flag` tinyint(1) DEFAULT '0',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `class_code` (`class_code`),
  KEY `parent_class_id` (`parent_class_id`),
  CONSTRAINT `material_class_ibfk_1` FOREIGN KEY (`parent_class_id`) REFERENCES `material_class` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `material_class`
--

LOCK TABLES `material_class` WRITE;
/*!40000 ALTER TABLE `material_class` DISABLE KEYS */;
INSERT INTO `material_class` VALUES (1,'ELEC','Electronics',NULL,0,1,0,NULL,1,'2026-05-13 18:19:41'),(2,'IC','Integrated Circuits',1,0,1,0,NULL,1,'2026-05-13 18:19:41'),(3,'MCU','Microcontrollers',2,0,1,0,NULL,1,'2026-05-13 18:19:41'),(4,'COMM-IC','Communications ICs',2,0,1,0,NULL,1,'2026-05-13 18:19:41'),(5,'PWR-IC','Power Management ICs',2,0,1,0,NULL,1,'2026-05-13 18:19:41'),(6,'PASSIVE','Passives',1,0,1,0,NULL,1,'2026-05-13 18:19:41'),(7,'RESIST','Resistors',6,0,1,0,NULL,1,'2026-05-13 18:19:41'),(8,'CAP','Capacitors',6,0,1,0,NULL,1,'2026-05-13 18:19:41'),(9,'INDUCT','Inductors',6,0,1,0,NULL,1,'2026-05-13 18:19:41'),(10,'CONN','Connectors',1,0,1,0,NULL,1,'2026-05-13 18:19:41'),(11,'MODULE','RF & Wireless Modules',1,0,1,0,NULL,1,'2026-05-13 18:19:41'),(12,'MECH','Mechanical',NULL,0,0,0,NULL,1,'2026-05-13 18:19:41'),(13,'PCB','Printed Circuit Board',12,0,1,0,NULL,1,'2026-05-13 18:19:41'),(14,'ENCL','Enclosures',12,0,0,0,NULL,1,'2026-05-13 18:19:41'),(15,'CABLE','Cables & Harnesses',NULL,0,1,0,NULL,1,'2026-05-13 18:19:41'),(16,'LABEL','Labels & Markings',NULL,0,0,0,NULL,1,'2026-05-13 18:19:41'),(17,'PACKING','Packaging',NULL,0,0,0,NULL,1,'2026-05-13 18:19:41'),(18,'FIRMWARE','Firmware & Software',NULL,0,0,0,NULL,1,'2026-05-13 18:19:41');
/*!40000 ALTER TABLE `material_class` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_family` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_line` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `model_number` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `platform_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `target_market` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_category` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `regulatory_marks` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `launch_date` date DEFAULT NULL,
  `end_of_life_date` date DEFAULT NULL,
  `product_manager` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `design_owner` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lifecycle_phase` enum('CONCEPT','DESIGN','PILOT','PRODUCTION','PHASE_OUT','EOL') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PRODUCTION',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_code` (`product_code`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,'EDGE-GW-5000','EdgeConnect 5000 Industrial IoT Gateway','EdgeConnect','Industrial IoT','EC-5000','EDGE-V5','Industrial Automation','IoT Gateway',NULL,'CE,FCC,UL,IP67',NULL,NULL,NULL,NULL,'PRODUCTION',1,'2026-05-13 18:19:41','2026-05-13 18:19:41'),(2,'EDGE-GW-5100','EdgeConnect 5100 Heavy-Duty IoT Gateway','EdgeConnect','Industrial IoT','EC-5100','EDGE-V5','Oil & Gas','IoT Gateway',NULL,'CE,FCC,ATEX,IP68',NULL,NULL,NULL,NULL,'PILOT',1,'2026-05-13 18:19:41','2026-05-13 18:19:41'),(3,'EDGE-GW-5200','EdgeConnect 5200 Rail-Grade Gateway','EdgeConnect','Industrial IoT','EC-5200','EDGE-V5','Rail & Transit','IoT Gateway',NULL,'CE,EN50155,IP65',NULL,NULL,NULL,NULL,'DESIGN',1,'2026-05-13 18:19:41','2026-05-13 18:19:41'),(4,'EDGE-PSU-100W','EdgePower 100W DIN-Rail PSU','EdgePower','Power Systems','EP-100W','PWRV2','Industrial','Power Supply',NULL,'CE,UL,TUV',NULL,NULL,NULL,NULL,'PRODUCTION',1,'2026-05-13 18:19:41','2026-05-13 18:19:41'),(5,'EDGE-ANT-4G','EdgeAntenna 4G/LTE External Antenna','EdgeAntenna','Wireless','EA-4G','ANTV1','Industrial IoT','Antenna',NULL,'CE,FCC',NULL,NULL,NULL,NULL,'PRODUCTION',1,'2026-05-13 18:19:41','2026-05-13 18:19:41');
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier`
--

DROP TABLE IF EXISTS `supplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supplier` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `supplier_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `legal_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `trade_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duns_number` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `supplier_tier` enum('TIER1','TIER2','TIER3','SPOT') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'TIER2',
  `risk_rating` enum('LOW','MEDIUM','HIGH','CRITICAL') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country_of_origin` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `headquarters_city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `primary_contact` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_email` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_phone` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lead_time_days` int DEFAULT NULL,
  `payment_terms` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currency_code` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'USD',
  `certifications` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_approved` tinyint(1) DEFAULT '0',
  `approved_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `supplier_code` (`supplier_code`),
  UNIQUE KEY `duns_number` (`duns_number`),
  KEY `idx_supplier_code` (`supplier_code`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier`
--

LOCK TABLES `supplier` WRITE;
/*!40000 ALTER TABLE `supplier` DISABLE KEYS */;
INSERT INTO `supplier` VALUES (1,'SUP-001','Texas Instruments Inc.','TI','006932717',NULL,'TIER1','LOW','US','Dallas TX','John Liu','jliu@ti.example.com',NULL,21,'Net30','USD','ISO9001,IATF16949,AEC-Q100',NULL,1,'procurement@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(2,'SUP-002','STMicroelectronics N.V.','ST','271837154',NULL,'TIER1','LOW','NL','Geneva','Marie Dupont','mdupont@st.example.com',NULL,28,'Net45','USD','ISO9001,ISO14001,AEC-Q100',NULL,1,'procurement@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(3,'SUP-003','Molex LLC','Molex','042569791',NULL,'TIER1','LOW','US','Lisle IL','Sam Park','spark@molex.example.com',NULL,14,'Net30','USD','ISO9001,IATF16949',NULL,1,'procurement@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(4,'SUP-004','Würth Elektronik GmbH','Würth','315629841',NULL,'TIER2','LOW','DE','Waldenburg','Hans Braun','hbraun@we.example.com',NULL,21,'Net30','EUR','ISO9001,ISO14001',NULL,1,'procurement@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(5,'SUP-005','Murata Manufacturing Co.','Murata','692154870',NULL,'TIER1','LOW','JP','Kyoto','Kenji Sato','ksato@murata.example.com',NULL,35,'Net45','USD','ISO9001,AEC-Q200',NULL,1,'procurement@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(6,'SUP-006','Amphenol Corp.','Amphenol','056984013',NULL,'TIER1','LOW','US','Wallingford CT','Lisa Chen','lchen@amphenol.example.com',NULL,28,'Net30','USD','ISO9001,IATF16949',NULL,1,'procurement@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(7,'SUP-007','Marvell Technology Inc.','Marvell','110493821',NULL,'TIER1','MEDIUM','US','Santa Clara CA','Dave Wang','dwang@marvell.example.com',NULL,42,'Net60','USD','ISO9001',NULL,1,'procurement@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(8,'SUP-008','Laird Connectivity','Laird','204871539',NULL,'TIER2','LOW','GB','London','Tom Hawkins','thawkins@laird.example.com',NULL,21,'Net30','USD','ISO9001,FCC,CE',NULL,1,'procurement@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(9,'SUP-009','Belden Inc.','Belden','008127634',NULL,'TIER2','LOW','US','Chicago IL','Amy Ross','aross@belden.example.com',NULL,14,'Net30','USD','ISO9001,UL',NULL,1,'procurement@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25'),(10,'SUP-010','Phoenix Contact GmbH','Phoenix','317284910',NULL,'TIER2','LOW','DE','Blomberg','Klaus Richter','krichter@phoenixc.example.com',NULL,21,'Net30','EUR','ISO9001,UL,CE',NULL,1,'procurement@bomiq.com',NULL,1,'2026-05-13 18:19:41','2026-05-16 11:30:25');
/*!40000 ALTER TABLE `supplier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unit_of_measure`
--

DROP TABLE IF EXISTS `unit_of_measure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `unit_of_measure` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uom_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `uom_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `uom_category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `base_unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `conversion_factor` decimal(18,6) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uom_code` (`uom_code`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unit_of_measure`
--

LOCK TABLES `unit_of_measure` WRITE;
/*!40000 ALTER TABLE `unit_of_measure` DISABLE KEYS */;
INSERT INTO `unit_of_measure` VALUES (1,'EA','Each','Discrete','EA',1.000000,1,'2026-05-13 18:19:41','2026-05-13 18:19:41'),(2,'KG','Kilogram','Mass','KG',1.000000,1,'2026-05-13 18:19:41','2026-05-13 18:19:41'),(3,'GR','Gram','Mass','KG',0.001000,1,'2026-05-13 18:19:41','2026-05-13 18:19:41'),(4,'MM','Millimeter','Length','M',0.001000,1,'2026-05-13 18:19:41','2026-05-13 18:19:41'),(5,'M','Meter','Length','M',1.000000,1,'2026-05-13 18:19:41','2026-05-13 18:19:41'),(6,'LTR','Liter','Volume','LTR',1.000000,1,'2026-05-13 18:19:41','2026-05-13 18:19:41'),(7,'ML','Milliliter','Volume','LTR',0.001000,1,'2026-05-13 18:19:41','2026-05-13 18:19:41'),(8,'MTR','Meter (wire)','Length','M',1.000000,1,'2026-05-13 18:19:41','2026-05-13 18:19:41'),(9,'PKT','Packet','Discrete','EA',1.000000,1,'2026-05-13 18:19:41','2026-05-13 18:19:41'),(10,'SET','Set','Discrete','EA',1.000000,1,'2026-05-13 18:19:41','2026-05-13 18:19:41');
/*!40000 ALTER TABLE `unit_of_measure` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-16 11:31:44
