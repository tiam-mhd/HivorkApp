# 📋 Implementation Tasks - Supplier & Purchase Order System

> **Project:** Hivork Supplier Management  
> **Start Date:** December 2, 2025  
> **Target:** Phase 1 MVP Completion

---

## 🎯 Phase 1: Database & Entities (Week 1)

### Task 1.1: Database Migrations
**Priority:** 🔴 Critical  
**Estimate:** 1 day  
**Dependencies:** None

- [ ] Create migration for `suppliers` table
- [ ] Create migration for `supplier_contacts` table
- [ ] Create migration for `supplier_products` table
- [ ] Create migration for `supplier_documents` table
- [ ] Create migration for `purchase_orders` table
- [ ] Create migration for `purchase_order_items` table
- [ ] Create migration for `purchase_order_receipts` table
- [ ] Create migration for `purchase_order_receipt_items` table
- [ ] Create migration for `purchase_order_payments` table
- [ ] Create migration for `stock_batches` table
- [ ] Create migration for `stock_transactions` table
- [ ] Add indexes and foreign keys
- [ ] Test migrations up/down

**Files to Create:**
- `backend/src/migrations/YYYYMMDDHHMMSS-create-suppliers.ts`
- `backend/src/migrations/YYYYMMDDHHMMSS-create-supplier-contacts.ts`
- `backend/src/migrations/YYYYMMDDHHMMSS-create-supplier-products.ts`
- `backend/src/migrations/YYYYMMDDHHMMSS-create-supplier-documents.ts`
- `backend/src/migrations/YYYYMMDDHHMMSS-create-purchase-orders.ts`
- `backend/src/migrations/YYYYMMDDHHMMSS-create-purchase-order-items.ts`
- `backend/src/migrations/YYYYMMDDHHMMSS-create-purchase-order-receipts.ts`
- `backend/src/migrations/YYYYMMDDHHMMSS-create-purchase-order-receipt-items.ts`
- `backend/src/migrations/YYYYMMDDHHMMSS-create-purchase-order-payments.ts`
- `backend/src/migrations/YYYYMMDDHHMMSS-create-stock-batches.ts`
- `backend/src/migrations/YYYYMMDDHHMMSS-create-stock-transactions.ts`

---

### Task 1.2: Entity Models
**Priority:** 🔴 Critical  
**Estimate:** 1 day  
**Dependencies:** Task 1.1

- [ ] Create `Supplier` entity with all fields and relations
- [ ] Create `SupplierContact` entity
- [ ] Create `SupplierProduct` entity
- [ ] Create `SupplierDocument` entity
- [ ] Create `PurchaseOrder` entity
- [ ] Create `PurchaseOrderItem` entity
- [ ] Create `PurchaseOrderReceipt` entity
- [ ] Create `PurchaseOrderReceiptItem` entity
- [ ] Create `PurchaseOrderPayment` entity
- [ ] Create `StockBatch` entity
- [ ] Create `StockTransaction` entity
- [ ] Create all enums (SupplierType, SupplierStatus, etc.)
- [ ] Add decorators and validation

**Files to Create:**
- `backend/src/modules/supplier/entities/supplier.entity.ts`
- `backend/src/modules/supplier/entities/supplier-contact.entity.ts`
- `backend/src/modules/supplier/entities/supplier-product.entity.ts`
- `backend/src/modules/supplier/entities/supplier-document.entity.ts`
- `backend/src/modules/purchase-order/entities/purchase-order.entity.ts`
- `backend/src/modules/purchase-order/entities/purchase-order-item.entity.ts`
- `backend/src/modules/purchase-order/entities/purchase-order-receipt.entity.ts`
- `backend/src/modules/purchase-order/entities/purchase-order-receipt-item.entity.ts`
- `backend/src/modules/purchase-order/entities/purchase-order-payment.entity.ts`
- `backend/src/modules/inventory/entities/stock-batch.entity.ts`
- `backend/src/modules/inventory/entities/stock-transaction.entity.ts`

---

### Task 1.3: DTOs (Data Transfer Objects)
**Priority:** 🟡 High  
**Estimate:** 1 day  
**Dependencies:** Task 1.2

**Supplier DTOs:**
- [ ] `CreateSupplierDto`
- [ ] `UpdateSupplierDto`
- [ ] `FilterSupplierDto`
- [ ] `CreateSupplierContactDto`
- [ ] `UpdateSupplierContactDto`
- [ ] `CreateSupplierProductDto`
- [ ] `UpdateSupplierProductDto`
- [ ] `UploadSupplierDocumentDto`

**Purchase Order DTOs:**
- [ ] `CreatePurchaseOrderDto`
- [ ] `UpdatePurchaseOrderDto`
- [ ] `FilterPurchaseOrderDto`
- [ ] `CreatePurchaseOrderItemDto`
- [ ] `CreateReceiptDto`
- [ ] `CreateReceiptItemDto`
- [ ] `CreatePaymentDto`

**Files to Create:**
- `backend/src/modules/supplier/dto/create-supplier.dto.ts`
- `backend/src/modules/supplier/dto/update-supplier.dto.ts`
- `backend/src/modules/supplier/dto/filter-supplier.dto.ts`
- `backend/src/modules/supplier/dto/create-supplier-contact.dto.ts`
- `backend/src/modules/supplier/dto/update-supplier-contact.dto.ts`
- `backend/src/modules/supplier/dto/create-supplier-product.dto.ts`
- `backend/src/modules/supplier/dto/update-supplier-product.dto.ts`
- `backend/src/modules/purchase-order/dto/create-purchase-order.dto.ts`
- `backend/src/modules/purchase-order/dto/update-purchase-order.dto.ts`
- `backend/src/modules/purchase-order/dto/filter-purchase-order.dto.ts`
- etc.

---

## 🔧 Phase 2: Services & Business Logic (Week 1-2)

### Task 2.1: Supplier Service
**Priority:** 🔴 Critical  
**Estimate:** 2 days  
**Dependencies:** Task 1.2, 1.3

- [ ] Create `SupplierService` with CRUD operations
- [ ] Implement `create()` with auto code generation
- [ ] Implement `findAll()` with filtering and pagination
- [ ] Implement `findOne()` with relations
- [ ] Implement `update()` with business rules
- [ ] Implement `remove()` (soft delete)
- [ ] Implement `changeStatus()` with validation
- [ ] Implement `linkToBusiness()` for B2B
- [ ] Implement `unlinkBusiness()`
- [ ] Add duplicate detection logic
- [ ] Add supplier stats calculation

**Files to Create:**
- `backend/src/modules/supplier/supplier.service.ts`
- `backend/src/modules/supplier/supplier-contact.service.ts`
- `backend/src/modules/supplier/supplier-product.service.ts`
- `backend/src/modules/supplier/supplier-document.service.ts`

---

### Task 2.2: Purchase Order Service
**Priority:** 🔴 Critical  
**Estimate:** 2 days  
**Dependencies:** Task 2.1

- [ ] Create `PurchaseOrderService` with CRUD
- [ ] Implement `createPurchaseOrder()` with validation
- [ ] Implement `approvePurchaseOrder()` workflow
- [ ] Implement `rejectPurchaseOrder()`
- [ ] Implement `cancelPurchaseOrder()`
- [ ] Implement auto order number generation
- [ ] Implement financial calculations (subtotal, tax, total)
- [ ] Add supplier validation checks
- [ ] Implement order status updates

**Files to Create:**
- `backend/src/modules/purchase-order/purchase-order.service.ts`
- `backend/src/modules/purchase-order/purchase-order-item.service.ts`

---

### Task 2.3: Receipt & Inventory Service
**Priority:** 🔴 Critical  
**Estimate:** 2 days  
**Dependencies:** Task 2.2

- [ ] Create `ReceiptService`
- [ ] Implement `createReceipt()` with validation
- [ ] Implement `updateInventory()` integration
- [ ] Create `StockBatchService`
- [ ] Implement `createBatch()` on receipt
- [ ] Create `CostCalculationService`
- [ ] Implement FIFO algorithm `calculateCOGS_FIFO()`
- [ ] Implement `recordSale()` with batch allocation
- [ ] Implement `recordPurchase()` with batch creation
- [ ] Add stock transaction logging

**Files to Create:**
- `backend/src/modules/purchase-order/receipt.service.ts`
- `backend/src/modules/inventory/stock-batch.service.ts`
- `backend/src/modules/inventory/stock-transaction.service.ts`
- `backend/src/modules/inventory/cost-calculation.service.ts`

---

### Task 2.4: Payment Service
**Priority:** 🟡 High  
**Estimate:** 1 day  
**Dependencies:** Task 2.2

- [ ] Create `PurchaseOrderPaymentService`
- [ ] Implement `recordPayment()`
- [ ] Integrate with Expense module
- [ ] Update supplier debt/balance
- [ ] Update PO paid/remaining amounts
- [ ] Add payment validation

**Files to Create:**
- `backend/src/modules/purchase-order/payment.service.ts`

---

## 🌐 Phase 3: Controllers & APIs (Week 2)

### Task 3.1: Supplier Controller
**Priority:** 🔴 Critical  
**Estimate:** 1 day  
**Dependencies:** Task 2.1

- [ ] Create `SupplierController`
- [ ] `POST /suppliers` - Create supplier
- [ ] `GET /suppliers` - List with filters
- [ ] `GET /suppliers/:id` - Get details
- [ ] `PUT /suppliers/:id` - Update
- [ ] `DELETE /suppliers/:id` - Soft delete
- [ ] `PATCH /suppliers/:id/status` - Change status
- [ ] `GET /suppliers/:id/stats` - Get KPIs
- [ ] `POST /suppliers/:id/contacts` - Add contact
- [ ] `GET /suppliers/:id/contacts` - List contacts
- [ ] `PUT /suppliers/:id/contacts/:contactId` - Update contact
- [ ] `DELETE /suppliers/:id/contacts/:contactId` - Delete contact
- [ ] `POST /suppliers/:id/products` - Link product
- [ ] `GET /suppliers/:id/products` - List products
- [ ] `PUT /suppliers/:id/products/:spId` - Update link
- [ ] `DELETE /suppliers/:id/products/:spId` - Unlink
- [ ] Add Swagger documentation
- [ ] Add authentication guards
- [ ] Add role-based access control

**Files to Create:**
- `backend/src/modules/supplier/supplier.controller.ts`
- `backend/src/modules/supplier/supplier-contact.controller.ts`
- `backend/src/modules/supplier/supplier-product.controller.ts`

---

### Task 3.2: Purchase Order Controller
**Priority:** 🔴 Critical  
**Estimate:** 1 day  
**Dependencies:** Task 2.2

- [ ] Create `PurchaseOrderController`
- [ ] `POST /purchase-orders` - Create PO
- [ ] `GET /purchase-orders` - List with filters
- [ ] `GET /purchase-orders/:id` - Get details
- [ ] `PUT /purchase-orders/:id` - Update
- [ ] `DELETE /purchase-orders/:id` - Cancel
- [ ] `PATCH /purchase-orders/:id/approve` - Approve
- [ ] `PATCH /purchase-orders/:id/reject` - Reject
- [ ] `POST /purchase-orders/:id/receipts` - Create receipt
- [ ] `GET /purchase-orders/:id/receipts` - List receipts
- [ ] `POST /purchase-orders/:id/payments` - Record payment
- [ ] `GET /purchase-orders/:id/payments` - List payments
- [ ] Add Swagger documentation
- [ ] Add guards and RBAC

**Files to Create:**
- `backend/src/modules/purchase-order/purchase-order.controller.ts`
- `backend/src/modules/purchase-order/receipt.controller.ts`
- `backend/src/modules/purchase-order/payment.controller.ts`

---

### Task 3.3: Inventory Controller (Batch/Cost APIs)
**Priority:** 🟡 High  
**Estimate:** 1 day  
**Dependencies:** Task 2.3

- [ ] Create `StockBatchController`
- [ ] `GET /stock-batches` - List batches
- [ ] `GET /stock-batches/:id` - Get batch details
- [ ] `GET /products/:id/batches` - Get product batches
- [ ] `GET /products/:id/cost-analysis` - Cost analysis
- [ ] `GET /inventory/valuation` - Inventory valuation report
- [ ] Add Swagger docs

**Files to Create:**
- `backend/src/modules/inventory/stock-batch.controller.ts`
- `backend/src/modules/inventory/cost-calculation.controller.ts`

---

## 🔗 Phase 4: Integrations (Week 2-3)

### Task 4.1: Expense Module Integration
**Priority:** 🟡 High  
**Estimate:** 0.5 day  
**Dependencies:** Task 2.4

- [ ] Update `ExpenseCategory` to include supplier-related categories
- [ ] Add `supplierId` field to `Expense` entity (if not exists)
- [ ] Create expense automatically on payment
- [ ] Link expense to purchase order
- [ ] Add supplier filter in expense queries

**Files to Update:**
- `backend/src/modules/expense/entities/expense.entity.ts`
- `backend/src/modules/expense/expense.service.ts`

---

### Task 4.2: Product/Inventory Integration
**Priority:** 🔴 Critical  
**Estimate:** 1 day  
**Dependencies:** Task 2.3

- [ ] Update `ProductVariant` to support batch tracking
- [ ] Integrate receipt with stock update
- [ ] Update invoice creation to use FIFO cost calculation
- [ ] Add cost fields to invoice items
- [ ] Calculate profit on invoice creation
- [ ] Display cost and profit in invoice response

**Files to Update:**
- `backend/src/modules/product/entities/product-variant.entity.ts`
- `backend/src/modules/invoice/invoice.service.ts`
- `backend/src/modules/invoice/entities/invoice-item.entity.ts`

---

### Task 4.3: Business Module Integration (B2B)
**Priority:** 🟢 Medium  
**Estimate:** 1 day  
**Dependencies:** Task 2.1

- [ ] Add B2B linking API endpoints
- [ ] Implement business search for suppliers
- [ ] Create catalog sharing mechanism
- [ ] Implement price sync from linked business
- [ ] Add B2B order flow

**Files to Create:**
- `backend/src/modules/supplier/b2b.service.ts`
- `backend/src/modules/supplier/b2b.controller.ts`

---

## ✅ Phase 5: Module Setup (Week 3)

### Task 5.1: Module Configuration
**Priority:** 🔴 Critical  
**Estimate:** 0.5 day  
**Dependencies:** All above

- [ ] Create `SupplierModule`
- [ ] Create `PurchaseOrderModule`
- [ ] Update `InventoryModule` (or create if not exists)
- [ ] Register all entities in TypeORM
- [ ] Register all services
- [ ] Register all controllers
- [ ] Import in `AppModule`
- [ ] Set up module dependencies

**Files to Create:**
- `backend/src/modules/supplier/supplier.module.ts`
- `backend/src/modules/purchase-order/purchase-order.module.ts`
- `backend/src/modules/inventory/inventory.module.ts`

---

## 🧪 Phase 6: Testing (Week 3)

### Task 6.1: Unit Tests
**Priority:** 🟡 High  
**Estimate:** 2 days  
**Dependencies:** Phase 5

- [ ] Test `SupplierService` methods
- [ ] Test `PurchaseOrderService` methods
- [ ] Test `CostCalculationService` FIFO algorithm
- [ ] Test `StockBatchService` methods
- [ ] Test business rules and validations
- [ ] Mock database calls
- [ ] Test edge cases

**Files to Create:**
- `backend/src/modules/supplier/supplier.service.spec.ts`
- `backend/src/modules/purchase-order/purchase-order.service.spec.ts`
- `backend/src/modules/inventory/cost-calculation.service.spec.ts`

---

### Task 6.2: Integration Tests
**Priority:** 🟢 Medium  
**Estimate:** 1 day  
**Dependencies:** Task 6.1

- [ ] Test full PO workflow (create → approve → receive → pay)
- [ ] Test supplier lifecycle
- [ ] Test FIFO with multiple batches
- [ ] Test B2B linking
- [ ] Test API endpoints (e2e)

**Files to Create:**
- `backend/test/supplier.e2e-spec.ts`
- `backend/test/purchase-order.e2e-spec.ts`

---

## 📊 Phase 7: Reports & Analytics (Week 3-4)

### Task 7.1: Supplier Reports
**Priority:** 🟢 Medium  
**Estimate:** 1 day  
**Dependencies:** Phase 5

- [ ] Top suppliers by purchase volume
- [ ] Supplier performance report
- [ ] Supplier debt report
- [ ] Document expiry alerts

**Files to Create:**
- `backend/src/modules/supplier/reports/supplier-report.service.ts`

---

### Task 7.2: Purchase Reports
**Priority:** 🟢 Medium  
**Estimate:** 1 day  
**Dependencies:** Phase 5

- [ ] Purchase volume by period
- [ ] Purchase by category/supplier
- [ ] Outstanding POs report
- [ ] Late deliveries report

**Files to Create:**
- `backend/src/modules/purchase-order/reports/purchase-report.service.ts`

---

### Task 7.3: Cost & Profit Reports
**Priority:** 🟡 High  
**Estimate:** 1 day  
**Dependencies:** Task 2.3

- [ ] Product profit report
- [ ] Inventory valuation report
- [ ] Cost analysis by product
- [ ] Profit margin trends

**Files to Create:**
- `backend/src/modules/inventory/reports/cost-report.service.ts`

---

## 📱 Phase 8: Admin Dashboard UI (Week 4-5)

### Task 8.1: Supplier Management UI
**Priority:** 🟡 High  
**Estimate:** 3 days  
**Dependencies:** Task 3.1

- [ ] Supplier list page with filters
- [ ] Supplier detail page
- [ ] Create/Edit supplier form
- [ ] Manage contacts UI
- [ ] Link products UI
- [ ] Upload documents UI
- [ ] Supplier stats dashboard

---

### Task 8.2: Purchase Order UI
**Priority:** 🟡 High  
**Estimate:** 3 days  
**Dependencies:** Task 3.2

- [ ] PO list page
- [ ] Create PO wizard
- [ ] PO detail page
- [ ] Approve/Reject workflow UI
- [ ] Receipt creation UI
- [ ] Payment recording UI

---

### Task 8.3: Inventory & Cost UI
**Priority:** 🟢 Medium  
**Estimate:** 2 days  
**Dependencies:** Task 3.3

- [ ] Stock batches view
- [ ] Inventory valuation report
- [ ] Cost analysis charts
- [ ] Profit dashboard

---

## 📝 Documentation (Ongoing)

### Task 9.1: API Documentation
- [ ] Complete Swagger/OpenAPI specs
- [ ] Add examples for all endpoints
- [ ] Document authentication
- [ ] Document error responses

### Task 9.2: Developer Documentation
- [ ] Architecture overview
- [ ] Database schema diagrams
- [ ] FIFO algorithm explanation
- [ ] B2B integration guide
- [ ] Deployment guide

---

## 🎯 Success Criteria

✅ All database migrations run successfully  
✅ All entities properly defined with relations  
✅ All CRUD APIs working with authentication  
✅ FIFO cost calculation accurate  
✅ PO workflow complete (create → receive → pay)  
✅ Supplier management fully functional  
✅ Integration with expenses working  
✅ Unit test coverage > 80%  
✅ API documentation complete  
✅ Admin UI functional for core features  

---

**Estimated Total Time: 3-4 weeks for MVP**
