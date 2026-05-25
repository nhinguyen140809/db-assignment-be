-- ===================================================
-- File: initial_data.sql
-- Purpose: Insert minimal data required for system boot.
-- Includes:
--   - default admin account
--   - basic configuration rows
-- Notes: No demo data
-- ===================================================

INSERT INTO [administrator] ([username], [password_hash])
VALUES ('support_admin01', '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a'); -- password: 123, hashed with bcrypt
INSERT INTO [administrator] ([username], [password_hash])
VALUES ('support_admin02', '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a'); -- password: 123, hashed with bcrypt
INSERT INTO [administrator] ([username], [password_hash])
VALUES ('support_admin03', '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a'); -- password: 123, hashed with bcrypt
INSERT INTO [administrator] ([username], [password_hash])
VALUES ('support_admin04', '$2b$10$6l3NEPoPFc.CV3ZUt5VSKuHo2VNx8oKoO7qJrZ1pC2CqymNE6PF5a'); -- password: 123, hashed with bcrypt

INSERT INTO [category] ([name])
VALUES
    ('Fast Food'),
    ('Desserts'),
    ('Beverages'),
    ('Asian Cuisine'),
    ('Italian Cuisine'),
    ('Healthy Food');
