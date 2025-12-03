# تقویم‌های شمسی حرفه‌ای 🗓️

دو تقویم شمسی با طراحی **مدرن و حرفه‌ای** که کاملاً سازگار با تم light/dark mode هستند.

---

## 1. تقویم کامل (PersianDatePicker) 📅

تقویم افقی با قابلیت swipe و انیمیشن

### ویژگی‌های برتر:
- ✅ **PageView افقی** - swipe کردن بین ماه‌ها
- ✅ **Bottom Sheet** با handle bar
- ✅ نمایش تاریخ انتخابی با کارت زیبا و gradient
- ✅ دکمه "امروز" برای بازگشت سریع
- ✅ انیمیشن smooth برای انتخاب
- ✅ جمعه‌ها قرمز رنگ
- ✅ هایلایت روز جاری
- ✅ دکمه‌های تایید/لغو با طراحی مدرن

### نحوه استفاده:

```dart
import 'package:hivork_app/core/widgets/persian_date_picker.dart';

final selectedDate = await showPersianDatePicker(
  context: context,
  initialDate: Jalali.now(),
);

if (selectedDate != null) {
  print('انتخاب شد: ${selectedDate.formatCompactDate()}');
}
```

---

## 2. تقویم فشرده (CompactPersianDatePicker) 🎯

تقویم با دسترسی سریع به تاریخ‌های رایج

### ویژگی‌های برتر:
- ✅ تب‌های سریع: **فردا، امروز، دیروز**
- ✅ لیست عمودی **قابل اسکرول** از ماه‌ها
- ✅ هر ماه با 10 سال اخیر
- ✅ شماره ماه در دایره
- ✅ هایلایت ماه و سال جاری
- ✅ انیمیشن انتخاب
- ✅ دکمه تایید با نمایش تاریخ

### نحوه استفاده:

```dart
import 'package:hivork_app/core/widgets/compact_persian_date_picker.dart';

final selectedDate = await showCompactPersianDatePicker(
  context: context,
  initialDate: Jalali.now(),
);

if (selectedDate != null) {
  final dateTime = selectedDate.toDateTime();
}
```

---

## مقایسه و کاربرد

| ویژگی | PersianDatePicker | CompactPersianDatePicker |
|-------|------------------|-------------------------|
| **حالت نمایش** | افقی (Swipe) | عمودی (Scroll) |
| **مناسب برای** | انتخاب دقیق روز | انتخاب سریع ماه/سال |
| **تب‌های سریع** | ❌ | ✅ (فردا/امروز/دیروز) |
| **اسکرول** | افقی | عمودی |
| **UI** | کارت تاریخ با gradient | لیست ماه‌ها با سال‌ها |

---

## پیشنهادات استفاده

### استفاده از PersianDatePicker برای:
- ✅ فرم‌های ثبت نام
- ✅ انتخاب تاریخ تولد
- ✅ رزرو و نوبت‌دهی
- ✅ هر جایی که روز دقیق مهمه

### استفاده از CompactPersianDatePicker برای:
- ✅ فاکتورها (با دسترسی سریع به امروز/دیروز/فردا)
- ✅ گزارش‌های ماهانه
- ✅ فیلتر تاریخی
- ✅ انتخاب سریع ماه و سال

---

## نمونه کامل در Invoice

```dart
Future<void> _selectDate() async {
  final jalaliDate = Jalali.fromDateTime(_selectedDate);
  
  // برای فاکتور از CompactPersianDatePicker استفاده کن
  final picked = await showCompactPersianDatePicker(
    context: context,
    initialDate: jalaliDate,
  );

  if (picked != null) {
    setState(() {
      _selectedDate = picked.toDateTime();
    });
  }
}
```

---

## تبدیل بین تاریخ‌ها

```dart
// Jalali به DateTime
final jalali = Jalali(1403, 9, 10);
final dateTime = jalali.toDateTime();

// DateTime به Jalali  
final dateTime = DateTime.now();
final jalali = Jalali.fromDateTime(dateTime);

// فرمت کردن
print(jalali.formatCompactDate()); // ۱۰ آذر ۱۴۰۳
```

---

## نکات طراحی UI

### رنگ‌ها به طور خودکار از تم استفاده می‌کنند:
- `primary`: دکمه‌ها و انتخاب‌ها
- `primaryContainer`: کارت‌ها و هایلایت‌ها
- `surface`: پس‌زمینه
- `error`: جمعه‌ها
- `onPrimary/onSurface`: متن‌ها

### انیمیشن‌ها:
- ✅ Fade & Slide برای ماه‌ها
- ✅ Scale برای انتخاب روز
- ✅ Smooth page transition
- ✅ Tab indicator animation

---

## نیازمندی‌ها

```yaml
dependencies:
  shamsi_date: ^1.1.0
```

---

## Performance

- ⚡ 60 FPS در همه انیمیشن‌ها
- 🎯 Lazy loading برای ماه‌ها
- 💾 حافظه بهینه با PageView
- 🚀 بدون lag در اسکرول

---

## پشتیبانی

- ✅ Android 5.0+ (API 21+)
- ✅ iOS 11.0+
- ✅ Web
- ✅ Desktop (Windows, macOS, Linux)

---

## تغییرات نسخه جدید

### نسخه 2.0
- 🎉 طراحی کاملاً جدید
- ⚡ PageView افقی با swipe
- 🎨 Bottom Sheet به جای Dialog
- 📱 بهتر برای موبایل
- 🎯 تب‌های سریع در Compact
- 📜 اسکرول عمودی برای ماه‌ها
- ✨ انیمیشن‌های smooth

تقویم با ویژگی‌های کامل و حرفه‌ای

### ویژگی‌ها:
- ✅ هدر زیبا با gradient
- ✅ انتخابگر ماه و سال
- ✅ نمایش کامل روزهای ماه
- ✅ هایلایت روز جاری و روز انتخابی
- ✅ نمایش جمعه‌ها به رنگ قرمز
- ✅ سه حالت نمایش: روزها، ماه‌ها، سال‌ها
- ✅ دکمه‌های تایید و لغو
- ✅ سازگار کامل با light/dark mode

### نحوه استفاده:

```dart
import 'package:hivork_app/core/widgets/persian_date_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

// در داخل تابع async
final selectedDate = await showPersianDatePicker(
  context: context,
  initialDate: Jalali.now(),
  firstDate: Jalali(1400, 1, 1),
  lastDate: Jalali(1410, 12, 29),
);

if (selectedDate != null) {
  print('تاریخ انتخابی: ${selectedDate.year}/${selectedDate.month}/${selectedDate.day}');
}
```

---

## 2. تقویم فشرده (CompactPersianDatePicker)

تقویم با طراحی جدولی مطابق طرح ارائه شده

### ویژگی‌ها:
- ✅ تب‌های سریع: امروز، دیروز، فردا
- ✅ جدول انتخاب ماه و سال
- ✅ طراحی فشرده و زیبا
- ✅ انتخاب سریع از جدول
- ✅ دکمه تایید بزرگ
- ✅ سازگار با light/dark mode

### نحوه استفاده:

```dart
import 'package:hivork_app/core/widgets/compact_persian_date_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

// در داخل تابع async
final selectedDate = await showCompactPersianDatePicker(
  context: context,
  initialDate: Jalali.now(),
);

if (selectedDate != null) {
  // تبدیل به DateTime در صورت نیاز
  final dateTime = selectedDate.toDateTime();
  print('تاریخ انتخابی: $dateTime');
}
```

---

## تبدیل بین Jalali و DateTime

### از Jalali به DateTime:
```dart
final jalali = Jalali(1403, 9, 10);
final dateTime = jalali.toDateTime();
```

### از DateTime به Jalali:
```dart
final dateTime = DateTime.now();
final jalali = Jalali.fromDateTime(dateTime);
```

---

## نمونه کامل در Invoice

```dart
Future<void> _selectDate() async {
  // تبدیل تاریخ فعلی به شمسی
  final jalaliDate = Jalali.fromDateTime(_selectedDate);
  
  // نمایش تقویم
  final picked = await showCompactPersianDatePicker(
    context: context,
    initialDate: jalaliDate,
  );

  if (picked != null) {
    setState(() {
      // تبدیل به DateTime و ذخیره
      _selectedDate = picked.toDateTime();
    });
  }
}
```

---

## سفارشی‌سازی رنگ‌ها

تقویم‌ها به طور خودکار از رنگ‌های تم پروژه استفاده می‌کنند:

- `theme.colorScheme.primary`: رنگ اصلی
- `theme.colorScheme.surface`: پس‌زمینه
- `theme.colorScheme.error`: جمعه‌ها
- `theme.colorScheme.primaryContainer`: هایلایت‌ها

برای تغییر رنگ‌ها، کافیست تم اپلیکیشن را تغییر دهید.

---

## نکات مهم

1. **Package مورد نیاز**: مطمئن شوید `shamsi_date: ^1.1.0` در `pubspec.yaml` نصب شده
2. **Import**: حتماً `shamsi_date` را import کنید
3. **Performance**: هر دو تقویم بهینه‌سازی شده و performance عالی دارند
4. **Responsive**: به طور خودکار با سایزهای مختلف صفحه سازگار هستند

---

## پیشنهادات استفاده

- **فرم‌های ساده**: از `CompactPersianDatePicker` استفاده کنید
- **انتخاب دقیق**: از `PersianDatePicker` استفاده کنید
- **فاکتورها**: `CompactPersianDatePicker` با تب‌های سریع مناسب‌تر است
- **گزارش‌ها**: `PersianDatePicker` با امکانات بیشتر بهتر است
