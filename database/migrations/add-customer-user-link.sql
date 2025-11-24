-- Migration: Add userId to customers table to link customers with user accounts
-- Date: 2025-11-23

-- Add userId column to customers table
ALTER TABLE customers
ADD COLUMN "userId" UUID;

-- Add index for userId
CREATE INDEX idx_customers_userId ON customers("userId");

-- Add foreign key constraint to users table
ALTER TABLE customers
ADD CONSTRAINT fk_customers_userId
FOREIGN KEY ("userId") REFERENCES users(id)
ON DELETE SET NULL;

-- Add comment
COMMENT ON COLUMN customers."userId" IS 'Link to user account if customer has registered in the system';
