
USE proximity_effects;

-- The application filters businesses by area.
CREATE INDEX IDX_Business_AreaID
ON Business (AreaID)
;

-- The application looks up all business categories for a business, or
-- for multiple businesses at once.
CREATE INDEX IDX_BusinessCategory_BusinessID
ON BusinessCategory (BusinessID)
;
