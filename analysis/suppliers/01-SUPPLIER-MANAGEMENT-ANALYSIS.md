# 🤝 تحلیل سیستم مدیریت تامین‌کنندگان (Supplier Management)

> **تاریخ:** 2 دسامبر 2025  
> **وضعیت:** 📋 در انتظار تایید  
> **ویژگی کلیدی:** پشتیبانی از B2B Marketplace

---

## 📌 خلاصه اجرایی

### 🎯 اهداف ماژول
1. **مدیریت جامع تامین‌کنندگان**: ثبت و نگهداری کامل اطلاعات تامین‌کنندگان (حقیقی/حقوقی)
2. **پیوند محصول-تامین‌کننده**: اتصال محصولات و تنوع‌ها به تامین‌کنندگان با قیمت خرید
3. **B2B Marketplace**: امکان اشتراک‌گذاری کاتالوگ محصولات بین کسب‌وکارها
4. **یکپارچگی با خرید**: آماده‌سازی برای سیستم سفارش خرید (Purchase Order)
5. **تحلیل عملکرد**: ارزیابی کیفیت، قیمت و زمان‌بندی تحویل

### 💡 نوآوری کلیدی: B2B Connection

```
┌─────────────────────────────────────────────────────────┐
│  مرحله 1: ثبت به عنوان تامین‌کننده خارجی              │
│  Business A: "فروشگاه من"                              │
│  └─> Supplier: "شرکت پخش XYZ" (اطلاعات دستی)          │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  مرحله 2: تامین‌کننده در هایورک ثبت‌نام می‌کند         │
│  "شرکت پخش XYZ" → Business در سیستم می‌شود            │
│  businessId: xyz-business-uuid                          │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  مرحله 3: اتصال و همگام‌سازی (B2B Link)                │
│  Supplier.linkedBusinessId = xyz-business-uuid          │
│  └─> دسترسی به کاتالوگ واقعی محصولات                  │
│  └─> قیمت‌های به‌روز خودکار                            │
│  └─> سفارش خرید مستقیم در سیستم                        │
└─────────────────────────────────────────────────────────┘
```

**مزایای B2B:**
- ✅ حذف ورود دستی محصولات
- ✅ قیمت‌گذاری یکپارچه و به‌روز
- ✅ کاهش خطای انسانی
- ✅ سفارش‌گذاری سریع‌تر
- ✅ پیگیری هوشمند موجودی

---

## 🎭 نقش‌ها و سطوح دسترسی

| نقش | مجوزهای دسترسی | موارد استفاده |
|-----|----------------|----------------|
| **Business Owner** | ایجاد، ویرایش، حذف، تایید تامین‌کننده | مدیریت کامل |
| **Procurement Manager** | مشاهده، ویرایش، ثبت سفارش | خرید و تدارکات |
| **Inventory Manager** | مشاهده تامین‌کننده، لینک به محصول | مدیریت موجودی |
| **Finance** | مشاهده، پرداخت، بدهی | مالی و حسابداری |
| **Employee** | مشاهده فقط (محدود) | کارکنان عملیاتی |

---

## 🗄️ طراحی Database Schema

### 1️⃣ Suppliers Table (جدول اصلی تامین‌کنندگان)

```typescript
@Entity('suppliers')
@Index(['businessId', 'status'])
@Index(['businessId', 'code'], { unique: true })
@Index(['linkedBusinessId'], { where: 'linkedBusinessId IS NOT NULL' })
export class Supplier {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // ─────────────── Tenant Isolation ─────────────── //
  @Column({ type: 'uuid' })
  @Index()
  businessId: string; // کسب‌وکاری که این تامین‌کننده را ثبت کرده

  @ManyToOne(() => Business, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'businessId' })
  business: Business;

  // ─────────────── B2B Integration ─────────────── //
  @Column({ type: 'uuid', nullable: true })
  @Index()
  linkedBusinessId: string; // اگر این تامین‌کننده خودش Business داشته باشد

  @ManyToOne(() => Business, { nullable: true })
  @JoinColumn({ name: 'linkedBusinessId' })
  linkedBusiness: Business;

  @Column({ type: 'boolean', default: false })
  isLinkedBusiness: boolean; // آیا به Business متصل شده؟

  @Column({ type: 'timestamp', nullable: true })
  linkedAt: Date; // تاریخ اتصال

  // ─────────────── Basic Info ─────────────── //
  @Column({ type: 'varchar', length: 50, unique: true })
  code: string; // کد تامین‌کننده (AUTO: SUP-00001)

  @Column({ type: 'varchar', length: 200 })
  name: string; // نام تجاری/نمایشی (قابل تغییر توسط خریدار)

  @Column({ type: 'varchar', length: 200, nullable: true })
  legalName: string; // نام رسمی/حقوقی کامل

  @Column({
    type: 'enum',
    enum: SupplierType,
    default: SupplierType.DISTRIBUTOR,
  })
  type: SupplierType;

  @Column({
    type: 'enum',
    enum: SupplierStatus,
    default: SupplierStatus.DRAFT,
  })
  status: SupplierStatus;

  // ─────────────── Legal IDs ─────────────── //
  @Column({ type: 'varchar', length: 20, nullable: true })
  taxId: string; // شناسه مالیاتی

  @Column({ type: 'varchar', length: 20, nullable: true })
  nationalId: string; // کد ملی (اشخاص حقیقی)

  @Column({ type: 'varchar', length: 20, nullable: true })
  registrationNumber: string; // شماره ثبت (اشخاص حقوقی)

  @Column({ type: 'varchar', length: 20, nullable: true })
  economicCode: string; // کد اقتصادی

  // ─────────────── Contact Info ─────────────── //
  @Column({ type: 'varchar', length: 20, nullable: true })
  phone: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  email: string;

  @Column({ type: 'varchar', length: 500, nullable: true })
  website: string;

  @Column({ type: 'text', nullable: true })
  address: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  city: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  province: string;

  @Column({ type: 'varchar', length: 20, nullable: true })
  postalCode: string;

  @Column({ type: 'varchar', length: 100, default: 'Iran' })
  country: string;

  // ─────────────── Business Terms ─────────────── //
  @Column({ type: 'varchar', length: 3, default: 'IRR' })
  currency: string; // ارز پیش‌فرض: IRR, USD, EUR

  @Column({ type: 'integer', default: 0 })
  paymentTermDays: number; // مهلت پرداخت (روز)

  @Column({ type: 'varchar', length: 50, nullable: true })
  paymentTermType: string; // Net30, Net60, Prepaid, COD

  @Column({ type: 'integer', default: 7 })
  defaultLeadTimeDays: number; // زمان آماده‌سازی پیش‌فرض

  @Column({ type: 'varchar', length: 50, nullable: true })
  incoterm: string; // EXW, FOB, CIF, DDP

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  creditLimit: number; // سقف اعتبار

  // ─────────────── Performance Metrics ─────────────── //
  @Column({ type: 'decimal', precision: 3, scale: 2, default: 0 })
  qualityRating: number; // 0.00 - 5.00

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 100 })
  onTimeDeliveryRate: number; // درصد تحویل به‌موقع

  @Column({ type: 'integer', default: 0 })
  totalOrders: number; // تعداد کل سفارشات

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  totalPurchaseAmount: number; // مجموع خرید

  @Column({ type: 'timestamp', nullable: true })
  lastOrderDate: Date; // آخرین سفارش

  @Column({ type: 'timestamp', nullable: true })
  lastPaymentDate: Date; // آخرین پرداخت

  // ─────────────── Financial ─────────────── //
  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  currentDebt: number; // بدهی فعلی

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  totalPaid: number; // مجموع پرداختی

  // ─────────────── Additional Info ─────────────── //
  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'text', nullable: true })
  notes: string; // یادداشت‌های داخلی

  @Column({ type: 'simple-array', nullable: true })
  tags: string[]; // تگ‌های دسته‌بندی

  @Column({ type: 'varchar', length: 100, nullable: true })
  industry: string; // صنعت: textile, food, electronics

  @Column({ type: 'jsonb', nullable: true })
  customFields: Record<string, any>; // فیلدهای اختصاصی

  // ─────────────── Approval Workflow ─────────────── //
  @Column({ type: 'date', nullable: true })
  onboardingDate: Date; // تاریخ شروع همکاری

  @Column({ type: 'timestamp', nullable: true })
  approvedAt: Date;

  @Column({ type: 'uuid', nullable: true })
  approvedBy: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'approvedBy' })
  approver: User;

  // ─────────────── Relations ─────────────── //
  @OneToMany(() => SupplierContact, contact => contact.supplier)
  contacts: SupplierContact[];

  @OneToMany(() => SupplierProduct, sp => sp.supplier)
  products: SupplierProduct[];

  @OneToMany(() => SupplierDocument, doc => doc.supplier)
  documents: SupplierDocument[];

  // ─────────────── Timestamps ─────────────── //
  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  deletedAt: Date; // Soft delete
}

// ─────────────── Enums ─────────────── //
export enum SupplierType {
  MANUFACTURER = 'manufacturer',      // تولیدکننده
  DISTRIBUTOR = 'distributor',        // توزیع‌کننده
  WHOLESALER = 'wholesaler',          // عمده‌فروش
  IMPORTER = 'importer',              // واردکننده
  SERVICE_PROVIDER = 'service',       // ارائه‌دهنده خدمات
  FREELANCER = 'freelancer',          // فریلنسر
  OTHER = 'other',
}

export enum SupplierStatus {
  DRAFT = 'draft',                    // پیش‌نویس
  PENDING_REVIEW = 'pending',         // در انتظار بررسی
  APPROVED = 'approved',              // تایید شده
  SUSPENDED = 'suspended',            // معلق
  BLOCKED = 'blocked',                // مسدود
  ARCHIVED = 'archived',              // بایگانی شده
}
```

---

### 2️⃣ Supplier Contacts (مخاطبین تامین‌کننده)

```typescript
@Entity('supplier_contacts')
@Index(['supplierId'])
export class SupplierContact {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  supplierId: string;

  @ManyToOne(() => Supplier, supplier => supplier.contacts, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'supplierId' })
  supplier: Supplier;

  @Column({ type: 'varchar', length: 100 })
  fullName: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  position: string; // سمت: مدیر فروش، مدیر مالی

  @Column({ type: 'varchar', length: 20, nullable: true })
  phone: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  email: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  whatsapp: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  telegram: string;

  @Column({
    type: 'enum',
    enum: ContactRole,
    default: ContactRole.GENERAL,
  })
  role: ContactRole;

  @Column({ type: 'boolean', default: false })
  isPrimary: boolean; // مخاطب اصلی

  @Column({ type: 'boolean', default: true })
  isActive: boolean;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

export enum ContactRole {
  GENERAL = 'general',
  SALES = 'sales',
  SUPPORT = 'support',
  FINANCE = 'finance',
  TECHNICAL = 'technical',
}
```

---

### 3️⃣ Supplier Products (پیوند محصول-تامین‌کننده)

```typescript
@Entity('supplier_products')
@Index(['supplierId', 'productVariantId'], { unique: true })
@Index(['supplierId', 'isPreferred'])
export class SupplierProduct {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // ─────────────── Relations ─────────────── //
  @Column({ type: 'uuid' })
  supplierId: string;

  @ManyToOne(() => Supplier, supplier => supplier.products, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'supplierId' })
  supplier: Supplier;

  @Column({ type: 'uuid', nullable: true })
  productId: string; // محصول اصلی (اختیاری)

  @ManyToOne(() => Product, { nullable: true })
  @JoinColumn({ name: 'productId' })
  product: Product;

  @Column({ type: 'uuid' })
  productVariantId: string; // تنوع محصول (اجباری)

  @ManyToOne(() => ProductVariant, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'productVariantId' })
  productVariant: ProductVariant;

  // ─────────────── Supplier Product Info ─────────────── //
  @Column({ type: 'varchar', length: 100, nullable: true })
  supplierSku: string; // کد محصول نزد تامین‌کننده

  @Column({ type: 'varchar', length: 200, nullable: true })
  supplierProductName: string; // نام محصول نزد تامین‌کننده

  // ─────────────── Pricing ─────────────── //
  @Column({ type: 'decimal', precision: 15, scale: 2 })
  purchasePrice: number; // قیمت خرید فعلی

  @Column({ type: 'varchar', length: 3, default: 'IRR' })
  currency: string;

  @Column({ type: 'date', nullable: true })
  priceValidUntil: Date; // اعتبار قیمت تا

  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  previousPrice: number; // قیمت قبلی (برای مقایسه)

  @Column({ type: 'timestamp', nullable: true })
  lastPriceUpdate: Date;

  // ─────────────── Order Terms ─────────────── //
  @Column({ type: 'decimal', precision: 15, scale: 3, default: 1 })
  minOrderQuantity: number; // حداقل سفارش (MOQ)

  @Column({ type: 'decimal', precision: 15, scale: 3, nullable: true })
  orderMultiple: number; // مضرب سفارش (مثلاً 12 تایی)

  @Column({ type: 'integer', default: 7 })
  leadTimeDays: number; // زمان آماده‌سازی (روز)

  @Column({ type: 'varchar', length: 200, nullable: true })
  packagingInfo: string; // اطلاعات بسته‌بندی

  // ─────────────── Preference & Status ─────────────── //
  @Column({ type: 'boolean', default: false })
  isPreferred: boolean; // تامین‌کننده ترجیحی؟

  @Column({ type: 'integer', default: 1 })
  priority: number; // اولویت (1 = اول)

  @Column({ type: 'boolean', default: true })
  isActive: boolean; // فعال بودن

  @Column({ type: 'date', nullable: true })
  discontinuedDate: Date; // تاریخ قطع همکاری

  // ─────────────── Performance ─────────────── //
  @Column({ type: 'decimal', precision: 3, scale: 2, default: 0 })
  qualityScore: number; // امتیاز کیفیت (0-5)

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 100 })
  fulfillmentRate: number; // نرخ تأمین به‌موقع

  @Column({ type: 'integer', default: 0 })
  totalOrdered: number; // تعداد کل سفارش

  @Column({ type: 'timestamp', nullable: true })
  lastOrderDate: Date;

  // ─────────────── Additional Info ─────────────── //
  @Column({ type: 'text', nullable: true })
  notes: string;

  @Column({ type: 'jsonb', nullable: true })
  specifications: Record<string, any>; // مشخصات فنی

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

---

### 4️⃣ Supplier Documents (مدارک تامین‌کننده)

```typescript
@Entity('supplier_documents')
@Index(['supplierId', 'documentType'])
export class SupplierDocument {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  supplierId: string;

  @ManyToOne(() => Supplier, supplier => supplier.documents, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'supplierId' })
  supplier: Supplier;

  @Column({
    type: 'enum',
    enum: DocumentType,
  })
  documentType: DocumentType;

  @Column({ type: 'varchar', length: 200 })
  title: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  documentNumber: string; // شماره سند

  @Column({ type: 'varchar', length: 500 })
  filePath: string; // مسیر فایل در Storage

  @Column({ type: 'varchar', length: 200 })
  fileName: string;

  @Column({ type: 'varchar', length: 50 })
  mimeType: string;

  @Column({ type: 'integer' })
  fileSize: number; // بایت

  @Column({ type: 'date', nullable: true })
  issueDate: Date; // تاریخ صدور

  @Column({ type: 'date', nullable: true })
  expiryDate: Date; // تاریخ انقضا

  @Column({
    type: 'enum',
    enum: DocumentStatus,
    default: DocumentStatus.PENDING,
  })
  status: DocumentStatus;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @Column({ type: 'uuid', nullable: true })
  uploadedBy: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'uploadedBy' })
  uploader: User;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

export enum DocumentType {
  CONTRACT = 'contract',              // قرارداد
  LICENSE = 'license',                // مجوز
  CERTIFICATE = 'certificate',        // گواهی
  INSURANCE = 'insurance',            // بیمه‌نامه
  TAX_DOCUMENT = 'tax',               // مدارک مالیاتی
  REGISTRATION = 'registration',      // ثبت‌نامه
  BANK_INFO = 'bank',                 // اطلاعات بانکی
  OTHER = 'other',
}

export enum DocumentStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  EXPIRED = 'expired',
}
```

---

## 🔄 چرخه عمر تامین‌کننده (Supplier Lifecycle)

```
1. DRAFT (پیش‌نویس)
   └─> ایجاد اولیه، وارد کردن اطلاعات پایه
   
2. PENDING_REVIEW (در انتظار بررسی)
   └─> بررسی مدارک، اطلاعات مالی و حقوقی
   └─> تماس با تامین‌کننده
   
3. APPROVED (تایید شده)
   └─> آماده برای سفارش خرید
   └─> اتصال محصولات
   └─> فعال در سیستم
   
4. SUSPENDED (معلق)
   └─> مشکل موقت (تأخیر، کیفیت)
   └─> غیرفعال موقت
   
5. BLOCKED (مسدود)
   └─> مشکل جدی
   └─> عدم پرداخت یا تخلف
   
6. ARCHIVED (بایگانی)
   └─> قطع همکاری
   └─> نگهداری تاریخچه
```

---

## 🔗 یکپارچگی‌ها (Integrations)

### 1️⃣ محصولات و موجودی
```typescript
// هنگام دریافت کالا
const receipt = {
  supplierId: 'supplier-uuid',
  productVariantId: 'variant-uuid',
  quantity: 100,
  purchasePrice: 50000,
  // سیستم به‌روزرسانی می‌کند:
  // - ProductVariant.currentStock
  // - SupplierProduct.lastOrderDate
  // - Supplier.totalOrders++
};
```

### 2️⃣ هزینه‌ها
```typescript
// ثبت خرید به عنوان هزینه
const expense = {
  categoryId: 'product-purchase-category',
  supplierId: 'supplier-uuid',
  amount: 5000000,
  referenceType: 'SUPPLIER_PAYMENT',
  // اتصال به ماژول Expense
};
```

### 3️⃣ B2B Marketplace
```typescript
// وقتی تامین‌کننده در سیستم ثبت‌نام می‌کند
async linkSupplierToBusiness(
  supplierId: string,
  linkedBusinessId: string
) {
  // 1. بروزرسانی Supplier
  supplier.linkedBusinessId = linkedBusinessId;
  supplier.isLinkedBusiness = true;
  supplier.linkedAt = new Date();
  
  // 2. اشتراک‌گذاری کاتالوگ
  const sharedCatalog = await catalogService.shareCatalog(
    linkedBusinessId,
    supplierId
  );
  
  // 3. همگام‌سازی قیمت‌ها
  await syncPricesFromLinkedBusiness(supplierId);
}
```

### 4️⃣ سفارش خرید (Phase 2)
```typescript
// ایجاد سفارش خرید
const purchaseOrder = {
  supplierId: 'supplier-uuid',
  items: [
    {
      productVariantId: 'variant-1',
      quantity: 50,
      unitPrice: 45000,
      // قیمت از SupplierProduct
    }
  ],
  status: 'PENDING',
};
```

---

## 📊 قوانین کسب‌وکار (Business Rules)

### ✅ قوانین اجباری

1. **تامین‌کننده باید حداقل یک مخاطب داشته باشد**
   ```typescript
   if (supplier.contacts.length === 0) {
     throw new Error('حداقل یک مخاطب الزامی است');
   }
   ```

2. **فقط تامین‌کنندگان APPROVED می‌توانند در سفارش خرید استفاده شوند**
   ```typescript
   if (supplier.status !== SupplierStatus.APPROVED) {
     throw new Error('تامین‌کننده باید تایید شده باشد');
   }
   ```

3. **کنترل سقف اعتبار**
   ```typescript
   if (supplier.currentDebt > supplier.creditLimit) {
     // هشدار به مدیر مالی
     await notifyFinanceManager(supplier);
   }
   ```

4. **هشدار انقضای قیمت**
   ```typescript
   if (supplierProduct.priceValidUntil < new Date()) {
     // قیمت منقضی شده، نیاز به بروزرسانی
     supplierProduct.needsPriceUpdate = true;
   }
   ```

5. **B2B: جلوگیری از تکرار اطلاعات**
   ```typescript
   // وقتی تامین‌کننده لینک می‌شود، اطلاعات از Business اصلی خوانده شود
   if (supplier.isLinkedBusiness) {
     const businessInfo = await getBusinessInfo(supplier.linkedBusinessId);
     // نمایش اطلاعات واقعی، نه اطلاعات دستی
   }
   ```

---

## 🎨 طراحی UI/UX

### صفحات اصلی

#### 1. لیست تامین‌کنندگان
```
┌────────────────────────────────────────────────────┐
│  🤝 تامین‌کنندگان                     [+ افزودن]   │
├────────────────────────────────────────────────────┤
│  🔍 [جستجو...]  📊 [وضعیت▼]  🏷️ [تگ▼]  🔄        │
├────────────────────────────────────────────────────┤
│                                                    │
│  ┌──────────────────────────────────────────────┐ │
│  │ 🟢 شرکت پخش آرین          SUP-00001         │ │
│  │ 📞 021-12345678  👤 3 مخاطب  📦 24 محصول    │ │
│  │ 💰 بدهی: 12,500,000 ریال                    │ │
│  │ ⭐ 4.5 | ✅ 95% تحویل به‌موقع                │ │
│  └──────────────────────────────────────────────┘ │
│                                                    │
│  ┌──────────────────────────────────────────────┐ │
│  │ 🔗 فروشگاه دیجی‌استایل    SUP-00002  [B2B]  │ │
│  │ 🏢 متصل به کسب‌وکار هایورک                  │ │
│  │ 📦 156 محصول مشترک                           │ │
│  │ 💰 سفارش اخیر: 3 روز پیش                    │ │
│  └──────────────────────────────────────────────┘ │
│                                                    │
└────────────────────────────────────────────────────┘
```

#### 2. جزئیات تامین‌کننده
```
┌────────────────────────────────────────────────────┐
│  ← بازگشت                                          │
│  📋 شرکت پخش آرین (SUP-00001)          [ویرایش]   │
├────────────────────────────────────────────────────┤
│  Tab: 📊 اطلاعات | 👥 مخاطبین | 📦 محصولات ...    │
├────────────────────────────────────────────────────┤
│                                                    │
│  🟢 تایید شده (Approved)                          │
│                                                    │
│  📌 اطلاعات پایه                                  │
│  ┌─────────────────────┬──────────────────────┐   │
│  │ نام: شرکت پخش آرین  │ نوع: توزیع‌کننده     │   │
│  │ کد اقتصادی: 123456  │ تلفن: 021-1234567   │   │
│  │ آدرس: تهران، ...    │                      │   │
│  └─────────────────────┴──────────────────────┘   │
│                                                    │
│  💰 اطلاعات مالی                                  │
│  ┌─────────────────────┬──────────────────────┐   │
│  │ بدهی: 12.5M ریال     │ سقف: 50M ریال       │   │
│  │ مجموع خرید: 450M    │ پرداخت: 437.5M     │   │
│  └─────────────────────┴──────────────────────┘   │
│                                                    │
│  📈 عملکرد                                        │
│  ⭐ کیفیت: 4.5/5                                  │
│  ✅ تحویل به‌موقع: 95%                            │
│  📦 تعداد سفارشات: 47                             │
│                                                    │
└────────────────────────────────────────────────────┘
```

#### 3. افزودن/ویرایش تامین‌کننده
```
┌────────────────────────────────────────────────────┐
│  افزودن تامین‌کننده جدید                           │
├────────────────────────────────────────────────────┤
│                                                    │
│  🔍 جستجوی سریع در هایورک                         │
│  ┌────────────────────────────────────────────┐   │
│  │ [جستجو در کسب‌وکارهای هایورک...]     [🔍]   │   │
│  └────────────────────────────────────────────┘   │
│  💡 اگر تامین‌کننده در هایورک است، متصل کنید!     │
│                                                    │
│  ─────────── یا ثبت دستی ───────────              │
│                                                    │
│  * نام تجاری                                      │
│  [____________________________________]            │
│                                                    │
│  نوع تامین‌کننده                                  │
│  ( ) تولیدکننده  (•) توزیع‌کننده                  │
│  ( ) عمده‌فروش   ( ) واردکننده                    │
│                                                    │
│  شماره تماس                                       │
│  [____________________________________]            │
│                                                    │
│  ایمیل                                            │
│  [____________________________________]            │
│                                                    │
│  [بعدی: مخاطبین >]                                │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## 🔐 امنیت و دسترسی

### Row-Level Security
```sql
-- هر کسب‌وکار فقط تامین‌کنندگان خودش را ببیند
CREATE POLICY supplier_isolation ON suppliers
  USING (business_id = current_business_id());
```

### Permission Checks
```typescript
@UseGuards(JwtAuthGuard, RoleGuard)
@Roles('owner', 'admin', 'procurement')
@Post()
async createSupplier() { ... }

@Roles('owner', 'admin', 'procurement', 'finance', 'inventory')
@Get()
async getSuppliers() { ... }
```

---

## 📈 KPI و گزارش‌ها

### شاخص‌های کلیدی
1. **کیفیت تامین**
   - Quality Rating (1-5)
   - Defect Rate (نرخ معیوب)
   - Return Rate (نرخ برگشت)

2. **زمان‌بندی**
   - On-Time Delivery Rate
   - Average Lead Time
   - Late Delivery Count

3. **مالی**
   - Total Purchase Volume
   - Average Order Value
   - Payment History Score
   - Current Debt vs Credit Limit

4. **B2B**
   - Number of Linked Suppliers
   - Shared Catalog Items
   - Direct Order Success Rate

### گزارش‌ها
- **گزارش عملکرد تامین‌کننده**: مقایسه چند تامین‌کننده
- **تحلیل هزینه خرید**: بهترین قیمت‌ها
- **هشدار مدارک**: نزدیک به انقضا
- **گزارش بدهی**: وضعیت مالی

---

## 🚀 فازبندی پیاده‌سازی

### Phase 1: Core Supplier Management (MVP)
**زمان: 2-3 هفته**

#### Backend
- [x] Database Schema & Migrations
- [x] Entity Models (Supplier, Contact, Product, Document)
- [x] CRUD APIs
  - POST /suppliers
  - GET /suppliers
  - GET /suppliers/:id
  - PUT /suppliers/:id
  - DELETE /suppliers/:id
- [x] Search & Filter
- [x] Validation & Business Rules
- [x] Supplier-Product Linking

#### Frontend (Admin Dashboard)
- [x] لیست تامین‌کنندگان
- [x] فرم افزودن/ویرایش
- [x] صفحه جزئیات
- [x] مدیریت مخاطبین
- [x] پیوند محصولات

### Phase 2: B2B Integration
**زمان: 2 هفته**

#### Backend
- [ ] B2B Linking Logic
- [ ] Catalog Sharing API
- [ ] Price Sync Mechanism
- [ ] Business Search in Hivork

#### Frontend
- [ ] جستجوی کسب‌وکارها
- [ ] درخواست اتصال B2B
- [ ] نمایش کاتالوگ مشترک
- [ ] مدیریت دسترسی‌ها

### Phase 3: Purchase Orders Integration
**زمان: 3 هفته**
- [ ] Purchase Order Module
- [ ] Order → Supplier Flow
- [ ] Receipt & Inventory Update
- [ ] Payment Tracking

### Phase 4: Analytics & Advanced
**زمان: 2 هفته**
- [ ] Performance Dashboard
- [ ] Supplier Comparison
- [ ] Smart Recommendations
- [ ] Document Expiry Alerts
- [ ] Automated Reports

---

## 📝 API Endpoints (Phase 1)

### Suppliers
```
POST   /api/v1/suppliers              ایجاد تامین‌کننده
GET    /api/v1/suppliers              لیست تامین‌کنندگان
GET    /api/v1/suppliers/:id          جزئیات
PUT    /api/v1/suppliers/:id          ویرایش
DELETE /api/v1/suppliers/:id          حذف (Soft)
PATCH  /api/v1/suppliers/:id/status   تغییر وضعیت
GET    /api/v1/suppliers/:id/stats    آمار و KPI
```

### Contacts
```
POST   /api/v1/suppliers/:id/contacts
GET    /api/v1/suppliers/:id/contacts
PUT    /api/v1/suppliers/:id/contacts/:contactId
DELETE /api/v1/suppliers/:id/contacts/:contactId
```

### Products
```
POST   /api/v1/suppliers/:id/products        افزودن محصول
GET    /api/v1/suppliers/:id/products        لیست محصولات
PUT    /api/v1/suppliers/:id/products/:spId  ویرایش قیمت/شرایط
DELETE /api/v1/suppliers/:id/products/:spId  حذف پیوند
```

### Documents
```
POST   /api/v1/suppliers/:id/documents
GET    /api/v1/suppliers/:id/documents
GET    /api/v1/suppliers/:id/documents/:docId/download
DELETE /api/v1/suppliers/:id/documents/:docId
```

### B2B (Phase 2)
```
GET    /api/v1/suppliers/search-businesses   جستجو در هایورک
POST   /api/v1/suppliers/:id/link-business   اتصال B2B
DELETE /api/v1/suppliers/:id/unlink-business قطع اتصال
GET    /api/v1/suppliers/:id/shared-catalog  کاتالوگ مشترک
```

---

## ✅ معیارهای موفقیت

### فنی
- ✅ Response Time < 200ms
- ✅ 100% Code Coverage for Business Logic
- ✅ Zero Data Leak (Tenant Isolation)
- ✅ API Documentation Complete

### کسب‌وکار
- ✅ کاهش 50% زمان ثبت تامین‌کننده
- ✅ افزایش دقت داده‌ها با B2B
- ✅ کاهش 30% خطای ورود دستی
- ✅ بهبود 40% سرعت سفارش‌گذاری

---

## 🎯 نکات مهم پیاده‌سازی

### 1️⃣ B2B Connection Flow
```typescript
// الگوریتم پیشنهادی
async connectSupplierToBusiness(
  supplierId: string,
  targetBusinessId: string
) {
  // 1. Validation
  const supplier = await this.findOne(supplierId);
  const business = await this.businessService.findOne(targetBusinessId);
  
  if (supplier.isLinkedBusiness) {
    throw new ConflictException('تامین‌کننده قبلاً متصل شده');
  }
  
  // 2. Link
  supplier.linkedBusinessId = targetBusinessId;
  supplier.isLinkedBusiness = true;
  supplier.linkedAt = new Date();
  
  // 3. Sync Basic Info (read-only from linked business)
  supplier.legalName = business.name;
  supplier.taxId = business.taxId;
  supplier.phone = business.phone;
  
  // 4. Create Catalog Share
  await this.catalogService.createShare({
    fromBusinessId: targetBusinessId,
    toBusinessId: supplier.businessId,
    accessLevel: 'READ_PRICES',
  });
  
  await this.supplierRepo.save(supplier);
  
  return supplier;
}
```

### 2️⃣ Duplicate Detection
```typescript
// جلوگیری از ثبت تکراری
async checkDuplicateSupplier(data: CreateSupplierDto) {
  const existing = await this.supplierRepo.findOne({
    where: [
      { businessId: data.businessId, taxId: data.taxId },
      { businessId: data.businessId, phone: data.phone },
      { businessId: data.businessId, email: data.email },
    ]
  });
  
  if (existing) {
    return {
      isDuplicate: true,
      matchedSupplier: existing,
      matchReason: 'tax_id' | 'phone' | 'email'
    };
  }
  
  return { isDuplicate: false };
}
```

### 3️⃣ Auto Code Generation
```typescript
async generateSupplierCode(businessId: string): Promise<string> {
  const lastSupplier = await this.supplierRepo.findOne({
    where: { businessId },
    order: { createdAt: 'DESC' }
  });
  
  let nextNumber = 1;
  if (lastSupplier && lastSupplier.code) {
    const match = lastSupplier.code.match(/SUP-(\d+)/);
    if (match) {
      nextNumber = parseInt(match[1]) + 1;
    }
  }
  
  return `SUP-${nextNumber.toString().padStart(5, '0')}`;
  // SUP-00001, SUP-00002, ...
}
```

---

## 🔮 آینده‌نگری

### Planned Features (Phase 4+)
- **AI-Powered Supplier Suggestions**: پیشنهاد تامین‌کننده بر اساس تاریخچه
- **Automated Reordering**: سفارش خودکار در سطح حداقل
- **Supplier Performance Prediction**: پیش‌بینی مشکلات
- **Multi-Currency Management**: مدیریت حرفه‌ای ارز
- **EDI Integration**: اتصال به سیستم‌های سازمانی
- **Blockchain for Contracts**: قرارداد هوشمند

---

## 📚 منابع و مراجع

- NestJS Documentation: https://docs.nestjs.com
- TypeORM Relations: https://typeorm.io/relations
- B2B Best Practices: Industry Standards
- Supply Chain Management: Academic Research

---

**آماده برای تایید و شروع پیاده‌سازی! 🚀**

> پس از تایید، فایل تحلیل سیستم سفارشات خرید (Purchase Orders) در `analysis/purchase-orders/` ایجاد خواهد شد.
