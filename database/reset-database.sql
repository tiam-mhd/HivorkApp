-- Script to reset database for development
-- Run this when you need to sync schema from scratch

-- Disconnect all connections
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'hivork_db'
  AND pid <> pg_backend_pid();

-- Drop and recreate database
DROP DATABASE IF EXISTS hivork_db;
CREATE DATABASE hivork_db;

-- Switch to the new database
\c hivork_db;

-- Create uuid extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE hivork_db TO postgres;
