import 'package:flutter/material.dart';
import '../../../business/data/models/business_model.dart';
import '../../../product/presentation/pages/product_form_page.dart';
import '../../../customer/presentation/pages/customer_form_page.dart';
import '../../../customer/presentation/bloc/customer_bloc.dart';
import '../../../customer/data/repositories/customer_repository.dart';
import '../../../customer/data/services/customer_api_service.dart';
import '../../../../core/di/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/business_analytics_widget.dart';

class HomeTabPage extends StatelessWidget {
  final Business? activeBusiness;
  
  const HomeTabPage({
    super.key,
    this.activeBusiness,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Business Info Card
          if (activeBusiness != null) ...[
            _buildBusinessInfoCard(context, activeBusiness!),
            const SizedBox(height: 16),
          ],
          
          // Business Analytics Widget
          BusinessAnalyticsWidget(activeBusiness: activeBusiness),
          
          const SizedBox(height: 16),
          
          // Quick Actions
          Text(
            'دسترسی سریع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 12),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildQuickActionCard(
                context,
                icon: Icons.add_circle_outline,
                title: 'فاکتور جدید',
                color: Colors.blue,
              ),
              _buildQuickActionCard(
                context,
                icon: Icons.person_add_outlined,
                title: 'مشتری جدید',
                color: Colors.green,
                onTap: () {
                  if (activeBusiness != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => CustomerBloc(
                            CustomerRepository(
                              CustomerApiService(ServiceLocator().dio),
                            ),
                          ),
                          child: CustomerFormPage(
                            businessId: activeBusiness!.id,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              _buildQuickActionCard(
                context,
                icon: Icons.inventory_outlined,
                title: 'افزودن محصول',
                color: Colors.orange,
                onTap: () {
                  if (activeBusiness != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductFormPage(
                          businessId: activeBusiness!.id,
                        ),
                      ),
                    );
                  }
                },
              ),
              _buildQuickActionCard(
                context,
                icon: Icons.payments_outlined,
                title: 'هزینه جدید',
                color: Colors.red,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          Text(
            'فعالیت‌های اخیر',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 12),
          
          ...List.generate(5, (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    index % 3 == 0 
                        ? Icons.receipt_long
                        : index % 3 == 1
                            ? Icons.person
                            : Icons.shopping_bag,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        index % 3 == 0 
                            ? 'فاکتور جدید ثبت شد'
                            : index % 3 == 1
                                ? 'مشتری جدید اضافه شد'
                                : 'محصول جدید ثبت شد',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${index + 1} دقیقه پیش',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap ?? () {
        // Handle quick action
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBusinessInfoCard(BuildContext context, Business business) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(isDark ? 0.6 : 0.7),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(isDark ? 0.4 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business,
                  color: theme.colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (business.tradeName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        business.tradeName!,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          if (business.category != null || business.industry != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (business.category != null)
                  _buildChip(
                    context,
                    label: business.category!.name,
                    icon: Icons.category,
                  ),
                if (business.industry != null)
                  _buildChip(
                    context,
                    label: business.industry!.name,
                    icon: Icons.work,
                  ),
              ],
            ),
          ],
          
          if (business.description != null && business.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              business.description!,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              if (business.phone != null) ...[
                Expanded(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.phone,
                    text: business.phone!,
                  ),
                ),
              ],
              if (business.email != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.email,
                    text: business.email!,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildChip(BuildContext context, {required String label, required IconData icon}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark 
            ? theme.colorScheme.surface.withOpacity(0.7)
            : theme.colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 14, 
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(BuildContext context, {required IconData icon, required String text}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withOpacity(0.6)
            : theme.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon, 
              size: 14, 
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
