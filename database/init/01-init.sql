-- Initial Database Setup for Hivork
-- این فایل به صورت خودکار هنگام راه‌اندازی PostgreSQL container اجرا می‌شود

-- Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create Schemas
CREATE SCHEMA IF NOT EXISTS public;
CREATE SCHEMA IF NOT EXISTS audit;

-- Set Timezone
SET timezone = 'Asia/Tehran';

-- Create Audit Table for tracking changes
CREATE TABLE IF NOT EXISTS audit.changes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(255) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL, -- INSERT, UPDATE, DELETE
    old_data JSONB,
    new_data JSONB,
    user_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster audit queries
CREATE INDEX IF NOT EXISTS idx_audit_changes_table ON audit.changes(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_changes_record ON audit.changes(record_id);
CREATE INDEX IF NOT EXISTS idx_audit_changes_created ON audit.changes(created_at);

-- Create base function for updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Log successful initialization
DO $$
BEGIN
    RAISE NOTICE 'Database initialized successfully at %', NOW();
END $$;
