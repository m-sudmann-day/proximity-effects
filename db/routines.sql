
USE proximity_effects;

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

DROP PROCEDURE IF EXISTS GetBusinessesForArea;
DELIMITER $$
CREATE PROCEDURE GetBusinessesForArea(_AreaID int, _CategoryID1 int,
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

DROP PROCEDURE IF EXISTS GetBusinessCategoriesForArea;
DELIMITER $$
CREATE PROCEDURE GetBusinessCategoriesForArea(_AreaID int)
BEGIN
	SELECT *
	FROM AreaCategory ac
    WHERE AreaID = _AreaID;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS GetReviewsForArea;
DELIMITER $$
CREATE PROCEDURE GetReviewsForArea(_AreaID int)
BEGIN
	SELECT r.*
	FROM Review r
    INNER JOIN Business b ON r.BusinessID = b.ID
    WHERE b.Area = _AreaID;
END $$
DELIMITER ;
