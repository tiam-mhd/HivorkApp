class NumberFormatter {
  /// فرمت کردن عدد به فرمت ریالی
  static String formatCurrency(double? amount) {
    if (amount == null) return '۰ ریال';
    try {
      // Simple formatting without intl package issues
      final formatted = amount.toStringAsFixed(0);
      final withComma = _addThousandSeparator(formatted);
      return '$withComma ریال';
    } catch (e) {
      return '${amount.toStringAsFixed(0)} ریال';
    }
  }

  /// فرمت کردن عدد به فرمت ریالی بدون واحد
  static String formatNumber(double? amount) {
    if (amount == null) return '۰';
    try {
      final formatted = amount.toStringAsFixed(0);
      return _addThousandSeparator(formatted);
    } catch (e) {
      return amount.toStringAsFixed(0);
    }
  }

  /// اضافه کردن جداکننده هزارگان
  static String _addThousandSeparator(String number) {
    // Remove any existing separators
    number = number.replaceAll(',', '');
    
    // Add thousand separators
    final parts = number.split('.');
    final integerPart = parts[0];
    final result = StringBuffer();
    
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(integerPart[i]);
    }
    
    if (parts.length > 1) {
      result.write('.');
      result.write(parts[1]);
    }
    
    return result.toString();
  }

  /// فرمت کردن عدد اعشاری
  static String formatDecimal(double? amount) {
    if (amount == null) return '۰';
    try {
      return amount.toStringAsFixed(2);
    } catch (e) {
      return amount.toStringAsFixed(2);
    }
  }

  /// تبدیل اعداد انگلیسی به فارسی
  static String toPersianNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    String output = input;
    for (int i = 0; i < english.length; i++) {
      output = output.replaceAll(english[i], persian[i]);
    }
    return output;
  }

  /// تبدیل اعداد فارسی به انگلیسی
  static String toEnglishNumber(String input) {
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String output = input;
    for (int i = 0; i < persian.length; i++) {
      output = output.replaceAll(persian[i], english[i]);
    }
    return output;
  }

  /// فرمت کردن درصد
  static String formatPercentage(double? percentage) {
    if (percentage == null) return '۰٪';
    return '${formatDecimal(percentage)}٪';
  }
}
