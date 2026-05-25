-- =======================================================
-- SQL Script to Create Database Schema
-- =======================================================


-- Drop the database if it already exists
USE master;
GO

IF DB_ID('CrabFood') IS NOT NULL
BEGIN
    PRINT 'Dropping existing CrabFood database...';
    ALTER DATABASE CrabFood SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CrabFood;
END
GO

-- Create SQL Server Login sManager
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'sManager')
BEGIN
    PRINT 'Creating SQL Server Login sManager...';
    CREATE LOGIN sManager WITH PASSWORD = 'db@TN01';
END
GO

-- Create the database
IF (DB_ID('CrabFood') IS NULL)
BEGIN
    PRINT 'Creating CrabFood database...';
    CREATE DATABASE CrabFood;
END
GO

-- Use the newly created database
USE CrabFood;
GO

-- Create User sManager for the database
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sManager')
BEGIN
    PRINT 'Creating database user sManager...';
    CREATE USER sManager FOR LOGIN sManager;
END
GO

ALTER ROLE db_owner ADD MEMBER sManager;
GO