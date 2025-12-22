# Document Tracking System - Complete Setup Guide

## 📋 Table of Contents
1. [System Requirements](#system-requirements)
2. [Prerequisites Installation](#prerequisites-installation)
3. [Automated Setup (Recommended)](#automated-setup-recommended)
4. [Manual Setup](#manual-setup)
5. [Configuration](#configuration)
6. [Database Setup](#database-setup)
7. [Running the Application](#running-the-application)
8. [Troubleshooting](#troubleshooting)

---

## 🖥️ System Requirements

### Minimum Requirements
- **OS**: Windows 10/11, macOS 10.14+, or Linux (Ubuntu 18.04+)
- **RAM**: 4GB minimum (8GB recommended)
- **Storage**: 2GB free space
- **Processor**: Dual-core 2.0 GHz or higher

### Required Software
1. **Node.js** (v16.0.0 or higher) - [Download](https://nodejs.org/)
2. **XAMPP** (for Windows) or **LAMP/MAMP** (for Linux/Mac) - [Download XAMPP](https://www.apachefriends.org/)
3. **Composer** (PHP dependency manager) - [Download](https://getcomposer.org/)
4. **Git** (optional, for cloning repository) - [Download](https://git-scm.com/)

---

## 📦 Prerequisites Installation

### 1. Install Node.js
1. Download Node.js LTS version from https://nodejs.org/
2. Run the installer and follow the setup wizard
3. **Important**: Check "Add to PATH" during installation
4. Verify installation:
   ```cmd
   node --version
   npm --version
   ```
   You should see version numbers (e.g., v18.17.0 and 9.6.7)

### 2. Install XAMPP (Windows) or LAMP/MAMP (Linux/Mac)

#### Windows (XAMPP):
1. Download XAMPP from https://www.apachefriends.org/
2. Install to default location: `C:\xampp\`
3. **Important**: During installation, uncheck any antivirus warnings
4. Start XAMPP Control Panel
5. Start **Apache** and **MySQL** services

#### Linux:
```bash
sudo apt update
sudo apt install apache2 mysql-server php php-mysql php-pdo php-json php-mbstring php-xml
```

#### macOS (MAMP):
1. Download MAMP from https://www.mamp.info/
2. Install and start Apache and MySQL services

### 3. Install Composer (PHP Dependency Manager)
1. Download Composer from https://getcomposer.org/download/
2. For Windows: Download and run `Composer-Setup.exe`
3. For Linux/Mac: Follow installation instructions on the website
4. Verify installation:
   ```cmd
   composer --version
   ```

### 4. Verify PHP Installation
1. Open Command Prompt/Terminal
2. Check PHP version:
   ```cmd
   php --version
   ```
   Should be PHP 7.4 or higher (PHP 8.0+ recommended)

---

## 🚀 Automated Setup (Recommended)

### Windows Users:
1. **Double-click `setup.bat`** in the project root directory
2. The script will automatically:
   - Check for Node.js, PHP, and Composer
   - Install Node.js dependencies
   - Install PHP dependencies via Composer
   - Create necessary directories
   - Generate `.env` file
   - Create database
   - Import database schema
   - Set up default admin user

3. Follow the on-screen prompts
4. When complete, start XAMPP (Apache and MySQL)
5. Run the application using `npm start` or `npm run electron-dev`

### Linux/Mac Users:
```bash
chmod +x setup.sh
./setup.sh
```

---

## 🔧 Manual Setup

If automated setup doesn't work, follow these steps:

### Step 1: Install Node.js Dependencies
```cmd
cd C:\xampp\htdocs\document-tracking
npm install
```

### Step 2: Install PHP Dependencies
```cmd
composer install
```

### Step 3: Create Required Directories
```cmd
mkdir uploads\documents
mkdir backups
```

### Step 4: Create Environment File
Create a file named `.env` in the project root with the following content:
```env
# Database Configuration
DB_HOST=localhost
DB_NAME=document_tracking
DB_USERNAME=root
DB_PASSWORD=

# JWT Secret Key (Generate a random string)
JWT_SECRET_KEY=your-super-secret-jwt-key-change-this-in-production

# Application Settings
APP_URL=http://localhost/document-tracking
```

**Important**: Change `JWT_SECRET_KEY` to a random string for security!

### Step 5: Database Setup

#### Option A: Using phpMyAdmin (Recommended)
1. Open XAMPP Control Panel
2. Click "Admin" next to MySQL to open phpMyAdmin
3. Click "New" to create a database
4. Name it: `document_tracking`
5. Click "Create"
6. Select the `document_tracking` database
7. Go to "Import" tab
8. Click "Choose File" and select: `database/document_tracking.sql`
9. Click "Go" to import

#### Option B: Using Command Line
```cmd
mysql -u root -p
CREATE DATABASE document_tracking;
USE document_tracking;
SOURCE database/document_tracking.sql;
EXIT;
```

### Step 6: Run Database Migrations
After importing the main schema, run these migrations in order:
1. `database/migration_add_intermediate_column.sql`
2. `database/migration_add_department_head_role.sql`

### Step 7: Create Default Admin User
Run this SQL in phpMyAdmin or MySQL command line:
```sql
INSERT INTO users (name, email, password, role, is_active, created_at) 
VALUES (
    'Administrator', 
    'admin@doctrack.com', 
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
    'admin', 
    1, 
    NOW()
);
```
**Default Password**: `admin123`

---

## ⚙️ Configuration

### API Configuration
Edit `src/config/api.js` if your project is not in the default XAMPP location:
```javascript
const API_BASE_URL = 'http://localhost/document-tracking/api';
```

### Database Configuration
If your database credentials differ, update `api/config/database.php` or use the `.env` file.

### File Upload Settings
- Default upload directory: `uploads/documents/`
- Maximum file size: Configured in PHP `php.ini` (default: 2MB)
- To increase: Edit `C:\xampp\php\php.ini`:
  ```ini
  upload_max_filesize = 10M
  post_max_size = 10M
  ```

---

## 🗄️ Database Setup Details

### Required Tables
The system requires these tables:
- `users` - User accounts (admin, staff, department_head)
- `departments` - Department information
- `documents` - Document records
- `document_forwarding_history` - Document routing history
- `user_activities` - Activity logs (optional)

### Default Users
After setup, you can login with:
- **Admin**: `admin@doctrack.com` / `admin123`
- **Staff**: `staff@doctrack.com` / `staff123` (create via admin panel)

### Database Roles
- **admin**: Full system access
- **staff**: Basic document operations
- **department_head**: Department management and reports

---

## 🏃 Running the Application

### Development Mode (Recommended for development)
```cmd
npm start
```
Then open: `http://localhost:3000`

### Production Mode
```cmd
npm run build
npm start
```

### Desktop App (Electron)
```cmd
npm run electron-dev
```

---

## 🔍 Verification Checklist

After setup, verify everything works:

- [ ] Node.js is installed (`node --version`)
- [ ] npm is installed (`npm --version`)
- [ ] PHP is installed (`php --version`)
- [ ] Composer is installed (`composer --version`)
- [ ] XAMPP Apache is running
- [ ] XAMPP MySQL is running
- [ ] Database `document_tracking` exists
- [ ] Database schema is imported
- [ ] `.env` file exists in project root
- [ ] `node_modules` folder exists
- [ ] `vendor` folder exists (PHP dependencies)
- [ ] `uploads/documents` directory exists
- [ ] `backups` directory exists
- [ ] Can access `http://localhost/document-tracking/api/auth/login.php`

---

## 🐛 Troubleshooting

### Issue: "npm is not recognized"
**Solution**: 
1. Restart Command Prompt after installing Node.js
2. Or manually add Node.js to PATH:
   - Right-click "This PC" → Properties → Advanced System Settings
   - Click "Environment Variables"
   - Under "System Variables", find "Path" and click "Edit"
   - Add: `C:\Program Files\nodejs\`

### Issue: "Composer is not recognized"
**Solution**:
1. Restart Command Prompt after installing Composer
2. Or add Composer to PATH manually

### Issue: "Database connection failed"
**Solutions**:
1. Ensure XAMPP MySQL is running
2. Check database credentials in `.env` file
3. Verify database `document_tracking` exists
4. Test connection:
   ```cmd
   mysql -u root -p
   SHOW DATABASES;
   ```

### Issue: "401 Unauthorized" errors
**Solutions**:
1. Ensure XAMPP Apache is running
2. Verify project is in `C:\xampp\htdocs\document-tracking\`
3. Check `.env` file exists and has correct JWT_SECRET_KEY
4. Clear browser cache and cookies
5. Try logging in again

### Issue: "Failed to create database backup"
**Solutions**:
1. Ensure `mysqldump` is accessible
2. For XAMPP, it's usually at: `C:\xampp\mysql\bin\mysqldump.exe`
3. Add MySQL bin directory to PATH if needed
4. Check that `backups` directory exists and is writable

### Issue: "File upload failed"
**Solutions**:
1. Check `uploads/documents` directory exists
2. Verify directory permissions (should be writable)
3. Check PHP `upload_max_filesize` and `post_max_size` settings
4. Ensure Apache has write permissions to uploads folder

### Issue: "Port 3000 already in use"
**Solution**:
```cmd
# Find and kill process using port 3000
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### Issue: "CORS errors"
**Solution**:
1. Ensure API is accessible at `http://localhost/document-tracking/api/`
2. Check `api/config/cors.php` is properly configured
3. Verify Apache mod_rewrite is enabled

### Issue: "Module not found" errors
**Solution**:
```cmd
# Reinstall dependencies
rm -rf node_modules
npm install
```

---

## 📁 Project Structure

```
document-tracking/
├── api/                      # PHP Backend
│   ├── admin/               # Admin endpoints
│   ├── auth/                # Authentication
│   ├── config/              # Configuration files
│   ├── dashboard/           # Dashboard stats
│   ├── departments/         # Department management
│   ├── documents/           # Document operations
│   ├── reports/             # Reports and analytics
│   ├── staff/               # Staff management
│   └── user/                # User profile
├── backups/                 # Database backups
├── database/                # Database schemas and migrations
├── public/                  # Public assets
├── src/                     # React Frontend
│   ├── components/          # React components
│   ├── contexts/            # React contexts
│   ├── pages/               # Page components
│   └── config/              # Frontend config
├── uploads/                 # Uploaded documents
│   └── documents/           # Document files
├── vendor/                  # PHP dependencies (Composer)
├── node_modules/           # Node.js dependencies
├── .env                     # Environment variables (create this)
├── composer.json           # PHP dependencies
├── package.json            # Node.js dependencies
├── setup.bat              # Automated setup script (Windows)
└── SETUP_GUIDE.md         # This file
```

---

## 🔐 Security Notes

1. **Change Default Passwords**: Immediately change default admin password after first login
2. **JWT Secret Key**: Use a strong, random JWT secret key in production
3. **Database Password**: Don't use empty password in production
4. **File Permissions**: Restrict write permissions on uploads directory
5. **HTTPS**: Use HTTPS in production environments
6. **Environment Variables**: Never commit `.env` file to version control

---

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Verify all prerequisites are installed correctly
3. Check error logs:
   - PHP errors: `C:\xampp\apache\logs\error.log`
   - MySQL errors: `C:\xampp\mysql\data\mysql_error.log`
4. Run verification: Check that all checklist items are completed

---

## 🎉 Next Steps

After successful setup:
1. Login with admin credentials
2. Create departments
3. Add staff members
4. Start uploading and tracking documents!

**Happy Document Tracking! 📄✨**

