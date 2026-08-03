-- ================================================
--       FDB-System Core Database Schema
-- ================================================

CREATE TABLE IF NOT EXISTS `players` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `cid` INT(11) DEFAULT 1,
  `license` VARCHAR(255) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `money` LONGTEXT NOT NULL,
  `charinfo` LONGTEXT DEFAULT NULL,
  `job` LONGTEXT NOT NULL,
  `gang` LONGTEXT DEFAULT NULL,
  `position` LONGTEXT NOT NULL,
  `metadata` LONGTEXT NOT NULL,
  `weight` INT(11) DEFAULT 35000,
  PRIMARY KEY (`citizenid`),
  KEY `id` (`id`),
  KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `inventories` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `identifier` VARCHAR(100) NOT NULL,
  `items` LONGTEXT DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_weapons` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `serial` VARCHAR(50) NOT NULL,
  `weapon` VARCHAR(50) NOT NULL,
  `components` LONGTEXT DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `serial` (`serial`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_horses` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `stable` VARCHAR(50) NOT NULL DEFAULT 'valentine',
  `citizenid` VARCHAR(50) NOT NULL,
  `horseid` VARCHAR(50) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `horse` VARCHAR(50) NOT NULL,
  `gender` VARCHAR(10) NOT NULL DEFAULT 'male',
  `active` TINYINT(1) NOT NULL DEFAULT 0,
  `born` INT(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `horseid` (`horseid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `playerskins` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `skin` LONGTEXT DEFAULT NULL,
  `clothes` LONGTEXT DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
