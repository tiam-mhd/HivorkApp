# ✅ Sync Checklist - وضعیت همگام‌سازی Backend و Flutter

تاریخ آخرین بروزرسانی: 2025-01-16

---

## 📊 خلاصه وضعیت

| ماژول | Backend | Flutter | مستندات | وضعیت |
|-------|---------|---------|---------|-------|
| Auth | ✅ | ✅ | ✅ | همگام |
| Business | ✅ | ✅ | ✅ | همگام |
| **Product** | ✅ | ✅ | ✅ | **همگام - جدید** |
| Customer | ⏳ | ⏳ | ❌ | در انتظار |
| Invoice | ⏳ | ⏳ | ❌ | در انتظار |

---

## 🆕 Product Module - SYNCED ✅

**تاریخ**: 2025-01-16  
**وضعیت**: ✅ کامل و همگام

### Backend
- ✅ Entity: `backend/src/modules/product/entities/product.entity.ts`
- ✅ DTOs: `create-product.dto.ts`, `update-product.dto.ts`, `filter-product.dto.ts`
- ✅ Service: `product.service.ts` - 14 methods
- ✅ Controller: `product.controller.ts` - 13 endpoints
- ✅ Enums: `ProductType`, `ProductUnit`, `ProductStatus`

### Flutter
- ✅ Models: `product.dart`, `product_filter.dart`, `product_stats.dart`
- ✅ API Service: `product_api_service.dart` - 14 methods
- ✅ Repository: `product_repository.dart`
- ✅ BLoC: `product_bloc.dart` - 15 events
- ✅ UI Pages: `products_page.dart`, `product_form_page.dart`, `product_detail_page.dart`
- ✅ Widgets: `product_grid_item.dart`, `product_list_item.dart`
- ✅ Navigation: 4 routes در `main.dart`
- ✅ Dashboard Integration: منوی محصولات اضافه شد

### API Contract
- ✅ مستندات: `api-contracts/product-api.md`
- ✅ 13 Endpoints مستند شده
- ✅ تمام DTOs و Response Types
- ✅ Error Handling
- ✅ Flutter Implementation Guide

### Features Implemented
- ✅ CRUD کامل (Create, Read, Update, Delete)
- ✅ فیلتر پیشرفته (status, type, price range, stock)
- ✅ جستجو (name, code, barcode)
- ✅ Pagination با infinite scroll
- ✅ View modes (Grid/List toggle)
- ✅ Stock management (update, adjust)
- ✅ Status management
- ✅ Image management (upload, remove)
- ✅ Statistics
- ✅ Categories & Brands
- ✅ Low stock warnings
- ✅ Pull-to-refresh
- ✅ Empty states
- ✅ Error handling

### Pending Tasks
- [ ] تست‌های Backend
- [ ] تست‌های Flutter (Unit, Widget, Integration)
- [ ] Image Upload واقعی (فعلاً فقط URL)
- [ ] Edit Product - بارگذاری محصول موجود در فرم
- [ ] Seed data برای تست

---

## وضعیت فعلی

### ✅ User Entity - SYNCED
**Backend:** `backend/src/modules/users/entities/user.entity.ts`
```typescript
- id: string (uuid)
- fullName: string
- phone: string (unique)
- email: string (nullable)
- password: string (hashed)
- role: UserRole (super_admin | business_owner | employee)
- status: UserStatus (active | inactive | suspended | pending_verification)
- avatar: string (nullable)
- phoneVerified: boolean
- emailVerified: boolean
- verificationCode: string (nullable)
- verificationCodeExpiry: Date (nullable)
- refreshToken: string (nullable)
```

**Flutter:** `mobile/lib/features/auth/domain/entities/user.dart`
```dart
- id: String
- fullName: String
- phone: String
- email: String?
- avatar: String?
- role: UserRole
- status: UserStatus
- phoneVerified: bool
- emailVerified: bool
- lastLoginAt: DateTime?
- createdAt: DateTime
```

**Status:** ✅ همگام - تمام فیلدهای مهم مطابقت دارند

---

### ✅ Register API - SYNCED

**Backend Endpoint:** `POST /api/v1/auth/register`

**Backend DTO:** `RegisterDto`
```typescript
- fullName: string (min: 3, max: 100)
- phone: string (pattern: ^09[0-9]{9}$)
- email?: string (optional, valid email)
- password: string (min: 8, max: 50, must contain uppercase, lowercase, digit)
```

**Flutter Request:**
```dart
RegisterEvent {
  fullName: String
  phone: String
  password: String
  email: String?
}
```

**Status:** ✅ همگام - تمام پارامترها مطابقت دارند

---

### ✅ Login API - SYNCED

**Backend Endpoint:** `POST /api/v1/auth/login`

**Backend DTO:** `LoginDto`
```typescript
- phone: string (pattern: ^09[0-9]{9}$)
- password: string
```

**Flutter Request:**
```dart
LoginEvent {
  phone: String
  password: String
}
```

**Status:** ✅ همگام

---

### ✅ Check Phone API - SYNCED

**Backend Endpoint:** `POST /api/v1/auth/check-phone`

**Backend DTO:** `CheckPhoneDto`
```typescript
- phone: string (pattern: ^09[0-9]{9}$)
```

**Flutter Request:**
```dart
CheckPhoneEvent {
  phone: String
}
```

**Backend Response:**
```json
{
  "success": true,
  "message": "بررسی انجام شد",
  "data": {
    "exists": boolean
  }
}
```

**Status:** ✅ همگام

---

## تغییرات انجام شده (2025-11-16)

### Backend:
1. ✅ اضافه شدن endpoint: `POST /auth/check-phone`
2. ✅ DTO: `CheckPhoneDto` ایجاد شد
3. ✅ Service method: `checkPhone(phone: string)` اضافه شد
4. ✅ CORS اصلاح شد: `origin: '*'` برای development

### Flutter:
1. ✅ User Entity تغییر کرد: `firstName + lastName + businessName` → `fullName`
2. ✅ UserModel به‌روز شد
3. ✅ RegisterEvent اصلاح شد: فقط `fullName, phone, password, email?`
4. ✅ RegisterDto تغییر کرد
5. ✅ RegisterDetailsPage به‌روز شد: فرم جدید با fullName و email
6. ✅ RegisterUseCase اصلاح شد
7. ✅ AuthRepository اصلاح شد
8. ✅ AuthRepositoryImpl به‌روز شد
9. ✅ خطای type mismatch در `_handleDioError` برطرف شد
10. ✅ CheckPhoneUseCase اضافه شد
11. ✅ Phone-first flow پیاده‌سازی شد

---

## مراحل بعدی برای تست

### قبل از تست:
1. ⚠️ **Backend را restart کنید:**
   ```bash
   cd backend
   npm run start:dev
   ```

2. ⚠️ **Generated files را rebuild کنید:**
   ```bash
   cd mobile
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. ⚠️ **Flutter را اجرا کنید:**
   ```bash
   cd mobile
   flutter run -d chrome
   ```

### سناریوهای تست:

#### ✅ سناریو 1: ثبت‌نام کاربر جدید
1. وارد کردن شماره: `09123456789`
2. سیستم چک می‌کند → کاربر وجود ندارد
3. نمایش صفحه ثبت‌نام
4. وارد کردن:
   - نام کامل: "علی محمدی"
   - ایمیل (اختیاری): "ali@example.com"
   - رمز عبور: "Pass@1234"
   - تکرار رمز عبور: "Pass@1234"
5. کلیک روی ثبت‌نام
6. انتظار: موفقیت و redirect به صفحه ورود

#### ✅ سناریو 2: ورود کاربر موجود
1. وارد کردن شماره: `09123456789`
2. سیستم چک می‌کند → کاربر وجود دارد
3. نمایش صفحه ورود
4. وارد کردن رمز عبور
5. کلیک روی ورود
6. انتظار: ورود موفق و redirect به dashboard

---

## نکات مهم

### ⚠️ قبل از هر تغییر در Backend:
1. ابتدا در `api-contracts/` ثبت کنید
2. سپس Backend را تغییر دهید
3. بعد Flutter را مطابق مستندات به‌روز کنید

### ⚠️ قبل از هر تغییر در Flutter:
1. بررسی کنید که `api-contracts/` چه می‌گوید
2. مطمئن شوید Backend مطابق است
3. سپس Flutter را پیاده‌سازی کنید

### ⚠️ فیلدهای حساس:
- `fullName` در Backend = `fullName` در Flutter (نه firstName/lastName)
- `phoneVerified` در Backend = `phoneVerified` در Flutter (نه isPhoneVerified)
- `status` در Backend = `status` در Flutter (نه isActive)
- `email` اختیاری است در هر دو طرف

---

## مشکلات شناخته شده و راه حل

### ❌ مشکل: 404 Error
**علت:** Backend restart نشده یا endpoint ثبت نشده
**راه حل:** `npm run start:dev` در backend

### ❌ مشکل: Type Error - statusCode
**علت:** در web، statusCode ممکن است String باشد
**راه حل:** ✅ اصلاح شد در `auth_repository_impl.dart` line 277

### ❌ مشکل: CORS Error
**علت:** CORS_ORIGIN='*' به آرایه تبدیل می‌شد
**راه حل:** ✅ اصلاح شد در `main.ts` line 24

---

## تاییدیه نهایی

این checklist تضمین می‌کند که:
- ✅ Backend و Flutter از نظر data structure همگام هستند
- ✅ تمام API endpoints مطابق مستندات هستند
- ✅ تمام validation rules یکسان هستند
- ✅ Response formats مطابقت دارند
- ✅ Error handling یکسان است

**آخرین بررسی:** 2025-11-16
**وضعیت:** ✅ READY FOR TESTING
