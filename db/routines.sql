
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


call proximity_effects.GetBusinesses(3,22169, NULL, NULL, NULL, NULL, 10000);