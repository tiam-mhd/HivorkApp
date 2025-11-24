import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/invoice.dart';
import '../../data/services/invoice_provider.dart';
import '../../data/services/invoice_pdf_service.dart';
import '../widgets/invoice_status_badge.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/extensions/date_extensions.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  _InvoiceDetailScreenState createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvoice();
    });
  }

  Future<void> _loadInvoice() async {
    final provider = context.read<InvoiceProvider>();
    await provider.loadInvoiceDetails(widget.invoiceId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<InvoiceProvider>();
    final invoice = provider.selectedInvoice;

    return Scaffold(
      appBar: AppBar(
        title: Text(invoice?.invoiceNumber ?? 'جزئیات فاکتور'),
        actions: [
          if (invoice != null) ...[
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () => _shareInvoice(invoice),
              tooltip: 'اشتراک‌گذاری',
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded),
              onPressed: () => _generatePdf(invoice),
              tooltip: 'دانلود PDF',
            ),
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _editInvoice(invoice),
              tooltip: 'ویرایش',
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: const [
                      Icon(Icons.copy_rounded, size: 20),
                      SizedBox(width: 12),
                      Text('کپی فاکتور'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: const [
                      Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('حذف فاکتور', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'duplicate') {
                  _duplicateInvoice(invoice!);
                } else if (value == 'delete') {
                  _deleteInvoice(invoice!);
                }
              },
            ),
          ],
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? _buildError(provider.error!)
              : invoice == null
                  ? _buildNotFound()
                  : RefreshIndicator(
                      onRefresh: _loadInvoice,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(invoice, theme),
                            const SizedBox(height: 16),
                            _buildCustomerInfo(invoice, theme),
                            const SizedBox(height: 16),
                            _buildItemsTable(invoice, theme),
                            const SizedBox(height: 16),
                            _buildTotals(invoice, theme),
                            if (invoice.discountAmount > 0 ||
                                invoice.taxAmount > 0 ||
                                (invoice.extraCosts?.isNotEmpty ?? false)) ...[
                              const SizedBox(height: 16),
                              _buildAdditionalCharges(invoice, theme),
                            ],
                            if (invoice.payments?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 16),
                              _buildPayments(invoice, theme),
                            ],
                            if (invoice.notes?.isNotEmpty ?? false) ...[
                              const SizedBox(height: 16),
                              _buildNotes(invoice, theme),
                            ],
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildHeader(Invoice invoice, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'شماره فاکتور',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invoice.invoiceNumber,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                InvoiceStatusBadge(status: invoice.status, type: InvoiceStatusBadgeType.status,),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'نوع فاکتور',
                    invoice.type.label,
                    Icons.description_rounded,
                    theme,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'تاریخ صدور',
                    invoice.issueDate.toPersianDate(),
                    Icons.calendar_today_rounded,
                    theme,
                  ),
                ),
              ],
            ),
            if (invoice.type == InvoiceType.sales) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusChip(
                      'وضعیت پرداخت',
                      invoice.paymentStatus?.label ?? '-',
                      _getPaymentStatusColor(invoice.paymentStatus),
                      theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusChip(
                      'وضعیت ارسال',
                      invoice.shippingStatus?.label ?? '-',
                      _getShippingStatusColor(invoice.shippingStatus),
                      theme,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(Invoice invoice, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'اطلاعات مشتری',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (invoice.customer != null) ...[
              _buildInfoRow('نام مشتری', invoice.customer!.fullName, theme),
              if (invoice.customer!.phone?.isNotEmpty ?? false)
                _buildInfoRow('تلفن', invoice.customer!.phone!, theme),
              if (invoice.customer!.email?.isNotEmpty ?? false)
                _buildInfoRow('ایمیل', invoice.customer!.email!, theme),
              if (invoice.customer!.address?.isNotEmpty ?? false)
                _buildInfoRow('آدرس', invoice.customer!.address!, theme),
            ] else
              Text(
                'اطلاعات مشتری موجود نیست',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTable(Invoice invoice, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'اقلام فاکتور',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invoice.items.length,
              separatorBuilder: (context, index) => Divider(
                height: 24,
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
              itemBuilder: (context, index) {
                final item = invoice.items[index];
                return _buildItemRow(item, theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(InvoiceItem item, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                NumberFormatter.toPersianNumber(item.quantity.toString()),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.variant?.name?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.variant?.name ?? 'بدون نام',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'قیمت واحد: ${NumberFormatter.formatCurrency(item.unitPrice)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              NumberFormatter.formatCurrency(item.totalPrice),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotals(Invoice invoice, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('جمع کل', invoice.subtotal, theme, isBold: false),
            if (invoice.discountAmount > 0) ...[
              const SizedBox(height: 8),
              _buildTotalRow(
                'تخفیف ${_getDiscountLabel(invoice)}',
                -invoice.discountAmount,
                theme,
                isDiscount: true,
              ),
            ],
            if (invoice.taxAmount > 0) ...[
              const SizedBox(height: 8),
              _buildTotalRow('مالیات', invoice.taxAmount, theme),
            ],
            if (invoice.extraCostsTotal > 0) ...[
              const SizedBox(height: 8),
              _buildTotalRow('هزینه‌های اضافی', invoice.extraCostsTotal, theme),
            ],
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.onSurface.withOpacity(0.2)),
            const SizedBox(height: 12),
            _buildTotalRow(
              'مبلغ نهایی',
              invoice.totalAmount,
              theme,
              isBold: true,
              isFinal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalCharges(Invoice invoice, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'هزینه‌های اضافی',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (invoice.extraCosts?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              ...invoice.extraCosts!.map((cost) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildInfoRow(
                      cost.description ?? 'بدون توضیح',
                      NumberFormatter.formatCurrency(cost.amount),
                      theme,
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPayments(Invoice invoice, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'پرداخت‌ها',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invoice.payments!.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final payment = invoice.payments![index];
                return _buildPaymentRow(payment, theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(InvoicePayment payment, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payment.paymentMethod.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                NumberFormatter.formatCurrency(payment.amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          if (payment.notes?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Text(
              payment.notes!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            payment.paymentDate.toPersianDate(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes(Invoice invoice, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'یادداشت',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              invoice.notes!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    String label,
    String value,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount,
    ThemeData theme, {
    bool isBold = false,
    bool isFinal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isFinal ? 16 : 14,
          ),
        ),
        Text(
          '${isDiscount ? "-" : ""}${NumberFormatter.formatCurrency(amount.abs())}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isFinal ? 18 : 14,
            color: isFinal
                ? theme.colorScheme.primary
                : isDiscount
                    ? Colors.red
                    : null,
          ),
        ),
      ],
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadInvoice,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'فاکتور یافت نشد',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بازگشت'),
          ),
        ],
      ),
    );
  }

  String _getDiscountLabel(Invoice invoice) {
    if (invoice.discountType == DiscountType.percentage) {
      return '(${NumberFormatter.toPersianNumber(invoice.discountValue?.toStringAsFixed(0) ?? '0')}%)';
    }
    return '';
  }

  Color _getPaymentStatusColor(PaymentStatus? status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.partial:
        return Colors.orange;
      case PaymentStatus.unpaid:
        return Colors.blue;
      // case PaymentStatus.OVERDUE:
      //   return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getShippingStatusColor(ShippingStatus? status) {
    switch (status) {
      case ShippingStatus.delivered:
        return Colors.green;
      case ShippingStatus.shipped:
        return Colors.blue;
      case ShippingStatus.processing:
        return Colors.orange;
      case ShippingStatus.pending:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _shareInvoice(Invoice invoice) async {
    try {
      final pdfService = InvoicePdfService();
      await pdfService.shareInvoice(invoice);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در اشتراک‌گذاری: $e')),
        );
      }
    }
  }

  Future<void> _generatePdf(Invoice invoice) async {
    try {
      final pdfService = InvoicePdfService();
      await pdfService.printInvoice(invoice);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در تولید PDF: $e')),
        );
      }
    }
  }

  void _editInvoice(Invoice invoice) {
    // TODO: Navigate to edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('صفحه ویرایش به‌زودی اضافه می‌شود')),
    );
  }

  Future<void> _duplicateInvoice(Invoice invoice) async {
    // TODO: Implement duplicate functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قابلیت کپی فاکتور به‌زودی اضافه می‌شود')),
    );
  }

  Future<void> _deleteInvoice(Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف فاکتور'),
        content: const Text('آیا از حذف این فاکتور اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<InvoiceProvider>();
      await provider.deleteInvoice(invoice.id ?? '');
      
      if (mounted && provider.error == null) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فاکتور با موفقیت حذف شد')),
        );
      }
    }
  }
}
