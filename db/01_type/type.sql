-- ===================================================
-- File: type.sql
-- Purpose: Defines custom data types for the database.
-- ===================================================

CREATE TYPE IDType FROM VARCHAR(16) NOT NULL;
CREATE TYPE LongitudeType FROM DECIMAL(11, 8) NOT NULL;
CREATE TYPE LatitudeType FROM DECIMAL(10, 8) NOT NULL;
CREATE TYPE MoneyType FROM DECIMAL(10, 2);