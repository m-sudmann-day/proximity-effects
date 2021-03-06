
USE proximity_effects;

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
