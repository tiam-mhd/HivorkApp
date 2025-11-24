import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hivork_app/features/invoice/presentation/pages/invoice_list_screen.dart';
import '../../../business/data/models/business_model.dart';
import '../../../product/data/services/product_api_service.dart';
import '../../../product/data/models/product_stats.dart';
import '../../../product/data/models/product_filter.dart';
import '../../../product/presentation/pages/products_page.dart';
import '../../../customer/data/services/customer_api_service.dart';
import '../../../customer/data/models/customer_stats.dart';
import '../../../customer/presentation/pages/customers_page.dart';
import '../../../invoice/data/services/invoice_provider.dart';
import '../../../invoice/data/services/invoice_service.dart';
import '../../../../core/di/service_locator.dart';

class BusinessAnalyticsWidget extends StatefulWidget {
  final Business? activeBusiness;
  
  const BusinessAnalyticsWidget({
    super.key,
    this.activeBusiness,
  });

  @override
  State<BusinessAnalyticsWidget> createState() => _BusinessAnalyticsWidgetState();
}

class _BusinessAnalyticsWidgetState extends State<BusinessAnalyticsWidget> {
  late final ProductApiService _productApi;
  late final CustomerApiService _customerApi;
  late final InvoiceService _invoiceService;
  ProductStats? _productStats;
  CustomerStats? _customerStats;
  Map<String, dynamic>? _invoiceStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final dio = ServiceLocator().dio;
    _productApi = ProductApiService(dio);
    _customerApi = CustomerApiService(dio);
    _invoiceService = InvoiceService(dio);
    if (widget.activeBusiness != null) {
      _loadStats();
    }
  }

  @override
  void didUpdateWidget(BusinessAnalyticsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeBusiness?.id != oldWidget.activeBusiness?.id) {
      if (widget.activeBusiness != null) {
        _loadStats();
      }
    }
  }

  Future<void> _loadStats() async {
    if (widget.activeBusiness == null) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      print('📊 Loading stats for business: ${widget.activeBusiness!.id}');
      
      final results = await Future.wait([
        _productApi.getProductStats(widget.activeBusiness!.id),
        _customerApi.getCustomerStats(widget.activeBusiness!.id),
        _invoiceService.getStats(businessId: widget.activeBusiness!.id),
      ]);
      
      print('📊 Stats loaded successfully');
      
      if (mounted) {
        setState(() {
          _productStats = results[0] as ProductStats;
          _customerStats = results[1] as CustomerStats;
          _invoiceStats = results[2] as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'آمار کلی',
                        style: TextStyle(
                          color: theme.colorScheme.surface,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'نمای کلی عملکرد',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'آمار امروز',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Analytics Grid
          _isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnalyticsCard(
                            context,
                            icon: Icons.people_outline,
                            title: 'مشتریان',
                            value: _customerStats?.total.toString() ?? '0',
                            subtitle: '${_customerStats?.active ?? 0} فعال',
                            color: isDark ? Color(0xFF60A5FA) : theme.colorScheme.primary,
                            onTap: widget.activeBusiness != null ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomersPage(
                                    businessId: widget.activeBusiness!.id,
                                  ),
                                ),
                              );
                            } : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildAnalyticsCard(
                            context,
                            icon: Icons.receipt_long_outlined,
                            title: 'فاکتورها',
                            value: _invoiceStats?['total']?.toString() ?? '0',
                            subtitle: '+${_invoiceStats?['today'] ?? 0} امروز',
                            color: isDark ? Color(0xFF7AADCE) : theme.colorScheme.secondary,
                            onTap: widget.activeBusiness != null ? () {
                              // تنظیم businessId در provider قبل از نمایش صفحه
                              final invoiceProvider = context.read<InvoiceProvider>();
                              invoiceProvider.setBusinessId(widget.activeBusiness!.id);
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const InvoiceListScreen(),
                                ),
                              );
                            } : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildAnalyticsCard(
                            context,
                            icon: Icons.inventory_2_outlined,
                            title: 'محصولات',
                            value: _productStats?.total.toString() ?? '0',
                            subtitle: '${_productStats?.active ?? 0} فعال',
                            color: isDark ? Color(0xFFFFC976) : theme.colorScheme.tertiary,
                            onTap: widget.activeBusiness != null ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductsPage(
                                    businessId: widget.activeBusiness!.id,
                                  ),
                                ),
                              );
                            } : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildAnalyticsCard(
                            context,
                            icon: Icons.warning_outlined,
                            title: 'کم موجود',
                            value: _productStats?.lowStock.toString() ?? '0',
                            subtitle: '${_productStats?.outOfStock ?? 0} ناموجود',
                            color: isDark ? Color(0xFFEF4444) : Color(0xFFDC2626),
                            onTap: widget.activeBusiness != null ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductsPage(
                                    businessId: widget.activeBusiness!.id,
                                    initialFilter: ProductFilter(lowStock: true),
                                  ),
                                ),
                              );
                            } : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
