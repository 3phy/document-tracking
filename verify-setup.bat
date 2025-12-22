@echo off
echo ========================================
echo Document Tracking System - Setup Verification
echo ========================================
echo.

set ERRORS=0
set WARNINGS=0

:: Check Node.js
echo [1/12] Checking Node.js...
where node >nul 2>&1
if %errorLevel% neq 0 (
    echo [X] Node.js is NOT installed or not in PATH
    set /a ERRORS+=1
) else (
    for /f "tokens=*" %%i in ('node --version') do echo [OK] Node.js: %%i
)
echo.

:: Check npm
echo [2/12] Checking npm...
where npm >nul 2>&1
if %errorLevel% neq 0 (
    echo [X] npm is NOT installed or not in PATH
    set /a ERRORS+=1
) else (
    for /f "tokens=*" %%i in ('npm --version') do echo [OK] npm: %%i
)
echo.

:: Check PHP
echo [3/12] Checking PHP...
where php >nul 2>&1
if %errorLevel% neq 0 (
    echo [X] PHP is NOT installed or not in PATH
    set /a ERRORS+=1
) else (
    for /f "tokens=*" %%i in ('php --version') do (
        echo [OK] PHP: %%i
        goto :php_found
    )
    :php_found
)
echo.

:: Check Composer
echo [4/12] Checking Composer...
where composer >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Composer is NOT installed or not in PATH
    set /a WARNINGS+=1
) else (
    for /f "tokens=*" %%i in ('composer --version') do echo [OK] Composer: %%i
)
echo.

:: Check MySQL
echo [5/12] Checking MySQL...
if exist "C:\xampp\mysql\bin\mysql.exe" (
    echo [OK] MySQL found in XAMPP
) else (
    echo [!] MySQL not found in default XAMPP location
    set /a WARNINGS+=1
)
echo.

:: Check node_modules
echo [6/12] Checking Node.js dependencies...
if exist "node_modules" (
    echo [OK] node_modules directory exists
) else (
    echo [X] node_modules directory NOT found. Run: npm install
    set /a ERRORS+=1
)
echo.

:: Check vendor (PHP dependencies)
echo [7/12] Checking PHP dependencies...
if exist "vendor" (
    echo [OK] vendor directory exists
) else (
    echo [!] vendor directory NOT found. Run: composer install
    set /a WARNINGS+=1
)
echo.

:: Check .env file
echo [8/12] Checking .env file...
if exist ".env" (
    echo [OK] .env file exists
    findstr /C:"JWT_SECRET_KEY" .env >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] JWT_SECRET_KEY is configured
    ) else (
        echo [!] JWT_SECRET_KEY not found in .env
        set /a WARNINGS+=1
    )
) else (
    echo [X] .env file NOT found. Create it from env.template
    set /a ERRORS+=1
)
echo.

:: Check directories
echo [9/12] Checking required directories...
if exist "uploads\documents" (
    echo [OK] uploads\documents exists
) else (
    echo [X] uploads\documents NOT found. Create it manually
    set /a ERRORS+=1
)

if exist "backups" (
    echo [OK] backups directory exists
) else (
    echo [!] backups directory NOT found. Will be created automatically
    set /a WARNINGS+=1
)
echo.

:: Check database files
echo [10/12] Checking database schema files...
if exist "database\document_tracking.sql" (
    echo [OK] Main database schema found
) else (
    echo [!] database\document_tracking.sql NOT found
    set /a WARNINGS+=1
)
echo.

:: Check API endpoint
echo [11/12] Checking API accessibility...
echo This will test if the API is accessible...
curl -s http://localhost/document-tracking/api/auth/login.php >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] API endpoint is accessible
) else (
    echo [!] API endpoint not accessible. Make sure Apache is running
    set /a WARNINGS+=1
)
echo.

:: Check XAMPP services
echo [12/12] Checking XAMPP services...
echo Please verify manually:
echo   - Apache is running in XAMPP Control Panel
echo   - MySQL is running in XAMPP Control Panel
echo.

:: Summary
echo ========================================
echo Verification Summary
echo ========================================
echo.
if %ERRORS% equ 0 (
    echo [OK] No critical errors found
) else (
    echo [X] Found %ERRORS% critical error(s)
)
if %WARNINGS% gtr 0 (
    echo [!] Found %WARNINGS% warning(s)
)
echo.

if %ERRORS% gtr 0 (
    echo Please fix the errors above before running the application.
) else (
    echo Setup looks good! You can now run the application.
    echo   Development: npm start
    echo   Desktop App: npm run electron-dev
)
echo.
pause

