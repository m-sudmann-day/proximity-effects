
USE proximity_effects;

-- LOAD DATA INFILE 'C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data\\user.csv'
-- INTO TABLE User
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- ;

LOAD DATA INFILE 'C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data\\area.csv'
INTO TABLE Area
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

LOAD DATA INFILE 'C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data\\business3.csv'
INTO TABLE Business
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
;

-- LOAD DATA INFILE 'C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data\\review.csv'
-- INTO TABLE Review
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- ;

LOAD DATA INFILE 'C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data\\category.csv'
INTO TABLE Category
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

LOAD DATA INFILE 'C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data\\business-category.csv'
INTO TABLE BusinessCategory
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

-- Delete BusinessCategories for businesses that were not loaded because they had no reviews.
DELETE FROM BusinessCategory
WHERE BusinessID NOT IN
	(SELECT ID FROM Business);

-- Only after the previous line of cleanup can we now apply a foreign key.
ALTER TABLE BusinessCategory
ADD FOREIGN KEY (BusinessID) REFERENCES Business(ID) ON DELETE RESTRICT;
