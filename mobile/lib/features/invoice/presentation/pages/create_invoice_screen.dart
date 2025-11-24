import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:intl/intl.dart';
import '../../data/models/invoice.dart';
import '../../data/services/invoice_provider.dart';
import '../widgets/invoice_type_selection_bottom_sheet.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../customer/data/models/customer.dart';
import '../../../customer/presentation/pages/customers_page.dart';
import '../../../product/data/models/product.dart';
import '../../../product/data/models/product_variant.dart';
import 'product_variant_selection_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final Invoice? invoice;
  final String? businessId;

  const CreateInvoiceScreen({
    super.key,
    this.invoice,
    this.businessId,
  });

  @override
  _CreateInvoiceScreenState createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  InvoiceType? _selectedType;
  DateTime _selectedDate = DateTime.now();
  Customer? _selectedCustomer;
  List<InvoiceItemData> _items = [];
  
  // Toggles for optional fields
  bool _hasDiscount = false;
  bool _hasTax = false;
  bool _hasExtraCosts = false;
  
  // Discount fields
  DiscountType _discountType = DiscountType.percentage;
  final _discountValueController = TextEditingController();
  
  // Tax fields
  final _taxPercentageController = TextEditingController(text: '9');
  
  // Extra costs
  List<ExtraCostData> _extraCosts = [];
  
  // Calculated values
  double _subtotal = 0;
  double _discountAmount = 0;
  double _taxAmount = 0;
  double _extraCostsTotal = 0;
  double _total = 0;

  bool get _isEditMode => widget.invoice != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadInvoiceData();
    }
    _discountValueController.addListener(_recalculateTotals);
    _taxPercentageController.addListener(_recalculateTotals);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _discountValueController.dispose();
    _taxPercentageController.dispose();
    super.dispose();
  }

  void _loadInvoiceData() {
    final invoice = widget.invoice!;
    _selectedType = invoice.type;
    _selectedDate = invoice.issueDate;
    // Load customer - note: Invoice model doesn't have full customer object, only customerId/customerName
    // We'll need to fetch customer separately if needed for edit mode
    _notesController.text = invoice.notes ?? '';
    
    // Load items
    _items = invoice.items.map((item) => InvoiceItemData(
      productId: item.productId ?? '',
      productName: item.productName,
      variantId: item.variantId,
      variantName: item.description, // Using description as variantName
      quantity: item.quantity.toInt(),
      unitPrice: item.unitPrice,
    )).toList();
    
    // Load discount
    if (invoice.discountAmount > 0) {
      _hasDiscount = true;
      _discountType = invoice.discountType ?? DiscountType.percentage;
      _discountValueController.text = (invoice.discountValue ?? 0).toString();
    }
    
    // Load tax
    if (invoice.taxAmount > 0) {
      _hasTax = true;
      final taxRate = (invoice.taxAmount / invoice.subtotal * 100).toStringAsFixed(0);
      _taxPercentageController.text = taxRate;
    }
    
    // Load extra costs
    if (invoice.extraCosts.isNotEmpty) {
      _hasExtraCosts = true;
      _extraCosts = invoice.extraCosts.map((cost) => ExtraCostData(
        description: cost.title,
        amount: cost.amount,
      )).toList();
    }
    
    _recalculateTotals();
  }

  void _recalculateTotals() {
    setState(() {
      // Calculate subtotal
      _subtotal = _items.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));
      
      // Calculate discount
      if (_hasDiscount) {
        final discountValue = double.tryParse(_discountValueController.text) ?? 0;
        if (_discountType == DiscountType.percentage) {
          _discountAmount = _subtotal * (discountValue / 100);
        } else {
          _discountAmount = discountValue;
        }
      } else {
        _discountAmount = 0;
      }
      
      // Calculate tax
      if (_hasTax) {
        final taxPercentage = double.tryParse(_taxPercentageController.text) ?? 0;
        final taxableAmount = _subtotal - _discountAmount;
        _taxAmount = taxableAmount * (taxPercentage / 100);
      } else {
        _taxAmount = 0;
      }
      
      // Calculate extra costs total
      if (_hasExtraCosts) {
        _extraCostsTotal = _extraCosts.fold(0, (sum, cost) => sum + cost.amount);
      } else {
        _extraCostsTotal = 0;
      }
      
      // Calculate total
      _total = _subtotal - _discountAmount + _taxAmount + _extraCostsTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<InvoiceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'ویرایش فاکتور' : 'فاکتور جدید'),
        actions: [
          if (!_isEditMode && _selectedType == null)
            TextButton.icon(
              onPressed: _selectType,
              icon: const Icon(Icons.description_rounded),
              label: const Text('انتخاب نوع'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_selectedType == null && !_isEditMode)
                      _buildSelectTypePrompt(theme)
                    else ...[
                      _buildTypeAndDateSection(theme),
                      const SizedBox(height: 16),
                      _buildCustomerSection(theme),
                      const SizedBox(height: 16),
                      _buildItemsSection(theme),
                      const SizedBox(height: 16),
                      _buildDiscountSection(theme),
                      const SizedBox(height: 16),
                      _buildTaxSection(theme),
                      const SizedBox(height: 16),
                      _buildExtraCostsSection(theme),
                      const SizedBox(height: 16),
                      _buildNotesSection(theme),
                      const SizedBox(height: 16),
                      _buildTotalsCard(theme),
                    ],
                  ],
                ),
              ),
            ),
            if (_selectedType != null || _isEditMode)
              _buildBottomActions(theme, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectTypePrompt(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: _selectType,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'انتخاب نوع فاکتور',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'برای شروع، نوع فاکتور را انتخاب کنید',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _selectType,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('انتخاب'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeAndDateSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _isEditMode ? null : _selectType,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedType!.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          Expanded(
            child: InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedDate.toPersianDate(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    String label,
    String value,
    IconData icon,
    ThemeData theme, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
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
                if (onTap != null) ...[
                  const Spacer(),
                  Icon(Icons.edit_rounded, size: 14, color: theme.colorScheme.primary),
                ],
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
        ),
      ),
    );
  }

  Widget _buildCustomerSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مشتری',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedCustomer == null)
              OutlinedButton.icon(
                onPressed: _selectCustomer,
                icon: const Icon(Icons.add_rounded),
                label: const Text('انتخاب مشتری'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.person_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedCustomer!.fullName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_selectedCustomer!.phone?.isNotEmpty ?? false)
                            Text(
                              _selectedCustomer!.phone!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _selectCustomer,
                      icon: const Icon(Icons.edit_rounded),
                      tooltip: 'تغییر مشتری',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'اقلام فاکتور',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${NumberFormatter.toPersianNumber(_items.length.toString())} قلم',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_items.isEmpty)
              OutlinedButton.icon(
                onPressed: _selectProducts,
                icon: const Icon(Icons.add_rounded),
                label: const Text('افزودن محصول'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              )
            else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _buildItemRow(_items[index], index, theme),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _selectProducts,
                icon: const Icon(Icons.add_rounded),
                label: const Text('افزودن محصول بیشتر'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(InvoiceItemData item, int index, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.variantName?.isNotEmpty ?? false)
                      Text(
                        item.variantName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeItem(index),
                icon: const Icon(Icons.delete_outline_rounded),
                color: Colors.red,
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildQuantityControl(item, theme),
              ),
              const SizedBox(width: 12),
              Text(
                NumberFormatter.formatCurrency(item.unitPrice),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                NumberFormatter.formatCurrency(item.quantity * item.unitPrice),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(InvoiceItemData item, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            if (item.quantity > 1) {
              setState(() {
                item.quantity--;
                _recalculateTotals();
              });
            }
          },
          icon: const Icon(Icons.remove_rounded),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceVariant,
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(32, 32),
          ),
        ),
        Container(
          width: 50,
          alignment: Alignment.center,
          child: Text(
            NumberFormatter.toPersianNumber(item.quantity.toString()),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              item.quantity++;
              _recalculateTotals();
            });
          },
          icon: const Icon(Icons.add_rounded),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceVariant,
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(32, 32),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.discount_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تخفیف',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _hasDiscount,
                  onChanged: (value) {
                    setState(() {
                      _hasDiscount = value;
                      if (!value) _discountValueController.clear();
                      _recalculateTotals();
                    });
                  },
                ),
              ],
            ),
            if (_hasDiscount) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<DiscountType>(
                      segments: const [
                        ButtonSegment(
                          value: DiscountType.percentage,
                          label: Text('درصد'),
                          icon: Icon(Icons.percent_rounded, size: 16),
                        ),
                        ButtonSegment(
                          value: DiscountType.amount,
                          label: Text('مبلغ'),
                          icon: Icon(Icons.money_rounded, size: 16),
                        ),
                      ],
                      selected: {_discountType},
                      onSelectionChanged: (Set<DiscountType> newSelection) {
                        setState(() {
                          _discountType = newSelection.first;
                          _recalculateTotals();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _discountValueController,
                decoration: InputDecoration(
                  labelText: _discountType == DiscountType.percentage ? 'درصد تخفیف' : 'مبلغ تخفیف',
                  suffixText: _discountType == DiscountType.percentage ? '%' : 'تومان',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              if (_discountAmount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'معادل: ${NumberFormatter.formatCurrency(_discountAmount)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],


              Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'مالیات',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _hasTax,
                  onChanged: (value) {
                    setState(() {
                      _hasTax = value;
                      if (!value) _taxPercentageController.text = '9';
                      _recalculateTotals();
                    });
                  },
                ),
              

              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Switch(
                  value: _hasExtraCosts,
                  onChanged: (value) {
                    setState(() {
                      _hasExtraCosts = value;
                      if (!value) _extraCosts.clear();
                      _recalculateTotals();
                    });
                  },
                ),
              ],
            ),
            if (_hasExtraCosts) ...[
              const SizedBox(height: 16),
              if (_extraCosts.isEmpty)
                OutlinedButton.icon(
                  onPressed: _addExtraCost,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('افزودن هزینه'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                )
              else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _extraCosts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final cost = _extraCosts[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cost.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  NumberFormatter.formatCurrency(cost.amount),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeExtraCost(index),
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: Colors.red,
                            iconSize: 20,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _addExtraCost,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('افزودن هزینه بیشتر'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),
              ],
            ],
          
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaxSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'مالیات',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _hasTax,
                  onChanged: (value) {
                    setState(() {
                      _hasTax = value;
                      if (!value) _taxPercentageController.text = '9';
                      _recalculateTotals();
                    });
                  },
                ),
              ],
            ),
            if (_hasTax) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _taxPercentageController,
                decoration: const InputDecoration(
                  labelText: 'درصد مالیات',
                  suffixText: '%',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              if (_taxAmount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'مبلغ مالیات: ${NumberFormatter.formatCurrency(_taxAmount)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExtraCostsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Switch(
                  value: _hasExtraCosts,
                  onChanged: (value) {
                    setState(() {
                      _hasExtraCosts = value;
                      if (!value) _extraCosts.clear();
                      _recalculateTotals();
                    });
                  },
                ),
              ],
            ),
            if (_hasExtraCosts) ...[
              const SizedBox(height: 16),
              if (_extraCosts.isEmpty)
                OutlinedButton.icon(
                  onPressed: _addExtraCost,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('افزودن هزینه'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                )
              else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _extraCosts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final cost = _extraCosts[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cost.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  NumberFormatter.formatCurrency(cost.amount),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeExtraCost(index),
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: Colors.red,
                            iconSize: 20,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _addExtraCost,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('افزودن هزینه بیشتر'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
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
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'توضیحات اضافی...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildTotalRow('جمع کل', _subtotal, theme),
          if (_discountAmount > 0) ...[
            const SizedBox(height: 6),
            _buildTotalRow('تخفیف', -_discountAmount, theme, isDiscount: true),
          ],
          if (_taxAmount > 0) ...[
            const SizedBox(height: 6),
            _buildTotalRow('مالیات', _taxAmount, theme),
          ],
          if (_extraCostsTotal > 0) ...[
            const SizedBox(height: 6),
            _buildTotalRow('هزینه‌های اضافی', _extraCostsTotal, theme),
          ],
          const SizedBox(height: 8),
          Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.3)),
          const SizedBox(height: 8),
          _buildTotalRow('مبلغ نهایی', _total, theme, isFinal: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, ThemeData theme, {
    bool isFinal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
            fontSize: isFinal ? 16 : 14,
          ),
        ),
        Text(
          '${isDiscount ? "-" : ""}${NumberFormatter.formatCurrency(amount.abs())}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isFinal ? FontWeight.bold : FontWeight.w600,
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

  Widget _buildBottomActions(ThemeData theme, InvoiceProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: provider.isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('انصراف'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: provider.isLoading ? null : _saveInvoice,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditMode ? 'ذخیره تغییرات' : 'ایجاد فاکتور'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectType() async {
    final type = await InvoiceTypeSelectionBottomSheet.show(context);
    if (type != null) {
      setState(() {
        _selectedType = type;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2021, 3, 21), // 1400/1/1
      lastDate: DateTime(2032, 3, 20),  // 1410/12/29
      locale: const Locale('fa', 'IR'),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectCustomer() async {
    final provider = context.read<InvoiceProvider>();
    final result = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomersPage(
          businessId: provider.businessId ?? '',
          selectionMode: true,
          selectedCustomer: _selectedCustomer,
        ),
      ),
    );
    
    if (result != null && mounted) {
      setState(() {
        _selectedCustomer = result;
      });
    }
  }

  Future<void> _selectProducts() async {
    final provider = context.read<InvoiceProvider>();
    final businessId = provider.businessId;
    
    if (businessId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً ابتدا کسب‌وکار را انتخاب کنید')),
      );
      return;
    }

    final result = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductVariantSelectionScreen(
          businessId: businessId,
        ),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        for (var item in result) {
          final product = item['product'] as Product;
          final variant = item['variant'] as ProductVariant?;

          // محاسبه قیمت
          double price = 0;
          if (variant != null && variant.salePrice != null) {
            price = variant.salePrice!;
          } else {
            price = product.salePrice;
          }

          // اضافه کردن به لیست items
          _items.add(InvoiceItemData(
            productId: product.id,
            productName: product.name,
            variantId: variant?.id,
            variantName: variant?.name ?? variant?.sku,
            quantity: 1,
            unitPrice: price,
          ));
        }
        _recalculateTotals();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.length} محصول اضافه شد'),
          action: SnackBarAction(
            label: 'باشه',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _recalculateTotals();
    });
  }

  Future<void> _addExtraCost() async {
    final result = await showDialog<ExtraCostData>(
      context: context,
      builder: (context) => const _ExtraCostDialog(),
    );
    
    if (result != null) {
      setState(() {
        _extraCosts.add(result);
        _recalculateTotals();
      });
    }
  }

  void _removeExtraCost(int index) {
    setState(() {
      _extraCosts.removeAt(index);
      _recalculateTotals();
    });
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً مشتری را انتخاب کنید')),
      );
      return;
    }
    
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً حداقل یک محصول اضافه کنید')),
      );
      return;
    }

    final provider = context.read<InvoiceProvider>();
    
    final invoiceData = {
      'type': _selectedType!.name,
      'issueDate': _selectedDate.toIso8601String(), // تغییر از invoiceDate به issueDate
      'customerId': _selectedCustomer!.id,
      'items': _items.map((item) => {
        'productId': item.productId,
        'variantId': item.variantId,
        'productName': item.productName, // اضافه کردن productName
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
      }).toList(),
      if (_hasDiscount && _discountValueController.text.isNotEmpty) ...{
        'discountType': _discountType.name,
        'discountValue': double.parse(_discountValueController.text),
      },
      if (_hasTax && _taxPercentageController.text.isNotEmpty)
        'taxPercentage': double.parse(_taxPercentageController.text),
      if (_hasExtraCosts && _extraCosts.isNotEmpty)
        'extraCosts': _extraCosts.map((cost) => {
          'description': cost.description,
          'amount': cost.amount,
        }).toList(),
      if (_notesController.text.isNotEmpty)
        'notes': _notesController.text,
    };

    if (_isEditMode) {
      await provider.updateInvoice(widget.invoice!.id ?? '', invoiceData);
    } else {
      await provider.createInvoice(invoiceData);
    }

    if (mounted && provider.error == null) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditMode ? 'فاکتور با موفقیت به‌روزرسانی شد' : 'فاکتور با موفقیت ایجاد شد')),
      );
    }
  }
}

// Helper classes
class InvoiceItemData {
  final String productId;
  final String productName;
  final String? variantId;
  final String? variantName;
  int quantity;
  final double unitPrice;

  InvoiceItemData({
    required this.productId,
    required this.productName,
    this.variantId,
    this.variantName,
    required this.quantity,
    required this.unitPrice,
  });
}

class ExtraCostData {
  final String description;
  final double amount;

  ExtraCostData({
    required this.description,
    required this.amount,
  });
}

// Extra Cost Dialog
class _ExtraCostDialog extends StatefulWidget {
  const _ExtraCostDialog();

  @override
  State<_ExtraCostDialog> createState() => _ExtraCostDialogState();
}

class _ExtraCostDialogState extends State<_ExtraCostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('هزینه اضافی'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'عنوان',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'لطفاً عنوان را وارد کنید';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'مبلغ',
                suffixText: 'تومان',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'لطفاً مبلغ را وارد کنید';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'مبلغ باید بیشتر از صفر باشد';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                ExtraCostData(
                  description: _descriptionController.text,
                  amount: double.parse(_amountController.text),
                ),
              );
            }
          },
          child: const Text('افزودن'),
        ),
      ],
    );
  }
}
