-- Add business_industry enum
CREATE TYPE business_industry AS ENUM (
  'food',
  'clothing',
  'electronics',
  'beauty',
  'auto',
  'health',
  'education',
  'construction',
  'technology',
  'finance',
  'real_estate',
  'entertainment',
  'sports',
  'agriculture',
  'other'
);

-- Add industry column to businesses table
ALTER TABLE businesses 
ADD COLUMN industry business_industry;

-- Add 'online' to business_type enum
ALTER TYPE business_type ADD VALUE IF NOT EXISTS 'online';

-- Create index on industry column for better query performance
CREATE INDEX idx_businesses_industry ON businesses(industry) WHERE industry IS NOT NULL;

-- Comments for documentation
COMMENT ON COLUMN businesses.industry IS 'صنعت کسب و کار - مستقل از نوع کسب و کار';
COMMENT ON TYPE business_industry IS 'انواع صنایع قابل انتخاب برای کسب و کار';
