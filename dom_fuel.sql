-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.24-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.3.0.6589
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table esxlegacy_a9e0f4.dom_fuel
CREATE TABLE IF NOT EXISTS `dom_fuel` (
  `GasStation` varchar(50) DEFAULT NULL,
  `Owner` varchar(46) DEFAULT NULL,
  `id` varchar(50) DEFAULT NULL,
  `Gas` int(255) DEFAULT NULL,
  `Money` int(255) DEFAULT NULL,
  `Price` int(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table esxlegacy_a9e0f4.dom_fuel: ~27 rows (approximately)
INSERT INTO `dom_fuel` (`GasStation`, `Owner`, `id`, `Gas`, `Money`, `Price`) VALUES
	('7001', NULL, NULL, 0, 0, 0),
	('9094', NULL, NULL, 0, 0, 0),
	('3051', NULL, NULL, 0, 0, 0),
	('7286', NULL, NULL, 0, 0, 0),
	('8140', NULL, NULL, 0, 0, 0),
	('3008', NULL, NULL, 0, 0, 0),
	('5011', NULL, NULL, 0, 0, 0),
	('7302', NULL, NULL, 0, 0, 0),
	('4023', NULL, NULL, 0, 0, 0),
	('9051', NULL, NULL, 0, 0, 0),
	('8194', NULL, NULL, 0, 0, 0),
	('1012', NULL, NULL, 0, 0, 0),
	('9330', NULL, NULL, 0, 0, 0),
	('5016', NULL, NULL, 0, 0, 0),
	('7354', NULL, NULL, 0, 0, 0);
	('Panorama Dr', "BigSmoke", 'license:7a9638ebb414b63e8aa7671749ea61fb474d70bb', 100000, 0, 30),
	('Great Ocean Hwy - 1', "GamerTag", 'license:e294983749f5da0d7cb4ef223f468f5aaa218024', 100000, 0, 30),
	('Grapseed Main St', "GamerTag", 'license:e294983749f5da0d7cb4ef223f468f5aaa218024', 100000, 0, 30),
	('Route 68 - 5', "GamerTag", 'license:e294983749f5da0d7cb4ef223f468f5aaa218024', 100000, 0, 30),
	('Senora Way', "BigSmoke", 'license:7a9638ebb414b63e8aa7671749ea61fb474d70bb', 100000, 0, 30),
	('Route 68 - 2', "GamerTag", 'license:e294983749f5da0d7cb4ef223f468f5aaa218024', 100000, 0, 30),
	('Route 68 - 3', "GamerTag", 'license:e294983749f5da0d7cb4ef223f468f5aaa218024', 100000, 0, 30),
	('Innocence Blvd', "BigSmoke", 'license:7a9638ebb414b63e8aa7671749ea61fb474d70bb', 100000, 0, 30),
	('Macdonald St', "BigSmoke", 'license:7a9638ebb414b63e8aa7671749ea61fb474d70bb', 100000, 0, 30),
	('Calais Ave', "BigSmoke", 'license:7a9638ebb414b63e8aa7671749ea61fb474d70bb', 100000, 0, 30),
	('North Rockford Dr - 1', "BigSmoke", 'license:7a9638ebb414b63e8aa7671749ea61fb474d70bb', 100000, 0, 30),

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
