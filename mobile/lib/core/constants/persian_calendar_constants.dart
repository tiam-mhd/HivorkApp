/// ثابت‌های مشترک تقویم شمسی
class PersianCalendarConstants {
  // نام ماه‌های شمسی
  static const List<String> monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  // نام روزهای هفته (مخفف)
  static const List<String> weekDayNames = [
    'ش', // شنبه
    'ی', // یکشنبه
    'د', // دوشنبه
    'س', // سه‌شنبه
    'چ', // چهارشنبه
    'پ', // پنج‌شنبه
    'ج', // جمعه
  ];

  // نام روزهای هفته (کامل)
  static const List<String> weekDayFullNames = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه',
  ];

  // index روز جمعه
  static const int fridayIndex = 7;
}
