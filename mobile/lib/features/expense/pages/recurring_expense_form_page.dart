import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hivork_app/core/widgets/compact_persian_date_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../models/recurring_expense.dart';
import '../providers/recurring_expense_provider.dart';
import '../providers/expense_provider.dart';

class RecurringExpenseFormPage extends StatefulWidget {
  final String businessId;
  final RecurringExpense? expense;

  const RecurringExpenseFormPage({
    super.key,
    required this.businessId,
    this.expense,
  });

  @override
  State<RecurringExpenseFormPage> createState() =>
      _RecurringExpenseFormPageState();
}

class _RecurringExpenseFormPageState extends State<RecurringExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _intervalController = TextEditingController(text: '1');
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController();

  String? _selectedCategoryId;
  RecurringFrequency _selectedFrequency = RecurringFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _selectedPaymentMethod = 'cash';
  bool _isActive = true;
  bool _autoCreate = true;
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
    _intervalController.text = expense.interval.toString();
    _noteController.text = expense.note ?? '';
    _tagsController.text = expense.tags ?? '';
    _selectedCategoryId = expense.categoryId;
    _selectedFrequency = expense.frequency;
    _startDate = expense.startDate;
    _endDate = expense.endDate;
    _selectedPaymentMethod = expense.paymentMethod;
    _isActive = expense.isActive;
    _autoCreate = expense.autoCreate;
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', ''));
      final interval = int.parse(_intervalController.text);

      if (_isEditing) {
        final dto = UpdateRecurringExpenseDto(
          categoryId: _selectedCategoryId,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          amount: amount,
          frequency: _selectedFrequency,
          interval: interval,
          startDate: _startDate,
          endDate: _endDate,
          paymentMethod: _selectedPaymentMethod,
          isActive: _isActive,
          autoCreate: _autoCreate,
          tags: _tagsController.text.isEmpty ? null : _tagsController.text,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );

        await context.read<RecurringExpenseProvider>().updateRecurringExpense(
          id: widget.expense!.id,
          dto: dto,
        );
      } else {
        final dto = CreateRecurringExpenseDto(
          businessId: widget.businessId,
          categoryId: _selectedCategoryId,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          amount: amount,
          frequency: _selectedFrequency,
          interval: interval,
          startDate: _startDate,
          endDate: _endDate,
          paymentMethod: _selectedPaymentMethod,
          autoCreate: _autoCreate,
          tags: _tagsController.text.isEmpty ? null : _tagsController.text,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );

        await context.read<RecurringExpenseProvider>().createRecurringExpense(
          dto,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'هزینه تکراری با موفقیت ویرایش شد'
                  : 'هزینه تکراری با موفقیت ثبت شد',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      _showError('خطا در ذخیره: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ویرایش هزینه تکراری' : 'هزینه تکراری جدید'),
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
            _buildFrequencySection(),
            const SizedBox(height: 16),
            _buildDateSection(),
            const SizedBox(height: 16),
            _buildPaymentMethodField(),
            const SizedBox(height: 16),
            _buildSwitches(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildTagsField(),
            const SizedBox(height: 16),
            _buildNoteField(),
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
        hintText: 'مثلاً: اجاره ماهانه',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'عنوان الزامی است';
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
        if (double.tryParse(value) == null) {
          return 'مبلغ نامعتبر است';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildCategoryField() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          decoration: const InputDecoration(
            labelText: 'دسته‌بندی',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: provider.categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Row(
                children: [
                  Text(
                    category.icon ?? '📁',
                    style: const TextStyle(fontSize: 20),
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

  Widget _buildFrequencySection() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'دوره تکرار',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: RecurringFrequency.values.map((frequency) {
                final isSelected = _selectedFrequency == frequency;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(frequency.icon),
                      const SizedBox(width: 6),
                      Text(frequency.persianLabel),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primaryContainer,
                  backgroundColor: theme.colorScheme.surface,
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFrequency = frequency);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _intervalController,
              decoration: InputDecoration(
                labelText: 'فاصله تکرار',
                hintText: '1',
                helperText: 'مثلاً: هر 2 ماه یا هر 3 هفته',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.repeat),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'فاصله تکرار الزامی است';
                }
                final interval = int.tryParse(value);
                if (interval == null || interval < 1) {
                  return 'فاصله باید حداقل 1 باشد';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'بازه زمانی',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.play_circle),
              title: const Text('تاریخ شروع'),
              subtitle: Text(DateFormat('yyyy/MM/dd').format(_startDate)),
              onTap: () => _selectDate(context, isStartDate: true),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.stop_circle),
              title: const Text('تاریخ پایان (اختیاری)'),
              subtitle: Text(
                _endDate != null
                    ? DateFormat('yyyy/MM/dd').format(_endDate!)
                    : 'نامحدود',
              ),
              onTap: () => _selectDate(context, isStartDate: false),
              trailing: _endDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _endDate = null);
                      },
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodField() {
    return DropdownButtonFormField<String>(
      value: _selectedPaymentMethod,
      decoration: const InputDecoration(
        labelText: 'روش پرداخت',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.payment),
      ),
      items: const [
        DropdownMenuItem(value: 'cash', child: Text('نقدی')),
        DropdownMenuItem(value: 'card', child: Text('کارت بانکی')),
        DropdownMenuItem(value: 'cheque', child: Text('چک')),
        DropdownMenuItem(value: 'online', child: Text('آنلاین')),
        DropdownMenuItem(value: 'other', child: Text('سایر')),
      ],
      onChanged: (value) {
        setState(() => _selectedPaymentMethod = value!);
      },
    );
  }

  Widget _buildSwitches() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                'فعال',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'هزینه تکراری فعال باشد',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: _isActive,
              activeColor: theme.colorScheme.primary,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            SwitchListTile(
              title: Text(
                'ایجاد خودکار',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'به صورت خودکار هزینه ثبت شود',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: _autoCreate,
              activeColor: theme.colorScheme.primary,
              onChanged: (value) {
                setState(() => _autoCreate = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'توضیحات',
        hintText: 'توضیحات تکمیلی...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildTagsField() {
    return TextFormField(
      controller: _tagsController,
      decoration: const InputDecoration(
        labelText: 'برچسب‌ها',
        hintText: 'با کاما جدا کنید (مثال: اجاره, منزل)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.label),
      ),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      decoration: const InputDecoration(
        labelText: 'یادداشت',
        hintText: 'یادداشت‌های داخلی...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 2,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _saveExpense,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save),
      label: Text(_isEditing ? 'ویرایش' : 'ذخیره'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final initialDate = isStartDate ? _startDate : (_endDate ?? _startDate);
    final firstDate = isStartDate ? DateTime(2000) : _startDate;
    
    final jalaliDate = Jalali.fromDateTime(initialDate);

    final picked = await showCompactPersianDatePicker(
      context: context,
      initialDate: jalaliDate,
    );

    // final picked = await showDatePicker(
    //   context: context,
    //   initialDate: initialDate,
    //   firstDate: firstDate,
    //   lastDate: DateTime(2100),
    // );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked.toDateTime();
          // Reset end date if it's before new start date
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = picked.toDateTime();
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _intervalController.dispose();
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
