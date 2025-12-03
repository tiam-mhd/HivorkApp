import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../core/widgets/compact_persian_date_picker.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../data/providers/purchase_order_provider.dart';
import '../../data/models/purchase_order_model.dart';
import '../../data/dtos/purchase_order_dtos.dart';
import '../../data/enums/purchase_order_enums.dart';
import '../../../supplier/data/models/supplier_model.dart';
import '../../../supplier/data/providers/supplier_provider.dart';
import '../../../supplier/presentation/pages/supplier_list_page.dart';
import '../../../product/data/models/product.dart';
import '../../../product/data/models/product_variant.dart';
import '../../../product/presentation/pages/product_form_page.dart';
import '../../../invoice/presentation/pages/product_variant_selection_screen.dart';
import '../../../../core/utils/number_formatter.dart';

class PurchaseOrderFormPage extends StatefulWidget {
  final String businessId;
  final String? purchaseOrderId;
  final PurchaseOrderModel? purchaseOrder;

  const PurchaseOrderFormPage({
    super.key,
    required this.businessId,
    this.purchaseOrderId,
    this.purchaseOrder,
  });

  @override
  State<PurchaseOrderFormPage> createState() => _PurchaseOrderFormPageState();
}

class _PurchaseOrderFormPageState extends State<PurchaseOrderFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _orderNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _shippingCostController = TextEditingController();
  final _discountController = TextEditingController();
  final _taxRateController = TextEditingController();

  // Selections
  Supplier? _selectedSupplier;
  PurchaseOrderType _selectedType = PurchaseOrderType.standard;
  DateTime _orderDate = DateTime.now();
  DateTime? _expectedDeliveryDate;

  // Items
  final List<CreatePurchaseOrderItemDto> _items = [];

  List<Supplier> _suppliers = [];

  @override
  void initState() {
    super.initState();
    _orderNumberController.text = 'PO-${DateTime.now().millisecondsSinceEpoch}';
    _shippingCostController.text = '0';
    _discountController.text = '0';
    _taxRateController.text = '9';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSuppliers();
      if (widget.purchaseOrderId != null) {
        _loadPurchaseOrderById();
      } else if (widget.purchaseOrder != null) {
        _loadPurchaseOrderData();
      }
    });
  }

  Future<void> _loadPurchaseOrderById() async {
    try {
      final provider = context.read<PurchaseOrderProvider>();
      await provider.loadPurchaseOrder(
        widget.purchaseOrderId!,
        widget.businessId,
      );
      if (mounted && provider.selectedPurchaseOrder != null) {
        setState(() {
          _loadPurchaseOrderData(provider.selectedPurchaseOrder!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در بارگذاری سفارش: $e')));
        context.go('/purchase-orders', extra: widget.businessId);
      }
    }
  }

  Future<void> _loadSuppliers() async {
    try {
      final provider = context.read<SupplierProvider>();
      await provider.loadSuppliers(widget.businessId);
      if (mounted) {
        setState(() {
          _suppliers = provider.suppliers;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری تامین‌کنندگان: $e')),
        );
      }
    }
  }

  void _loadPurchaseOrderData([PurchaseOrderModel? po]) {
    final order = po ?? widget.purchaseOrder!;
    _orderNumberController.text = order.orderNumber;
    if (order.supplier != null) {
      _selectedSupplier = _suppliers.firstWhere(
        (s) => s.id == order.supplier!.id,
        orElse: () => Supplier(
          id: order.supplier!.id,
          name: order.supplier!.name,
          code: '',
          type: SupplierType.distributor,
          country: 'Iran',
          currency: 'IRR',
          creditLimit: '0',
          paymentTermDays: 0,
          defaultLeadTimeDays: 7,
          businessId: widget.businessId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    _selectedType = order.type;
    _orderDate = order.orderDate;
    _expectedDeliveryDate = order.expectedDeliveryDate;
    _notesController.text = order.notes ?? '';
    _deliveryAddressController.text = order.deliveryAddress ?? '';
    _shippingCostController.text = order.shippingCost;
    _discountController.text = order.discountAmount;
    _taxRateController.text = order.taxRate;

    // Load items
    for (final item in order.items) {
      _items.add(
        CreatePurchaseOrderItemDto(
          productId: item.productId,
          productVariantId: item.productVariantId,
          productName: item.productName,
          sku: item.sku,
          quantity: double.parse(item.quantity.toString()),
          unitPrice: double.parse(item.unitPrice),
          discountAmount: double.parse(item.discountAmount),
          taxRate: double.parse(item.taxRate),
          notes: item.notes,
        ),
      );
    }
  }

  @override
  void dispose() {
    _orderNumberController.dispose();
    _notesController.dispose();
    _deliveryAddressController.dispose();
    _shippingCostController.dispose();
    _discountController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit =
        widget.purchaseOrderId != null || widget.purchaseOrder != null;
    final canEdit =
        !isEdit || widget.purchaseOrder!.status == PurchaseOrderStatus.draft;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'ویرایش سفارش خرید' : 'سفارش خرید جدید'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Supplier Selection
            _buildSupplierSection(canEdit),
            const SizedBox(height: 16),

            // Order Number
            TextFormField(
              controller: _orderNumberController,
              enabled: !isEdit && canEdit,
              decoration: const InputDecoration(
                labelText: 'شماره سفارش *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'الزامی' : null,
            ),
            const SizedBox(height: 16),

            // Order Date & Delivery Date
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: canEdit ? () => _selectDate(context, true) : null,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'تاریخ سفارش *',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_orderDate.toPersianDate()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: canEdit ? () => _selectDate(context, false) : null,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'تاریخ تحویل',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _expectedDeliveryDate?.toPersianDate() ?? 'انتخاب کنید',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Items Section
            const Text(
              'کالاها',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ..._items.asMap().entries.map((entry) {
              return _buildItemCard(entry.key, entry.value, canEdit);
            }),

            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'هنوز کالایی اضافه نشده',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

            if (canEdit) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectProducts,
                      icon: const Icon(Icons.search),
                      label: const Text('انتخاب از لیست'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _createNewProduct,
                      icon: const Icon(Icons.add),
                      label: const Text('محصول جدید'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Financial Summary
            _buildFinancialSummary(canEdit),
            const SizedBox(height: 24),

            // Save Button
            if (canEdit)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  child: const Text('ثبت سفارش'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierSection(bool canEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تامین‌کننده',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_selectedSupplier == null)
          OutlinedButton.icon(
            onPressed: canEdit ? _selectSupplier : null,
            icon: const Icon(Icons.add),
            label: const Text('انتخاب تامین‌کننده'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          )
        else
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.business)),
              title: Text(_selectedSupplier!.name),
              subtitle: Text(_selectedSupplier!.code),
              trailing: canEdit
                  ? IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _selectSupplier,
                    )
                  : null,
            ),
          ),
      ],
    );
  }

  Widget _buildItemCard(
    int index,
    CreatePurchaseOrderItemDto item,
    bool canEdit,
  ) {
    final subtotal = item.quantity * item.unitPrice;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (canEdit)
                  IconButton(
                    onPressed: () => _removeItem(index),
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                  ),
              ],
            ),
            if (item.sku != null && item.sku!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'SKU: ${item.sku}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('قیمت واحد:'),
                Text(NumberFormatter.formatCurrency(item.unitPrice)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('تعداد:'),
                if (canEdit)
                  _buildQuantityControl(index, item)
                else
                  Text(
                    NumberFormatter.toPersianNumber(item.quantity.toString()),
                  ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'جمع:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  NumberFormatter.formatCurrency(subtotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl(int index, CreatePurchaseOrderItemDto item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              if (item.quantity > 1) {
                item.quantity--;
              } else {
                _removeItem(index);
              }
            });
          },
          icon: Icon(item.quantity > 1 ? Icons.remove : Icons.delete_outline),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
        ),
        Container(
          width: 50,
          alignment: Alignment.center,
          child: Text(
            NumberFormatter.toPersianNumber(item.quantity.toString()),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              item.quantity++;
            });
          },
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummary(bool canEdit) {
    double subtotal = 0;
    for (final item in _items) {
      subtotal += item.quantity * item.unitPrice;
    }

    final shippingCost = double.tryParse(_shippingCostController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final taxRate = double.tryParse(_taxRateController.text) ?? 0;

    final subtotalAfterDiscount = subtotal - discount;
    final tax = subtotalAfterDiscount * (taxRate / 100);
    final total = subtotalAfterDiscount + tax + shippingCost;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'خلاصه مالی',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('جمع کالاها:'),
                Text(NumberFormatter.formatCurrency(subtotal)),
              ],
            ),
            const SizedBox(height: 12),
            if (canEdit) ...[
              TextFormField(
                controller: _shippingCostController,
                decoration: const InputDecoration(
                  labelText: 'هزینه حمل',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  labelText: 'تخفیف',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('هزینه حمل:'),
                  Text(NumberFormatter.formatCurrency(shippingCost)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('تخفیف:'),
                  Text(
                    NumberFormatter.formatCurrency(discount),
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('مالیات (${taxRate.toStringAsFixed(0)}%):'),
                Text(NumberFormatter.formatCurrency(tax)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'جمع کل:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  NumberFormatter.formatCurrency(total),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isOrderDate) async {
    final Jalali? picked = await showCompactPersianDatePicker(
      context: context,
      initialDate: isOrderDate
          ? Jalali.fromDateTime(_orderDate)
          : (_expectedDeliveryDate != null
                ? Jalali.fromDateTime(_expectedDeliveryDate!)
                : Jalali.now()),
    );

    if (picked != null) {
      setState(() {
        if (isOrderDate) {
          _orderDate = picked.toDateTime();
        } else {
          _expectedDeliveryDate = picked.toDateTime();
        }
      });
    }
  }

  Future<void> _selectSupplier() async {
    final result = await Navigator.push<Supplier>(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierListPage(
          businessId: widget.businessId,
          selectionMode: true,
          selectedSupplier: _selectedSupplier,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedSupplier = result;
      });
    }
  }

  Future<void> _selectProducts() async {
    final result = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductVariantSelectionScreen(businessId: widget.businessId),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        for (var item in result) {
          final product = item['product'] as Product;
          final variant = item['variant'] as ProductVariant?;

          double price = 0;
          if (variant != null) {
            price = variant.purchasePrice ?? product.purchasePrice ?? 0;
          } else {
            price = product.purchasePrice ?? 0;
          }

          _items.add(
            CreatePurchaseOrderItemDto(
              productId: product.id,
              productVariantId: variant?.id,
              productName: variant?.name ?? product.name,
              sku: variant?.sku ?? product.sku,
              quantity: 1,
              unitPrice: price,
              discountAmount: 0,
              taxRate: 0,
            ),
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.length} محصول اضافه شد'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    }
  }

  Future<void> _createNewProduct() async {
    final result = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormPage(businessId: widget.businessId),
      ),
    );

    if (result != null && mounted) {
      if (result.hasVariants && result.variants != null && result.variants!.isNotEmpty) {
        _showVariantSelectionForProduct(result);
      } else {
        setState(() {
          _items.add(
            CreatePurchaseOrderItemDto(
              productId: result.id,
              productName: result.name,
              sku: result.sku,
              quantity: 1,
              unitPrice: result.purchasePrice ?? 0,
              discountAmount: 0,
              taxRate: 0,
            ),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('محصول با موفقیت اضافه شد'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    }
  }

  Future<void> _showVariantSelectionForProduct(Product product) async {
    final selectedVariants = await showDialog<List<ProductVariant>>(
      context: context,
      builder: (context) => _VariantSelectionDialog(product: product),
    );

    if (selectedVariants != null && selectedVariants.isNotEmpty && mounted) {
      setState(() {
        for (var variant in selectedVariants) {
          _items.add(
            CreatePurchaseOrderItemDto(
              productId: product.id,
              productVariantId: variant.id,
              productName: variant.name ?? '${product.name} - ${variant.sku}',
              sku: variant.sku,
              quantity: 1,
              unitPrice: variant.purchasePrice ?? product.purchasePrice ?? 0,
              discountAmount: 0,
              taxRate: 0,
            ),
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedVariants.length} تنوع با موفقیت اضافه شد'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً حداقل یک کالا اضافه کنید')),
      );
      return;
    }

    final provider = context.read<PurchaseOrderProvider>();

    final dto = CreatePurchaseOrderDto(
      supplierId: _selectedSupplier!.id,
      orderNumber: _orderNumberController.text,
      type: _selectedType,
      orderDate: _orderDate,
      expectedDeliveryDate: _expectedDeliveryDate,
      taxRate: double.tryParse(_taxRateController.text) ?? 0,
      discountAmount: double.tryParse(_discountController.text) ?? 0,
      shippingCost: double.tryParse(_shippingCostController.text) ?? 0,
      deliveryAddress: _deliveryAddressController.text.isNotEmpty
          ? _deliveryAddressController.text
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      items: _items,
    );

    try {
      if (widget.purchaseOrder == null) {
        await provider.createPurchaseOrder(widget.businessId, dto);
      } else {
        final updateDto = UpdatePurchaseOrderDto(
          supplierId: _selectedSupplier!.id,
          type: _selectedType,
          orderDate: _orderDate,
          expectedDeliveryDate: _expectedDeliveryDate,
          taxRate: double.tryParse(_taxRateController.text) ?? 0,
          discountAmount: double.tryParse(_discountController.text) ?? 0,
          shippingCost: double.tryParse(_shippingCostController.text) ?? 0,
          deliveryAddress: _deliveryAddressController.text.isNotEmpty
              ? _deliveryAddressController.text
              : null,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          items: _items,
        );

        await provider.updatePurchaseOrder(
          widget.businessId,
          widget.purchaseOrderId ?? widget.purchaseOrder!.id,
          updateDto,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('سفارش با موفقیت ثبت شد'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        context.go('/purchase-orders', extra: widget.businessId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا: $e')));
      }
    }
  }
}

// Variant Selection Dialog
class _VariantSelectionDialog extends StatefulWidget {
  final Product product;

  const _VariantSelectionDialog({required this.product});

  @override
  State<_VariantSelectionDialog> createState() =>
      _VariantSelectionDialogState();
}

class _VariantSelectionDialogState extends State<_VariantSelectionDialog> {
  final Set<String> _selectedVariantIds = {};

  @override
  Widget build(BuildContext context) {
    final variants = widget.product.variants ?? [];

    return AlertDialog(
      title: Text('انتخاب تنوع - ${widget.product.name}'),
      content: SizedBox(
        width: 500,
        child: variants.isEmpty
            ? const Center(child: Text('تنوعی یافت نشد'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: variants.length,
                itemBuilder: (context, index) {
                  final variant = variants[index];
                  final isSelected = _selectedVariantIds.contains(variant.id);

                  return CheckboxListTile(
                    title: Text(variant.name ?? variant.sku),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (variant.sku.isNotEmpty) Text('SKU: ${variant.sku}'),
                        Text(
                          'قیمت خرید: ${NumberFormatter.formatCurrency(variant.purchasePrice ?? widget.product.purchasePrice ?? 0)}',
                        ),
                      ],
                    ),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedVariantIds.add(variant.id);
                        } else {
                          _selectedVariantIds.remove(variant.id);
                        }
                      });
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('لغو'),
        ),
        FilledButton(
          onPressed: _selectedVariantIds.isEmpty
              ? null
              : () {
                  final selected = variants
                      .where((v) => _selectedVariantIds.contains(v.id))
                      .toList();
                  Navigator.pop(context, selected);
                },
          child: Text('افزودن (${_selectedVariantIds.length})'),
        ),
      ],
    );
  }
}
