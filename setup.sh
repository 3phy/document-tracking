#!/bin/bash

echo "========================================"
echo "Document Tracking System - Setup Script"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ========================================
# Step 1: Check Prerequisites
# ========================================
echo "[1/8] Checking prerequisites..."
echo ""

MISSING_DEPS=0

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}[OK]${NC} Node.js found: $NODE_VERSION"
else
    echo -e "${RED}[X]${NC} Node.js is NOT installed"
    echo "    Please install Node.js from https://nodejs.org/"
    MISSING_DEPS=1
fi

# Check npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}[OK]${NC} npm found: $NPM_VERSION"
else
    echo -e "${RED}[X]${NC} npm is NOT installed"
    MISSING_DEPS=1
fi

# Check PHP
if command -v php &> /dev/null; then
    PHP_VERSION=$(php --version | head -n 1)
    echo -e "${GREEN}[OK]${NC} PHP found: $PHP_VERSION"
else
    echo -e "${RED}[X]${NC} PHP is NOT installed"
    echo "    Install: sudo apt install php php-mysql php-pdo php-json php-mbstring php-xml"
    MISSING_DEPS=1
fi

# Check Composer
if command -v composer &> /dev/null; then
    COMPOSER_VERSION=$(composer --version | head -n 1)
    echo -e "${GREEN}[OK]${NC} Composer found: $COMPOSER_VERSION"
else
    echo -e "${RED}[X]${NC} Composer is NOT installed"
    echo "    Please install Composer from https://getcomposer.org/"
    MISSING_DEPS=1
fi

# Check MySQL
if command -v mysql &> /dev/null; then
    echo -e "${GREEN}[OK]${NC} MySQL found"
else
    echo -e "${YELLOW}[WARNING]${NC} MySQL not found in PATH"
    echo "    Please ensure MySQL/MariaDB is installed and running"
fi

if [ $MISSING_DEPS -eq 1 ]; then
    echo ""
    echo -e "${RED}ERROR: Missing required dependencies. Please install them and run this script again.${NC}"
    exit 1
fi

echo ""
echo "All prerequisites found!"
echo ""

# ========================================
# Step 2: Install Node.js Dependencies
# ========================================
echo "[2/8] Installing Node.js dependencies..."
echo ""
npm install
if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Failed to install Node.js dependencies${NC}"
    exit 1
fi
echo -e "${GREEN}[OK]${NC} Node.js dependencies installed"
echo ""

# ========================================
# Step 3: Install PHP Dependencies
# ========================================
echo "[3/8] Installing PHP dependencies (Composer)..."
echo ""
if [ -f "composer.json" ]; then
    composer install --no-interaction
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}[WARNING]${NC} Composer install failed. Continuing anyway..."
    else
        echo -e "${GREEN}[OK]${NC} PHP dependencies installed"
    fi
else
    echo "[SKIP] composer.json not found, skipping PHP dependencies"
fi
echo ""

# ========================================
# Step 4: Create Required Directories
# ========================================
echo "[4/8] Creating required directories..."
echo ""

mkdir -p uploads/documents
mkdir -p backups

echo -e "${GREEN}[OK]${NC} Directories created"
echo ""

# ========================================
# Step 5: Create .env File
# ========================================
echo "[5/8] Setting up environment configuration..."
echo ""

if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cat > .env << EOF
# Database Configuration
DB_HOST=localhost
DB_NAME=document_tracking
DB_USERNAME=root
DB_PASSWORD=

# JWT Secret Key - CHANGE THIS IN PRODUCTION!
JWT_SECRET_KEY=document-tracking-secret-key-$(openssl rand -hex 32)

# Application Settings
APP_URL=http://localhost/document-tracking
EOF
    echo -e "${GREEN}[OK]${NC} .env file created"
    echo -e "${YELLOW}WARNING:${NC} Please change JWT_SECRET_KEY in .env file for security!"
else
    echo "[SKIP] .env file already exists"
fi
echo ""

# ========================================
# Step 6: Database Setup
# ========================================
echo "[6/8] Database setup..."
echo ""
echo "Please ensure MySQL is running before proceeding."
echo ""
read -p "Do you want to create the database automatically? (y/n): " CREATE_DB
if [[ $CREATE_DB =~ ^[Yy]$ ]]; then
    echo ""
    echo "Creating database..."
    mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS document_tracking;" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK]${NC} Database created or already exists"
    else
        echo -e "${YELLOW}[WARNING]${NC} Could not create database automatically"
        echo "           Please create it manually"
    fi
else
    echo "[SKIP] Database creation skipped"
    echo "       Please create 'document_tracking' database manually"
fi
echo ""

# ========================================
# Step 7: Import Database Schema
# ========================================
echo "[7/8] Database schema import..."
echo ""
read -p "Do you want to import the database schema? (y/n): " IMPORT_SCHEMA
if [[ $IMPORT_SCHEMA =~ ^[Yy]$ ]]; then
    echo ""
    echo "Importing database schema..."
    if [ -f "database/document_tracking.sql" ]; then
        mysql -u root -p document_tracking < database/document_tracking.sql 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[OK]${NC} Main schema imported"
            
            # Import migrations
            if [ -f "database/migration_add_intermediate_column.sql" ]; then
                mysql -u root -p document_tracking < database/migration_add_intermediate_column.sql 2>/dev/null
            fi
            if [ -f "database/migration_add_department_head_role.sql" ]; then
                mysql -u root -p document_tracking < database/migration_add_department_head_role.sql 2>/dev/null
            fi
            echo -e "${GREEN}[OK]${NC} Migrations imported"
        else
            echo -e "${YELLOW}[WARNING]${NC} Could not import schema automatically"
            echo "           Please import manually in phpMyAdmin or MySQL"
        fi
    else
        echo -e "${RED}[ERROR]${NC} database/document_tracking.sql not found"
    fi
else
    echo "[SKIP] Schema import skipped"
    echo "       Please import database schema manually"
fi
echo ""

# ========================================
# Step 8: Build Application
# ========================================
echo "[8/8] Building React application..."
echo ""
read -p "Do you want to build the application now? (y/n): " BUILD_APP
if [[ $BUILD_APP =~ ^[Yy]$ ]]; then
    npm run build
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}[WARNING]${NC} Build failed. You can build later with: npm run build"
    else
        echo -e "${GREEN}[OK]${NC} Application built successfully"
    fi
else
    echo "[SKIP] Build skipped"
    echo "       Build later with: npm run build"
fi
echo ""

# ========================================
# Setup Complete
# ========================================
echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Start Apache and MySQL services"
echo "  2. If database wasn't imported, import schema manually"
echo "  3. Create default admin user (see SETUP_GUIDE.md)"
echo "  4. Run the application:"
echo "     - Development: npm start"
echo "     - Desktop App: npm run electron-dev"
echo ""
echo "Default login credentials:"
echo "  Admin: admin@doctrack.com / admin123"
echo ""
echo "IMPORTANT: Change default passwords after first login!"
echo ""
echo "For detailed instructions, see SETUP_GUIDE.md"
echo ""

