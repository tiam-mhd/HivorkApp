-- Create product_categories table
CREATE TABLE IF NOT EXISTS product_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(20),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_category_business FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

-- Create closure table for tree structure
CREATE TABLE IF NOT EXISTS product_categories_closure (
    id_ancestor UUID NOT NULL REFERENCES product_categories(id) ON DELETE CASCADE,
    id_descendant UUID NOT NULL REFERENCES product_categories(id) ON DELETE CASCADE,
    PRIMARY KEY (id_ancestor, id_descendant)
);

-- Create indexes
CREATE INDEX idx_product_categories_business ON product_categories(business_id);
CREATE INDEX idx_product_categories_name ON product_categories(business_id, name);
CREATE INDEX idx_product_categories_sort ON product_categories(sort_order);

-- Update products table to allow NULL category (for uncategorized products)
ALTER TABLE products ALTER COLUMN category DROP NOT NULL;
ALTER TABLE products ALTER COLUMN category DROP DEFAULT;
COMMENT ON COLUMN products.category IS 'Category ID reference to product_categories table, NULL means uncategorized';
