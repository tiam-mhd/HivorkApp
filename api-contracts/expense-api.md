# Expense API Documentation

## Base URL
```
/expenses
/expense-categories
```

---

## 📊 Expense Categories API

### 1. Get All Categories
```http
GET /expense-categories?businessId={businessId}
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| businessId | string (UUID) | ✅ | شناسه کسب‌وکار |

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Success",
  data: ExpenseCategory[]
}
```

**ExpenseCategory Model:**
```typescript
{
  id: string;                    // UUID
  businessId: string;            // UUID
  parentId?: string;             // UUID - دسته والد (برای سلسله‌مراتب)
  name: string;                  // نام دسته
  description?: string;          // توضیحات
  color?: string;                // رنگ (#RRGGBB)
  icon?: string;                 // نام آیکون Material
  isActive: boolean;             // فعال/غیرفعال
  isSystem: boolean;             // دسته سیستمی (قابل حذف نیست)
  sortOrder: number;             // ترتیب نمایش
  budgetAmount?: number;         // بودجه ماهانه (Phase 2)
  createdAt: string;             // ISO date
  updatedAt: string;             // ISO date
}
```

---

### 2. Get Category Hierarchy
```http
GET /expense-categories/hierarchy?businessId={businessId}
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| businessId | string (UUID) | ✅ | شناسه کسب‌وکار |

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Success",
  data: ExpenseCategoryTree[]
}

// ExpenseCategoryTree
{
  ...ExpenseCategory,
  children: ExpenseCategoryTree[]  // زیرمجموعه‌ها
}
```

---

### 3. Get Single Category
```http
GET /expense-categories/:id
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Success",
  data: ExpenseCategory
}
```

---

### 4. Create Category
```http
POST /expense-categories
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```typescript
{
  businessId: string;        // Required - UUID
  parentId?: string;         // Optional - UUID
  name: string;              // Required - max 255
  description?: string;      // Optional
  color?: string;            // Optional - #RRGGBB format
  icon?: string;             // Optional - Material icon name
  sortOrder?: number;        // Optional - default: 0
  budgetAmount?: number;     // Optional - monthly budget
}
```

**Response 201:**
```typescript
{
  statusCode: 201,
  message: "Expense category created successfully",
  data: ExpenseCategory
}
```

---

### 5. Update Category
```http
PUT /expense-categories/:id
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:** (همه فیلدها optional)
```typescript
{
  parentId?: string;
  name?: string;
  description?: string;
  color?: string;
  icon?: string;
  isActive?: boolean;
  sortOrder?: number;
  budgetAmount?: number;
}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Expense category updated successfully",
  data: ExpenseCategory
}
```

---

### 6. Delete Category
```http
DELETE /expense-categories/:id
Authorization: Bearer {token}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Expense category deleted successfully"
}
```

**Note:** دسته‌های سیستمی (isSystem: true) قابل حذف نیستند.

---

### 7. Create System Default Categories
```http
POST /expense-categories/system?businessId={businessId}
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| businessId | string (UUID) | ✅ | شناسه کسب‌وکار |

**Response 201:**
```typescript
{
  statusCode: 201,
  message: "System categories created successfully",
  data: {
    created: number  // تعداد دسته‌های ساخته شده
  }
}
```

**Default Categories Created:**
1. خرید کالا (#FF9800) - با 3 زیرمجموعه
2. حقوق و دستمزد (#2196F3) - با 3 زیرمجموعه
3. اجاره (#4CAF50) - با 2 زیرمجموعه
4. آب و برق و گاز (#FFC107) - با 3 زیرمجموعه
5. حمل و نقل (#9C27B0) - با 3 زیرمجموعه
6. بازاریابی و تبلیغات (#E91E63) - با 3 زیرمجموعه
7. نگهداری و تعمیرات (#795548) - با 2 زیرمجموعه
8. سایر هزینه‌ها (#9E9E9E)

---

## 💰 Expenses API

### 1. Get All Expenses (with filters)
```http
GET /expenses?businessId={businessId}&[filters]
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| businessId | string (UUID) | ✅ | شناسه کسب‌وکار |
| search | string | ❌ | جستجو در عنوان و توضیحات |
| categoryId | string (UUID) | ❌ | فیلتر بر اساس دسته |
| paymentMethod | enum | ❌ | روش پرداخت |
| paymentStatus | enum | ❌ | وضعیت پرداخت |
| fromDate | string (ISO) | ❌ | از تاریخ |
| toDate | string (ISO) | ❌ | تا تاریخ |
| minAmount | number | ❌ | حداقل مبلغ |
| maxAmount | number | ❌ | حداکثر مبلغ |
| page | number | ❌ | شماره صفحه (default: 1) |
| limit | number | ❌ | تعداد در صفحه (default: 20) |

**Payment Method Enum:**
- `cash` - نقد
- `card` - کارت
- `bank_transfer` - انتقال بانکی
- `check` - چک
- `credit` - اعتبار
- `other` - سایر

**Payment Status Enum:**
- `pending` - در انتظار
- `paid` - پرداخت شده
- `partially_paid` - پرداخت جزئی
- `cancelled` - لغو شده

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Success",
  data: {
    expenses: Expense[],
    pagination: {
      page: number,
      limit: number,
      total: number,
      totalPages: number
    }
  }
}
```

**Expense Model:**
```typescript
{
  id: string;                         // UUID
  businessId: string;                 // UUID
  categoryId?: string;                // UUID
  category?: ExpenseCategory;         // Populated category
  
  title: string;                      // عنوان هزینه
  description?: string;               // توضیحات تکمیلی
  
  amount: number;                     // مبلغ (Rial)
  
  expenseDate: string;                // تاریخ هزینه (ISO)
  
  paymentMethod: PaymentMethod;       // روش پرداخت
  paymentStatus: PaymentStatus;       // وضعیت پرداخت
  
  referenceType?: ReferenceType;      // نوع ارجاع
  referenceId?: string;               // UUID - شناسه مرجع
  
  attachments?: Attachment[];         // فایل‌های پیوست
  
  isPaid: boolean;                    // پرداخت شده؟
  
  tags?: string[];                    // برچسب‌ها
  note?: string;                      // یادداشت داخلی
  
  isRecurring: boolean;               // تکراری؟
  recurringRule?: RecurringRule;      // قانون تکرار
  
  createdBy: string;                  // UUID - ایجاد کننده
  approvedBy?: string;                // UUID - تایید کننده
  approvedAt?: string;                // ISO date
  
  createdAt: string;                  // ISO date
  updatedAt: string;                  // ISO date
  deletedAt?: string;                 // ISO date (soft delete)
}
```

**Attachment Model:**
```typescript
{
  url: string;
  filename: string;
  mimeType: string;
  size: number;  // bytes
}
```

**RecurringRule Model:**
```typescript
{
  frequency: 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'yearly';
  interval: number;      // هر چند دوره یکبار
  endDate?: string;      // تاریخ پایان (ISO)
}
```

**Reference Type Enum:**
- `product_purchase` - خرید محصول
- `salary` - حقوق
- `supplier_payment` - پرداخت به تامین‌کننده
- `rent` - اجاره
- `utility` - آب و برق و گاز
- `other` - سایر

---

### 2. Get Single Expense
```http
GET /expenses/:id
Authorization: Bearer {token}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Success",
  data: Expense  // با category populated
}
```

---

### 3. Create Expense
```http
POST /expenses
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```typescript
{
  businessId: string;              // Required - UUID
  categoryId?: string;             // Optional - UUID
  
  title: string;                   // Required - max 255
  description?: string;            // Optional
  
  amount: number;                  // Required - min: 0
  
  expenseDate: string;             // Required - ISO date
  
  paymentMethod: PaymentMethod;    // Required
  paymentStatus: PaymentStatus;    // Required
  
  referenceType?: ReferenceType;   // Optional
  referenceId?: string;            // Optional - UUID
  
  isPaid?: boolean;                // Optional - default: true
  
  tags?: string[];                 // Optional
  note?: string;                   // Optional
  
  isRecurring?: boolean;           // Optional - default: false
  recurringRule?: RecurringRule;   // Optional
}
```

**Response 201:**
```typescript
{
  statusCode: 201,
  message: "Expense created successfully",
  data: Expense
}
```

---

### 4. Update Expense
```http
PUT /expenses/:id
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:** (همه فیلدها optional)
```typescript
{
  categoryId?: string;
  title?: string;
  description?: string;
  amount?: number;
  expenseDate?: string;
  paymentMethod?: PaymentMethod;
  paymentStatus?: PaymentStatus;
  referenceType?: ReferenceType;
  referenceId?: string;
  isPaid?: boolean;
  tags?: string[];
  note?: string;
  isRecurring?: boolean;
  recurringRule?: RecurringRule;
}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Expense updated successfully",
  data: Expense
}
```

---

### 5. Delete Expense
```http
DELETE /expenses/:id
Authorization: Bearer {token}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Expense deleted successfully"
}
```

**Note:** Soft delete - فقط deletedAt ست می‌شود.

---

### 6. Upload Attachment
```http
POST /expenses/:id/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body:**
```
file: File (image or PDF, max 10MB)
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "File uploaded successfully",
  data: Expense  // با attachments بروز شده
}
```

---

### 7. Delete Attachment
```http
DELETE /expenses/:id/attachments/:filename
Authorization: Bearer {token}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Attachment removed successfully",
  data: Expense
}
```

---

### 8. Approve Expense
```http
POST /expenses/:id/approve
Authorization: Bearer {token}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Expense approved successfully",
  data: Expense  // با approvedBy و approvedAt
}
```

---

### 9. Reject Expense
```http
POST /expenses/:id/reject
Authorization: Bearer {token}
```

**Request Body:**
```typescript
{
  reason?: string;  // دلیل رد
}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Expense rejected successfully",
  data: Expense
}
```

---

## 📈 Statistics & Reports API

### 1. Get Expense Statistics
```http
GET /expenses/stats?businessId={businessId}
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| businessId | string (UUID) | ✅ | شناسه کسب‌وکار |

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Success",
  data: {
    totalExpenses: number,           // کل هزینه‌ها
    totalAmount: number,              // مجموع مبلغ
    todayTotal: number,               // کل امروز
    monthTotal: number,               // کل این ماه
    yearTotal: number,                // کل امسال
    categoryBreakdown: {
      categoryId: string,
      categoryName: string,
      categoryColor: string,
      totalAmount: number,
      percentage: number,
      count: number
    }[],
    monthlyChange: number,            // درصد تغییر نسبت به ماه قبل
    averageExpense: number            // میانگین هزینه
  }
}
```

---

### 2. Get Top Expenses
```http
GET /expenses/top?businessId={businessId}&limit={limit}
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| businessId | string (UUID) | ✅ | - | شناسه کسب‌وکار |
| limit | number | ❌ | 10 | تعداد هزینه‌ها |

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Success",
  data: Expense[]  // مرتب شده بر اساس amount (نزولی)
}
```

---

### 3. Get Daily Total
```http
GET /expenses/daily-total?businessId={businessId}&date={date}
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| businessId | string (UUID) | ✅ | - | شناسه کسب‌وکار |
| date | string (ISO) | ✅ | - | تاریخ مورد نظر |

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Success",
  data: {
    date: string,
    total: number
  }
}
```

---

### 4. Get Monthly Total
```http
GET /expenses/monthly-total?businessId={businessId}&year={year}&month={month}
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| businessId | string (UUID) | ✅ | شناسه کسب‌وکار |
| year | number | ✅ | سال (مثلاً 2025) |
| month | number | ✅ | ماه (1-12) |

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Success",
  data: {
    year: number,
    month: number,
    total: number
  }
}
```

---

### 5. Get Yearly Total
```http
GET /expenses/yearly-total?businessId={businessId}&year={year}
Authorization: Bearer {token}
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| businessId | string (UUID) | ✅ | شناسه کسب‌وکار |
| year | number | ✅ | سال (مثلاً 2025) |

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Success",
  data: {
    year: number,
    total: number
  }
}
```

---

## 🚨 Error Responses

### 400 Bad Request
```typescript
{
  statusCode: 400,
  message: "Validation failed",
  errors: [
    {
      field: "amount",
      message: "Amount must be greater than 0"
    }
  ]
}
```

### 401 Unauthorized
```typescript
{
  statusCode: 401,
  message: "Unauthorized"
}
```

### 403 Forbidden
```typescript
{
  statusCode: 403,
  message: "You don't have permission to access this resource"
}
```

### 404 Not Found
```typescript
{
  statusCode: 404,
  message: "Expense not found"
}
```

### 500 Internal Server Error
```typescript
{
  statusCode: 500,
  message: "Internal server error",
  error?: string
}
```

---

## 🔄 Recurring Expenses API (Phase 2)

### 1. Create Recurring Expense
```http
POST /recurring-expenses
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```typescript
{
  businessId: string;            // UUID - الزامی
  categoryId?: string;           // UUID - دسته‌بندی
  title: string;                 // نام هزینه تکراری
  description?: string;          // توضیحات
  amount: number;                // مبلغ (decimal 15,2)
  frequency: RecurringFrequency; // تناوب (enum)
  interval: number;              // فاصله (پیش‌فرض: 1)
  startDate: string;             // تاریخ شروع (ISO date)
  endDate?: string;              // تاریخ پایان (اختیاری)
  paymentMethod: PaymentMethod;  // روش پرداخت
  autoCreate: boolean;           // ایجاد خودکار (پیش‌فرض: true)
  tags?: string;                 // برچسب‌ها
  note?: string;                 // یادداشت
}
```

**RecurringFrequency Enum:**
```typescript
enum RecurringFrequency {
  DAILY = 'daily',           // روزانه
  WEEKLY = 'weekly',         // هفتگی
  MONTHLY = 'monthly',       // ماهانه
  QUARTERLY = 'quarterly',   // سه‌ماهه
  YEARLY = 'yearly'          // سالانه
}
```

**Response 201:**
```typescript
{
  statusCode: 201,
  message: "Recurring expense created successfully",
  data: RecurringExpense
}
```

**RecurringExpense Model:**
```typescript
{
  id: string;                    // UUID
  businessId: string;            // UUID
  categoryId?: string;           // UUID
  title: string;                 // نام هزینه
  description?: string;          // توضیحات
  amount: number;                // مبلغ
  frequency: RecurringFrequency; // تناوب
  interval: number;              // فاصله (مثلا هر 2 ماه)
  startDate: string;             // تاریخ شروع
  endDate?: string;              // تاریخ پایان
  nextOccurrence: string;        // تاریخ هزینه بعدی
  paymentMethod: PaymentMethod;  // روش پرداخت
  isActive: boolean;             // فعال/غیرفعال
  autoCreate: boolean;           // ایجاد خودکار
  lastCreatedAt?: string;        // آخرین هزینه ایجاد شده
  tags?: string;                 // برچسب‌ها
  note?: string;                 // یادداشت
  createdAt: string;             // تاریخ ایجاد
  updatedAt: string;             // تاریخ بروزرسانی
}
```

**Example:**
```json
{
  "businessId": "123e4567-e89b-12d3-a456-426614174000",
  "categoryId": "223e4567-e89b-12d3-a456-426614174000",
  "title": "Monthly Office Rent",
  "description": "Office space rental payment",
  "amount": 15000000,
  "frequency": "monthly",
  "interval": 1,
  "startDate": "2025-01-01",
  "endDate": null,
  "paymentMethod": "bank_transfer",
  "autoCreate": true,
  "tags": "rent,office,fixed-cost",
  "note": "Payable on 1st of each month"
}
```

---

### 2. Get All Recurring Expenses
```http
GET /recurring-expenses?businessId={businessId}
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| businessId | string (UUID) | ✅ | شناسه کسب‌وکار |

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Success",
  data: RecurringExpense[]
}
```

---

### 3. Get Single Recurring Expense
```http
GET /recurring-expenses/:id?businessId={businessId}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Success",
  data: {
    ...RecurringExpense,
    generatedExpenses: Expense[]  // هزینه‌های ایجاد شده از این الگو
  }
}
```

---

### 4. Update Recurring Expense
```http
PUT /recurring-expenses/:id
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:** (همه فیلدها اختیاری)
```typescript
{
  categoryId?: string;
  title?: string;
  description?: string;
  amount?: number;
  frequency?: RecurringFrequency;
  interval?: number;
  startDate?: string;
  endDate?: string;
  paymentMethod?: PaymentMethod;
  autoCreate?: boolean;
  isActive?: boolean;
  tags?: string;
  note?: string;
}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Recurring expense updated",
  data: RecurringExpense
}
```

**Note:** تغییر frequency یا startDate باعث محاسبه مجدد nextOccurrence می‌شود

---

### 5. Delete Recurring Expense
```http
DELETE /recurring-expenses/:id?businessId={businessId}
Authorization: Bearer {token}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Recurring expense deleted"
}
```

**Note:** حذف الگو روی هزینه‌های ایجاد شده قبلی تاثیری ندارد

---

### 6. Toggle Active Status
```http
POST /recurring-expenses/:id/toggle-active?businessId={businessId}
Authorization: Bearer {token}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Active status toggled",
  data: {
    isActive: boolean  // وضعیت جدید
  }
}
```

**Use Case:** غیرفعال کردن موقت بدون حذف (مثلا تعطیلات)

---

### 7. Skip Next Occurrence
```http
POST /recurring-expenses/:id/skip?businessId={businessId}
Authorization: Bearer {token}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Next occurrence skipped",
  data: {
    previousNextOccurrence: string,
    newNextOccurrence: string
  }
}
```

**Use Case:** رد شدن یک‌بار از نوبت بعدی (مثلا پرداخت شده از جای دیگر)

---

### 8. Get Upcoming Occurrences
```http
GET /recurring-expenses/:id/upcoming?businessId={businessId}&count={count}
```

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| businessId | string (UUID) | ✅ | - | شناسه کسب‌وکار |
| count | number | ❌ | 5 | تعداد تاریخ‌های آینده |

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Success",
  data: string[]  // آرایه تاریخ‌های آینده (ISO)
}
```

**Example:**
```json
{
  "statusCode": 200,
  "message": "Success",
  "data": [
    "2025-01-01",
    "2025-02-01",
    "2025-03-01",
    "2025-04-01",
    "2025-05-01"
  ]
}
```

**Use Case:** پیش‌نمایش تاریخ‌های ایجاد خودکار

---

### 9. Manual Cron Trigger (Testing)
```http
POST /recurring-expenses/cron/trigger-manual
Authorization: Bearer {token}
```

**Response 200:**
```typescript
{
  statusCode: 200,
  message: "Cron job triggered manually",
  data: {
    created: number,   // تعداد هزینه‌های ایجاد شده
    errors: number     // تعداد خطاها
  }
}
```

**Use Case:** تست دستی ایجاد خودکار هزینه‌ها (در production به صورت خودکار هر روز ساعت 00:00 اجرا می‌شود)

---

## 🤖 Automatic Expense Creation

### Cron Job Details:
- **Schedule:** Every day at 00:00 (midnight)
- **Process:** Finds all active recurring expenses with `nextOccurrence <= today`
- **Actions:**
  1. Creates new expense with `paymentStatus: pending`
  2. Links expense to recurring template (`recurringExpenseId`)
  3. Updates `nextOccurrence` based on frequency
  4. Updates `lastCreatedAt` timestamp
  5. Auto-deactivates if `endDate` has passed

### Created Expense Properties:
```typescript
{
  businessId: from template,
  categoryId: from template,
  title: from template,
  description: from template,
  amount: from template,
  expenseDate: template.nextOccurrence,
  paymentMethod: from template,
  paymentStatus: 'pending',     // Always pending
  isPaid: false,                // Always false
  isRecurring: true,            // Flag as recurring
  recurringExpenseId: template.id,
  createdBy: null,              // System created
  tags: from template,
  note: from template
}
```

### Frequency Calculation:
- **Daily:** +1 day (with interval support)
- **Weekly:** +7 days (with interval support)
- **Monthly:** Same day next month(s) (handles month-end correctly)
- **Quarterly:** +3 months (with interval support)
- **Yearly:** +1 year (with interval support)

**Interval Examples:**
- `frequency: monthly, interval: 1` → Every month
- `frequency: monthly, interval: 2` → Every 2 months
- `frequency: weekly, interval: 2` → Every 2 weeks

---

## 📝 Common Use Cases

### Monthly Rent:
```json
{
  "title": "Office Rent",
  "amount": 15000000,
  "frequency": "monthly",
  "interval": 1,
  "startDate": "2025-01-01",
  "autoCreate": true
}
```

### Weekly Salaries:
```json
{
  "title": "Part-time Staff Salaries",
  "amount": 5000000,
  "frequency": "weekly",
  "interval": 1,
  "startDate": "2025-01-06",
  "autoCreate": true
}
```

### Quarterly Taxes:
```json
{
  "title": "VAT Payment",
  "amount": 25000000,
  "frequency": "quarterly",
  "interval": 1,
  "startDate": "2025-03-31",
  "autoCreate": true
}
```

### Bi-monthly Subscription:
```json
{
  "title": "Software License",
  "amount": 2000000,
  "frequency": "monthly",
  "interval": 2,
  "startDate": "2025-01-01",
  "endDate": "2025-12-31",
  "autoCreate": true
}
```

---

## 📝 Notes

### Business Rules:
1. **businessId** همیشه الزامی است
2. **Soft Delete**: هزینه‌ها با deletedAt حذف می‌شوند
3. **System Categories**: دسته‌های سیستمی قابل حذف نیستند
4. **File Upload**: حداکثر 10MB per file
5. **Attachments**: حداکثر 5 فایل per expense
6. **Recurring Expenses**: حذف الگو روی هزینه‌های قبلی تاثیری ندارد
7. **Auto-Create**: فقط برای recurring expenses با `isActive: true` و `autoCreate: true`

### Validation Rules:
- `title`: required, max 255 characters
- `amount`: required, min 0, max 999,999,999,999.99
- `expenseDate`: required, نمی‌تواند آینده باشد
- `categoryId`: باید exist کند
- `color`: باید فرمت #RRGGBB باشد
- `frequency`: باید یکی از مقادیر enum باشد
- `interval`: min 1, max 999
- `endDate`: باید بعد از startDate باشد

### Performance:
- Pagination: default 20 items per page
- Index on: businessId, categoryId, expenseDate, paymentStatus, nextOccurrence, isActive
- Lazy load attachments
- Cron job optimized for bulk operations

---

**Last Updated:** December 1, 2025  
**API Version:** 1.0  
**Status:** ✅ Phase 1 Complete | 🚀 Phase 2 (Recurring Expenses) Complete

