
DROP DATABASE IF EXISTS proximity_effects_2;

CREATE DATABASE proximity_effects_2;

USE proximity_effects_2;

-- -------------------------
-- TABLES
-- -------------------------

CREATE TABLE Area(
	ID int NOT NULL AUTO_INCREMENT,
	Name varchar(25) NOT NULL,
	IsActive bool NOT NULL,
    PRIMARY KEY (ID)
) ENGINE=MYISAM CHARACTER SET UTF8;
;

CREATE TABLE Business(
	ID bigint NOT NULL AUTO_INCREMENT,
	Name varchar(100) NOT NULL,
	Longitude float(13,9) NOT NULL,
	Latitude float(13,9) NOT NULL,
	ReviewCount int NOT NULL,
	YelpStars float NOT NULL,
    AreaID int NOT NULL,
    Density int NULL,
	PRIMARY KEY (ID),
    FOREIGN KEY (AreaID) REFERENCES Area(ID) ON DELETE RESTRICT
) ENGINE=MYISAM CHARACTER SET UTF8;
;

CREATE TABLE Category(
	ID bigint NOT NULL AUTO_INCREMENT,
	Name varchar(100) NOT NULL,
	PRIMARY KEY (ID)
) ENGINE=MYISAM CHARACTER SET UTF8;
;

CREATE TABLE BusinessCategory(
	ID int NOT NULL AUTO_INCREMENT,
	BusinessID bigint NOT NULL,
	CategoryID bigint NOT NULL,
    PRIMARY KEY (ID),
	FOREIGN KEY (BusinessID) REFERENCES Business(ID) ON DELETE RESTRICT,
    FOREIGN KEY (CategoryID) REFERENCES Category(ID) ON DELETE RESTRICT
) ENGINE=MYISAM CHARACTER SET UTF8
;

CREATE TABLE SavedAnalysis(
	ID bigint NOT NULL AUTO_INCREMENT,
    Description varchar(250) NOT NULL,
	AreaID int NOT NULL,
    Category1ID int NULL,
    Category2ID int NULL,
    Category3ID int NULL,
    Category4ID int NULL,
    Category5ID int NULL,
    -- The collection of summary statistics that provided here is not particularly
    -- important to the overall design and could be extended or reduced in this
    -- list of columns.
	-- BEGIN SUMMARY STATISTICS
    BusinessCount int NOT NULL,
    MeanRating int NOT NULL,
    StDevRating double NOT NULL,
    AveragePopulationDensity int NOT NULL,
	-- END SUMMARY STATISTICS
	PRIMARY KEY (ID),
    FOREIGN KEY (Category1ID) REFERENCES Category(ID) ON DELETE RESTRICT,
    FOREIGN KEY (Category2ID) REFERENCES Category(ID) ON DELETE RESTRICT,
    FOREIGN KEY (Category3ID) REFERENCES Category(ID) ON DELETE RESTRICT,
    FOREIGN KEY (Category4ID) REFERENCES Category(ID) ON DELETE RESTRICT,
    FOREIGN KEY (Category5ID) REFERENCES Category(ID) ON DELETE RESTRICT
) ENGINE=MYISAM CHARACTER SET UTF8
;

CREATE TABLE SavedAnalysisDetail(
	ID int NOT NULL AUTO_INCREMENT,
	SavedAnalysisID bigint NOT NULL,
    Radius double NOT NULL,
    MeanRating double NOT NULL,
    StDevRating double NOT NULL,
    PRIMARY KEY (ID),
    FOREIGN KEY (SavedAnalysisID) REFERENCES SavedAnalsyis(ID) ON DELETE CASCADE
) ENGINE=MYISAM CHARACTER SET UTF8
;

-- -------------------------
-- DATA
-- -------------------------

-- For performance reasons, load tables with their initial data before creating indexes.

/*
LOAD DATA INFILE '/home/ubuntu/projects/proximity-effects/data/area.csv'
INTO TABLE Area
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

LOAD DATA INFILE '/home/ubuntu/projects/proximity-effects/data/business.csv'
INTO TABLE Business
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

LOAD DATA INFILE '/home/ubuntu/projects/proximity-effects/data/category.csv'
INTO TABLE Category
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

LOAD DATA INFILE '/home/ubuntu/projects/proximity-effects/data/business-category.csv'
INTO TABLE BusinessCategory
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

LOAD DATA INFILE '/home/ubuntu/projects/proximity-effects/data/saved-analysis.csv'
INTO TABLE SavedAnalysis
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

LOAD DATA INFILE '/home/ubuntu/projects/proximity-effects/data/saved-analysis-category.csv'
INTO TABLE SavedAnalysisCategory
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

LOAD DATA INFILE '/home/ubuntu/projects/proximity-effects/data/saved-analysis-detail.csv'
INTO TABLE SavedAnalysisDetail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;
*/

-- -------------------------
-- INDEXES
-- -------------------------

-- No indexes are created on Area or Category because they have too few rows to benefit.

-- The application filters businesses by area.
CREATE INDEX IDX_Business_AreaID
ON Business (AreaID)
;

-- The application filters businesses by category.
CREATE INDEX IDX_BusinessCategory_BusinessID
ON BusinessCategory (BusinessID)
;

-- We retrieve all detail records for a single saved analysis.
CREATE INDEX IDX_SavedAnalysisDetail_SavedAnalysisID
ON SavedAnalysisDetail (SavedAnalysisID)
;

-- -------------------------
-- PROCEDURES
-- -------------------------

DROP PROCEDURE IF EXISTS GetAllAreas;
DELIMITER $$
CREATE PROCEDURE GetAllAreas()
BEGIN
	SELECT *
    FROM Area
    WHERE IsActive=1
    ORDER BY Name;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS GetAllCategories;
DELIMITER $$
CREATE PROCEDURE GetAllCategories()
BEGIN
	SELECT *
    FROM Category
    ORDER BY Name;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS GetBusinesses;
DELIMITER $$
CREATE PROCEDURE GetBusinesses(_AreaID int, _CategoryID1 int,
	_CategoryID2 int, _CategoryID3 int, _CategoryID4 int, _CategoryID5 int,
    _MaxRows int)
BEGIN
	SELECT b.*
	FROM Business b
    INNER JOIN BusinessCategory bc ON bc.BusinessID = b.ID
    WHERE AreaID = _AreaID
    AND bc.CategoryID in (_CategoryID1, _CategoryID2, _CategoryID3, _CategoryID4, _CategoryID5)
    LIMIT _MaxRows;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS GetSavedAnalysisWithDetail;
DELIMITER $$
CREATE PROCEDURE GetSavedAnalysisWithDetail(_SavedAnalysisID bigint)
BEGIN
	SELECT *
    FROM SavedAnalysis
    WHERE ID = _SavedAnalysisID;
    
    SELECT *
    FROM SavedAnalysisDetail
    WHERE SavedAnalysisID = _SavedAnalysisID;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS SaveAnalysis;
DELIMITER $$
CREATE PROCEDURE SaveAnalysis(_AreaID int, _Category1ID int, _Category2ID int, _Category3ID int,
	_Category4ID int, _Category5ID int, _Description varchar(250), _BusinessCount int,
    _MeanRating int, _StDevRating double, _AveragePopulationDensity int)
BEGIN
    INSERT INTO SavedAnalysis
    (AreaID, Category1ID, Category2ID, Category3ID, Category4ID, Category5ID,
    Description, BusinessCount, MeanRating, StDevRating, AveragePopulationDensity)
    VALUES (_AreaID, _Category1ID, _Category2ID, _Category3ID, _Category4ID, _Category5ID,
    _Description, _BusinessCount, _MeanRating, _StDevRating, _AveragePopulationDensity);
    
    SELECT LAST_INSERT_ID() as ID;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS SaveAnalysisDetail;
DELIMITER $$
CREATE PROCEDURE SaveAnalysisDetail(_SavedAnalysisID int, _Radius double, _MeanRating double,
	_StDevRating double)
BEGIN
	INSERT INTO SavedAnalysisDetail
    (SavedAnalysisID, Radius, MeanRating, StDevRating)
    VALUES
    (_SavedAnalysisID, _Radius, _MeanRating, _StDevRating);
END $$
DELIMITER ;
