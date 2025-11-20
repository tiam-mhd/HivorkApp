import 'package:intl/intl.dart' as intl;
import 'package:shamsi_date/shamsi_date.dart';

class DateFormatter {
  static String formatPersianDate(DateTime date) {
    final shamsi = Jalali.fromDateTime(date);
    return '${shamsi.year}/${shamsi.month.toString().padLeft(2, '0')}/${shamsi.day.toString().padLeft(2, '0')}';
  }

  static String formatPersianDateTime(DateTime dateTime) {
    final shamsi = Jalali.fromDateTime(dateTime);
    final time = intl.DateFormat('HH:mm').format(dateTime);
    return '${shamsi.year}/${shamsi.month.toString().padLeft(2, '0')}/${shamsi.day.toString().padLeft(2, '0')} $time';
  }

  static DateTime? parsePersianDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length != 3) return null;
      
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      
      return Jalali(year, month, day).toDateTime();
    } catch (e) {
      return null;
    }
  }
}

class NumberFormatter {
  static String formatCurrency(num amount) {
    final formatter = intl.NumberFormat('#,###', 'fa');
    return '${formatter.format(amount)} ریال';
  }

  static String formatNumber(num number) {
    final formatter = intl.NumberFormat('#,###', 'fa');
    return formatter.format(number);
  }

  static String formatPercentage(num percentage) {
    return '$percentage٪';
  }
}

class PhoneFormatter {
  static String formatPhone(String phone) {
    if (phone.length == 11 && phone.startsWith('0')) {
      return '${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}';
    }
    return phone;
  }

  static String cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
