-- Create customer_groups table
CREATE TABLE IF NOT EXISTS customer_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    color VARCHAR(7),
    icon VARCHAR(50),
    discount_rate DECIMAL(5, 2) DEFAULT 0,
    payment_term_days INTEGER DEFAULT 0,
    credit_limit DECIMAL(15, 2) DEFAULT 0,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(business_id, name)
);

CREATE INDEX IF NOT EXISTS idx_customer_groups_business_id ON customer_groups(business_id);

-- Add groupId column to customers table
ALTER TABLE customers ADD COLUMN IF NOT EXISTS group_id UUID REFERENCES customer_groups(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_customers_group_id ON customers(group_id);

-- Remove old customerGroup enum column if it exists (migrate data first if needed)
-- NOTE: If you have existing data, you may want to create default groups and migrate the data
-- For now, we'll just drop the column
ALTER TABLE customers DROP COLUMN IF EXISTS customer_group;

-- Optional: Create default groups for existing businesses
INSERT INTO customer_groups (name, description, color, icon, business_id, sort_order)
SELECT 
    'عمومی' as name,
    'مشتریان عمومی' as description,
    '#9E9E9E' as color,
    'people' as icon,
    id as business_id,
    1 as sort_order
FROM businesses
ON CONFLICT (business_id, name) DO NOTHING;

INSERT INTO customer_groups (name, description, color, icon, discount_rate, business_id, sort_order)
SELECT 
    'VIP' as name,
    'مشتریان ویژه' as description,
    '#FFD700' as color,
    'star' as icon,
    5.0 as discount_rate,
    id as business_id,
    2 as sort_order
FROM businesses
ON CONFLICT (business_id, name) DO NOTHING;

INSERT INTO customer_groups (name, description, color, icon, discount_rate, credit_limit, business_id, sort_order)
SELECT 
    'عمده فروش' as name,
    'خریداران عمده' as description,
    '#2196F3' as color,
    'store' as icon,
    10.0 as discount_rate,
    100000000 as credit_limit,
    id as business_id,
    3 as sort_order
FROM businesses
ON CONFLICT (business_id, name) DO NOTHING;
