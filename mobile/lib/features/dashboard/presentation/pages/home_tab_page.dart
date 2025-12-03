import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../business/data/models/business_model.dart';
import '../../data/providers/dashboard_provider.dart';
import '../../../../core/utils/number_formatter.dart';
import 'dart:math' as math;

class HomeTabPage extends StatefulWidget {
  final Business? activeBusiness;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  
  const HomeTabPage({
    super.key,
    this.activeBusiness,
    this.scaffoldKey,
  });

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;

  @override
  void initState() {
    super.initState();
    
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _cardsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );

    _cardsAnimation = CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeOutBack,
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardsAnimationController.forward();
    });
    
    // بارگذاری داده‌ها
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.activeBusiness != null) {
        context.read<DashboardProvider>().loadDashboardData(widget.activeBusiness!.id);
      }
    });
  }

  @override
  void didUpdateWidget(HomeTabPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeBusiness?.id != oldWidget.activeBusiness?.id) {
      if (widget.activeBusiness != null) {
        context.read<DashboardProvider>().loadDashboardData(widget.activeBusiness!.id);
      }
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.menu_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          onPressed: () {
            widget.scaffoldKey?.currentState?.openDrawer();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/branding/Logo.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              'هایورک',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.onSurface,
              ),
            ),
            onPressed: () {
              // Handle notifications
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Animated Header
          FadeTransition(
            opacity: _headerAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(_headerAnimation),
              child: _buildWelcomeHeader(context),
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Stats Overview Cards
          AnimatedBuilder(
            animation: _cardsAnimation,
            builder: (context, child) {
              final opacity = _cardsAnimation.value.clamp(0.0, 1.0);
              return Transform.scale(
                scale: 0.8 + (0.2 * _cardsAnimation.value),
                child: Opacity(
                  opacity: opacity,
                  child: child,
                ),
              );
            },
            child: _buildStatsOverview(context),
          ),
          
          const SizedBox(height: 28),
          
          // Quick Insights
          _buildSectionHeader(context, 'نگاه سریع', Icons.insights),
          const SizedBox(height: 16),
          _buildQuickInsights(context),
          
          const SizedBox(height: 28),
          
          // Recent Activity
          _buildSectionHeader(context, 'فعالیت‌های اخیر', Icons.history),
          const SizedBox(height: 16),
          _buildRecentActivity(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    String greeting = 'سلام';
    IconData greetingIcon = Icons.wb_sunny;
    
    if (hour < 12) {
      greeting = 'صبح بخیر';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 18) {
      greeting = 'بعدازظهر بخیر';
      greetingIcon = Icons.wb_cloudy;
    } else {
      greeting = 'عصر بخیر';
      greetingIcon = Icons.nights_stay;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  greetingIcon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.activeBusiness?.name ?? 'کسب و کار شما',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (widget.activeBusiness != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                if (widget.activeBusiness!.industry != null)
                  _buildInfoChip(
                    widget.activeBusiness!.industry!.name,
                    Icons.work_outline,
                  ),
                const SizedBox(width: 8),
                if (widget.activeBusiness!.category != null)
                  _buildInfoChip(
                    widget.activeBusiness!.category!.name,
                    Icons.category_outlined,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final stats = provider.stats;
        
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _buildStatCard(
              context,
              title: 'فروش امروز',
              value: NumberFormatter.formatCurrency(stats.todaySales),
              unit: 'تومان',
              icon: Icons.trending_up,
              color: Colors.green,
              trend: stats.todaySales > 0 ? '+${NumberFormatter.toPersianNumber(stats.todaySales.toInt().toString())}' : '۰',
              trendPositive: stats.todaySales > 0,
            ),
            _buildStatCard(
              context,
              title: 'فاکتورها',
              value: NumberFormatter.toPersianNumber(stats.totalInvoices.toString()),
              unit: 'فاکتور',
              icon: Icons.receipt_long,
              color: Colors.blue,
              trend: '+${NumberFormatter.toPersianNumber(stats.finalizedInvoices.toString())}',
              trendPositive: true,
            ),
            _buildStatCard(
              context,
              title: 'مشتریان',
              value: NumberFormatter.toPersianNumber(stats.totalCustomers.toString()),
              unit: 'نفر',
              icon: Icons.people,
              color: Colors.purple,
              trend: '+${NumberFormatter.toPersianNumber(stats.newCustomersThisMonth.toString())}',
              trendPositive: true,
            ),
            _buildStatCard(
              context,
              title: 'محصولات',
              value: NumberFormatter.toPersianNumber(stats.totalProducts.toString()),
              unit: 'کالا',
              icon: Icons.inventory_2,
              color: Colors.orange,
              trend: stats.lowStockProducts > 0 
                  ? '${NumberFormatter.toPersianNumber(stats.lowStockProducts.toString())} کم'
                  : 'عالی',
              trendPositive: stats.lowStockProducts == 0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required String trend,
    required bool trendPositive,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (trendPositive ? Colors.green : Colors.red).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: trendPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: trendPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInsights(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SizedBox.shrink();
        }
        
        final stats = provider.stats;
        
        return Column(
          children: [
            _buildInsightCard(
              context,
              title: 'موجودی کم',
              subtitle: stats.lowStockProducts > 0 
                  ? '${NumberFormatter.toPersianNumber(stats.lowStockProducts.toString())} محصول'
                  : 'همه محصولات کافی',
              value: stats.lowStockProducts > 0 ? 'نیاز به سفارش' : 'عالی',
              icon: stats.lowStockProducts > 0 ? Icons.warning_amber : Icons.check_circle,
              color: stats.lowStockProducts > 0 ? Colors.orange : Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              context,
              title: 'مشتریان فعال',
              subtitle: '${NumberFormatter.toPersianNumber(stats.activeCustomers.toString())} مشتری',
              value: '${NumberFormatter.formatCurrency(stats.totalSales)} فروش',
              icon: Icons.person_outline,
              color: Colors.indigo,
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              context,
              title: 'فاکتورهای پیش‌نویس',
              subtitle: '${NumberFormatter.toPersianNumber(stats.draftInvoices.toString())} فاکتور',
              value: stats.draftInvoices > 0 ? 'نیاز به تکمیل' : 'همه نهایی شده',
              icon: stats.draftInvoices > 0 ? Icons.pending_actions : Icons.check_circle_outline,
              color: stats.draftInvoices > 0 ? Colors.orange : Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SizedBox.shrink();
        }
        
        final stats = provider.stats;
        
        // فعالیت‌های ساختگی بر اساس داده‌های واقعی
        final activities = <Map<String, dynamic>>[];
        
        if (stats.finalizedInvoices > 0) {
          activities.add({
            'title': 'فاکتور جدید نهایی شد',
            'subtitle': '${NumberFormatter.toPersianNumber(stats.finalizedInvoices.toString())} فاکتور امروز نهایی شده',
            'icon': Icons.receipt_long,
            'color': Colors.blue,
          });
        }
        
        if (stats.newCustomersThisMonth > 0) {
          activities.add({
            'title': 'مشتریان جدید اضافه شدند',
            'subtitle': '${NumberFormatter.toPersianNumber(stats.newCustomersThisMonth.toString())} مشتری این ماه',
            'icon': Icons.person_add,
            'color': Colors.green,
          });
        }
        
        if (stats.todaySales > 0) {
          activities.add({
            'title': 'فروش امروز',
            'subtitle': 'مبلغ ${NumberFormatter.formatCurrency(stats.todaySales)} تومان',
            'icon': Icons.attach_money,
            'color': Colors.green,
          });
        }
        
        if (stats.todayExpenses > 0) {
          activities.add({
            'title': 'هزینه‌های امروز',
            'subtitle': 'مبلغ ${NumberFormatter.formatCurrency(stats.todayExpenses)} تومان',
            'icon': Icons.payment,
            'color': Colors.red,
          });
        }
        
        if (stats.lowStockProducts > 0) {
          activities.add({
            'title': 'هشدار موجودی کم',
            'subtitle': '${NumberFormatter.toPersianNumber(stats.lowStockProducts.toString())} محصول نیاز به سفارش',
            'icon': Icons.warning_amber,
            'color': Colors.orange,
          });
        }
        
        if (activities.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'هیچ فعالیتی ثبت نشده',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Column(
          children: activities.take(5).map((activity) {
            return _buildActivityItem(
              context,
              title: activity['title'],
              subtitle: activity['subtitle'],
              time: 'امروز',
              icon: activity['icon'],
              color: activity['color'],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
