# Purchase Order API Contract - قرارداد API سفارش خرید

> 📋 **منبع حقیقت واحد** برای تمام APIهای مربوط به سفارشات خرید

## Base URL
```
/api/purchase-orders
```

## Authentication
همه endpoint‌ها نیاز به `Bearer Token` دارند.
```
Authorization: Bearer {access_token}
```

---

## 📖 فهرست محتوا

1. [مدیریت سفارش خرید](#1-purchase-order-management)
2. [مدیریت پرداخت‌ها](#2-payment-management)
3. [مدیریت رسیدها](#3-receipt-management)

---

## 1. Purchase Order Management

### 1.1. ایجاد سفارش خرید

```http
POST /api/purchase-orders?businessId={businessId}
```

**Request Body:**
```typescript
{
  supplierId: string;        // (required)
  orderDate: string;         // تاریخ سفارش (ISO) - (required)
  expectedDeliveryDate?: string; // تاریخ تحویل مورد انتظار (ISO)
  
  items: PurchaseOrderItem[]; // (required, min: 1)
  
  shippingCost?: number;     // هزینه حمل - default: 0
  taxAmount?: number;        // مالیات - default: 0
  discountAmount?: number;   // تخفیف - default: 0
  
  paymentTerms?: string;     // شرایط پرداخت
  deliveryAddress?: string;  // آدرس تحویل
  notes?: string;            // یادداشت
}

interface PurchaseOrderItem {
  productId: string;         // (required)
  productVariantId?: string; // برای محصولات دارای تنوع
  quantity: number;          // (required, min: 1)
  unitPrice: number;         // قیمت واحد (required, min: 0)
  notes?: string;
}
```

**Response:** `201 Created`
```typescript
{
  id: string;
  businessId: string;
  supplierId: string;
  orderNumber: string;       // کد خودکار: PO-YYYYMMDD-XXXX
  
  orderDate: string;
  expectedDeliveryDate?: string;
  actualDeliveryDate?: string;
  
  status: 'DRAFT';           // وضعیت اولیه
  
  items: {
    id: string;
    productId: string;
    productVariantId?: string;
    quantity: number;
    receivedQuantity: 0;     // دریافت شده اولیه
    unitPrice: number;
    totalPrice: number;      // quantity × unitPrice
    notes?: string;
    
    // اطلاعات محصول (populated)
    product: {
      id: string;
      name: string;
      sku: string;
    };
    productVariant?: {
      id: string;
      sku: string;
      attributeValues: { name: string; value: string }[];
    };
  }[];
  
  subtotal: number;          // مجموع items
  shippingCost: number;
  taxAmount: number;
  discountAmount: number;
  totalAmount: number;       // محاسبه خودکار
  
  paidAmount: 0;             // پرداخت شده اولیه
  remainingAmount: number;   // مانده
  
  paymentTerms?: string;
  deliveryAddress?: string;
  notes?: string;
  
  createdBy: string;         // userId
  approvedBy?: string;
  createdAt: string;
  updatedAt: string;
}
```

**Calculation:**
```typescript
subtotal = sum(item.totalPrice for each item)
totalAmount = subtotal + shippingCost + taxAmount - discountAmount
remainingAmount = totalAmount - paidAmount
```

**Error Responses:**
- `400` - داده‌های نامعتبر یا تامین‌کننده غیر فعال
- `404` - تامین‌کننده یا محصول یافت نشد

---

### 1.2. دریافت لیست سفارشات

```http
GET /api/purchase-orders?businessId={businessId}&[filters]
```

**Query Parameters:**
```typescript
{
  businessId: string;        // (required)
  
  // فیلترها
  supplierId?: string;
  status?: PurchaseOrderStatus;
  orderNumber?: string;      // جستجوی دقیق
  
  // محدوده تاریخ
  dateFrom?: string;         // ISO date
  dateTo?: string;
  
  // محدوده مبلغ
  minTotal?: number;
  maxTotal?: number;
  
  // صفحه‌بندی
  page?: number;             // default: 1
  limit?: number;            // default: 50, max: 100
}
```

**Purchase Order Status:**
```typescript
enum PurchaseOrderStatus {
  DRAFT = 'DRAFT',                     // پیش‌نویس
  PENDING_APPROVAL = 'PENDING_APPROVAL', // در انتظار تایید
  APPROVED = 'APPROVED',               // تایید شده
  SENT = 'SENT',                       // ارسال شده به تامین‌کننده
  PARTIALLY_RECEIVED = 'PARTIALLY_RECEIVED', // دریافت جزئی
  RECEIVED = 'RECEIVED',               // دریافت کامل
  CANCELLED = 'CANCELLED',             // لغو شده
  CLOSED = 'CLOSED'                    // بسته شده
}
```

**Response:** `200 OK`
```typescript
{
  data: PurchaseOrder[];     // بدون items (لیست مختصر)
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
```

---

### 1.3. دریافت جزئیات سفارش

```http
GET /api/purchase-orders/:id?businessId={businessId}
```

**Response:** `200 OK` - همان ساختار کامل ایجاد با items

---

### 1.4. دریافت با شماره سفارش

```http
GET /api/purchase-orders/by-number/:orderNumber?businessId={businessId}
```

**Response:** `200 OK` - همان ساختار کامل

---

### 1.5. ویرایش سفارش (فقط DRAFT)

```http
PATCH /api/purchase-orders/:id?businessId={businessId}
```

**Request Body:** (همان فیلدهای create، همه optional)

**Response:** `200 OK` - همان ساختار کامل

**Error Responses:**
- `400` - فقط سفارشات DRAFT قابل ویرایش هستند
- `404` - سفارش یافت نشد

---

### 1.6. حذف سفارش (فقط DRAFT)

```http
DELETE /api/purchase-orders/:id?businessId={businessId}
```

**Response:** `204 No Content`

**Error Responses:**
- `400` - فقط سفارشات DRAFT قابل حذف هستند

---

### 1.7. ارسال برای تایید

```http
PATCH /api/purchase-orders/:id/submit?businessId={businessId}
```

**Response:** `200 OK` - با `status: 'PENDING_APPROVAL'`

**Error Responses:**
- `400` - سفارش باید در وضعیت DRAFT باشد

---

### 1.8. تایید سفارش

```http
PATCH /api/purchase-orders/:id/approve?businessId={businessId}
```

**Response:** `200 OK` - با `status: 'APPROVED'`

**Note:** `approvedBy` و `approvedAt` ثبت می‌شود.

---

### 1.9. رد سفارش

```http
PATCH /api/purchase-orders/:id/reject?businessId={businessId}
```

**Request Body:**
```typescript
{
  reason: string;            // دلیل رد (required)
}
```

**Response:** `200 OK` - با `status: 'DRAFT'` (برگشت به پیش‌نویس)

---

### 1.10. ارسال به تامین‌کننده

```http
PATCH /api/purchase-orders/:id/send?businessId={businessId}
```

**Response:** `200 OK` - با `status: 'SENT'`

**Error Responses:**
- `400` - سفارش باید APPROVED باشد

---

### 1.11. لغو سفارش

```http
PATCH /api/purchase-orders/:id/cancel?businessId={businessId}
```

**Request Body:**
```typescript
{
  reason: string;            // دلیل لغو (required)
}
```

**Response:** `200 OK` - با `status: 'CANCELLED'`

**Error Responses:**
- `400` - سفارش نمی‌تواند لغو شود (مثلاً RECEIVED است)

---

### 1.12. بستن سفارش

```http
PATCH /api/purchase-orders/:id/close?businessId={businessId}
```

**Response:** `200 OK` - با `status: 'CLOSED'`

**Note:** برای سفارشاتی که کامل نشدند ولی دیگر پیگیری نمی‌شوند.

---

### 1.13. آمار سفارشات

```http
GET /api/purchase-orders/stats?businessId={businessId}
```

**Response:** `200 OK`
```typescript
{
  totalOrders: number;
  
  // تفکیک وضعیت
  byStatus: {
    draft: number;
    pendingApproval: number;
    approved: number;
    sent: number;
    partiallyReceived: number;
    received: number;
    cancelled: number;
    closed: number;
  };
  
  // مالی
  totalAmount: number;       // مجموع ارزش سفارشات
  totalPaid: number;         // مجموع پرداخت شده
  totalRemaining: number;    // مجموع باقیمانده
  
  // محصولات
  totalItems: number;        // تعداد کل آیتم‌ها
  totalQuantity: number;     // تعداد کل واحدها
  receivedQuantity: number;  // تعداد دریافت شده
  
  // تامین‌کنندگان
  activeSuppliers: number;   // تعداد تامین‌کنندگانی با سفارش فعال
}
```

---

## 2. Payment Management

### 2.1. ثبت پرداخت

```http
POST /api/purchase-orders/:purchaseOrderId/payments?businessId={businessId}
```

**Request Body:**
```typescript
{
  amount: number;            // مبلغ (required, min: 0.01)
  paymentDate: string;       // تاریخ پرداخت (ISO) - (required)
  paymentMethod: PaymentMethod; // (required)
  
  referenceNumber?: string;  // شماره مرجع/رسید
  notes?: string;
}

enum PaymentMethod {
  CASH = 'CASH',             // نقد
  BANK_TRANSFER = 'BANK_TRANSFER', // انتقال بانکی
  CHEQUE = 'CHEQUE',         // چک
  CARD = 'CARD',             // کارت
  ONLINE = 'ONLINE',         // آنلاین
  OTHER = 'OTHER'            // سایر
}
```

**Response:** `201 Created`
```typescript
{
  id: string;
  purchaseOrderId: string;
  amount: number;
  paymentDate: string;
  paymentMethod: PaymentMethod;
  referenceNumber?: string;
  
  status: 'PENDING';         // وضعیت اولیه
  
  notes?: string;
  paidBy: string;            // userId
  createdAt: string;
  updatedAt: string;
}
```

**Error Responses:**
- `400` - مبلغ بیش از مانده سفارش است
- `404` - سفارش یافت نشد

---

### 2.2. دریافت پرداخت‌های سفارش

```http
GET /api/purchase-orders/:purchaseOrderId/payments?businessId={businessId}
```

**Response:** `200 OK`
```typescript
{
  data: Payment[];
  summary: {
    totalPaid: number;
    totalPending: number;
    totalCompleted: number;
    remainingAmount: number;
  };
}
```

---

### 2.3. جزئیات پرداخت

```http
GET /api/purchase-orders/:purchaseOrderId/payments/:id?businessId={businessId}
```

**Response:** `200 OK`
```typescript
{
  id: string;
  purchaseOrderId: string;
  amount: number;
  paymentDate: string;
  paymentMethod: PaymentMethod;
  referenceNumber?: string;
  
  status: 'PENDING' | 'COMPLETED' | 'FAILED' | 'CANCELLED';
  
  // اگر COMPLETED
  completedAt?: string;
  
  // اگر FAILED
  failureReason?: string;
  failedAt?: string;
  
  notes?: string;
  paidBy: string;
  createdAt: string;
  updatedAt: string;
}
```

---

### 2.4. ویرایش پرداخت (فقط PENDING)

```http
PATCH /api/purchase-orders/:purchaseOrderId/payments/:id?businessId={businessId}
```

**Request Body:** (همان فیلدهای create، همه optional)

**Response:** `200 OK` - همان ساختار Payment

**Error Responses:**
- `400` - فقط پرداخت‌های PENDING قابل ویرایش هستند

---

### 2.5. حذف پرداخت (فقط PENDING)

```http
DELETE /api/purchase-orders/:purchaseOrderId/payments/:id?businessId={businessId}
```

**Response:** `204 No Content`

---

### 2.6. تکمیل پرداخت

```http
PATCH /api/purchase-orders/:purchaseOrderId/payments/:id/complete?businessId={businessId}
```

**Response:** `200 OK` - با `status: 'COMPLETED'`

**Side Effects:**
- `paidAmount` سفارش به‌روز می‌شود
- `balance` تامین‌کننده به‌روز می‌شود
- `lastPaymentDate` تامین‌کننده ثبت می‌شود

---

### 2.7. شکست پرداخت

```http
PATCH /api/purchase-orders/:purchaseOrderId/payments/:id/fail?businessId={businessId}
```

**Request Body:**
```typescript
{
  reason?: string;           // دلیل شکست
}
```

**Response:** `200 OK` - با `status: 'FAILED'`

---

### 2.8. لغو پرداخت

```http
PATCH /api/purchase-orders/:purchaseOrderId/payments/:id/cancel?businessId={businessId}
```

**Request Body:**
```typescript
{
  reason?: string;           // دلیل لغو
}
```

**Response:** `200 OK` - با `status: 'CANCELLED'`

**Note:** اگر قبلاً COMPLETED بود، مبالغ بازگردانده می‌شوند.

---

## 3. Receipt Management

### 3.1. ثبت رسید دریافت کالا

```http
POST /api/purchase-orders/:purchaseOrderId/receipts?businessId={businessId}
```

**Request Body:**
```typescript
{
  receiptDate: string;       // تاریخ دریافت (ISO) - (required)
  items: ReceiptItem[];      // (required, min: 1)
  notes?: string;
}

interface ReceiptItem {
  purchaseOrderItemId: string; // (required)
  receivedQuantity: number;  // (required, min: 1)
  notes?: string;
}
```

**Response:** `201 Created`
```typescript
{
  id: string;
  purchaseOrderId: string;
  receiptNumber: string;     // کد خودکار: RCP-YYYYMMDD-XXXX
  receiptDate: string;
  
  status: 'DRAFT';           // وضعیت اولیه
  
  items: {
    id: string;
    purchaseOrderItemId: string;
    receivedQuantity: number;
    notes?: string;
    
    // اطلاعات آیتم سفارش
    orderItem: {
      productId: string;
      productVariantId?: string;
      quantity: number;
      receivedQuantity: number; // قبل از این رسید
      product: {
        id: string;
        name: string;
        sku: string;
      };
    };
  }[];
  
  notes?: string;
  receivedBy: string;        // userId
  completedAt?: string;
  createdAt: string;
  updatedAt: string;
}
```

**Validation:**
- `receivedQuantity` نباید بیش از `(quantity - receivedQuantity)` هر آیتم باشد

**Error Responses:**
- `400` - مقدار نامعتبر یا بیش از مانده سفارش
- `404` - سفارش یا آیتم یافت نشد

---

### 3.2. دریافت رسیدهای سفارش

```http
GET /api/purchase-orders/:purchaseOrderId/receipts?businessId={businessId}
```

**Response:** `200 OK`
```typescript
{
  data: Receipt[];
  summary: {
    totalReceipts: number;
    totalItems: number;
    totalQuantity: number;    // مجموع دریافت شده
  };
}
```

---

### 3.3. جزئیات رسید

```http
GET /api/purchase-orders/:purchaseOrderId/receipts/:id?businessId={businessId}
```

**Response:** `200 OK` - همان ساختار کامل Receipt

---

### 3.4. ویرایش رسید (فقط DRAFT)

```http
PATCH /api/purchase-orders/:purchaseOrderId/receipts/:id?businessId={businessId}
```

**Request Body:** (همان فیلدهای create، همه optional)

**Response:** `200 OK` - همان ساختار Receipt

**Error Responses:**
- `400` - فقط رسیدهای DRAFT قابل ویرایش هستند

---

### 3.5. حذف رسید (فقط DRAFT)

```http
DELETE /api/purchase-orders/:purchaseOrderId/receipts/:id?businessId={businessId}
```

**Response:** `204 No Content`

---

### 3.6. تکمیل رسید

```http
PATCH /api/purchase-orders/:purchaseOrderId/receipts/:id/complete?businessId={businessId}
```

**Response:** `200 OK` - با `status: 'COMPLETED'`

**Side Effects:**
1. `receivedQuantity` آیتم‌های سفارش به‌روز می‌شود
2. موجودی محصولات افزایش می‌یابد
3. اگر تمام آیتم‌ها دریافت شدند: `status: 'RECEIVED'`
4. اگر بخشی دریافت شد: `status: 'PARTIALLY_RECEIVED'`
5. `actualDeliveryDate` در اولین رسید کامل ثبت می‌شود

**Error Responses:**
- `400` - رسید قبلاً تکمیل شده

---

### 3.7. لغو رسید

```http
PATCH /api/purchase-orders/:purchaseOrderId/receipts/:id/cancel?businessId={businessId}
```

**Request Body:**
```typescript
{
  reason?: string;           // دلیل لغو
}
```

**Response:** `200 OK` - با `status: 'CANCELLED'`

**Note:** اگر قبلاً COMPLETED بود، مقادیر بازگردانده می‌شوند (موجودی، receivedQuantity).

---

## 📊 Common Types

### Purchase Order Status Flow
```
DRAFT → PENDING_APPROVAL → APPROVED → SENT → PARTIALLY_RECEIVED → RECEIVED → CLOSED
                              ↓                        ↓
                          CANCELLED                CANCELLED
```

### Payment Status
```typescript
enum PaymentStatus {
  PENDING = 'PENDING',       // در انتظار
  COMPLETED = 'COMPLETED',   // تکمیل شده
  FAILED = 'FAILED',         // ناموفق
  CANCELLED = 'CANCELLED'    // لغو شده
}
```

### Receipt Status
```typescript
enum ReceiptStatus {
  DRAFT = 'DRAFT',           // پیش‌نویس
  COMPLETED = 'COMPLETED',   // تکمیل شده
  CANCELLED = 'CANCELLED'    // لغو شده
}
```

---

## 🔒 Business Rules

### Purchase Order
1. **Auto Calculations:**
   ```typescript
   item.totalPrice = item.quantity × item.unitPrice
   subtotal = sum(item.totalPrice)
   totalAmount = subtotal + shippingCost + taxAmount - discountAmount
   remainingAmount = totalAmount - paidAmount
   ```

2. **Status Transitions:**
   - `DRAFT` → `PENDING_APPROVAL`: حداقل 1 آیتم داشته باشد
   - `PENDING_APPROVAL` → `APPROVED`: توسط user مجاز
   - `APPROVED` → `SENT`: آماده ارسال به تامین‌کننده
   - `SENT` → `PARTIALLY_RECEIVED`: اولین رسید کامل
   - `PARTIALLY_RECEIVED` → `RECEIVED`: تمام آیتم‌ها دریافت شدند

3. **Edit Restrictions:**
   - فقط `DRAFT` قابل ویرایش و حذف است
   - `CANCELLED` و `CLOSED` غیرقابل تغییر هستند

### Payment
1. مجموع پرداخت‌های COMPLETED نباید از `totalAmount` سفارش بیشتر شود
2. فقط `PENDING` قابل ویرایش و حذف است
3. لغو پرداخت `COMPLETED` مبالغ را بازمی‌گرداند

### Receipt
1. **Quantity Validation:**
   ```typescript
   maxReceivable = item.quantity - item.receivedQuantity
   receivedQuantity <= maxReceivable
   ```

2. **Inventory Update:**
   - در تکمیل رسید: `product.currentStock += receivedQuantity`
   - در لغو رسید تکمیل شده: `product.currentStock -= receivedQuantity`

3. **Order Status Update:**
   ```typescript
   if (all items fully received) {
     purchaseOrder.status = 'RECEIVED'
     purchaseOrder.actualDeliveryDate = receipt.receiptDate
   } else if (any item partially received) {
     purchaseOrder.status = 'PARTIALLY_RECEIVED'
   }
   ```

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
- `400` - Bad Request (داده‌های نامعتبر، عملیات غیرمجاز)
- `401` - Unauthorized (عدم احراز هویت)
- `403` - Forbidden (عدم دسترسی)
- `404` - Not Found (یافت نشد)
- `409` - Conflict (تداخل داده)
- `500` - Internal Server Error (خطای سرور)

---

## 📝 Integration Notes

### با Supplier Module
- تایید status تامین‌کننده قبل از ایجاد سفارش
- به‌روزرسانی `balance`, `totalPurchases`, `lastPurchaseDate`

### با Product Module
- تایید موجود بودن محصول و variant
- به‌روزرسانی `currentStock` در تکمیل رسید

### با Inventory Module
- ایجاد transaction برای هر رسید تکمیل شده
- ردیابی موجودی در سطح انبار
