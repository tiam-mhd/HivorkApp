import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../constants/persian_calendar_constants.dart';

/// تقویم شمسی حرفه‌ای با طراحی مدرن
class PersianDatePicker extends StatefulWidget {
  final Jalali? initialDate;
  final Jalali? firstDate;
  final Jalali? lastDate;
  final Function(Jalali) onDateSelected;

  const PersianDatePicker({
    Key? key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<PersianDatePicker> createState() => _PersianDatePickerState();
}

class _PersianDatePickerState extends State<PersianDatePicker> {
  late PageController _pageController;
  late Jalali _selectedDate;
  late Jalali _displayMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? Jalali.now();
    _displayMonth = Jalali(_selectedDate.year, _selectedDate.month, 1);
    
    // محاسبه index اولیه (200 ماه قبل از امروز)
    final monthsSinceEpoch = (_displayMonth.year - 1400) * 12 + _displayMonth.month - 1;
    _pageController = PageController(initialPage: 200 + monthsSinceEpoch);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Jalali _getMonthForPage(int page) {
    final monthIndex = page - 200;
    final year = 1400 + (monthIndex ~/ 12);
    final month = (monthIndex % 12) + 1;
    return Jalali(year, month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle bar
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

          // تاریخ انتخابی
          _buildSelectedDateDisplay(theme),

          // روزهای هفته
          _buildWeekDaysHeader(theme),

          // تقویم با PageView افقی
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _displayMonth = _getMonthForPage(page);
                });
              },
              itemBuilder: (context, page) {
                final monthDate = _getMonthForPage(page);
                return _buildMonthGrid(theme, monthDate);
              },
            ),
          ),

          // دکمه‌های اکشن
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // دکمه بستن
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceVariant,
            ),
          ),

          // نمایش ماه و سال
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  PersianCalendarConstants.monthNames[_displayMonth.month - 1],
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _displayMonth.year.toString(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // دکمه امروز
          TextButton(
            onPressed: () {
              final today = Jalali.now();
              final todayMonthIndex = (today.year - 1400) * 12 + today.month - 1;
              _pageController.animateToPage(
                200 + todayMonthIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() {
                _selectedDate = today;
                _displayMonth = Jalali(today.year, today.month, 1);
              });
            },
            child: const Text('امروز'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateDisplay(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تاریخ انتخابی',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedDate.day} ${PersianCalendarConstants.monthNames[_selectedDate.month - 1]} ${_selectedDate.year}',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: PersianCalendarConstants.weekDayNames.map((day) {
          final isFriday = day == 'ج';
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  color: isFriday
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthGrid(ThemeData theme, Jalali monthDate) {
    final days = _getDaysInMonth(monthDate);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          if (date == null) return const SizedBox.shrink();

          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;
          
          final isToday = date.year == Jalali.now().year &&
              date.month == Jalali.now().month &&
              date.day == Jalali.now().day;
          
          final isFriday = date.weekDay == 7;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
                widget.onDateSelected(date);
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : isToday
                          ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isToday && !isSelected
                      ? Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.5),
                          width: 2,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : isFriday
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Jalali?> _getDaysInMonth(Jalali monthDate) {
    final daysInMonth = monthDate.monthLength;
    final firstWeekDay = monthDate.weekDay;
    
    List<Jalali?> days = [];
    
    for (int i = 1; i < firstWeekDay; i++) {
      days.add(null);
    }
    
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(Jalali(monthDate.year, monthDate.month, i));
    }
    
    return days;
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('لغو'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
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
                  Text(
                    'تایید (${_selectedDate.day} ${PersianCalendarConstants.monthNames[_selectedDate.month - 1]})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



/// تابع کمکی برای نمایش تقویم شمسی
Future<Jalali?> showPersianDatePicker({
  required BuildContext context,
  Jalali? initialDate,
  Jalali? firstDate,
  Jalali? lastDate,
}) async {
  return await showModalBottomSheet<Jalali>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PersianDatePicker(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      onDateSelected: (date) {},
    ),
  );
}
