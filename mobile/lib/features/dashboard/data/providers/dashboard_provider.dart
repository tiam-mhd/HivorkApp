import 'package:flutter/foundation.dart';
import '../../../product/data/services/product_api_service.dart';
import '../../../product/data/models/product_stats.dart';
import '../../../customer/data/services/customer_api_service.dart';
import '../../../customer/data/models/customer_stats.dart';
import '../../../invoice/data/services/invoice_service.dart';
import '../../../expense/services/expense_api_service.dart';
import '../../../expense/models/models.dart';

class DashboardStats {
  final int totalProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  
  final int totalCustomers;
  final int activeCustomers;
  final int newCustomersThisMonth;
  
  final int totalInvoices;
  final int draftInvoices;
  final int finalizedInvoices;
  final double totalSales;
  final double todaySales;
  final double paidAmount;
  final double unpaidAmount;
  
  final double totalExpenses;
  final double todayExpenses;

  DashboardStats({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.totalCustomers,
    required this.activeCustomers,
    required this.newCustomersThisMonth,
    required this.totalInvoices,
    required this.draftInvoices,
    required this.finalizedInvoices,
    required this.totalSales,
    required this.todaySales,
    required this.paidAmount,
    required this.unpaidAmount,
    required this.totalExpenses,
    required this.todayExpenses,
  });

  static DashboardStats empty() {
    return DashboardStats(
      totalProducts: 0,
      lowStockProducts: 0,
      outOfStockProducts: 0,
      totalCustomers: 0,
      activeCustomers: 0,
      newCustomersThisMonth: 0,
      totalInvoices: 0,
      draftInvoices: 0,
      finalizedInvoices: 0,
      totalSales: 0,
      todaySales: 0,
      paidAmount: 0,
      unpaidAmount: 0,
      totalExpenses: 0,
      todayExpenses: 0,
    );
  }
}

class DashboardProvider extends ChangeNotifier {
  final ProductApiService _productApi;
  final CustomerApiService _customerApi;
  final InvoiceService _invoiceService;
  final ExpenseApiService _expenseApi;

  DashboardProvider(
    this._productApi,
    this._customerApi,
    this._invoiceService,
    this._expenseApi,
  );

  DashboardStats _stats = DashboardStats.empty();
  bool _isLoading = false;
  String? _error;

  DashboardStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardData(String businessId) async {
    if (businessId.isEmpty) {
      _error = 'شناسه کسب‌وکار موجود نیست';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // بارگذاری موازی همه داده‌ها
      final results = await Future.wait([
        _productApi.getProductStats(businessId),
        _customerApi.getCustomerStats(businessId),
        _invoiceService.getStats(businessId: businessId),
        _loadExpenseStats(businessId),
      ]);

      final productStats = results[0] as ProductStats;
      final customerStats = results[1] as CustomerStats;
      final invoiceStats = results[2] as Map<String, dynamic>;
      final expenseStats = results[3] as Map<String, double>;

      _stats = DashboardStats(
        // Product stats
        totalProducts: productStats.total,
        lowStockProducts: productStats.lowStock,
        outOfStockProducts: productStats.outOfStock,
        
        // Customer stats
        totalCustomers: customerStats.total,
        activeCustomers: customerStats.active,
        newCustomersThisMonth: 0, // این فیلد در API موجود نیست
        
        // Invoice stats
        totalInvoices: invoiceStats['total'] ?? 0,
        draftInvoices: invoiceStats['byStatus']?['draft'] ?? 0,
        finalizedInvoices: invoiceStats['byStatus']?['finalized'] ?? 0,
        totalSales: (invoiceStats['totalAmount'] ?? 0).toDouble(),
        todaySales: (invoiceStats['todayAmount'] ?? 0).toDouble(),
        paidAmount: (invoiceStats['paidAmount'] ?? 0).toDouble(),
        unpaidAmount: (invoiceStats['unpaidAmount'] ?? 0).toDouble(),
        
        // Expense stats
        totalExpenses: expenseStats['total'] ?? 0,
        todayExpenses: expenseStats['today'] ?? 0,
      );

      _error = null;
    } catch (e) {
      _error = 'خطا در بارگذاری داده‌ها: ${e.toString()}';
      _stats = DashboardStats.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, double>> _loadExpenseStats(String businessId) async {
    try {
      final expenses = await _expenseApi.getExpenses(businessId: businessId);
      
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      
      final todayExpenses = expenses
          .where((e) => 
              e.expenseDate.isAfter(todayStart) && 
              e.expenseDate.isBefore(todayEnd))
          .fold<double>(0, (sum, e) => sum + e.amount);
      
      final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

      return {
        'total': total,
        'today': todayExpenses,
      };
    } catch (e) {
      print('❌ Error loading expense stats: $e');
      return {'total': 0, 'today': 0};
    }
  }

  void refresh(String businessId) {
    loadDashboardData(businessId);
  }
}
