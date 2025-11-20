-- Drop old enums if exist
DROP TYPE IF EXISTS business_type CASCADE;
DROP TYPE IF EXISTS business_industry CASCADE;

-- Create business_categories table
CREATE TABLE IF NOT EXISTS business_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  "nameEn" VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(500),
  icon VARCHAR(100),
  color VARCHAR(20),
  "sortOrder" INTEGER DEFAULT 0,
  "isActive" BOOLEAN DEFAULT true,
  "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create business_industries table
CREATE TABLE IF NOT EXISTS business_industries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  "nameEn" VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(500),
  icon VARCHAR(100),
  color VARCHAR(7),
  "sortOrder" INTEGER DEFAULT 0,
  "isActive" BOOLEAN DEFAULT true,
  "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_business_categories_slug ON business_categories(slug);
CREATE INDEX idx_business_categories_is_active ON business_categories("isActive");
CREATE INDEX idx_business_industries_slug ON business_industries(slug);
CREATE INDEX idx_business_industries_is_active ON business_industries("isActive");

-- Add columns to businesses table
ALTER TABLE businesses DROP COLUMN IF EXISTS type;
ALTER TABLE businesses DROP COLUMN IF EXISTS industry;

ALTER TABLE businesses ADD COLUMN IF NOT EXISTS "categoryId" UUID;
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS "industryId" UUID;

-- Add foreign keys
ALTER TABLE businesses 
  ADD CONSTRAINT fk_business_category 
  FOREIGN KEY ("categoryId") 
  REFERENCES business_categories(id) 
  ON DELETE SET NULL;

ALTER TABLE businesses 
  ADD CONSTRAINT fk_business_industry 
  FOREIGN KEY ("industryId") 
  REFERENCES business_industries(id) 
  ON DELETE SET NULL;

-- Create indexes for foreign keys
CREATE INDEX idx_businesses_category_id ON businesses("categoryId");
CREATE INDEX idx_businesses_industry_id ON businesses("industryId");

-- Insert default categories
INSERT INTO business_categories (name, "nameEn", slug, description, icon, color, "sortOrder", "isActive") VALUES
  ('خرده‌فروشی', 'Retail', 'retail', 'فروش کالا به صورت خرده به مصرف‌کنندگان', 'store', '#2196F3', 1, true),
  ('عمده‌فروشی', 'Wholesale', 'wholesale', 'فروش کالا به صورت عمده به خرده‌فروشان', 'warehouse', '#9C27B0', 2, true),
  ('خدماتی', 'Service', 'service', 'ارائه خدمات به مشتریان', 'home_repair_service', '#4CAF50', 3, true),
  ('تولیدی', 'Manufacturing', 'manufacturing', 'تولید و ساخت کالا', 'factory', '#FF9800', 4, true),
  ('رستوران/کافه', 'Restaurant & Cafe', 'restaurant', 'ارائه غذا و نوشیدنی', 'restaurant', '#F44336', 5, true),
  ('آنلاین', 'Online Store', 'online', 'فروشگاه اینترنتی', 'shopping_cart', '#00BCD4', 6, true),
  ('سایر', 'Other', 'other', 'سایر انواع کسب و کار', 'more_horiz', '#757575', 99, true)
ON CONFLICT (slug) DO NOTHING;

-- Insert default industries
INSERT INTO business_industries (name, "nameEn", slug, description, icon, color, "sortOrder", "isActive") VALUES
  ('مواد غذایی', 'Food & Beverage', 'food', 'تولید، توزیع و فروش مواد غذایی', 'fastfood', '#FF5722', 1, true),
  ('پوشاک', 'Clothing & Fashion', 'clothing', 'طراحی، تولید و فروش پوشاک', 'checkroom', '#E91E63', 2, true),
  ('الکترونیک', 'Electronics', 'electronics', 'فروش و تعمیر لوازم الکترونیکی', 'devices', '#3F51B5', 3, true),
  ('آرایشی و بهداشتی', 'Beauty & Cosmetics', 'beauty', 'محصولات آرایشی و بهداشتی', 'face', '#9C27B0', 4, true),
  ('خودرو', 'Automotive', 'auto', 'فروش، تعمیر و خدمات خودرو', 'directions_car', '#607D8B', 5, true),
  ('سلامت و درمان', 'Healthcare', 'health', 'خدمات پزشکی و درمانی', 'medical_services', '#F44336', 6, true),
  ('آموزشی', 'Education', 'education', 'خدمات آموزشی و آموزشگاهی', 'school', '#2196F3', 7, true),
  ('ساختمانی', 'Construction', 'construction', 'ساخت و ساز و خدمات ساختمانی', 'construction', '#795548', 8, true),
  ('فناوری', 'Technology & IT', 'technology', 'خدمات فناوری اطلاعات', 'computer', '#00BCD4', 9, true),
  ('مالی', 'Finance & Banking', 'finance', 'خدمات مالی و بانکی', 'account_balance', '#4CAF50', 10, true),
  ('املاک', 'Real Estate', 'real-estate', 'خرید و فروش املاک', 'home', '#FF9800', 11, true),
  ('سرگرمی', 'Entertainment', 'entertainment', 'خدمات سرگرمی و تفریحی', 'movie', '#673AB7', 12, true),
  ('ورزشی', 'Sports & Fitness', 'sports', 'خدمات و تجهیزات ورزشی', 'fitness_center', '#009688', 13, true),
  ('کشاورزی', 'Agriculture', 'agriculture', 'تولیدات کشاورزی و دامی', 'agriculture', '#8BC34A', 14, true),
  ('حمل و نقل', 'Transportation', 'transportation', 'خدمات حمل و نقل', 'local_shipping', '#FFC107', 15, true),
  ('سایر', 'Other', 'other', 'سایر صنایع', 'more_horiz', '#757575', 99, true)
ON CONFLICT (slug) DO NOTHING;

COMMENT ON TABLE business_categories IS 'دسته‌بندی‌های کسب و کار - قابل مدیریت از داشبورد ادمین';
COMMENT ON TABLE business_industries IS 'صنایع کسب و کار - قابل مدیریت از داشبورد ادمین';
