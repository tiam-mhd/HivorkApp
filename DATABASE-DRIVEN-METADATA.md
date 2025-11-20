# راهنمای کامل تغییر به Database-Driven Metadata

## 🎯 تغییرات اعمال شده

### ❌ قبل (Enum-based):
```typescript
enum BusinessType {
  RETAIL = 'retail',
  WHOLESALE = 'wholesale',
  // ...
}
```

### ✅ بعد (Database-driven):
```typescript
@Entity('business_categories')
class BusinessCategory {
  id: UUID
  name: string          // 'خرده‌فروشی'
  nameEn: string        // 'Retail'
  slug: string          // 'retail'
  icon: string          // 'store'
  color: string         // '#2196F3'
  sortOrder: number
  isActive: boolean
}
```

---

## 📋 مراحل اجرا

### 1. Migration دیتابیس

```bash
cd d:\Tiam\Projects\Hivork
psql -U postgres -d hivork_db -f database\migrations\convert-business-type-to-tables.sql
```

این migration:
- جداول `business_categories` و `business_industries` میسازه
- Enum های قدیمی رو حذف میکنه  
- ستون‌های `categoryId` و `industryId` به businesses اضافه میکنه
- 7 دسته پیش‌فرض و 16 صنعت پیش‌فرض insert میکنه

### 2. بررسی داده‌های پیش‌فرض

```sql
-- بررسی Categories
SELECT id, name, "nameEn", slug, icon, color, "sortOrder"
FROM business_categories
WHERE "isActive" = true
ORDER BY "sortOrder";

-- بررسی Industries
SELECT id, name, "nameEn", slug, icon, "sortOrder"
FROM business_industries
WHERE "isActive" = true
ORDER BY "sortOrder";
```

دسته‌بندی‌های پیش‌فرض:
1. خرده‌فروشی (retail)
2. عمده‌فروشی (wholesale)
3. خدماتی (service)
4. تولیدی (manufacturing)
5. رستوران/کافه (restaurant)
6. آنلاین (online)
7. سایر (other)

صنایع پیش‌فرض:
1. مواد غذایی (food)
2. پوشاک (clothing)
3. الکترونیک (electronics)
4. آرایشی و بهداشتی (beauty)
5. خودرو (auto)
6. سلامت و درمان (health)
7. آموزشی (education)
8. ساختمانی (construction)
9. فناوری (technology)
10. مالی (finance)
11. املاک (real-estate)
12. سرگرمی (entertainment)
13. ورزشی (sports)
14. کشاورزی (agriculture)
15. حمل و نقل (transportation)
16. سایر (other)

### 3. راه‌اندازی Backend

```bash
cd d:\Tiam\Projects\Hivork\backend
npm run start:dev
```

### 4. تست API های جدید

#### دریافت دسته‌بندی‌ها (Public):
```bash
curl http://localhost:3000/api/business-metadata/categories
```

#### دریافت صنایع (Public):
```bash
curl http://localhost:3000/api/business-metadata/industries
```

#### ایجاد دسته‌بندی جدید (Admin فقط):
```bash
curl -X POST http://localhost:3000/api/business-metadata/categories \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{
    "name": "دسته تست",
    "nameEn": "Test Category",
    "slug": "test-category",
    "icon": "category",
    "color": "#FF5722",
    "sortOrder": 10,
    "isActive": true
  }'
```

#### ایجاد کسب و کار با category و industry جدید:
```bash
curl -X POST http://localhost:3000/api/business \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer USER_TOKEN" \
  -d '{
    "name": "فروشگاه تست",
    "categoryId": "uuid-of-retail-category",
    "industryId": "uuid-of-electronics-industry",
    "description": "توضیحات",
    "phone": "02112345678"
  }'
```

---

## 📁 فایل‌های تغییر یافته

### Backend:

#### ✅ جدید:
- `business-category.entity.ts` - Entity دسته‌بندی
- `business-industry.entity.ts` - Entity صنعت
- `business-category.dto.ts` - DTOهای دسته‌بندی
- `business-industry.dto.ts` - DTOهای صنعت
- `business-metadata.controller.ts` - Controller مدیریت metadata

#### 🔄 تغییر یافته:
- `business.entity.ts` - حذف enum، اضافه شدن relation
- `create-business.dto.ts` - استفاده از UUID به جای enum
- `business.module.ts` - اضافه شدن entity و controller جدید

### Database:
- `convert-business-type-to-tables.sql` - Migration کامل

### Flutter:

#### ✅ جدید:
- `business_metadata_model.dart` - Models برای Category و Industry
- `business_metadata_api_service.dart` - API service

#### 🔄 تغییر یافته:
- `business_model.dart` - استفاده از objects به جای enum
- `business_api_service.dart` - ارسال UUID به جای enum value
- `create_business_page.dart` - صفحه placeholder (نیاز به تکمیل)

---

## 🎨 مزایای رویکرد جدید

### 1. مدیریت از داشبورد ادمین
```typescript
// Admin می‌تونه دسته جدید اضافه کنه
POST /business-metadata/categories
{
  "name": "کافی شاپ",
  "nameEn": "Coffee Shop",
  "slug": "coffee-shop",
  "icon": "local_cafe",
  "color": "#795548"
}
```

### 2. چند زبانه
```typescript
{
  "name": "خرده‌فروشی",  // فارسی
  "nameEn": "Retail"      // انگلیسی
}
// بعداً می‌شه زبان‌های دیگه اضافه کرد
```

### 3. سفارشی‌سازی UI
```typescript
{
  "icon": "store",        // Material icon name
  "color": "#2196F3",     // رنگ کارت در UI
  "sortOrder": 1          // ترتیب نمایش
}
```

### 4. فعال/غیرفعال کردن
```typescript
{
  "isActive": false  // دسته رو غیرفعال کن بدون حذف
}
```

---

## 🔌 API Endpoints جدید

### Public (بدون Authentication):
- `GET /business-metadata/categories` - لیست دسته‌بندی‌های فعال
- `GET /business-metadata/industries` - لیست صنایع فعال

### Admin Only:
- `GET /business-metadata/categories/all` - همه دسته‌بندی‌ها
- `POST /business-metadata/categories` - ایجاد دسته‌بندی
- `PATCH /business-metadata/categories/:id` - ویرایش
- `DELETE /business-metadata/categories/:id` - حذف

- `GET /business-metadata/industries/all` - همه صنایع
- `POST /business-metadata/industries` - ایجاد صنعت
- `PATCH /business-metadata/industries/:id` - ویرایش
- `DELETE /business-metadata/industries/:id` - حذف

---

## 🔄 نحوه استفاده در Flutter

### 1. دریافت لیست Categories:
```dart
final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'));
final metadataService = BusinessMetadataApiService(dio);

final categories = await metadataService.getCategories();
// [
//   BusinessCategory(id: 'uuid', name: 'خرده‌فروشی', icon: 'store', ...),
//   BusinessCategory(id: 'uuid', name: 'عمده‌فروشی', icon: 'warehouse', ...),
// ]
```

### 2. نمایش در UI:
```dart
ListView.builder(
  itemCount: categories.length,
  itemBuilder: (context, index) {
    final category = categories[index];
    return ListTile(
      leading: Icon(
        _getIconData(category.icon), // 'store' -> Icons.store
        color: _parseColor(category.color), // '#2196F3' -> Color
      ),
      title: Text(category.name),
      subtitle: Text(category.nameEn),
    );
  },
)
```

### 3. ایجاد کسب و کار:
```dart
final request = CreateBusinessRequest(
  name: 'فروشگاه من',
  categoryId: selectedCategory.id,  // ✅ UUID از database
  industryId: selectedIndustry.id,  // ✅ UUID از database
  description: 'توضیحات',
);

await businessApiService.createBusiness(request);
```

---

## 📊 مقایسه داده‌ها

### قبل:
```json
{
  "name": "فروشگاه علی",
  "type": "retail",           // ❌ String ثابت
  "industry": "electronics"   // ❌ String ثابت
}
```

### بعد:
```json
{
  "name": "فروشگاه علی",
  "categoryId": "uuid-here",   // ✅ Foreign Key
  "industryId": "uuid-here",   // ✅ Foreign Key
  "category": {                // ✅ Relation
    "id": "...",
    "name": "خرده‌فروشی",
    "nameEn": "Retail",
    "icon": "store",
    "color": "#2196F3"
  }
}
```

---

## 🛠️ کارهای باقی مانده

### Backend:
- ✅ Entities ساخته شد
- ✅ DTOs ساخته شد
- ✅ Controller ساخته شد
- ✅ Module به‌روزرسانی شد
- ✅ Migration نوشته شد
- ⏳ Validation بیشتر (unique slug, etc.)
- ⏳ Seed data بیشتر

### Flutter:
- ✅ Models ساخته شد
- ✅ API Service ساخته شد
- ⏳ صفحه ایجاد کسب و کار باید تکمیل بشه:
  - دریافت Categories از API
  - دریافت Industries از API
  - UI برای انتخاب Category
  - UI برای انتخاب Industry
  - ارسال UUID به backend
- ⏳ صفحه ادمین برای مدیریت Categories/Industries

### Database:
- ✅ Migration اجرا شد
- ✅ Seed data اضافه شد
- ⏳ Backup قبل از production

---

## 💡 نکات مهم

1. **یکتا بودن Slug**: Slug باید unique باشه (برای URL-friendly)
2. **Soft Delete**: بهتره به جای حذف کامل، `isActive = false` بزاری
3. **Caching**: لیست Categories/Industries رو در Flutter cache کن
4. **Default Value**: همیشه یه "سایر" داشته باش
5. **Translation**: از همین الان برای چند زبانه آماده‌ایم

---

## 🎯 مثال استفاده در داشبورد ادمین

```typescript
// صفحه مدیریت دسته‌بندی‌ها
@Component({
  template: `
    <table>
      <tr *ngFor="let category of categories">
        <td>{{ category.name }}</td>
        <td>{{ category.nameEn }}</td>
        <td>
          <mat-icon [style.color]="category.color">
            {{ category.icon }}
          </mat-icon>
        </td>
        <td>
          <mat-slide-toggle [(ngModel)]="category.isActive"
                           (change)="toggleActive(category)">
          </mat-slide-toggle>
        </td>
        <td>
          <button (click)="edit(category)">ویرایش</button>
          <button (click)="delete(category)">حذف</button>
        </td>
      </tr>
    </table>
  `
})
```

---

**ساخته شده در**: 17 نوامبر 2025  
**نسخه**: 2.0.0  
**وضعیت**: Backend آماده | Flutter نیاز به تکمیل دارد
