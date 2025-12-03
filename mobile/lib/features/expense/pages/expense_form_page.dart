import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hivork_app/core/widgets/compact_persian_date_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../core/utils/formatters.dart';
import '../models/models.dart';
import '../providers/expense_provider.dart';

class ExpenseFormPage extends StatefulWidget {
  final String businessId;
  final Expense? expense; // null for create, non-null for edit

  const ExpenseFormPage({super.key, required this.businessId, this.expense});

  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  PaymentMethod? _selectedPaymentMethod = PaymentMethod.cash;
  PaymentStatus _selectedPaymentStatus = PaymentStatus.paid;
  bool _isPaid = true;
  List<String> _tags = [];

  bool _isLoading = false;
  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateForm();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadCategories(widget.businessId);
    });
  }

  void _populateForm() {
    final expense = widget.expense!;
    _titleController.text = expense.title;
    _descriptionController.text = expense.description ?? '';
    _amountController.text = expense.amount.toString();
    _noteController.text = expense.note ?? '';
    _selectedCategoryId = expense.categoryId;
    _selectedDate = expense.expenseDate;
    _selectedPaymentMethod = expense.paymentMethod;
    _selectedPaymentStatus = expense.paymentStatus;
    _isPaid = expense.isPaid;
    _tags = expense.tags ?? [];
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final expenseProvider = context.read<ExpenseProvider>();

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', ''));

      if (_isEditing) {
        await expenseProvider.updateExpense(
          widget.expense!.id,
          categoryId: _selectedCategoryId,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          amount: amount,
          expenseDate: _selectedDate,
          paymentMethod: _selectedPaymentMethod?.value,
          paymentStatus: _selectedPaymentStatus.value,
          isPaid: _isPaid,
          tags: _tags.isEmpty ? null : _tags,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );
      } else {
        await expenseProvider.createExpense(
          businessId: widget.businessId,
          categoryId: _selectedCategoryId,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          amount: amount,
          expenseDate: _selectedDate,
          paymentMethod: _selectedPaymentMethod?.value,
          paymentStatus: _selectedPaymentStatus.value,
          isPaid: _isPaid,
          tags: _tags.isEmpty ? null : _tags,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'هزینه با موفقیت ویرایش شد'
                  : 'هزینه با موفقیت ثبت شد',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('خطا در ذخیره هزینه: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ویرایش هزینه' : 'هزینه جدید'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildCategoryField(),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildPaymentMethodField(),
            const SizedBox(height: 16),
            _buildPaymentStatusField(),
            const SizedBox(height: 16),
            _buildIsPaidSwitch(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildNoteField(),
            const SizedBox(height: 16),
            _buildTagsField(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'عنوان هزینه *',
        hintText: 'مثلا: خرید لوازم اداری',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'عنوان هزینه الزامی است';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'مبلغ (تومان) *',
        hintText: '0',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'مبلغ الزامی است';
        }
        final amount = double.tryParse(value.replaceAll(',', ''));
        if (amount == null || amount <= 0) {
          return 'مبلغ باید بیشتر از صفر باشد';
        }
        return null;
      },
      onChanged: (value) {
        // Format as currency while typing
        if (value.isNotEmpty) {
          final number = value.replaceAll(',', '');
          final formatted = Formatters.formatNumber(double.parse(number));
          if (formatted != value) {
            _amountController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        }
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildCategoryField() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        return DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          decoration: const InputDecoration(
            labelText: 'دسته‌بندی',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          hint: const Text('انتخاب دسته‌بندی'),
          items: provider.categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _parseColor(category.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedCategoryId = value);
          },
        );
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        // final picked = await showDatePicker(
        //   context: context,
        //   initialDate: _selectedDate,
        //   firstDate: DateTime(2000),
        //   lastDate: DateTime.now(),
        // );

        final jalaliDate = Jalali.fromDateTime(_selectedDate);

        final picked = await showCompactPersianDatePicker(
          context: context,
          initialDate: jalaliDate,
        );

        if (picked != null) {
          setState(() => _selectedDate = picked.toDateTime());
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'تاریخ هزینه *',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          Formatters.formatPersianDate(_selectedDate),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodField() {
    return DropdownButtonFormField<PaymentMethod>(
      value: _selectedPaymentMethod,
      decoration: const InputDecoration(
        labelText: 'روش پرداخت',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.payment),
      ),
      items: PaymentMethod.values.map((method) {
        return DropdownMenuItem(value: method, child: Text(method.label));
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedPaymentMethod = value);
      },
    );
  }

  Widget _buildPaymentStatusField() {
    return DropdownButtonFormField<PaymentStatus>(
      value: _selectedPaymentStatus,
      decoration: const InputDecoration(
        labelText: 'وضعیت پرداخت *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.check_circle_outline),
      ),
      items: PaymentStatus.values.map((status) {
        return DropdownMenuItem(value: status, child: Text(status.label));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPaymentStatus = value!;
          _isPaid = value == PaymentStatus.paid;
        });
      },
    );
  }

  Widget _buildIsPaidSwitch() {
    return SwitchListTile(
      title: const Text('پرداخت شده'),
      subtitle: const Text('آیا این هزینه پرداخت شده است؟'),
      value: _isPaid,
      onChanged: (value) {
        setState(() {
          _isPaid = value;
          if (value) {
            _selectedPaymentStatus = PaymentStatus.paid;
          } else {
            _selectedPaymentStatus = PaymentStatus.pending;
          }
        });
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'توضیحات',
        hintText: 'جزئیات هزینه را وارد کنید',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      textInputAction: TextInputAction.newline,
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      decoration: const InputDecoration(
        labelText: 'یادداشت',
        hintText: 'یادداشت خصوصی',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 2,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'برچسب‌ها',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addTag,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('افزودن برچسب'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_tags.isEmpty)
          const Text(
            'هیچ برچسبی اضافه نشده',
            style: TextStyle(color: Colors.grey),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () {
                  setState(() => _tags.remove(tag));
                },
                deleteIcon: const Icon(Icons.close, size: 16),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('افزودن برچسب'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'نام برچسب',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() => _tags.add(controller.text));
                  Navigator.pop(context);
                }
              },
              child: const Text('افزودن'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveExpense,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              _isEditing ? 'ذخیره تغییرات' : 'ثبت هزینه',
              style: const TextStyle(fontSize: 16),
            ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف هزینه'),
        content: const Text('آیا از حذف این هزینه اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteExpense();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExpense() async {
    setState(() => _isLoading = true);

    final success = await context.read<ExpenseProvider>().deleteExpense(
      widget.expense!.id,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هزینه با موفقیت حذف شد'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError('خطا در حذف هزینه');
        setState(() => _isLoading = false);
      }
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
