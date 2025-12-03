import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/purchase_order_item_model.dart';
import '../../data/dtos/receipt_dtos.dart';

/// Dialog for recording receipt of goods from a purchase order
class AddReceiptDialog extends StatefulWidget {
  final String purchaseOrderId;
  final List<PurchaseOrderItemModel> orderItems;

  const AddReceiptDialog({
    super.key,
    required this.purchaseOrderId,
    required this.orderItems,
  });

  @override
  State<AddReceiptDialog> createState() => _AddReceiptDialogState();
}

class _AddReceiptDialogState extends State<AddReceiptDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberFormat = NumberFormat('#,##0', 'fa');

  // Form fields
  final _receiptNumberController = TextEditingController();
  final _receivedByController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _receiptDate = DateTime.now();
  final Map<String, _ReceiptItemData> _itemsData = {};

  @override
  void initState() {
    super.initState();
    // Generate receipt number with timestamp
    _receiptNumberController.text =
        'RCP-${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}';

    // Initialize items data
    for (var item in widget.orderItems) {
      final remainingQty = double.parse(item.quantity) -
          double.parse(item.receivedQuantity);
      _itemsData[item.id] = _ReceiptItemData(
        itemId: item.id,
        itemName: item.productName,
        orderedQty: double.parse(item.quantity),
        receivedQty: double.parse(item.receivedQuantity),
        remainingQty: remainingQty,
        receiveNow: remainingQty,
        rejectedQty: 0,
        rejectionReason: null,
        notes: null,
      );
    }
  }

  @override
  void dispose() {
    _receiptNumberController.dispose();
    _receivedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectReceiptDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _receiptDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fa'),
    );
    if (picked != null) {
      setState(() => _receiptDate = picked);
    }
  }

  void _editItem(String itemId) {
    final itemData = _itemsData[itemId]!;
    showDialog(
      context: context,
      builder: (context) => _EditReceiptItemDialog(
        itemData: itemData,
        onSave: (updated) {
          setState(() {
            _itemsData[itemId] = updated;
          });
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Check if at least one item has received quantity
      final hasReceivedItems =
          _itemsData.values.any((item) => item.receiveNow > 0);
      if (!hasReceivedItems) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حداقل یک قلم باید دریافت شود')),
        );
        return;
      }

      // Build items list
      final items = _itemsData.values
          .where((item) => item.receiveNow > 0 || item.rejectedQty > 0)
          .map((item) => CreateReceiptItemDto(
                purchaseOrderItemId: item.itemId,
                receivedQuantity: item.receiveNow,
                rejectedQuantity: item.rejectedQty > 0 ? item.rejectedQty : 0,
                rejectionReason: item.rejectionReason,
                notes: item.notes,
              ))
          .toList();

      final dto = CreateReceiptDto(
        purchaseOrderId: widget.purchaseOrderId,
        receiptNumber: _receiptNumberController.text,
        receiptDate: _receiptDate,
        receivedBy: _receivedByController.text.isEmpty
            ? null
            : _receivedByController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        items: items,
      );

      Navigator.pop(context, dto);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.inventory_2, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'ثبت رسید کالا',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Receipt number
                  TextFormField(
                    controller: _receiptNumberController,
                    decoration: const InputDecoration(
                      labelText: 'شماره رسید *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'شماره رسید الزامی است';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Receipt date
                  InkWell(
                    onTap: _selectReceiptDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'تاریخ دریافت *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('yyyy/MM/dd', 'fa').format(_receiptDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Received by
                  TextFormField(
                    controller: _receivedByController,
                    decoration: const InputDecoration(
                      labelText: 'تحویل گیرنده',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      hintText: 'نام شخص تحویل گیرنده',
                    ),
                    maxLength: 200,
                  ),
                  const SizedBox(height: 16),

                  // Items section
                  const Text(
                    'اقلام دریافتی *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _itemsData.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final itemData = _itemsData.values.elementAt(index);
                        final hasRemaining = itemData.remainingQty > 0;

                        return ListTile(
                          title: Text(
                            itemData.itemName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'سفارش: ${_numberFormat.format(itemData.orderedQty.toInt())} | '
                                'دریافت شده: ${_numberFormat.format(itemData.receivedQty.toInt())} | '
                                'باقیمانده: ${_numberFormat.format(itemData.remainingQty.toInt())}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (itemData.receiveNow > 0)
                                Text(
                                  'دریافت الان: ${_numberFormat.format(itemData.receiveNow.toInt())}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (itemData.rejectedQty > 0)
                                Text(
                                  'رد شده: ${_numberFormat.format(itemData.rejectedQty.toInt())}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                          trailing: hasRemaining
                              ? IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editItem(itemData.itemId),
                                  tooltip: 'ویرایش مقادیر',
                                )
                              : const Icon(Icons.check_circle,
                                  color: Color(0xFF10B981)),
                          tileColor: itemData.receiveNow > 0
                              ? const Color(0xFFD1FAE5)
                              : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'یادداشت کلی',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('انصراف'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check),
                        label: const Text('ثبت رسید'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for receipt item editing
class _ReceiptItemData {
  final String itemId;
  final String itemName;
  final double orderedQty;
  final double receivedQty;
  final double remainingQty;
  final double receiveNow;
  final double rejectedQty;
  final String? rejectionReason;
  final String? notes;

  _ReceiptItemData({
    required this.itemId,
    required this.itemName,
    required this.orderedQty,
    required this.receivedQty,
    required this.remainingQty,
    required this.receiveNow,
    required this.rejectedQty,
    this.rejectionReason,
    this.notes,
  });

  _ReceiptItemData copyWith({
    double? receiveNow,
    double? rejectedQty,
    String? rejectionReason,
    String? notes,
  }) {
    return _ReceiptItemData(
      itemId: itemId,
      itemName: itemName,
      orderedQty: orderedQty,
      receivedQty: receivedQty,
      remainingQty: remainingQty,
      receiveNow: receiveNow ?? this.receiveNow,
      rejectedQty: rejectedQty ?? this.rejectedQty,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
    );
  }
}

/// Dialog for editing individual receipt item
class _EditReceiptItemDialog extends StatefulWidget {
  final _ReceiptItemData itemData;
  final Function(_ReceiptItemData) onSave;

  const _EditReceiptItemDialog({
    required this.itemData,
    required this.onSave,
  });

  @override
  State<_EditReceiptItemDialog> createState() => _EditReceiptItemDialogState();
}

class _EditReceiptItemDialogState extends State<_EditReceiptItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberFormat = NumberFormat('#,##0', 'fa');
  late final TextEditingController _receiveNowController;
  late final TextEditingController _rejectedQtyController;
  late final TextEditingController _rejectionReasonController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _receiveNowController = TextEditingController(
      text: widget.itemData.receiveNow > 0
          ? _numberFormat.format(widget.itemData.receiveNow.toInt())
          : '',
    );
    _rejectedQtyController = TextEditingController(
      text: widget.itemData.rejectedQty > 0
          ? _numberFormat.format(widget.itemData.rejectedQty.toInt())
          : '',
    );
    _rejectionReasonController = TextEditingController(
      text: widget.itemData.rejectionReason ?? '',
    );
    _notesController = TextEditingController(
      text: widget.itemData.notes ?? '',
    );
  }

  @override
  void dispose() {
    _receiveNowController.dispose();
    _rejectedQtyController.dispose();
    _rejectionReasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final receiveNow = double.tryParse(
              _receiveNowController.text.replaceAll(',', '')) ??
          0;
      final rejectedQty = double.tryParse(
              _rejectedQtyController.text.replaceAll(',', '')) ??
          0;

      final updated = widget.itemData.copyWith(
        receiveNow: receiveNow,
        rejectedQty: rejectedQty,
        rejectionReason: _rejectionReasonController.text.isEmpty
            ? null
            : _rejectionReasonController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      widget.onSave(updated);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.itemData.itemName),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('سفارش: ${_numberFormat.format(widget.itemData.orderedQty.toInt())}'),
                    Text('دریافت شده: ${_numberFormat.format(widget.itemData.receivedQty.toInt())}'),
                    Text(
                      'باقیمانده: ${_numberFormat.format(widget.itemData.remainingQty.toInt())}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Receive now
              TextFormField(
                controller: _receiveNowController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'مقدار دریافتی',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.add_circle),
                  helperText: 'حداکثر: ${_numberFormat.format(widget.itemData.remainingQty.toInt())}',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // Optional
                  }
                  final qty = double.tryParse(value.replaceAll(',', ''));
                  if (qty == null || qty < 0) {
                    return 'مقدار نامعتبر';
                  }
                  if (qty > widget.itemData.remainingQty) {
                    return 'نمی‌تواند بیشتر از باقیمانده باشد';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Rejected qty
              TextFormField(
                controller: _rejectedQtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'مقدار رد شده (اختیاری)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cancel, color: Colors.red),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final qty = double.tryParse(value.replaceAll(',', ''));
                  if (qty == null || qty < 0) {
                    return 'مقدار نامعتبر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Rejection reason
              if (_rejectedQtyController.text.isNotEmpty)
                TextFormField(
                  controller: _rejectionReasonController,
                  decoration: const InputDecoration(
                    labelText: 'دلیل رد',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  maxLines: 2,
                ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'یادداشت',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('ذخیره'),
        ),
      ],
    );
  }
}
