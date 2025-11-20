# 🏗️ معماری Backend و طراحی Database - Hivork

## 📐 نمای کلی معماری

### Stack Technology
```
Backend Framework: NestJS (Node.js)
Database: PostgreSQL 15+
Cache: Redis 7+
File Storage: AWS S3 / Minio
Search Engine: Elasticsearch (فاز 2)
Message Queue: Bull (Redis-based)
API Documentation: Swagger/OpenAPI
```

### چرا NestJS؟
```
✅ معماری Modular و Scalable
✅ TypeScript Native
✅ Dependency Injection
✅ Built-in Testing Support
✅ Microservices Ready
✅ Enterprise-Grade
```

---

## 🗄️ طراحی Database Schema

### معماری Multi-Tenancy

```sql
-- استراتژی: Shared Database + Row-Level Security
-- هر کسب‌وکار یک tenant_id دارد
-- تمام جداول دارای tenant_id هستند
```

### Schema اصلی

#### 1️⃣ Authentication & Users Module

```sql
-- جدول کاربران اصلی
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500),
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP -- Soft delete
);

-- Index ها
CREATE INDEX idx_users_phone ON users(phone) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_is_active ON users(is_active);

-- جدول توکن‌های احراز هویت
CREATE TABLE user_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_type VARCHAR(50) NOT NULL, -- 'access', 'refresh', 'reset_password', 'verify_phone'
    token VARCHAR(500) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN DEFAULT false,
    device_info JSONB, -- {device: 'iPhone 13', browser: 'Safari', ip: '1.2.3.4'}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tokens_user_id ON user_tokens(user_id);
CREATE INDEX idx_tokens_token ON user_tokens(token) WHERE is_revoked = false;
CREATE INDEX idx_tokens_expires ON user_tokens(expires_at) WHERE is_revoked = false;

-- جدول لاگ‌های امنیتی
CREATE TABLE security_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL, -- 'login', 'logout', 'password_change', 'failed_login'
    ip_address VARCHAR(45),
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_security_logs_user_id ON security_logs(user_id);
CREATE INDEX idx_security_logs_created_at ON security_logs(created_at);
```

#### 2️⃣ Business Module

```sql
-- جدول دسته‌بندی کسب‌وکارها (توسط ادمین)
CREATE TABLE business_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_fa VARCHAR(255) NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(100), -- icon name from icon library
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول کسب‌وکارها
CREATE TABLE businesses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES business_categories(id) ON DELETE SET NULL,
    
    -- اطلاعات اصلی
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL, -- برای URL اختصاصی
    description TEXT,
    logo_url VARCHAR(500),
    cover_url VARCHAR(500),
    
    -- اطلاعات تماس
    phone VARCHAR(15),
    email VARCHAR(255),
    website VARCHAR(255),
    
    -- اطلاعات آدرس
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(2) DEFAULT 'IR',
    location POINT, -- برای نقشه
    
    -- اطلاعات مالی و قانونی
    national_id VARCHAR(50), -- شناسه ملی/کد اقتصادی
    tax_id VARCHAR(50), -- شماره مالیاتی
    registration_number VARCHAR(50),
    
    -- تنظیمات
    settings JSONB DEFAULT '{}', -- {currency: 'IRR', timezone: 'Asia/Tehran', ...}
    
    -- وضعیت و محدودیت‌ها
    subscription_plan VARCHAR(50) DEFAULT 'free', -- 'free', 'starter', 'professional', 'enterprise'
    subscription_expires_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    
    -- متادیتا
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_businesses_owner_id ON businesses(owner_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_businesses_slug ON businesses(slug) WHERE deleted_at IS NULL;
CREATE INDEX idx_businesses_category_id ON businesses(category_id);
CREATE INDEX idx_businesses_is_active ON businesses(is_active);

-- جدول اعضای کسب‌وکار (برای دسترسی چند کاربره)
CREATE TABLE business_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'member', -- 'owner', 'admin', 'manager', 'member', 'viewer'
    permissions JSONB DEFAULT '[]', -- ['invoices.create', 'products.edit', ...]
    is_active BOOLEAN DEFAULT true,
    invited_by UUID REFERENCES users(id),
    invited_at TIMESTAMP,
    joined_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(business_id, user_id)
);

CREATE INDEX idx_business_members_business_id ON business_members(business_id);
CREATE INDEX idx_business_members_user_id ON business_members(user_id);
```

#### 3️⃣ Product Module

```sql
-- جدول دسته‌بندی محصولات
CREATE TABLE product_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES product_categories(id) ON DELETE CASCADE,
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_product_categories_business_id ON product_categories(business_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_product_categories_parent_id ON product_categories(parent_id);

-- جدول ویژگی‌های محصول (مثل رنگ، سایز، ...)
CREATE TABLE product_attributes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL, -- 'رنگ', 'سایز', 'جنس'
    type VARCHAR(50) NOT NULL DEFAULT 'text', -- 'text', 'select', 'multiselect', 'color'
    values JSONB DEFAULT '[]', -- ['قرمز', 'آبی', 'سبز'] یا [{'value': 'red', 'label': 'قرمز', 'hex': '#FF0000'}]
    is_required BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_attributes_business_id ON product_attributes(business_id);

-- جدول محصولات
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    category_id UUID REFERENCES product_categories(id) ON DELETE SET NULL,
    
    -- اطلاعات اصلی
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL, -- برای URL
    sku VARCHAR(100), -- کد محصول
    barcode VARCHAR(100), -- بارکد
    description TEXT,
    short_description TEXT,
    
    -- قیمت‌گذاری
    price DECIMAL(15, 2) NOT NULL DEFAULT 0,
    cost_price DECIMAL(15, 2), -- قیمت خرید (دلخواه)
    compare_at_price DECIMAL(15, 2), -- قیمت قبل از تخفیف
    
    -- موجودی
    track_inventory BOOLEAN DEFAULT true,
    stock_quantity INTEGER DEFAULT 0,
    low_stock_threshold INTEGER DEFAULT 5, -- هشدار موجودی کم
    
    -- تصاویر
    images JSONB DEFAULT '[]', -- [{'url': '...', 'alt': '...', 'order': 1}]
    thumbnail_url VARCHAR(500),
    
    -- وزن و ابعاد (برای محاسبه هزینه ارسال)
    weight DECIMAL(10, 2), -- کیلوگرم
    dimensions JSONB, -- {length: 10, width: 5, height: 3, unit: 'cm'}
    
    -- ویژگی‌ها
    attributes JSONB DEFAULT '{}', -- {color: 'red', size: 'L'}
    
    -- SEO
    meta_title VARCHAR(255),
    meta_description TEXT,
    meta_keywords TEXT,
    
    -- وضعیت
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false, -- محصول ویژه
    published_at TIMESTAMP,
    
    -- آمار
    view_count INTEGER DEFAULT 0,
    sale_count INTEGER DEFAULT 0,
    
    -- متادیتا
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    UNIQUE(business_id, slug)
);

CREATE INDEX idx_products_business_id ON products(business_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_sku ON products(sku) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_barcode ON products(barcode) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_is_active ON products(is_active);
CREATE INDEX idx_products_is_featured ON products(is_featured);

-- جدول واریانت‌های محصول (مثلاً تی‌شرت قرمز سایز L)
CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    
    -- اطلاعات واریانت
    name VARCHAR(255), -- 'قرمز - L'
    sku VARCHAR(100),
    barcode VARCHAR(100),
    
    -- قیمت اختصاصی (اگر با محصول اصلی فرق دارد)
    price DECIMAL(15, 2),
    cost_price DECIMAL(15, 2),
    
    -- موجودی اختصاصی
    stock_quantity INTEGER DEFAULT 0,
    
    -- ویژگی‌های واریانت
    attributes JSONB NOT NULL DEFAULT '{}', -- {color: 'red', size: 'L'}
    
    -- تصویر اختصاصی
    image_url VARCHAR(500),
    
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_product_variants_product_id ON product_variants(product_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_product_variants_business_id ON product_variants(business_id);
CREATE INDEX idx_product_variants_sku ON product_variants(sku) WHERE deleted_at IS NULL;

-- جدول تاریخچه موجودی
CREATE TABLE inventory_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    variant_id UUID REFERENCES product_variants(id) ON DELETE SET NULL,
    
    type VARCHAR(50) NOT NULL, -- 'in', 'out', 'adjustment', 'return'
    quantity INTEGER NOT NULL, -- مثبت یا منفی
    quantity_before INTEGER NOT NULL,
    quantity_after INTEGER NOT NULL,
    
    reason VARCHAR(255), -- 'خرید', 'فروش', 'اصلاح', 'مرجوعی'
    reference_type VARCHAR(50), -- 'invoice', 'purchase_order', 'adjustment'
    reference_id UUID, -- id فاکتور یا سفارش
    
    unit_cost DECIMAL(15, 2), -- قیمت واحد (برای محاسبه ارزش موجودی)
    
    note TEXT,
    performed_by UUID REFERENCES users(id),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_inventory_transactions_business_id ON inventory_transactions(business_id);
CREATE INDEX idx_inventory_transactions_product_id ON inventory_transactions(product_id);
CREATE INDEX idx_inventory_transactions_created_at ON inventory_transactions(created_at);
```

#### 4️⃣ Customer Module

```sql
-- جدول مشتریان
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- اگر مشتری در سیستم ثبت‌نام کرده باشد
    
    -- اطلاعات اصلی (الزامی)
    phone VARCHAR(15) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    
    -- اطلاعات اضافی (دلخواه)
    email VARCHAR(255),
    national_id VARCHAR(50), -- کد ملی
    company_name VARCHAR(255), -- نام شرکت (برای مشتریان حقوقی)
    
    -- آدرس‌ها (JSON Array)
    addresses JSONB DEFAULT '[]', 
    /* [{
        id: 'uuid',
        title: 'منزل',
        full_address: '...',
        city: 'تهران',
        state: 'تهران',
        postal_code: '...',
        location: {lat: 35.6892, lng: 51.3890},
        is_default: true
    }] */
    
    -- اطلاعات تماس اضافی
    phone_secondary VARCHAR(15),
    social_media JSONB, -- {instagram: '@username', telegram: '@username'}
    
    -- دسته‌بندی مشتری
    customer_type VARCHAR(50) DEFAULT 'retail', -- 'retail', 'wholesale', 'vip'
    tags JSONB DEFAULT '[]', -- ['مشتری وفادار', 'خریدار عمده']
    
    -- اطلاعات مالی
    credit_limit DECIMAL(15, 2) DEFAULT 0, -- سقف اعتبار
    current_balance DECIMAL(15, 2) DEFAULT 0, -- بدهی یا بستانکار
    total_purchased DECIMAL(15, 2) DEFAULT 0, -- مجموع خرید
    
    -- آمار
    total_orders INTEGER DEFAULT 0,
    last_order_date TIMESTAMP,
    
    -- یادداشت‌ها
    notes TEXT,
    
    -- وضعیت
    is_active BOOLEAN DEFAULT true,
    is_blocked BOOLEAN DEFAULT false,
    blocked_reason TEXT,
    
    -- متادیتا
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    UNIQUE(business_id, phone)
);

CREATE INDEX idx_customers_business_id ON customers(business_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_user_id ON customers(user_id);
CREATE INDEX idx_customers_is_active ON customers(is_active);

-- جدول گروه‌های مشتریان (برای ارسال پیام گروهی، تخفیف گروهی و...)
CREATE TABLE customer_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- فیلترهای خودکار
    auto_filter JSONB, -- {total_purchased: {gte: 10000000}, total_orders: {gte: 5}}
    
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول ارتباط مشتری و گروه
CREATE TABLE customer_group_members (
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES customer_groups(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (customer_id, group_id)
);

-- جدول تاریخچه تعاملات با مشتری
CREATE TABLE customer_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    
    type VARCHAR(50) NOT NULL, -- 'call', 'email', 'sms', 'meeting', 'note'
    subject VARCHAR(255),
    description TEXT,
    
    performed_by UUID REFERENCES users(id),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_customer_interactions_customer_id ON customer_interactions(customer_id);
CREATE INDEX idx_customer_interactions_created_at ON customer_interactions(created_at);
```

#### 5️⃣ Invoice Module

```sql
-- جدول فاکتورها
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    
    -- شماره فاکتور
    invoice_number VARCHAR(50) NOT NULL, -- INV-2025-0001
    
    -- نوع فاکتور
    type VARCHAR(50) DEFAULT 'sale', -- 'sale', 'return', 'proforma'
    
    -- وضعیت
    status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'pending', 'confirmed', 'paid', 'partially_paid', 'cancelled', 'refunded'
    
    -- تاریخ‌ها
    issue_date DATE NOT NULL,
    due_date DATE,
    paid_date DATE,
    
    -- مبالغ
    subtotal DECIMAL(15, 2) NOT NULL DEFAULT 0, -- جمع کل بدون تخفیف و مالیات
    discount_amount DECIMAL(15, 2) DEFAULT 0,
    discount_percentage DECIMAL(5, 2) DEFAULT 0,
    tax_amount DECIMAL(15, 2) DEFAULT 0, -- مالیات
    tax_percentage DECIMAL(5, 2) DEFAULT 0,
    shipping_cost DECIMAL(15, 2) DEFAULT 0,
    total_amount DECIMAL(15, 2) NOT NULL DEFAULT 0, -- مبلغ نهایی
    paid_amount DECIMAL(15, 2) DEFAULT 0, -- مبلغ پرداخت شده
    remaining_amount DECIMAL(15, 2) DEFAULT 0, -- مانده
    
    -- اطلاعات ارسال
    shipping_address JSONB, -- کپی از آدرس مشتری
    shipping_method VARCHAR(100), -- 'پست', 'تیپاکس', 'پیک'
    tracking_code VARCHAR(100), -- کد رهگیری
    shipping_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'processing', 'shipped', 'delivered'
    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP,
    
    -- یادداشت‌ها
    customer_note TEXT, -- یادداشت مشتری
    internal_note TEXT, -- یادداشت داخلی
    
    -- متادیتا
    metadata JSONB DEFAULT '{}',
    
    -- ارجاع به سفارش والد (برای مرجوعی)
    parent_invoice_id UUID REFERENCES invoices(id),
    
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    UNIQUE(business_id, invoice_number)
);

CREATE INDEX idx_invoices_business_id ON invoices(business_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_invoices_customer_id ON invoices(customer_id);
CREATE INDEX idx_invoices_invoice_number ON invoices(invoice_number);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_issue_date ON invoices(issue_date);

-- جدول اقلام فاکتور
CREATE TABLE invoice_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    variant_id UUID REFERENCES product_variants(id) ON DELETE SET NULL,
    
    -- اطلاعات محصول (snapshot در زمان فروش)
    product_name VARCHAR(255) NOT NULL,
    product_sku VARCHAR(100),
    variant_name VARCHAR(255),
    
    -- قیمت و تعداد
    quantity DECIMAL(10, 2) NOT NULL,
    unit_price DECIMAL(15, 2) NOT NULL,
    discount_amount DECIMAL(15, 2) DEFAULT 0,
    tax_amount DECIMAL(15, 2) DEFAULT 0,
    total_price DECIMAL(15, 2) NOT NULL, -- (quantity * unit_price) - discount + tax
    
    -- یادداشت
    note TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_invoice_items_invoice_id ON invoice_items(invoice_id);
CREATE INDEX idx_invoice_items_product_id ON invoice_items(product_id);

-- جدول پرداخت‌ها
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    
    -- مبلغ و روش پرداخت
    amount DECIMAL(15, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL, -- 'cash', 'card', 'transfer', 'online', 'check'
    
    -- وضعیت
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'completed', 'failed', 'refunded'
    
    -- اطلاعات تراکنش
    transaction_id VARCHAR(255), -- شماره تراکنش بانکی
    reference_number VARCHAR(255), -- شماره مرجع
    gateway_response JSONB, -- پاسخ درگاه پرداخت
    
    -- تاریخ
    payment_date DATE NOT NULL,
    
    -- یادداشت
    note TEXT,
    
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_business_id ON payments(business_id);
CREATE INDEX idx_payments_invoice_id ON payments(invoice_id);
CREATE INDEX idx_payments_customer_id ON payments(customer_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);
```

#### 6️⃣ Expense Module

```sql
-- جدول دسته‌بندی هزینه‌ها
CREATE TABLE expense_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES expense_categories(id) ON DELETE CASCADE,
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    color VARCHAR(7), -- #FF5733
    icon VARCHAR(50),
    
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_expense_categories_business_id ON expense_categories(business_id);
CREATE INDEX idx_expense_categories_parent_id ON expense_categories(parent_id);

-- جدول هزینه‌ها
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    category_id UUID REFERENCES expense_categories(id) ON DELETE SET NULL,
    
    -- اطلاعات اصلی
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- مبلغ
    amount DECIMAL(15, 2) NOT NULL,
    
    -- تاریخ
    expense_date DATE NOT NULL,
    
    -- روش پرداخت
    payment_method VARCHAR(50), -- 'cash', 'card', 'transfer', 'check'
    
    -- ارجاع
    reference_type VARCHAR(50), -- 'product_purchase', 'salary', 'rent', 'other'
    reference_id UUID, -- ارجاع به خرید محصول یا...
    
    -- فایل‌های پیوست (رسید، فاکتور)
    attachments JSONB DEFAULT '[]', -- [{url: '...', filename: '...', type: 'image/jpeg'}]
    
    -- وضعیت
    is_paid BOOLEAN DEFAULT true,
    
    -- یادداشت
    note TEXT,
    
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_expenses_business_id ON expenses(business_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_expenses_category_id ON expenses(category_id);
CREATE INDEX idx_expenses_expense_date ON expenses(expense_date);
CREATE INDEX idx_expenses_reference ON expenses(reference_type, reference_id);
```

#### 7️⃣ Analytics & Reports Module

```sql
-- جدول آمار روزانه کسب‌وکار (Pre-aggregated)
CREATE TABLE business_daily_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    
    -- آمار فروش
    total_sales DECIMAL(15, 2) DEFAULT 0,
    total_orders INTEGER DEFAULT 0,
    total_products_sold INTEGER DEFAULT 0,
    average_order_value DECIMAL(15, 2) DEFAULT 0,
    
    -- آمار مشتری
    new_customers INTEGER DEFAULT 0,
    returning_customers INTEGER DEFAULT 0,
    
    -- آمار هزینه
    total_expenses DECIMAL(15, 2) DEFAULT 0,
    
    -- سود
    gross_profit DECIMAL(15, 2) DEFAULT 0, -- فروش - هزینه
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(business_id, date)
);

CREATE INDEX idx_business_daily_stats_business_date ON business_daily_stats(business_id, date DESC);

-- جدول محصولات پرفروش (Pre-calculated)
CREATE TABLE product_sales_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    
    period_type VARCHAR(20) NOT NULL, -- 'daily', 'weekly', 'monthly', 'yearly'
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    total_quantity_sold INTEGER DEFAULT 0,
    total_revenue DECIMAL(15, 2) DEFAULT 0,
    total_orders INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(business_id, product_id, period_type, period_start)
);

CREATE INDEX idx_product_sales_stats_business_period ON product_sales_stats(business_id, period_type, period_start DESC);
CREATE INDEX idx_product_sales_stats_product ON product_sales_stats(product_id);
```

#### 8️⃣ Notification & Communication Module

```sql
-- جدول نوتیفیکیشن‌ها
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    
    type VARCHAR(50) NOT NULL, -- 'invoice_created', 'payment_received', 'low_stock', 'system'
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    
    action_url VARCHAR(500), -- URL برای کلیک روی نوتیفیکیشن
    metadata JSONB DEFAULT '{}',
    
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- جدول ارسال SMS/Email
CREATE TABLE message_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES businesses(id) ON DELETE SET NULL,
    
    type VARCHAR(20) NOT NULL, -- 'sms', 'email'
    recipient VARCHAR(255) NOT NULL, -- شماره تلفن یا ایمیل
    
    subject VARCHAR(255), -- برای email
    body TEXT NOT NULL,
    
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'sent', 'failed', 'delivered'
    
    provider VARCHAR(50), -- 'sms.ir', 'kavenegar', 'sendgrid'
    provider_response JSONB,
    
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    
    error_message TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_message_logs_business_id ON message_logs(business_id);
CREATE INDEX idx_message_logs_status ON message_logs(status);
CREATE INDEX idx_message_logs_created_at ON message_logs(created_at DESC);
```

#### 9️⃣ System & Admin Module

```sql
-- جدول تنظیمات سیستم
CREATE TABLE system_settings (
    key VARCHAR(255) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT false, -- قابل نمایش به کاربران عادی
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول پلن‌های اشتراک
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE, -- 'free', 'starter', 'professional', 'enterprise'
    display_name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- قیمت
    price_monthly DECIMAL(15, 2) NOT NULL,
    price_yearly DECIMAL(15, 2),
    
    -- محدودیت‌ها
    limits JSONB NOT NULL, 
    /* {
        businesses: 1,
        products: 50,
        invoices_per_month: 100,
        customers: 500,
        storage_mb: 100,
        api_calls_per_day: 0
    } */
    
    -- ویژگی‌ها
    features JSONB DEFAULT '[]', -- ['basic_reports', 'sms_integration', 'api_access']
    
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول اشتراک‌های کاربران
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),
    
    status VARCHAR(50) DEFAULT 'active', -- 'active', 'cancelled', 'expired', 'trial'
    
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    
    -- تراکنش پرداخت
    amount_paid DECIMAL(15, 2),
    payment_method VARCHAR(50),
    transaction_id VARCHAR(255),
    
    -- تمدید خودکار
    auto_renew BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subscriptions_business_id ON subscriptions(business_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_end_date ON subscriptions(end_date);

-- جدول لاگ‌های سیستم
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    business_id UUID REFERENCES businesses(id) ON DELETE SET NULL,
    
    action VARCHAR(100) NOT NULL, -- 'invoice.create', 'product.update', 'user.delete'
    entity_type VARCHAR(50) NOT NULL, -- 'invoice', 'product', 'user'
    entity_id UUID,
    
    changes JSONB, -- {before: {...}, after: {...}}
    
    ip_address VARCHAR(45),
    user_agent TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_business_id ON audit_logs(business_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
```

---

## 🔐 Row-Level Security (RLS)

```sql
-- فعال‌سازی RLS برای جداول
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
-- ... سایر جداول

-- Policy نمونه برای دسترسی به کسب‌وکار
CREATE POLICY business_isolation_policy ON products
    USING (
        business_id IN (
            SELECT business_id 
            FROM business_members 
            WHERE user_id = current_setting('app.current_user_id')::UUID
            AND is_active = true
        )
    );
```

---

## 📊 Views (نماهای مفید)

```sql
-- نمای خلاصه فاکتورها
CREATE VIEW invoice_summary AS
SELECT 
    i.id,
    i.business_id,
    i.invoice_number,
    i.issue_date,
    i.status,
    i.total_amount,
    i.paid_amount,
    i.remaining_amount,
    c.full_name as customer_name,
    c.phone as customer_phone,
    COUNT(ii.id) as items_count
FROM invoices i
LEFT JOIN customers c ON i.customer_id = c.id
LEFT JOIN invoice_items ii ON i.id = ii.invoice_id
WHERE i.deleted_at IS NULL
GROUP BY i.id, c.id;

-- نمای موجودی محصولات
CREATE VIEW product_inventory AS
SELECT 
    p.id,
    p.business_id,
    p.name,
    p.sku,
    p.stock_quantity,
    p.low_stock_threshold,
    CASE 
        WHEN p.stock_quantity <= 0 THEN 'out_of_stock'
        WHEN p.stock_quantity <= p.low_stock_threshold THEN 'low_stock'
        ELSE 'in_stock'
    END as stock_status,
    p.price * p.stock_quantity as inventory_value
FROM products p
WHERE p.deleted_at IS NULL AND p.track_inventory = true;
```

---

**⏭️ بعدی: API Documentation**

📅 **تاریخ ایجاد**: 15 نوامبر 2025
🔄 **نسخه**: 1.0
