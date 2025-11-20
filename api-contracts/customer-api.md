# Customer API - API مدیریت مشتریان

## Base URL
```
/api/customers
/api/customer-groups
```

---

## Customers Endpoints

### 1. ایجاد مشتری جدید
```http
POST /api/customers
```

**Headers:**
```json
{
  "Authorization": "Bearer {token}",
  "Content-Type": "application/json"
}
```

**Request Body:**
```typescript
{
  customerCode: string;          // کد یکتای مشتری (الزامی)
  type: 'individual' | 'company'; // نوع مشتری (پیش‌فرض: individual)
  fullName: string;              // نام کامل (الزامی)
  phone?: string;                // شماره تماس
  email?: string;                // ایمیل
  nationalId?: string;           // کد ملی
  
  // اطلاعات شرکت (اگر type = company)
  companyName?: string;
  registrationNumber?: string;
  economicCode?: string;
  contactPerson?: string;
  
  // آدرس
  address?: string;
  city?: string;
  province?: string;
  postalCode?: string;
  country?: string;
  
  // گروه‌بندی
  groupId?: string | null;       // null = عمومی
  category?: string;
  source?: string;
  
  // اطلاعات مالی
  creditLimit?: number;          // پیش‌فرض: 0
  paymentTermDays?: number;      // پیش‌فرض: 0
  discountRate?: number;         // پیش‌فرض: 0
  
  // سایر
  birthDate?: string;            // ISO date
  avatar?: string;
  notes?: string;
  tags?: string[];
  customFields?: Record<string, any>;
  businessId: string;            // (الزامی)
}
```

**Response:**
```typescript
{
  id: string;
  customerCode: string;
  type: 'individual' | 'company';
  fullName: string;
  phone?: string;
  email?: string;
  nationalId?: string;
  companyName?: string;
  registrationNumber?: string;
  economicCode?: string;
  contactPerson?: string;
  address?: string;
  city?: string;
  province?: string;
  postalCode?: string;
  country?: string;
  groupId?: string;
  groupName?: string;           // از join با CustomerGroup
  groupColor?: string;
  groupIcon?: string;
  category?: string;
  source?: string;
  creditLimit: number;
  currentBalance: number;
  paymentTermDays: number;
  discountRate: number;
  totalOrders: number;
  totalPurchases: number;
  totalPayments: number;
  lastOrderDate?: string;
  lastPaymentDate?: string;
  birthDate?: string;
  avatar?: string;
  notes?: string;
  tags?: string[];
  customFields?: Record<string, any>;
  status: 'active' | 'inactive' | 'blocked';
  businessId: string;
  createdAt: string;
  updatedAt: string;
}
```

**Errors:**
- `409 Conflict` - کد مشتری یا شماره تماس تکراری است
- `400 Bad Request` - داده‌های نامعتبر

---

### 2. دریافت لیست مشتریان با فیلتر
```http
GET /api/customers?businessId={businessId}&...filters
```

**Query Parameters:**
```typescript
{
  businessId: string;          // (الزامی)
  page?: number;               // پیش‌فرض: 1
  limit?: number;              // پیش‌فرض: 20
  search?: string;             // جستجو در نام، کد، تلفن، ایمیل، نام شرکت
  type?: 'individual' | 'company';
  status?: 'active' | 'inactive' | 'blocked';
  groupId?: string | 'null';   // 'null' برای مشتریان بدون گروه (عمومی)
  category?: string;
  source?: string;
  city?: string;
  province?: string;
  tag?: string;
  minPurchases?: number;
  maxPurchases?: number;
  hasDebt?: boolean;
  hasCredit?: boolean;
}
```

**Response:**
```typescript
{
  data: Customer[];            // آرایه مشتریان
  total: number;
  page: number;
  limit: number;
}
```

---

### 3. دریافت جزئیات مشتری
```http
GET /api/customers/{id}
```

**Response:**
```typescript
Customer  // همان ساختار بالا
```

**Errors:**
- `404 Not Found` - مشتری یافت نشد

---

### 4. بروزرسانی مشتری
```http
PATCH /api/customers/{id}
```

**Request Body:**
همان فیلدهای create به جز customerCode و businessId

**Response:**
```typescript
Customer
```

**Errors:**
- `404 Not Found` - مشتری یافت نشد
- `409 Conflict` - شماره تماس یا ایمیل تکراری

---

### 5. حذف مشتری
```http
DELETE /api/customers/{id}
```

**Response:**
```
204 No Content
```

**Errors:**
- `404 Not Found` - مشتری یافت نشد
- `409 Conflict` - امکان حذف مشتری با حساب باز وجود ندارد

---

### 6. بروزرسانی وضعیت مشتری
```http
PATCH /api/customers/{id}/status
```

**Request Body:**
```typescript
{
  status: 'active' | 'inactive' | 'blocked';
}
```

**Response:**
```typescript
Customer
```

---

### 7. دریافت آمار مشتریان
```http
GET /api/customers/stats?businessId={businessId}
```

**Response:**
```typescript
{
  total: number;
  active: number;
  inactive: number;
  blocked: number;
  withDebt: number;
  withCredit: number;
  totalDebt: number;
  totalCredit: number;
  totalSales: number;
}
```

---

### 8. دریافت دسته‌بندی‌ها
```http
GET /api/customers/categories?businessId={businessId}
```

**Response:**
```typescript
string[]  // لیست نام دسته‌بندی‌های استفاده شده
```

---

### 9. دریافت منابع
```http
GET /api/customers/sources?businessId={businessId}
```

**Response:**
```typescript
string[]  // لیست منابع استفاده شده
```

---

### 10. دریافت تگ‌ها
```http
GET /api/customers/tags?businessId={businessId}
```

**Response:**
```typescript
string[]  // لیست تگ‌های استفاده شده
```

---

## Customer Groups Endpoints

### 1. ایجاد گروه مشتریان
```http
POST /api/customer-groups
```

**Request Body:**
```typescript
{
  name: string;                // (الزامی)
  description?: string;
  color?: string;              // رنگ hex مثل "#3B82F6"
  icon?: string;
  discountRate?: number;       // پیش‌فرض: 0
  paymentTermDays?: number;    // پیش‌فرض: 0
  creditLimit?: number;        // پیش‌فرض: 0
  sortOrder?: number;          // پیش‌فرض: 0
  isActive?: boolean;          // پیش‌فرض: true
  businessId: string;          // (الزامی)
}
```

**Response:**
```typescript
{
  success: true;
  message: string;
  data: {
    id: string;
    name: string;
    description?: string;
    color?: string;
    icon?: string;
    discountRate: number;
    paymentTermDays: number;
    creditLimit: number;
    sortOrder: number;
    isActive: boolean;
    businessId: string;
    createdAt: string;
    updatedAt: string;
  }
}
```

**Errors:**
- `409 Conflict` - نام گروه تکراری است

---

### 2. دریافت لیست گروه‌ها
```http
GET /api/customer-groups?businessId={businessId}
```

**Response:**
```typescript
{
  success: true;
  data: [
    {
      id: string;
      name: string;
      description?: string;
      color?: string;
      icon?: string;
      discountRate: number;
      paymentTermDays: number;
      creditLimit: number;
      sortOrder: number;
      isActive: boolean;
      customerCount: number;     // تعداد مشتریان در این گروه
      businessId: string;
      createdAt: string;
      updatedAt: string;
    }
  ]
}
```

---

### 3. دریافت جزئیات گروه
```http
GET /api/customer-groups/{id}?businessId={businessId}
```

**Response:**
```typescript
{
  success: true;
  data: CustomerGroup  // با customers relation
}
```

---

### 4. بروزرسانی گروه
```http
PATCH /api/customer-groups/{id}?businessId={businessId}
```

**Request Body:**
```typescript
{
  name?: string;
  description?: string;
  color?: string;
  icon?: string;
  discountRate?: number;
  paymentTermDays?: number;
  creditLimit?: number;
  sortOrder?: number;
  isActive?: boolean;
}
```

**Response:**
```typescript
{
  success: true;
  message: string;
  data: CustomerGroup;
}
```

---

### 5. حذف گروه (مشتریان به عمومی منتقل می‌شوند)
```http
DELETE /api/customer-groups/{id}?businessId={businessId}
```

**Response:**
```typescript
{
  success: true;
  message: "Customer group deleted successfully. All customers moved to general group.";
}
```

**توجه:** همه مشتریان این گروه به گروه عمومی (groupId = null) منتقل می‌شوند.

---

### 6. دریافت آمار گروه‌ها
```http
GET /api/customer-groups/stats?businessId={businessId}
```

**Response:**
```typescript
{
  success: true;
  data: {
    groups: [
      {
        groupId: string;
        groupName: string;
        customerCount: number;
        totalRevenue: number;
        totalBalance: number;
      }
    ],
    ungrouped: {
      groupId: null;
      groupName: "عمومی";
      customerCount: number;
      totalRevenue: number;
      totalBalance: number;
    }
  }
}
```

---

## Error Handling

همه خطاها با فرمت زیر برگردانده می‌شوند:

```typescript
{
  statusCode: number;
  message: string;
  error?: string;
}
```

### کدهای خطا رایج:
- `400` - Bad Request - داده‌های ورودی نامعتبر
- `401` - Unauthorized - نیاز به احراز هویت
- `404` - Not Found - رکورد یافت نشد
- `409` - Conflict - تکراری بودن داده
- `500` - Internal Server Error - خطای سرور

---

## نکات مهم Flutter:

### 1. گروه‌بندی عمومی:
```dart
// برای فیلتر کردن مشتریان بدون گروه:
filter.groupId = 'null';  // String 'null'

// برای ذخیره مشتری بدون گروه:
customer.groupId = null;  // Dart null
```

### 2. تبدیل Enum:
```dart
// Backend: 'individual', 'company'
enum CustomerType { individual, company }

// تبدیل:
type.toString().split('.').last  // 'individual'
```

### 3. Decimal to Double:
```dart
// Backend با StringToDoubleConverter برمی‌گردد
@StringToDoubleConverter()
final double creditLimit;
```

### 4. حذف گروه:
وقتی گروهی حذف می‌شود، مشتریان آن خودکار به گروه "عمومی" منتقل می‌شوند. نیازی به بروزرسانی دستی نیست.

---

## مثال‌های استفاده:

### ایجاد مشتری:
```dart
final response = await dio.post('/customers', data: {
  'customerCode': 'CUST-001',
  'fullName': 'علی محمدی',
  'phone': '09123456789',
  'groupId': groupId,  // یا null برای عمومی
  'businessId': businessId,
});
```

### جستجو:
```dart
final response = await dio.get('/customers', queryParameters: {
  'businessId': businessId,
  'search': 'علی',
  'groupId': 'null',  // فقط مشتریان عمومی
  'hasDebt': true,
  'page': 1,
  'limit': 20,
});
```

### مدیریت گروه:
```dart
// ایجاد گروه
await dio.post('/customer-groups', data: {
  'name': 'VIP',
  'color': '#3B82F6',
  'discountRate': 10,
  'businessId': businessId,
});

// حذف گروه (مشتریان به عمومی منتقل می‌شوند)
await dio.delete('/customer-groups/$groupId', queryParameters: {
  'businessId': businessId,
});
```

---

✅ **به روز شده:** 19 نوامبر 2025  
📝 **نسخه:** 1.0.0
