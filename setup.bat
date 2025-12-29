@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Document Tracking System - Setup Script
echo ========================================
echo.

:: Check if running as administrator (optional but recommended)
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo WARNING: Not running as administrator. Some operations may require admin rights.
    echo.
)

:: ========================================
:: Step 1: Check Prerequisites
:: ========================================
echo [1/8] Checking prerequisites...
echo.

set MISSING_DEPS=0

:: Check Node.js
where node >nul 2>&1
if %errorLevel% neq 0 (
    echo [X] Node.js is NOT installed or not in PATH
    echo     Please install Node.js from https://nodejs.org/
    set MISSING_DEPS=1
) else (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo [OK] Node.js found: !NODE_VERSION!
)

:: Check npm
where npm >nul 2>&1
if %errorLevel% neq 0 (
    echo [X] npm is NOT installed or not in PATH
    set MISSING_DEPS=1
) else (
    for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
    echo [OK] npm found: !NPM_VERSION!
)

:: Check PHP
where php >nul 2>&1
if %errorLevel% neq 0 (
    echo [X] PHP is NOT installed or not in PATH
    echo     Please install XAMPP and add PHP to PATH: C:\xampp\php
    set MISSING_DEPS=1
) else (
    for /f "tokens=*" %%i in ('php --version') do set PHP_VERSION=%%i
    echo [OK] PHP found: !PHP_VERSION!
)

:: Check Composer
where composer >nul 2>&1
if %errorLevel% neq 0 (
    echo [X] Composer is NOT installed or not in PATH
    echo     Please install Composer from https://getcomposer.org/
    set MISSING_DEPS=1
) else (
    for /f "tokens=*" %%i in ('composer --version') do set COMPOSER_VERSION=%%i
    echo [OK] Composer found: !COMPOSER_VERSION!
)

:: Check MySQL (via XAMPP)
if exist "C:\xampp\mysql\bin\mysql.exe" (
    echo [OK] MySQL found in XAMPP
) else (
    echo [WARNING] MySQL not found in default XAMPP location
    echo           Please ensure XAMPP MySQL is installed
)

if %MISSING_DEPS%==1 (
    echo.
    echo ERROR: Missing required dependencies. Please install them and run this script again.
    pause
    exit /b 1
)

echo.
echo All prerequisites found!
echo.

:: ========================================
:: Step 2: Install Node.js Dependencies
:: ========================================
echo [2/8] Installing Node.js dependencies...
echo.
call npm install
if %errorLevel% neq 0 (
    echo ERROR: Failed to install Node.js dependencies
    pause
    exit /b 1
)
echo [OK] Node.js dependencies installed
echo.

:: ========================================
:: Step 3: Install PHP Dependencies
:: ========================================
echo [3/8] Installing PHP dependencies (Composer)...
echo.
if exist "composer.json" (
    call composer install --no-interaction
    if %errorLevel% neq 0 (
        echo WARNING: Composer install failed. Continuing anyway...
    ) else (
        echo [OK] PHP dependencies installed
    )
) else (
    echo [SKIP] composer.json not found, skipping PHP dependencies
)
echo.

:: ========================================
:: Step 4: Create Required Directories
:: ========================================
echo [4/8] Creating required directories...
echo.

if not exist "uploads" mkdir uploads
if not exist "uploads\documents" mkdir uploads\documents
if not exist "backups" mkdir backups

echo [OK] Directories created
echo.

:: ========================================
:: Step 5: Create .env File
:: ========================================
echo [5/8] Setting up environment configuration...
echo.

if not exist ".env" (
    if exist "env.template" (
        echo Creating .env file from env.template...
        copy /Y "env.template" ".env" >nul
        echo [OK] .env file created
        echo     Please set JWT_SECRET_KEY and SMTP_* values in .env before using Forgot Password OTP.
    ) else (
        echo Creating .env file...
        (
            echo # Database Configuration
            echo DB_HOST=localhost
            echo DB_NAME=document_tracking
            echo DB_USERNAME=root
            echo DB_PASSWORD=
            echo.
            echo # JWT Secret Key - CHANGE THIS IN PRODUCTION!
            echo JWT_SECRET_KEY=document-tracking-secret-key-change-in-production-!RANDOM!%RANDOM%
            echo.
            echo # Application Settings
            echo APP_URL=http://localhost/document-tracking
            echo.
            echo # App Name
            echo APP_NAME=Document Progress Tracking System
            echo.
            echo # Email / SMTP (PHPMailer)
            echo SMTP_HOST=
            echo SMTP_PORT=587
            echo SMTP_SECURE=tls
            echo SMTP_USER=
            echo SMTP_PASS=
            echo SMTP_FROM_EMAIL=
            echo SMTP_FROM_NAME=Document Progress Tracking System
        ) > .env
        echo [OK] .env file created
        echo     WARNING: Please change JWT_SECRET_KEY and set SMTP_* in .env file.
    )
) else (
    echo [SKIP] .env file already exists
)
echo.

:: ========================================
:: Step 6: Database Setup
:: ========================================
echo [6/8] Database setup...
echo.
echo Please ensure XAMPP MySQL is running before proceeding.
echo.
set /p CREATE_DB="Do you want to create the database automatically? (Y/N): "
if /i "%CREATE_DB%"=="Y" (
    echo.
    echo Creating database...
    
    :: Try to create database
    if exist "C:\xampp\mysql\bin\mysql.exe" (
        "C:\xampp\mysql\bin\mysql.exe" -u root -e "CREATE DATABASE IF NOT EXISTS document_tracking;" 2>nul
        if %errorLevel% equ 0 (
            echo [OK] Database created or already exists
        ) else (
            echo [WARNING] Could not create database automatically
            echo           Please create it manually in phpMyAdmin
        )
    ) else (
        echo [WARNING] MySQL not found. Please create database manually.
    )
) else (
    echo [SKIP] Database creation skipped
    echo        Please create 'document_tracking' database manually
)
echo.

:: ========================================
:: Step 7: Import Database Schema
:: ========================================
echo [7/8] Database schema import...
echo.


:: ========================================
:: Step 8: Build Application
:: ========================================
echo [8/8] Building React application...
echo.
set /p BUILD_APP="Do you want to build the application now? (Y/N): "
if /i "%BUILD_APP%"=="Y" (
    call npm run build
    if %errorLevel% neq 0 (
        echo [WARNING] Build failed. You can build later with: npm run build
    ) else (
        echo [OK] Application built successfully
    )
) else (
    echo [SKIP] Build skipped
    echo        Build later with: npm run build
)
echo.

:: ========================================
:: Setup Complete
:: ========================================
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Next steps:
echo   1. Start XAMPP Control Panel
echo   2. Start Apache and MySQL services
echo   3. Import database schema in phpMyAdmin:
echo      - database/document_tracking.sql
echo      - database/migration_add_intermediate_column.sql
echo      - database/migration_add_department_head_role.sql
echo   4. Create default admin user (see SETUP_GUIDE.md)
echo   5. Run the application:
echo      - Development: npm start
echo      - Desktop App: npm run electron-dev
echo.
echo Default login credentials:
echo   Admin: admin@doctrack.com / admin123
echo.
echo IMPORTANT: Change default passwords after first login!
echo.
echo For detailed instructions, see SETUP_GUIDE.md
echo.
pause
