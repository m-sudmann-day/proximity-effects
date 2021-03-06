
USE proximity_effects;

DROP PROCEDURE IF EXISTS GetAllAreas;
DELIMITER $$
CREATE PROCEDURE GetAllAreas()
BEGIN
	SELECT *
    FROM Area
    WHERE IsActive = TRUE
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
CREATE PROCEDURE GetBusinesses(_AreaID int, _CategoryID int)
BEGIN
	SELECT b.*
	FROM Business b
    INNER JOIN BusinessCategory bc ON bc.BusinessID = b.ID
    WHERE AreaID = _AreaID
    AND bc.CategoryID = _CategoryID;
END $$
DELIMITER ;
