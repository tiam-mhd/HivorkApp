# Flutter Phase 3 Implementation Tasks

> تسک‌بندی کامل پیاده‌سازی Phase 3 برای Flutter App

---

## 📊 Progress Overview

**Total Tasks**: 60  
**Completed**: 1  
**In Progress**: 0  
**Remaining**: 59  

---

## 🎯 Module 1: Supplier Management (تامین‌کننده)

### 1.1 Data Layer
- [x] ✅ Setup folder structure
- [ ] Create Supplier Model
- [ ] Create Contact Model  
- [ ] Create SupplierProduct Model
- [ ] Create Document Model
- [ ] Create CreateSupplierDto
- [ ] Create UpdateSupplierDto
- [ ] Create FilterSupplierDto
- [ ] Create Contact DTOs
- [ ] Create SupplierProduct DTOs
- [ ] Create Document DTOs

### 1.2 API Service
- [ ] Setup SupplierApiService
- [ ] Implement CRUD endpoints
- [ ] Implement status change endpoints
- [ ] Implement stats endpoint
- [ ] Setup ContactApiService
- [ ] Setup SupplierProductApiService
- [ ] Setup DocumentApiService (with file upload)

### 1.3 State Management
- [ ] Create SupplierProvider
- [ ] Implement supplier list state
- [ ] Implement supplier detail state
- [ ] Implement filter/search state
- [ ] Implement contact management state
- [ ] Implement product management state
- [ ] Implement document management state

### 1.4 UI - Main Screens
- [ ] Supplier List Screen
  - [ ] List view with cards
  - [ ] Pull to refresh
  - [ ] Search functionality
  - [ ] Filter dialog
  - [ ] Floating action button (Add)
- [ ] Supplier Create/Edit Screen
  - [ ] Form validation
  - [ ] Category picker
  - [ ] Rating selector
  - [ ] Address fields
  - [ ] Banking info fields
- [ ] Supplier Detail Screen
  - [ ] Header with info
  - [ ] Tabs (Info, Contacts, Products, Documents, Stats)
  - [ ] Status badge
  - [ ] Action buttons (Edit, Delete, Change Status)

### 1.5 UI - Sub Features
- [ ] Contact Management
  - [ ] Contact list
  - [ ] Add contact dialog
  - [ ] Edit contact
  - [ ] Mark as primary
- [ ] Product Management
  - [ ] Supplier products list
  - [ ] Add product dialog
  - [ ] Edit product info
  - [ ] Remove product
- [ ] Document Management
  - [ ] Document list with types
  - [ ] Upload document (with file picker)
  - [ ] View document
  - [ ] Approve/Reject buttons
  - [ ] Document status badges

### 1.6 Widgets & Components
- [ ] SupplierCard widget
- [ ] SupplierStatusBadge widget
- [ ] ContactCard widget
- [ ] SupplierProductCard widget
- [ ] DocumentCard widget
- [ ] SupplierFilterDialog widget
- [ ] SupplierStatsCard widget

---

## 🛒 Module 2: Purchase Order (سفارش خرید)

### 2.1 Data Layer
- [ ] Create PurchaseOrder Model
- [ ] Create PurchaseOrderItem Model
- [ ] Create Payment Model
- [ ] Create Receipt Model
- [ ] Create ReceiptItem Model
- [ ] Create CreatePurchaseOrderDto
- [ ] Create UpdatePurchaseOrderDto
- [ ] Create FilterPurchaseOrderDto
- [ ] Create Payment DTOs
- [ ] Create Receipt DTOs

### 2.2 API Service
- [ ] Setup PurchaseOrderApiService
- [ ] Implement CRUD endpoints
- [ ] Implement workflow endpoints (submit, approve, send, cancel)
- [ ] Implement stats endpoint
- [ ] Setup PaymentApiService
- [ ] Implement payment CRUD
- [ ] Implement payment status endpoints (complete, fail, cancel)
- [ ] Setup ReceiptApiService
- [ ] Implement receipt CRUD
- [ ] Implement receipt complete/cancel

### 2.3 State Management
- [ ] Create PurchaseOrderProvider
- [ ] Implement list state
- [ ] Implement detail state
- [ ] Implement create/edit state
- [ ] Implement payment state
- [ ] Implement receipt state
- [ ] Implement workflow actions state

### 2.4 UI - Main Screens
- [ ] Purchase Order List Screen
  - [ ] List with status badges
  - [ ] Pull to refresh
  - [ ] Filter by status/supplier
  - [ ] Search by order number
- [ ] Create Purchase Order Screen (Multi-step)
  - [ ] Step 1: Select Supplier
  - [ ] Step 2: Add Items
  - [ ] Step 3: Shipping & Payment Terms
  - [ ] Step 4: Review & Submit
- [ ] Purchase Order Detail Screen
  - [ ] Header with order info
  - [ ] Status timeline
  - [ ] Items list
  - [ ] Payment summary
  - [ ] Receipt summary
  - [ ] Action buttons (Approve, Send, Cancel)

### 2.5 UI - Sub Features
- [ ] Payment Management
  - [ ] Payment list
  - [ ] Add payment form
  - [ ] Payment method picker
  - [ ] Complete payment action
  - [ ] Payment history
- [ ] Receipt Management
  - [ ] Receipt list
  - [ ] Create receipt form
  - [ ] Select items & quantities
  - [ ] Complete receipt action
  - [ ] Receipt history

### 2.6 Widgets & Components
- [ ] PurchaseOrderCard widget
- [ ] PurchaseOrderStatusBadge widget
- [ ] PurchaseOrderItemCard widget
- [ ] PaymentCard widget
- [ ] ReceiptCard widget
- [ ] SupplierPicker widget
- [ ] ProductPickerForPO widget
- [ ] PaymentMethodPicker widget
- [ ] PurchaseOrderTimelineWidget

---

## 📦 Module 3: Inventory Management (موجودی انبار)

### 3.1 Data Layer
- [ ] Create Warehouse Model
- [ ] Create InventoryItem Model
- [ ] Create Transaction Model
- [ ] Create Transfer Model
- [ ] Create TransferItem Model
- [ ] Create Warehouse DTOs
- [ ] Create Transaction DTOs
- [ ] Create Transfer DTOs

### 3.2 API Service
- [ ] Setup WarehouseApiService
- [ ] Implement warehouse CRUD
- [ ] Implement warehouse stats
- [ ] Setup InventoryApiService
- [ ] Implement inventory endpoints
- [ ] Implement set stock endpoint
- [ ] Implement reserve/release endpoints
- [ ] Setup TransactionApiService
- [ ] Setup TransferApiService
- [ ] Implement transfer workflow (start, complete, cancel)

### 3.3 State Management
- [ ] Create WarehouseProvider
- [ ] Create InventoryProvider
- [ ] Create TransactionProvider
- [ ] Create TransferProvider
- [ ] Implement list states
- [ ] Implement detail states
- [ ] Implement CRUD states

### 3.4 UI - Main Screens
- [ ] Warehouse List Screen
  - [ ] Warehouse cards
  - [ ] Quick stats per warehouse
  - [ ] Add warehouse button
- [ ] Warehouse Detail Screen
  - [ ] Warehouse info
  - [ ] Inventory by warehouse
  - [ ] Warehouse stats
- [ ] Inventory Overview Screen
  - [ ] All products inventory
  - [ ] Stock level indicators
  - [ ] Low stock alerts
  - [ ] Filter by warehouse
- [ ] Product Inventory Detail Screen
  - [ ] Stock by warehouse
  - [ ] Transaction history
  - [ ] Set stock action
  - [ ] Reserve/release actions

### 3.5 UI - Transaction Management
- [ ] Transaction List Screen
  - [ ] Filter by type
  - [ ] Filter by warehouse
  - [ ] Date range filter
- [ ] Add Transaction Screen
  - [ ] Transaction type picker (IN/OUT/ADJUSTMENT)
  - [ ] Warehouse picker
  - [ ] Product picker
  - [ ] Quantity input
  - [ ] Reference info

### 3.6 UI - Transfer Management
- [ ] Transfer List Screen
  - [ ] Filter by status
  - [ ] Filter by warehouse
- [ ] Create Transfer Screen
  - [ ] From warehouse picker
  - [ ] To warehouse picker
  - [ ] Add items
  - [ ] Transfer date
- [ ] Transfer Detail Screen
  - [ ] Transfer info
  - [ ] Items list
  - [ ] Status badge
  - [ ] Action buttons (Start, Complete, Cancel)

### 3.7 Widgets & Components
- [ ] WarehouseCard widget
- [ ] StockLevelIndicator widget
- [ ] TransactionCard widget
- [ ] TransactionTypeBadge widget
- [ ] TransferCard widget
- [ ] TransferStatusBadge widget
- [ ] WarehousePicker widget

---

## 🏠 Module 4: Home Screen Integration

### 4.1 Home Screen Updates
- [ ] Add Supplier icon & navigation
- [ ] Add Purchase Order icon & navigation
- [ ] Add Inventory icon & navigation
- [ ] Update Quick Stats section
  - [ ] Add total suppliers stat
  - [ ] Add pending POs stat
  - [ ] Add low stock alerts stat
- [ ] Add Quick Actions
  - [ ] Quick add supplier
  - [ ] Quick create PO
  - [ ] Quick stock adjustment

### 4.2 Dashboard Stats
- [ ] Fetch supplier stats in DashboardProvider
- [ ] Fetch purchase order stats
- [ ] Fetch inventory stats
- [ ] Add charts for Phase 3 data
  - [ ] Purchase trends
  - [ ] Stock movement
  - [ ] Supplier performance

### 4.3 Navigation & Routing
- [ ] Add supplier routes
- [ ] Add purchase order routes
- [ ] Add inventory routes
- [ ] Update navigation drawer
- [ ] Add deep linking support
- [ ] Add bottom navigation items (if needed)

### 4.4 Search Integration
- [ ] Add suppliers to global search
- [ ] Add purchase orders to search
- [ ] Update search results UI
- [ ] Add filters to search

---

## 🔧 Module 5: Common Components & Utils

### 5.1 Shared Widgets
- [ ] StatusWorkflowWidget (for PO workflow)
- [ ] FileUploadWidget (for documents)
- [ ] DateRangePicker
- [ ] MultiSelectDialog
- [ ] ConfirmationDialog enhancements

### 5.2 Utils & Helpers
- [ ] SupplierStatusHelper
- [ ] PurchaseOrderStatusHelper
- [ ] TransactionTypeHelper
- [ ] FilePickerHelper
- [ ] PDFViewerHelper

### 5.3 Validators
- [ ] Supplier form validators
- [ ] Purchase order form validators
- [ ] Inventory form validators

---

## ✅ Module 6: Testing & Quality

### 6.1 Unit Tests
- [ ] Supplier model tests
- [ ] Purchase order model tests
- [ ] Inventory model tests
- [ ] Provider tests
- [ ] API service tests

### 6.2 Widget Tests
- [ ] Supplier screens tests
- [ ] Purchase order screens tests
- [ ] Inventory screens tests
- [ ] Widget component tests

### 6.3 Integration Tests
- [ ] Supplier flow test (Create → Edit → Delete)
- [ ] Purchase order flow test (Create → Approve → Receive)
- [ ] Inventory flow test (Add → Transfer → Adjust)
- [ ] End-to-end navigation test

### 6.4 Bug Fixes & Polish
- [ ] Fix any reported bugs
- [ ] UI/UX improvements
- [ ] Performance optimization
- [ ] Error handling improvements
- [ ] Loading states improvements
- [ ] Empty states improvements

---

## 📝 Notes & Conventions

### File Naming
- Models: `{name}_model.dart` (e.g., `supplier_model.dart`)
- DTOs: `{action}_{name}_dto.dart` (e.g., `create_supplier_dto.dart`)
- Services: `{name}_api_service.dart`
- Providers: `{name}_provider.dart`
- Pages: `{name}_page.dart`
- Widgets: `{name}_widget.dart`

### Code Style
- Follow existing Flutter project structure
- Use Provider for state management
- Follow API contracts from `api-contracts/` folder
- Use proper error handling with try-catch
- Show loading states during API calls
- Show snackbars for success/error messages

### API Integration
- Base URL from environment config
- Add businessId to all requests
- Include Bearer token in headers
- Handle 401 (redirect to login)
- Handle 403 (show permission error)
- Handle 404 (show not found)
- Handle 500 (show server error)

---

## 🎯 Completion Criteria

### Definition of Done (DoD) for Each Task:
- [ ] Code written and tested locally
- [ ] No compile errors
- [ ] No runtime errors
- [ ] UI matches design patterns
- [ ] API integration working
- [ ] Error handling implemented
- [ ] Loading states working
- [ ] Success/error messages shown
- [ ] Navigation working
- [ ] Code reviewed (if team)
- [ ] Committed to git

### Module Completion:
- [ ] All tasks completed
- [ ] Integration tests passing
- [ ] No critical bugs
- [ ] Documentation updated
- [ ] Demo ready

---

## 📅 Timeline Estimate

- **Module 1 (Supplier)**: 5-7 days
- **Module 2 (Purchase Order)**: 6-8 days
- **Module 3 (Inventory)**: 6-8 days
- **Module 4 (Integration)**: 2-3 days
- **Module 5 (Common)**: 2-3 days
- **Module 6 (Testing)**: 3-4 days

**Total**: 24-33 days (4-6 weeks)

---

## 🚀 Next Steps

1. Start with Supplier Module (foundational)
2. Then Purchase Order (depends on Supplier)
3. Then Inventory (can be parallel with PO)
4. Integrate all into Home Screen
5. Testing & Polish

**Current Focus**: Supplier Models & DTOs
