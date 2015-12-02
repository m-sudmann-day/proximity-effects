
USE proximity_effects;

-- C:\\OneDrive\\BGSE\\GitHub\\proximity-effects\\data\\

-- LOAD DATA INFILE '/home/ubuntu/projects/proximity-effects/data/user.csv'
-- INTO TABLE User
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- ;

LOAD DATA INFILE '/home/ubuntu/projects/proximity-effects/data/area.csv'
INTO TABLE Area
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

LOAD DATA INFILE '/home/ubuntu/projects/proximity-effects/data/business3.csv'
INTO TABLE Business
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;

-- LOAD DATA INFILE '/home/ubuntu/projects/proximity-effects/data/review.csv'
-- INTO TABLE Review
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- ;

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
