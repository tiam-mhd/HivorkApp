import 'package:flutter/material.dart';
import '../../data/models/invoice.dart';
import 'invoice_status_badge.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/extensions/date_extensions.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFinalize;
  final VoidCallback? onCancel;
  final VoidCallback? onDuplicate;

  const InvoiceCard({
    Key? key,
    required this.invoice,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onFinalize,
    this.onCancel,
    this.onDuplicate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Invoice Number & Type Icon
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _getTypeColor(invoice.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _getTypeIcon(invoice.type),
                            size: 16,
                            color: _getTypeColor(invoice.type),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice.invoiceNumber,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                invoice.type.label,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  InvoiceStatusBadge(
                    status: invoice.status,
                    type: InvoiceStatusBadgeType.status,
                  ),
                  // Menu
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      if (invoice.status == InvoiceStatus.draft && onFinalize != null)
                        PopupMenuItem(
                          value: 'finalize',
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'تایید و کسر موجودی',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      if (invoice.status == InvoiceStatus.finalized && onCancel != null)
                        PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(
                                Icons.cancel_rounded,
                                size: 18,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'لغو فاکتور',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      if (invoice.status == InvoiceStatus.draft && onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text('ویرایش'),
                            ],
                          ),
                        ),
                      if (onDuplicate != null)
                        PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.copy_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text('کپی فاکتور'),
                            ],
                          ),
                        ),
                      if (invoice.status == InvoiceStatus.draft && onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_rounded,
                                size: 18,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'حذف',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'finalize':
                          onFinalize?.call();
                          break;
                        case 'cancel':
                          onCancel?.call();
                          break;
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'duplicate':
                          onDuplicate?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
              const SizedBox(height: 8),

              // Customer & Date Row
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            invoice.customerName ?? 'نامشخص',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        invoice.issueDate.toPersianDate(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Amount & Payment Status Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'مبلغ:',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              NumberFormatter.formatCurrency(invoice.totalAmount),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (invoice.type == InvoiceType.sales && 
                      invoice.paymentStatus != null) ...[
                    const SizedBox(width: 8),
                    InvoiceStatusBadge(
                      status: invoice.paymentStatus!,
                      type: InvoiceStatusBadgeType.payment,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(InvoiceType type) {
    switch (type) {
      case InvoiceType.sales:
        return Icons.shopping_cart_rounded;
      case InvoiceType.proforma:
        return Icons.description_rounded;
      case InvoiceType.purchase:
        return Icons.shopping_bag_rounded;
      case InvoiceType.returned:
        return Icons.keyboard_return_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _getTypeColor(InvoiceType type) {
    switch (type) {
      case InvoiceType.sales:
        return Colors.green;
      case InvoiceType.proforma:
        return Colors.blue;
      case InvoiceType.purchase:
        return Colors.orange;
      case InvoiceType.returned:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}