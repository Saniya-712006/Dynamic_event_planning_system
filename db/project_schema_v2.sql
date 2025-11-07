-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: dynamic_event_planning
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `allocated`
--

DROP TABLE IF EXISTS `allocated`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `allocated` (
  `eid` varchar(5) NOT NULL,
  `rid` varchar(5) NOT NULL,
  `allocated_quantity` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`eid`,`rid`),
  KEY `rid` (`rid`),
  CONSTRAINT `allocated_ibfk_1` FOREIGN KEY (`eid`) REFERENCES `event` (`eid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `allocated_ibfk_2` FOREIGN KEY (`rid`) REFERENCES `resource` (`rid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `allocated`
--

LOCK TABLES `allocated` WRITE;
/*!40000 ALTER TABLE `allocated` DISABLE KEYS */;
INSERT INTO `allocated` VALUES ('E005','R004',12),('E005','R005',250),('E007','R001',3);
/*!40000 ALTER TABLE `allocated` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Update_Used_Quantity_Insert` AFTER INSERT ON `allocated` FOR EACH ROW BEGIN
    UPDATE resource
    SET used_quantity = used_quantity + NEW.allocated_quantity
    WHERE rid = NEW.rid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Update_Used_Quantity_Update` AFTER UPDATE ON `allocated` FOR EACH ROW BEGIN
    
    UPDATE resource
    SET used_quantity = used_quantity - OLD.allocated_quantity
    WHERE rid = OLD.rid;
    
    
    UPDATE resource
    SET used_quantity = used_quantity + NEW.allocated_quantity
    WHERE rid = NEW.rid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Update_Used_Quantity_Delete` AFTER DELETE ON `allocated` FOR EACH ROW BEGIN
    UPDATE resource
    SET used_quantity = used_quantity - OLD.allocated_quantity
    WHERE rid = OLD.rid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `attends`
--

DROP TABLE IF EXISTS `attends`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attends` (
  `sid` varchar(5) NOT NULL,
  `eid` varchar(5) NOT NULL,
  `status` enum('P','A') NOT NULL,
  PRIMARY KEY (`sid`,`eid`),
  KEY `fk_attends_eid` (`eid`),
  CONSTRAINT `fk_attends_eid` FOREIGN KEY (`eid`) REFERENCES `event` (`eid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_attends_sid` FOREIGN KEY (`sid`) REFERENCES `students` (`sid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attends`
--

LOCK TABLES `attends` WRITE;
/*!40000 ALTER TABLE `attends` DISABLE KEYS */;
INSERT INTO `attends` VALUES ('S001','E001','P'),('S001','E005','P'),('S001','E007','P'),('S002','E002','A'),('S003','E005','P'),('S004','E003','P'),('S004','E004','P'),('S006','E004','P'),('S006','E008','A'),('S007','E001','P'),('S007','E007','P');
/*!40000 ALTER TABLE `attends` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Before_Student_Attends_Insert` BEFORE INSERT ON `attends` FOR EACH ROW BEGIN
    DECLARE conflict_count INT;
    DECLARE new_event_date DATE;
    DECLARE new_event_time TIME;

    
    SELECT actual_date, actual_time INTO new_event_date, new_event_time
    FROM event
    WHERE eid = NEW.eid;

    
    SELECT COUNT(*) INTO conflict_count
    FROM attends a
    JOIN event e ON a.eid = e.eid
    WHERE a.sid = NEW.sid                 
      AND e.actual_date = new_event_date  
      AND e.actual_time = new_event_time; 

    
    IF conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Student is already registered for another event at this exact time.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Prevent_Past_Event_Registration` BEFORE INSERT ON `attends` FOR EACH ROW BEGIN
    DECLARE event_date DATE;

    
    SELECT actual_date INTO event_date
    FROM event
    WHERE eid = NEW.eid;

    
    IF event_date < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Cannot register for an event that has already taken place.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Validate_Attendance_Update` BEFORE UPDATE ON `attends` FOR EACH ROW BEGIN
    DECLARE event_date DATE;

    
    IF NEW.status = 'A' AND OLD.status <> 'A' THEN
        
        
        SELECT actual_date INTO event_date
        FROM event
        WHERE eid = NEW.eid;

        
        IF event_date > CURDATE() THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Cannot mark attendance for an event that has not yet occurred.';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `club`
--

DROP TABLE IF EXISTS `club`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `club` (
  `cid` varchar(5) NOT NULL,
  `cname` varchar(15) NOT NULL,
  `description` text,
  `domain_name` varchar(15) NOT NULL,
  PRIMARY KEY (`cid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `club`
--

LOCK TABLES `club` WRITE;
/*!40000 ALTER TABLE `club` DISABLE KEYS */;
INSERT INTO `club` VALUES ('C001','CodeGeeks','A club for competitive coding and development.','Technical'),('C002','Orators','A public speaking and debate club for students.','Literary'),('C003','Aperture','A club for photography and visual arts.','Cultural'),('C004','Melodia','The university music and choir club.','Cultural');
/*!40000 ALTER TABLE `club` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event`
--

DROP TABLE IF EXISTS `event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event` (
  `eid` varchar(5) NOT NULL,
  `ename` varchar(10) NOT NULL,
  `etype` varchar(10) DEFAULT 'GENERAL',
  `opt_date` date NOT NULL,
  `actual_date` date NOT NULL,
  `opt_time` time NOT NULL,
  `actual_time` time NOT NULL,
  `dept` varchar(10) DEFAULT 'GENERAL',
  PRIMARY KEY (`eid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event`
--

LOCK TABLES `event` WRITE;
/*!40000 ALTER TABLE `event` DISABLE KEYS */;
INSERT INTO `event` VALUES ('E001','HackFest','Technical','2025-11-20','2025-11-20','09:00:00','09:15:00','CSE'),('E002','DebateCon','Literary','2025-11-25','2025-11-25','11:00:00','11:00:00','GENERAL'),('E003','CaptureIt','Cultural','2025-11-30','2025-11-30','10:00:00','10:00:00','GENERAL'),('E004','StageRight','Cultural','2025-12-05','2025-12-05','17:00:00','17:00:00','GENERAL'),('E005','CodeRelay','Technical','2025-12-10','2025-12-10','09:00:00','09:00:00','CSE'),('E007','horcrux','Technical','2025-11-07','2025-11-07','10:20:00','10:20:00','CSE'),('E008','AT','Cultural','2025-11-06','2025-11-06','09:35:00','09:35:00','GENERAL');
/*!40000 ALTER TABLE `event` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `faculty`
--

DROP TABLE IF EXISTS `faculty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `faculty` (
  `fid` varchar(5) NOT NULL,
  `ffname` varchar(15) NOT NULL,
  `flname` varchar(15) DEFAULT NULL,
  `dept` varchar(10) NOT NULL,
  PRIMARY KEY (`fid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faculty`
--

LOCK TABLES `faculty` WRITE;
/*!40000 ALTER TABLE `faculty` DISABLE KEYS */;
INSERT INTO `faculty` VALUES ('F001','Rajesh','Gupta','CSE'),('F002','Sunita','Sharma','ECE'),('F003','Vikram','Singh','CSE');
/*!40000 ALTER TABLE `faculty` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback` (
  `fbid` varchar(5) NOT NULL,
  `rating` int DEFAULT '3',
  `event_id` varchar(5) NOT NULL,
  `comment` text,
  PRIMARY KEY (`fbid`),
  KEY `event_id` (`event_id`),
  CONSTRAINT `feedback_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `event` (`eid`),
  CONSTRAINT `chk_rating` CHECK (((`rating` >= 1) and (`rating` <= 5)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback`
--

LOCK TABLES `feedback` WRITE;
/*!40000 ALTER TABLE `feedback` DISABLE KEYS */;
INSERT INTO `feedback` VALUES ('FB01',5,'E001','Excellent management and informative!'),('FB02',4,'E002','The event was great, timings could be better.'),('FB03',4,'E001','Good event, but the mic kept cutting out.'),('FB04',5,'E002','Loved the topics. Very engaging speakers!'),('FB05',4,'E002','Good event , enjoyed it '),('FB06',5,'E008','Amazing event once in a lifetime opportunity !!');
/*!40000 ALTER TABLE `feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `funded`
--

DROP TABLE IF EXISTS `funded`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `funded` (
  `eid` varchar(5) NOT NULL,
  `spid` varchar(5) NOT NULL,
  PRIMARY KEY (`eid`,`spid`),
  KEY `spid` (`spid`),
  CONSTRAINT `funded_ibfk_1` FOREIGN KEY (`eid`) REFERENCES `event` (`eid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `funded_ibfk_2` FOREIGN KEY (`spid`) REFERENCES `sponsor` (`spid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `funded`
--

LOCK TABLES `funded` WRITE;
/*!40000 ALTER TABLE `funded` DISABLE KEYS */;
INSERT INTO `funded` VALUES ('E001','SP001'),('E005','SP001'),('E002','SP002'),('E003','SP003'),('E004','SP003');
/*!40000 ALTER TABLE `funded` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guides`
--

DROP TABLE IF EXISTS `guides`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guides` (
  `sid` varchar(5) NOT NULL,
  `fid` varchar(5) NOT NULL,
  `role` varchar(15) DEFAULT 'MENTOR',
  PRIMARY KEY (`sid`,`fid`),
  KEY `fid` (`fid`),
  CONSTRAINT `guides_ibfk_1` FOREIGN KEY (`sid`) REFERENCES `students` (`sid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `guides_ibfk_2` FOREIGN KEY (`fid`) REFERENCES `faculty` (`fid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guides`
--

LOCK TABLES `guides` WRITE;
/*!40000 ALTER TABLE `guides` DISABLE KEYS */;
INSERT INTO `guides` VALUES ('S001','F001','MENTOR'),('S002','F002','MENTOR'),('S003','F003','MENTOR'),('S004','F002','MENTOR');
/*!40000 ALTER TABLE `guides` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `is_part_of`
--

DROP TABLE IF EXISTS `is_part_of`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `is_part_of` (
  `sid` varchar(5) NOT NULL,
  `cid` varchar(5) NOT NULL,
  `role` varchar(15) DEFAULT 'GENERAL',
  PRIMARY KEY (`sid`,`cid`),
  KEY `cid` (`cid`),
  CONSTRAINT `is_part_of_ibfk_1` FOREIGN KEY (`sid`) REFERENCES `students` (`sid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `is_part_of_ibfk_2` FOREIGN KEY (`cid`) REFERENCES `club` (`cid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `is_part_of`
--

LOCK TABLES `is_part_of` WRITE;
/*!40000 ALTER TABLE `is_part_of` DISABLE KEYS */;
INSERT INTO `is_part_of` VALUES ('S001','C001','Coordinator'),('S002','C002','Member'),('S003','C001','Member'),('S003','C003','Coordinator'),('S004','C003','Coordinator');
/*!40000 ALTER TABLE `is_part_of` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `organizes`
--

DROP TABLE IF EXISTS `organizes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `organizes` (
  `cid` varchar(5) NOT NULL,
  `eid` varchar(5) NOT NULL,
  PRIMARY KEY (`cid`,`eid`),
  KEY `fk_org_eid` (`eid`),
  CONSTRAINT `fk_org_cid` FOREIGN KEY (`cid`) REFERENCES `club` (`cid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_org_eid` FOREIGN KEY (`eid`) REFERENCES `event` (`eid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `organizes`
--

LOCK TABLES `organizes` WRITE;
/*!40000 ALTER TABLE `organizes` DISABLE KEYS */;
INSERT INTO `organizes` VALUES ('C001','E001'),('C002','E002'),('C003','E003'),('C004','E004'),('C001','E005'),('C003','E007'),('C002','E008');
/*!40000 ALTER TABLE `organizes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource`
--

DROP TABLE IF EXISTS `resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `resource` (
  `rid` varchar(5) NOT NULL,
  `type` varchar(12) DEFAULT 'GENERAL',
  `pred_quantity` int DEFAULT NULL,
  `used_quantity` int DEFAULT NULL,
  PRIMARY KEY (`rid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource`
--

LOCK TABLES `resource` WRITE;
/*!40000 ALTER TABLE `resource` DISABLE KEYS */;
INSERT INTO `resource` VALUES ('R001','Projector',10,12),('R002','Microphone',15,14),('R003','Speakers',4,5),('R004','Furniture',300,12),('R005','Chairs',300,250);
/*!40000 ALTER TABLE `resource` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sponsor`
--

DROP TABLE IF EXISTS `sponsor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sponsor` (
  `spid` varchar(5) NOT NULL,
  `sname` varchar(15) NOT NULL,
  `contri_type` varchar(10) NOT NULL,
  `contri_amt` int NOT NULL,
  PRIMARY KEY (`spid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sponsor`
--

LOCK TABLES `sponsor` WRITE;
/*!40000 ALTER TABLE `sponsor` DISABLE KEYS */;
INSERT INTO `sponsor` VALUES ('SP001','TechCorp','Monetary',50000),('SP002','BookWorm','In-Kind',10000),('SP003','CreativeInc','Monetary',25000),('SP004','PES','Monetary',30000);
/*!40000 ALTER TABLE `sponsor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_preferences`
--

DROP TABLE IF EXISTS `student_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_preferences` (
  `sid` varchar(5) NOT NULL,
  `etype` varchar(10) NOT NULL,
  PRIMARY KEY (`sid`,`etype`),
  CONSTRAINT `fk_pref_sid` FOREIGN KEY (`sid`) REFERENCES `students` (`sid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_preferences`
--

LOCK TABLES `student_preferences` WRITE;
/*!40000 ALTER TABLE `student_preferences` DISABLE KEYS */;
INSERT INTO `student_preferences` VALUES ('S001','Technical'),('S002','Literary'),('S003','Cultural'),('S003','Technical'),('S004','Cultural');
/*!40000 ALTER TABLE `student_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `sid` varchar(5) NOT NULL,
  `fname` varchar(15) NOT NULL,
  `lname` varchar(15) DEFAULT NULL,
  `department` varchar(10) NOT NULL,
  `sem` int NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`sid`),
  CONSTRAINT `chk_sem` CHECK (((`sem` >= 1) and (`sem` <= 8)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES ('S001','Aarav','Kumar','CSE',5,'scrypt:32768:8:1$cWUoYIx9JUTbdH9k$da456074bb328c4226efeec8ab057e97acefc9fb696032e2f3f91edb17e56770b82a1973303686ba98115ec4fc0c8a9df04ff8e51fcc889722af130f476edfc3'),('S002','Priya','Singh','ECE',3,'scrypt:32768:8:1$cWUoYIx9JUTbdH9k$da456074bb328c4226efeec8ab057e97acefc9fb696032e2f3f91edb17e56770b82a1973303686ba98115ec4fc0c8a9df04ff8e51fcc889722af130f476edfc3'),('S003','Ravi','Sharma','CSE',5,'scrypt:32768:8:1$cWUoYIx9JUTbdH9k$da456074bb328c4226efeec8ab057e97acefc9fb696032e2f3f91edb17e56770b82a1973303686ba98115ec4fc0c8a9df04ff8e51fcc889722af130f476edfc3'),('S004','Meera','Iyer','ECE',3,'scrypt:32768:8:1$cWUoYIx9JUTbdH9k$da456074bb328c4226efeec8ab057e97acefc9fb696032e2f3f91edb17e56770b82a1973303686ba98115ec4fc0c8a9df04ff8e51fcc889722af130f476edfc3'),('S005','Shalmali ','Ram','CSE',5,'scrypt:32768:8:1$cWUoYIx9JUTbdH9k$da456074bb328c4226efeec8ab057e97acefc9fb696032e2f3f91edb17e56770b82a1973303686ba98115ec4fc0c8a9df04ff8e51fcc889722af130f476edfc3'),('S006','Alice','Mathew','ECE',3,'scrypt:32768:8:1$cWUoYIx9JUTbdH9k$da456074bb328c4226efeec8ab057e97acefc9fb696032e2f3f91edb17e56770b82a1973303686ba98115ec4fc0c8a9df04ff8e51fcc889722af130f476edfc3'),('S007','Peter ','Fernandis','CIVIL',3,'scrypt:32768:8:1$4UrRhyb2kqt8gy1y$daf589449de424f344750f7a348f21c2f9ddb88a0abb8d4e0ae0de7c0ed7d1540b3fa3821151c91bc85dcdbaa9641e47f759f950883a2479af2d23c4ab8f2303');
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_attends_detailed`
--

DROP TABLE IF EXISTS `v_attends_detailed`;
/*!50001 DROP VIEW IF EXISTS `v_attends_detailed`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_attends_detailed` AS SELECT 
 1 AS `student_id`,
 1 AS `student_first_name`,
 1 AS `student_last_name`,
 1 AS `event_id`,
 1 AS `event_name`,
 1 AS `attendance_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_club_membership`
--

DROP TABLE IF EXISTS `v_club_membership`;
/*!50001 DROP VIEW IF EXISTS `v_club_membership`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_club_membership` AS SELECT 
 1 AS `student_id`,
 1 AS `student_first_name`,
 1 AS `student_last_name`,
 1 AS `club_id`,
 1 AS `club_name`,
 1 AS `role`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_event_summary`
--

DROP TABLE IF EXISTS `v_event_summary`;
/*!50001 DROP VIEW IF EXISTS `v_event_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_event_summary` AS SELECT 
 1 AS `eid`,
 1 AS `ename`,
 1 AS `actual_date`,
 1 AS `actual_time`,
 1 AS `club_name`,
 1 AS `registered_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_feedback_detailed`
--

DROP TABLE IF EXISTS `v_feedback_detailed`;
/*!50001 DROP VIEW IF EXISTS `v_feedback_detailed`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_feedback_detailed` AS SELECT 
 1 AS `feedback_id`,
 1 AS `event_id`,
 1 AS `event_name`,
 1 AS `rating`,
 1 AS `comment`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `venue`
--

DROP TABLE IF EXISTS `venue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venue` (
  `vid` varchar(5) NOT NULL,
  `vname` varchar(25) NOT NULL,
  `capacity` int DEFAULT NULL,
  `floor` int NOT NULL,
  `room` varchar(4) DEFAULT NULL,
  `block` varchar(15) NOT NULL,
  PRIMARY KEY (`vid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venue`
--

LOCK TABLES `venue` WRITE;
/*!40000 ALTER TABLE `venue` DISABLE KEYS */;
INSERT INTO `venue` VALUES ('V001','Auditorium',500,1,'G11','Main'),('V002','Seminar Hall',120,2,'205','Admin'),('V003','Open Air Theatre',800,0,'OAT','BE'),('V004','SEMINAR HALL',120,2,'','BE');
/*!40000 ALTER TABLE `venue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'dynamic_event_planning'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_GetAverageEventRating` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_GetAverageEventRating`(p_eid VARCHAR(5)) RETURNS decimal(3,2)
    READS SQL DATA
BEGIN
    DECLARE avg_rating DECIMAL(3, 2);

    SELECT AVG(rating)
    INTO avg_rating
    FROM feedback
    WHERE event_id = p_eid;

    
    RETURN avg_rating;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_GetEventAttendanceRatio` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_GetEventAttendanceRatio`(p_eid VARCHAR(5)) RETURNS decimal(5,2)
    READS SQL DATA
BEGIN
    DECLARE total_registered INT;
    DECLARE total_attended INT;
    DECLARE ratio DECIMAL(5, 2);

    
    SELECT 
        COUNT(*), 
        SUM(CASE WHEN status = 'A' THEN 1 ELSE 0 END)
    INTO total_registered, total_attended
    FROM attends
    WHERE eid = p_eid;

    
    IF total_registered = 0 THEN
        SET ratio = 0.00;
    ELSE
        SET ratio = (total_attended / total_registered) * 100.0;
    END IF;

    RETURN ratio;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_GetStudentTotalAttendance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_GetStudentTotalAttendance`(p_sid VARCHAR(5)) RETURNS int
    READS SQL DATA
BEGIN

    DECLARE attend_count INT;





    SELECT COUNT(*)

    INTO attend_count

    FROM attends

    WHERE sid = p_sid AND status = 'A';



    RETURN attend_count;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_GetTotalSponsorship` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_GetTotalSponsorship`(p_eid VARCHAR(5)) RETURNS int
    READS SQL DATA
BEGIN
    DECLARE total_amount INT;

    
    SELECT IFNULL(SUM(s.contri_amt), 0)
    INTO total_amount
    FROM sponsor s
    JOIN funded f ON s.spid = f.spid
    WHERE f.eid = p_eid
      AND s.contri_type = 'Monetary'; 

    RETURN total_amount;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddEvent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddEvent`(
    IN e_id VARCHAR(5),
    IN e_name VARCHAR(10),
    IN e_type VARCHAR(10),
    IN e_opt_date DATE,
    IN e_actual_date DATE,
    IN e_opt_time TIME,
    IN e_actual_time TIME,
    IN e_dept VARCHAR(10)
)
BEGIN
    INSERT INTO event(eid, ename, etype, opt_date, actual_date, opt_time, actual_time, dept)
    VALUES(e_id, e_name, e_type, e_opt_date, e_actual_date, e_opt_time, e_actual_time, e_dept);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetEventsByDepartment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetEventsByDepartment`(IN dept_name VARCHAR(10))
BEGIN
    SELECT eid, ename, etype, actual_date, actual_time, dept
    FROM event
    WHERE dept = dept_name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateCoordinator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCoordinator`(
    IN e_id VARCHAR(5),
    IN new_gname VARCHAR(15)
)
BEGIN
    UPDATE event
    SET gname = new_gname
    WHERE eid = e_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_attends_detailed`
--

/*!50001 DROP VIEW IF EXISTS `v_attends_detailed`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_attends_detailed` AS select `a`.`sid` AS `student_id`,`s`.`fname` AS `student_first_name`,`s`.`lname` AS `student_last_name`,`a`.`eid` AS `event_id`,`e`.`ename` AS `event_name`,`a`.`status` AS `attendance_status` from ((`attends` `a` join `students` `s` on((`a`.`sid` = `s`.`sid`))) join `event` `e` on((`a`.`eid` = `e`.`eid`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_club_membership`
--

/*!50001 DROP VIEW IF EXISTS `v_club_membership`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_club_membership` AS select `ipo`.`sid` AS `student_id`,`s`.`fname` AS `student_first_name`,`s`.`lname` AS `student_last_name`,`ipo`.`cid` AS `club_id`,`c`.`cname` AS `club_name`,`ipo`.`role` AS `role` from ((`is_part_of` `ipo` join `students` `s` on((`ipo`.`sid` = `s`.`sid`))) join `club` `c` on((`ipo`.`cid` = `c`.`cid`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_event_summary`
--

/*!50001 DROP VIEW IF EXISTS `v_event_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_event_summary` AS select `e`.`eid` AS `eid`,`e`.`ename` AS `ename`,`e`.`actual_date` AS `actual_date`,`e`.`actual_time` AS `actual_time`,`c`.`cname` AS `club_name`,count(`a`.`sid`) AS `registered_count` from (((`event` `e` left join `organizes` `o` on((`e`.`eid` = `o`.`eid`))) left join `club` `c` on((`o`.`cid` = `c`.`cid`))) left join `attends` `a` on((`e`.`eid` = `a`.`eid`))) group by `e`.`eid`,`e`.`ename`,`e`.`actual_date`,`e`.`actual_time`,`c`.`cname` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_feedback_detailed`
--

/*!50001 DROP VIEW IF EXISTS `v_feedback_detailed`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_feedback_detailed` AS select `f`.`fbid` AS `feedback_id`,`f`.`event_id` AS `event_id`,`e`.`ename` AS `event_name`,`f`.`rating` AS `rating`,`f`.`comment` AS `comment` from (`feedback` `f` join `event` `e` on((`f`.`event_id` = `e`.`eid`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-07 10:10:01
