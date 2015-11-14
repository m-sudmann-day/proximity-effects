
DROP DATABASE IF EXISTS proximity_effects;

CREATE DATABASE proximity_effects;

USE proximity_effects;

-- CREATE TABLES

CREATE TABLE Area(
	ID int NOT NULL,
	Name varchar(25) NOT NULL,
	IsActive bool NOT NULL,
    PRIMARY KEY (ID)
);

CREATE TABLE Business(
	ID bigint NOT NULL,
	Name varchar(100) NOT NULL,
	Longitude float(13,9) NOT NULL,
	Latitude float(13,9) NOT NULL,
	ReviewCount int NOT NULL,
	YelpStars float NOT NULL,
    AreaID int NOT NULL,
    Density int NULL,
	PRIMARY KEY (ID),
    FOREIGN KEY (AreaID) REFERENCES Area(ID) ON DELETE RESTRICT
);

CREATE TABLE Category(
	ID bigint NOT NULL,
	Name varchar(100) NOT NULL,
	PRIMARY KEY (ID)
);

CREATE TABLE BusinessCategory(
	BusinessID bigint NOT NULL,
	CategoryID bigint NOT NULL,
    FOREIGN KEY (BusinessID) REFERENCES Business(ID) ON DELETE RESTRICT,
    FOREIGN KEY (CategoryID) REFERENCES Category(ID) ON DELETE RESTRICT
);

CREATE TABLE User(
	ID bigint NOT NULL,
	ReviewCount int NOT NULL,
	AverageStars float NOT NULL,
	PRIMARY KEY (ID)
);

CREATE TABLE Review(
	UserID bigint NOT NULL,
	BusinessID bigint NOT NULL,
	Date datetime NOT NULL,
	Stars float NOT NULL,
	FOREIGN KEY (UserID) REFERENCES User(ID) ON DELETE RESTRICT,
	FOREIGN KEY (BusinessID) REFERENCES Business(ID) ON DELETE RESTRICT
);

CREATE TABLE AreaCategory(
	AreaID int NOT NULL,
	CategoryID bigint NOT NULL,
    BusinessCount int NOT NULL,
    FOREIGN KEY (AreaID) REFERENCES Area(ID) ON DELETE RESTRICT,
    FOREIGN KEY (CategoryID) REFERENCES Category(ID) ON DELETE RESTRICT
);
