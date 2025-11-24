import 'package:shamsi_date/shamsi_date.dart';

extension DateExtensions on DateTime {
  /// تبدیل به تاریخ شمسی
  String toPersianDate() {
    final jalali = Jalali.fromDateTime(this);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  /// تبدیل به تاریخ و زمان شمسی
  String toPersianDateTime() {
    final jalali = Jalali.fromDateTime(this);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')} - ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// نمایش تاریخ به صورت نسبی (امروز، دیروز و...)
  String toRelativePersianDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(year, month, day);

    if (dateToCheck == today) {
      return 'امروز';
    } else if (dateToCheck == yesterday) {
      return 'دیروز';
    } else {
      return toPersianDate();
    }
  }

  /// اختلاف روزها
  int differenceInDays(DateTime other) {
    final date1 = DateTime(year, month, day);
    final date2 = DateTime(other.year, other.month, other.day);
    return date1.difference(date2).inDays;
  }

  /// بررسی اینکه آیا تاریخ امروز است یا نه
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// بررسی اینکه آیا تاریخ دیروز است یا نه
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}
