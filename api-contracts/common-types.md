# Common Types - تایپ‌های مشترک

## Base URL
```
http://localhost:3000/api/v1
```

**توجه:** تمام endpointها بدون `/v1` اضافی هستند.  
مثال: `POST /api/v1/auth/check-phone` (نه `/api/v1/v1/auth/check-phone`)

## Response Wrapper
تمام پاسخ‌های موفق در این ساختار هستند:

```typescript
{
  "success": boolean,
  "message": string,
  "data": T | null,
  "timestamp": string (ISO 8601)
}
```

### مثال پاسخ موفق:
```json
{
  "success": true,
  "message": "عملیات با موفقیت انجام شد",
  "data": { ... },
  "timestamp": "2025-11-16T12:00:00.000Z"
}
```

## Error Response
تمام خطاها در این ساختار هستند:

```typescript
{
  "message": string | string[],
  "error": string,
  "statusCode": number
}
```

### مثال پاسخ خطا:
```json
{
  "message": "شماره موبایل نامعتبر است",
  "error": "Bad Request",
  "statusCode": 400
}
```

## Common Status Codes
- `200` - OK
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `422` - Unprocessable Entity
- `429` - Too Many Requests
- `500` - Internal Server Error

## Headers
### Request Headers:
```
Content-Type: application/json
Authorization: Bearer {access_token}  // برای endpointهای محافظت شده
```

### Response Headers:
```
Content-Type: application/json
```

## Phone Format
```
شماره موبایل باید با فرمت ایرانی باشد: 09xxxxxxxxx
طول: 11 کاراکتر
شروع با: 09
```

## Date/Time Format
تمام تاریخ‌ها به فرمت ISO 8601:
```
2025-11-16T12:00:00.000Z
```

## Pagination (برای لیست‌ها)
```typescript
{
  "items": T[],
  "total": number,
  "page": number,
  "limit": number,
  "totalPages": number
}
```

## User Entity (مدل کاربر)
```typescript
{
  "id": string (uuid),
  "fullName": string,
  "phone": string,
  "email": string | null,
  "status": "active" | "inactive" | "suspended" | "pendingVerification",
  "avatar": string | null,
  "phoneVerified": boolean,
  "emailVerified": boolean,
  "createdAt": string (ISO 8601),
  "updatedAt": string (ISO 8601)
}
```

**توجه:** 
- فیلد `role` دیگر در User وجود ندارد
- نقش‌ها از طریق `UserBusiness` مدیریت می‌شوند
- فرمت status به camelCase تغییر کرد (`pendingVerification` به جای `pending_verification`)

---

## Expense Enums

### PaymentMethod (روش پرداخت)
```typescript
enum PaymentMethod {
  CASH = 'cash',                    // نقد
  CARD = 'card',                    // کارت
  BANK_TRANSFER = 'bank_transfer',  // انتقال بانکی
  CHECK = 'check',                  // چک
  CREDIT = 'credit',                // اعتبار
  OTHER = 'other'                   // سایر
}
```

**Persian Labels:**
```dart
static const persianLabels = {
  'cash': 'نقد',
  'card': 'کارت',
  'bank_transfer': 'انتقال بانکی',
  'check': 'چک',
  'credit': 'اعتبار',
  'other': 'سایر',
};
```

### PaymentStatus (وضعیت پرداخت)
```typescript
enum PaymentStatus {
  PENDING = 'pending',              // در انتظار پرداخت
  PAID = 'paid',                    // پرداخت شده
  PARTIALLY_PAID = 'partially_paid', // پرداخت جزئی
  CANCELLED = 'cancelled'           // لغو شده
}
```

**Persian Labels:**
```dart
static const persianLabels = {
  'pending': 'در انتظار',
  'paid': 'پرداخت شده',
  'partially_paid': 'پرداخت جزئی',
  'cancelled': 'لغو شده',
};
```

### ReferenceType (نوع ارجاع)
```typescript
enum ReferenceType {
  PRODUCT_PURCHASE = 'product_purchase',   // خرید محصول
  SALARY = 'salary',                       // حقوق
  SUPPLIER_PAYMENT = 'supplier_payment',   // پرداخت به تامین‌کننده
  RENT = 'rent',                           // اجاره
  UTILITY = 'utility',                     // آب و برق و گاز
  OTHER = 'other'                          // سایر
}
```

**Persian Labels:**
```dart
static const persianLabels = {
  'product_purchase': 'خرید محصول',
  'salary': 'حقوق',
  'supplier_payment': 'پرداخت به تامین‌کننده',
  'rent': 'اجاره',
  'utility': 'آب و برق و گاز',
  'other': 'سایر',
};
```

### RecurringFrequency (تناوب تکرار - Phase 2)
```typescript
enum RecurringFrequency {
  DAILY = 'daily',          // روزانه
  WEEKLY = 'weekly',        // هفتگی
  MONTHLY = 'monthly',      // ماهانه
  QUARTERLY = 'quarterly',  // سه‌ماهه
  YEARLY = 'yearly'         // سالانه
}
```

**Persian Labels:**
```dart
static const persianLabels = {
  'daily': 'روزانه',
  'weekly': 'هفتگی',
  'monthly': 'ماهانه',
  'quarterly': 'سه‌ماهه',
  'yearly': 'سالانه',
};
```

---

## Expense Category Model
```typescript
{
  id: string;              // UUID
  businessId: string;      // UUID
  parentId?: string;       // UUID - دسته والد
  name: string;            // نام دسته
  description?: string;    // توضیحات
  color?: string;          // رنگ (#RRGGBB)
  icon?: string;           // نام آیکون Material
  isActive: boolean;       // فعال/غیرفعال
  isSystem: boolean;       // سیستمی (قابل حذف نیست)
  sortOrder: number;       // ترتیب نمایش
  budgetAmount?: number;   // بودجه ماهانه
  createdAt: string;       // ISO date
  updatedAt: string;       // ISO date
}
```

---

## Expense Model
```typescript
{
  id: string;
  businessId: string;
  categoryId?: string;
  category?: ExpenseCategory;
  
  title: string;
  description?: string;
  
  amount: number;
  
  expenseDate: string;           // ISO date
  
  paymentMethod: PaymentMethod;
  paymentStatus: PaymentStatus;
  
  referenceType?: ReferenceType;
  referenceId?: string;
  
  attachments?: {
    url: string;
    filename: string;
    mimeType: string;
    size: number;
  }[];
  
  isPaid: boolean;
  
  tags?: string[];
  note?: string;
  
  isRecurring: boolean;
  recurringExpenseId?: string;   // لینک به الگوی تکرار (Phase 2)
  recurringRule?: {
    frequency: 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'yearly';
    interval: number;
    endDate?: string;
  };
  
  createdBy: string;
  approvedBy?: string;
  approvedAt?: string;
  
  createdAt: string;
  updatedAt: string;
  deletedAt?: string;
}
```

---

## Recurring Expense Model (Phase 2)
```typescript
{
  id: string;                    // UUID
  businessId: string;            // UUID
  categoryId?: string;           // UUID
  category?: ExpenseCategory;    // Relation
  
  title: string;                 // ��� ����� ʘ����
  description?: string;          // �������
  
  amount: number;                // ���� (decimal 15,2)
  
  frequency: RecurringFrequency; // �����
  interval: number;              // ����� (��ԝ���: 1)
  
  startDate: string;             // ����� ���� (ISO date)
  endDate?: string;              // ����� ����� (�������)
  nextOccurrence: string;        // ����� ����� ���� (ISO date)
  
  paymentMethod: PaymentMethod;  // ��� ������
  
  isActive: boolean;             // ����/�������
  autoCreate: boolean;           // ����� ��Ϙ��
  lastCreatedAt?: string;        // ����� ����� ����� ���
  
  tags?: string;                 // �э�ȝ��
  note?: string;                 // �������
  
  generatedExpenses?: Expense[]; // �������� ����� ��� (relation)
  
  createdAt: string;             // ISO date
  updatedAt: string;             // ISO date
}
```

**Use Cases:**
- ����� ������ ����
- ���� ��ј��� (��ʐ�/������)
- ������ ������ (����)
- ���� ������
- ����ǘ���� ������ (�������ѡ ������ʡ etc.)
