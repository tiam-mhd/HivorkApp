import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../constants/persian_calendar_constants.dart';

/// تقویم شمسی فشرده با Picker عمودی (iOS Style)
class CompactPersianDatePicker extends StatefulWidget {
  final Jalali? initialDate;
  final Function(Jalali) onDateSelected;

  const CompactPersianDatePicker({
    Key? key,
    this.initialDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<CompactPersianDatePicker> createState() => _CompactPersianDatePickerState();
}

class _CompactPersianDatePickerState extends State<CompactPersianDatePicker> {
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;
  
  late Jalali _selectedDate;
  
  // لیست سال‌ها (از 1380 تا 1420)
  final List<int> _years = List.generate(41, (i) => 1380 + i);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? Jalali.now();
    
    // تنظیم scroll controllers برای نمایش تاریخ اولیه
    _dayController = FixedExtentScrollController(initialItem: _selectedDate.day - 1);
    _monthController = FixedExtentScrollController(initialItem: _selectedDate.month - 1);
    _yearController = FixedExtentScrollController(initialItem: _years.indexOf(_selectedDate.year));
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }
  
  void _updateDate() {
    widget.onDateSelected(_selectedDate);
  }
  
  void _setToday() {
    final today = Jalali.now();
    setState(() {
      _selectedDate = today;
      _dayController.animateToItem(
        today.day - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _monthController.animateToItem(
        today.month - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _yearController.animateToItem(
        _years.indexOf(today.year),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }
  
  void _setYesterday() {
    final yesterday = Jalali.now().addDays(-1);
    setState(() {
      _selectedDate = yesterday;
      _dayController.animateToItem(
        yesterday.day - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _monthController.animateToItem(
        yesterday.month - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _yearController.animateToItem(
        _years.indexOf(yesterday.year),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }
  
  void _setTomorrow() {
    final tomorrow = Jalali.now().addDays(1);
    setState(() {
      _selectedDate = tomorrow;
      _dayController.animateToItem(
        tomorrow.day - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _monthController.animateToItem(
        tomorrow.month - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _yearController.animateToItem(
        _years.indexOf(tomorrow.year),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.65,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(theme),

          // دکمه‌های سریع (امروز، دیروز، فردا)
          _buildQuickButtons(theme),

          // Picker با سه ستون
          Expanded(
            child: _buildDatePicker(theme),
          ),

          // دکمه تایید
          _buildConfirmButton(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'تاریخ فاکتور',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _setTomorrow,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
              child: const Text('فردا'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: _setToday,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('امروز'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: _setYesterday,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
              child: const Text('دیروز'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return Stack(
      children: [
        // سه ستون picker
        Row(
          children: [
            // ستون روز
            Expanded(
              child: _buildPickerColumn(
                controller: _dayController,
                itemCount: _selectedDate.monthLength,
                itemBuilder: (index) => (index + 1).toString(),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedDate = Jalali(_selectedDate.year, _selectedDate.month, index + 1);
                    _updateDate();
                  });
                },
              ),
            ),
            
            // جداکننده
            Container(
              width: 1,
              color: theme.colorScheme.outlineVariant,
              margin: const EdgeInsets.symmetric(vertical: 40),
            ),
            
            // ستون ماه
            Expanded(
              flex: 2,
              child: _buildPickerColumn(
                controller: _monthController,
                itemCount: 12,
                itemBuilder: (index) => PersianCalendarConstants.monthNames[index],
                onSelectedItemChanged: (index) {
                  setState(() {
                    final maxDay = Jalali(_selectedDate.year, index + 1, 1).monthLength;
                    final day = _selectedDate.day > maxDay ? maxDay : _selectedDate.day;
                    _selectedDate = Jalali(_selectedDate.year, index + 1, day);
                    
                    // آپدیت کنترلر روز اگر ماه عوض شد
                    if (_selectedDate.day != day) {
                      _dayController.jumpToItem(day - 1);
                    }
                    _updateDate();
                  });
                },
              ),
            ),
            
            // جداکننده
            Container(
              width: 1,
              color: theme.colorScheme.outlineVariant,
              margin: const EdgeInsets.symmetric(vertical: 40),
            ),
            
            // ستون سال
            Expanded(
              child: _buildPickerColumn(
                controller: _yearController,
                itemCount: _years.length,
                itemBuilder: (index) => _years[index].toString(),
                onSelectedItemChanged: (index) {
                  setState(() {
                    final year = _years[index];
                    final maxDay = Jalali(year, _selectedDate.month, 1).monthLength;
                    final day = _selectedDate.day > maxDay ? maxDay : _selectedDate.day;
                    _selectedDate = Jalali(year, _selectedDate.month, day);
                    
                    // آپدیت کنترلر روز اگر سال کبیسه عوض شد
                    if (_selectedDate.day != day) {
                      _dayController.jumpToItem(day - 1);
                    }
                    _updateDate();
                  });
                },
              ),
            ),
          ],
        ),
        
        // خط انتخاب وسط
        Center(
          child: IgnorePointer(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                color: theme.colorScheme.primaryContainer.withOpacity(0.1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerColumn({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) itemBuilder,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 48,
      perspective: 0.005,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          if (index < 0 || index >= itemCount) return null;
          
          final theme = Theme.of(context);
          final isSelected = controller.selectedItem == index;
          
          return Center(
            child: Text(
              itemBuilder(index),
              style: TextStyle(
                fontSize: isSelected ? 20 : 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          );
        },
        childCount: itemCount,
      ),
    );
  }

  Widget _buildConfirmButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: () {
            widget.onDateSelected(_selectedDate);
            Navigator.pop(context, _selectedDate);
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check, size: 20),
              const SizedBox(width: 8),
              const Text(
                'تایید',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/// ���� ��� ���� ����� ����� �����
Future<Jalali?> showCompactPersianDatePicker({
  required BuildContext context,
  Jalali? initialDate,
}) async {
  return await showModalBottomSheet<Jalali>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CompactPersianDatePicker(
      initialDate: initialDate,
      onDateSelected: (date) {},
    ),
  );
}
