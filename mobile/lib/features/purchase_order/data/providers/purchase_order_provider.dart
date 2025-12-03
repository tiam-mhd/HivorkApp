import 'package:flutter/foundation.dart';
import '../models/purchase_order_model.dart';
import '../models/purchase_order_payment_model.dart';
import '../models/purchase_order_receipt_model.dart';
import '../dtos/purchase_order_dtos.dart';
import '../dtos/payment_dtos.dart';
import '../dtos/receipt_dtos.dart';
import '../services/purchase_order_api_service.dart';
import '../services/payment_api_service.dart';
import '../services/receipt_api_service.dart';
import '../enums/purchase_order_enums.dart';

/// Purchase Order Provider
/// مدیریت State برای Purchase Orders، Payments و Receipts
class PurchaseOrderProvider with ChangeNotifier {
  final PurchaseOrderApiService _purchaseOrderApiService;
  final PaymentApiService _paymentApiService;
  final ReceiptApiService _receiptApiService;

  PurchaseOrderProvider(
    this._purchaseOrderApiService,
    this._paymentApiService,
    this._receiptApiService,
  );

  // ========================
  // State - Purchase Orders
  // ========================
  List<PurchaseOrderModel> _purchaseOrders = [];
  PurchaseOrderModel? _selectedPurchaseOrder;
  PurchaseOrderStatsResponse? _stats;
  PaginationMeta? _pagination;

  bool _isLoading = false;
  String? _error;

  // State - Payments
  List<PurchaseOrderPaymentModel> _payments = [];
  PaymentSummary? _paymentSummary;
  bool _isLoadingPayments = false;

  // State - Receipts
  List<PurchaseOrderReceiptModel> _receipts = [];
  ReceiptSummary? _receiptSummary;
  bool _isLoadingReceipts = false;

  // Filters
  String? _supplierIdFilter;
  PurchaseOrderStatus? _statusFilter;
  PurchaseOrderType? _typeFilter;
  DateTime? _dateFromFilter;
  DateTime? _dateToFilter;
  double? _minAmountFilter;
  double? _maxAmountFilter;
  String? _searchQuery;

  // ========================
  // Getters - Purchase Orders
  // ========================
  List<PurchaseOrderModel> get purchaseOrders => _purchaseOrders;
  PurchaseOrderModel? get selectedPurchaseOrder => _selectedPurchaseOrder;
  PurchaseOrderStatsResponse? get stats => _stats;
  PaginationMeta? get pagination => _pagination;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters - Payments
  List<PurchaseOrderPaymentModel> get payments => _payments;
  PaymentSummary? get paymentSummary => _paymentSummary;
  bool get isLoadingPayments => _isLoadingPayments;

  // Getters - Receipts
  List<PurchaseOrderReceiptModel> get receipts => _receipts;
  ReceiptSummary? get receiptSummary => _receiptSummary;
  bool get isLoadingReceipts => _isLoadingReceipts;

  // Getters - Filters
  String? get supplierIdFilter => _supplierIdFilter;
  PurchaseOrderStatus? get filterStatus => _statusFilter;
  PurchaseOrderType? get filterType => _typeFilter;
  DateTime? get filterStartDate => _dateFromFilter;
  DateTime? get filterEndDate => _dateToFilter;
  double? get filterMinAmount => _minAmountFilter;
  double? get filterMaxAmount => _maxAmountFilter;
  String? get searchQuery => _searchQuery;

  bool get hasActiveFilters =>
      _supplierIdFilter != null ||
      _statusFilter != null ||
      _typeFilter != null ||
      _dateFromFilter != null ||
      _dateToFilter != null ||
      _minAmountFilter != null ||
      _maxAmountFilter != null ||
      _searchQuery != null;

  // ========================
  // Purchase Order CRUD
  // ========================

  /// Load purchase orders with filters
  Future<void> loadPurchaseOrders(
    String businessId, {
    int page = 1,
    int limit = 50,
  }) async {
    if (businessId.isEmpty) {
      _error = 'شناسه کسب‌وکار موجود نیست';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _purchaseOrderApiService.getPurchaseOrders(
        businessId,
        supplierId: _supplierIdFilter,
        status: _statusFilter?.value,
        dateFrom: _dateFromFilter?.toIso8601String(),
        dateTo: _dateToFilter?.toIso8601String(),
        minTotal: _minAmountFilter,
        maxTotal: _maxAmountFilter,
        page: page,
        limit: limit,
      );

      _purchaseOrders = response.data;
      _pagination = response.pagination;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _purchaseOrders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load purchase order by ID
  Future<void> loadPurchaseOrder(String id, String businessId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedPurchaseOrder =
          await _purchaseOrderApiService.getPurchaseOrder(id, businessId);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _selectedPurchaseOrder = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load purchase order by order number
  Future<void> loadPurchaseOrderByNumber(
    String orderNumber,
    String businessId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedPurchaseOrder = await _purchaseOrderApiService
          .getPurchaseOrderByNumber(orderNumber, businessId);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _selectedPurchaseOrder = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create purchase order
  Future<bool> createPurchaseOrder(
    String businessId,
    CreatePurchaseOrderDto dto,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final purchaseOrder =
          await _purchaseOrderApiService.createPurchaseOrder(dto, businessId);
      _purchaseOrders.insert(0, purchaseOrder);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update purchase order (only DRAFT)
  Future<bool> updatePurchaseOrder(
    String id,
    String businessId,
    UpdatePurchaseOrderDto dto,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _purchaseOrderApiService.updatePurchaseOrder(
        id,
        businessId,
        dto,
      );

      final index = _purchaseOrders.indexWhere((po) => po.id == id);
      if (index != -1) {
        _purchaseOrders[index] = updated;
      }

      if (_selectedPurchaseOrder?.id == id) {
        _selectedPurchaseOrder = updated;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete purchase order (only DRAFT)
  Future<bool> deletePurchaseOrder(String id, String businessId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _purchaseOrderApiService.deletePurchaseOrder(id, businessId);

      _purchaseOrders.removeWhere((po) => po.id == id);
      if (_selectedPurchaseOrder?.id == id) {
        _selectedPurchaseOrder = null;
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load purchase order statistics
  Future<void> loadStats(String businessId) async {
    try {
      _stats = await _purchaseOrderApiService.getPurchaseOrderStats(businessId);
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // ========================
  // Purchase Order Status Actions
  // ========================

  /// Approve purchase order
  Future<bool> approvePurchaseOrder(String id, String businessId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated =
          await _purchaseOrderApiService.approvePurchaseOrder(id, businessId);
      _updatePurchaseOrderInList(updated);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send purchase order to supplier
  Future<bool> sendPurchaseOrder(String id, String businessId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated =
          await _purchaseOrderApiService.sendPurchaseOrder(id, businessId);
      _updatePurchaseOrderInList(updated);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Confirm purchase order with supplier
  Future<bool> confirmPurchaseOrder(String id, String businessId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated =
          await _purchaseOrderApiService.confirmPurchaseOrder(id, businessId);
      _updatePurchaseOrderInList(updated);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancel purchase order
  Future<bool> cancelPurchaseOrder(
    String id,
    String businessId,
    String reason,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _purchaseOrderApiService.cancelPurchaseOrder(
        id,
        businessId,
        reason,
      );
      _updatePurchaseOrderInList(updated);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Close purchase order
  Future<bool> closePurchaseOrder(String id, String businessId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated =
          await _purchaseOrderApiService.closePurchaseOrder(id, businessId);
      _updatePurchaseOrderInList(updated);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========================
  // Payment Management
  // ========================

  /// Load payments for purchase order
  Future<void> loadPayments(String purchaseOrderId) async {
    _isLoadingPayments = true;
    notifyListeners();

    try {
      final response = await _paymentApiService.getPayments(purchaseOrderId);
      _payments = response.data;
      _paymentSummary = response.summary;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingPayments = false;
      notifyListeners();
    }
  }

  /// Create payment
  Future<bool> createPayment(
    String purchaseOrderId,
    String businessId,
    CreatePaymentDto dto,
  ) async {
    _isLoadingPayments = true;
    notifyListeners();

    try {
      final payment = await _paymentApiService.createPayment(
        purchaseOrderId,
        dto,
        businessId,
      );
      _payments.insert(0, payment);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoadingPayments = false;
      notifyListeners();
    }
  }

  /// Complete payment
  Future<bool> completePayment(String purchaseOrderId, String paymentId) async {
    _isLoadingPayments = true;
    notifyListeners();

    try {
      final updated =
          await _paymentApiService.completePayment(purchaseOrderId, paymentId);
      _updatePaymentInList(updated);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoadingPayments = false;
      notifyListeners();
    }
  }

  /// Delete payment (only PENDING)
  Future<bool> deletePayment(String purchaseOrderId, String paymentId) async {
    _isLoadingPayments = true;
    notifyListeners();

    try {
      await _paymentApiService.deletePayment(purchaseOrderId, paymentId);
      _payments.removeWhere((p) => p.id == paymentId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoadingPayments = false;
      notifyListeners();
    }
  }

  // ========================
  // Receipt Management
  // ========================

  /// Load receipts for purchase order
  Future<void> loadReceipts(String purchaseOrderId) async {
    _isLoadingReceipts = true;
    notifyListeners();

    try {
      final response = await _receiptApiService.getReceipts(purchaseOrderId);
      _receipts = response.data;
      _receiptSummary = response.summary;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingReceipts = false;
      notifyListeners();
    }
  }

  /// Create receipt
  Future<bool> createReceipt(
    String purchaseOrderId,
    String businessId,
    CreateReceiptDto dto,
  ) async {
    _isLoadingReceipts = true;
    notifyListeners();

    try {
      final receipt = await _receiptApiService.createReceipt(
        purchaseOrderId,
        dto,
        businessId,
      );
      _receipts.insert(0, receipt);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoadingReceipts = false;
      notifyListeners();
    }
  }

  /// Complete receipt
  Future<bool> completeReceipt(String purchaseOrderId, String receiptId) async {
    _isLoadingReceipts = true;
    notifyListeners();

    try {
      final updated =
          await _receiptApiService.completeReceipt(purchaseOrderId, receiptId);
      _updateReceiptInList(updated);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoadingReceipts = false;
      notifyListeners();
    }
  }

  /// Delete receipt (only DRAFT)
  Future<bool> deleteReceipt(String purchaseOrderId, String receiptId) async {
    _isLoadingReceipts = true;
    notifyListeners();

    try {
      await _receiptApiService.deleteReceipt(purchaseOrderId, receiptId);
      _receipts.removeWhere((r) => r.id == receiptId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoadingReceipts = false;
      notifyListeners();
    }
  }

  // ========================
  // Filter Management
  // ========================

  void setSupplierFilter(String? supplierId) {
    _supplierIdFilter = supplierId;
    notifyListeners();
  }

  void setStatusFilter(PurchaseOrderStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setTypeFilter(PurchaseOrderType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  void setDateRangeFilter(DateTime? from, DateTime? to) {
    _dateFromFilter = from;
    _dateToFilter = to;
    notifyListeners();
  }

  void setAmountRangeFilter(double? min, double? max) {
    _minAmountFilter = min;
    _maxAmountFilter = max;
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _supplierIdFilter = null;
    _statusFilter = null;
    _typeFilter = null;
    _dateFromFilter = null;
    _dateToFilter = null;
    _minAmountFilter = null;
    _maxAmountFilter = null;
    _searchQuery = null;
    notifyListeners();
  }

  // ========================
  // Helper Methods
  // ========================

  void _updatePurchaseOrderInList(PurchaseOrderModel updated) {
    final index = _purchaseOrders.indexWhere((po) => po.id == updated.id);
    if (index != -1) {
      _purchaseOrders[index] = updated;
    }

    if (_selectedPurchaseOrder?.id == updated.id) {
      _selectedPurchaseOrder = updated;
    }
  }

  void _updatePaymentInList(PurchaseOrderPaymentModel updated) {
    final index = _payments.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _payments[index] = updated;
    }
  }

  void _updateReceiptInList(PurchaseOrderReceiptModel updated) {
    final index = _receipts.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _receipts[index] = updated;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPurchaseOrder = null;
    notifyListeners();
  }
}
