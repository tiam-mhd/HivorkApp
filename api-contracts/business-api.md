# Business API Contract

## Overview
مدیریت کسب و کارها، ایجاد، ویرایش، حذف و دریافت اطلاعات کسب و کارها

**Base URL**: `/business`

**Authentication**: تمام endpointها نیاز به Bearer Token دارند

---

## Data Types

### BusinessType Enum
```typescript
enum BusinessType {
  RETAIL = 'retail',           // خرده‌فروشی
  WHOLESALE = 'wholesale',     // عمده‌فروشی
  SERVICE = 'service',         // خدماتی
  MANUFACTURING = 'manufacturing', // تولیدی
  RESTAURANT = 'restaurant',   // رستوران/کافه
  ONLINE = 'online',          // فروشگاه آنلاین
  OTHER = 'other',            // سایر
}
```

### BusinessIndustry Enum (پیشنهادی - نیاز به اضافه شدن در بک‌اند)
```typescript
enum BusinessIndustry {
  FOOD = 'food',               // مواد غذایی
  CLOTHING = 'clothing',       // پوشاک
  ELECTRONICS = 'electronics', // الکترونیک
  BEAUTY = 'beauty',           // آرایشی و بهداشتی
  AUTO = 'auto',               // خودرو
  HEALTH = 'health',           // سلامت و درمان
  EDUCATION = 'education',     // آموزشی
  CONSTRUCTION = 'construction', // ساختمانی
  TECHNOLOGY = 'technology',   // فناوری
  FINANCE = 'finance',         // مالی
  REAL_ESTATE = 'real_estate', // املاک
  ENTERTAINMENT = 'entertainment', // سرگرمی
  SPORTS = 'sports',           // ورزشی
  AGRICULTURE = 'agriculture', // کشاورزی
  OTHER = 'other',             // سایر
}
```

### BusinessStatus Enum
```typescript
enum BusinessStatus {
  ACTIVE = 'active',       // فعال
  INACTIVE = 'inactive',   // غیرفعال
  SUSPENDED = 'suspended', // معلق
}
```

### Business Object
```typescript
interface Business {
  id: string;                    // UUID
  name: string;                  // نام کسب و کار (حداکثر 200 کاراکتر)
  tradeName?: string;            // نام تجاری (حداکثر 200 کاراکتر)
  type: BusinessType;            // نوع کسب و کار
  industry?: BusinessIndustry;   // صنعت (پیشنهادی)
  status: BusinessStatus;        // وضعیت
  description?: string;          // توضیحات (حداکثر 500 کاراکتر)
  
  // اطلاعات ثبتی
  nationalId?: string;           // شناسه ملی (حداکثر 20 کاراکتر)
  registrationNumber?: string;   // شماره ثبت (حداکثر 20 کاراکتر)
  economicCode?: string;         // کد اقتصادی (حداکثر 20 کاراکتر)
  
  // اطلاعات تماس
  phone?: string;                // تلفن (حداکثر 15 کاراکتر)
  email?: string;                // ایمیل
  website?: string;              // وبسایت
  
  // آدرس
  address?: string;              // آدرس (حداکثر 500 کاراکتر)
  city?: string;                 // شهر (حداکثر 100 کاراکتر)
  state?: string;                // استان (حداکثر 100 کاراکتر)
  postalCode?: string;           // کد پستی (حداکثر 20 کاراکتر)
  
  // تنظیمات
  logo?: string;                 // URL لوگو
  currency: string;              // واحد پول (پیش‌فرض: IRR)
  locale: string;                // زبان (پیش‌فرض: fa-IR)
  timezone: string;              // منطقه زمانی (پیش‌فرض: Asia/Tehran)
  
  // تنظیمات پیشرفته
  settings?: {
    invoicePrefix?: string;           // پیشوند شماره فاکتور
    invoiceNumberFormat?: string;     // فرمت شماره فاکتور
    taxRate?: number;                 // نرخ مالیات
    enableInventory?: boolean;        // فعال‌سازی انبارداری
    lowStockThreshold?: number;       // آستانه موجودی کم
    [key: string]: any;
  };
  
  // روابط
  ownerId: string;               // شناسه مالک
  owner?: User;                  // مالک کسب و کار
  
  // تاریخ‌ها
  createdAt: Date;               // تاریخ ایجاد
  updatedAt: Date;               // تاریخ آخرین ویرایش
}
```

---

## Endpoints

### 1. Create Business
ایجاد کسب و کار جدید

**Endpoint**: `POST /business`

**Request Body**:
```json
{
  "name": "فروشگاه الکترونیک آریا",
  "tradeName": "آریا شاپ",
  "type": "retail",
  "industry": "electronics",
  "description": "فروش لوازم الکترونیکی و دیجیتال",
  "phone": "02112345678",
  "email": "info@ariashop.com",
  "website": "https://ariashop.com",
  "address": "تهران، خیابان ولیعصر، پلاک 123",
  "city": "تهران",
  "state": "تهران",
  "postalCode": "1234567890",
  "nationalId": "1234567890",
  "registrationNumber": "123456",
  "economicCode": "1234567890123"
}
```

**Required Fields**:
- `name`: نام کسب و کار
- `type`: نوع کسب و کار

**Response** (201 Created):
```json
{
  "success": true,
  "message": "کسب و کار با موفقیت ایجاد شد",
  "data": {
    "id": "uuid-here",
    "name": "فروشگاه الکترونیک آریا",
    "type": "retail",
    "industry": "electronics",
    "status": "active",
    "currency": "IRR",
    "locale": "fa-IR",
    "timezone": "Asia/Tehran",
    "ownerId": "user-uuid",
    "createdAt": "2024-01-01T12:00:00Z",
    "updatedAt": "2024-01-01T12:00:00Z",
    ...
  }
}
```

**Error Responses**:
- `409 Conflict`: کسب و کار با این نام قبلاً ثبت شده
- `400 Bad Request`: داده‌های ورودی نامعتبر
- `401 Unauthorized`: نیاز به احراز هویت

---

### 2. Get My Businesses
دریافت لیست کسب و کارهای کاربر

**Endpoint**: `GET /business/my-businesses`

**Response** (200 OK):
```json
{
  "success": true,
  "message": "کسب و کارهای شما با موفقیت دریافت شد",
  "data": [
    {
      "id": "uuid-1",
      "name": "فروشگاه الکترونیک آریا",
      "type": "retail",
      "industry": "electronics",
      "status": "active",
      "logo": "https://example.com/logo.png",
      "createdAt": "2024-01-01T12:00:00Z",
      ...
    }
  ]
}
```

---

### 3. Get Business Details
دریافت جزئیات یک کسب و کار

**Endpoint**: `GET /business/:id`

**Path Parameters**:
- `id`: شناسه کسب و کار (UUID)

**Response** (200 OK):
```json
{
  "success": true,
  "message": "جزئیات کسب و کار با موفقیت دریافت شد",
  "data": {
    "id": "uuid-here",
    "name": "فروشگاه الکترونیک آریا",
    "tradeName": "آریا شاپ",
    "type": "retail",
    "industry": "electronics",
    "status": "active",
    "description": "فروش لوازم الکترونیکی و دیجیتال",
    "phone": "02112345678",
    "email": "info@ariashop.com",
    "address": "تهران، خیابان ولیعصر، پلاک 123",
    "city": "تهران",
    "owner": {
      "id": "user-uuid",
      "name": "علی احمدی",
      "phone": "09123456789"
    },
    "createdAt": "2024-01-01T12:00:00Z",
    ...
  }
}
```

**Error Responses**:
- `404 Not Found`: کسب و کار یافت نشد
- `403 Forbidden`: دسترسی به این کسب و کار ندارید

---

### 4. Update Business
ویرایش اطلاعات کسب و کار

**Endpoint**: `PATCH /business/:id`

**Path Parameters**:
- `id`: شناسه کسب و کار

**Request Body** (همه فیلدها اختیاری):
```json
{
  "name": "فروشگاه جدید",
  "description": "توضیحات جدید",
  "phone": "02187654321",
  "address": "آدرس جدید"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "کسب و کار با موفقیت ویرایش شد",
  "data": {
    "id": "uuid-here",
    "name": "فروشگاه جدید",
    ...
  }
}
```

---

### 5. Get Business Stats
دریافت آمار کسب و کار

**Endpoint**: `GET /business/:id/stats`

**Response** (200 OK):
```json
{
  "success": true,
  "message": "آمار کسب و کار با موفقیت دریافت شد",
  "data": {
    "totalProducts": 150,
    "totalCustomers": 89,
    "totalInvoices": 230,
    "totalRevenue": 45000000,
    "activeProducts": 142,
    "lowStockProducts": 5
  }
}
```

---

### 6. Delete Business
حذف کسب و کار (فقط مالک)

**Endpoint**: `DELETE /business/:id`

**Response** (200 OK):
```json
{
  "success": true,
  "message": "کسب و کار با موفقیت حذف شد"
}
```

---

## Migration Guide

### تغییرات مورد نیاز در Backend:

1. **اضافه کردن فیلد `industry` به Business Entity**:

```typescript
// backend/src/modules/business/entities/business.entity.ts

export enum BusinessIndustry {
  FOOD = 'food',
  CLOTHING = 'clothing',
  ELECTRONICS = 'electronics',
  BEAUTY = 'beauty',
  AUTO = 'auto',
  HEALTH = 'health',
  EDUCATION = 'education',
  CONSTRUCTION = 'construction',
  TECHNOLOGY = 'technology',
  FINANCE = 'finance',
  REAL_ESTATE = 'real_estate',
  ENTERTAINMENT = 'entertainment',
  SPORTS = 'sports',
  AGRICULTURE = 'agriculture',
  OTHER = 'other',
}

// در کلاس Business:
@Column({ type: 'enum', enum: BusinessIndustry, nullable: true })
industry?: BusinessIndustry;
```

2. **اضافه کردن `ONLINE` به BusinessType**:

```typescript
export enum BusinessType {
  RETAIL = 'retail',
  WHOLESALE = 'wholesale',
  SERVICE = 'service',
  MANUFACTURING = 'manufacturing',
  RESTAURANT = 'restaurant',
  ONLINE = 'online',  // اضافه شود
  OTHER = 'other',
}
```

3. **به‌روزرسانی CreateBusinessDto**:

```typescript
// در create-business.dto.ts
@ApiPropertyOptional({ enum: BusinessIndustry, example: BusinessIndustry.ELECTRONICS })
@IsOptional()
@IsEnum(BusinessIndustry)
industry?: BusinessIndustry;
```

4. **Migration دیتابیس**:

```sql
-- افزودن enum صنعت
CREATE TYPE business_industry AS ENUM (
  'food', 'clothing', 'electronics', 'beauty', 'auto',
  'health', 'education', 'construction', 'technology',
  'finance', 'real_estate', 'entertainment', 'sports',
  'agriculture', 'other'
);

-- افزودن ستون industry
ALTER TABLE businesses 
ADD COLUMN industry business_industry;

-- افزودن 'online' به enum نوع کسب و کار
ALTER TYPE business_type ADD VALUE 'online';
```

---

## Notes

- فیلد `industry` اختیاری است
- `type` و `industry` می‌توانند مستقل از هم باشند (مثلاً یک رستوران می‌تواند صنعت "food" داشته باشد)
- تنظیمات پیشرفته در `settings` ذخیره می‌شوند (JSONB)
- فقط مالک کسب و کار می‌تواند آن را حذف کند
- کاربران دیگر می‌توانند از طریق `UserBusiness` به کسب و کار دسترسی داشته باشند
