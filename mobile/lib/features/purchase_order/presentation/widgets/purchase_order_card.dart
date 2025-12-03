import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/purchase_order_model.dart';
import '../../data/enums/purchase_order_enums.dart';

class PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrderModel purchaseOrder;
  final VoidCallback onTap;

  const PurchaseOrderCard({
    Key? key,
    required this.purchaseOrder,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final numberFormat = NumberFormat('#,##0', 'fa');
    final dateFormat = DateFormat('yyyy/MM/dd', 'fa');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order Number & Status
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            purchaseOrder.orderNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, purchaseOrder.status),
                ],
              ),
              const SizedBox(height: 12),

              // Supplier Info
              if (purchaseOrder.supplier != null)
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        purchaseOrder.supplier!.name,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),

              // Order Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'تاریخ سفارش: ${dateFormat.format(purchaseOrder.orderDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (purchaseOrder.expectedDeliveryDate != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.local_shipping,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(purchaseOrder.expectedDeliveryDate!),
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              const Divider(height: 1),
              const SizedBox(height: 12),

              // Financial Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مبلغ کل',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${numberFormat.format(double.tryParse(purchaseOrder.totalAmount) ?? 0)} ریال',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  // Paid Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'پرداخت شده',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${numberFormat.format(double.tryParse(purchaseOrder.paidAmount) ?? 0)} ریال',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),

                  // Remaining Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'باقیمانده',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${numberFormat.format(double.tryParse(purchaseOrder.remainingAmount) ?? 0)} ریال',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: (double.tryParse(purchaseOrder.remainingAmount) ?? 0) > 0
                              ? colorScheme.error
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Items Count
              if (purchaseOrder.items.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${purchaseOrder.items.length} قلم کالا',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, PurchaseOrderStatus status) {
    final theme = Theme.of(context);
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case PurchaseOrderStatus.draft:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
      case PurchaseOrderStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        break;
      case PurchaseOrderStatus.approved:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        break;
      case PurchaseOrderStatus.sent:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade900;
        break;
      case PurchaseOrderStatus.confirmed:
        backgroundColor = Colors.teal.shade100;
        textColor = Colors.teal.shade900;
        break;
      case PurchaseOrderStatus.partiallyReceived:
        backgroundColor = Colors.amber.shade100;
        textColor = Colors.amber.shade900;
        break;
      case PurchaseOrderStatus.received:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;
      case PurchaseOrderStatus.cancelled:
        backgroundColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.error;
        break;
      case PurchaseOrderStatus.closed:
        backgroundColor = Colors.grey.shade300;
        textColor = Colors.grey.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
