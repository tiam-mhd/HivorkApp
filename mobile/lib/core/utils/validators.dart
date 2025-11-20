class Validators {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'شماره تلفن الزامی است';
    }
    
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleaned.length != 11) {
      return 'شماره تلفن باید 11 رقم باشد';
    }
    
    if (!cleaned.startsWith('09')) {
      return 'شماره تلفن باید با 09 شروع شود';
    }
    
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'ایمیل نامعتبر است';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز عبور الزامی است';
    }
    
    if (value.length < 8) {
      return 'رمز عبور باید حداقل 8 کاراکتر باشد';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'رمز عبور باید حداقل یک حرف بزرگ داشته باشد';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'رمز عبور باید حداقل یک حرف کوچک داشته باشد';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'رمز عبور باید حداقل یک عدد داشته باشد';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName الزامی است';
    }
    return null;
  }

  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (double.tryParse(value) == null) {
      return 'لطفا یک عدد معتبر وارد کنید';
    }
    
    return null;
  }

  static String? validatePositiveNumber(String? value) {
    final numberError = validateNumber(value);
    if (numberError != null) return numberError;
    
    if (value != null && double.parse(value) < 0) {
      return 'عدد باید مثبت باشد';
    }
    
    return null;
  }
}
