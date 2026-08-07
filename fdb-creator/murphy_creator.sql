CREATE TABLE IF NOT EXISTS `murphy_creator` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charid` varchar(200) NOT NULL,
  `peddata` json NOT NULL,
  `informations` json NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

