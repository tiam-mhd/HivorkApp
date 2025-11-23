@echo off
REM ==================================================
REM 🧹 Quick Gradle Cache Clean (Windows)
REM ==================================================
echo.
echo 🧹 Cleaning All Gradle Caches...
echo.

REM Kill Gradle Daemons
echo 🛑 Stopping Gradle daemons...
taskkill /F /IM java.exe /FI "WINDOWTITLE eq gradle*" >nul 2>&1

REM Flutter Clean
echo 📦 Running flutter clean...
call flutter clean

REM Delete Global Gradle Caches
echo 🗑️  Deleting global Gradle caches...
if exist "%USERPROFILE%\.gradle\caches" (
    rmdir /s /q "%USERPROFILE%\.gradle\caches"
    echo ✅ Global caches deleted
)

if exist "%USERPROFILE%\.gradle\wrapper" (
    rmdir /s /q "%USERPROFILE%\.gradle\wrapper"
    echo ✅ Wrapper deleted
)

if exist "%USERPROFILE%\.gradle\daemon" (
    rmdir /s /q "%USERPROFILE%\.gradle\daemon"
    echo ✅ Daemon cleaned
)

if exist "%USERPROFILE%\.gradle\native" (
    rmdir /s /q "%USERPROFILE%\.gradle\native"
    echo ✅ Native cache deleted
)

REM Delete Project Gradle Files
echo 🗑️  Deleting project Gradle files...
if exist "android\.gradle" (
    rmdir /s /q "android\.gradle"
    echo ✅ Project .gradle deleted
)

if exist "android\build" (
    rmdir /s /q "android\build"
    echo ✅ Android build deleted
)

if exist "android\app\build" (
    rmdir /s /q "android\app\build"
    echo ✅ App build deleted
)

REM Delete Kotlin Cache
if exist "%USERPROFILE%\.kotlin" (
    rmdir /s /q "%USERPROFILE%\.kotlin"
    echo ✅ Kotlin cache deleted
)

REM Flutter Pub Get
echo.
echo 📥 Running flutter pub get...
call flutter pub get

echo.
echo ========================================
echo ✨ Cleanup Complete!
echo ========================================
echo.
echo 💡 Next: flutter run or flutter build apk
echo.
pause
