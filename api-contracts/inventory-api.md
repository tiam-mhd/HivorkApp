# Inventory API Contract - قرارداد API موجودی انبار

> 📋 **منبع حقیقت واحد** برای تمام APIهای مربوط به مدیریت موجودی

## Base URL
```
/api/inventory
```

## Authentication
همه endpoint‌ها نیاز به `Bearer Token` دارند.
```
Authorization: Bearer {access_token}
```

---

## 📖 فهرست محتوا

1. [مدیریت انبارها](#1-warehouse-management)
2. [مدیریت موجودی](#2-inventory-management)
3. [مدیریت تراکنش‌ها](#3-transaction-management)
4. [مدیریت انتقال بین انبارها](#4-transfer-management)

---

## 1. Warehouse Management

### 1.1. ایجاد انبار

```http
POST /api/inventory/warehouses?businessId={businessId}
```

**Request Body:**
```typescript
{
  name: string;              // نام انبار (required)
  code?: string;             // کد انبار (اختیاری، خودکار)
  type: WarehouseType;       // (required)
  
  address?: string;
  city?: string;
  state?: string;
  postalCode?: string;
  
  managerId?: string;        // مدیر انبار
  phone?: string;
  email?: string;
  
  capacity?: number;         // ظرفیت (متر مربع یا واحد)
  isActive?: boolean;        // فعال؟ - default: true
  notes?: string;
}

enum WarehouseType {
  MAIN = 'MAIN',             // انبار اصلی
  BRANCH = 'BRANCH',         // شعبه
  RETAIL = 'RETAIL',         // خرده‌فروشی
  TRANSIT = 'TRANSIT',       // انبار ترانزیت
  VIRTUAL = 'VIRTUAL'        // مجازی
}
```

**Response:** `201 Created`
```typescript
{
  id: string;
  businessId: string;
  name: string;
  code: string;              // کد خودکار: WH-XXXXXX
  type: WarehouseType;
  
  address?: string;
  city?: string;
  state?: string;
  postalCode?: string;
  
  managerId?: string;
  phone?: string;
  email?: string;
  
  capacity?: number;
  isActive: boolean;
  notes?: string;
  
  createdAt: string;
  updatedAt: string;
}
```

**Error Responses:**
- `400` - داده‌های نامعتبر
- `409` - انبار با این کد قبلاً ثبت شده

---

### 1.2. دریافت لیست انبارها

```http
GET /api/inventory/warehouses?businessId={businessId}&[filters]
```

**Query Parameters:**
```typescript
{
  businessId: string;        // (required)
  type?: WarehouseType;
  isActive?: boolean;
  search?: string;           // جستجو در نام، کد
}
```

**Response:** `200 OK`
```typescript
{
  data: Warehouse[];
}
```

---

### 1.3. دریافت جزئیات انبار

```http
GET /api/inventory/warehouses/:id?businessId={businessId}
```

**Response:** `200 OK` - همان ساختار Warehouse

---

### 1.4. ویرایش انبار

```http
PATCH /api/inventory/warehouses/:id?businessId={businessId}
```

**Request Body:** (همان فیلدهای create، همه optional)

**Response:** `200 OK` - همان ساختار Warehouse

---

### 1.5. حذف انبار

```http
DELETE /api/inventory/warehouses/:id?businessId={businessId}
```

**Response:** `204 No Content`

**Error Responses:**
- `400` - انبار دارای موجودی است
- `404` - انبار یافت نشد

---

### 1.6. آمار انبار

```http
GET /api/inventory/warehouses/:id/stats?businessId={businessId}
```

**Response:** `200 OK`
```typescript
{
  warehouseId: string;
  
  // موجودی
  totalProducts: number;     // تعداد محصولات منحصربه‌فرد
  totalQuantity: number;     // مجموع تعداد
  totalValue: number;        // ارزش کل موجودی
  
  // ظرفیت
  capacity?: number;
  usedCapacity?: number;
  availableCapacity?: number;
  
  // تراکنش‌ها (30 روز اخیر)
  recentTransactions: {
    totalIn: number;         // ورودی
    totalOut: number;        // خروجی
    totalAdjustment: number; // تعدیل
  };
  
  // محصولات کم‌موجود
  lowStockProducts: {
    productId: string;
    productName: string;
    currentStock: number;
    minStock: number;
  }[];
  
  // محصولات بدون موجودی
  outOfStockProducts: {
    productId: string;
    productName: string;
  }[];
}
```

---

## 2. Inventory Management

### 2.1. دریافت موجودی محصولات

```http
GET /api/inventory?businessId={businessId}&[filters]
```

**Query Parameters:**
```typescript
{
  businessId: string;        // (required)
  
  // فیلترها
  warehouseId?: string;      // فیلتر بر اساس انبار
  productId?: string;        // فیلتر بر اساس محصول
  productVariantId?: string; // فیلتر بر اساس تنوع
  
  stockStatus?: 'IN_STOCK' | 'LOW_STOCK' | 'OUT_OF_STOCK';
  
  // صفحه‌بندی
  page?: number;             // default: 1
  limit?: number;            // default: 50
}
```

**Response:** `200 OK`
```typescript
{
  data: InventoryItem[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

interface InventoryItem {
  id: string;
  businessId: string;
  warehouseId: string;
  productId: string;
  productVariantId?: string;
  
  quantity: number;          // موجودی فعلی
  reservedQuantity: number;  // رزرو شده
  availableQuantity: number; // قابل دسترس
  
  minStock?: number;         // حداقل موجودی
  maxStock?: number;         // حداکثر موجودی
  reorderPoint?: number;     // نقطه سفارش مجدد
  
  // اطلاعات محصول
  product: {
    id: string;
    name: string;
    sku: string;
    price?: number;
  };
  
  productVariant?: {
    id: string;
    sku: string;
    attributeValues: { name: string; value: string }[];
  };
  
  warehouse: {
    id: string;
    name: string;
    code: string;
  };
  
  lastTransactionDate?: string;
  createdAt: string;
  updatedAt: string;
}
```

**Calculation:**
```typescript
availableQuantity = quantity - reservedQuantity
```

---

### 2.2. دریافت موجودی یک محصول

```http
GET /api/inventory/product/:productId?businessId={businessId}&productVariantId={variantId}
```

**Response:** `200 OK`
```typescript
{
  productId: string;
  productVariantId?: string;
  
  totalQuantity: number;     // مجموع در تمام انبارها
  totalReserved: number;
  totalAvailable: number;
  
  byWarehouse: {
    warehouseId: string;
    warehouseName: string;
    quantity: number;
    reservedQuantity: number;
    availableQuantity: number;
  }[];
  
  product: {
    id: string;
    name: string;
    sku: string;
    trackInventory: boolean;
    minStock?: number;
    maxStock?: number;
  };
}
```

---

### 2.3. تنظیم موجودی (Set Stock)

```http
POST /api/inventory/set-stock?businessId={businessId}
```

**Request Body:**
```typescript
{
  warehouseId: string;       // (required)
  productId: string;         // (required)
  productVariantId?: string;
  
  quantity: number;          // موجودی جدید (required, min: 0)
  reason?: string;           // دلیل تغییر
}
```

**Response:** `200 OK`
```typescript
{
  inventoryItem: InventoryItem;
  transaction: Transaction;  // تراکنش ADJUSTMENT ایجاد می‌شود
}
```

**Note:** این endpoint موجودی را مستقیماً تنظیم می‌کند (نه افزایش/کاهش).

---

### 2.4. تنظیم حدود موجودی

```http
PATCH /api/inventory/:id/thresholds?businessId={businessId}
```

**Request Body:**
```typescript
{
  minStock?: number;         // حداقل موجودی
  maxStock?: number;         // حداکثر موجودی
  reorderPoint?: number;     // نقطه سفارش مجدد
}
```

**Response:** `200 OK` - همان ساختار InventoryItem

---

### 2.5. رزرو موجودی

```http
POST /api/inventory/reserve?businessId={businessId}
```

**Request Body:**
```typescript
{
  warehouseId: string;       // (required)
  productId: string;         // (required)
  productVariantId?: string;
  quantity: number;          // (required, min: 1)
  referenceType?: string;    // نوع مرجع (مثلاً 'INVOICE')
  referenceId?: string;      // شناسه مرجع
  notes?: string;
}
```

**Response:** `200 OK`
```typescript
{
  inventoryItem: InventoryItem; // با reservedQuantity به‌روز شده
}
```

**Error Responses:**
- `400` - موجودی کافی نیست

---

### 2.6. آزادسازی رزرو

```http
POST /api/inventory/release?businessId={businessId}
```

**Request Body:** (همان فیلدهای reserve)

**Response:** `200 OK` - همان ساختار

---

## 3. Transaction Management

### 3.1. ایجاد تراکنش

```http
POST /api/inventory/transactions?businessId={businessId}
```

**Request Body:**
```typescript
{
  type: TransactionType;     // (required)
  warehouseId: string;       // (required)
  productId: string;         // (required)
  productVariantId?: string;
  
  quantity: number;          // (required, min: 1)
  transactionDate: string;   // تاریخ (ISO) - (required)
  
  // اطلاعات مرجع
  referenceType?: string;    // مثلاً: 'PURCHASE_ORDER', 'INVOICE', 'TRANSFER'
  referenceId?: string;
  referenceNumber?: string;
  
  notes?: string;
}

enum TransactionType {
  IN = 'IN',                 // ورودی
  OUT = 'OUT',               // خروجی
  ADJUSTMENT = 'ADJUSTMENT', // تعدیل
  TRANSFER_IN = 'TRANSFER_IN',   // انتقال ورودی
  TRANSFER_OUT = 'TRANSFER_OUT', // انتقال خروجی
  RETURN = 'RETURN'          // برگشت
}
```

**Response:** `201 Created`
```typescript
{
  id: string;
  businessId: string;
  type: TransactionType;
  warehouseId: string;
  productId: string;
  productVariantId?: string;
  
  quantity: number;
  transactionDate: string;
  
  // موجودی قبل و بعد
  previousQuantity: number;
  newQuantity: number;
  
  referenceType?: string;
  referenceId?: string;
  referenceNumber?: string;
  
  notes?: string;
  createdBy: string;
  createdAt: string;
}
```

**Side Effects:**
- `IN`, `TRANSFER_IN`, `RETURN`: افزایش موجودی
- `OUT`, `TRANSFER_OUT`: کاهش موجودی
- `ADJUSTMENT`: تنظیم به مقدار جدید

---

### 3.2. دریافت تراکنش‌ها

```http
GET /api/inventory/transactions?businessId={businessId}&[filters]
```

**Query Parameters:**
```typescript
{
  businessId: string;        // (required)
  
  // فیلترها
  type?: TransactionType;
  warehouseId?: string;
  productId?: string;
  productVariantId?: string;
  
  referenceType?: string;
  referenceId?: string;
  
  // محدوده تاریخ
  dateFrom?: string;         // ISO date
  dateTo?: string;
  
  // صفحه‌بندی
  page?: number;             // default: 1
  limit?: number;            // default: 50
}
```

**Response:** `200 OK`
```typescript
{
  data: Transaction[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
```

---

### 3.3. جزئیات تراکنش

```http
GET /api/inventory/transactions/:id?businessId={businessId}
```

**Response:** `200 OK` - همان ساختار Transaction با populated product و warehouse

---

### 3.4. حذف تراکنش (فقط ADJUSTMENT)

```http
DELETE /api/inventory/transactions/:id?businessId={businessId}
```

**Response:** `204 No Content`

**Error Responses:**
- `400` - فقط تراکنش‌های ADJUSTMENT قابل حذف هستند
- `400` - نمی‌توان موجودی را برگرداند (منفی می‌شود)

**Note:** موجودی به حالت قبل برمی‌گردد.

---

### 3.5. آمار تراکنش‌ها

```http
GET /api/inventory/transactions/stats?businessId={businessId}&[filters]
```

**Query Parameters:**
```typescript
{
  businessId: string;        // (required)
  warehouseId?: string;
  dateFrom?: string;
  dateTo?: string;
}
```

**Response:** `200 OK`
```typescript
{
  totalTransactions: number;
  
  byType: {
    in: number;
    out: number;
    adjustment: number;
    transferIn: number;
    transferOut: number;
    return: number;
  };
  
  byDate: {
    date: string;            // YYYY-MM-DD
    in: number;
    out: number;
    adjustment: number;
  }[];
  
  topProducts: {
    productId: string;
    productName: string;
    totalIn: number;
    totalOut: number;
  }[];
}
```

---

## 4. Transfer Management

### 4.1. ایجاد انتقال بین انبارها

```http
POST /api/inventory/transfers?businessId={businessId}
```

**Request Body:**
```typescript
{
  fromWarehouseId: string;   // انبار مبدا (required)
  toWarehouseId: string;     // انبار مقصد (required)
  
  transferDate: string;      // تاریخ انتقال (ISO) - (required)
  items: TransferItem[];     // (required, min: 1)
  
  notes?: string;
}

interface TransferItem {
  productId: string;         // (required)
  productVariantId?: string;
  quantity: number;          // (required, min: 1)
  notes?: string;
}
```

**Response:** `201 Created`
```typescript
{
  id: string;
  businessId: string;
  transferNumber: string;    // کد خودکار: TRF-YYYYMMDD-XXXX
  
  fromWarehouseId: string;
  toWarehouseId: string;
  
  transferDate: string;
  
  status: 'DRAFT';           // وضعیت اولیه
  
  items: {
    id: string;
    productId: string;
    productVariantId?: string;
    quantity: number;
    notes?: string;
    
    product: {
      id: string;
      name: string;
      sku: string;
    };
  }[];
  
  notes?: string;
  createdBy: string;
  completedAt?: string;
  createdAt: string;
  updatedAt: string;
}
```

**Error Responses:**
- `400` - موجودی کافی در انبار مبدا نیست
- `400` - انبار مبدا و مقصد یکی هستند

---

### 4.2. دریافت لیست انتقالات

```http
GET /api/inventory/transfers?businessId={businessId}&[filters]
```

**Query Parameters:**
```typescript
{
  businessId: string;        // (required)
  
  fromWarehouseId?: string;
  toWarehouseId?: string;
  status?: 'DRAFT' | 'IN_TRANSIT' | 'COMPLETED' | 'CANCELLED';
  
  dateFrom?: string;
  dateTo?: string;
  
  page?: number;
  limit?: number;
}
```

**Response:** `200 OK`
```typescript
{
  data: Transfer[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
```

---

### 4.3. جزئیات انتقال

```http
GET /api/inventory/transfers/:id?businessId={businessId}
```

**Response:** `200 OK` - همان ساختار Transfer کامل

---

### 4.4. ویرایش انتقال (فقط DRAFT)

```http
PATCH /api/inventory/transfers/:id?businessId={businessId}
```

**Request Body:** (همان فیلدهای create، همه optional)

**Response:** `200 OK` - همان ساختار Transfer

---

### 4.5. حذف انتقال (فقط DRAFT)

```http
DELETE /api/inventory/transfers/:id?businessId={businessId}
```

**Response:** `204 No Content`

---

### 4.6. شروع انتقال

```http
PATCH /api/inventory/transfers/:id/start?businessId={businessId}
```

**Response:** `200 OK` - با `status: 'IN_TRANSIT'`

**Side Effects:**
- موجودی از انبار مبدا کسر می‌شود
- تراکنش `TRANSFER_OUT` ایجاد می‌شود

**Error Responses:**
- `400` - انتقال باید در وضعیت DRAFT باشد

---

### 4.7. تکمیل انتقال

```http
PATCH /api/inventory/transfers/:id/complete?businessId={businessId}
```

**Response:** `200 OK` - با `status: 'COMPLETED'`

**Side Effects:**
- موجودی به انبار مقصد اضافه می‌شود
- تراکنش `TRANSFER_IN` ایجاد می‌شود

**Error Responses:**
- `400` - انتقال باید در وضعیت IN_TRANSIT باشد

---

### 4.8. لغو انتقال

```http
PATCH /api/inventory/transfers/:id/cancel?businessId={businessId}
```

**Request Body:**
```typescript
{
  reason: string;            // دلیل لغو (required)
}
```

**Response:** `200 OK` - با `status: 'CANCELLED'`

**Side Effects:**
- اگر `IN_TRANSIT` بود، موجودی به انبار مبدا برمی‌گردد

---

## 📊 Common Types

### Transfer Status Flow
```
DRAFT → IN_TRANSIT → COMPLETED
   ↓         ↓
CANCELLED  CANCELLED
```

### Stock Status Calculation
```typescript
if (quantity === 0) return 'OUT_OF_STOCK';
if (minStock && quantity <= minStock) return 'LOW_STOCK';
return 'IN_STOCK';
```

---

## 🔒 Business Rules

### Inventory Item
1. **Unique Constraint:**
   - ترکیب `(businessId, warehouseId, productId, productVariantId)` یکتا است

2. **Available Quantity:**
   ```typescript
   availableQuantity = quantity - reservedQuantity
   ```

3. **Negative Stock:**
   - موجودی نمی‌تواند منفی شود (except with special permission)

### Transaction
1. **Effect on Inventory:**
   ```typescript
   IN, TRANSFER_IN, RETURN: quantity += amount
   OUT, TRANSFER_OUT: quantity -= amount
   ADJUSTMENT: quantity = newAmount
   ```

2. **Deletion:**
   - فقط `ADJUSTMENT` قابل حذف است
   - حذف، موجودی را به حالت قبل برمی‌گرداند

### Transfer
1. **Warehouse Validation:**
   - انبار مبدا و مقصد نباید یکی باشند
   - هر دو انبار باید `isActive: true` باشند

2. **Inventory Check:**
   - در `start`: موجودی کافی در مبدا چک می‌شود
   - در `complete`: موجودی به مقصد اضافه می‌شود

3. **Cancellation:**
   - `DRAFT`: بدون اثر
   - `IN_TRANSIT`: موجودی به مبدا برمی‌گردد
   - `COMPLETED`: غیرقابل لغو

---

## ⚠️ Error Handling

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
- `400` - Bad Request (داده‌های نامعتبر، موجودی ناکافی)
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict (موجودی قبلاً ثبت شده)
- `500` - Internal Server Error

---

## 📝 Integration Notes

### با Purchase Order Module
- دریافت کالا (`receipt.complete`) → Transaction `IN`
- به‌روزرسانی خودکار موجودی

### با Invoice Module (آینده)
- ثبت فروش → Transaction `OUT`
- رزرو موجودی برای فاکتور

### با Product Module
- همگام‌سازی `product.currentStock` با مجموع inventory items
- `trackInventory: false` → موجودی ثبت نمی‌شود
