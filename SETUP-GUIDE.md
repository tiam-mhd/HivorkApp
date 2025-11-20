# Hivork Project Setup Guide
# راهنمای راه‌اندازی پروژه Hivork

## مرحله 1: نصب Docker Desktop

1. دانلود از: https://www.docker.com/products/docker-desktop/
2. نصب و راه‌اندازی Docker Desktop
3. تایید نصب:
   ```powershell
   docker --version
   docker-compose --version
   ```

## مرحله 2: راه‌اندازی Services

```powershell
# در پوشه اصلی پروژه
cd D:\Tiam\Projects\Hivork

# کپی فایل environment
Copy-Item .env.example .env

# ویرایش .env (رمزهای پیشفرض رو تغییر بدید)
notepad .env

# راه‌اندازی PostgreSQL و Redis
docker-compose up -d

# چک کردن وضعیت
docker-compose ps
```

خروجی باید شبیه این باشه:
```
NAME                    STATUS    PORTS
hivork-postgres         Up        0.0.0.0:5432->5432/tcp
hivork-redis            Up        0.0.0.0:6379->6379/tcp
hivork-pgadmin          Up        0.0.0.0:5050->80/tcp
hivork-redis-commander  Up        0.0.0.0:8081->8081/tcp
```

## مرحله 3: ساخت Backend Project

```powershell
# نصب NestJS CLI
npm install -g @nestjs/cli

# ساخت پروژه Backend
nest new hivork-backend

# وارد پوشه پروژه شوید
cd hivork-backend

# نصب dependencies مورد نیاز
npm install @nestjs/typeorm typeorm pg
npm install @nestjs/jwt @nestjs/passport passport passport-jwt
npm install @nestjs/config
npm install bcrypt
npm install class-validator class-transformer
npm install --save-dev @types/bcrypt @types/passport-jwt

# اجرای Backend
npm run start:dev
```

## مرحله 4: ساخت Flutter App

```powershell
# بازگشت به پوشه اصلی
cd ..

# ساخت پروژه Flutter
flutter create hivork-app

cd hivork-app

# نصب packages اصلی
flutter pub add riverpod flutter_riverpod
flutter pub add go_router
flutter pub add dio
flutter pub add hive flutter_secure_storage
flutter pub add freezed_annotation json_annotation
flutter pub add --dev build_runner freezed json_serializable

# اجرای app
flutter run
```

## مرحله 5: ساخت Admin Dashboard

```powershell
# بازگشت به پوشه اصلی
cd ..

# نصب Angular CLI
npm install -g @angular/cli@17

# ساخت پروژه Angular
ng new hivork-admin --routing --style=scss --standalone=false

cd hivork-admin

# نصب packages
npm install @ngrx/store @ngrx/effects @ngrx/entity @ngrx/store-devtools
npm install @angular/material
npm install tailwindcss postcss autoprefixer
npx tailwindcss init

# اجرای Admin Panel
npm start
```

## مرحله 6: تست اتصالات

### 1. PostgreSQL
```powershell
# اتصال به PostgreSQL
docker-compose exec postgres psql -U hivork -d hivork_db

# تست query
SELECT version();

# خروج
\q
```

### 2. Redis
```powershell
# اتصال به Redis
docker-compose exec redis redis-cli -a hivork_redis_pass_2024

# تست
PING
# باید PONG برگردونه

# خروج
EXIT
```

### 3. PgAdmin
مراجعه به: http://localhost:5050
- Email: admin@hivork.com
- Password: admin123

### 4. Redis Commander
مراجعه به: http://localhost:8081

## مرحله 7: ساخت Git Repository

```powershell
# بازگشت به پوشه اصلی
cd D:\Tiam\Projects\Hivork

# Initialize Git
git init

# Add all files
git add .

# اولین commit
git commit -m "Initial commit: Hivork project structure with Docker setup"

# اضافه کردن remote (بعد از ساخت repo در GitHub)
git remote add origin https://github.com/your-username/hivork.git

# Push
git branch -M main
git push -u origin main
```

## دستورات مفید

### Docker Commands
```powershell
# دیدن لاگ‌ها
docker-compose logs -f

# Restart services
docker-compose restart

# Stop services
docker-compose down

# Remove volumes (⚠️ data will be deleted)
docker-compose down -v

# Rebuild images
docker-compose build --no-cache
docker-compose up -d
```

### Backend Commands
```powershell
cd hivork-backend

# Development mode
npm run start:dev

# Build
npm run build

# Production mode
npm run start:prod

# Tests
npm run test
npm run test:e2e
npm run test:cov

# Generate module
nest g module modules/products
nest g controller modules/products
nest g service modules/products
```

### Flutter Commands
```powershell
cd hivork-app

# Run on Chrome
flutter run -d chrome

# Build APK
flutter build apk --release

# Build for iOS
flutter build ios --release

# Tests
flutter test

# Code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Clean
flutter clean
flutter pub get
```

### Angular Commands
```powershell
cd hivork-admin

# Development server
ng serve
# یا
npm start

# Build for production
ng build --configuration production

# Generate component
ng generate component components/dashboard

# Generate service
ng generate service services/auth

# Tests
ng test

# Lint
ng lint
```

## Checklist نصب موفق ✅

- [ ] Docker Desktop نصب و اجرا شده
- [ ] PostgreSQL container در حال اجرا است (port 5432)
- [ ] Redis container در حال اجرا است (port 6379)
- [ ] PgAdmin در مرورگر باز می‌شود (port 5050)
- [ ] Backend project ساخته شده و اجرا می‌شود (port 3000)
- [ ] Flutter project ساخته شده و اجرا می‌شود
- [ ] Admin project ساخته شده و اجرا می‌شود (port 4200)
- [ ] Git repository initialize شده
- [ ] فایل .env از .env.example کپی شده

## مشکلات رایج و راه‌حل

### Docker not starting
```powershell
# Enable Hyper-V in Windows
# PowerShell as Administrator:
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

### Port already in use
```powershell
# Find process using port
netstat -ano | findstr :5432

# Kill process
taskkill /PID [process-id] /F
```

### npm install errors
```powershell
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
Remove-Item -Recurse -Force node_modules
Remove-Item package-lock.json
npm install
```

## گام بعدی

بعد از تکمیل این مراحل، آماده‌اید که شروع کنید به:
1. پیاده‌سازی database schema در Backend
2. ساخت API endpoints
3. پیاده‌سازی UI در Flutter و Angular
4. تست و debug

برای جزئیات هر بخش، به فایل‌های زیر مراجعه کنید:
- Backend: `03-BACKEND-ARCHITECTURE.md`
- API: `04-API-DOCUMENTATION.md`
- Flutter: `05-FLUTTER-APP-ARCHITECTURE.md`
- Admin: `06-ANGULAR-ADMIN-DASHBOARD.md`
- Timeline: `07-PROJECT-TIMELINE.md`
