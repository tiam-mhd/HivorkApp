import 'package:flutter/material.dart';
import '../../data/models/invoice.dart';
import 'invoice_status_badge.dart';
import '../../../../core/utils/number_formatter.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFinalize;

  const InvoiceCard({
    Key? key,
    required this.invoice,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onFinalize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final borderColor = theme.dividerColor.withOpacity(isDark ? 0.25 : 0.15);
    final textColor = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onEdit != null || onDelete != null
          ? () => _showContextMenu(context)
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // آیکون نوع - کوچکتر
            Icon(
              invoice.type == InvoiceType.sales
                  ? Icons.receipt_long_outlined
                  : Icons.description_outlined,
              size: 20,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(width: 10),

            // اطلاعات اصلی
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          invoice.invoiceNumber,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      InvoiceStatusBadge(
                        status: invoice.status,
                        type: InvoiceStatusBadgeType.status,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invoice.customerName ?? 'نامشخص',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // مبلغ
            Text(
              NumberFormatter.formatCurrency(invoice.totalAmount),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onFinalize != null && invoice.status == InvoiceStatus.draft)
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                title: const Text('نهایی کردن'),
                onTap: () {
                  Navigator.pop(context);
                  onFinalize!();
                },
              ),
            if (onEdit != null && invoice.status == InvoiceStatus.draft)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('ویرایش'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit!();
                },
              ),
            if (onDelete != null && invoice.status == InvoiceStatus.draft)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('حذف'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete!();
                },
              ),
          ],
        ),
      ),
    );
  }
}
