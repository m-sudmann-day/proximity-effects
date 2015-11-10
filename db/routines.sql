
USE distance_effects;

DELIMITER $$
CREATE PROCEDURE GetBusinessesForArea(AreaFilter varchar(6))
BEGIN
	SELECT ID, Name, Longitude, Latitude, ReviewCount, YelpStars
	FROM Business
    WHERE Area = AreaFilter;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetBusinessCategoriesForArea(AreaFilter varchar(6))
BEGIN
	SELECT bc.*
	FROM BusinessCategory bc
    INNER JOIN Business b ON bc.BusinessID = b.ID
    WHERE b.Area = AreaFilter;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetReviewsForArea(AreaFilter varchar(6))
BEGIN
	SELECT r.*
	FROM Review r
    INNER JOIN Business b ON r.BusinessID = b.ID
    WHERE b.Area = AreaFilter;
END $$
DELIMITER ;
