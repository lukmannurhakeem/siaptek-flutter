# Save this file as: C:\Users\User\flutter\base_app\build_and_deploy.ps1
# Then run: .\build_and_deploy.ps1

# Configuration
$FLUTTER_PROJECT = "C:\Users\User\flutter\base_app"
$LANDING_PAGE_REPO = "C:\Users\User\flutter\PWA_LANDING"
$APP_FOLDER = "web"
$BASE_HREF = "/pwa_landing/web/"

# Navigate to Flutter project
Write-Host "📂 Navigating to Flutter project..." -ForegroundColor Blue
Set-Location $FLUTTER_PROJECT

Write-Host "🚀 Starting Flutter PWA build and deploy..." -ForegroundColor Blue
Write-Host "Flutter Project: $FLUTTER_PROJECT" -ForegroundColor Cyan
Write-Host "Landing Page: $LANDING_PAGE_REPO" -ForegroundColor Cyan
Write-Host "Deploy to: $LANDING_PAGE_REPO\$APP_FOLDER`n" -ForegroundColor Cyan

# Step 1: Clean previous build
Write-Host "[1/7] Cleaning previous build..." -ForegroundColor Blue
fvm flutter clean

# Step 2: Get dependencies
Write-Host "`n[2/7] Getting dependencies..." -ForegroundColor Blue
fvm flutter pub get

# Step 3: Build Flutter web
Write-Host "`n[3/7] Building Flutter web..." -ForegroundColor Blue
fvm flutter build web --release --base-href $BASE_HREF

if ($LASTEXITCODE -ne 0)
{
    Write-Host "`n[ERROR] Build failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 4: Check if landing page repo exists
if (-not (Test-Path $LANDING_PAGE_REPO))
{
    Write-Host "`n[ERROR] Landing page repo not found at: $LANDING_PAGE_REPO" -ForegroundColor Red
    Write-Host "Please check the path and update the script" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 5: Create app folder if it doesn't exist
Write-Host "`n[4/7] Preparing destination folder..." -ForegroundColor Blue
$APP_PATH = Join-Path $LANDING_PAGE_REPO $APP_FOLDER
New-Item -ItemType Directory -Force -Path $APP_PATH | Out-Null

# Step 6: Remove old app files
Write-Host "[5/7] Removing old files..." -ForegroundColor Blue
Get-ChildItem -Path $APP_PATH -Exclude ".gitkeep" | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

# Step 7: Copy new build
Write-Host "[6/7] Copying build files..." -ForegroundColor Blue
$BUILD_PATH = "build\web\*"
Copy-Item -Path $BUILD_PATH -Destination $APP_PATH -Recurse -Force

Write-Host "`n[SUCCESS] Build copied successfully!" -ForegroundColor Green
Write-Host "Location: $APP_PATH" -ForegroundColor Cyan

Write-Host "`n[COMPLETE] Your Flutter PWA is ready!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Blue
Write-Host "  1. cd `"$LANDING_PAGE_REPO`"" -ForegroundColor White
Write-Host "  2. git status" -ForegroundColor White
Write-Host "  3. git add $APP_FOLDER" -ForegroundColor White
Write-Host "  4. git commit -m `"Update Flutter PWA`"" -ForegroundColor White
Write-Host "  5. git push origin main" -ForegroundColor White
Write-Host "`n🌐 After push, your app will be at:" -ForegroundColor Blue
Write-Host "   https://lukmannurhakeem.github.io/pwa_landing/web/" -ForegroundColor Cyan

Read-Host "`nPress Enter to close"