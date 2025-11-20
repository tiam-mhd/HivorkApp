# Product API Contract - قرارداد API محصولات

> 📋 **منبع حقیقت واحد** برای تمام APIهای مربوط به محصولات

## Base URL
```
/api/products
```

## Authentication
همه endpoint‌ها نیاز به `Bearer Token` دارند.
```
Authorization: Bearer {access_token}
```

---

## 📑 فهرست Endpoints

1. [Create Product](#1-create-product) - ایجاد محصول جدید
2. [Get All Products](#2-get-all-products) - دریافت لیست محصولات
3. [Get Product by ID](#3-get-product-by-id) - دریافت اطلاعات یک محصول
4. [Update Product](#4-update-product) - به‌روزرسانی محصول
5. [Delete Product](#5-delete-product) - حذف محصول
6. [Update Stock](#6-update-stock) - به‌روزرسانی موجودی
7. [Adjust Stock](#7-adjust-stock) - تنظیم موجودی (اضافه/کسر)
8. [Update Status](#8-update-status) - تغییر وضعیت محصول
9. [Get Product Stats](#9-get-product-stats) - دریافت آمار محصولات
10. [Get Categories](#10-get-categories) - دریافت لیست دسته‌بندی‌ها
11. [Get Brands](#11-get-brands) - دریافت لیست برندها
12. [Upload Image](#12-upload-image) - آپلود تصویر محصول
13. [Remove Image](#13-remove-image) - حذف تصویر محصول

---

## 🔷 Enums و Types مشترک

### ProductType
```typescript
enum ProductType {
  GOODS = 'goods',      // کالا
  SERVICE = 'service'   // خدمات
}
```

### ProductUnit
```typescript
enum ProductUnit {
  PIECE = 'piece',               // عدد
  KILOGRAM = 'kilogram',         // کیلوگرم
  GRAM = 'gram',                 // گرم
  LITER = 'liter',               // لیتر
  METER = 'meter',               // متر
  SQUARE_METER = 'square_meter', // متر مربع
  CUBIC_METER = 'cubic_meter',   // متر مکعب
  BOX = 'box',                   // جعبه
  CARTON = 'carton',             // کارتن
  PACK = 'pack',                 // بسته
  HOUR = 'hour',                 // ساعت
  DAY = 'day',                   // روز
  MONTH = 'month'                // ماه
}
```

### ProductStatus
```typescript
enum ProductStatus {
  ACTIVE = 'active',           // فعال
  INACTIVE = 'inactive',       // غیرفعال
  OUT_OF_STOCK = 'out_of_stock' // ناموجود
}
```

### Product Entity (مدل کامل)
```typescript
interface Product {
  id: string;                    // UUID
  code: string;                  // کد محصول (یونیک)
  name: string;                  // نام فارسی
  nameEn?: string;               // نام انگلیسی
  description?: string;          // توضیحات
  type: ProductType;             // نوع محصول
  unit: ProductUnit;             // واحد
  barcode?: string;              // بارکد
  category?: string;             // دسته‌بندی
  brand?: string;                // برند
  
  // قیمت‌گذاری
  purchasePrice: number;         // قیمت خرید
  salePrice: number;             // قیمت فروش
  wholesalePrice?: number;       // قیمت عمده
  taxRate: number;               // نرخ مالیات (درصد)
  discountRate: number;          // درصد تخفیف
  
  // موجودی
  currentStock: number;          // موجودی فعلی
  minStock: number;              // حداقل موجودی
  maxStock?: number;             // حداکثر موجودی
  reorderPoint?: number;         // نقطه سفارش مجدد
  trackInventory: boolean;       // پیگیری موجودی
  
  // تصاویر
  mainImage?: string;            // تصویر اصلی (URL)
  images?: string[];             // لیست تصاویر
  
  // اطلاعات اضافی
  supplier?: string;             // تامین‌کننده
  sku?: string;                  // SKU
  weight?: number;               // وزن
  dimensions?: {                 // ابعاد
    length?: number;
    width?: number;
    height?: number;
    unit?: string;
  };
  customFields?: Record<string, any>; // فیلدهای سفارشی
  
  status: ProductStatus;         // وضعیت
  notes?: string;                // یادداشت‌ها
  
  // روابط
  businessId: string;            // شناسه کسب‌وکار
  business?: Business;           // کسب‌وکار
  
  // تاریخ‌ها
  createdAt: Date;
  updatedAt: Date;
}
```

---

## 1️⃣ Create Product

### Request
```http
POST /api/products
Content-Type: application/json
Authorization: Bearer {token}

{
  "code": "PRD-001",
  "name": "لپ‌تاپ ایسوس",
  "nameEn": "ASUS Laptop",
  "description": "لپ‌تاپ 15 اینچی ایسوس",
  "type": "goods",
  "unit": "piece",
  "barcode": "1234567890123",
  "category": "Electronics",
  "brand": "ASUS",
  "purchasePrice": 15000000,
  "salePrice": 18000000,
  "wholesalePrice": 17000000,
  "taxRate": 9,
  "discountRate": 0,
  "currentStock": 50,
  "minStock": 10,
  "maxStock": 200,
  "reorderPoint": 15,
  "trackInventory": true,
  "mainImage": "https://example.com/image.jpg",
  "images": ["https://example.com/image1.jpg", "https://example.com/image2.jpg"],
  "supplier": "Tech Supplier Co.",
  "sku": "ASUS-LP-001",
  "weight": 2.5,
  "dimensions": {
    "length": 35,
    "width": 25,
    "height": 2,
    "unit": "cm"
  },
  "notes": "محصول پرفروش",
  "businessId": "uuid-business-id"
}
```

### Response (201 Created)
```json
{
  "id": "uuid-product-id",
  "code": "PRD-001",
  "name": "لپ‌تاپ ایسوس",
  "nameEn": "ASUS Laptop",
  "description": "لپ‌تاپ 15 اینچی ایسوس",
  "type": "goods",
  "unit": "piece",
  "barcode": "1234567890123",
  "category": "Electronics",
  "brand": "ASUS",
  "purchasePrice": 15000000,
  "salePrice": 18000000,
  "wholesalePrice": 17000000,
  "taxRate": 9,
  "discountRate": 0,
  "currentStock": 50,
  "minStock": 10,
  "maxStock": 200,
  "reorderPoint": 15,
  "trackInventory": true,
  "mainImage": "https://example.com/image.jpg",
  "images": ["https://example.com/image1.jpg", "https://example.com/image2.jpg"],
  "supplier": "Tech Supplier Co.",
  "sku": "ASUS-LP-001",
  "weight": 2.5,
  "dimensions": {
    "length": 35,
    "width": 25,
    "height": 2,
    "unit": "cm"
  },
  "status": "active",
  "notes": "محصول پرفروش",
  "businessId": "uuid-business-id",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z"
}
```

### Errors
- `409 Conflict` - کد محصول تکراری است
- `400 Bad Request` - اطلاعات ورودی نامعتبر
- `401 Unauthorized` - توکن نامعتبر

---

## 2️⃣ Get All Products

### Request
```http
GET /api/products?businessId={businessId}&page=1&limit=20&search=لپتاپ&status=active&type=goods&minPrice=10000000&maxPrice=20000000&lowStock=true
Authorization: Bearer {token}
```

### Query Parameters
| پارامتر | نوع | الزامی | توضیحات | پیش‌فرض |
|---------|-----|--------|---------|---------|
| businessId | string | ✅ بله | شناسه کسب‌وکار | - |
| page | number | خیر | شماره صفحه | 1 |
| limit | number | خیر | تعداد در صفحه | 10 |
| search | string | خیر | جستجو در نام، کد، بارکد | - |
| status | string | خیر | فیلتر وضعیت | - |
| type | string | خیر | فیلتر نوع | - |
| category | string | خیر | فیلتر دسته‌بندی | - |
| brand | string | خیر | فیلتر برند | - |
| minPrice | number | خیر | حداقل قیمت | - |
| maxPrice | number | خیر | حداکثر قیمت | - |
| lowStock | boolean | خیر | محصولات کم موجودی | false |
| outOfStock | boolean | خیر | محصولات ناموجود | false |

### Response (200 OK)
```json
{
  "items": [
    {
      "id": "uuid-1",
      "code": "PRD-001",
      "name": "لپ‌تاپ ایسوس",
      "nameEn": "ASUS Laptop",
      "description": "لپ‌تاپ 15 اینچی",
      "type": "goods",
      "unit": "piece",
      "category": "Electronics",
      "brand": "ASUS",
      "purchasePrice": 15000000,
      "salePrice": 18000000,
      "currentStock": 50,
      "minStock": 10,
      "status": "active",
      "mainImage": "https://example.com/image.jpg",
      "createdAt": "2024-01-15T10:30:00.000Z",
      "updatedAt": "2024-01-15T10:30:00.000Z"
    }
  ],
  "total": 45,
  "page": 1,
  "limit": 20,
  "totalPages": 3
}
```

---

## 3️⃣ Get Product by ID

### Request
```http
GET /api/products/{id}
Authorization: Bearer {token}
```

### Response (200 OK)
```json
{
  "id": "uuid-product-id",
  "code": "PRD-001",
  "name": "لپ‌تاپ ایسوس",
  "nameEn": "ASUS Laptop",
  "description": "لپ‌تاپ 15 اینچی ایسوس",
  "type": "goods",
  "unit": "piece",
  "barcode": "1234567890123",
  "category": "Electronics",
  "brand": "ASUS",
  "purchasePrice": 15000000,
  "salePrice": 18000000,
  "wholesalePrice": 17000000,
  "taxRate": 9,
  "discountRate": 0,
  "currentStock": 50,
  "minStock": 10,
  "maxStock": 200,
  "reorderPoint": 15,
  "trackInventory": true,
  "mainImage": "https://example.com/image.jpg",
  "images": ["https://example.com/image1.jpg", "https://example.com/image2.jpg"],
  "supplier": "Tech Supplier Co.",
  "sku": "ASUS-LP-001",
  "weight": 2.5,
  "dimensions": {
    "length": 35,
    "width": 25,
    "height": 2,
    "unit": "cm"
  },
  "status": "active",
  "notes": "محصول پرفروش",
  "businessId": "uuid-business-id",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z"
}
```

### Errors
- `404 Not Found` - محصول یافت نشد
- `401 Unauthorized` - عدم دسترسی

---

## 4️⃣ Update Product

### Request
```http
PATCH /api/products/{id}
Content-Type: application/json
Authorization: Bearer {token}

{
  "name": "لپ‌تاپ ایسوس مدل جدید",
  "salePrice": 19000000,
  "currentStock": 45,
  "notes": "قیمت به‌روز شد"
}
```

> ⚠️ **نکته**: تمام فیلدها اختیاری هستند. فقط فیلدهای ارسال شده به‌روز می‌شوند.

### Response (200 OK)
```json
{
  "id": "uuid-product-id",
  "code": "PRD-001",
  "name": "لپ‌تاپ ایسوس مدل جدید",
  "salePrice": 19000000,
  "currentStock": 45,
  "notes": "قیمت به‌روز شد",
  "updatedAt": "2024-01-16T14:20:00.000Z",
  "...": "بقیه فیلدها"
}
```

### Errors
- `404 Not Found` - محصول یافت نشد
- `409 Conflict` - کد تکراری (در صورت تغییر code)

---

## 5️⃣ Delete Product

### Request
```http
DELETE /api/products/{id}
Authorization: Bearer {token}
```

### Response (204 No Content)
بدون محتوا

### Errors
- `404 Not Found` - محصول یافت نشد
- `409 Conflict` - محصول در حال استفاده است

---

## 6️⃣ Update Stock

### Request
```http
PATCH /api/products/{id}/stock
Content-Type: application/json
Authorization: Bearer {token}

{
  "quantity": 100
}
```

> 📝 **توضیح**: موجودی به مقدار مشخص **تنظیم** می‌شود (نه اضافه یا کسر)

### Response (200 OK)
```json
{
  "id": "uuid-product-id",
  "currentStock": 100,
  "status": "active",
  "updatedAt": "2024-01-16T15:00:00.000Z"
}
```

---

## 7️⃣ Adjust Stock

### Request
```http
PATCH /api/products/{id}/stock/adjust
Content-Type: application/json
Authorization: Bearer {token}

{
  "adjustment": -5
}
```

> 📝 **توضیح**: 
> - عدد مثبت = افزایش موجودی
> - عدد منفی = کاهش موجودی
> - `currentStock = currentStock + adjustment`

### Response (200 OK)
```json
{
  "id": "uuid-product-id",
  "currentStock": 45,
  "previousStock": 50,
  "adjustment": -5,
  "status": "active",
  "updatedAt": "2024-01-16T15:30:00.000Z"
}
```

### Errors
- `409 Conflict` - موجودی کافی نیست (برای کاهش)

---

## 8️⃣ Update Status

### Request
```http
PATCH /api/products/{id}/status
Content-Type: application/json
Authorization: Bearer {token}

{
  "status": "inactive"
}
```

### Response (200 OK)
```json
{
  "id": "uuid-product-id",
  "status": "inactive",
  "updatedAt": "2024-01-16T16:00:00.000Z"
}
```

---

## 9️⃣ Get Product Stats

### Request
```http
GET /api/products/stats?businessId={businessId}
Authorization: Bearer {token}
```

### Response (200 OK)
```json
{
  "totalProducts": 150,
  "activeProducts": 120,
  "inactiveProducts": 25,
  "outOfStockProducts": 5,
  "lowStockProducts": 12,
  "totalValue": 450000000,
  "averagePrice": 3000000
}
```

---

## 🔟 Get Categories

### Request
```http
GET /api/products/categories?businessId={businessId}
Authorization: Bearer {token}
```

### Response (200 OK)
```json
[
  "Electronics",
  "Clothing",
  "Food",
  "Furniture",
  "Books"
]
```

---

## 1️⃣1️⃣ Get Brands

### Request
```http
GET /api/products/brands?businessId={businessId}
Authorization: Bearer {token}
```

### Response (200 OK)
```json
[
  "ASUS",
  "Samsung",
  "Apple",
  "Sony",
  "LG"
]
```

---

## 1️⃣2️⃣ Upload Image

### Request
```http
POST /api/products/{id}/images
Content-Type: application/json
Authorization: Bearer {token}

{
  "imageUrl": "https://example.com/new-image.jpg"
}
```

### Response (200 OK)
```json
{
  "id": "uuid-product-id",
  "mainImage": "https://example.com/new-image.jpg",
  "images": ["https://example.com/new-image.jpg", "https://example.com/image1.jpg"],
  "updatedAt": "2024-01-16T17:00:00.000Z"
}
```

---

## 1️⃣3️⃣ Remove Image

### Request
```http
DELETE /api/products/{id}/images
Content-Type: application/json
Authorization: Bearer {token}

{
  "imageUrl": "https://example.com/image1.jpg"
}
```

### Response (200 OK)
```json
{
  "id": "uuid-product-id",
  "images": ["https://example.com/new-image.jpg"],
  "updatedAt": "2024-01-16T17:30:00.000Z"
}
```

---

## 🔄 Error Responses (مشترک)

### 400 Bad Request
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": [
    "code must be a string",
    "purchasePrice must be a positive number"
  ]
}
```

### 401 Unauthorized
```json
{
  "statusCode": 401,
  "message": "Unauthorized"
}
```

### 404 Not Found
```json
{
  "statusCode": 404,
  "message": "Product not found"
}
```

### 409 Conflict
```json
{
  "statusCode": 409,
  "message": "Product code already exists"
}
```

### 500 Internal Server Error
```json
{
  "statusCode": 500,
  "message": "Internal server error"
}
```

---

## 📝 نکات پیاده‌سازی Flutter

### 1. Product Model
```dart
@JsonSerializable()
class Product {
  final String id;
  final String code;
  final String name;
  final String? nameEn;
  final String? description;
  final String type;
  final String unit;
  // ... بقیه فیلدها
}
```

### 2. API Service
```dart
class ProductApiService {
  Future<Product> createProduct(CreateProductDto dto);
  Future<PaginatedResponse<Product>> getProducts(ProductFilter filter);
  Future<Product> getProductById(String id);
  Future<Product> updateProduct(String id, UpdateProductDto dto);
  Future<void> deleteProduct(String id);
  Future<Product> updateStock(String id, double quantity);
  Future<Product> adjustStock(String id, double adjustment);
  Future<Product> updateStatus(String id, String status);
  Future<ProductStats> getProductStats(String businessId);
  Future<List<String>> getCategories(String businessId);
  Future<List<String>> getBrands(String businessId);
}
```

### 3. BLoC Events
```dart
- LoadProducts
- LoadProductById
- CreateProduct
- UpdateProduct
- DeleteProduct
- UpdateProductStock
- AdjustProductStock
- UpdateProductStatus
- LoadProductStats
- LoadCategories
- LoadBrands
- ApplyFilter
- SearchProducts
```

---

## ✅ چک‌لیست Sync

- [x] Backend Controller کامل است
- [x] Backend DTOs کامل است
- [x] Backend Entity کامل است
- [x] Flutter Models ایجاد شد
- [x] Flutter API Service ایجاد شد
- [x] Flutter Repository ایجاد شد
- [x] Flutter BLoC ایجاد شد
- [x] Flutter UI Pages ایجاد شد
- [x] مستندات API کامل است
- [ ] تست‌های Backend نوشته شود
- [ ] تست‌های Flutter نوشته شود
- [ ] Image Upload واقعی پیاده‌سازی شود
- [ ] Edit Product در Flutter تکمیل شود

---

## 🔗 لینک‌های مرتبط

- [Common Types](./common-types.md) - تایپ‌های مشترک
- [Auth API](./auth-api.md) - احراز هویت
- [Business API](./business-api.md) - کسب‌وکار
- [Backend Product Module](../backend/src/modules/product/) - کد Backend
- [Flutter Product Feature](../mobile/lib/features/product/) - کد Flutter

---

**آخرین به‌روزرسانی**: 2024-01-16  
**وضعیت**: ✅ کامل و همگام با کد
