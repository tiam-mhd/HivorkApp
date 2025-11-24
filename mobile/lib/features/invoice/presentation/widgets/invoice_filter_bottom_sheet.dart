import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/invoice_provider.dart';
import '../../data/models/invoice.dart';

class InvoiceFilterBottomSheet extends StatefulWidget {
  const InvoiceFilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<InvoiceFilterBottomSheet> createState() =>
      _InvoiceFilterBottomSheetState();
}

class _InvoiceFilterBottomSheetState extends State<InvoiceFilterBottomSheet> {
  InvoiceType? _selectedType;
  InvoiceStatus? _selectedStatus;
  PaymentStatus? _selectedPaymentStatus;
  ShippingStatus? _selectedShippingStatus;

  @override
  void initState() {
    super.initState();
    final provider = context.read<InvoiceProvider>();
    _selectedType = provider.filterType;
    _selectedStatus = provider.filterStatus;
    _selectedPaymentStatus = provider.filterPaymentStatus;
    _selectedShippingStatus = provider.filterShippingStatus;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'فیلتر فاکتورها',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAll,
                    child: const Text('پاک کردن'),
                  ),
                ],
              ),
              const Divider(),

              // Filters
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // نوع فاکتور
                    _buildSection(
                      title: 'نوع فاکتور',
                      child: Wrap(
                        spacing: 8,
                        children: InvoiceType.values.map((type) {
                          return ChoiceChip(
                            label: Text(type.label),
                            selected: _selectedType == type,
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = selected ? type : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // وضعیت فاکتور
                    _buildSection(
                      title: 'وضعیت فاکتور',
                      child: Wrap(
                        spacing: 8,
                        children: InvoiceStatus.values.map((status) {
                          return ChoiceChip(
                            label: Text(status.label),
                            selected: _selectedStatus == status,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus = selected ? status : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // وضعیت پرداخت
                    _buildSection(
                      title: 'وضعیت پرداخت',
                      child: Wrap(
                        spacing: 8,
                        children: PaymentStatus.values.map((status) {
                          return ChoiceChip(
                            label: Text(status.label),
                            selected: _selectedPaymentStatus == status,
                            onSelected: (selected) {
                              setState(() {
                                _selectedPaymentStatus =
                                    selected ? status : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // وضعیت ارسال
                    _buildSection(
                      title: 'وضعیت ارسال',
                      child: Wrap(
                        spacing: 8,
                        children: ShippingStatus.values.map((status) {
                          return ChoiceChip(
                            label: Text(status.label),
                            selected: _selectedShippingStatus == status,
                            onSelected: (selected) {
                              setState(() {
                                _selectedShippingStatus =
                                    selected ? status : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('انصراف'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('اعمال فیلتر'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  void _clearAll() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _selectedPaymentStatus = null;
      _selectedShippingStatus = null;
    });
  }

  void _applyFilters() {
    context.read<InvoiceProvider>().applyFilters(
          type: _selectedType,
          status: _selectedStatus,
          paymentStatus: _selectedPaymentStatus,
          shippingStatus: _selectedShippingStatus,
        );
    Navigator.pop(context);
  }
}
