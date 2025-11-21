# تحلیل سیستم ویژگی‌دهی محصولات و مدیریت موجودی مبتنی بر Variants

> **وضعیت:** ✅ آماده تایید و پیاده‌سازی  
> **تاریخ:** 20 نوامبر 2025  
> **نسخه:** 2.0 (Revised)

---

## 📌 خلاصه اجرایی (Executive Summary)

### 🎯 هدف
طراحی و پیاده‌سازی یک سیستم **Product Attributes** و **Variant-Based Inventory Management** که به کاربران اجازه می‌دهد:

1. **ویژگی‌های دلخواه** تعریف کنند (سایز، رنگ، جنس، اندازه و ...)
2. **نوع داده** هر ویژگی را مشخص کنند (متن، عدد، انتخابی، رنگ و ...)
3. ویژگی‌ها **تک مقداره** یا **چند مقداره** باشند
4. ویژگی‌ها **ثابت** (در سطح محصول) یا **متغیر** (در سطح Variant) باشند
5. **موجودی مجزا** برای هر ترکیب ویژگی (Variant) مدیریت کنند
6. **رهگیری کامل** فروش و موجودی در سیستم فاکتورها

### 🏆 نوآوری‌های کلیدی

| ویژگی | توضیح | مثال |
|-------|-------|------|
| **Cardinality** | تک یا چند مقداره | جنس: ["پنبه", "پلی‌استر"] |
| **Scope** | ثابت یا متغیر | جنس: ثابت / سایز: متغیر |
| **Variant Snapshot** | ذخیره تاریخچه فروش | SKU + ویژگی‌ها در فاکتور |
| **Stock Transaction** | Audit Trail موجودی | رهگیری کامل تغییرات |
| **Backward Compatible** | سازگار با محصولات فعلی | hasVariants = true/false |

### 📊 معماری در یک نگاه

```
┌─────────────────────────────────────────────────────┐
│                 ProductAttribute                    │
│  (تعریف ویژگی‌ها: سایز، رنگ، جنس و ...)            │
│  - DataType: TEXT, NUMBER, SELECT, COLOR            │
│  - Cardinality: SINGLE / MULTIPLE ✨                │
│  - Scope: PRODUCT_LEVEL / VARIANT_LEVEL ✨          │
└──────────────┬──────────────────────────────────────┘
               │
     ┌─────────┴────────┐
     │                  │
     ▼                  ▼
┌─────────────┐   ┌──────────────┐
│  Product    │   │ProductVariant│
│ Attributes  │   │  Attributes  │
│  (ثابت)     │   │   (متغیر)    │
└─────────────┘   └──────┬───────┘
                         │
                         ▼
                  ┌──────────────┐
                  │ InvoiceItem  │
                  │ + variantId ✨│
                  │ + snapshot  ✨│
                  └──────────────┘
```

### ✅ مشکلات حل شده

1. **تداخل با سیستم انبارداری:** با اضافه کردن `variantId` به `InvoiceItem` حل شد
2. **تک vs چند داده‌ای:** با `AttributeCardinality` پشتیبانی می‌شود
3. **ویژگی ثابت vs متغیر:** با `AttributeScope` تفکیک شدند
4. **رهگیری دقیق موجودی:** با `StockTransaction` و `variantSnapshot` حل شد
5. **سازگاری با گذشته:** محصولات فعلی بدون تغییر کار می‌کنند

---

## 🔴 نقد و بررسی درخواست (Critical Review)

### ✅ نکات صحیح در درخواست:
1. **تک داده‌ای vs چندداده‌ای**: دقیقاً درست است! برخی ویژگی‌ها فقط یک مقدار دارند (جنس=پنبه) و برخی چند مقدار (رنگ=آبی+سفید)
2. **انعطاف‌پذیری**: هر محصول باید بتواند ویژگی‌های دلخواهش را داشته باشد
3. **مدیریت موجودی براساس ترکیب**: هر Variant موجودی مجزا دارد

### 🔴 مشکلات احتمالی که باید حل شوند:

#### 1️⃣ **تداخل با سیستم انبارداری (CRITICAL)**

**مشکل:** در سیستم فعلی:
- فاکتورها (`invoice_items`) مستقیماً به `productId` متصل هستند
- موجودی در سطح محصول (`Product.currentStock`) مدیریت می‌شود
- اگر Variant اضافه کنیم، رهگیری موجودی به هم می‌ریزد!

**سناریوی مشکل:**
```
1. فروش: تی‌شرت سایز L رنگ آبی (2 عدد)
2. سیستم فعلی: از Product.currentStock کم می‌کند (❌ اشتباه!)
3. سیستم جدید: باید از Variant خاص کم کند (✅ درست)
```

**راهکار:**
```typescript
// invoice_items باید variantId هم داشته باشد
@Entity('invoice_items')
class InvoiceItem {
  productId: string;           // محصول اصلی
  variantId?: string;          // ✨ جدید: Variant انتخاب شده
  variantDetails?: JSON;       // ✨ جدید: ذخیره snapshot ویژگی‌ها
  // ...
}
```

#### 2️⃣ **Cardinality (تک/چند داده‌ای) در Attribute**

**درخواست شما کاملاً درست است!** باید مشخص کنیم:

```typescript
enum AttributeCardinality {
  SINGLE = 'single',        // تک مقدار: جنس = "پنبه"
  MULTIPLE = 'multiple',    // چند مقدار: رنگ = ["آبی", "سفید"]
}

@Entity('product_attributes')
class ProductAttribute {
  // ...
  cardinality: AttributeCardinality;  // ✨ تک یا چند داده‌ای
  
  // برای SELECT و MULTI_SELECT
  allowCustomValue: boolean;          // ✨ آیا مقدار دلخواه مجاز است؟
}
```

#### 3️⃣ **Fixed vs Variable Attributes (ثابت vs متغیر)**

**مشکل:** برخی ویژگی‌ها ثابت هستند (جنس همیشه پنبه) و برخی در Variantها متغیرند (سایز و رنگ)

**راهکار:**
```typescript
enum AttributeScope {
  PRODUCT_LEVEL = 'product_level',    // ثابت برای همه (مثل جنس)
  VARIANT_LEVEL = 'variant_level',    // متغیر در Variants (مثل سایز)
}

@Entity('product_attributes')
class ProductAttribute {
  scope: AttributeScope;  // ✨ تعیین سطح
}
```

**مثال:**
```
محصول: تی‌شرت
├─ ویژگی‌های ثابت (Product-level):
│  └─ جنس: پنبه
└─ ویژگی‌های متغیر (Variant-level):
   ├─ سایز: S, M, L, XL
   └─ رنگ: آبی, قرمز, سفید
   
Variants:
├─ V1: [جنس: پنبه] + سایز: S + رنگ: آبی
├─ V2: [جنس: پنبه] + سایز: M + رنگ: آبی
└─ V3: [جنس: پنبه] + سایز: L + رنگ: قرمز
```

---

## 📋 خلاصه درخواست (اصلاح شده)

یک سیستم **Product Attributes** با قابلیت **Variant-Based Inventory Management** که:

1. **تعریف ویژگی‌های دلخواه** با تعیین نوع داده، تک/چندداده‌ای، و سطح (ثابت/متغیر)
2. **ویژگی‌های ثابت** در سطح محصول (مثل جنس)
3. **ویژگی‌های متغیر** برای ایجاد Variants (مثل سایز و رنگ)
4. **مدیریت موجودی مستقل** برای هر Variant
5. **ادغام با سیستم فاکتورها** برای رهگیری دقیق
6. **سازگاری با محصولات فعلی** (بدون Variant)

---

## 🎯 مثال کاربردی (اصلاح شده)

### محصول: تی‌شرت مردانه

#### ویژگی‌های ثابت (Product-level):
```
جنس: پنبه (تک مقداره، همه Variantها این جنس دارند)
برند: Nike
کشور سازنده: ترکیه
```

#### ویژگی‌های متغیر (Variant-level):
```
سایز: S, M, L, XL, XXL (تک مقداره، هر Variant یک سایز)
رنگ: آبی, قرمز, سفید, مشکی (تک مقداره، هر Variant یک رنگ)
```

#### Variants (ترکیبات) با موجودی:

| ID | سایز | رنگ | SKU | موجودی | قیمت |
|----|------|-----|-----|--------|------|
| V1 | S | آبی | TSH-S-BLU | 5 | 150,000 |
| V2 | M | آبی | TSH-M-BLU | 10 | 150,000 |
| V3 | L | آبی | TSH-L-BLU | 8 | 160,000 |
| V4 | XL | آبی | TSH-XL-BLU | 3 | 170,000 |
| V5 | S | قرمز | TSH-S-RED | 12 | 150,000 |
| V6 | M | قرمز | TSH-M-RED | 0 | 150,000 |
| V7 | L | سفید | TSH-L-WHT | 15 | 160,000 |

**موجودی کل محصول** = 5+10+8+3+12+0+15 = 53 عدد

**نکات مهم:**
- جنس برای همه یکسان است (پنبه) → ویژگی ثابت
- سایز و رنگ در هر Variant متفاوت → ویژگی‌های متغیر
- هر Variant موجودی و قیمت مستقل دارد

---

## 🎯 مثال پیچیده‌تر: چند داده‌ای

### محصول: کفش ورزشی

#### ویژگی‌های ثابت:
```
برند: Adidas
نوع: کتانی ورزشی
جنس رویه: چرم مصنوعی + پارچه (چند مقداره!) ✨
```

#### ویژگی‌های متغیر:
```
سایز: 38, 39, 40, 41, 42, 43
رنگ اصلی: مشکی, سفید, آبی
رنگ‌های ترکیبی: [مشکی+قرمز], [سفید+آبی] (چند مقداره!) ✨
```

**Variant نمونه:**
```json
{
  "variantId": "V1",
  "sku": "SHOE-42-BLK-RED",
  "attributes": {
    // ثابت (از محصول اصلی ارث‌بری می‌شود)
    "brand": "Adidas",
    "material": ["چرم مصنوعی", "پارچه"],  // چند مقداره
    
    // متغیر (مخصوص این Variant)
    "size": 42,                              // تک مقداره
    "colors": ["مشکی", "قرمز"]              // چند مقداره
  },
  "stock": 8,
  "price": 2500000
}
```

---

## 🏗️ معماری پیشنهادی (اصلاح شده)

### 1️⃣ **ProductAttribute** (تعریف ویژگی‌ها)

جدولی برای تعریف ویژگی‌های قابل استفاده در کسب‌وکار

```typescript
enum AttributeDataType {
  TEXT = 'text',                 // متن آزاد
  NUMBER = 'number',             // عدد
  SELECT = 'select',             // انتخاب از لیست (تک یا چند)
  COLOR = 'color',               // رنگ (HEX code)
  BOOLEAN = 'boolean',           // بله/خیر
  DATE = 'date',                 // تاریخ
}

enum AttributeCardinality {
  SINGLE = 'single',             // تک مقدار
  MULTIPLE = 'multiple',         // چند مقدار
}

enum AttributeScope {
  PRODUCT_LEVEL = 'product_level',   // ثابت برای همه Variants
  VARIANT_LEVEL = 'variant_level',   // متغیر در هر Variant
}

@Entity('product_attributes')
class ProductAttribute {
  @PrimaryGeneratedColumn('uuid')
  id: string;
  
  @Column({ type: 'uuid' })
  @Index()
  businessId: string;
  
  // شناسایی
  @Column({ type: 'varchar', length: 100 })
  name: string;                  // نام فارسی: "رنگ", "سایز"
  
  @Column({ type: 'varchar', length: 100, nullable: true })
  nameEn: string;                // نام انگلیسی: "Color", "Size"
  
  @Column({ type: 'varchar', length: 50 })
  @Index()
  code: string;                  // کد یونیک: "color", "size"
  
  // تنظیمات نوع داده
  @Column({
    type: 'enum',
    enum: AttributeDataType,
    default: AttributeDataType.TEXT,
  })
  dataType: AttributeDataType;   // نوع داده
  
  @Column({
    type: 'enum',
    enum: AttributeCardinality,
    default: AttributeCardinality.SINGLE,
  })
  cardinality: AttributeCardinality;  // ✨ تک یا چند داده‌ای
  
  @Column({
    type: 'enum',
    enum: AttributeScope,
    default: AttributeScope.VARIANT_LEVEL,
  })
  scope: AttributeScope;         // ✨ سطح محصول یا Variant
  
  // مقادیر ممکن (برای SELECT)
  @Column({ type: 'jsonb', nullable: true })
  options: {
    value: string;               // مقدار
    label: string;               // برچسب نمایشی
    color?: string;              // رنگ (برای نمایش UI)
    sortOrder?: number;          // ترتیب
  }[];
  
  @Column({ type: 'boolean', default: false })
  allowCustomValue: boolean;     // ✨ مجاز بودن مقدار دلخواه
  
  // Validation
  @Column({ type: 'boolean', default: false })
  required: boolean;             // اجباری
  
  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  minValue: number;              // حداقل (برای NUMBER)
  
  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  maxValue: number;              // حداکثر (برای NUMBER)
  
  @Column({ type: 'varchar', length: 200, nullable: true })
  pattern: string;               // Regex pattern
  
  @Column({ type: 'text', nullable: true })
  description: string;           // توضیحات
  
  @Column({ type: 'text', nullable: true })
  helpText: string;              // راهنما برای کاربر
  
  // UI Settings
  @Column({ type: 'integer', default: 0 })
  sortOrder: number;             // ترتیب نمایش
  
  @Column({ type: 'varchar', length: 50, nullable: true })
  displayFormat: string;         // فرمت نمایش (مثلاً برای عدد)
  
  @Column({ type: 'varchar', length: 50, nullable: true })
  icon: string;                  // آیکون
  
  // Status
  @Column({ type: 'boolean', default: true })
  isActive: boolean;             // فعال/غیرفعال
  
  @CreateDateColumn()
  createdAt: Date;
  
  @UpdateDateColumn()
  updatedAt: Date;
  
  // Relations
  @ManyToOne(() => Business, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'businessId' })
  business: Business;
}
```

---

### 2️⃣ **ProductAttributeValue** (مقادیر ویژگی‌های محصول)

ویژگی‌های ثابت در سطح محصول (Product-level)

```typescript
@Entity('product_attribute_values')
class ProductAttributeValue {
  @PrimaryGeneratedColumn('uuid')
  id: string;
  
  @Column({ type: 'uuid' })
  @Index()
  productId: string;
  
  @Column({ type: 'uuid' })
  @Index()
  attributeId: string;
  
  // ذخیره مقدار بر اساس نوع داده و cardinality
  @Column({ type: 'jsonb' })
  value: any;  // می‌تواند: string, number, string[], boolean, Date
  
  /*
  مثال‌ها:
  - TEXT (single):           { "value": "پنبه" }
  - NUMBER (single):         { "value": 250 }
  - SELECT (single):         { "value": "large" }
  - SELECT (multiple):       { "value": ["cotton", "polyester"] }
  - COLOR (single):          { "value": "#FF0000" }
  - COLOR (multiple):        { "value": ["#FF0000", "#0000FF"] }
  - BOOLEAN:                 { "value": true }
  - DATE:                    { "value": "2024-01-15" }
  */
  
  @Column({ type: 'integer', default: 0 })
  sortOrder: number;
  
  @CreateDateColumn()
  createdAt: Date;
  
  @UpdateDateColumn()
  updatedAt: Date;
  
  // Relations
  @ManyToOne(() => Product, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'productId' })
  product: Product;
  
  @ManyToOne(() => ProductAttribute, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'attributeId' })
  attribute: ProductAttribute;
  
  // Unique constraint
  @Index(['productId', 'attributeId'], { unique: true })
}
```

---

### 3️⃣ **ProductVariant** (ترکیبات محصول)

```typescript
enum VariantStatus {
  IN_STOCK = 'in_stock',           // موجود
  LOW_STOCK = 'low_stock',         // موجودی کم
  OUT_OF_STOCK = 'out_of_stock',   // ناموجود
  DISCONTINUED = 'discontinued',    // متوقف شده
}

@Entity('product_variants')
class ProductVariant {
  @PrimaryGeneratedColumn('uuid')
  id: string;
  
  @Column({ type: 'uuid' })
  @Index()
  productId: string;
  
  @Column({ type: 'uuid' })
  @Index()
  businessId: string;
  
  // شناسایی
  @Column({ type: 'varchar', length: 100, unique: true })
  @Index()
  sku: string;                   // ✨ SKU یونیک (اجباری برای Variant)
  
  @Column({ type: 'varchar', length: 100, nullable: true })
  barcode: string;
  
  @Column({ type: 'varchar', length: 200, nullable: true })
  name: string;                  // نام اختصاصی (مثلاً "تی‌شرت سایز L آبی")
  
  // ویژگی‌های متغیر (Variant-level attributes)
  @Column({ type: 'jsonb' })
  attributes: Record<string, any>;
  /*
  مثال:
  {
    "size": "L",                    // تک مقداره
    "color": "#0000FF",             // تک مقداره
    "features": ["waterproof", "breathable"]  // چند مقداره
  }
  */
  
  // موجودی
  @Column({ type: 'decimal', precision: 15, scale: 3, default: 0 })
  currentStock: number;          // ✨ موجودی فعلی این Variant
  
  @Column({ type: 'decimal', precision: 15, scale: 3, default: 0 })
  minStock: number;              // حداقل موجودی
  
  @Column({ type: 'decimal', precision: 15, scale: 3, nullable: true })
  reorderPoint: number;          // نقطه سفارش مجدد
  
  // قیمت‌گذاری (تفاوت با محصول اصلی)
  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  priceAdjustment: number;       // ✨ تفاوت قیمت (+ یا -)
  
  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  purchasePriceAdjustment: number;
  
  // یا قیمت مطلق
  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  salePrice: number;             // قیمت نهایی (اگر null، از محصول اصلی)
  
  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  purchasePrice: number;
  
  // تصاویر
  @Column({ type: 'varchar', length: 500, nullable: true })
  mainImage: string;
  
  @Column({ type: 'simple-array', nullable: true })
  images: string[];
  
  // ابعاد و وزن
  @Column({ type: 'decimal', precision: 10, scale: 3, nullable: true })
  weight: number;
  
  @Column({ type: 'jsonb', nullable: true })
  dimensions: {
    length?: number;
    width?: number;
    height?: number;
    unit?: string;
  };
  
  // وضعیت
  @Column({ type: 'boolean', default: true })
  isActive: boolean;
  
  @Column({
    type: 'enum',
    enum: VariantStatus,
    default: VariantStatus.IN_STOCK,
  })
  status: VariantStatus;
  
  @Column({ type: 'integer', default: 0 })
  sortOrder: number;
  
  @Column({ type: 'text', nullable: true })
  notes: string;
  
  @CreateDateColumn()
  createdAt: Date;
  
  @UpdateDateColumn()
  updatedAt: Date;
  
  // Relations
  @ManyToOne(() => Product, (product) => product.variants, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'productId' })
  product: Product;
  
  @ManyToOne(() => Business, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'businessId' })
  business: Business;
  
  @OneToMany(() => InvoiceItem, (item) => item.variant)
  invoiceItems: InvoiceItem[];  // ✨ ارتباط با فاکتورها
}
```

---

### 4️⃣ **تغییرات در Product Entity**

```typescript
@Entity('products')
class Product {
  // ... فیلدهای موجود ...
  
  // ✨ فیلدهای جدید برای Variants:
  
  @Column({ type: 'boolean', default: false })
  hasVariants: boolean;           // آیا این محصول Variant دارد؟
  
  @Column({ type: 'decimal', precision: 15, scale: 3, default: 0 })
  totalStock: number;             // موجودی کل (محاسبه‌ای)
  
  // Relations
  @OneToMany(() => ProductVariant, (variant) => variant.product)
  variants: ProductVariant[];
  
  @OneToMany(() => ProductAttributeValue, (value) => value.product)
  attributeValues: ProductAttributeValue[];  // ✨ ویژگی‌های ثابت
}
```

**منطق محاسبه موجودی:**
```typescript
calculateTotalStock(product: Product): number {
  if (!product.hasVariants) {
    return product.currentStock;  // موجودی خود محصول
  }
  
  // جمع موجودی تمام Variantهای فعال
  return product.variants
    .filter(v => v.isActive)
    .reduce((sum, v) => sum + v.currentStock, 0);
}
```

---

### 5️⃣ **تغییرات در InvoiceItem Entity** ✨

**CRITICAL**: برای رهگیری دقیق موجودی

```typescript
@Entity('invoice_items')
class InvoiceItem {
  // ... فیلدهای موجود ...
  
  @Column({ type: 'uuid', nullable: true })
  productId: string;             // محصول اصلی
  
  // ✨ جدید:
  @Column({ type: 'uuid', nullable: true })
  variantId: string;             // Variant انتخاب شده (اگر دارد)
  
  @Column({ type: 'jsonb', nullable: true })
  variantSnapshot: {             // ✨ Snapshot ویژگی‌ها در زمان فروش
    sku: string;
    attributes: Record<string, any>;
    name?: string;
  };
  
  // Relations
  @ManyToOne(() => Product, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'productId' })
  product: Product;
  
  @ManyToOne(() => ProductVariant, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'variantId' })
  variant: ProductVariant;       // ✨ ارتباط با Variant
}
```

**چرا Snapshot؟**
- اگر Variant بعداً تغییر کند یا حذف شود، فاکتور تاریخی معتبر بماند
- می‌توانیم ببینیم دقیقاً چه چیزی فروخته شده

---
  
  name: string;                  // نام ویژگی (فارسی): "رنگ", "سایز"
  nameEn?: string;               // نام انگلیسی: "Color", "Size"
  code: string;                  // کد یونیک: "color", "size"
  
  dataType: AttributeDataType;   // نوع داده
  
  // برای انتخابی
  options?: string[];            // مقادیر ممکن: ["آبی","قرمز","سفید"]
  
  // Validation
  required: boolean;             // اجباری بودن
  minValue?: number;             // حداقل (برای عدد)
  maxValue?: number;             // حداکثر (برای عدد)
  pattern?: string;              // Regex pattern (برای متن)
  
  sortOrder: number;             // ترتیب نمایش
  isActive: boolean;             // فعال/غیرفعال
  
  createdAt: Date;
  updatedAt: Date;
}
```

**انواع داده (AttributeDataType):**
```typescript
enum AttributeDataType {
  TEXT = 'text',           // متن آزاد
  NUMBER = 'number',       // عدد
  SELECT = 'select',       // انتخاب از لیست (یکی)
  MULTI_SELECT = 'multi_select', // انتخاب چندگانه
  COLOR = 'color',         // رنگ (HEX code)
  BOOLEAN = 'boolean',     // بله/خیر
  DATE = 'date',           // تاریخ
}
```

---

### 2️⃣ **ProductAttributeValue** (مقادیر ویژگی‌ها)

جدول واسط برای تعریف اینکه یک محصول چه ویژگی‌هایی دارد

```typescript
@Entity('product_attribute_values')
class ProductAttributeValue {
  id: string;                    // UUID
  productId: string;             // محصول
  attributeId: string;           // ویژگی
  
  // مقدار بسته به نوع داده
  textValue?: string;            // برای TEXT
  numberValue?: number;          // برای NUMBER
  selectValue?: string;          // برای SELECT
  multiSelectValue?: string[];   // برای MULTI_SELECT
  colorValue?: string;           // برای COLOR (HEX)
  booleanValue?: boolean;        // برای BOOLEAN
  dateValue?: Date;              // برای DATE
  
  sortOrder: number;             // ترتیب نمایش
  
  createdAt: Date;
  updatedAt: Date;
  
  // Relations
  product: Product;
  attribute: ProductAttribute;
}
```

---

### 3️⃣ **ProductVariant** (ترکیبات محصول)

جدول اصلی برای ذخیره ترکیبات مختلف ویژگی‌ها + موجودی

```typescript
@Entity('product_variants')
class ProductVariant {
  id: string;                    // UUID
  productId: string;             // محصول اصلی
  businessId: string;            // کسب‌وکار
  
  // شناسایی
  sku?: string;                  // SKU اختصاصی این Variant
  barcode?: string;              // بارکد اختصاصی
  
  // ترکیب ویژگی‌ها (JSON)
  attributes: {
    [attributeCode: string]: any;
  };
  // مثال: { "size": "XL", "color": "آبی", "material": "پنبه" }
  
  // موجودی
  currentStock: number;          // موجودی فعلی این Variant
  minStock: number;              // حداقل موجودی
  reorderPoint?: number;         // نقطه سفارش مجدد
  
  // قیمت‌گذاری (اختیاری - اگر با محصول اصلی فرق داشته باشد)
  priceAdjustment?: number;      // تفاوت قیمت با محصول اصلی
  purchasePriceAdjustment?: number;
  
  // تصویر اختصاصی (اختیاری)
  image?: string;
  
  // وضعیت
  isActive: boolean;             // فعال/غیرفعال
  status: VariantStatus;         // وضعیت موجودی
  
  // متادیتا
  weight?: number;               // وزن
  dimensions?: {
    length?: number;
    width?: number;
    height?: number;
  };
  
  createdAt: Date;
  updatedAt: Date;
  
  // Relations
  product: Product;
  business: Business;
}
```

**وضعیت Variant:**
```typescript
enum VariantStatus {
  IN_STOCK = 'in_stock',           // موجود
  LOW_STOCK = 'low_stock',         // موجودی کم
  OUT_OF_STOCK = 'out_of_stock',   // ناموجود
  DISCONTINUED = 'discontinued',    // متوقف شده
}
```

---

### 4️⃣ **تغییرات در Product Entity**

محصول اصلی باید بداند که آیا Variant دارد یا نه:

```typescript
@Entity('products')
class Product {
  // ... فیلدهای موجود ...
  
  // ✨ فیلدهای جدید:
  
  @Column({ type: 'boolean', default: false })
  hasVariants: boolean;           // آیا این محصول Variant دارد؟
  
  @Column({ type: 'decimal', precision: 15, scale: 3, default: 0 })
  totalStock: number;             // موجودی کل = sum(variants.currentStock)
  
  // Relations
  @OneToMany(() => ProductVariant, variant => variant.product)
  variants: ProductVariant[];
  
  @OneToMany(() => ProductAttributeValue, value => value.product)
  attributeValues: ProductAttributeValue[];
}
```

**منطق:**
- اگر `hasVariants = false`: موجودی از `currentStock` خود محصول
- اگر `hasVariants = true`: موجودی از `totalStock` که حاصل جمع Variantهاست

---

## 🔄 فلوی کاری (Workflow) - اصلاح شده

### مرحله 1: تعریف ویژگی‌ها توسط کاربر

```
1. کاربر وارد "تنظیمات ویژگی‌ها" می‌شود
2. ویژگی اول (ثابت - Product-level):
   - نام: "جنس"
   - نوع: SELECT
   - Cardinality: SINGLE (تک مقداره)
   - Scope: PRODUCT_LEVEL (ثابت)
   - مقادیر: ["پنبه", "پلی‌استر", "ترگال"]
   
3. ویژگی دوم (متغیر - Variant-level):
   - نام: "سایز"
   - نوع: SELECT
   - Cardinality: SINGLE (تک مقداره)
   - Scope: VARIANT_LEVEL (متغیر)
   - مقادیر: ["S", "M", "L", "XL", "XXL"]
   
4. ویژگی سوم (متغیر - Variant-level):
   - نام: "رنگ"
   - نوع: COLOR
   - Cardinality: SINGLE (تک مقداره)
   - Scope: VARIANT_LEVEL (متغیر)
```

### مرحله 2: ایجاد محصول با Variants

```
1. کاربر محصول "تی‌شرت مردانه" را ایجاد می‌کند
   - نام: تی‌شرت مردانه
   - قیمت پایه: 150,000
   - hasVariants = true ✅

2. تخصیص ویژگی‌های ثابت (Product-level):
   - جنس: پنبه (برای همه Variantها یکسان)

3. انتخاب ویژگی‌های متغیر (Variant-level):
   - سایز ✅
   - رنگ ✅

4. ایجاد Variants:
   روش A: دستی
   - کاربر یک به یک Variant اضافه می‌کند
   
   روش B: ایجاد خودکار
   - سیستم تمام ترکیبات ممکن را پیشنهاد می‌دهد
   - مثلاً: 5 سایز × 4 رنگ = 20 Variant
   - کاربر مورد نظرش را انتخاب/حذف می‌کند

5. برای هر Variant:
   - SKU خودکار یا دستی
   - موجودی اولیه
   - قیمت (یا تفاوت از قیمت پایه)
   - تصویر (اختیاری)
```

### مرحله 3: مدیریت موجودی

```
سناریو 1: ورود به انبار
├─ کاربر Variant خاص را انتخاب می‌کند (مثلاً: سایز L، رنگ آبی)
├─ تعداد را وارد می‌کند: +10
├─ variant.currentStock += 10
├─ product.totalStock بازمحاسبه می‌شود
└─ variant.status به‌روز می‌شود

سناریو 2: فروش (از طریق فاکتور)
├─ کاربر محصول را انتخاب می‌کند
├─ سیستم لیست Variantهای موجود نشان می‌دهد
├─ کاربر Variant مورد نظر را انتخاب می‌کند
├─ تعداد را وارد می‌کند: 2
├─ Validation: آیا موجودی کافی است؟
├─ در InvoiceItem ذخیره می‌شود:
│  ├─ productId
│  ├─ variantId ✨
│  └─ variantSnapshot ✨ (SKU, attributes)
├─ پس از تایید فاکتور:
│  ├─ variant.currentStock -= 2
│  ├─ product.totalStock بازمحاسبه می‌شود
│  └─ variant.status به‌روز می‌شود
└─ رهگیری کامل: چه چیزی، کی، چند تا فروخته شد
```

### مرحله 4: گزارش‌گیری

```
- موجودی به تفکیک Variant
- Variantهای پرفروش
- Variantهای کم‌فروش
- هشدار موجودی کم
- پیش‌بینی نیاز به سفارش مجدد
```

---

## 📊 محاسبات خودکار و Triggers

### 1. محاسبه موجودی کل (totalStock)

```typescript
async updateTotalStock(productId: string) {
  const product = await this.productRepository.findOne({
    where: { id: productId },
    relations: ['variants'],
  });
  
  if (!product.hasVariants) {
    // محصولات بدون Variant موجودی خودشان را دارند
    return;
  }
  
  // جمع موجودی تمام Variantهای فعال
  const totalStock = product.variants
    .filter(v => v.isActive)
    .reduce((sum, v) => sum + Number(v.currentStock), 0);
  
  await this.productRepository.update(productId, { totalStock });
}

// این تابع باید بعد از هر تغییر موجودی Variant اجرا شود:
// - ورود به انبار
// - خروج از انبار
// - فروش
// - مرجوعی
```

### 2. محاسبه وضعیت Variant

```typescript
calculateVariantStatus(variant: ProductVariant): VariantStatus {
  if (!variant.isActive) {
    return VariantStatus.DISCONTINUED;
  }
  
  if (variant.currentStock <= 0) {
    return VariantStatus.OUT_OF_STOCK;
  }
  
  if (variant.currentStock <= variant.minStock) {
    return VariantStatus.LOW_STOCK;
  }
  
  return VariantStatus.IN_STOCK;
}

// Auto-update after stock changes
async afterStockChange(variantId: string) {
  const variant = await this.variantRepository.findOne({
    where: { id: variantId },
  });
  
  const newStatus = this.calculateVariantStatus(variant);
  
  if (variant.status !== newStatus) {
    await this.variantRepository.update(variantId, { status: newStatus });
    
    // اگر موجودی کم شد، Notification بفرست
    if (newStatus === VariantStatus.LOW_STOCK) {
      await this.notificationService.sendLowStockAlert(variant);
    }
  }
  
  // به‌روزرسانی وضعیت محصول اصلی
  await this.updateProductStatus(variant.productId);
}
```

### 3. محاسبه وضعیت محصول

```typescript
async updateProductStatus(productId: string) {
  const product = await this.productRepository.findOne({
    where: { id: productId },
    relations: ['variants']
  });
  
  if (!product.hasVariants) {
    // منطق قبلی برای محصولات ساده
    const status = product.currentStock > 0 
      ? ProductStatus.ACTIVE 
      : ProductStatus.OUT_OF_STOCK;
      
    await this.productRepository.update(productId, { status });
    return;
  }
  
  // برای محصولات با Variant
  const hasStockInAnyVariant = product.variants.some(v => 
    v.isActive && v.currentStock > 0
  );
  
  const status = hasStockInAnyVariant 
    ? ProductStatus.ACTIVE 
    : ProductStatus.OUT_OF_STOCK;
    
  await this.productRepository.update(productId, { status });
}
```

### 4. Stock Transaction (رهگیری تغییرات موجودی)

برای Audit Trail کامل:

```typescript
@Entity('stock_transactions')
class StockTransaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;
  
  @Column({ type: 'uuid' })
  productId: string;
  
  @Column({ type: 'uuid', nullable: true })
  variantId: string;  // ✨ اگر محصول Variant دارد
  
  @Column({
    type: 'enum',
    enum: TransactionType,
  })
  type: TransactionType;  // IN, OUT, ADJUSTMENT, RETURN
  
  @Column({ type: 'decimal', precision: 15, scale: 3 })
  quantity: number;  // + یا -
  
  @Column({ type: 'decimal', precision: 15, scale: 3 })
  balanceBefore: number;
  
  @Column({ type: 'decimal', precision: 15, scale: 3 })
  balanceAfter: number;
  
  @Column({ type: 'varchar', length: 100, nullable: true })
  reference: string;  // شماره فاکتور، رسید و ...
  
  @Column({ type: 'text', nullable: true })
  notes: string;
  
  @CreateDateColumn()
  createdAt: Date;
  
  @Column({ type: 'uuid' })
  createdBy: string;
}

enum TransactionType {
  PURCHASE = 'purchase',        // خرید
  SALE = 'sale',                // فروش
  RETURN = 'return',            // مرجوعی
  ADJUSTMENT = 'adjustment',    // تعدیل
  INITIAL = 'initial',          // موجودی اولیه
  DAMAGE = 'damage',            // ضایعات
  TRANSFER = 'transfer',        // انتقال (اگر چند انبار داشتیم)
}
```

این سیستم اطمینان می‌دهد که:
- ✅ هیچ تغییر موجودی از دست نمی‌رود
- ✅ می‌توان History کامل را دید
- ✅ Audit و بررسی ممکن است
- ✅ با سیستم فاکتورها ادغام شده

---

## 🎯 پاسخ به سوالات شما

### ✅ سوال 1: سیستم انبارداری به هم نمی‌ریزد؟

**پاسخ:** خیر! با اضافه کردن `variantId` به `InvoiceItem`:
```typescript
// قبل (محصولات ساده):
InvoiceItem → productId → Product.currentStock

// بعد (با Variant):
InvoiceItem → productId + variantId → ProductVariant.currentStock
                                   → Product.totalStock (محاسبه‌ای)
```

**مزایا:**
- موجودی هر Variant مجزا مدیریت می‌شود
- رهگیری دقیق: چه Variantی فروخته شد
- History کامل در `StockTransaction`
- محصولات قدیمی (بدون Variant) همچنان کار می‌کنند

### ✅ سوال 2: تک داده‌ای vs چندداده‌ای

**پاسخ:** دقیقاً درست گفتید! با `AttributeCardinality`:

```typescript
// مثال 1: تک داده‌ای
{
  name: "سایز",
  cardinality: SINGLE,
  value: "L"  // فقط یک مقدار
}

// مثال 2: چند داده‌ای
{
  name: "جنس",
  cardinality: MULTIPLE,
  value: ["پنبه", "پلی‌استر"]  // چند مقدار
}

// مثال 3: رنگ‌های ترکیبی
{
  name: "رنگ",
  cardinality: MULTIPLE,
  value: ["#000000", "#FF0000"]  // مشکی + قرمز
}
```

**در دیتابیس:**
```typescript
// ProductVariant.attributes (JSONB)
{
  "size": "L",                        // تک مقداره
  "colors": ["#0000FF", "#FFFFFF"],   // چند مقداره
  "material": ["cotton", "polyester"] // چند مقداره
}
```

### ✅ سوال 3: ویژگی ثابت vs متغیر

**پاسخ:** با `AttributeScope` حل شد:

```
PRODUCT_LEVEL (ثابت):
├─ ذخیره در: ProductAttributeValue
├─ برای همه Variantها یکسان
└─ مثال: جنس=پنبه، برند=Nike

VARIANT_LEVEL (متغیر):
├─ ذخیره در: ProductVariant.attributes
├─ در هر Variant متفاوت
└─ مثال: سایز، رنگ
```

**مثال کامل:**
```json
// Product
{
  "id": "prod-123",
  "name": "تی‌شرت",
  "hasVariants": true,
  "attributeValues": [
    {
      "attribute": "material",  // ثابت
      "value": "cotton"
    },
    {
      "attribute": "brand",     // ثابت
      "value": "Nike"
    }
  ]
}

// Variants
{
  "id": "var-1",
  "productId": "prod-123",
  "attributes": {
    "size": "L",      // متغیر
    "color": "#0000FF" // متغیر
  },
  "currentStock": 10
}
```

---

## ✅ مزایای این معماری

### 1️⃣ **انعطاف‌پذیری کامل**
- کاربر می‌تواند هر ویژگی دلخواهی تعریف کند
- تک یا چند داده‌ای
- ثابت یا متغیر
- نوع داده دلخواه

### 2️⃣ **مقیاس‌پذیری**
- برای هزاران Variant مناسب
- Index مناسب روی JSONB
- Query بهینه

### 3️⃣ **مدیریت موجودی دقیق**
- موجودی مستقل برای هر Variant
- محاسبه خودکار موجودی کل
- رهگیری کامل تغییرات

### 4️⃣ **ادغام با سیستم فاکتورها**
- `variantId` در InvoiceItem
- Snapshot ویژگی‌ها (تاریخچه محفوظ)
- Stock Transaction برای Audit

### 5️⃣ **سازگاری با گذشته**
- محصولات قدیمی (hasVariants=false) همچنان کار می‌کنند
- Migration تدریجی ممکن است
- بدون Breaking Changes

### 6️⃣ **گزارش‌دهی قوی**
- گزارش به تفکیک Variant
- تحلیل فروش براساس ویژگی‌ها
- پیش‌بینی نیاز

---

## 🚨 نکات مهم پیاده‌سازی

### 1. Transaction Management
```typescript
// همه عملیات موجودی باید در Transaction
async sellProduct(invoiceItem: CreateInvoiceItemDto) {
  return await this.dataSource.transaction(async (manager) => {
    // 1. Check stock
    const variant = await manager.findOne(ProductVariant, {
      where: { id: invoiceItem.variantId },
      lock: { mode: 'pessimistic_write' }  // Lock برای جلوگیری از Over-selling
    });
    
    if (variant.currentStock < invoiceItem.quantity) {
      throw new Error('Insufficient stock');
    }
    
    // 2. Create invoice item
    await manager.save(InvoiceItem, invoiceItem);
    
    // 3. Update stock
    variant.currentStock -= invoiceItem.quantity;
    await manager.save(variant);
    
    // 4. Log transaction
    await manager.save(StockTransaction, {
      variantId: variant.id,
      type: TransactionType.SALE,
      quantity: -invoiceItem.quantity,
      balanceBefore: variant.currentStock + invoiceItem.quantity,
      balanceAfter: variant.currentStock,
    });
    
    // 5. Update totals
    await this.updateTotalStock(variant.productId, manager);
  });
}
```

### 2. Index Strategy
```sql
-- ProductAttribute
CREATE INDEX idx_product_attribute_business ON product_attributes(business_id);
CREATE INDEX idx_product_attribute_code ON product_attributes(code);
CREATE INDEX idx_product_attribute_scope ON product_attributes(scope);

-- ProductVariant
CREATE INDEX idx_product_variant_product ON product_variants(product_id);
CREATE INDEX idx_product_variant_sku ON product_variants(sku);
CREATE INDEX idx_product_variant_status ON product_variants(status);
CREATE INDEX idx_product_variant_attributes ON product_variants USING GIN (attributes);

-- InvoiceItem
CREATE INDEX idx_invoice_item_variant ON invoice_items(variant_id);

-- StockTransaction
CREATE INDEX idx_stock_transaction_variant ON stock_transactions(variant_id);
CREATE INDEX idx_stock_transaction_date ON stock_transactions(created_at);
```

### 3. Validation Rules
```typescript
// قبل از ایجاد Variant
async validateVariant(dto: CreateVariantDto) {
  // 1. Check duplicate SKU
  const existing = await this.variantRepository.findOne({
    where: { sku: dto.sku }
  });
  if (existing) throw new Error('SKU already exists');
  
  // 2. Check attributes match product's variant-level attributes
  const product = await this.productRepository.findOne({
    where: { id: dto.productId },
    relations: ['attributeValues', 'attributeValues.attribute']
  });
  
  // 3. Validate attribute values
  for (const [key, value] of Object.entries(dto.attributes)) {
    const attr = await this.attributeRepository.findOne({
      where: { code: key }
    });
    
    if (!attr) throw new Error(`Attribute ${key} not found`);
    if (attr.scope !== AttributeScope.VARIANT_LEVEL) {
      throw new Error(`Attribute ${key} is not variant-level`);
    }
    
    // Validate cardinality
    if (attr.cardinality === AttributeCardinality.SINGLE) {
      if (Array.isArray(value)) {
        throw new Error(`Attribute ${key} should be single value`);
      }
    }
    
    // Validate options
    if (attr.options && !attr.allowCustomValue) {
      const validValues = attr.options.map(o => o.value);
      const valuesToCheck = Array.isArray(value) ? value : [value];
      for (const v of valuesToCheck) {
        if (!validValues.includes(v)) {
          throw new Error(`Invalid value for ${key}`);
        }
      }
    }
  }
}
```

---

## 🔌 API Endpoints پیشنهادی

### Attributes Management

```
POST   /api/products/attributes              // ایجاد ویژگی جدید
GET    /api/products/attributes              // لیست ویژگی‌ها
GET    /api/products/attributes/:id          // جزئیات یک ویژگی
PUT    /api/products/attributes/:id          // ویرایش ویژگی
DELETE /api/products/attributes/:id          // حذف ویژگی
PATCH  /api/products/attributes/:id/toggle   // فعال/غیرفعال کردن
```

### Product Variants

```
POST   /api/products/:id/variants                    // ایجاد Variant جدید
GET    /api/products/:id/variants                    // لیست Variants یک محصول
GET    /api/products/:id/variants/:variantId         // جزئیات یک Variant
PUT    /api/products/:id/variants/:variantId         // ویرایش Variant
DELETE /api/products/:id/variants/:variantId         // حذف Variant
PATCH  /api/products/:id/variants/:variantId/stock   // به‌روزرسانی موجودی
POST   /api/products/:id/variants/bulk-create        // ایجاد چند Variant همزمان
```

### Inventory Management

```
GET    /api/products/:id/inventory           // گزارش کامل موجودی (همه Variants)
POST   /api/products/:id/recalculate-stock   // بازمحاسبه موجودی کل
GET    /api/products/variants/low-stock      // Variantهای با موجودی کم
```

---

## 📱 رابط کاربری (UI/UX) پیشنهادی

### صفحه تنظیمات ویژگی‌ها

```
┌─────────────────────────────────────────┐
│ 🎨 مدیریت ویژگی‌های محصولات           │
├─────────────────────────────────────────┤
│                                         │
│ [➕ ویژگی جدید]                        │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📏 سایز                  [✏️] [🗑️] │ │
│ │ نوع: انتخابی                        │ │
│ │ مقادیر: S, M, L, XL, XXL            │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 🎨 رنگ                   [✏️] [🗑️] │ │
│ │ نوع: رنگ                            │ │
│ │ مقادیر: [🔵] [🔴] [⚪] [⚫]        │ │
│ └─────────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

### صفحه ایجاد/ویرایش محصول با Variants

```
┌─────────────────────────────────────────┐
│ نام محصول: تی‌شرت                       │
│ قیمت پایه: 150,000 ریال                 │
│                                         │
│ ☑️ این محصول دارای تنوع است            │
│                                         │
│ ویژگی‌های انتخاب شده:                  │
│ [x] سایز  [x] رنگ  [ ] جنس             │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📦 تنوع‌های محصول (5 مورد)          │ │
│ ├─────────────────────────────────────┤ │
│ │                                     │ │
│ │ Variant 1:  S  |  آبی   | موجودی: 5│ │
│ │ Variant 2:  M  |  آبی   | موجودی: 10│ │
│ │ Variant 3:  L  |  آبی   | موجودی: 3│ │
│ │ Variant 4:  S  |  قرمز  | موجودی: 8│ │
│ │ Variant 5:  M  |  قرمز  | موجودی: 0│ │
│ │                                     │ │
│ │ [➕ افزودن تنوع جدید]               │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ 📊 موجودی کل: 26 عدد                   │
│                                         │
└─────────────────────────────────────────┘
```

### صفحه فروش (انتخاب Variant)

```
محصول: تی‌شرت
┌─────────────────────────────────────────┐
│ سایز را انتخاب کنید:                   │
│ ( ) S    ( ) M    (•) L    ( ) XL      │
│                                         │
│ رنگ را انتخاب کنید:                    │
│ ( ) 🔵 آبی   (•) 🔴 قرمز  ( ) ⚪ سفید │
│                                         │
│ ─────────────────────────────────────── │
│ انتخاب شما: L - قرمز                   │
│ موجودی: 7 عدد                          │
│ قیمت: 160,000 ریال                     │
│                                         │
│           [✅ افزودن به فاکتور]        │
└─────────────────────────────────────────┘
```

---

## ✅ مزایای این معماری

1. **انعطاف‌پذیری کامل**: کاربر می‌تواند هر ویژگی دلخواهی تعریف کند
2. **مقیاس‌پذیر**: برای هزاران Variant مناسب است
3. **مدیریت موجودی دقیق**: موجودی هر ترکیب جداگانه مدیریت می‌شود
4. **محاسبات خودکار**: موجودی کل و وضعیت‌ها خودکار به‌روز می‌شوند
5. **قیمت‌گذاری انعطاف‌پذیر**: امکان قیمت متفاوت برای هر Variant
6. **گزارش‌دهی قوی**: می‌توان گزارشات تفصیلی از موجودی و فروش گرفت
7. **سازگاری**: با سیستم فعلی کاملاً سازگار است

---

## 🚀 مراحل پیاده‌سازی

### Phase 1: Database & Entities (Backend)
1. ✨ ایجاد Entity: `ProductAttribute` (تعریف ویژگی‌ها)
2. ✨ ایجاد Entity: `ProductAttributeValue` (ویژگی‌های ثابت محصول)
3. ✨ ایجاد Entity: `ProductVariant` (ترکیبات محصول)
4. ✨ ایجاد Entity: `StockTransaction` (رهگیری موجودی)
5. ✨ به‌روزرسانی Entity: `Product` (اضافه کردن hasVariants, totalStock)
6. ✨ به‌روزرسانی Entity: `InvoiceItem` (اضافه کردن variantId, variantSnapshot)
7. ✨ ایجاد Migrations

### Phase 2: Backend Services
1. ✨ Module: `product-attributes`
   - AttributesService (CRUD ویژگی‌ها)
   - AttributesController
   - DTOs و Validation

2. ✨ Module: `product-variants`
   - VariantsService (CRUD Variants)
   - VariantsController
   - Bulk Create Variants

3. ✨ Stock Management Service
   - محاسبه موجودی کل (updateTotalStock)
   - محاسبه وضعیت Variant
   - محاسبه وضعیت محصول
   - ثبت StockTransaction

4. ✨ به‌روزرسانی Invoice Service
   - پشتیبانی از variantId
   - ذخیره variantSnapshot
   - کسر موجودی از Variant

### Phase 3: API Endpoints
```
Attributes:
  POST   /api/products/attributes
  GET    /api/products/attributes
  GET    /api/products/attributes/:id
  PUT    /api/products/attributes/:id
  DELETE /api/products/attributes/:id
  PATCH  /api/products/attributes/:id/toggle

Variants:
  POST   /api/products/:id/variants
  GET    /api/products/:id/variants
  GET    /api/products/:id/variants/:variantId
  PUT    /api/products/:id/variants/:variantId
  DELETE /api/products/:id/variants/:variantId
  PATCH  /api/products/:id/variants/:variantId/stock
  POST   /api/products/:id/variants/bulk-create
  POST   /api/products/:id/variants/generate  // پیشنهاد ترکیبات

Stock:
  GET    /api/products/:id/inventory
  POST   /api/products/:id/recalculate-stock
  GET    /api/variants/low-stock
  GET    /api/stock-transactions
```

### Phase 4: Frontend (Flutter)
1. ✨ صفحه مدیریت ویژگی‌ها
   - لیست ویژگی‌ها
   - افزودن/ویرایش ویژگی
   - تنظیمات (DataType, Cardinality, Scope)

2. ✨ صفحه ایجاد/ویرایش محصول
   - Toggle "این محصول Variant دارد"
   - اضافه کردن ویژگی‌های ثابت
   - انتخاب ویژگی‌های متغیر

3. ✨ صفحه مدیریت Variants
   - لیست Variants محصول
   - افزودن Variant دستی
   - ایجاد خودکار ترکیبات
   - ویرایش موجودی و قیمت
   - آپلود تصویر

4. ✨ صفحه فروش (Invoice)
   - انتخاب محصول
   - اگر hasVariants: نمایش انتخابگر Variant
   - نمایش موجودی Variant
   - اضافه به فاکتور

5. ✨ صفحه گزارش موجودی
   - موجودی به تفکیک Variant
   - Variantهای کم‌موجود
   - تاریخچه تغییرات

### Phase 5: Testing & Optimization
1. ✨ Unit Tests
   - AttributesService
   - VariantsService
   - StockService

2. ✨ Integration Tests
   - ایجاد محصول با Variants
   - فروش و کسر موجودی
   - محاسبات خودکار

3. ✨ Performance Tests
   - Query optimization
   - Index verification
   - Load testing

4. ✨ Documentation
   - API Documentation
   - User Guide
   - Developer Guide

---

## ❓ سوالات نهایی برای تایید

### 1️⃣ معماری و طراحی
- ✅ آیا تفکیک ویژگی‌های **ثابت** (Product-level) و **متغیر** (Variant-level) درست است؟
- ✅ آیا پشتیبانی از ویژگی‌های **چند مقداره** (مثل: جنس = ["پنبه", "پلی‌استر"]) نیاز دارید؟
- ✅ آیا نیاز به **تصویر جداگانه** برای هر Variant هست؟

### 2️⃣ قیمت‌گذاری
- ✅ آیا هر Variant می‌تواند **قیمت متفاوت** داشته باشد؟
- ✅ یا فقط **تفاوت قیمت** (±) با محصول اصلی ذخیره شود؟
- **پیشنهاد:** هر دو گزینه پشتیبانی شود (priceAdjustment یا salePrice مطلق)

### 3️⃣ موجودی و انبارداری
- ✅ آیا فعلاً **یک انبار** کافی است؟ (بعداً می‌توان چند انبار اضافه کرد)
- ✅ آیا نیاز به **نقطه سفارش مجدد** (reorderPoint) برای هر Variant هست؟
- ✅ آیا نیاز به **هشدار موجودی کم** (Low Stock Alert) هست؟

### 4️⃣ کاربری و UI
- ✅ آیا در فرم فروش، کاربر باید **همه ویژگی‌ها را ببیند** یا فقط Variantهای آماده انتخاب کند؟
- **پیشنهاد:** هر دو روش:
  - روش A: لیست Variantهای آماده (سریع‌تر)
  - روش B: انتخاب ویژگی‌ها و پیدا کردن Variant (کاربرپسندتر)

### 5️⃣ ویژگی‌های اضافی
- ❓ آیا نیاز به **Import/Export Excel** برای Variants هست؟
- ❓ آیا نیاز به **کپی کردن** یک Variant به Variant دیگر هست؟
- ❓ آیا نیاز به **تاریخچه تغییر قیمت** Variant هست؟
- ❓ آیا نیاز به **تخفیف گروهی** روی Variantهای خاص هست؟

### 6️⃣ گزارش‌ها
- ✅ گزارش موجودی به تفکیک Variant
- ✅ گزارش فروش به تفکیک Variant
- ✅ Variantهای پرفروش / کم‌فروش
- ❓ گزارش سود به تفکیک Variant؟

### 7️⃣ محصولات فعلی
- ✅ آیا می‌خواهید محصولات فعلی **به صورت دستی** به Variant تبدیل شوند؟
- ✅ یا **خودکار** تبدیل شوند (یک Variant با موجودی فعلی)؟
- **پیشنهاد:** دستی، چون ممکن است کاربر بخواهد ویژگی‌ها را تنظیم کند

---

## 📝 توصیه‌های نهایی

### ✅ شروع با MVP (حداقل محصول قابل ارائه)
برای شروع سریع، پیشنهاد می‌کنم اول این ویژگی‌ها را پیاده کنیم:

**Phase 1 (MVP):**
1. تعریف ویژگی‌های ساده (فقط SELECT, TEXT)
2. تفکیک Product-level / Variant-level
3. ایجاد Variants دستی
4. موجودی مستقل هر Variant
5. انتخاب Variant در فروش
6. محاسبه موجودی کل

**Phase 2 (Enhanced):**
1. پشتیبانی از COLOR, NUMBER, DATE
2. ویژگی‌های چند مقداره (MULTIPLE)
3. ایجاد خودکار Variants
4. تصاویر اختصاصی Variant
5. StockTransaction برای Audit

**Phase 3 (Advanced):**
1. Import/Export Excel
2. گزارش‌های پیشرفته
3. پیش‌بینی نیاز
4. چند انبار (اگر نیاز بود)

### 🎯 مزیت این رویکرد
- شروع سریع (MVP در 1-2 هفته)
- Feedback زود هنگام از کاربران
- امکان تغییر طراحی در صورت نیاز
- کاهش ریسک

---

## 🔥 آماده شروع!

اگر این تحلیل با نیازتان **مطابقت دارد** و **سوالات بالا را پاسخ دادید**، می‌توانیم **فوراً شروع کنیم**:

### گام بعدی:
1. ✅ **تایید نهایی** این سند
2. 🔨 شروع **Phase 1: Entities & Migrations**
3. 🚀 پیاده‌سازی **Backend Services**
4. 📱 پیاده‌سازی **Flutter UI**
5. 🧪 تست و بهینه‌سازی

**زمان تخمینی Phase 1 (MVP):** 7-10 روز کاری

---

💬 **منتظر تایید شما هستم!** لطفاً بگویید:
- آیا این طراحی را تایید می‌کنید?
- آیا پاسخ سوالات بالا را دارید؟
- آیا می‌خواهید از MVP شروع کنیم یا مستقیم Full Version؟

