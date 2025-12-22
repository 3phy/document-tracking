# Quick Start Guide

## 🚀 Fastest Setup (Windows)

1. **Install Prerequisites** (if not already installed):
   - [Node.js](https://nodejs.org/) - Download and install LTS version
   - [XAMPP](https://www.apachefriends.org/) - Download and install
   - [Composer](https://getcomposer.org/) - Download and install

2. **Run Setup Script**:
   - Double-click `setup.bat`
   - Follow the on-screen prompts
   - Answer "Y" to all questions

3. **Start Services**:
   - Open XAMPP Control Panel
   - Start **Apache** and **MySQL**

4. **Import Database**:
   - Open phpMyAdmin (click "Admin" next to MySQL in XAMPP)
   - Create database: `document_tracking`
   - Import: `database/document_tracking.sql`
   - Import: `database/migration_add_intermediate_column.sql`
   - Import: `database/migration_add_department_head_role.sql`

5. **Run Application**:
   ```cmd
   npm start
   ```
   Open: http://localhost:3000

6. **Login**:
   - Email: `admin@doctrack.com`
   - Password: `admin123`

**That's it!** 🎉

---

## 📋 Manual Setup Checklist

If automated setup doesn't work:

- [ ] Node.js installed (`node --version`)
- [ ] npm installed (`npm --version`)
- [ ] PHP installed (`php --version`)
- [ ] Composer installed (`composer --version`)
- [ ] XAMPP installed and running
- [ ] Run `npm install`
- [ ] Run `composer install`
- [ ] Create `.env` file (copy from `env.template`)
- [ ] Create `uploads/documents` directory
- [ ] Create `backups` directory
- [ ] Create database `document_tracking`
- [ ] Import database schema
- [ ] Start Apache and MySQL
- [ ] Run `npm start`

---

## 🔧 Common Issues

**"npm not recognized"**
→ Restart Command Prompt after installing Node.js

**"Database connection failed"**
→ Check XAMPP MySQL is running and database exists

**"401 Unauthorized"**
→ Check `.env` file exists and JWT_SECRET_KEY is set

**"Port 3000 in use"**
→ Kill process: `netstat -ano | findstr :3000` then `taskkill /PID <PID> /F`

---

For detailed instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)

