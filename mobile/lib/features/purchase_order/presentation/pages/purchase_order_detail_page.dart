import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/providers/purchase_order_provider.dart';
import '../../data/models/purchase_order_model.dart';
import '../../data/enums/purchase_order_enums.dart';
import '../widgets/add_payment_dialog.dart';
import '../widgets/add_receipt_dialog.dart';

class PurchaseOrderDetailPage extends StatefulWidget {
  final String businessId;
  final String purchaseOrderId;

  const PurchaseOrderDetailPage({
    Key? key,
    required this.businessId,
    required this.purchaseOrderId,
  }) : super(key: key);

  @override
  State<PurchaseOrderDetailPage> createState() =>
      _PurchaseOrderDetailPageState();
}

class _PurchaseOrderDetailPageState extends State<PurchaseOrderDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _numberFormat = NumberFormat('#,##0', 'fa');
  final _dateFormat = DateFormat('yyyy/MM/dd', 'fa');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<PurchaseOrderProvider>();
    await provider.loadPurchaseOrder(widget.purchaseOrderId, widget.businessId);
    await provider.loadPayments(widget.purchaseOrderId);
    await provider.loadReceipts(widget.purchaseOrderId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات سفارش خرید'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'خلاصه', icon: Icon(Icons.info_outline)),
            Tab(text: 'کالاها', icon: Icon(Icons.inventory_2)),
            Tab(text: 'پرداخت‌ها', icon: Icon(Icons.payments)),
            Tab(text: 'رسیدها', icon: Icon(Icons.receipt_long)),
          ],
        ),
      ),
      body: Consumer<PurchaseOrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('خطا: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            );
          }

          final purchaseOrder = provider.selectedPurchaseOrder;
          if (purchaseOrder == null) {
            return const Center(child: Text('سفارش یافت نشد'));
          }

          return Column(
            children: [
              _buildStatusBar(purchaseOrder),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(purchaseOrder),
                    _buildItemsTab(purchaseOrder),
                    _buildPaymentsTab(provider),
                    _buildReceiptsTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildStatusBar(PurchaseOrderModel po) {
    Color statusColor;
    IconData statusIcon;

    switch (po.status) {
      case PurchaseOrderStatus.draft:
        statusColor = Colors.grey;
        statusIcon = Icons.edit_note;
        break;
      case PurchaseOrderStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case PurchaseOrderStatus.approved:
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case PurchaseOrderStatus.sent:
        statusColor = Colors.purple;
        statusIcon = Icons.send;
        break;
      case PurchaseOrderStatus.confirmed:
        statusColor = Colors.teal;
        statusIcon = Icons.verified;
        break;
      case PurchaseOrderStatus.partiallyReceived:
        statusColor = Colors.amber;
        statusIcon = Icons.hourglass_bottom;
        break;
      case PurchaseOrderStatus.received:
        statusColor = Colors.green;
        statusIcon = Icons.inventory;
        break;
      case PurchaseOrderStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case PurchaseOrderStatus.closed:
        statusColor = Colors.grey;
        statusIcon = Icons.lock;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: statusColor.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  po.orderNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  po.status.label,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildActionButtons(po),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PurchaseOrderModel po) {
    final buttons = <Widget>[];

    if (po.status == PurchaseOrderStatus.draft) {
      buttons.add(
        FilledButton.icon(
          onPressed: () => _approveOrder(po.id),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('تایید'),
        ),
      );
    } else if (po.status == PurchaseOrderStatus.approved) {
      buttons.add(
        FilledButton.icon(
          onPressed: () => _sendOrder(po.id),
          icon: const Icon(Icons.send, size: 18),
          label: const Text('ارسال'),
        ),
      );
    } else if (po.status == PurchaseOrderStatus.sent) {
      buttons.add(
        FilledButton.icon(
          onPressed: () => _confirmOrder(po.id),
          icon: const Icon(Icons.verified, size: 18),
          label: const Text('تایید تامین‌کننده'),
        ),
      );
    }

    if (po.status != PurchaseOrderStatus.cancelled && po.status != PurchaseOrderStatus.closed) {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(width: 8));
      }
      buttons.add(
        OutlinedButton.icon(
          onPressed: () => _cancelOrder(po.id),
          icon: const Icon(Icons.cancel, size: 18),
          label: const Text('لغو'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        ),
      );
    }

    return Row(children: buttons);
  }

  Widget _buildOverviewTab(PurchaseOrderModel po) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          'اطلاعات تامین‌کننده',
          [
            if (po.supplier != null) ...[
              _buildInfoRow('نام', po.supplier!.name),
              if (po.supplier!.companyName != null)
                _buildInfoRow('نام شرکت', po.supplier!.companyName!),
              if (po.supplier!.email != null)
                _buildInfoRow('ایمیل', po.supplier!.email!),
              if (po.supplier!.phone != null)
                _buildInfoRow('تلفن', po.supplier!.phone!),
            ] else
              const Text('اطلاعات تامین‌کننده موجود نیست'),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          'اطلاعات سفارش',
          [
            _buildInfoRow('شماره سفارش', po.orderNumber),
            _buildInfoRow('نوع', po.type.label),
            _buildInfoRow('تاریخ سفارش', _dateFormat.format(po.orderDate)),
            if (po.expectedDeliveryDate != null)
              _buildInfoRow('تحویل پیش‌بینی', _dateFormat.format(po.expectedDeliveryDate!)),
            _buildInfoRow('واحد پول', po.currency),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          'خلاصه مالی',
          [
            _buildInfoRow('جمع کالاها', '${_numberFormat.format(double.parse(po.subtotal))} ریال'),
            _buildInfoRow('هزینه حمل', '${_numberFormat.format(double.parse(po.shippingCost))} ریال'),
            _buildInfoRow('تخفیف', '${_numberFormat.format(double.parse(po.discountAmount))} ریال'),
            _buildInfoRow('مالیات', '${_numberFormat.format(double.parse(po.taxAmount))} ریال'),
            const Divider(),
            _buildInfoRow(
              'جمع کل',
              '${_numberFormat.format(double.parse(po.totalAmount))} ریال',
              isBold: true,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'پرداخت شده',
              '${_numberFormat.format(double.parse(po.paidAmount))} ریال',
              valueColor: const Color(0xFF10B981),
            ),
            _buildInfoRow(
              'باقیمانده',
              '${_numberFormat.format(double.parse(po.remainingAmount))} ریال',
              valueColor: double.parse(po.remainingAmount) > 0 ? Colors.red : Colors.green,
            ),
          ],
        ),
        if (po.deliveryAddress != null) ...[
          const SizedBox(height: 16),
          _buildSection(
            'آدرس تحویل',
            [
              Text(po.deliveryAddress!),
            ],
          ),
        ],
        if (po.notes != null) ...[
          const SizedBox(height: 16),
          _buildSection(
            'یادداشت‌ها',
            [
              Text(po.notes!),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildItemsTab(PurchaseOrderModel po) {
    if (po.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('هیچ کالایی ثبت نشده'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: po.items.length,
      itemBuilder: (context, index) {
        final item = po.items[index];
        final quantity = double.parse(item.quantity);
        final unitPrice = double.parse(item.unitPrice);
        final subtotal = quantity * unitPrice;
        final discount = double.parse(item.discountAmount);
        final taxRate = double.parse(item.taxRate);
        final total = (subtotal - discount) * (1 + taxRate / 100);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (item.sku != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${item.sku}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const Divider(),
                _buildInfoRow('تعداد', '${_numberFormat.format(quantity.toInt())} ${item.unit ?? 'عدد'}'),
                _buildInfoRow('قیمت واحد', '${_numberFormat.format(unitPrice)} ریال'),
                if (discount > 0)
                  _buildInfoRow('تخفیف', '${_numberFormat.format(discount)} ریال'),
                if (taxRate > 0)
                  _buildInfoRow('مالیات', '$taxRate%'),
                const Divider(),
                _buildInfoRow(
                  'جمع',
                  '${_numberFormat.format(total)} ریال',
                  isBold: true,
                  valueColor: const Color(0xFF10B981),
                ),
                if (item.notes != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'یادداشت: ${item.notes}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab(PurchaseOrderProvider provider) {
    if (provider.isLoadingPayments) {
      return const Center(child: CircularProgressIndicator());
    }

    final payments = provider.payments;
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payments_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('هیچ پرداختی ثبت نشده'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _showAddPaymentDialog,
              icon: const Icon(Icons.add),
              label: const Text('افزودن پرداخت'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length + 1,
      itemBuilder: (context, index) {
        if (index == payments.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: OutlinedButton.icon(
              onPressed: _showAddPaymentDialog,
              icon: const Icon(Icons.add),
              label: const Text('افزودن پرداخت جدید'),
            ),
          );
        }

        final payment = payments[index];
        Color statusColor;
        switch (payment.status) {
          case PaymentStatus.pending:
            statusColor = Colors.orange;
            break;
          case PaymentStatus.completed:
            statusColor = Colors.green;
            break;
          case PaymentStatus.failed:
            statusColor = Colors.red;
            break;
          case PaymentStatus.cancelled:
            statusColor = Colors.grey;
            break;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(Icons.payments, color: statusColor),
            title: Text(
              '${_numberFormat.format(double.parse(payment.amount))} ریال',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${payment.method.label} - ${_dateFormat.format(payment.paymentDate)}'),
                Text(
                  payment.status.label,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
                if (payment.referenceNumber != null)
                  Text(
                    'مرجع: ${payment.referenceNumber}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
            trailing: payment.status == PaymentStatus.pending
                ? PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'complete',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF10B981)),
                            SizedBox(width: 8),
                            Text('تکمیل پرداخت'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'complete') {
                        _completePayment(payment.id);
                      } else if (value == 'delete') {
                        _deletePayment(payment.id);
                      }
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildReceiptsTab(PurchaseOrderProvider provider) {
    if (provider.isLoadingReceipts) {
      return const Center(child: CircularProgressIndicator());
    }

    final receipts = provider.receipts;
    if (receipts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('هیچ رسیدی ثبت نشده'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _showAddReceiptDialog,
              icon: const Icon(Icons.add),
              label: const Text('افزودن رسید'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: receipts.length + 1,
      itemBuilder: (context, index) {
        if (index == receipts.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: OutlinedButton.icon(
              onPressed: _showAddReceiptDialog,
              icon: const Icon(Icons.add),
              label: const Text('افزودن رسید جدید'),
            ),
          );
        }

        final receipt = receipts[index];
        Color statusColor;
        switch (receipt.status) {
          case ReceiptStatus.draft:
            statusColor = Colors.orange;
            break;
          case ReceiptStatus.completed:
            statusColor = Colors.green;
            break;
          case ReceiptStatus.cancelled:
            statusColor = Colors.grey;
            break;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(Icons.receipt_long, color: statusColor),
            title: Text(
              receipt.receiptNumber,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_dateFormat.format(receipt.receiptDate)),
                Text(
                  '${receipt.items.length} قلم - ${receipt.status.label}',
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
                if (receipt.receivedBy != null)
                  Text(
                    'تحویل گیرنده: ${receipt.receivedBy}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
            trailing: receipt.status == ReceiptStatus.draft
                ? PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'complete',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF10B981)),
                            SizedBox(width: 8),
                            Text('تکمیل رسید'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'complete') {
                        _completeReceipt(receipt.id);
                      } else if (value == 'delete') {
                        _deleteReceipt(receipt.id);
                      }
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    final provider = context.watch<PurchaseOrderProvider>();
    final po = provider.selectedPurchaseOrder;

    if (po == null) return null;

    if (_tabController.index == 2) {
      return FloatingActionButton.extended(
        onPressed: _showAddPaymentDialog,
        icon: const Icon(Icons.add),
        label: const Text('پرداخت جدید'),
      );
    } else if (_tabController.index == 3) {
      return FloatingActionButton.extended(
        onPressed: _showAddReceiptDialog,
        icon: const Icon(Icons.add),
        label: const Text('رسید جدید'),
      );
    }

    return null;
  }

  Future<void> _approveOrder(String orderId) async {
    final provider = context.read<PurchaseOrderProvider>();
    try {
      await provider.approvePurchaseOrder(widget.businessId, orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سفارش تایید شد')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }

  Future<void> _sendOrder(String orderId) async {
    final provider = context.read<PurchaseOrderProvider>();
    try {
      await provider.sendPurchaseOrder(widget.businessId, orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سفارش ارسال شد')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }

  Future<void> _confirmOrder(String orderId) async {
    final provider = context.read<PurchaseOrderProvider>();
    try {
      await provider.confirmPurchaseOrder(widget.businessId, orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سفارش تایید شد توسط تامین‌کننده')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('لغو سفارش'),
        content: const Text('آیا مطمئن هستید که می‌خواهید این سفارش را لغو کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('خیر'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('بله، لغو کن'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final provider = context.read<PurchaseOrderProvider>();
    try {
      await provider.cancelPurchaseOrder(widget.businessId, orderId, 'لغو شده توسط کاربر');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سفارش لغو شد')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }

  Future<void> _completePayment(String paymentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تایید تکمیل پرداخت'),
        content: const Text('آیا از تکمیل این پرداخت اطمینان دارید؟\n\nپس از تکمیل، مبلغ پرداختی به مانده سفارش اعمال می‌شود.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تایید'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final provider = context.read<PurchaseOrderProvider>();
    try {
      await provider.completePayment(widget.purchaseOrderId, paymentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('پرداخت تکمیل شد'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        await provider.loadPayments(widget.purchaseOrderId);
        await provider.loadPurchaseOrder(widget.purchaseOrderId, widget.businessId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }

  Future<void> _deletePayment(String paymentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف پرداخت'),
        content: const Text('آیا از حذف این پرداخت اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final provider = context.read<PurchaseOrderProvider>();
    try {
      await provider.deletePayment(widget.purchaseOrderId, paymentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('پرداخت حذف شد')),
        );
        await provider.loadPayments(widget.purchaseOrderId);
        await provider.loadPurchaseOrder(widget.purchaseOrderId, widget.businessId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }

  Future<void> _completeReceipt(String receiptId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تایید تکمیل رسید'),
        content: const Text('آیا از تکمیل این رسید اطمینان دارید؟\n\nپس از تکمیل، مقادیر دریافتی به سفارش اعمال می‌شود.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تایید'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final provider = context.read<PurchaseOrderProvider>();
    try {
      await provider.completeReceipt(widget.purchaseOrderId, receiptId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رسید تکمیل شد'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        await provider.loadReceipts(widget.purchaseOrderId);
        await provider.loadPurchaseOrder(widget.purchaseOrderId, widget.businessId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }

  Future<void> _deleteReceipt(String receiptId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف رسید'),
        content: const Text('آیا از حذف این رسید اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final provider = context.read<PurchaseOrderProvider>();
    try {
      await provider.deleteReceipt(widget.purchaseOrderId, receiptId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رسید حذف شد')),
        );
        await provider.loadReceipts(widget.purchaseOrderId);
        await provider.loadPurchaseOrder(widget.purchaseOrderId, widget.businessId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }

  void _showAddPaymentDialog() async {
    final provider = context.read<PurchaseOrderProvider>();
    final po = provider.selectedPurchaseOrder;
    if (po == null) return;

    final result = await showDialog(
      context: context,
      builder: (context) => AddPaymentDialog(
        purchaseOrderId: widget.purchaseOrderId,
        remainingAmount: po.remainingAmount,
      ),
    );

    if (result != null && mounted) {
      try {
        final success = await provider.createPayment(
          widget.purchaseOrderId,
          widget.businessId,
          result,
        );
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('پرداخت با موفقیت ثبت شد'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          await provider.loadPayments(widget.purchaseOrderId);
          await provider.loadPurchaseOrder(widget.purchaseOrderId, widget.businessId);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطا در ثبت پرداخت: $e')),
          );
        }
      }
    }
  }

  void _showAddReceiptDialog() async {
    final provider = context.read<PurchaseOrderProvider>();
    final po = provider.selectedPurchaseOrder;
    if (po == null || po.items.isEmpty) return;

    final result = await showDialog(
      context: context,
      builder: (context) => AddReceiptDialog(
        purchaseOrderId: widget.purchaseOrderId,
        orderItems: po.items,
      ),
    );

    if (result != null && mounted) {
      try {
        final success = await provider.createReceipt(
          widget.purchaseOrderId,
          widget.businessId,
          result,
        );
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('رسید با موفقیت ثبت شد'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          await provider.loadReceipts(widget.purchaseOrderId);
          await provider.loadPurchaseOrder(widget.purchaseOrderId, widget.businessId);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطا در ثبت رسید: $e')),
          );
        }
      }
    }
  }
}
