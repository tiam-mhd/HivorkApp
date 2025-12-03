# 💰 تحلیل مدیریت قیمت خرید و محاسبه سود/زیان

> **تاریخ:** 2 دسامبر 2025  
> **موضوع:** Cost Tracking & Profit/Loss Calculation  
> **اهمیت:** 🔴 بحرانی - تأثیر مستقیم بر گزارشات مالی

---

## 🎯 مسئله اصلی

```
سناریو:
1. خرید 1: 100 عدد تی‌شرت @ 50,000 ریال = 5,000,000 ریال
2. فروش: 30 عدد @ 80,000 ریال = 2,400,000 ریال
3. خرید 2: 50 عدد تی‌شرت @ 55,000 ریال = 2,750,000 ریال
4. فروش: 40 عدد @ 85,000 ریال = 3,400,000 ریال

❓ سوال: چه قیمت خریدی را برای محاسبه سود استفاده کنیم؟
```

---

## 📊 روش‌های استاندارد حسابداری موجودی

### 1️⃣ **FIFO (First In, First Out)** ⭐ توصیه شده

**مفهوم:** اولین کالای خریداری شده، اولین کالای فروخته شده است.

```
مثال:
خرید 1: 100 @ 50,000 = 5M
خرید 2: 50 @ 55,000 = 2.75M

فروش 1: 30 عدد
├─ 30 عدد از خرید 1 @ 50,000
└─ بهای تمام شده: 30 × 50,000 = 1,500,000
└─ سود: (30 × 80,000) - 1,500,000 = 900,000 ✅

فروش 2: 40 عدد
├─ 40 عدد باقیمانده از خرید 1 @ 50,000
│  (چون 30 عدد از 100 فروخته شده، 70 مانده)
└─ بهای تمام شده: 40 × 50,000 = 2,000,000
└─ سود: (40 × 85,000) - 2,000,000 = 1,400,000 ✅

موجودی باقیمانده:
├─ 30 عدد از خرید 1 @ 50,000 = 1,500,000
└─ 50 عدد از خرید 2 @ 55,000 = 2,750,000
└─ ارزش موجودی: 4,250,000 ریال
```

**مزایا:**
- ✅ منطقی‌تر (کالای قدیمی‌تر اول فروخته می‌شود)
- ✅ مطابق با واقعیت فیزیکی (خصوصاً برای کالاهای فاسدشدنی)
- ✅ قبول شده در استانداردهای حسابداری ایران و بین‌المللی (IFRS)
- ✅ در دوران تورم، سود بیشتری نشان می‌دهد

**معایب:**
- ⚠️ پیچیده‌تر در پیاده‌سازی
- ⚠️ نیاز به ردیابی دقیق‌تر موجودی

---

### 2️⃣ **LIFO (Last In, First Out)**

**مفهوم:** آخرین کالای خریداری شده، اولین کالای فروخته شده است.

```
فروش 2: 40 عدد
├─ 40 عدد از خرید 2 @ 55,000
└─ بهای تمام شده: 40 × 55,000 = 2,200,000
└─ سود: (40 × 85,000) - 2,200,000 = 1,200,000

موجودی:
├─ 70 عدد از خرید 1 @ 50,000
└─ 10 عدد از خرید 2 @ 55,000
```

**⚠️ توجه:** LIFO در ایران و بسیاری از کشورها مجاز نیست!

---

### 3️⃣ **Weighted Average Cost (میانگین موزون)** ⭐ ساده‌تر

**مفهوم:** میانگین قیمت تمام خریدها

```
بعد از خرید 1:
└─ میانگین: 50,000

فروش 1: 30 عدد @ 50,000
└─ بهای تمام شده: 1,500,000
└─ موجودی: 70 عدد @ 50,000 = 3,500,000

بعد از خرید 2:
├─ موجودی فعلی: 70 @ 50,000 = 3,500,000
├─ خرید جدید: 50 @ 55,000 = 2,750,000
├─ جمع: 120 عدد = 6,250,000
└─ میانگین جدید: 6,250,000 ÷ 120 = 52,083 ریال

فروش 2: 40 عدد @ 52,083
└─ بهای تمام شده: 40 × 52,083 = 2,083,320
└─ سود: (40 × 85,000) - 2,083,320 = 1,316,680

موجودی باقیمانده:
└─ 80 عدد @ 52,083 = 4,166,640
```

**مزایا:**
- ✅ ساده‌تر در پیاده‌سازی
- ✅ نوسانات قیمت را smooth می‌کند
- ✅ قابل قبول در حسابداری ایران

**معایب:**
- ⚠️ کمتر دقیق در ردیابی واقعی
- ⚠️ باید بعد از هر خرید میانگین را recalculate کرد

---

### 4️⃣ **Specific Identification (شناسایی مشخص)**

**مفهوم:** هر واحد را جداگانه ردیابی می‌کنیم.

**کاربرد:** فقط برای کالاهای منحصر به فرد (خودرو، جواهرات، آثار هنری)

❌ برای کالاهای معمولی عملی نیست.

---

## 🏗️ طراحی Database برای FIFO

### گزینه 1: Stock Batches (توصیه شده) ⭐

```typescript
@Entity('stock_batches')
export class StockBatch {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  businessId: string;

  @Column({ type: 'uuid' })
  productVariantId: string;

  @ManyToOne(() => ProductVariant)
  @JoinColumn({ name: 'productVariantId' })
  productVariant: ProductVariant;

  // ─────────── Batch Info ─────────── //
  @Column({ type: 'varchar', length: 50 })
  batchNumber: string; // BATCH-00001

  @Column({ type: 'date' })
  purchaseDate: Date;

  @Column({ type: 'uuid', nullable: true })
  purchaseOrderId: string; // مرجع سفارش خرید

  @Column({ type: 'uuid', nullable: true })
  supplierId: string;

  // ─────────── Quantities ─────────── //
  @Column({ type: 'decimal', precision: 15, scale: 3 })
  initialQuantity: number; // مقدار اولیه

  @Column({ type: 'decimal', precision: 15, scale: 3 })
  currentQuantity: number; // مقدار باقیمانده

  @Column({ type: 'decimal', precision: 15, scale: 3, default: 0 })
  soldQuantity: number; // مقدار فروخته شده

  // ─────────── Cost ─────────── //
  @Column({ type: 'decimal', precision: 15, scale: 2 })
  unitCost: number; // قیمت واحد خرید (شامل همه هزینه‌های جانبی)

  @Column({ type: 'decimal', precision: 15, scale: 2 })
  totalCost: number; // قیمت کل batch

  // ─────────── Additional Costs ─────────── //
  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  shippingCost: number; // هزینه حمل

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  customsDuty: number; // عوارض گمرکی

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  otherCosts: number; // سایر هزینه‌ها

  // ─────────── Status ─────────── //
  @Column({ type: 'boolean', default: true })
  isActive: boolean; // آیا batch هنوز موجودی دارد؟

  @Column({ type: 'date', nullable: true })
  expiryDate: Date; // تاریخ انقضا (برای کالاهای فاسدشدنی)

  @Column({ type: 'varchar', length: 100, nullable: true })
  lotNumber: string; // شماره LOT تولید

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

---

### گزینه 2: Stock Transactions با Cost Tracking

```typescript
@Entity('stock_transactions')
export class StockTransaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  businessId: string;

  @Column({ type: 'uuid' })
  productVariantId: string;

  @Column({
    type: 'enum',
    enum: TransactionType,
  })
  type: TransactionType; // IN, OUT, ADJUSTMENT

  @Column({ type: 'decimal', precision: 15, scale: 3 })
  quantity: number;

  // ─────────── Cost Information ─────────── //
  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  unitCost: number; // برای IN transactions

  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  totalCost: number;

  // برای OUT transactions (فروش)
  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  allocatedCost: number; // بهای تمام شده (محاسبه شده با FIFO)

  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  salePrice: number; // قیمت فروش

  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  profit: number; // سود = salePrice - allocatedCost

  // ─────────── References ─────────── //
  @Column({ type: 'varchar', length: 50, nullable: true })
  referenceType: string; // PURCHASE_ORDER, INVOICE, ADJUSTMENT

  @Column({ type: 'uuid', nullable: true })
  referenceId: string;

  @Column({ type: 'uuid', nullable: true })
  batchId: string; // ارجاع به batch

  @Column({ type: 'date' })
  transactionDate: Date;

  @CreateDateColumn()
  createdAt: Date;
}

export enum TransactionType {
  IN = 'in',           // ورود کالا
  OUT = 'out',         // خروج کالا (فروش)
  ADJUSTMENT = 'adj',  // تعدیل
  RETURN = 'return',   // برگشت
  DAMAGE = 'damage',   // ضایعات
}
```

---

## 💻 پیاده‌سازی الگوریتم FIFO

```typescript
// ─────────── Service برای محاسبه COGS (Cost of Goods Sold) ─────────── //

@Injectable()
export class CostCalculationService {
  
  /**
   * محاسبه بهای تمام شده برای فروش با روش FIFO
   */
  async calculateCOGS_FIFO(
    productVariantId: string,
    quantityToSell: number,
    businessId: string
  ): Promise<COGSResult> {
    
    // 1. دریافت batch های فعال به ترتیب تاریخ خرید (FIFO)
    const batches = await this.stockBatchRepo.find({
      where: {
        businessId,
        productVariantId,
        currentQuantity: MoreThan(0),
        isActive: true,
      },
      order: {
        purchaseDate: 'ASC', // اولین خریدها اول
        createdAt: 'ASC',
      },
    });

    if (batches.length === 0) {
      throw new BadRequestException('موجودی کافی نیست');
    }

    let remainingToAllocate = quantityToSell;
    let totalCost = 0;
    const allocations: BatchAllocation[] = [];

    // 2. تخصیص از batch ها
    for (const batch of batches) {
      if (remainingToAllocate <= 0) break;

      const quantityFromThisBatch = Math.min(
        remainingToAllocate,
        batch.currentQuantity
      );

      const costFromThisBatch = quantityFromThisBatch * batch.unitCost;

      allocations.push({
        batchId: batch.id,
        batchNumber: batch.batchNumber,
        quantity: quantityFromThisBatch,
        unitCost: batch.unitCost,
        totalCost: costFromThisBatch,
      });

      totalCost += costFromThisBatch;
      remainingToAllocate -= quantityFromThisBatch;
    }

    // 3. بررسی موجودی کافی
    if (remainingToAllocate > 0) {
      throw new BadRequestException(
        `موجودی کافی نیست. ${remainingToAllocate} عدد کمبود دارید`
      );
    }

    return {
      totalCost,
      averageUnitCost: totalCost / quantityToSell,
      allocations,
    };
  }

  /**
   * ثبت فروش و کم کردن از batch ها
   */
  async recordSale(
    productVariantId: string,
    quantity: number,
    salePrice: number,
    invoiceId: string,
    businessId: string
  ): Promise<SaleRecord> {
    
    // 1. محاسبه COGS
    const cogs = await this.calculateCOGS_FIFO(
      productVariantId,
      quantity,
      businessId
    );

    // 2. کم کردن از batch ها
    for (const allocation of cogs.allocations) {
      const batch = await this.stockBatchRepo.findOne(allocation.batchId);
      
      batch.currentQuantity -= allocation.quantity;
      batch.soldQuantity += allocation.quantity;
      
      if (batch.currentQuantity <= 0) {
        batch.isActive = false;
      }
      
      await this.stockBatchRepo.save(batch);
    }

    // 3. ثبت transaction
    const transaction = this.stockTransactionRepo.create({
      businessId,
      productVariantId,
      type: TransactionType.OUT,
      quantity: -quantity, // منفی برای خروج
      allocatedCost: cogs.totalCost,
      salePrice: salePrice * quantity,
      profit: (salePrice * quantity) - cogs.totalCost,
      referenceType: 'INVOICE',
      referenceId: invoiceId,
      transactionDate: new Date(),
    });

    await this.stockTransactionRepo.save(transaction);

    // 4. بروزرسانی موجودی کل
    await this.updateProductVariantStock(productVariantId, -quantity);

    return {
      totalCost: cogs.totalCost,
      totalRevenue: salePrice * quantity,
      profit: (salePrice * quantity) - cogs.totalCost,
      profitMargin: ((salePrice - cogs.averageUnitCost) / salePrice) * 100,
    };
  }

  /**
   * ثبت خرید جدید (ایجاد batch جدید)
   */
  async recordPurchase(data: {
    productVariantId: string;
    quantity: number;
    unitCost: number;
    purchaseOrderId?: string;
    supplierId?: string;
    shippingCost?: number;
    otherCosts?: number;
    businessId: string;
  }): Promise<StockBatch> {
    
    // محاسبه unit cost واقعی (شامل هزینه‌های جانبی)
    const additionalCostPerUnit = 
      ((data.shippingCost || 0) + (data.otherCosts || 0)) / data.quantity;
    
    const actualUnitCost = data.unitCost + additionalCostPerUnit;

    // ایجاد batch جدید
    const batchNumber = await this.generateBatchNumber(data.businessId);
    
    const batch = this.stockBatchRepo.create({
      businessId: data.businessId,
      productVariantId: data.productVariantId,
      batchNumber,
      purchaseDate: new Date(),
      purchaseOrderId: data.purchaseOrderId,
      supplierId: data.supplierId,
      initialQuantity: data.quantity,
      currentQuantity: data.quantity,
      soldQuantity: 0,
      unitCost: actualUnitCost,
      totalCost: actualUnitCost * data.quantity,
      shippingCost: data.shippingCost || 0,
      otherCosts: data.otherCosts || 0,
      isActive: true,
    });

    await this.stockBatchRepo.save(batch);

    // ثبت transaction ورود
    await this.stockTransactionRepo.save({
      businessId: data.businessId,
      productVariantId: data.productVariantId,
      type: TransactionType.IN,
      quantity: data.quantity,
      unitCost: actualUnitCost,
      totalCost: actualUnitCost * data.quantity,
      batchId: batch.id,
      referenceType: 'PURCHASE_ORDER',
      referenceId: data.purchaseOrderId,
      transactionDate: new Date(),
    });

    // بروزرسانی موجودی کل
    await this.updateProductVariantStock(data.productVariantId, data.quantity);

    return batch;
  }
}

// ─────────── Types ─────────── //
interface COGSResult {
  totalCost: number;
  averageUnitCost: number;
  allocations: BatchAllocation[];
}

interface BatchAllocation {
  batchId: string;
  batchNumber: string;
  quantity: number;
  unitCost: number;
  totalCost: number;
}

interface SaleRecord {
  totalCost: number;
  totalRevenue: number;
  profit: number;
  profitMargin: number;
}
```

---

## 📊 گزارش‌های مالی

### 1. گزارش سود/زیان محصول

```typescript
async getProductProfitReport(
  productVariantId: string,
  startDate: Date,
  endDate: Date,
  businessId: string
) {
  const transactions = await this.stockTransactionRepo.find({
    where: {
      businessId,
      productVariantId,
      type: TransactionType.OUT,
      transactionDate: Between(startDate, endDate),
    },
  });

  const totalRevenue = transactions.reduce((sum, t) => sum + t.salePrice, 0);
  const totalCost = transactions.reduce((sum, t) => sum + t.allocatedCost, 0);
  const totalProfit = totalRevenue - totalCost;
  const profitMargin = (totalProfit / totalRevenue) * 100;

  return {
    productVariantId,
    period: { startDate, endDate },
    totalRevenue,
    totalCost,
    totalProfit,
    profitMargin,
    unitsSold: transactions.reduce((sum, t) => sum + Math.abs(t.quantity), 0),
  };
}
```

### 2. گزارش ارزش موجودی (Inventory Valuation)

```typescript
async getInventoryValuation(businessId: string) {
  const batches = await this.stockBatchRepo.find({
    where: {
      businessId,
      currentQuantity: MoreThan(0),
      isActive: true,
    },
    relations: ['productVariant', 'productVariant.product'],
  });

  const valuation = batches.map(batch => ({
    product: batch.productVariant.product.name,
    variant: batch.productVariant.sku,
    batchNumber: batch.batchNumber,
    quantity: batch.currentQuantity,
    unitCost: batch.unitCost,
    totalValue: batch.currentQuantity * batch.unitCost,
    purchaseDate: batch.purchaseDate,
  }));

  const totalValue = valuation.reduce((sum, item) => sum + item.totalValue, 0);

  return {
    items: valuation,
    totalValue,
    generatedAt: new Date(),
  };
}
```

---

## 🎨 نمایش در UI

### صفحه جزئیات محصول - تب "تاریخچه خرید"

```
┌────────────────────────────────────────────────────┐
│  📦 تی‌شرت پنبه | سایز L                            │
│  Tab: [اطلاعات] [موجودی] [💰 تاریخچه خرید]        │
├────────────────────────────────────────────────────┤
│                                                    │
│  📊 ارزش موجودی فعلی: 4,250,000 ریال              │
│  📦 موجودی کل: 80 عدد                              │
│                                                    │
│  Batches فعال:                                     │
│  ┌──────────────────────────────────────────────┐ │
│  │ BATCH-00123  |  📅 1403/08/15                │ │
│  │ 🤝 شرکت پخش آرین                             │ │
│  │ موجودی: 30/100 عدد                           │ │
│  │ 💰 قیمت خرید: 50,000 ریال                    │ │
│  │ 📊 ارزش باقیمانده: 1,500,000 ریال            │ │
│  └──────────────────────────────────────────────┘ │
│                                                    │
│  ┌──────────────────────────────────────────────┐ │
│  │ BATCH-00156  |  📅 1403/09/10                │ │
│  │ 🤝 شرکت پخش آرین                             │ │
│  │ موجودی: 50/50 عدد                            │ │
│  │ 💰 قیمت خرید: 55,000 ریال                    │ │
│  │ 📊 ارزش باقیمانده: 2,750,000 ریال            │ │
│  └──────────────────────────────────────────────┘ │
│                                                    │
│  📈 میانگین قیمت خرید فعلی: 53,125 ریال          │
│                                                    │
└────────────────────────────────────────────────────┘
```

### صفحه فاکتور - نمایش سود واقعی

```
┌────────────────────────────────────────────────────┐
│  فاکتور #INV-00234                                 │
├────────────────────────────────────────────────────┤
│  تی‌شرت پنبه | L | آبی                             │
│  تعداد: 40                                         │
│  قیمت فروش: 85,000 × 40 = 3,400,000 ریال          │
│  💰 بهای تمام شده: 2,000,000 ریال                 │
│  💚 سود: 1,400,000 ریال (41%)                      │
│                                                    │
│  ℹ️ محاسبه شده با روش FIFO                         │
│  └─ 40 عدد از BATCH-00123 @ 50,000               │
└────────────────────────────────────────────────────┘
```

---

## 🚀 پیاده‌سازی گام به گام

### Phase 1: ساختار پایه (1 هفته)
- [x] ایجاد جدول StockBatch
- [x] ایجاد جدول StockTransaction
- [x] Migration ها

### Phase 2: Business Logic (1 هفته)
- [x] Service برای FIFO calculation
- [x] Integration با Purchase Order
- [x] Integration با Invoice

### Phase 3: گزارش‌ها (3-4 روز)
- [x] Inventory Valuation Report
- [x] Product Profit Report
- [x] Cost Analysis Dashboard

### Phase 4: UI (1 هفته)
- [x] نمایش batch ها در صفحه محصول
- [x] نمایش سود در فاکتور
- [x] Dashboard های مالی

---

## ⚙️ تنظیمات سیستم

```typescript
// در تنظیمات Business
@Entity('business_settings')
export class BusinessSettings {
  // ...
  
  @Column({
    type: 'enum',
    enum: CostMethod,
    default: CostMethod.FIFO,
  })
  costCalculationMethod: CostMethod;
  
  @Column({ type: 'boolean', default: true })
  includeSippingInCost: boolean; // آیا هزینه حمل در COGS محاسبه شود؟
  
  @Column({ type: 'boolean', default: false })
  trackByBatch: boolean; // آیا batch tracking فعال باشد؟
}

export enum CostMethod {
  FIFO = 'fifo',
  WEIGHTED_AVERAGE = 'weighted_average',
  SPECIFIC = 'specific',
}
```

---

## 💡 توصیه نهایی

### برای Hivork:

✅ **استفاده از FIFO با Stock Batches**
- دقیق‌تر
- مطابق استانداردهای حسابداری
- شفاف برای کاربر

✅ **Fallback به Weighted Average**
- برای کسب‌وکارهای ساده
- گزینه در تنظیمات

✅ **نمایش واضح در UI**
- کاربر ببیند چطور سود محاسبه شده
- Transparency = Trust

---

## 📚 مراجع

- استانداردهای حسابداری ایران
- IFRS (International Financial Reporting Standards)
- Inventory Management Best Practices

---

**آماده برای پیاده‌سازی! 💪**
