# منطق محصولات و تنوع‌ها - Product & Variants Logic

> 📋 **مستند کامل** منطق کاری محصولات دارای تنوع و بدون تنوع در سیستم

## 📌 خلاصه

این سیستم دو نوع محصول را پشتیبانی می‌کند:
1. **محصولات دارای تنوع** (Products with Variants) - مثل لباس با رنگ و سایزهای مختلف
2. **محصولات بدون تنوع** (Simple Products) - مثل کتاب یا خدمات

هر محصول با فیلد `hasVariants` مشخص می‌کند که از کدام نوع است.

---

## 🎯 دو حالت محصول

### 1️⃣ محصول دارای تنوع (`hasVariants: true`)

#### مشخصات:
- ✅ دارای **تنوع‌های متعدد** (مثلاً رنگ قرمز، آبی، سبز)
- ✅ ویژگی‌های سطح تنوع و سطح محصول را می‌تواند داشته باشد
- ✅ موجودی و قیمت در سطح **تنوع** (Variant) مدیریت می‌شود
- ❌ فیلدهای موجودی محصول (`currentStock`, `minStock`, ...) **نباید** در UI دیده شود
- ❌ `trackInventory` در سطح محصول همیشه `false` است

#### UI محصول دارای تنوع:

**📁 تب 1: اطلاعات پایه**
```
✅ نمایش: کد، نام، توضیحات، نوع، واحد، قیمت‌گذاری
❌ مخفی: فیلدهای موجودی (currentStock, minStock, maxStock, reorderPoint)
❌ مخفی: سوئیچ trackInventory
✅ نمایش: سوئیچ hasVariants (فعال)
```

**📁 تب 2: ویژگی‌ها و تنوع**
```
✅ نمایش: تمام ویژگی‌های سطح محصول (Product-Level)
✅ نمایش: تمام ویژگی‌های سطح تنوع (Variant-Level)
✅ نمایش: دکمه "مدیریت تنوع‌ها"
✅ نمایش: دکمه "تولید خودکار تنوع‌ها"
```

#### ساخت تنوع‌ها:

**🔧 تولید خودکار:**
- فقط از ویژگی‌های **سطح تنوع** (Variant-Level) استفاده می‌کند
- تمام ترکیب‌های ممکن را ایجاد می‌کند
- مثال: اگر رنگ (قرمز، آبی) و سایز (S, M, L) داشته باشیم → 6 تنوع ایجاد می‌شود

**➕ افزودن دستی:**
- در فرم افزودن تنوع، فقط ویژگی‌های **سطح تنوع** مرتبط با محصول نمایش داده می‌شود
- کاربر باید برای هر ویژگی الزامی، مقدار انتخاب کند

#### مثال عملی:
```
محصول: تی‌شرت ورزشی
hasVariants: true

ویژگی‌های سطح محصول:
- جنس: پنبه
- کشور سازنده: ایران

ویژگی‌های سطح تنوع:
- رنگ: قرمز، آبی، سبز
- سایز: S, M, L, XL

تنوع‌ها (12 تنوع):
1. تی‌شرت قرمز - S
2. تی‌شرت قرمز - M
3. تی‌شرت قرمز - L
4. تی‌شرت قرمز - XL
5. تی‌شرت آبی - S
...
```

---

### 2️⃣ محصول بدون تنوع (`hasVariants: false`)

#### مشخصات:
- ✅ محصول **ساده** بدون تنوع
- ✅ فقط ویژگی‌های سطح محصول (Product-Level) را می‌تواند داشته باشد
- ✅ موجودی و قیمت در سطح **محصول** مدیریت می‌شود
- ✅ فیلدهای موجودی در تب اطلاعات پایه **نمایش داده می‌شود**
- ✅ `trackInventory` قابل تنظیم است (true/false)

#### UI محصول بدون تنوع:

**📁 تب 1: اطلاعات پایه**
```
✅ نمایش: کد، نام، توضیحات، نوع، واحد، قیمت‌گذاری
✅ نمایش: فیلدهای موجودی (currentStock, minStock, maxStock, reorderPoint)
✅ نمایش: سوئیچ trackInventory
✅ نمایش: سوئیچ hasVariants (غیرفعال)
```

**📁 تب 2: ویژگی‌ها**
```
✅ نمایش: فقط ویژگی‌های سطح محصول (Product-Level)
❌ مخفی: ویژگی‌های سطح تنوع (Variant-Level)
❌ مخفی: بخش مدیریت تنوع‌ها
```

#### مثال عملی:
```
محصول: کتاب آموزش برنامه‌نویسی
hasVariants: false

ویژگی‌های سطح محصول:
- ناشر: نشر فلان
- تعداد صفحات: 350
- نویسنده: احمد محمدی

موجودی:
- موجودی فعلی: 50
- حداقل موجودی: 10
- trackInventory: true
```

---

## 🔄 تغییر نوع محصول

### تغییر از بدون تنوع به دارای تنوع

**قبل:** `hasVariants: false` → **بعد:** `hasVariants: true`

**تغییرات خودکار سیستم:**
1. ✅ ویژگی‌های الزامی سطح تنوع به محصول اضافه می‌شود
2. ✅ فیلدهای موجودی محصول صفر می‌شود:
   ```
   currentStock = 0
   minStock = 0
   maxStock = null
   reorderPoint = null
   trackInventory = false
   ```
3. ✅ UI تب دوم به "ویژگی‌ها و تنوع" تغییر می‌کند
4. ✅ بخش مدیریت تنوع‌ها نمایش داده می‌شود

**توجه:** موجودی قبلی محصول **از بین می‌رود**. کاربر باید تنوع‌ها را بسازد و موجودی را دوباره وارد کند.

### تغییر از دارای تنوع به بدون تنوع

**قبل:** `hasVariants: true` → **بعد:** `hasVariants: false`

**تغییرات خودکار سیستم:**
1. ✅ ویژگی‌های سطح تنوع از محصول حذف می‌شود
2. ✅ فیلدهای موجودی محصول قابل ویرایش می‌شود
3. ✅ UI تب دوم به "ویژگی‌ها" تغییر می‌کند
4. ✅ بخش مدیریت تنوع‌ها مخفی می‌شود

**توجه:** تنوع‌های موجود **حذف نمی‌شود**. باید توسط کاربر حذف شوند یا سیستم هشدار دهد.

---

## 📊 جدول مقایسه

| ویژگی | محصول دارای تنوع | محصول بدون تنوع |
|-------|------------------|-----------------|
| `hasVariants` | `true` | `false` |
| نام تب دوم | "ویژگی‌ها و تنوع" | "ویژگی‌ها" |
| ویژگی‌های Product-Level | ✅ | ✅ |
| ویژگی‌های Variant-Level | ✅ | ❌ |
| نمایش فیلدهای موجودی در تب اول | ❌ | ✅ |
| مدیریت موجودی | در سطح تنوع | در سطح محصول |
| `trackInventory` محصول | همیشه `false` | قابل تنظیم |
| بخش مدیریت تنوع‌ها | ✅ | ❌ |
| تولید خودکار تنوع | ✅ (از Variant-Level) | ❌ |

---

## 🔐 ویژگی‌های الزامی (Required Attributes)

### رفتار سیستم

**پس از ساخت محصول جدید:**

سیستم به‌صورت خودکار ویژگی‌های الزامی را بر اساس نوع محصول ثبت می‌کند:

#### اگر `hasVariants = true`:
```
✅ ویژگی‌های الزامی Product-Level → ثبت می‌شود (مقدار خالی)
✅ ویژگی‌های الزامی Variant-Level → ثبت می‌شود (مقدار خالی)
```

#### اگر `hasVariants = false`:
```
✅ ویژگی‌های الزامی Product-Level → ثبت می‌شود (مقدار خالی)
❌ ویژگی‌های الزامی Variant-Level → ثبت نمی‌شود
```

**نکته:** مقادیر خالی (`[]`) ثبت می‌شود تا بعداً توسط کاربر پر شود.

---

## 🎨 نمونه کد Backend

### Auto-assign Required Attributes
```typescript
async create(createProductDto: CreateProductDto): Promise<Product> {
  const product = await this.productRepository.save(createProductDto);
  
  // Auto-assign required attributes
  const requiredAttributes = await this.attributeRepository.find({
    where: {
      businessId: product.businessId,
      required: true,
      isActive: true,
    },
  });

  const attributesToAssign = requiredAttributes.filter(attr => {
    if (product.hasVariants) {
      // محصول دارای تنوع: همه ویژگی‌های الزامی
      return true;
    } else {
      // محصول بدون تنوع: فقط ویژگی‌های سطح محصول
      return attr.scope === AttributeScope.PRODUCT_LEVEL;
    }
  });

  const attributeValues = attributesToAssign.map((attr, index) => ({
    productId: product.id,
    attributeId: attr.id,
    value: [], // Empty
    sortOrder: index,
  }));

  await this.attributeValueRepository.save(attributeValues);
  
  return product;
}
```

### Handle hasVariants Change
```typescript
async update(id: string, updateDto: UpdateProductDto): Promise<Product> {
  const product = await this.findOne(id);
  
  const wasHasVariants = product.hasVariants;
  const willBeHasVariants = updateDto.hasVariants ?? product.hasVariants;

  if (wasHasVariants !== willBeHasVariants) {
    if (willBeHasVariants) {
      // Add Variant-Level attributes
      await this.addVariantLevelAttributes(product);
      // Reset inventory fields
      updateDto.currentStock = 0;
      updateDto.minStock = 0;
      updateDto.trackInventory = false;
    } else {
      // Remove Variant-Level attributes
      await this.removeVariantLevelAttributes(product);
    }
  }

  Object.assign(product, updateDto);
  return await this.productRepository.save(product);
}
```

---

## 📱 نمونه کد Flutter

### Filter Attributes by Scope
```dart
List<ProductAttribute> get _assignedAttributes {
  return _allAttributes.where((attr) {
    if (widget.hasVariants) {
      // محصول دارای تنوع: همه ویژگی‌ها
      return _productAttributeValues.containsKey(attr.id);
    } else {
      // محصول بدون تنوع: فقط سطح محصول
      return _productAttributeValues.containsKey(attr.id) && 
             attr.scope == AttributeScope.productLevel;
    }
  }).toList();
}

List<ProductAttribute> get _availableAttributes {
  return _allAttributes.where((attr) {
    if (_productAttributeValues.containsKey(attr.id)) return false;
    
    if (widget.hasVariants) {
      return true; // همه ویژگی‌ها
    } else {
      return attr.scope == AttributeScope.productLevel; // فقط سطح محصول
    }
  }).toList();
}
```

### Dynamic Tab Name
```dart
TabBar(
  tabs: [
    Tab(text: 'اطلاعات پایه'),
    Tab(
      text: _hasVariants ? 'ویژگی‌ها و تنوع' : 'ویژگی‌ها',
      icon: Icon(_hasVariants ? Icons.playlist_add : Icons.list),
    ),
  ],
)
```

### Conditional Inventory Fields
```dart
// فیلدهای موجودی فقط برای محصولات بدون تنوع فعال است
TextField(
  controller: _currentStockController,
  enabled: !_hasVariants,
)
```

---

## ✅ چک‌لیست پیاده‌سازی

### Backend
- [x] اضافه کردن فیلد `hasVariants` به Product entity
- [x] اضافه کردن `totalStock` برای محصولات دارای تنوع
- [x] پیاده‌سازی auto-assign برای required attributes
- [x] پیاده‌سازی logic تغییر hasVariants
- [x] صفر کردن فیلدهای موجودی زمان تغییر به hasVariants=true
- [x] فیلتر کردن Variant-Level attributes در API تولید تنوع

### Frontend (Flutter)
- [x] اضافه کردن فیلد `hasVariants` به Product model
- [x] نمایش سوئیچ hasVariants در فرم محصول
- [x] تغییر نام تب بر اساس hasVariants
- [x] مخفی/نمایش فیلدهای موجودی بر اساس hasVariants
- [x] فیلتر کردن attributes در ProductAttributesTab
- [x] فیلتر کردن attributes در VariantFormDialog
- [x] نمایش/مخفی بخش مدیریت تنوع‌ها

### Documentation
- [x] به‌روزرسانی API Contracts
- [x] ایجاد این مستند کامل
- [x] اضافه کردن مثال‌های عملی

---

## 📚 منابع مرتبط

- [Product API Contract](./api-contracts/product-api.md)
- [Product Attributes Analysis](./PRODUCT-ATTRIBUTES-ANALYSIS.md)
- [Product Variants User Guide](./PRODUCT-VARIANTS-USER-GUIDE.md)

---

**آخرین به‌روزرسانی:** 23 نوامبر 2025
