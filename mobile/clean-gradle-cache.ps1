#!/usr/bin/env pwsh
# ==================================================
# 🧹 Clean All Gradle Caches Script
# ==================================================
# این اسکریپت تمام کش‌های Gradle را از ریشه پاک می‌کند
# استفاده: .\clean-gradle-cache.ps1
# ==================================================

Write-Host "🧹 Starting Gradle Cache Cleanup..." -ForegroundColor Cyan
Write-Host ""

# 1. Flutter Clean
Write-Host "1️⃣ Cleaning Flutter build..." -ForegroundColor Yellow
flutter clean
Write-Host "✅ Flutter build cleaned" -ForegroundColor Green
Write-Host ""

# 2. پاک کردن Global Gradle Caches
Write-Host "2️⃣ Cleaning Global Gradle caches..." -ForegroundColor Yellow
$gradleCaches = "$env:USERPROFILE\.gradle\caches"
if (Test-Path $gradleCaches) {
    Remove-Item -Path $gradleCaches -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Global Gradle caches deleted: $gradleCaches" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No global caches found" -ForegroundColor Gray
}
Write-Host ""

# 3. پاک کردن Gradle Wrapper
Write-Host "3️⃣ Cleaning Gradle wrapper..." -ForegroundColor Yellow
$gradleWrapper = "$env:USERPROFILE\.gradle\wrapper"
if (Test-Path $gradleWrapper) {
    Remove-Item -Path $gradleWrapper -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Gradle wrapper deleted: $gradleWrapper" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No wrapper cache found" -ForegroundColor Gray
}
Write-Host ""

# 4. پاک کردن Daemon Logs
Write-Host "4️⃣ Cleaning Gradle daemon..." -ForegroundColor Yellow
$gradleDaemon = "$env:USERPROFILE\.gradle\daemon"
if (Test-Path $gradleDaemon) {
    Remove-Item -Path $gradleDaemon -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Gradle daemon cleaned: $gradleDaemon" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No daemon files found" -ForegroundColor Gray
}
Write-Host ""

# 5. پاک کردن Native Build Cache
Write-Host "5️⃣ Cleaning native build cache..." -ForegroundColor Yellow
$gradleNative = "$env:USERPROFILE\.gradle\native"
if (Test-Path $gradleNative) {
    Remove-Item -Path $gradleNative -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Native cache deleted: $gradleNative" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No native cache found" -ForegroundColor Gray
}
Write-Host ""

# 6. پاک کردن Project-Level .gradle
Write-Host "6️⃣ Cleaning project .gradle..." -ForegroundColor Yellow
$projectGradle = ".\android\.gradle"
if (Test-Path $projectGradle) {
    Remove-Item -Path $projectGradle -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Project .gradle deleted: $projectGradle" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No project .gradle found" -ForegroundColor Gray
}
Write-Host ""

# 7. پاک کردن Android Build Folders
Write-Host "7️⃣ Cleaning Android build folders..." -ForegroundColor Yellow
$androidBuild = ".\android\build"
$appBuild = ".\android\app\build"

if (Test-Path $androidBuild) {
    Remove-Item -Path $androidBuild -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Android build deleted: $androidBuild" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No android/build found" -ForegroundColor Gray
}

if (Test-Path $appBuild) {
    Remove-Item -Path $appBuild -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ App build deleted: $appBuild" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No app/build found" -ForegroundColor Gray
}
Write-Host ""

# 8. پاک کردن Kotlin Build Cache
Write-Host "8️⃣ Cleaning Kotlin build cache..." -ForegroundColor Yellow
$kotlinCache = "$env:USERPROFILE\.kotlin"
if (Test-Path $kotlinCache) {
    Remove-Item -Path $kotlinCache -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Kotlin cache deleted: $kotlinCache" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No Kotlin cache found" -ForegroundColor Gray
}
Write-Host ""

# 9. پاک کردن Android Studio Cache (اختیاری)
Write-Host "9️⃣ Cleaning Android Studio caches..." -ForegroundColor Yellow
$androidStudioCache = "$env:USERPROFILE\.AndroidStudio*\system\caches"
$items = Get-Item -Path $androidStudioCache -ErrorAction SilentlyContinue
if ($items) {
    foreach ($item in $items) {
        Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Android Studio cache deleted: $($item.FullName)" -ForegroundColor Green
    }
} else {
    Write-Host "ℹ️  No Android Studio cache found" -ForegroundColor Gray
}
Write-Host ""

# 10. Flutter Pub Get
Write-Host "🔟 Running flutter pub get..." -ForegroundColor Yellow
flutter pub get
Write-Host "✅ Dependencies downloaded" -ForegroundColor Green
Write-Host ""

# نمایش خلاصه
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✨ Cleanup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Close Android Studio (if open)" -ForegroundColor White
Write-Host "   2. Run: flutter build apk --debug" -ForegroundColor White
Write-Host "   3. Or: flutter run" -ForegroundColor White
Write-Host ""
Write-Host "💡 Tip: For production build, use:" -ForegroundColor Cyan
Write-Host "   flutter build apk --release" -ForegroundColor White
Write-Host ""
