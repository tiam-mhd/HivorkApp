# 🚀 Hivork - سیستم مدیریت مالی و کسب‌وکار

cd mobile; dart run build_runner build --delete-conflicting-outputs

## 📋 درباره پروژه

Hivork یک پلتفرم SaaS جامع برای مدیریت مالی و عملیات کسب‌وکارهای کوچک و متوسط است که شامل:

- 🏢 مدیریت چند کسب‌وکار
- 📦 مدیریت محصولات و موجودی
- 👥 مدیریت مشتریان
- 🧾 صدور فاکتور و فروش
- 💰 مدیریت پرداخت‌ها و هزینه‌ها
- 📊 گزارش‌گیری و تحلیل هوشمند

---

## 🏗️ معماری سیستم

```
hivork/
├── hivork-backend/          # Backend API (NestJS)
├── hivork-app/              # Mobile App (Flutter)
├── hivork-admin/            # Admin Dashboard (Angular)
├── docker-compose.yml       # Docker Services
└── docs/                    # Documentation
```

### Technology Stack

**Backend:**
- NestJS (Node.js Framework)
- PostgreSQL (Database)
- Redis (Cache & Queue)
- TypeORM (ORM)
- JWT Authentication

**Mobile App:**
- Flutter 3.16+
- Riverpod (State Management)
- Go Router (Routing)

**Admin Panel:**
- Angular 17+
- NgRx (State Management)
- Angular Material + Tailwind CSS

---

## 🚀 راه‌اندازی سریع

### پیش‌نیازها

قبل از شروع، مطمئن شوید این ابزارها نصب شده‌اند:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (v20+)
- [Node.js](https://nodejs.org/) (v20+)
- [Git](https://git-scm.com/)

### مرحله 1: کلون پروژه

```bash
git clone https://github.com/your-username/hivork.git
cd hivork
```

### مرحله 2: راه‌اندازی Services

```bash
# کپی فایل environment
cp .env.example .env

# ویرایش .env و تنظیم مقادیر مورد نیاز
notepad .env

# راه‌اندازی PostgreSQL و Redis
docker-compose up -d

# چک کردن وضعیت
docker-compose ps
```

**دسترسی به Services:**
- PostgreSQL: `localhost:5432`
- Redis: `localhost:6379`
- PgAdmin: http://localhost:5050 (admin@hivork.com / admin123)
- Redis Commander: http://localhost:8081

### مرحله 3: راه‌اندازی Backend

```bash
cd hivork-backend

# نصب dependencies
npm install

# اجرای migrations
npm run migration:run

# Seed دیتای اولیه (اختیاری)
npm run seed

# اجرای در حالت Development
npm run start:dev

# Backend در دسترس است: http://localhost:3000
# API Docs (Swagger): http://localhost:3000/api/docs
```

### مرحله 4: راه‌اندازی Flutter App

```bash
cd hivork-app

# نصب dependencies
flutter pub get

# اجرای app
flutter run

# یا برای Web:
flutter run -d chrome
```

### مرحله 5: راه‌اندازی Admin Panel

```bash
cd hivork-admin

# نصب dependencies
npm install

# اجرای در حالت Development
npm start

# Admin Panel: http://localhost:4200
```

---

## 🧪 Testing

### Backend Tests

```bash
cd hivork-backend

# Unit Tests
npm run test

# E2E Tests
npm run test:e2e

# Test Coverage
npm run test:cov
```

### Flutter Tests

```bash
cd hivork-app

# Widget Tests
flutter test

# Integration Tests
flutter test integration_test/
```

### Angular Tests

```bash
cd hivork-admin

# Unit Tests
npm run test

# E2E Tests
npm run e2e
```

---

## 📦 Build برای Production

### Backend

```bash
cd hivork-backend
npm run build
npm run start:prod
```

### Flutter App

```bash
cd hivork-app

# Android
flutter build apk --release
# یا
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Admin Panel

```bash
cd hivork-admin
npm run build:prod
```

---

## 🐳 Docker Commands

```bash
# راه‌اندازی همه services
docker-compose up -d

# دیدن لاگ‌ها
docker-compose logs -f

# دیدن لاگ یک service خاص
docker-compose logs -f postgres

# خاموش کردن services
docker-compose down

# پاک کردن volumes (⚠️ دیتا پاک می‌شود)
docker-compose down -v

# Rebuild services
docker-compose up -d --build

# اجرای command در container
docker-compose exec postgres psql -U hivork -d hivork_db
```

---

## 📚 مستندات API

بعد از راه‌اندازی Backend، مستندات Swagger در دسترس است:

🔗 http://localhost:3000/api/docs

---

## 🗄️ Database Management

### PgAdmin

1. مراجعه به: http://localhost:5050
2. Login: `admin@hivork.com` / `admin123`
3. Add Server:
   - Name: Hivork Local
   - Host: postgres
   - Port: 5432
   - Username: hivork
   - Password: hivork_secret_pass_2024

### دستورات مفید PostgreSQL

```bash
# اتصال به database
docker-compose exec postgres psql -U hivork -d hivork_db

# Backup
docker-compose exec postgres pg_dump -U hivork hivork_db > backup.sql

# Restore
docker-compose exec -T postgres psql -U hivork -d hivork_db < backup.sql

# دیدن لیست tables
docker-compose exec postgres psql -U hivork -d hivork_db -c "\dt"
```

---

## 🔧 Troubleshooting

### مشکل: Docker container راه نمی‌افتد

```bash
# دیدن لاگ‌ها
docker-compose logs [service-name]

# Restart services
docker-compose restart

# پاک کردن و راه‌اندازی مجدد
docker-compose down
docker-compose up -d
```

### مشکل: Port قبلاً استفاده شده

```powershell
# پیدا کردن process
netstat -ano | findstr :5432

# Kill کردن process
taskkill /PID [process-id] /F
```

### مشکل: Migration اجرا نمی‌شود

```bash
# Revert آخرین migration
npm run migration:revert

# Generate migration جدید
npm run migration:generate -- src/database/migrations/YourMigrationName

# اجرای migrations
npm run migration:run
```

---

## 📖 مستندات بیشتر

- [📊 تحلیل کسب‌وکار](./01-BUSINESS-ANALYSIS.md)
- [🏗️ معماری Backend](./03-BACKEND-ARCHITECTURE.md)
- [📱 معماری Flutter App](./05-FLUTTER-APP-ARCHITECTURE.md)
- [🖥️ معماری Admin Dashboard](./06-ANGULAR-ADMIN-DASHBOARD.md)
- [📅 Timeline پروژه](./07-PROJECT-TIMELINE.md)

---

## 👥 تیم توسعه

- **Backend Developer**: [نام شما]
- **Flutter Developer**: [نام شما]
- **UI/UX Designer**: [نام شما]
---

## 📚 مستندات مهم پروژه

### راهنماهای تخصصی
- [📖 PRODUCT-VARIANTS-LOGIC.md](./PRODUCT-VARIANTS-LOGIC.md) - منطق کامل محصولات دارای تنوع و بدون تنوع
- [📋 IMPLEMENTATION-SUMMARY.md](./IMPLEMENTATION-SUMMARY.md) - خلاصه تغییرات اخیر
- [🔄 PRODUCT-VARIANTS-USER-GUIDE.md](./PRODUCT-VARIANTS-USER-GUIDE.md) - راهنمای کاربری تنوع محصولات
- [📊 PRODUCT-ATTRIBUTES-ANALYSIS.md](./PRODUCT-ATTRIBUTES-ANALYSIS.md) - تحلیل ویژگی‌های محصول

### API Contracts
- [🔌 Product API](./api-contracts/product-api.md) - قرارداد API محصولات
- [👥 Customer API](./api-contracts/customer-api.md) - قرارداد API مشتریان
- [🏢 Business API](./api-contracts/business-api.md) - قرارداد API کسب‌وکارها
- [🔐 Auth API](./api-contracts/auth-api.md) - قرارداد API احراز هویت

### Architecture & Design
- [🏗️ Backend Architecture](./03-BACKEND-ARCHITECTURE.md)
- [📱 Flutter App Architecture](./05-FLUTTER-APP-ARCHITECTURE.md)
- [🖥️ Angular Admin Dashboard](./06-ANGULAR-ADMIN-DASHBOARD.md)

---

## 🎯 ویژگی‌های کلیدی

### محصولات و موجودی 📦
- ✅ دو نوع محصول: دارای تنوع و بدون تنوع
- ✅ مدیریت ویژگی‌های سطح محصول و سطح تنوع
- ✅ تولید خودکار تنوع‌ها بر اساس ویژگی‌ها
- ✅ مدیریت هوشمند موجودی
- ✅ دسته‌بندی سلسله مراتبی محصولات

### مشتریان 👥
- ✅ مدیریت اطلاعات مشتریان
- ✅ گروه‌بندی مشتریان
- ✅ تاریخچه خرید و تراکنش‌ها
- ✅ تخفیف‌های اختصاصی

### فاکتورها و فروش 🧾
- ✅ صدور فاکتور سریع
- ✅ پشتیبانی از تخفیف و مالیات
- ✅ چاپ و ارسال فاکتور
- ✅ پیگیری وضعیت پرداخت

---

- **Product Manager**: [نام شما]

---

## 📄 License

این پروژه تحت لایسنس MIT منتشر شده است.

---

## 🤝 مشارکت

برای مشارکت در پروژه:

1. Fork کنید
2. Feature branch بسازید (`git checkout -b feature/AmazingFeature`)
3. Commit کنید (`git commit -m 'Add some AmazingFeature'`)
4. Push کنید (`git push origin feature/AmazingFeature`)
5. Pull Request باز کنید

---

## 📞 پشتیبانی

برای سوالات و پشتیبانی:

- 📧 Email: support@hivork.com
- 💬 Telegram: @hivork_support
- 🌐 Website: https://hivork.com

---

**ساخته شده با ❤️ توسط تیم Hivork**
