# Document Tracking System

A comprehensive document tracking system built with Electron, React, and PHP. This application allows users to upload documents, generate unique barcodes, and track document status through scanning.

## Features

### User Roles
- **Admin**: Manage staff accounts, view all documents, generate reports
- **Staff**: Upload documents, scan barcodes to mark as received

### Core Functionality
- Document upload with automatic barcode generation
- Barcode scanning for status updates
- Real-time dashboard with statistics
- Role-based access control
- Document status tracking (Outgoing, Pending, Received)
- Staff management (Admin only)
- Report generation and export (Admin only)

## Technology Stack

- **Frontend**: Electron + React + Material-UI
- **Backend**: PHP + MySQL
- **Database**: MySQL (via XAMPP)
- **Barcode**: JsBarcode library
- **Authentication**: JWT tokens

## Prerequisites

- XAMPP (Apache + MySQL + PHP)
- Node.js (v14 or higher)
- npm or yarn

## Installation

### 1. Database Setup

1. Start XAMPP and ensure Apache and MySQL are running
2. Open phpMyAdmin (http://localhost/phpmyadmin)
3. Import the database schema:
   ```sql
   -- Run the contents of database/schema.sql
   ```

### 2. Backend Setup

1. Place the project in your XAMPP htdocs directory:
   ```
   C:\xampp\htdocs\document-tracking\
   ```

2. Create a `.env` file in the project root (copy from `.env.example` if available):
   ```env
   # Database Configuration
   DB_HOST=localhost
   DB_NAME=document_tracking
   DB_USERNAME=root
   DB_PASSWORD=

   # JWT Secret Key (CHANGE THIS IN PRODUCTION!)
   JWT_SECRET_KEY=your-secret-key-here-change-this-in-production

   # API Configuration
   API_BASE_URL=http://localhost/document-tracking/api

   # CORS Allowed Origins (comma-separated)
   CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost

   # Application Environment
   APP_ENV=development
   ```

   **Important**: The `.env` file is gitignored. Never commit sensitive credentials to version control.

3. If you prefer not to use `.env`, the system will use default values, but this is **not recommended for production**.

### 3. Frontend Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Install additional dependencies for development:
   ```bash
   npm install --save-dev electron-is-dev
   ```

3. Build the React application:
   ```bash
   npm run build
   ```

### 4. Running the Application

#### Development Mode
```bash
npm run electron-dev
```

#### Production Mode
```bash
npm run electron
```

## Default Login Credentials

- **Admin**: admin@doctrack.com / password123
- **Staff**: staff@doctrack.com / password123

## API Endpoints

### Authentication
- `POST /api/auth/login.php` - User login
- `GET /api/auth/verify.php` - Verify JWT token

### Documents
- `POST /api/documents/upload.php` - Upload document
- `GET /api/documents/list.php` - List documents
- `POST /api/documents/scan.php` - Scan barcode

### Dashboard
- `GET /api/dashboard/stats.php` - Get dashboard statistics

### Staff Management (Admin only)
- `GET /api/staff/list.php` - List staff members
- `POST /api/staff/create.php` - Create staff member
- `PUT /api/staff/update.php` - Update staff member
- `DELETE /api/staff/delete.php` - Delete staff member
- `PUT /api/staff/toggle.php` - Toggle staff status

### Reports (Admin only)
- `GET /api/reports/stats.php` - Get report statistics
- `GET /api/reports/documents.php` - Get document reports
- `GET /api/reports/export.php` - Export reports to CSV

## File Structure

```
document-tracking/
├── api/                    # PHP backend
│   ├── config/            # Configuration files
│   ├── auth/              # Authentication endpoints
│   ├── documents/         # Document management
│   ├── dashboard/         # Dashboard data
│   ├── staff/             # Staff management
│   └── reports/           # Reporting system
├── database/              # Database schema
├── uploads/               # Uploaded files
├── public/                # Electron main process
├── src/                   # React application
│   ├── components/        # Reusable components
│   ├── contexts/          # React contexts
│   ├── pages/             # Page components
│   └── theme.js           # Material-UI theme
└── package.json           # Dependencies and scripts
```

## Security Features

- JWT-based authentication
- Password hashing with PHP's password_hash()
- File type validation for uploads
- File size limits (10MB)
- SQL injection prevention with prepared statements
- CORS headers for API security
- Environment-based configuration (credentials stored in `.env`)
- Secure error handling (no sensitive information exposure)
- Authentication middleware for consistent security

## Recent Improvements

See [REFACTORING.md](REFACTORING.md) for details on recent security and code quality improvements:
- Environment configuration system
- Authentication middleware
- Standardized response helpers
- Improved error handling
- Better CORS configuration

## Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Ensure XAMPP MySQL is running
   - Check database credentials in `api/config/database.php`
   - Verify database exists and schema is imported

2. **File Upload Issues**
   - Check uploads directory permissions
   - Verify file size limits
   - Ensure supported file types

3. **Authentication Issues**
   - Check JWT secret key configuration
   - Verify token expiration settings
   - Clear browser storage if needed

4. **Electron App Not Starting**
   - Ensure React app is built (`npm run build`)
   - Check Node.js version compatibility
   - Verify all dependencies are installed

## Development

### Adding New Features

1. Create API endpoints in appropriate directories
2. Add React components in `src/components/`
3. Create pages in `src/pages/`
4. Update routing in `src/App.js`

### Database Changes

1. Update schema in `database/schema.sql`
2. Create migration scripts if needed
3. Update API endpoints to handle new fields

## License

This project is for educational and internal use. Please ensure proper licensing for production deployment.

## Support

For issues and questions, please check the troubleshooting section or contact the development team.
