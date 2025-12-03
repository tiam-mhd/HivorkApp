# راهنمای آیکون اپلیکیشن

## آیکون ارسالی شما
آیکون نارنجی شش‌ضلعی با طرح مشکی در داخل

## مراحل نصب آیکون:

### 1. آماده‌سازی تصاویر

تصویر آیکونی که فرستادید رو با نام‌های زیر در این پوشه قرار بدید:

#### الف) برای همه پلتفرم‌ها:
- **app_icon.png**: تصویر اصلی با سایز 1024x1024 پیکسل
  - باید background نارنجی (#FF9800) و آیکون مشکی داخلش باشه

#### ب) برای Android Adaptive Icon (اختیاری اما توصیه می‌شود):
- **app_icon_foreground.png**: فقط طرح مشکی شش‌ضلعی بدون background (1024x1024)
  - این تصویر باید transparent background داشته باشه
  - رنگ background از تنظیمات pubspec.yaml استفاده می‌شه (#FF9800)

### 2. اجرای دستور تولید آیکون

بعد از قرار دادن تصاویر، این دستورات رو اجرا کن:

```bash
cd D:\Tiam\Startup\HivorkApp\mobile
flutter pub get
flutter pub run flutter_launcher_icons
```

### 3. نتیجه

بعد از اجرای دستورات:
- ✅ آیکون‌های Android در سایزهای مختلف تولید می‌شه
- ✅ آیکون‌های iOS تولید می‌شه  
- ✅ آیکون وب تولید می‌شه
- ✅ Adaptive icons برای Android نصب می‌شه

---

## توضیحات تکنیکی

### رنگ نارنجی: 
- Hex: `#FF9800`
- RGB: `(255, 152, 0)`

### سایزهایی که تولید می‌شن:

**Android:**
- mipmap-mdpi: 48x48
- mipmap-hdpi: 72x72
- mipmap-xhdpi: 96x96
- mipmap-xxhdpi: 144x144
- mipmap-xxxhdpi: 192x192

**iOS:**
- 20x20 (@1x, @2x, @3x)
- 29x29 (@1x, @2x, @3x)
- 40x40 (@1x, @2x, @3x)
- 60x60 (@2x, @3x)
- 76x76 (@1x, @2x)
- 83.5x83.5 (@2x)
- 1024x1024 (@1x)

**Web:**
- favicon.png
- Icon-192.png
- Icon-512.png
- Icon-maskable-192.png
- Icon-maskable-512.png

---

## نکات مهم:

1. **کیفیت تصویر**: حتماً از تصویر با کیفیت بالا (1024x1024) استفاده کنید
2. **فرمت**: PNG با پشتیبانی از transparency
3. **Safe Area**: 10% حاشیه اطراف رو خالی بذارید برای adaptive icons
4. **تست**: بعد از تولید حتماً روی دستگاه واقعی تست کنید

---

## مشکلات رایج:

### اگر دستور اجرا نشد:
```bash
# پاک کردن کش
flutter clean
flutter pub get
dart run flutter_launcher_icons
```

### اگر آیکون تغییر نکرد:
1. اپلیکیشن رو uninstall کنید
2. دوباره build بگیرید و نصب کنید

---

## فایل‌های مورد نیاز:

در این پوشه قرار بدید:
- [ ] app_icon.png (1024x1024)
- [ ] app_icon_foreground.png (1024x1024, transparent) - اختیاری
