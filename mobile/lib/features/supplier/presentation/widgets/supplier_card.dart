import 'package:flutter/material.dart';
import '../../data/models/supplier_model.dart';

class SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback? onTap;

  const SupplierCard({
    Key? key,
    required this.supplier,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (supplier.legalName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            supplier.legalName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'کد: ${supplier.code}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(context, supplier.status),
                ],
              ),
              const SizedBox(height: 12),

              // Type Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      supplier.type.typeText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (supplier.industry != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        supplier.industry!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Contact Info
              if (supplier.phone != null || supplier.email != null) ...[
                Row(
                  children: [
                    if (supplier.phone != null) ...[
                      Icon(Icons.phone, size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        supplier.phone!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (supplier.phone != null && supplier.email != null)
                      const SizedBox(width: 16),
                    if (supplier.email != null) ...[
                      Icon(Icons.email, size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          supplier.email!,
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Location
              if (supplier.city != null || supplier.province != null) ...[
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      [supplier.city, supplier.province]
                          .where((e) => e != null)
                          .join('، '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              Divider(height: 16, color: colorScheme.outlineVariant),

              // Financial Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Balance
                  if (supplier.balance != 0)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                supplier.hasDebt
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16,
                                color: supplier.hasDebt ? colorScheme.error : const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                supplier.hasDebt ? 'بدهی' : 'بستانکار',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: supplier.hasDebt ? colorScheme.error : const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${supplier.balance.abs().toStringAsFixed(0)} تومان',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: supplier.hasDebt ? colorScheme.error : const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Total Orders
                  if (supplier.totalOrders > 0)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سفارشات',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${supplier.totalOrders}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Quality Rating
                  if ((double.tryParse(supplier.qualityRating) ?? 0) > 0)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'کیفیت',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: colorScheme.tertiary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                (double.tryParse(supplier.qualityRating) ?? 0).toStringAsFixed(1),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, SupplierStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color color;
    switch (status) {
      case SupplierStatus.draft:
        color = colorScheme.onSurfaceVariant;
        break;
      case SupplierStatus.pending:
        color = const Color(0xFFFFC107); // warning
        break;
      case SupplierStatus.approved:
        color = const Color(0xFF10B981); // success
        break;
      case SupplierStatus.suspended:
        color = colorScheme.tertiary;
        break;
      case SupplierStatus.blocked:
        color = colorScheme.error;
        break;
      case SupplierStatus.archived:
        color = colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.statusText,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
