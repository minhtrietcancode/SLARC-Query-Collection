-- MAKE SURE WHEN TESTING YOU ALWAYS RUN THIS STATEMENT: NEED TO HAVE 'only full group by' OR 'ANSI' in the SQL_MODE to ensure you don't have invalid GROUP_BY statements which will fail during our automarking!
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

-- IF RUNNING THIS ON YOUR OWN LOCAL HOST DBMS, UNCOMMENT THE FOLLOWING LINES
-- ELSE ON THE INFO20003 SERVER, COMMENT THEM OUT
/*
DROP SCHEMA IF EXISTS `slarc` ;
CREATE SCHEMA IF NOT EXISTS `slarc` DEFAULT CHARACTER SET utf8 ;
USE `slarc` ;
*/


-- -----------------------------------------------------
-- Table `user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `user` ;

CREATE TABLE IF NOT EXISTS `user` (
  `userID` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `authType` ENUM('gmail', 'facebook', 'github', 'apple') NOT NULL,
  `reputation` INT NOT NULL,
  `avatarURL` VARCHAR(100) NULL,
  PRIMARY KEY (`userID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `moderator`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `moderator` ;

CREATE TABLE IF NOT EXISTS `moderator` (
  `modID` INT NOT NULL AUTO_INCREMENT,
  `linkedUserID` INT NOT NULL,
  `description` VARCHAR(45) NULL,
  `dateModStatus` DATETIME NOT NULL,
  PRIMARY KEY (`modID`),
  UNIQUE INDEX `linkedUserID_UNIQUE` (`linkedUserID` ASC) VISIBLE,
  CONSTRAINT `fk_moderator_user1`
    FOREIGN KEY (`linkedUserID`)
    REFERENCES `user` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `channel`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `channel` ;

CREATE TABLE IF NOT EXISTS `channel` (
  `channelID` INT NOT NULL AUTO_INCREMENT,
  `channelName` VARCHAR(45) NOT NULL,
  `description` VARCHAR(45) NULL,
  `dateCreated` DATETIME NOT NULL,
  PRIMARY KEY (`channelID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `post`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `post` ;

CREATE TABLE IF NOT EXISTS `post` (
  `postPermanentID` INT NOT NULL AUTO_INCREMENT,
  `authorID` INT NOT NULL,
  `text` VARCHAR(1000) NOT NULL,
  `viewCount` BIGINT NOT NULL,
  `dateCreated` DATETIME NOT NULL,
  `restricted` TINYINT NOT NULL,
  `modHidden` TINYINT NOT NULL,
  PRIMARY KEY (`postPermanentID`),
  INDEX `fk_post_user1_idx` (`authorID` ASC) VISIBLE,
  CONSTRAINT `fk_post_user1`
    FOREIGN KEY (`authorID`)
    REFERENCES `user` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `postreply`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `postreply` ;

CREATE TABLE IF NOT EXISTS `postreply` (
  `originalPostID` INT NOT NULL,
  `replyPostID` INT NOT NULL,
  PRIMARY KEY (`originalPostID`, `replyPostID`),
  INDEX `fk_postreply_post2_idx` (`replyPostID` ASC) VISIBLE,
  CONSTRAINT `fk_postreply_post1`
    FOREIGN KEY (`originalPostID`)
    REFERENCES `post` (`postPermanentID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_postreply_post2`
    FOREIGN KEY (`replyPostID`)
    REFERENCES `post` (`postPermanentID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `react`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `react` ;

CREATE TABLE IF NOT EXISTS `react` (
  `userID` INT NOT NULL,
  `postID` INT NOT NULL,
  `reactTime` DATETIME NOT NULL,
  `emoji` ENUM('like', 'love', 'care', 'haha', 'wow', 'sad', 'angry') NOT NULL,
  PRIMARY KEY (`userID`, `postID`),
  CONSTRAINT `fk_react_postid`
    FOREIGN KEY (`postID`)
    REFERENCES `post` (`postPermanentID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_react_userid`
    FOREIGN KEY (`userID`)
    REFERENCES `user` (`userID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `modagreement`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `modagreement` ;

CREATE TABLE IF NOT EXISTS `modagreement` (
  `modID` INT NOT NULL,
  `channelID` INT NOT NULL,
  `dateAppointed` DATETIME NOT NULL,
  `endorsedByModID` INT NULL,
  PRIMARY KEY (`modID`, `channelID`),
  INDEX `fk_channel_idx` (`channelID` ASC) VISIBLE,
  INDEX `fk_modchannel_moderator2_idx` (`endorsedByModID` ASC) VISIBLE,
  CONSTRAINT `fk_channel`
    FOREIGN KEY (`channelID`)
    REFERENCES `channel` (`channelID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_modchannel_moderator1`
    FOREIGN KEY (`modID`)
    REFERENCES `moderator` (`modID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_modchannel_moderator2`
    FOREIGN KEY (`endorsedByModID`)
    REFERENCES `moderator` (`modID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `postchannel`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `postchannel` ;

CREATE TABLE IF NOT EXISTS `postchannel` (
  `postID` INT NOT NULL,
  `channelID` INT NOT NULL,
  PRIMARY KEY (`postID`, `channelID`),
  INDEX `fk_postchannel_channel1_idx` (`channelID` ASC) VISIBLE,
  CONSTRAINT `fk_postchannel_channel1`
    FOREIGN KEY (`channelID`)
    REFERENCES `channel` (`channelID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_postchannel_post1`
    FOREIGN KEY (`postID`)
    REFERENCES `post` (`postPermanentID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `attachmentobject`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `attachmentobject` ;

CREATE TABLE IF NOT EXISTS `attachmentobject` (
  `postPermanentID` INT NOT NULL,
  `dataURL` VARCHAR(700) NOT NULL,
  `fileSize` INT NOT NULL,
  `virusScanned` TINYINT NOT NULL,
  PRIMARY KEY (`postPermanentID`, `dataURL`),
  CONSTRAINT `fk_attachmentobject_post1`
    FOREIGN KEY (`postPermanentID`)
    REFERENCES `post` (`postPermanentID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `moderatorreport`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `moderatorreport` ;

CREATE TABLE IF NOT EXISTS `moderatorreport` (
  `caseID` INT NOT NULL AUTO_INCREMENT,
  `postPermanentID` INT NOT NULL,
  `modID` INT NOT NULL,
  `allegationText` VARCHAR(100) NOT NULL,
  `modDecisionText` VARCHAR(100) NULL,
  `disciplinaryAction` TINYINT NOT NULL,
  `dateAlleged` DATETIME NOT NULL,
  `dateModAction` DATETIME NULL,
  PRIMARY KEY (`caseID`),
  INDEX `fk_moderatorreport_post1_idx` (`postPermanentID` ASC) VISIBLE,
  INDEX `fk_moderatorreport_moderator1_idx` (`modID` ASC) VISIBLE,
  CONSTRAINT `fk_moderatorreport_post1`
    FOREIGN KEY (`postPermanentID`)
    REFERENCES `post` (`postPermanentID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_moderatorreport_moderator1`
    FOREIGN KEY (`modID`)
    REFERENCES `moderator` (`modID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- DATA DUMP BELOW --

-- MySQL dump 10.13  Distrib 8.3.0, for macos14.2 (arm64)
--
-- Host: localhost    Database: slarc
-- ------------------------------------------------------
-- Server version	8.3.0

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
-- Current Database: `slarc`
--

--
-- Dumping data for table `attachmentobject`
--

LOCK TABLES `attachmentobject` WRITE;
/*!40000 ALTER TABLE `attachmentobject` DISABLE KEYS */;
INSERT INTO `attachmentobject` VALUES (1,'http://fakeupload.com/imgs/def456-ghi789-jkl012',4123,1),(2,'http://fakeupload.com/imgs/abc345-def678-ghi901',4678,0),(2,'http://fakeupload.com/imgs/jkl123-mno456-pqr789',4577,1),(2,'http://fakeupload.com/imgs/vwx123-yza456-bcd789',3350,1),(3,'http://fakeupload.com/imgs/stu345-vwx678-yza901',2498,1),(3,'http://fakeupload.com/imgs/xyz123-abc456-def789',3245,1),(4,'http://fakeupload.com/imgs/pqr123-stu456-vwx789',3333,1),(5,'http://fakeupload.com/imgs/jkl012-mno345-pqr678',4020,0),(8,'http://fakeupload.com/imgs/ghi234-jkl567-mno890',2899,0),(9,'http://fakeupload.com/imgs/jkl678-mno901-pqr234',2910,1),(11,'http://fakeupload.com/imgs/mno678-pqr901-stu234',2765,0),(23,'http://fakeupload.com/imgs/stu123-vwx456-yza789',4901,0),(27,'http://fakeupload.com/imgs/abc567-def890-ghi123',3899,0),(48,'http://fakeupload.com/imgs/def123-ghi456-jkl789',4521,1),(54,'http://fakeupload.com/imgs/ghi789-jkl012-mno345',2444,1),(55,'http://fakeupload.com/imgs/ghi678-jkl901-mno234',4211,0),(60,'http://fakeupload.com/imgs/def234-ghi567-jkl890',2299,0),(60,'http://fakeupload.com/imgs/mno345-pqr678-stu901',3876,0),(60,'http://fakeupload.com/imgs/pqr345-stu678-vwx901',3500,1),(70,'http://fakeupload.com/imgs/abc789-xyz123-pqr456',2567,0);
/*!40000 ALTER TABLE `attachmentobject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `channel`
--

LOCK TABLES `channel` WRITE;
/*!40000 ALTER TABLE `channel` DISABLE KEYS */;
INSERT INTO `channel` VALUES (1,'dota2_proplays','Pro Dota 2 matches and highlights.','2024-01-02 00:00:00'),(2,'esports_news','Latest updates in esports.','2024-01-22 00:00:00'),(3,'ranked_grind','Discuss your ranked journey.','2024-01-12 00:00:00'),(4,'dota2_memes','Fun Dota 2 memes and jokes.','2024-01-27 00:00:00'),(5,'hero_tips','Tips for mastering Dota 2 heroes.','2024-01-07 00:00:00');
/*!40000 ALTER TABLE `channel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `modagreement`
--

LOCK TABLES `modagreement` WRITE;
/*!40000 ALTER TABLE `modagreement` DISABLE KEYS */;
INSERT INTO `modagreement` VALUES (1,2,'2024-04-05 01:00:00',3),(1,3,'2024-04-05 01:00:00',2),(1,4,'2024-06-05 01:00:00',NULL),(1,5,'2024-04-05 01:00:00',3),(2,1,'2024-04-12 01:00:00',4),(2,3,'2024-01-12 00:00:00',NULL),(2,4,'2024-04-12 01:00:00',3),(3,2,'2024-01-22 00:00:00',NULL),(3,4,'2024-01-27 00:00:00',NULL),(3,5,'2024-01-07 00:00:00',NULL),(4,1,'2024-01-02 00:00:00',NULL),(4,3,'2024-04-25 01:00:00',6),(4,5,'2024-04-25 01:00:00',6),(5,1,'2024-05-03 01:00:00',7),(5,2,'2024-05-03 01:00:00',6),(5,4,'2024-05-03 01:00:00',7),(6,2,'2024-05-02 01:00:00',8),(6,3,'2024-04-24 01:00:00',7),(6,5,'2024-04-24 01:00:00',8),(7,1,'2024-05-02 01:00:00',9),(7,3,'2024-04-23 01:00:00',NULL),(7,4,'2024-05-02 01:00:00',8),(8,2,'2024-05-01 01:00:00',10),(8,4,'2024-05-01 01:00:00',NULL),(8,5,'2024-04-23 01:00:00',9),(9,1,'2024-05-01 01:00:00',10),(9,3,'2024-06-01 01:00:00',11),(9,5,'2024-04-22 01:00:00',NULL),(10,1,'2024-04-30 01:00:00',NULL),(10,2,'2024-04-30 01:00:00',11),(10,4,'2024-06-07 01:00:00',12),(11,2,'2024-04-29 01:00:00',NULL),(11,3,'2024-05-31 01:00:00',12),(11,5,'2024-06-14 01:00:00',1),(12,1,'2024-06-20 01:00:00',2),(12,3,'2024-05-30 01:00:00',NULL),(12,4,'2024-06-06 01:00:00',1);
/*!40000 ALTER TABLE `modagreement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `moderator`
--

LOCK TABLES `moderator` WRITE;
/*!40000 ALTER TABLE `moderator` DISABLE KEYS */;
INSERT INTO `moderator` VALUES (1,1,'Expert Juggernaut player, loves rampages','2024-04-05 01:00:00'),(2,2,'Dota 2 enthusiast, loves a good Chrono','2024-01-12 00:00:00'),(3,3,'Invoker combo master, unstoppable in mid','2024-01-07 00:00:00'),(4,4,'Master of map control, perfect warding','2024-01-02 00:00:00'),(5,5,'Loves playing support, great with Dazzle','2024-05-03 01:00:00'),(6,6,'Shadow Fiend mid player, fear the razes','2024-04-24 01:00:00'),(7,7,'Witch Doctor main, perfect Maledict','2024-04-23 01:00:00'),(8,8,'Crystal Maiden fan, freezing fields galore','2024-04-23 01:00:00'),(9,9,'Sniper from the high ground, headshot king','2024-04-22 01:00:00'),(10,10,'Tinker spammer, pushes every lane','2024-04-30 01:00:00'),(11,11,'PA crits are life, one-shot wonder','2024-04-29 01:00:00'),(12,12,'Techies expert, loves laying traps','2024-05-30 01:00:00');
/*!40000 ALTER TABLE `moderator` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `moderatorreport`
--

LOCK TABLES `moderatorreport` WRITE;
/*!40000 ALTER TABLE `moderatorreport` DISABLE KEYS */;
INSERT INTO `moderatorreport` VALUES (1,10,5,'He cheated!','No, he is just better than you',0,'2024-04-20 00:00:00','2024-04-21 00:00:00'),(2,25,8,'Juggernaut is banned','I agree',0,'2024-05-25 07:00:00','2024-04-30 00:00:00'),(3,33,3,'Offensive language used','Warning issued',1,'2024-05-01 00:00:00','2024-05-02 00:00:00'),(4,47,6,'Spamming in chat','Muted for 24 hours',1,'2024-06-12 06:00:00','2024-05-04 00:00:00'),(5,50,4,'Inappropriate content','Post removed',1,'2024-05-05 00:00:00','2024-05-06 00:00:00'),(6,64,7,'Toxic behavior','Banned for 7 days',1,'2024-05-18 07:00:00','2024-05-08 00:00:00'),(7,72,2,'Botting detected','Account suspended',1,'2024-05-09 00:00:00','2024-05-10 00:00:00'),(8,85,1,'Harassment of other players','Permanent ban',1,'2024-05-11 00:00:00','2024-05-12 00:00:00'),(9,11,12,'Exploit abuse','Temporary ban',1,'2024-06-20 07:00:00','2024-05-14 00:00:00'),(10,23,10,'False reporting','No action taken',0,'2024-06-07 07:00:00','2024-05-16 00:00:00'),(11,34,11,'Sharing personal information','Post deleted',1,'2024-06-14 07:00:00','2024-05-18 00:00:00'),(12,48,6,'Hate speech','Account permanently banned',1,'2024-05-19 00:00:00','2024-05-20 00:00:00'),(13,55,9,'Account hacking attempt','Security review initiated',1,'2024-06-01 07:00:00','2024-05-22 00:00:00'),(14,63,4,'Phishing links','Post removed and user warned',1,'2024-05-23 00:00:00','2024-05-24 00:00:00'),(15,76,8,'Offensive username','Username change required',1,'2024-05-25 07:00:00','2024-05-26 00:00:00'),(16,81,2,'Impersonating a moderator','Permanent ban',1,'2024-05-27 00:00:00','2024-05-28 00:00:00'),(17,19,7,'Advertising without permission','Post deleted',1,'2024-05-29 00:00:00','2024-05-30 00:00:00'),(18,29,3,'Multiple accounts abuse','All accounts suspended',1,'2024-05-31 00:00:00','2024-06-01 00:00:00'),(19,42,5,'Posting NSFW content','Post removed and warning issued',1,'2024-06-02 00:00:00','2024-06-03 00:00:00'),(20,99,1,'Threatening other users','Permanent ban',1,'2024-06-04 00:00:00','2024-06-05 00:00:00');
/*!40000 ALTER TABLE `moderatorreport` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `post`
--

LOCK TABLES `post` WRITE;
/*!40000 ALTER TABLE `post` DISABLE KEYS */;
INSERT INTO `post` VALUES (1,8,'Just won a match with Axe, completely dominated the game!',15034,'2024-04-05 00:00:00',0,0),(2,2,'Pulled off a rampage with Juggernaut today, felt amazing!',28367,'2024-04-10 00:00:00',1,0),(3,6,'Crystal Maiden\'s freezing field is so underrated!',1032,'2024-04-15 00:00:00',0,0),(4,6,'Sniper headshots are too strong in this patch.',29000,'2024-04-20 00:00:00',0,1),(5,1,'Reached Immortal with my Tinker plays, hard work paid off.',35122,'2024-04-25 00:00:00',0,0),(6,7,'Shadow Fiend still dominates the mid lane, nothing new.',17589,'2024-05-01 00:00:00',1,0),(7,9,'Sven with Mask of Madness is unstoppable.',6421,'2024-05-05 00:00:00',0,0),(8,3,'Thinking about switching to support role, any tips for Dazzle?',21789,'2024-05-10 00:00:00',1,1),(9,8,'Hit a perfect Echo Slam with Earthshaker, wiped the enemy team.',33004,'2024-05-15 00:00:00',0,0),(10,4,'Landed a max range arrow with Mirana, so satisfying!',17000,'2024-04-19 19:00:00',1,0),(11,21,'Phantom Assassin crits are just out of this world!',18456,'2024-06-20 02:00:00',0,0),(12,27,'Luna is surprisingly strong in this patch, loving the glaives.',2789,'2024-06-01 00:00:00',0,0),(13,25,'Storm Spirit is so slippery, impossible to catch!',20234,'2024-06-05 00:00:00',1,1),(14,19,'Drow Ranger is melting towers with that precision aura.',37000,'2024-06-10 00:00:00',0,0),(15,30,'Dealing with Techies is a nightmare, can we ban this hero?',32011,'2024-06-15 00:00:00',1,0),(16,18,'Laning with Witch Doctor today was too easy.',14200,'2024-04-08 00:00:00',0,1),(17,22,'Spectre\'s late game potential is scary, won a 60-minute game!',36789,'2024-04-12 00:00:00',0,0),(18,16,'Invoker\'s combos are so complex, but when they work, it\'s pure magic.',12987,'2024-04-18 00:00:00',0,0),(19,26,'Faceless Void\'s Chronosphere changes the course of any teamfight.',28200,'2024-05-28 19:00:00',1,0),(20,20,'Improving my micro skills with Meepo, feeling more confident now.',16500,'2024-04-28 00:00:00',0,1),(21,17,'Anti-Mage blink farming is the most efficient way to farm gold.',6900,'2024-05-02 00:00:00',0,0),(22,29,'Naga Siren\'s illusions are so deceptive, love playing her.',20145,'2024-05-06 00:00:00',0,0),(23,23,'Lifestealer\'s infest saved our team so many times today.',35900,'2024-06-07 02:00:00',1,0),(24,8,'Pudge hooks were on fire today, caught so many enemies.',39200,'2024-05-18 00:00:00',0,1),(25,4,'Terrorblade with metamorphosis is a tower-wrecking machine.',24500,'2024-05-25 02:00:00',0,0),(26,1,'Centaur Warrunner\'s blink stun is a great initiation tool.',10567,'2024-05-27 00:00:00',1,0),(27,27,'Oracle\'s ultimate is game-changing in clutch moments.',11800,'2024-06-03 00:00:00',0,0),(28,25,'Outplayed a Windranger with Ember Spirit, felt so satisfying.',37300,'2024-06-07 00:00:00',1,1),(29,19,'Bounty Hunter\'s track gold made a huge difference in our game.',31500,'2024-05-30 19:00:00',0,0),(30,30,'Enigma\'s Black Hole is so satisfying when you catch the entire team!',44900,'2024-06-17 00:00:00',0,0),(31,19,'Tried out Wraith King today, his reincarnation is so strong!',18275,'2024-05-25 00:00:00',1,0),(32,27,'Bounty Hunter is so much fun to play with that gold steal!',3241,'2024-05-30 00:00:00',0,1),(33,23,'How do you counter a fed Phantom Assassin?',29314,'2024-04-30 19:00:00',0,0),(34,28,'Love playing Pudge but my hooks need work.',12401,'2024-06-14 02:00:00',1,0),(35,30,'Anti-Mage is a great hero to split-push with.',21678,'2024-06-14 00:00:00',0,1),(36,18,'The laning phase is so important, any tips?',14876,'2024-06-19 00:00:00',0,0),(37,2,'Just had an intense game with Earthshaker, those stuns are amazing!',31015,'2024-06-24 00:00:00',0,0),(38,6,'Dota 2 tournaments are so much fun to watch!',27654,'2024-06-29 00:00:00',1,1),(39,6,'Slark is so hard to catch with that Shadow Dance.',14200,'2024-01-03 00:00:00',0,0),(40,5,'I feel like playing mid is too stressful.',10899,'2024-01-08 00:00:00',0,1),(41,20,'Invoker is so difficult to master but so rewarding.',12045,'2024-04-25 00:00:00',0,1),(42,1,'Lost a match because of a bad draft. Drafting is crucial!',21011,'2024-06-01 19:00:00',1,0),(43,17,'Learning to play support, any tips?',5003,'2024-05-05 00:00:00',0,0),(44,29,'The new patch has completely changed the meta.',35000,'2024-05-10 00:00:00',1,1),(45,25,'What\'s your favorite Dota 2 hero?',19483,'2024-05-15 00:00:00',0,0),(46,19,'Zeus ult is so satisfying when you secure kills across the map.',19987,'2024-01-13 00:00:00',0,0),(47,25,'Successfully baited the enemy team with my Illusions, felt great!',18322,'2024-06-12 01:00:00',1,0),(48,24,'Luna’s glaives are amazing for farming but hard to master.',25999,'2024-05-18 19:00:00',0,1),(49,17,'Laning against a good Templar Assassin is so difficult.',7621,'2024-01-28 00:00:00',0,0),(50,29,'Always ban Techies. Those mines are just too annoying.',27643,'2024-05-04 19:00:00',1,1),(51,23,'Just had a great game with Drow Ranger, those frost arrows!',18545,'2024-02-07 00:00:00',0,0),(52,27,'What do you think about the new hero, is it OP?',12234,'2024-02-12 00:00:00',0,0),(53,21,'Had a tough time against Broodmother, those spiders are relentless.',31421,'2024-02-17 00:00:00',1,1),(54,22,'Successfully stacked and farmed the jungle with Sven, easy game.',24976,'2024-02-22 00:00:00',0,0),(55,30,'Enigma’s black hole is game-changing when timed right.',28700,'2024-06-01 02:00:00',0,0),(56,18,'Supporting a good carry is so rewarding, played as Lion today.',11123,'2024-03-03 00:00:00',1,0),(57,28,'Climbing the ranks slowly, trying to master mid-lane.',29899,'2024-03-08 00:00:00',0,1),(58,26,'Aggressive trilane worked out perfectly, we won the lane hard.',17521,'2024-03-13 00:00:00',0,0),(59,20,'Playing around Roshan can change the outcome of a game.',26934,'2024-03-18 00:00:00',1,0),(60,17,'Tried out Ursa today, great for taking down Roshan early.',19231,'2024-03-23 00:00:00',0,1),(61,29,'Had an epic game with Void, those Chronospheres were on point.',22345,'2024-03-28 00:00:00',0,0),(62,19,'Kiting with Viper is so much fun, the enemy team couldn’t touch me.',30419,'2024-04-02 00:00:00',0,0),(63,25,'Farmed the jungle with Anti-Mage, carried the game late.',27300,'2024-05-22 19:00:00',1,0),(64,24,'Caught the enemy out of position with my Batrider lasso.',15876,'2024-05-18 02:00:00',0,0),(65,27,'Learned to stack camps with Chen, helped our carry get huge.',13122,'2024-04-17 00:00:00',0,1),(66,21,'Went on a killing spree with Phantom Assassin, so satisfying!',24567,'2024-04-22 00:00:00',1,0),(67,2,'Warding and dewarding can completely shift map control.',29934,'2024-04-27 00:00:00',0,0),(68,30,'Played an amazing support role, our carry snowballed hard.',18567,'2024-05-02 00:00:00',0,1),(69,16,'Just had an epic game with Phantom Assassin! Those crits are insane!',15324,'2024-01-12 00:00:00',0,0),(70,21,'Does anyone else think Drow Ranger is a bit OP lately?',27980,'2024-02-05 00:00:00',0,0),(71,18,'Tidehunter’s Ravage won us the game! GG!',48912,'2024-03-22 00:00:00',1,0),(72,23,'Invoker is such a complex hero, but so rewarding to play.',34210,'2024-05-08 19:00:00',0,1),(73,29,'Best way to counter an Ursa pick? Any tips?',15876,'2024-02-14 00:00:00',0,0),(74,17,'Just saw a 5-man Black Hole from Enigma! Unreal!',44890,'2024-05-01 00:00:00',1,0),(75,15,'Axe with Blade Mail is such a beast in the late game.',21945,'2024-03-10 00:00:00',0,0),(76,22,'New patch seems to have nerfed my favorite hero, Lich.',37450,'2024-05-25 02:00:00',0,1),(77,19,'Riki’s invisibility is so annoying! How do you guys deal with it?',8502,'2024-06-12 00:00:00',0,0),(78,24,'Played as Mirana today, those arrows are so satisfying to land.',26915,'2024-02-20 00:00:00',0,0),(79,27,'Centaur Warrunner is my go-to offlaner. Any better suggestions?',11574,'2024-01-18 00:00:00',1,0),(80,20,'Bloodseeker’s rupture is such a game changer.',42136,'2024-05-18 00:00:00',0,1),(81,25,'Slark is the king of late game carry!',37890,'2024-05-26 19:00:00',0,0),(82,30,'Witch Doctor’s Cask can change the tide of any battle.',9645,'2024-03-15 00:00:00',0,0),(83,18,'Faceless Void’s Chronosphere setup with Sniper is deadly!',22561,'2024-04-21 00:00:00',0,0),(84,16,'Just got my first Rampage with Spectre, feels amazing!',17580,'2024-01-30 00:00:00',1,1),(85,28,'Shadow Shaman’s wards are great for pushing towers.',30475,'2024-05-10 19:00:00',0,0),(86,21,'Meepo is so hard to play, but when it works, it’s so satisfying!',4890,'2024-05-07 00:00:00',0,0),(87,19,'Anyone else struggling with Tinker in the current patch?',14532,'2024-04-29 00:00:00',1,0),(88,23,'Rubick’s spell steal is the most fun ability in the game.',30789,'2024-06-15 00:00:00',0,1),(89,17,'Just had a great game with Juggernaut, spinning to win!',24510,'2024-03-05 00:00:00',0,0),(90,26,'Spectre’s Haunt is the best for catching out split pushers.',15376,'2024-05-12 00:00:00',0,0),(91,30,'Invoker’s Tornado-EMP combo is so satisfying to pull off.',36945,'2024-01-23 00:00:00',0,1),(92,15,'Crystal Maiden’s freezing field is a team fight winner.',48219,'2024-02-17 00:00:00',1,0),(93,25,'Pudge’s hooks are on point this patch!',33894,'2024-04-13 00:00:00',0,0),(94,22,'Viper’s poison is so strong, especially in the laning phase.',21865,'2024-06-01 00:00:00',0,0),(95,20,'Tinker’s rearm with Dagon is just unfair.',47891,'2024-03-28 00:00:00',0,1),(96,29,'Bounty Hunter’s track gold is so useful for snowballing.',26483,'2024-05-22 00:00:00',0,0),(97,28,'Is Ember Spirit still viable in the current meta?',19456,'2024-01-19 00:00:00',1,0),(98,27,'Lina’s Laguna Blade is a one-shot wonder!',36875,'2024-02-25 00:00:00',0,0),(99,24,'Enigma’s Black Hole into Sand King’s Epicenter is the dream combo.',44610,'2024-06-03 19:00:00',0,1),(100,26,'Anti-Mage is unstoppable once he gets farmed.',22791,'2024-03-03 00:00:00',1,0);
/*!40000 ALTER TABLE `post` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `postchannel`
--

LOCK TABLES `postchannel` WRITE;
/*!40000 ALTER TABLE `postchannel` DISABLE KEYS */;
INSERT INTO `postchannel` VALUES (2,1),(8,1),(14,1),(19,1),(22,1),(28,1),(34,1),(39,1),(42,1),(48,1),(52,1),(54,1),(59,1),(64,1),(69,1),(74,1),(79,1),(84,1),(89,1),(94,1),(99,1),(4,2),(7,2),(12,2),(16,2),(24,2),(27,2),(32,2),(36,2),(44,2),(47,2),(56,2),(61,2),(66,2),(71,2),(76,2),(81,2),(86,2),(91,2),(96,2),(1,3),(6,3),(11,3),(17,3),(21,3),(26,3),(31,3),(37,3),(41,3),(46,3),(51,3),(58,3),(62,3),(67,3),(72,3),(77,3),(82,3),(87,3),(92,3),(97,3),(3,4),(9,4),(13,4),(18,4),(23,4),(29,4),(33,4),(38,4),(43,4),(49,4),(53,4),(57,4),(63,4),(68,4),(73,4),(78,4),(83,4),(88,4),(93,4),(98,4),(5,5),(10,5),(15,5),(20,5),(25,5),(30,5),(35,5),(40,5),(45,5),(50,5),(55,5),(60,5),(65,5),(70,5),(75,5),(80,5),(85,5),(90,5),(95,5),(100,5);
/*!40000 ALTER TABLE `postchannel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `postreply`
--

LOCK TABLES `postreply` WRITE;
/*!40000 ALTER TABLE `postreply` DISABLE KEYS */;
INSERT INTO `postreply` VALUES (1,21),(2,22),(3,23),(4,24),(5,25),(6,26),(7,27),(8,28),(9,29),(10,30),(11,31),(12,32),(13,33),(14,34),(15,35),(16,36),(17,37),(18,38),(19,39),(20,40),(21,41),(22,42),(23,43),(24,44),(25,45),(26,46),(27,47),(28,48),(29,49),(30,50),(41,51),(42,52),(43,53);
/*!40000 ALTER TABLE `postreply` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `react`
--

LOCK TABLES `react` WRITE;
/*!40000 ALTER TABLE `react` DISABLE KEYS */;
INSERT INTO `react` VALUES (1,5,'2024-04-25 01:00:00','wow'),(1,37,'2024-06-24 01:00:00','haha'),(2,6,'2024-05-01 01:00:00','care'),(2,9,'2024-05-15 01:00:00','like'),(2,29,'2024-06-12 01:00:00','haha'),(2,63,'2024-06-03 00:00:00','sad'),(3,8,'2024-05-10 01:00:00','haha'),(3,12,'2024-06-01 01:00:00','haha'),(3,72,'2024-05-08 20:00:00','wow'),(4,13,'2024-06-05 01:00:00','sad'),(4,33,'2024-06-04 01:00:00','love'),(5,11,'2024-06-20 03:00:00','like'),(5,14,'2024-06-10 01:00:00','like'),(5,23,'2024-06-07 03:00:00','like'),(5,46,'2024-06-05 00:00:00','haha'),(6,2,'2024-04-10 01:00:00','like'),(6,17,'2024-04-12 01:00:00','haha'),(6,74,'2024-05-01 00:00:00','haha'),(7,15,'2024-06-15 01:00:00','love'),(7,47,'2024-06-12 02:00:00','care'),(7,78,'2024-04-12 00:00:00','care'),(7,89,'2024-04-27 00:00:00','haha'),(8,4,'2024-04-20 01:00:00','haha'),(8,35,'2024-06-14 01:00:00','sad'),(8,61,'2024-04-27 00:00:00','angry'),(9,4,'2024-06-07 00:00:00','like'),(9,18,'2024-04-18 01:00:00','care'),(9,28,'2024-06-07 01:00:00','angry'),(9,54,'2024-02-22 01:00:00','sad'),(10,24,'2024-05-18 01:00:00','love'),(10,44,'2024-05-10 01:00:00','sad'),(10,88,'2024-06-15 01:00:00','wow'),(10,90,'2024-05-12 01:00:00','haha'),(11,42,'2024-06-01 20:00:00','haha'),(11,59,'2024-03-18 01:00:00','wow'),(11,67,'2024-04-27 01:00:00','haha'),(12,3,'2024-04-15 01:00:00','haha'),(12,19,'2024-06-11 00:00:00','love'),(12,31,'2024-05-25 01:00:00','angry'),(12,45,'2024-05-15 01:00:00','love'),(13,40,'2024-05-14 00:00:00','wow'),(13,47,'2024-06-12 02:00:00','care'),(13,88,'2024-06-15 01:00:00','like'),(14,8,'2024-05-19 00:00:00','wow'),(14,11,'2024-06-20 03:00:00','sad'),(14,32,'2024-05-30 01:00:00','love'),(14,36,'2024-06-19 01:00:00','care'),(15,38,'2024-06-29 01:00:00','love'),(15,56,'2024-03-03 01:00:00','angry'),(15,71,'2024-04-30 00:00:00','wow'),(15,93,'2024-04-13 01:00:00','love'),(16,12,'2024-06-01 01:00:00','angry'),(16,15,'2024-06-15 01:00:00','care'),(16,71,'2024-04-20 00:00:00','haha'),(17,39,'2024-03-10 00:00:00','sad'),(17,41,'2024-06-15 00:00:00','angry'),(17,45,'2024-05-15 01:00:00','sad'),(17,83,'2024-04-21 01:00:00','care'),(18,31,'2024-05-25 01:00:00','sad'),(18,48,'2024-05-18 20:00:00','sad'),(18,77,'2024-06-12 01:00:00','care'),(19,7,'2024-05-05 01:00:00','care'),(19,51,'2024-03-29 00:00:00','angry'),(19,54,'2024-04-03 00:00:00','sad'),(20,5,'2024-04-25 01:00:00','like'),(20,48,'2024-05-18 20:00:00','care'),(20,62,'2024-04-02 01:00:00','love'),(20,66,'2024-04-22 01:00:00','angry'),(21,49,'2024-03-11 00:00:00','angry'),(21,59,'2024-03-18 01:00:00','like'),(21,86,'2024-05-07 01:00:00','wow'),(22,3,'2024-05-13 00:00:00','love'),(22,64,'2024-06-13 00:00:00','like'),(23,23,'2024-06-07 03:00:00','love'),(23,25,'2024-05-25 03:00:00','love'),(23,69,'2024-06-10 00:00:00','sad'),(24,13,'2024-06-05 01:00:00','care'),(24,67,'2024-05-12 00:00:00','love'),(24,84,'2024-06-12 00:00:00','angry'),(25,20,'2024-04-28 01:00:00','sad'),(25,28,'2024-06-07 01:00:00','like'),(25,73,'2024-02-14 01:00:00','wow'),(26,19,'2024-06-14 00:00:00','wow'),(26,26,'2024-05-27 01:00:00','like'),(26,80,'2024-06-02 00:00:00','care'),(27,7,'2024-05-05 01:00:00','wow'),(27,69,'2024-01-12 01:00:00','wow'),(27,76,'2024-05-25 03:00:00','wow'),(28,53,'2024-06-01 00:00:00','love'),(28,58,'2024-03-13 01:00:00','like'),(28,72,'2024-05-08 20:00:00','angry'),(28,82,'2024-05-03 00:00:00','sad'),(29,2,'2024-05-10 00:00:00','wow'),(29,16,'2024-04-08 01:00:00','angry'),(30,84,'2024-04-19 00:00:00','like'),(30,86,'2024-05-07 01:00:00','angry'),(30,88,'2024-06-15 01:00:00','angry');
/*!40000 ALTER TABLE `react` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'phantom_assassin','phantom_assassin@gmail.com','gmail',87,'https://example.com/avatars/phantom_assassin.jpg'),(2,'juggernaut','juggernaut@outlook.com','facebook',85,NULL),(3,'crystal_maiden','crystal_maiden@gmail.com','github',85,'https://example.com/avatars/crystal_maiden.jpg'),(4,'earthshaker','earthshaker@apple.com','apple',85,'https://example.com/avatars/earthshaker.jpg'),(5,'axe','axe@dota2.com','gmail',85,NULL),(6,'sniper','sniper@yahoo.com','facebook',85,'https://example.com/avatars/sniper.jpg'),(7,'viper','viper@outlook.com','github',85,NULL),(8,'drow_ranger','drow_ranger@gmail.com','apple',88,'https://example.com/avatars/drow_ranger.jpg'),(9,'tidehunter','tidehunter@hotmail.com','gmail',85,NULL),(10,'ursa','ursa@dota2.com','github',85,'https://example.com/avatars/ursa.jpg'),(11,'pudge','pudge@apple.com','facebook',91,'https://example.com/avatars/pudge.jpg'),(12,'invoker','invoker@gmail.com','gmail',85,'https://example.com/avatars/invoker.jpg'),(13,'lich','lich@outlook.com','github',70,NULL),(14,'enigma','enigma@dota2.com','apple',84,'https://example.com/avatars/enigma.jpg'),(15,'anti_mage','anti_mage@yahoo.com','gmail',29,'https://example.com/avatars/anti_mage.jpg'),(16,'slark','slark@hotmail.com','facebook',52,NULL),(17,'witch_doctor','witch_doctor@dota2.com','github',66,'https://example.com/avatars/witch_doctor.jpg'),(18,'bloodseeker','bloodseeker@gmail.com','apple',79,NULL),(19,'tinker','tinker@outlook.com','gmail',40,'https://example.com/avatars/tinker.jpg'),(20,'mirana','mirana@yahoo.com','facebook',95,'https://example.com/avatars/mirana.jpg'),(21,'faceless_void','faceless_void@hotmail.com','github',67,NULL),(22,'spectre','spectre@dota2.com','apple',85,'https://example.com/avatars/spectre.jpg'),(23,'riki','riki@gmail.com','gmail',44,'https://example.com/avatars/riki.jpg'),(24,'vengeful_spirit','vengeful_spirit@outlook.com','facebook',81,NULL),(25,'shadow_shaman','shadow_shaman@dota2.com','github',53,'https://example.com/avatars/shadow_shaman.jpg'),(26,'bounty_hunter','bounty_hunter@gmail.com','apple',92,'https://example.com/avatars/bounty_hunter.jpg'),(27,'centaur_warrunner','centaur_warrunner@hotmail.com','gmail',36,NULL),(28,'ember_spirit','ember_spirit@dota2.com','facebook',77,'https://example.com/avatars/ember_spirit.jpg'),(29,'meepo','meepo@gmail.com','github',61,'https://example.com/avatars/meepo.jpg'),(30,'rubick','rubick@outlook.com','apple',47,NULL);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-08-30  4:20:08
