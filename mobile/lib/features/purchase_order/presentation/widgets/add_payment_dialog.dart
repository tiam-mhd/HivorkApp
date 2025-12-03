import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/enums/purchase_order_enums.dart';
import '../../data/dtos/payment_dtos.dart';

/// Dialog for adding a new payment to a purchase order
class AddPaymentDialog extends StatefulWidget {
  final String purchaseOrderId;
  final String remainingAmount;

  const AddPaymentDialog({
    super.key,
    required this.purchaseOrderId,
    required this.remainingAmount,
  });

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberFormat = NumberFormat('#,##0', 'fa');

  // Form fields
  final _paymentNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _referenceNumberController = TextEditingController();
  final _transactionIdController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  PaymentMethod _method = PaymentMethod.cash;
  String _currency = 'IRR';

  @override
  void initState() {
    super.initState();
    // Generate payment number with timestamp
    _paymentNumberController.text =
        'PAY-${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}';
  }

  @override
  void dispose() {
    _paymentNumberController.dispose();
    _amountController.dispose();
    _referenceNumberController.dispose();
    _transactionIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectPaymentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fa'),
    );
    if (picked != null) {
      setState(() => _paymentDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final dto = CreatePaymentDto(
        purchaseOrderId: widget.purchaseOrderId,
        paymentNumber: _paymentNumberController.text,
        paymentDate: _paymentDate,
        amount: double.parse(_amountController.text.replaceAll(',', '')),
        currency: _currency,
        method: _method,
        referenceNumber: _referenceNumberController.text.isEmpty
            ? null
            : _referenceNumberController.text,
        transactionId: _transactionIdController.text.isEmpty
            ? null
            : _transactionIdController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      Navigator.pop(context, dto);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remainingDouble = double.tryParse(widget.remainingAmount) ?? 0;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
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
                      Icon(Icons.payment, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'ثبت پرداخت جدید',
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

                  // Remaining amount info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'مانده قابل پرداخت: ${_numberFormat.format(remainingDouble)} ریال',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment number
                  TextFormField(
                    controller: _paymentNumberController,
                    decoration: const InputDecoration(
                      labelText: 'شماره پرداخت *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'شماره پرداخت الزامی است';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Payment date
                  InkWell(
                    onTap: _selectPaymentDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'تاریخ پرداخت *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('yyyy/MM/dd', 'fa').format(_paymentDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'مبلغ (ریال) *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixText: 'ریال',
                      helperText: remainingDouble > 0
                          ? 'حداکثر: ${_numberFormat.format(remainingDouble)}'
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'مبلغ الزامی است';
                      }
                      final amount =
                          double.tryParse(value.replaceAll(',', ''));
                      if (amount == null || amount <= 0) {
                        return 'مبلغ باید بزرگتر از صفر باشد';
                      }
                      if (amount > remainingDouble) {
                        return 'مبلغ نمی‌تواند بیشتر از مانده باشد';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Auto-format with comma separator
                      final text = value.replaceAll(',', '');
                      if (text.isNotEmpty) {
                        final number = double.tryParse(text);
                        if (number != null) {
                          final formatted = _numberFormat.format(number);
                          if (formatted != value) {
                            _amountController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                  offset: formatted.length),
                            );
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Payment method
                  DropdownButtonFormField<PaymentMethod>(
                    initialValue: _method,
                    decoration: const InputDecoration(
                      labelText: 'روش پرداخت *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payment),
                    ),
                    items: PaymentMethod.values.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(method.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _method = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Reference number
                  TextFormField(
                    controller: _referenceNumberController,
                    decoration: const InputDecoration(
                      labelText: 'شماره مرجع',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt_long),
                      hintText: 'شماره چک، کارت، حواله و ...',
                    ),
                    maxLength: 200,
                  ),
                  const SizedBox(height: 16),

                  // Transaction ID
                  TextFormField(
                    controller: _transactionIdController,
                    decoration: const InputDecoration(
                      labelText: 'شناسه تراکنش',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                      hintText: 'شناسه بانکی یا درگاه پرداخت',
                    ),
                    maxLength: 200,
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
                        label: const Text('ثبت پرداخت'),
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
