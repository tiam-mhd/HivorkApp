# 🚀 API Documentation - Hivork Backend

## 📚 نمای کلی API

### Base Information
```
Base URL: https://api.hivork.com/v1
Authentication: JWT Bearer Token
Content-Type: application/json
Accept-Language: fa, en
```

### Response Format
```json
{
  "success": true,
  "data": {},
  "message": "عملیات با موفقیت انجام شد",
  "meta": {
    "timestamp": "2025-11-15T10:30:00Z",
    "request_id": "uuid"
  }
}
```

### Error Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "خطای اعتبارسنجی",
    "details": [
      {
        "field": "email",
        "message": "ایمیل معتبر نیست"
      }
    ]
  },
  "meta": {
    "timestamp": "2025-11-15T10:30:00Z",
    "request_id": "uuid"
  }
}
```

### HTTP Status Codes
```
200 OK - موفق
201 Created - ایجاد شد
204 No Content - بدون محتوا
400 Bad Request - درخواست نامعتبر
401 Unauthorized - احراز هویت نشده
403 Forbidden - دسترسی ممنوع
404 Not Found - یافت نشد
409 Conflict - تضاد
422 Unprocessable Entity - خطای اعتبارسنجی
429 Too Many Requests - درخواست بیش از حد
500 Internal Server Error - خطای سرور
503 Service Unavailable - سرویس در دسترس نیست
```

---

## 🔐 Authentication API

### POST /auth/register
ثبت‌نام کاربر جدید

**Request Body:**
```json
{
  "phone": "09123456789",
  "password": "SecurePass123!",
  "full_name": "علی احمدی"
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "phone": "09123456789",
      "full_name": "علی احمدی",
      "is_verified": false
    },
    "verification_sent": true
  },
  "message": "کد تایید به شماره شما ارسال شد"
}
```

---

### POST /auth/verify-phone
تایید شماره تلفن

**Request Body:**
```json
{
  "phone": "09123456789",
  "code": "123456"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 3600,
    "user": {
      "id": "uuid",
      "phone": "09123456789",
      "full_name": "علی احمدی",
      "is_verified": true
    }
  }
}
```

---

### POST /auth/login
ورود به سیستم

**Request Body:**
```json
{
  "phone": "09123456789",
  "password": "SecurePass123!"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 3600,
    "user": {
      "id": "uuid",
      "phone": "09123456789",
      "full_name": "علی احمدی",
      "avatar_url": "https://..."
    }
  }
}
```

---

### POST /auth/refresh-token
تمدید توکن

**Request Body:**
```json
{
  "refresh_token": "eyJhbGc..."
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGc...",
    "expires_in": 3600
  }
}
```

---

### POST /auth/logout
خروج از سیستم

**Headers:** `Authorization: Bearer {token}`

**Response:** `204 No Content`

---

### POST /auth/forgot-password
فراموشی رمز عبور

**Request Body:**
```json
{
  "phone": "09123456789"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "کد بازیابی به شماره شما ارسال شد"
}
```

---

### POST /auth/reset-password
بازیابی رمز عبور

**Request Body:**
```json
{
  "phone": "09123456789",
  "code": "123456",
  "new_password": "NewSecurePass123!"
}
```

**Response:** `200 OK`

---

## 🏢 Business API

### GET /businesses
لیست کسب‌وکارهای کاربر

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**
- `page` (integer, default: 1)
- `limit` (integer, default: 10)
- `is_active` (boolean)

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "name": "فروشگاه پوشاک آریا",
        "slug": "arya-shop",
        "category": {
          "id": "uuid",
          "name": "پوشاک"
        },
        "logo_url": "https://...",
        "subscription_plan": "professional",
        "is_active": true,
        "role": "owner",
        "created_at": "2025-01-01T10:00:00Z"
      }
    ],
    "meta": {
      "total": 3,
      "page": 1,
      "limit": 10,
      "total_pages": 1
    }
  }
}
```

---

### POST /businesses
ایجاد کسب‌وکار جدید

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "name": "فروشگاه پوشاک آریا",
  "category_id": "uuid",
  "phone": "02188776655",
  "address": "تهران، خیابان ولیعصر",
  "city": "تهران",
  "state": "تهران"
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "فروشگاه پوشاک آریا",
    "slug": "arya-shop",
    "subscription_plan": "free",
    "is_active": true
  }
}
```

**Validation Rules:**
- `name`: required, min:3, max:255
- `category_id`: required, exists:business_categories
- `phone`: nullable, regex:/^0[0-9]{10}$/
- حداکثر تعداد کسب‌وکار بر اساس پلن اشتراک

---

### GET /businesses/:id
جزئیات کسب‌وکار

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "فروشگاه پوشاک آریا",
    "slug": "arya-shop",
    "description": "...",
    "logo_url": "https://...",
    "phone": "02188776655",
    "email": "info@aryashop.com",
    "address": "تهران، خیابان ولیعصر",
    "city": "تهران",
    "subscription_plan": "professional",
    "settings": {
      "currency": "IRR",
      "timezone": "Asia/Tehran",
      "invoice_prefix": "INV"
    },
    "stats": {
      "total_products": 150,
      "total_customers": 320,
      "total_invoices": 1250,
      "monthly_revenue": 45000000
    },
    "role": "owner",
    "permissions": ["*"]
  }
}
```

---

### PATCH /businesses/:id
ویرایش کسب‌وکار

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "name": "فروشگاه پوشاک آریا - شعبه مرکزی",
  "description": "توضیحات...",
  "phone": "02188776655",
  "settings": {
    "invoice_prefix": "ARY"
  }
}
```

**Response:** `200 OK`

---

### DELETE /businesses/:id
حذف کسب‌وکار (soft delete)

**Headers:** `Authorization: Bearer {token}`

**Response:** `204 No Content`

---

### POST /businesses/:id/switch
سوئیچ به کسب‌وکار

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "current_business": {
      "id": "uuid",
      "name": "فروشگاه پوشاک آریا"
    }
  }
}
```

---

## 📦 Products API

### GET /businesses/:business_id/products
لیست محصولات

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**
- `page` (integer, default: 1)
- `limit` (integer, default: 20)
- `search` (string) - جستجو در نام، SKU
- `category_id` (uuid)
- `is_active` (boolean)
- `is_featured` (boolean)
- `stock_status` (enum: in_stock, low_stock, out_of_stock)
- `sort` (enum: name, price, created_at, sale_count)
- `order` (enum: asc, desc)

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "name": "تی‌شرت پنبه مردانه",
        "slug": "tshirt-cotton-men",
        "sku": "TSH-001",
        "price": 250000,
        "compare_at_price": 300000,
        "stock_quantity": 45,
        "stock_status": "in_stock",
        "thumbnail_url": "https://...",
        "category": {
          "id": "uuid",
          "name": "پوشاک مردانه"
        },
        "is_active": true,
        "is_featured": false,
        "sale_count": 128,
        "created_at": "2025-01-01T10:00:00Z"
      }
    ],
    "meta": {
      "total": 150,
      "page": 1,
      "limit": 20,
      "total_pages": 8
    }
  }
}
```

---

### POST /businesses/:business_id/products
ایجاد محصول

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "name": "تی‌شرت پنبه مردانه",
  "category_id": "uuid",
  "sku": "TSH-001",
  "barcode": "1234567890",
  "description": "توضیحات کامل محصول...",
  "price": 250000,
  "cost_price": 150000,
  "compare_at_price": 300000,
  "track_inventory": true,
  "stock_quantity": 50,
  "low_stock_threshold": 10,
  "images": [
    {
      "url": "https://...",
      "alt": "تصویر اصلی",
      "order": 1
    }
  ],
  "attributes": {
    "color": "آبی",
    "size": "L",
    "material": "پنبه"
  },
  "weight": 0.2,
  "dimensions": {
    "length": 30,
    "width": 20,
    "height": 2,
    "unit": "cm"
  },
  "is_active": true
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "تی‌شرت پنبه مردانه",
    "slug": "tshirt-cotton-men",
    "sku": "TSH-001",
    "price": 250000
  }
}
```

**Validation Rules:**
- `name`: required, min:3, max:255
- `price`: required, numeric, min:0
- `sku`: nullable, unique per business
- حداکثر تعداد محصول بر اساس پلن اشتراک

---

### GET /businesses/:business_id/products/:id
جزئیات محصول

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "تی‌شرت پنبه مردانه",
    "slug": "tshirt-cotton-men",
    "sku": "TSH-001",
    "barcode": "1234567890",
    "description": "...",
    "price": 250000,
    "cost_price": 150000,
    "compare_at_price": 300000,
    "stock_quantity": 45,
    "low_stock_threshold": 10,
    "images": [...],
    "attributes": {...},
    "category": {...},
    "variants": [
      {
        "id": "uuid",
        "name": "آبی - L",
        "sku": "TSH-001-BL-L",
        "price": 250000,
        "stock_quantity": 20,
        "attributes": {
          "color": "آبی",
          "size": "L"
        }
      }
    ],
    "stats": {
      "view_count": 1250,
      "sale_count": 128,
      "revenue": 32000000
    },
    "created_at": "2025-01-01T10:00:00Z"
  }
}
```

---

### PATCH /businesses/:business_id/products/:id
ویرایش محصول

**Request Body:** (همانند POST با فیلدهای دلخواه)

**Response:** `200 OK`

---

### DELETE /businesses/:business_id/products/:id
حذف محصول

**Response:** `204 No Content`

---

### POST /businesses/:business_id/products/:id/adjust-stock
تنظیم موجودی محصول

**Request Body:**
```json
{
  "quantity": 10,
  "type": "adjustment",
  "reason": "اصلاح موجودی",
  "note": "موجودی اشتباه وارد شده بود"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "product_id": "uuid",
    "quantity_before": 45,
    "quantity_after": 55,
    "change": 10
  }
}
```

---

### POST /businesses/:business_id/products/bulk-import
ایمپورت گروهی محصولات

**Request Body:**
```json
{
  "products": [
    {
      "name": "محصول 1",
      "sku": "P001",
      "price": 100000
    },
    {
      "name": "محصول 2",
      "sku": "P002",
      "price": 150000
    }
  ]
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "imported": 2,
    "failed": 0,
    "errors": []
  }
}
```

---

## 👥 Customers API

### GET /businesses/:business_id/customers
لیست مشتریان

**Query Parameters:**
- `page`, `limit`
- `search` - جستجو در نام، موبایل
- `customer_type` (retail, wholesale, vip)
- `is_active` (boolean)
- `sort` (name, total_orders, total_purchased, created_at)

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "full_name": "محمد رضایی",
        "phone": "09123456789",
        "email": "m.rezaei@example.com",
        "customer_type": "retail",
        "total_orders": 15,
        "total_purchased": 5500000,
        "current_balance": -150000,
        "last_order_date": "2025-10-20T10:00:00Z",
        "is_active": true,
        "created_at": "2024-01-15T10:00:00Z"
      }
    ],
    "meta": {
      "total": 320,
      "page": 1,
      "limit": 20
    }
  }
}
```

---

### POST /businesses/:business_id/customers
ایجاد مشتری

**Request Body:**
```json
{
  "phone": "09123456789",
  "full_name": "محمد رضایی",
  "email": "m.rezaei@example.com",
  "national_id": "1234567890",
  "addresses": [
    {
      "title": "منزل",
      "full_address": "تهران، خیابان آزادی، پلاک 123",
      "city": "تهران",
      "state": "تهران",
      "postal_code": "1234567890",
      "is_default": true
    }
  ],
  "customer_type": "retail",
  "tags": ["مشتری وفادار"],
  "notes": "یادداشت‌های داخلی"
}
```

**Response:** `201 Created`

**Validation:**
- `phone`: required, unique per business
- `full_name`: required, min:3
- حداکثر تعداد مشتری بر اساس پلن

---

### GET /businesses/:business_id/customers/:id
جزئیات مشتری

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "full_name": "محمد رضایی",
    "phone": "09123456789",
    "email": "m.rezaei@example.com",
    "addresses": [...],
    "stats": {
      "total_orders": 15,
      "total_purchased": 5500000,
      "average_order_value": 366667,
      "current_balance": -150000,
      "last_order_date": "2025-10-20T10:00:00Z"
    },
    "recent_orders": [...],
    "interactions": [...],
    "created_at": "2024-01-15T10:00:00Z"
  }
}
```

---

### PATCH /businesses/:business_id/customers/:id
ویرایش مشتری

**Response:** `200 OK`

---

### DELETE /businesses/:business_id/customers/:id
حذف مشتری

**Response:** `204 No Content`

---

### POST /businesses/:business_id/customers/:id/interactions
افزودن تعامل با مشتری

**Request Body:**
```json
{
  "type": "call",
  "subject": "پیگیری سفارش",
  "description": "مشتری در مورد زمان ارسال سوال کرد"
}
```

**Response:** `201 Created`

---

## 🧾 Invoices API

### GET /businesses/:business_id/invoices
لیست فاکتورها

**Query Parameters:**
- `page`, `limit`
- `search` - جستجو در شماره فاکتور، نام مشتری
- `status` (draft, pending, confirmed, paid, cancelled)
- `customer_id` (uuid)
- `from_date`, `to_date` (ISO date)
- `sort` (invoice_number, issue_date, total_amount)

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "invoice_number": "INV-2025-0001",
        "customer": {
          "id": "uuid",
          "full_name": "محمد رضایی",
          "phone": "09123456789"
        },
        "issue_date": "2025-11-01",
        "due_date": "2025-11-15",
        "status": "paid",
        "total_amount": 850000,
        "paid_amount": 850000,
        "remaining_amount": 0,
        "items_count": 3,
        "created_at": "2025-11-01T10:00:00Z"
      }
    ],
    "meta": {
      "total": 1250,
      "page": 1,
      "limit": 20,
      "summary": {
        "total_amount": 125000000,
        "paid_amount": 100000000,
        "remaining_amount": 25000000
      }
    }
  }
}
```

---

### POST /businesses/:business_id/invoices
ایجاد فاکتور

**Request Body:**
```json
{
  "customer_id": "uuid",
  "type": "sale",
  "issue_date": "2025-11-15",
  "due_date": "2025-11-30",
  "items": [
    {
      "product_id": "uuid",
      "variant_id": "uuid",
      "quantity": 2,
      "unit_price": 250000,
      "discount_amount": 0
    }
  ],
  "discount_percentage": 10,
  "tax_percentage": 9,
  "shipping_cost": 50000,
  "shipping_address": {
    "full_address": "تهران، خیابان آزادی، پلاک 123",
    "city": "تهران",
    "postal_code": "1234567890"
  },
  "shipping_method": "پست",
  "customer_note": "لطفاً با بسته‌بندی زیبا ارسال شود",
  "internal_note": "مشتری VIP"
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "invoice_number": "INV-2025-0001",
    "status": "draft",
    "subtotal": 500000,
    "discount_amount": 50000,
    "tax_amount": 40500,
    "shipping_cost": 50000,
    "total_amount": 540500
  }
}
```

**Business Logic:**
- اگر `track_inventory = true` → کاهش موجودی
- ایجاد `inventory_transaction`
- محاسبه خودکار مبالغ
- ایجاد `invoice_number` به صورت خودکار

---

### GET /businesses/:business_id/invoices/:id
جزئیات فاکتور

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "invoice_number": "INV-2025-0001",
    "type": "sale",
    "status": "paid",
    "customer": {...},
    "issue_date": "2025-11-01",
    "due_date": "2025-11-15",
    "paid_date": "2025-11-05",
    "items": [
      {
        "id": "uuid",
        "product_name": "تی‌شرت پنبه مردانه",
        "product_sku": "TSH-001",
        "variant_name": "آبی - L",
        "quantity": 2,
        "unit_price": 250000,
        "discount_amount": 0,
        "tax_amount": 45000,
        "total_price": 545000
      }
    ],
    "subtotal": 500000,
    "discount_amount": 50000,
    "tax_amount": 40500,
    "shipping_cost": 50000,
    "total_amount": 540500,
    "paid_amount": 540500,
    "remaining_amount": 0,
    "payments": [...],
    "shipping_address": {...},
    "tracking_code": "12345678",
    "shipping_status": "delivered",
    "delivered_at": "2025-11-07T14:30:00Z"
  }
}
```

---

### PATCH /businesses/:business_id/invoices/:id
ویرایش فاکتور

**Note:** فقط فاکتورهای draft قابل ویرایش هستند

**Response:** `200 OK`

---

### POST /businesses/:business_id/invoices/:id/confirm
تایید فاکتور

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "confirmed"
  }
}
```

---

### POST /businesses/:business_id/invoices/:id/cancel
لغو فاکتور

**Request Body:**
```json
{
  "reason": "درخواست مشتری",
  "restore_inventory": true
}
```

**Response:** `200 OK`

---

### GET /businesses/:business_id/invoices/:id/pdf
دانلود PDF فاکتور

**Response:** `200 OK`
- Content-Type: application/pdf
- PDF File Stream

---

### GET /businesses/:business_id/invoices/:id/label
دانلود PDF لیبل آدرس

**Response:** `200 OK`
- Content-Type: application/pdf
- PDF Label

---

### POST /businesses/:business_id/invoices/:id/send
ارسال فاکتور به مشتری

**Request Body:**
```json
{
  "method": "sms",
  "phone": "09123456789",
  "include_pdf": true
}
```

**Response:** `200 OK`

---

### POST /businesses/:business_id/invoices/:id/payments
ثبت پرداخت

**Request Body:**
```json
{
  "amount": 540500,
  "payment_method": "card",
  "payment_date": "2025-11-05",
  "transaction_id": "123456789",
  "note": "پرداخت کامل"
}
```

**Response:** `201 Created`

**Business Logic:**
- بروزرسانی `paid_amount` و `remaining_amount`
- اگر کامل پرداخت شد → `status = paid`
- بروزرسانی `current_balance` مشتری

---

## 💸 Expenses API

### GET /businesses/:business_id/expenses
لیست هزینه‌ها

**Query Parameters:**
- `page`, `limit`
- `category_id`
- `from_date`, `to_date`
- `payment_method`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "title": "اجاره ماهانه",
        "category": {
          "id": "uuid",
          "name": "اجاره"
        },
        "amount": 20000000,
        "expense_date": "2025-11-01",
        "payment_method": "transfer",
        "is_paid": true,
        "created_at": "2025-11-01T10:00:00Z"
      }
    ],
    "meta": {
      "total": 85,
      "page": 1,
      "limit": 20,
      "summary": {
        "total_amount": 150000000,
        "paid_amount": 140000000,
        "unpaid_amount": 10000000
      }
    }
  }
}
```

---

### POST /businesses/:business_id/expenses
ثبت هزینه

**Request Body:**
```json
{
  "title": "اجاره ماهانه",
  "category_id": "uuid",
  "amount": 20000000,
  "expense_date": "2025-11-01",
  "payment_method": "transfer",
  "is_paid": true,
  "description": "اجاره دفتر برای آبان ماه",
  "attachments": [
    {
      "url": "https://...",
      "filename": "receipt.jpg",
      "type": "image/jpeg"
    }
  ]
}
```

**Response:** `201 Created`

---

### Expense Categories APIs
- `GET /businesses/:business_id/expense-categories` - لیست دسته‌ها
- `POST /businesses/:business_id/expense-categories` - ایجاد دسته
- `PATCH /businesses/:business_id/expense-categories/:id` - ویرایش
- `DELETE /businesses/:business_id/expense-categories/:id` - حذف

---

## 📊 Analytics & Reports API

### GET /businesses/:business_id/analytics/dashboard
داشبورد آماری

**Query Parameters:**
- `from_date`, `to_date`
- `period` (daily, weekly, monthly, yearly)

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_sales": 45000000,
      "total_orders": 150,
      "total_customers": 85,
      "total_expenses": 12000000,
      "gross_profit": 33000000,
      "average_order_value": 300000
    },
    "sales_chart": [
      {"date": "2025-11-01", "amount": 1500000, "orders": 5},
      {"date": "2025-11-02", "amount": 2000000, "orders": 7}
    ],
    "top_products": [
      {
        "product_id": "uuid",
        "name": "تی‌شرت پنبه",
        "quantity_sold": 45,
        "revenue": 11250000
      }
    ],
    "top_customers": [
      {
        "customer_id": "uuid",
        "full_name": "محمد رضایی",
        "total_purchased": 5500000,
        "orders_count": 15
      }
    ],
    "low_stock_products": [
      {
        "product_id": "uuid",
        "name": "شلوار جین",
        "stock_quantity": 3,
        "threshold": 10
      }
    ]
  }
}
```

---

### GET /businesses/:business_id/analytics/sales-report
گزارش فروش

**Query Parameters:**
- `from_date`, `to_date`
- `group_by` (day, week, month, product, customer, category)
- `export` (pdf, excel, csv)

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "total_sales": 45000000,
    "total_orders": 150,
    "total_items_sold": 320,
    "average_order_value": 300000,
    "breakdown": [...]
  }
}
```

---

### GET /businesses/:business_id/analytics/profit-loss
گزارش سود و زیان

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "revenue": 45000000,
    "cost_of_goods_sold": 27000000,
    "gross_profit": 18000000,
    "expenses": 12000000,
    "net_profit": 6000000,
    "profit_margin": 13.33
  }
}
```

---

### GET /businesses/:business_id/analytics/inventory-report
گزارش موجودی

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "total_products": 150,
    "in_stock": 120,
    "low_stock": 25,
    "out_of_stock": 5,
    "total_inventory_value": 85000000,
    "products": [...]
  }
}
```

---

### GET /businesses/:business_id/analytics/recommendations
پیشنهادات هوشمند

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "recommendations": [
      {
        "type": "restock",
        "priority": "high",
        "message": "5 محصول کمبود موجودی دارند",
        "items": [...]
      },
      {
        "type": "marketing",
        "priority": "medium",
        "message": "20 مشتری بیش از 3 ماه خرید نکرده‌اند",
        "suggestion": "ارسال پیام تبلیغاتی با تخفیف ویژه"
      }
    ]
  }
}
```

---

## 📢 Notifications API

### GET /notifications
لیست نوتیفیکیشن‌های کاربر

**Query Parameters:**
- `page`, `limit`
- `is_read` (boolean)
- `type`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "type": "low_stock",
        "title": "کمبود موجودی",
        "message": "موجودی محصول 'تی‌شرت پنبه' به زیر 10 عدد رسید",
        "action_url": "/products/uuid",
        "is_read": false,
        "created_at": "2025-11-15T10:00:00Z"
      }
    ],
    "meta": {
      "total": 25,
      "unread_count": 5
    }
  }
}
```

---

### POST /notifications/:id/read
علامت‌گذاری به عنوان خوانده شده

**Response:** `200 OK`

---

### POST /notifications/mark-all-read
علامت‌گذاری همه به عنوان خوانده شده

**Response:** `200 OK`

---

## 👤 User Profile API

### GET /profile
پروفایل کاربر

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "phone": "09123456789",
    "email": "user@example.com",
    "full_name": "علی احمدی",
    "avatar_url": "https://...",
    "is_verified": true,
    "created_at": "2024-01-01T10:00:00Z"
  }
}
```

---

### PATCH /profile
ویرایش پروفایل

**Request Body:**
```json
{
  "full_name": "علی احمدی",
  "email": "newemail@example.com",
  "avatar_url": "https://..."
}
```

**Response:** `200 OK`

---

### POST /profile/change-password
تغییر رمز عبور

**Request Body:**
```json
{
  "current_password": "OldPass123!",
  "new_password": "NewPass123!"
}
```

**Response:** `200 OK`

---

## 📤 File Upload API

### POST /upload
آپلود فایل

**Request:** `multipart/form-data`
- `file`: File

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "url": "https://cdn.hivork.com/uploads/uuid/filename.jpg",
    "filename": "filename.jpg",
    "size": 152400,
    "mime_type": "image/jpeg"
  }
}
```

**Validation:**
- حداکثر سایز: 5MB (images), 10MB (documents)
- فرمت‌های مجاز: jpg, png, gif, pdf, xlsx, csv
- محدودیت بر اساس پلن اشتراک

---

## 🔒 Rate Limiting

```
Authentication APIs: 10 requests/minute
General APIs: 100 requests/minute
Upload APIs: 20 requests/minute
Export APIs: 5 requests/minute
```

**Response Header:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1699876543
```

**Error:** `429 Too Many Requests`

---

## 🎯 Webhooks (فاز 2)

کسب‌وکارها می‌توانند webhook برای رویدادها ثبت کنند:

**Events:**
- `invoice.created`
- `invoice.paid`
- `product.low_stock`
- `customer.created`
- `payment.received`

**Webhook Payload:**
```json
{
  "event": "invoice.paid",
  "data": {
    "invoice_id": "uuid",
    "amount": 540500
  },
  "timestamp": "2025-11-15T10:00:00Z"
}
```

---

## 📱 SDK & Libraries (فاز 3)

```javascript
// JavaScript/Node.js
import { Hivork } from '@hivork/sdk';

const client = new Hivork({
  apiKey: 'your-api-key'
});

const products = await client.products.list('business-id');
```

---

📅 **تاریخ**: 15 نوامبر 2025  
🔄 **نسخه**: 1.0  
📝 **وضعیت**: در حال توسعه
