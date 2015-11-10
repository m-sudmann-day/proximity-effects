
-- TODO: Indexes
-- TODO: Views

DROP DATABASE IF EXISTS distance_effects;

CREATE DATABASE distance_effects;

USE distance_effects;

-- CREATE TABLES

CREATE TABLE Business(
	ID bigint NOT NULL,
	State varchar(6) NULL,
	Name varchar(100) NULL,
	Longitude float(13,9) NOT NULL,
	Latitude float(13,9) NOT NULL,
	ReviewCount int NOT NULL,
	YelpStars float NOT NULL,
	PRIMARY KEY (ID)
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
	UserID bigint NULL,
	BusinessID bigint NULL,
	Date datetime NOT NULL,
	Stars float NOT NULL,
	FOREIGN KEY (UserID) REFERENCES User(ID) ON DELETE RESTRICT,
	FOREIGN KEY (BusinessID) REFERENCES Business(ID) ON DELETE RESTRICT
);
