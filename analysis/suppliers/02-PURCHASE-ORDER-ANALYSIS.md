# 🛒 تحلیل سیستم سفارشات خرید (Purchase Orders)

> **تاریخ:** 2 دسامبر 2025  
> **وضعیت:** 📋 در انتظار تایید  
> **وابستگی:** Supplier Management Module

---

## 📌 خلاصه اجرایی

### 🎯 اهداف ماژول
1. **مدیریت سفارشات خرید از تامین‌کنندگان**: ثبت، پیگیری و تکمیل سفارشات
2. **کنترل موجودی**: به‌روزرسانی خودکار موجودی پس از دریافت کالا
3. **یکپارچگی مالی**: اتصال به هزینه‌ها و پرداخت‌ها
4. **B2B Direct Orders**: سفارش مستقیم از تامین‌کنندگان متصل
5. **گزارش‌گیری**: تحلیل خرید، تامین‌کننده و مدیریت بودجه

### 🔄 جریان کلی (Purchase Order Lifecycle)

```
1. CREATE (ایجاد)
   ↓
   - انتخاب تامین‌کننده
   - افزودن محصولات/تنوع‌ها
   - تعیین مقادیر و قیمت‌ها
   
2. PENDING (در انتظار تایید)
   ↓
   - بررسی توسط مدیر
   - تایید یا رد
   
3. APPROVED (تایید شده)
   ↓
   - ارسال به تامین‌کننده
   - در انتظار تحویل
   
4. PARTIALLY_RECEIVED (دریافت جزئی)
   ↓
   - ثبت دریافت بخشی از کالا
   - به‌روزرسانی موجودی
   
5. RECEIVED (دریافت کامل)
   ↓
   - تکمیل سفارش
   - صدور فاکتور/هزینه
   
6. CANCELLED (لغو)
   └─> لغو سفارش قبل از تحویل
```

---

## 🗄️ طراحی Database Schema

### 1️⃣ Purchase Orders (سفارشات خرید)

```typescript
@Entity('purchase_orders')
@Index(['businessId', 'status'])
@Index(['businessId', 'orderNumber'], { unique: true })
@Index(['supplierId', 'status'])
export class PurchaseOrder {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // ─────────────── Tenant & Relations ─────────────── //
  @Column({ type: 'uuid' })
  @Index()
  businessId: string;

  @ManyToOne(() => Business, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'businessId' })
  business: Business;

  @Column({ type: 'uuid' })
  @Index()
  supplierId: string;

  @ManyToOne(() => Supplier)
  @JoinColumn({ name: 'supplierId' })
  supplier: Supplier;

  // ─────────────── Order Info ─────────────── //
  @Column({ type: 'varchar', length: 50, unique: true })
  orderNumber: string; // PO-00001

  @Column({ type: 'date' })
  orderDate: Date; // تاریخ ثبت سفارش

  @Column({ type: 'date', nullable: true })
  expectedDeliveryDate: Date; // تاریخ تحویل مورد انتظار

  @Column({ type: 'date', nullable: true })
  actualDeliveryDate: Date; // تاریخ تحویل واقعی

  @Column({
    type: 'enum',
    enum: PurchaseOrderStatus,
    default: PurchaseOrderStatus.DRAFT,
  })
  status: PurchaseOrderStatus;

  // ─────────────── Financial ─────────────── //
  @Column({ type: 'varchar', length: 3, default: 'IRR' })
  currency: string;

  @Column({ type: 'decimal', precision: 15, scale: 2 })
  subtotal: number; // مجموع قبل از تخفیف و مالیات

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  discountRate: number; // درصد تخفیف

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  discountAmount: number; // مبلغ تخفیف

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  taxRate: number; // درصد مالیات/عوارض

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  taxAmount: number; // مبلغ مالیات

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  shippingCost: number; // هزینه حمل

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  otherCosts: number; // سایر هزینه‌ها

  @Column({ type: 'decimal', precision: 15, scale: 2 })
  totalAmount: number; // جمع کل

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  paidAmount: number; // مبلغ پرداخت شده

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  remainingAmount: number; // مبلغ باقیمانده

  // ─────────────── Payment Terms ─────────────── //
  @Column({ type: 'integer', default: 0 })
  paymentTermDays: number; // مهلت پرداخت

  @Column({ type: 'varchar', length: 50, nullable: true })
  paymentMethod: string; // نقد، چک، انتقال بانکی

  @Column({ type: 'date', nullable: true })
  paymentDueDate: Date; // سررسید پرداخت

  // ─────────────── Delivery Info ─────────────── //
  @Column({ type: 'text', nullable: true })
  deliveryAddress: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  deliveryCity: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  deliveryProvince: string;

  @Column({ type: 'varchar', length: 20, nullable: true })
  deliveryPostalCode: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  contactPerson: string; // مسئول دریافت

  @Column({ type: 'varchar', length: 20, nullable: true })
  contactPhone: string;

  // ─────────────── Tracking ─────────────── //
  @Column({ type: 'varchar', length: 200, nullable: true })
  trackingNumber: string; // شماره رهگیری حمل

  @Column({ type: 'varchar', length: 100, nullable: true })
  shippingMethod: string; // روش حمل

  @Column({ type: 'varchar', length: 100, nullable: true })
  carrier: string; // شرکت حمل

  // ─────────────── Additional Info ─────────────── //
  @Column({ type: 'text', nullable: true })
  notes: string; // یادداشت داخلی

  @Column({ type: 'text', nullable: true })
  supplierNotes: string; // یادداشت برای تامین‌کننده

  @Column({ type: 'text', nullable: true })
  terms: string; // شرایط و ضوابط

  @Column({ type: 'varchar', length: 500, nullable: true })
  attachmentUrl: string; // فایل پیوست (PDF سفارش)

  @Column({ type: 'simple-array', nullable: true })
  tags: string[];

  // ─────────────── B2B ─────────────── //
  @Column({ type: 'boolean', default: false })
  isB2BOrder: boolean; // سفارش از طریق B2B؟

  @Column({ type: 'uuid', nullable: true })
  linkedBusinessOrderId: string; // ID سفارش در سیستم تامین‌کننده

  // ─────────────── Workflow ─────────────── //
  @Column({ type: 'uuid', nullable: true })
  createdBy: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'createdBy' })
  creator: User;

  @Column({ type: 'uuid', nullable: true })
  approvedBy: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'approvedBy' })
  approver: User;

  @Column({ type: 'timestamp', nullable: true })
  approvedAt: Date;

  @Column({ type: 'text', nullable: true })
  rejectionReason: string;

  // ─────────────── Relations ─────────────── //
  @OneToMany(() => PurchaseOrderItem, item => item.purchaseOrder, {
    cascade: true,
  })
  items: PurchaseOrderItem[];

  @OneToMany(() => PurchaseOrderReceipt, receipt => receipt.purchaseOrder)
  receipts: PurchaseOrderReceipt[];

  @OneToMany(() => PurchaseOrderPayment, payment => payment.purchaseOrder)
  payments: PurchaseOrderPayment[];

  // ─────────────── Timestamps ─────────────── //
  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  deletedAt: Date;
}

// ─────────────── Enums ─────────────── //
export enum PurchaseOrderStatus {
  DRAFT = 'draft',                    // پیش‌نویس
  PENDING = 'pending',                // در انتظار تایید
  APPROVED = 'approved',              // تایید شده
  SENT = 'sent',                      // ارسال شده به تامین‌کننده
  PARTIALLY_RECEIVED = 'partial',     // دریافت جزئی
  RECEIVED = 'received',              // دریافت کامل
  CANCELLED = 'cancelled',            // لغو شده
  REJECTED = 'rejected',              // رد شده
}
```

---

### 2️⃣ Purchase Order Items (اقلام سفارش)

```typescript
@Entity('purchase_order_items')
@Index(['purchaseOrderId'])
@Index(['productVariantId'])
export class PurchaseOrderItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  purchaseOrderId: string;

  @ManyToOne(() => PurchaseOrder, po => po.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'purchaseOrderId' })
  purchaseOrder: PurchaseOrder;

  // ─────────────── Product Info ─────────────── //
  @Column({ type: 'uuid', nullable: true })
  productId: string;

  @ManyToOne(() => Product, { nullable: true })
  @JoinColumn({ name: 'productId' })
  product: Product;

  @Column({ type: 'uuid' })
  productVariantId: string;

  @ManyToOne(() => ProductVariant)
  @JoinColumn({ name: 'productVariantId' })
  productVariant: ProductVariant;

  // Snapshot برای حفظ اطلاعات در زمان سفارش
  @Column({ type: 'varchar', length: 200 })
  productName: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  sku: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  supplierSku: string;

  @Column({ type: 'jsonb', nullable: true })
  variantAttributes: Record<string, any>; // {size: 'L', color: 'Red'}

  // ─────────────── Quantities ─────────────── //
  @Column({ type: 'decimal', precision: 15, scale: 3 })
  orderedQuantity: number; // مقدار سفارش

  @Column({ type: 'decimal', precision: 15, scale: 3, default: 0 })
  receivedQuantity: number; // مقدار دریافت شده

  @Column({ type: 'decimal', precision: 15, scale: 3, default: 0 })
  remainingQuantity: number; // مقدار باقیمانده

  @Column({ type: 'varchar', length: 50 })
  unit: string; // واحد: عدد، کیلو، لیتر

  // ─────────────── Pricing ─────────────── //
  @Column({ type: 'decimal', precision: 15, scale: 2 })
  unitPrice: number; // قیمت واحد

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  discountRate: number;

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  discountAmount: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  taxRate: number;

  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  taxAmount: number;

  @Column({ type: 'decimal', precision: 15, scale: 2 })
  subtotal: number; // جمع قبل از تخفیف و مالیات

  @Column({ type: 'decimal', precision: 15, scale: 2 })
  totalAmount: number; // جمع کل آیتم

  // ─────────────── Additional Info ─────────────── //
  @Column({ type: 'text', nullable: true })
  notes: string;

  @Column({ type: 'date', nullable: true })
  expectedDeliveryDate: Date; // تاریخ تحویل پیش‌بینی شده

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

---

### 3️⃣ Purchase Order Receipts (رسیدهای دریافت کالا)

```typescript
@Entity('purchase_order_receipts')
@Index(['purchaseOrderId'])
@Index(['businessId', 'receiptNumber'], { unique: true })
export class PurchaseOrderReceipt {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  businessId: string;

  @ManyToOne(() => Business, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'businessId' })
  business: Business;

  @Column({ type: 'uuid' })
  purchaseOrderId: string;

  @ManyToOne(() => PurchaseOrder, po => po.receipts)
  @JoinColumn({ name: 'purchaseOrderId' })
  purchaseOrder: PurchaseOrder;

  @Column({ type: 'varchar', length: 50, unique: true })
  receiptNumber: string; // REC-00001

  @Column({ type: 'date' })
  receiptDate: Date;

  @Column({ type: 'varchar', length: 100, nullable: true })
  receivedBy: string; // نام دریافت‌کننده

  @Column({
    type: 'enum',
    enum: ReceiptStatus,
    default: ReceiptStatus.PENDING,
  })
  status: ReceiptStatus;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @Column({ type: 'jsonb', nullable: true })
  attachments: Array<{
    url: string;
    fileName: string;
    fileType: string;
  }>;

  // ─────────────── Quality Check ─────────────── //
  @Column({ type: 'boolean', default: false })
  qualityChecked: boolean;

  @Column({ type: 'decimal', precision: 3, scale: 2, nullable: true })
  qualityScore: number; // 1-5

  @Column({ type: 'text', nullable: true })
  qualityNotes: string;

  @Column({ type: 'integer', default: 0 })
  damagedItems: number; // تعداد معیوب

  @Column({ type: 'integer', default: 0 })
  missingItems: number; // تعداد کسری

  @OneToMany(() => PurchaseOrderReceiptItem, item => item.receipt, {
    cascade: true,
  })
  items: PurchaseOrderReceiptItem[];

  @Column({ type: 'uuid', nullable: true })
  receivedBy: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'receivedBy' })
  receiver: User;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

export enum ReceiptStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
}
```

---

### 4️⃣ Purchase Order Receipt Items (اقلام رسید)

```typescript
@Entity('purchase_order_receipt_items')
@Index(['receiptId'])
@Index(['purchaseOrderItemId'])
export class PurchaseOrderReceiptItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  receiptId: string;

  @ManyToOne(() => PurchaseOrderReceipt, receipt => receipt.items, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'receiptId' })
  receipt: PurchaseOrderReceipt;

  @Column({ type: 'uuid' })
  purchaseOrderItemId: string;

  @ManyToOne(() => PurchaseOrderItem)
  @JoinColumn({ name: 'purchaseOrderItemId' })
  purchaseOrderItem: PurchaseOrderItem;

  @Column({ type: 'uuid' })
  productVariantId: string;

  @ManyToOne(() => ProductVariant)
  @JoinColumn({ name: 'productVariantId' })
  productVariant: ProductVariant;

  @Column({ type: 'decimal', precision: 15, scale: 3 })
  receivedQuantity: number; // مقدار دریافتی

  @Column({ type: 'decimal', precision: 15, scale: 3, default: 0 })
  damagedQuantity: number; // مقدار معیوب

  @Column({ type: 'decimal', precision: 15, scale: 3, default: 0 })
  acceptedQuantity: number; // مقدار قابل قبول

  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

---

### 5️⃣ Purchase Order Payments (پرداخت‌ها)

```typescript
@Entity('purchase_order_payments')
@Index(['purchaseOrderId'])
export class PurchaseOrderPayment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  purchaseOrderId: string;

  @ManyToOne(() => PurchaseOrder, po => po.payments)
  @JoinColumn({ name: 'purchaseOrderId' })
  purchaseOrder: PurchaseOrder;

  @Column({ type: 'date' })
  paymentDate: Date;

  @Column({ type: 'decimal', precision: 15, scale: 2 })
  amount: number;

  @Column({
    type: 'enum',
    enum: PaymentMethod,
  })
  paymentMethod: PaymentMethod;

  @Column({ type: 'varchar', length: 100, nullable: true })
  referenceNumber: string; // شماره مرجع/شماره چک

  @Column({
    type: 'enum',
    enum: PaymentStatus,
    default: PaymentStatus.PENDING,
  })
  status: PaymentStatus;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @Column({ type: 'uuid', nullable: true })
  expenseId: string; // لینک به هزینه

  @ManyToOne(() => Expense, { nullable: true })
  @JoinColumn({ name: 'expenseId' })
  expense: Expense;

  @Column({ type: 'uuid', nullable: true })
  recordedBy: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'recordedBy' })
  recorder: User;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

export enum PaymentMethod {
  CASH = 'cash',
  BANK_TRANSFER = 'bank_transfer',
  CHEQUE = 'cheque',
  CARD = 'card',
  CREDIT = 'credit',
  OTHER = 'other',
}

export enum PaymentStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
}
```

---

## 🔄 جریان‌های کاری (Workflows)

### 1️⃣ ایجاد سفارش خرید

```typescript
async createPurchaseOrder(data: CreatePurchaseOrderDto) {
  // 1. Validation
  const supplier = await this.supplierService.findOne(data.supplierId);
  
  if (supplier.status !== SupplierStatus.APPROVED) {
    throw new BadRequestException('تامین‌کننده باید تایید شده باشد');
  }
  
  // 2. Generate Order Number
  const orderNumber = await this.generateOrderNumber(data.businessId);
  
  // 3. Calculate Totals
  const items = await this.prepareOrderItems(data.items);
  const financial = this.calculateTotals(items, data);
  
  // 4. Create Order
  const purchaseOrder = this.purchaseOrderRepo.create({
    ...data,
    orderNumber,
    items,
    ...financial,
    status: PurchaseOrderStatus.DRAFT,
  });
  
  await this.purchaseOrderRepo.save(purchaseOrder);
  
  // 5. Update Supplier Stats
  await this.supplierService.incrementOrderCount(data.supplierId);
  
  return purchaseOrder;
}
```

---

### 2️⃣ تایید سفارش

```typescript
async approvePurchaseOrder(
  orderId: string,
  userId: string
) {
  const order = await this.findOne(orderId);
  
  if (order.status !== PurchaseOrderStatus.PENDING) {
    throw new BadRequestException('فقط سفارشات در انتظار قابل تایید هستند');
  }
  
  // Update Status
  order.status = PurchaseOrderStatus.APPROVED;
  order.approvedBy = userId;
  order.approvedAt = new Date();
  
  await this.purchaseOrderRepo.save(order);
  
  // Send Notification to Supplier
  if (order.supplier.isLinkedBusiness) {
    await this.notifyLinkedBusiness(order);
  } else {
    await this.sendEmailToSupplier(order);
  }
  
  return order;
}
```

---

### 3️⃣ دریافت کالا

```typescript
async receiveGoods(data: CreateReceiptDto) {
  const order = await this.findOne(data.purchaseOrderId);
  
  // 1. Generate Receipt Number
  const receiptNumber = await this.generateReceiptNumber(data.businessId);
  
  // 2. Create Receipt
  const receipt = this.receiptRepo.create({
    ...data,
    receiptNumber,
    status: ReceiptStatus.PENDING,
  });
  
  await this.receiptRepo.save(receipt);
  
  // 3. Update Order Items
  for (const item of data.items) {
    await this.updateOrderItemQuantities(item);
  }
  
  // 4. Update Inventory
  await this.updateInventory(receipt);
  
  // 5. Check if Order Complete
  await this.checkOrderCompletion(order.id);
  
  // 6. Update Supplier Metrics
  await this.updateSupplierMetrics(order.supplierId, receipt);
  
  return receipt;
}

async updateInventory(receipt: PurchaseOrderReceipt) {
  for (const item of receipt.items) {
    const variant = await this.variantRepo.findOne(item.productVariantId);
    
    // Add to stock
    variant.currentStock += item.acceptedQuantity;
    
    await this.variantRepo.save(variant);
    
    // Create Stock Transaction
    await this.stockTransactionService.create({
      productVariantId: item.productVariantId,
      type: 'PURCHASE_RECEIPT',
      quantity: item.acceptedQuantity,
      referenceId: receipt.id,
      referenceType: 'PURCHASE_ORDER_RECEIPT',
    });
  }
}
```

---

### 4️⃣ ثبت پرداخت

```typescript
async recordPayment(data: CreatePaymentDto) {
  const order = await this.findOne(data.purchaseOrderId);
  
  // 1. Create Payment Record
  const payment = this.paymentRepo.create({
    ...data,
    status: PaymentStatus.COMPLETED,
  });
  
  await this.paymentRepo.save(payment);
  
  // 2. Update Order Financials
  order.paidAmount += data.amount;
  order.remainingAmount = order.totalAmount - order.paidAmount;
  
  await this.purchaseOrderRepo.save(order);
  
  // 3. Create Expense Record
  const expense = await this.expenseService.create({
    businessId: order.businessId,
    categoryId: 'product-purchase-category',
    title: `پرداخت سفارش ${order.orderNumber}`,
    amount: data.amount,
    expenseDate: data.paymentDate,
    paymentMethod: data.paymentMethod,
    referenceType: 'PURCHASE_ORDER',
    referenceId: order.id,
    supplierId: order.supplierId,
  });
  
  // Link expense to payment
  payment.expenseId = expense.id;
  await this.paymentRepo.save(payment);
  
  // 4. Update Supplier Balance
  await this.supplierService.updateDebt(
    order.supplierId,
    -data.amount
  );
  
  return payment;
}
```

---

## 🎨 طراحی UI/UX

### صفحه لیست سفارشات

```
┌────────────────────────────────────────────────────┐
│  🛒 سفارشات خرید                       [+ جدید]    │
├────────────────────────────────────────────────────┤
│  🔍 [جستجو...]  📊 [وضعیت▼]  📅 [تاریخ▼]  🔄     │
├────────────────────────────────────────────────────┤
│                                                    │
│  ┌──────────────────────────────────────────────┐ │
│  │ PO-00045  |  ✅ تایید شده                    │ │
│  │ 🤝 شرکت پخش آرین                            │ │
│  │ 📅 1403/09/15  |  💰 45,000,000 ریال         │ │
│  │ 📦 12 قلم  |  🚚 در انتظار تحویل              │ │
│  └──────────────────────────────────────────────┘ │
│                                                    │
│  ┌──────────────────────────────────────────────┐ │
│  │ PO-00044  |  📥 دریافت جزئی (60%)            │ │
│  │ 🤝 واردات الکترونیک                         │ │
│  │ 📅 1403/09/10  |  💰 120,500,000 ریال        │ │
│  │ 📦 8 قلم  |  ⏱️ تأخیر 3 روزه                 │ │
│  └──────────────────────────────────────────────┘ │
│                                                    │
└────────────────────────────────────────────────────┘
```

### صفحه ایجاد سفارش

```
┌────────────────────────────────────────────────────┐
│  ایجاد سفارش خرید جدید                            │
├────────────────────────────────────────────────────┤
│                                                    │
│  1️⃣ انتخاب تامین‌کننده                           │
│  ┌────────────────────────────────────────────┐   │
│  │ [شرکت پخش آرین ▼]                    [🔗]  │   │
│  └────────────────────────────────────────────┘   │
│  💡 تامین‌کننده متصل B2B - کاتالوگ مشترک          │
│                                                    │
│  2️⃣ افزودن محصولات                               │
│  ┌────────────────────────────────────────────┐   │
│  │ [جستجوی محصول...]              [+ افزودن]  │   │
│  └────────────────────────────────────────────┘   │
│                                                    │
│  📦 تی‌شرت پنبه | سایز L | آبی                     │
│  └─ تعداد: [50] | قیمت: [45,000] | جمع: 2.25M    │
│                                                    │
│  📦 شلوار جین | سایز 32 | مشکی                    │
│  └─ تعداد: [30] | قیمت: [85,000] | جمع: 2.55M    │
│                                                    │
│  3️⃣ جزئیات مالی                                   │
│  جمع جزء: 4,800,000 ریال                          │
│  تخفیف (5%): -240,000 ریال                       │
│  مالیات (9%): +410,400 ریال                       │
│  هزینه حمل: +200,000 ریال                         │
│  ───────────────────────────                      │
│  💰 جمع کل: 5,170,400 ریال                        │
│                                                    │
│  [ذخیره پیش‌نویس]  [ارسال برای تایید]            │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## 📊 KPI و گزارش‌ها

### شاخص‌های کلیدی

1. **حجم خرید**
   - Total Purchase Value (ماهانه/سالانه)
   - Average Order Value
   - Top Products by Purchase Value

2. **عملکرد تامین‌کننده**
   - On-Time Delivery Rate
   - Order Fulfillment Rate
   - Quality Score

3. **مالی**
   - Outstanding Payables
   - Average Payment Cycle
   - Cash Flow from Purchases

4. **موجودی**
   - Stock Coverage Days
   - Reorder Point Triggers
   - Out of Stock Incidents

---

## 🚀 فازبندی

### Phase 1: Core (2-3 هفته)
- [x] Database Schema
- [x] CRUD Operations
- [x] Order Lifecycle
- [x] Basic UI

### Phase 2: Receipt & Inventory (2 هفته)
- [ ] Receipt Management
- [ ] Inventory Update
- [ ] Quality Check

### Phase 3: Financial Integration (1 هفته)
- [ ] Payment Tracking
- [ ] Expense Integration
- [ ] Supplier Balance

### Phase 4: B2B Orders (2 هفته)
- [ ] Direct Order from Linked Business
- [ ] Auto Price Sync
- [ ] Order Status Sync

---

**آماده برای تایید و پیاده‌سازی! 🚀**
