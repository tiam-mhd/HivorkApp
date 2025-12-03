# Supplier API Contract - قرارداد API تامین‌کنندگان

> 📋 **منبع حقیقت واحد** برای تمام APIهای مربوط به تامین‌کنندگان

## Base URL
```
/api/suppliers
```

## Authentication
همه endpoint‌ها نیاز به `Bearer Token` دارند.
```
Authorization: Bearer {access_token}
```

---

## 📖 فهرست محتوا

1. [مدیریت تامین‌کنندگان](#1-supplier-management)
2. [مدیریت مخاطبین](#2-contact-management)
3. [مدیریت محصولات تامین‌کننده](#3-supplier-products)
4. [مدیریت مستندات](#4-document-management)

---

## 1. Supplier Management

### 1.1. ایجاد تامین‌کننده

```http
POST /api/suppliers?businessId={businessId}
```

**Request Body:**
```typescript
{
  name: string;              // نام تامین‌کننده (required)
  companyName?: string;      // نام شرکت
  contactPerson?: string;    // شخص ارتباطی
  email?: string;            // ایمیل
  phone?: string;            // تلفن (required)
  mobile?: string;           // موبایل
  website?: string;          // وبسایت
  taxId?: string;            // شناسه مالیاتی
  registrationNumber?: string; // شماره ثبت
  
  // آدرس
  address?: string;
  city?: string;
  state?: string;
  postalCode?: string;
  country?: string;
  
  // اطلاعات مالی
  paymentTermDays?: number;  // مهلت پرداخت (روز) - default: 30
  creditLimit?: number;      // سقف اعتبار
  currency?: string;         // واحد پول - default: 'IRR'
  
  // اطلاعات بانکی
  bankName?: string;
  bankAccountNumber?: string;
  iban?: string;
  swiftCode?: string;
  
  // طبقه‌بندی
  category?: string;         // دسته‌بندی
  rating?: number;           // رتبه (1-5)
  tags?: string[];           // برچسب‌ها
  
  notes?: string;            // یادداشت
}
```

**Response:** `201 Created`
```typescript
{
  id: string;
  businessId: string;
  supplierCode: string;      // کد خودکار: SUP-YYYYMMDD-XXXX
  name: string;
  status: 'PENDING';         // وضعیت اولیه
  // ... سایر فیلدها
  balance: 0;                // موجودی اولیه
  totalPurchases: 0;
  totalPayments: 0;
  lastPurchaseDate: null;
  lastPaymentDate: null;
  createdAt: string;
  updatedAt: string;
}
```

**Error Responses:**
- `400` - داده‌های نامعتبر
- `409` - تامین‌کننده با این اطلاعات قبلاً ثبت شده

---

### 1.2. دریافت لیست تامین‌کنندگان

```http
GET /api/suppliers?businessId={businessId}&[filters]
```

**Query Parameters:**
```typescript
{
  businessId: string;        // (required)
  
  // فیلترها
  status?: 'PENDING' | 'APPROVED' | 'SUSPENDED' | 'BLOCKED';
  category?: string;
  rating?: number;           // 1-5
  search?: string;           // جستجو در نام، کد، تلفن
  tags?: string[];           // فیلتر بر اساس برچسب
  
  // محدوده موجودی
  minBalance?: number;
  maxBalance?: number;
  
  // محدوده تاریخ
  createdAfter?: string;     // ISO date
  createdBefore?: string;
  
  // مرتب‌سازی
  sortBy?: 'name' | 'supplierCode' | 'balance' | 'totalPurchases' | 'createdAt';
  sortOrder?: 'ASC' | 'DESC';
  
  // صفحه‌بندی
  page?: number;             // default: 1
  limit?: number;            // default: 50, max: 100
}
```

**Response:** `200 OK`
```typescript
{
  data: Supplier[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
```

---

### 1.3. دریافت جزئیات تامین‌کننده

```http
GET /api/suppliers/:id?businessId={businessId}
```

**Response:** `200 OK`
```typescript
{
  id: string;
  businessId: string;
  supplierCode: string;
  name: string;
  companyName?: string;
  contactPerson?: string;
  email?: string;
  phone?: string;
  mobile?: string;
  website?: string;
  
  status: 'PENDING' | 'APPROVED' | 'SUSPENDED' | 'BLOCKED';
  
  // آدرس
  address?: string;
  city?: string;
  state?: string;
  postalCode?: string;
  country?: string;
  
  // مالی
  balance: number;           // موجودی فعلی (بدهی ما)
  creditLimit?: number;
  paymentTermDays: number;
  currency: string;
  
  // آمار
  totalPurchases: number;    // مجموع خریدها
  totalPayments: number;     // مجموع پرداخت‌ها
  lastPurchaseDate?: string;
  lastPaymentDate?: string;
  
  // طبقه‌بندی
  category?: string;
  rating?: number;
  tags?: string[];
  
  // بانکی
  bankName?: string;
  bankAccountNumber?: string;
  iban?: string;
  swiftCode?: string;
  
  notes?: string;
  
  createdAt: string;
  updatedAt: string;
  deletedAt?: string;
}
```

**Error Responses:**
- `404` - تامین‌کننده یافت نشد

---

### 1.4. ویرایش تامین‌کننده

```http
PATCH /api/suppliers/:id?businessId={businessId}
```

**Request Body:** (همان فیلدهای create، همه optional)

**Response:** `200 OK` - همان ساختار جزئیات

**Error Responses:**
- `404` - تامین‌کننده یافت نشد
- `400` - داده‌های نامعتبر

---

### 1.5. حذف تامین‌کننده (Soft Delete)

```http
DELETE /api/suppliers/:id?businessId={businessId}
```

**Response:** `204 No Content`

**Error Responses:**
- `404` - تامین‌کننده یافت نشد
- `400` - تامین‌کننده دارای سفارش فعال است

---

### 1.6. تغییر وضعیت تامین‌کننده

```http
PATCH /api/suppliers/:id/status?businessId={businessId}
```

**Request Body:**
```typescript
{
  status: 'PENDING' | 'APPROVED' | 'SUSPENDED' | 'BLOCKED';
  reason?: string;           // دلیل تغییر (برای SUSPENDED و BLOCKED الزامی)
}
```

**Response:** `200 OK` - همان ساختار جزئیات

---

### 1.7. دریافت آمار تامین‌کننده

```http
GET /api/suppliers/:id/stats?businessId={businessId}
```

**Response:** `200 OK`
```typescript
{
  supplierId: string;
  
  // آمار مالی
  currentBalance: number;      // موجودی فعلی
  totalPurchases: number;      // مجموع خریدها
  totalPayments: number;       // مجموع پرداخت‌ها
  averagePurchaseAmount: number;
  
  // آمار سفارشات
  totalOrders: number;
  pendingOrders: number;
  completedOrders: number;
  cancelledOrders: number;
  
  // آمار محصولات
  totalProducts: number;       // تعداد محصولات
  activeProducts: number;
  
  // آمار مستندات
  totalDocuments: number;
  approvedDocuments: number;
  pendingDocuments: number;
  expiredDocuments: number;
  
  // تاریخ‌ها
  lastPurchaseDate?: string;
  lastPaymentDate?: string;
  lastContactDate?: string;
  
  // نمودار خریدها (6 ماه اخیر)
  purchasesByMonth: {
    month: string;             // YYYY-MM
    amount: number;
    count: number;
  }[];
}
```

---

## 2. Contact Management

### 2.1. ایجاد مخاطب

```http
POST /api/suppliers/:supplierId/contacts?businessId={businessId}
```

**Request Body:**
```typescript
{
  name: string;              // نام (required)
  position?: string;         // سمت
  email?: string;
  phone?: string;
  mobile?: string;
  isPrimary?: boolean;       // مخاطب اصلی؟ - default: false
  notes?: string;
}
```

**Response:** `201 Created`
```typescript
{
  id: string;
  supplierId: string;
  name: string;
  position?: string;
  email?: string;
  phone?: string;
  mobile?: string;
  isPrimary: boolean;
  notes?: string;
  createdAt: string;
  updatedAt: string;
}
```

**Note:** اگر `isPrimary: true` باشد، سایر مخاطبین به false تغییر می‌کنند.

---

### 2.2. دریافت مخاطبین تامین‌کننده

```http
GET /api/suppliers/:supplierId/contacts?businessId={businessId}
```

**Response:** `200 OK`
```typescript
{
  data: Contact[];
}
```

---

### 2.3. دریافت جزئیات مخاطب

```http
GET /api/suppliers/:supplierId/contacts/:id?businessId={businessId}
```

**Response:** `200 OK` - همان ساختار Contact

---

### 2.4. ویرایش مخاطب

```http
PATCH /api/suppliers/:supplierId/contacts/:id?businessId={businessId}
```

**Request Body:** (همان فیلدهای create، همه optional)

**Response:** `200 OK` - همان ساختار Contact

---

### 2.5. حذف مخاطب

```http
DELETE /api/suppliers/:supplierId/contacts/:id?businessId={businessId}
```

**Response:** `204 No Content`

---

## 3. Supplier Products

### 3.1. افزودن محصول به تامین‌کننده

```http
POST /api/suppliers/:supplierId/products?businessId={businessId}
```

**Request Body:**
```typescript
{
  productId: string;         // (required)
  productVariantId?: string; // برای محصولات دارای تنوع
  
  supplierSku?: string;      // کد محصول نزد تامین‌کننده
  supplierPrice?: number;    // قیمت تامین‌کننده
  minOrderQuantity?: number; // حداقل سفارش - default: 1
  leadTimeDays?: number;     // زمان تحویل (روز) - default: 7
  isPreferred?: boolean;     // تامین‌کننده ترجیحی؟ - default: false
  isActive?: boolean;        // فعال؟ - default: true
  notes?: string;
}
```

**Response:** `201 Created`
```typescript
{
  id: string;
  supplierId: string;
  productId: string;
  productVariantId?: string;
  
  supplierSku?: string;
  supplierPrice?: number;
  minOrderQuantity: number;
  leadTimeDays: number;
  isPreferred: boolean;
  isActive: boolean;
  notes?: string;
  
  // اطلاعات محصول (populated)
  product: {
    id: string;
    name: string;
    sku: string;
    currentStock?: number;
  };
  
  productVariant?: {
    id: string;
    sku: string;
    attributeValues: { name: string; value: string }[];
  };
  
  createdAt: string;
  updatedAt: string;
}
```

**Error Responses:**
- `400` - محصول قبلاً به این تامین‌کننده اضافه شده
- `404` - محصول یا تامین‌کننده یافت نشد

---

### 3.2. دریافت محصولات تامین‌کننده

```http
GET /api/suppliers/:supplierId/products?businessId={businessId}
```

**Query Parameters:**
```typescript
{
  isActive?: boolean;        // فیلتر محصولات فعال
  isPreferred?: boolean;     // فیلتر تامین‌کنندگان ترجیحی
}
```

**Response:** `200 OK`
```typescript
{
  data: SupplierProduct[];   // همان ساختار بالا
}
```

---

### 3.3. دریافت تامین‌کنندگان یک محصول

```http
GET /api/suppliers/products/:productId?businessId={businessId}&productVariantId={variantId}
```

**Response:** `200 OK`
```typescript
{
  data: SupplierProduct[];   // لیست تامین‌کنندگان این محصول
}
```

---

### 3.4. ویرایش محصول تامین‌کننده

```http
PATCH /api/suppliers/:supplierId/products/:id?businessId={businessId}
```

**Request Body:** (همان فیلدهای create به جز productId و productVariantId، همه optional)

**Response:** `200 OK` - همان ساختار SupplierProduct

---

### 3.5. حذف محصول از تامین‌کننده

```http
DELETE /api/suppliers/:supplierId/products/:id?businessId={businessId}
```

**Response:** `204 No Content`

---

## 4. Document Management

### 4.1. آپلود مستند

```http
POST /api/suppliers/:supplierId/documents?businessId={businessId}
Content-Type: multipart/form-data
```

**Request Body (FormData):**
```typescript
{
  file: File;                // فایل (required)
  documentType: SupplierDocumentType; // (required)
  documentNumber?: string;   // شماره مستند
  issueDate?: string;        // تاریخ صدور (ISO)
  expiryDate?: string;       // تاریخ انقضا (ISO)
  notes?: string;
}
```

**Document Types:**
```typescript
enum SupplierDocumentType {
  CONTRACT = 'CONTRACT',           // قرارداد
  CERTIFICATE = 'CERTIFICATE',     // گواهی
  LICENSE = 'LICENSE',             // مجوز
  INSURANCE = 'INSURANCE',         // بیمه
  TAX_DOCUMENT = 'TAX_DOCUMENT',   // مستند مالیاتی
  QUALITY_CERT = 'QUALITY_CERT',   // گواهی کیفیت
  OTHER = 'OTHER'                  // سایر
}
```

**Response:** `201 Created`
```typescript
{
  id: string;
  supplierId: string;
  documentType: SupplierDocumentType;
  documentNumber?: string;
  fileName: string;
  filePath: string;
  fileSize: number;
  mimeType: string;
  
  issueDate?: string;
  expiryDate?: string;
  
  status: 'PENDING';         // وضعیت اولیه
  
  notes?: string;
  createdAt: string;
  updatedAt: string;
}
```

**Error Responses:**
- `400` - فایل نامعتبر یا بیش از 10MB
- `415` - فرمت فایل پشتیبانی نمی‌شود

**Supported Formats:** PDF, JPG, PNG, DOCX (max: 10MB)

---

### 4.2. دریافت مستندات تامین‌کننده

```http
GET /api/suppliers/:supplierId/documents?businessId={businessId}&[filters]
```

**Query Parameters:**
```typescript
{
  documentType?: SupplierDocumentType;
  status?: 'PENDING' | 'APPROVED' | 'REJECTED' | 'EXPIRED';
}
```

**Response:** `200 OK`
```typescript
{
  data: Document[];
}
```

---

### 4.3. دریافت جزئیات مستند

```http
GET /api/suppliers/:supplierId/documents/:id?businessId={businessId}
```

**Response:** `200 OK`
```typescript
{
  id: string;
  supplierId: string;
  documentType: SupplierDocumentType;
  documentNumber?: string;
  fileName: string;
  filePath: string;
  fileSize: number;
  mimeType: string;
  
  issueDate?: string;
  expiryDate?: string;
  
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'EXPIRED';
  
  // در صورت تایید
  approvedBy?: string;
  approvedAt?: string;
  
  // در صورت رد
  rejectionReason?: string;
  rejectedBy?: string;
  rejectedAt?: string;
  
  notes?: string;
  createdAt: string;
  updatedAt: string;
}
```

---

### 4.4. تایید مستند

```http
PATCH /api/suppliers/:supplierId/documents/:id/approve?businessId={businessId}
```

**Response:** `200 OK` - همان ساختار Document با `status: 'APPROVED'`

---

### 4.5. رد مستند

```http
PATCH /api/suppliers/:supplierId/documents/:id/reject?businessId={businessId}
```

**Request Body:**
```typescript
{
  reason: string;            // دلیل رد (required)
}
```

**Response:** `200 OK` - همان ساختار Document با `status: 'REJECTED'`

---

### 4.6. حذف مستند

```http
DELETE /api/suppliers/:supplierId/documents/:id?businessId={businessId}
```

**Response:** `204 No Content`

**Note:** فایل از سرور نیز حذف می‌شود.

---

## 📊 Common Types

### Supplier Status
```typescript
enum SupplierStatus {
  PENDING = 'PENDING',       // در انتظار تایید
  APPROVED = 'APPROVED',     // تایید شده
  SUSPENDED = 'SUSPENDED',   // معلق
  BLOCKED = 'BLOCKED'        // مسدود
}
```

### Document Status
```typescript
enum DocumentStatus {
  PENDING = 'PENDING',       // در انتظار بررسی
  APPROVED = 'APPROVED',     // تایید شده
  REJECTED = 'REJECTED',     // رد شده
  EXPIRED = 'EXPIRED'        // منقضی شده
}
```

---

## 🔒 Business Rules

### Supplier
1. **Unique Constraints:**
   - `supplierCode` در هر business یکتا است
   - ترکیب `phone + businessId` یکتا است

2. **Auto Calculations:**
   - `balance = totalPurchases - totalPayments`
   - `supplierCode = SUP-YYYYMMDD-XXXX` (خودکار)

3. **Status Rules:**
   - فقط `APPROVED` می‌تواند سفارش دریافت کند
   - `BLOCKED` نمی‌تواند ویرایش شود

### Contact
1. تنها یک مخاطب می‌تواند `isPrimary = true` باشد
2. حداقل یک روش ارتباطی (email یا phone یا mobile) الزامی است

### Supplier Product
1. هر ترکیب `(supplierId, productId, productVariantId)` یکتا است
2. برای محصولات با تنوع، `productVariantId` الزامی است

### Document
1. مستندات منقضی شده خودکار `status: EXPIRED` می‌گیرند
2. حذف مستند، فایل را نیز از سرور حذف می‌کند
3. مستندات `APPROVED` نمی‌توانند ویرایش شوند

---

## ⚠️ Error Handling

همه خطاها با این ساختار برگردانده می‌شوند:

```typescript
{
  statusCode: number;
  message: string | string[];
  error: string;
  timestamp: string;
  path: string;
}
```

**Common Status Codes:**
- `400` - Bad Request (داده‌های نامعتبر)
- `401` - Unauthorized (عدم احراز هویت)
- `403` - Forbidden (عدم دسترسی)
- `404` - Not Found (یافت نشد)
- `409` - Conflict (تداخل داده)
- `415` - Unsupported Media Type (فرمت نامعتبر)
- `500` - Internal Server Error (خطای سرور)
