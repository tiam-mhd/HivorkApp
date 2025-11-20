# راهنمای Migration و استفاده از Business API

## 🚀 مراحل راه‌اندازی

### 1. Migration دیتابیس

دستورات SQL زیر را در PostgreSQL اجرا کنید:

```bash
cd d:\Tiam\Projects\Hivork
psql -U postgres -d hivork_db -f database\migrations\add-business-industry.sql
```

یا به صورت دستی:

```sql
-- Add business_industry enum
CREATE TYPE business_industry AS ENUM (
  'food', 'clothing', 'electronics', 'beauty', 'auto',
  'health', 'education', 'construction', 'technology',
  'finance', 'real_estate', 'entertainment', 'sports',
  'agriculture', 'other'
);

-- Add industry column
ALTER TABLE businesses 
ADD COLUMN industry business_industry;

-- Add 'online' to business_type
ALTER TYPE business_type ADD VALUE IF NOT EXISTS 'online';

-- Create index
CREATE INDEX idx_businesses_industry ON businesses(industry) 
WHERE industry IS NOT NULL;
```

### 2. راه‌اندازی Backend

```bash
cd d:\Tiam\Projects\Hivork\backend
npm run start:dev
```

بک‌اند باید روی `http://localhost:3000` بالا بیاد.

### 3. تست API با curl یا Postman

#### ایجاد کسب و کار:

```bash
curl -X POST http://localhost:3000/api/business \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "name": "فروشگاه تست",
    "type": "retail",
    "industry": "electronics",
    "description": "یک فروشگاه تستی",
    "phone": "02112345678"
  }'
```

#### دریافت لیست کسب و کارها:

```bash
curl -X GET http://localhost:3000/api/business/my-businesses \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 4. تست Flutter App

```bash
cd d:\Tiam\Projects\Hivork\mobile
flutter run -d chrome --web-port 57709
```

## 📁 ساختار فایل‌های جدید

```
mobile/lib/features/business/
├── data/
│   ├── models/
│   │   └── business_model.dart      # Models: Business, BusinessType, BusinessIndustry, CreateBusinessRequest
│   └── datasources/
│       └── business_api_service.dart # API calls: create, get, update, delete
└── presentation/
    └── pages/
        └── create_business_page.dart # صفحه ایجاد کسب و کار با 3 مرحله
```

## 🔄 تغییرات Backend

### فایل‌های تغییر یافته:

1. **`backend/src/modules/business/entities/business.entity.ts`**
   - اضافه شدن `BusinessIndustry` enum
   - اضافه شدن فیلد `industry`
   - اضافه شدن `ONLINE` به `BusinessType`

2. **`backend/src/modules/business/dto/create-business.dto.ts`**
   - اضافه شدن فیلد `industry` (اختیاری)

### نمونه Entity:

```typescript
export enum BusinessType {
  RETAIL = 'retail',
  WHOLESALE = 'wholesale',
  SERVICE = 'service',
  MANUFACTURING = 'manufacturing',
  RESTAURANT = 'restaurant',
  ONLINE = 'online',  // ✅ جدید
  OTHER = 'other',
}

export enum BusinessIndustry {  // ✅ جدید
  FOOD = 'food',
  CLOTHING = 'clothing',
  ELECTRONICS = 'electronics',
  // ... و سایر موارد
}

@Entity('businesses')
export class Business {
  // ...
  @Column({ type: 'enum', enum: BusinessType })
  type: BusinessType;

  @Column({ type: 'enum', enum: BusinessIndustry, nullable: true })
  industry?: BusinessIndustry;  // ✅ جدید
  // ...
}
```

## 📱 استفاده در Flutter

### مثال: ایجاد کسب و کار

```dart
import 'package:dio/dio.dart';
import '../data/models/business_model.dart';
import '../data/datasources/business_api_service.dart';

// در داخل widget یا state
final dio = Dio(BaseOptions(
  baseUrl: 'http://localhost:3000/api',
  headers: {
    'Authorization': 'Bearer $token',
  },
));

final apiService = BusinessApiService(dio);

final request = CreateBusinessRequest(
  name: 'فروشگاه من',
  type: BusinessType.retail,
  industry: BusinessIndustry.electronics,
  description: 'توضیحات',
  phone: '02112345678',
  address: 'تهران',
);

try {
  final business = await apiService.createBusiness(request);
  print('کسب و کار ایجاد شد: ${business.id}');
} catch (e) {
  print('خطا: $e');
}
```

### مثال: دریافت لیست کسب و کارها

```dart
try {
  final businesses = await apiService.getMyBusinesses();
  print('تعداد کسب و کارها: ${businesses.length}');
} catch (e) {
  print('خطا: $e');
}
```

## 🎨 UI Flow

صفحه ایجاد کسب و کار شامل 3 مرحله است:

### مرحله 1: انتخاب نوع کسب و کار
- نمایش 6 کارت با آیکون رنگی
- انواع: خرده‌فروشی، عمده‌فروشی، خدماتی، تولیدی، رستوران، آنلاین

### مرحله 2: اطلاعات پایه
- نام کسب و کار (اجباری)
- انتخاب صنعت با چیپ‌ها (8 صنعت رایج)
- آدرس، تلفن، توضیحات (اختیاری)

### مرحله 3: بررسی نهایی
- نمایش خلاصه اطلاعات وارد شده
- آیکون تأیید
- دکمه "ایجاد کسب و کار" با حالت loading

## 🔐 نکات امنیتی

1. **Authorization Header**: همیشه توکن JWT را به همراه درخواست‌ها ارسال کنید
2. **HTTPS در Production**: در محیط واقعی از HTTPS استفاده کنید
3. **Validation**: بک‌اند تمام ورودی‌ها را اعتبارسنجی می‌کند

## 🐛 عیب‌یابی

### خطای 401 Unauthorized
- مطمئن شوید توکن JWT معتبر است
- توکن را از Local Storage/Secure Storage بخوانید

### خطای 409 Conflict
- کسب و کار با این نام قبلاً ثبت شده
- نام دیگری انتخاب کنید

### خطای Connection
- مطمئن شوید بک‌اند روی `http://localhost:3000` در حال اجراست
- فایروال را بررسی کنید

## 📚 مستندات API کامل

فایل کامل API Contract در:
```
api-contracts/business-api.md
```

## ✅ Checklist

- [x] Migration دیتابیس اجرا شده
- [x] Backend Entity به‌روزرسانی شده
- [x] Backend DTO به‌روزرسانی شده
- [x] Flutter Models ایجاد شده
- [x] Flutter API Service ایجاد شده
- [x] UI صفحه ایجاد کسب و کار
- [x] API Contract مستندسازی شده
- [ ] Integration Test نوشته شود
- [ ] Authorization در Flutter پیاده‌سازی شود (نیاز به Bloc/Provider)

## 🔜 مراحل بعدی

1. **پیاده‌سازی Business Bloc در Flutter** برای مدیریت state
2. **اتصال به Auth State** برای دریافت خودکار توکن
3. **افزودن Caching** برای لیست کسب و کارها
4. **پیاده‌سازی Update Business**
5. **افزودن تصویر/لوگو Upload**

---

**نوشته شده در**: 17 نوامبر 2025
**نسخه**: 1.0.0
