
USE proximity_effects;

DELIMITER $$
CREATE PROCEDURE GetAllAreas()
BEGIN
	SELECT b.*
	FROM Business b
    WHERE AreaID = _AreaID;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetBusinessesForArea(_AreaID int)
BEGIN
	SELECT b.*
	FROM Business b
    WHERE AreaID = _AreaID;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetBusinessCategoriesForArea(_AreaID int)
BEGIN
	SELECT bc.*
	FROM BusinessCategory bc
    INNER JOIN Business b ON bc.BusinessID = b.ID
    WHERE b.AreaID = _AreaID;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetReviewsForArea(_AreaID int)
BEGIN
	SELECT r.*
	FROM Review r
    INNER JOIN Business b ON r.BusinessID = b.ID
    WHERE b.Area = _AreaID;
END $$
DELIMITER ;
