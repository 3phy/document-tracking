import React, { useState, useEffect } from 'react';
import { Routes, Route, Navigate, Outlet, useLocation } from 'react-router-dom';
import { Box } from '@mui/material';
import Sidebar from './components/Sidebar';
import Navbar from './components/Navbar';
import Login from './pages/Login';
import ForgotPassword from './pages/ForgotPassword';
import Dashboard from './pages/Dashboard';
import Documents from './pages/Documents';
import StaffManagement from './pages/StaffManagement';
import Reports from './pages/Reports';
import SystemAdmin from './pages/SystemAdmin';
import Settings from './pages/Settings';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import DepartmentDocuments from './pages/DepartmentDocuments';

function PrivateLayout({ sidebarOpen, setSidebarOpen }) {
  return (
    <Box sx={{ display: 'flex' }}>
      <Sidebar open={sidebarOpen} onToggle={() => setSidebarOpen(!sidebarOpen)} />
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          display: 'flex',
          flexDirection: 'column',
          minHeight: '100vh',
          backgroundColor: 'background.default',
        }}
      >
        <Navbar onMenuClick={() => setSidebarOpen(!sidebarOpen)} />
        <Box sx={{ flexGrow: 1, p: 3 }}>
          <Outlet />
        </Box>
      </Box>
    </Box>
  );
}

function AppContent() {
  const { user, loading } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const location = useLocation();

  // Prevent body scroll when on login page
  useEffect(() => {
    if (location.pathname === '/login' || location.pathname === '/forgot-password') {
      document.body.style.overflow = 'hidden';
      document.body.style.height = '100vh';
    } else {
      document.body.style.overflow = '';
      document.body.style.height = '';
    }
    
    return () => {
      document.body.style.overflow = '';
      document.body.style.height = '';
    };
  }, [location.pathname]);

  if (loading) {
    return (
      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        minHeight="100vh"
      >
        Loading...
      </Box>
    );
  }

  return (
    <Routes>
      <Route path="/login" element={user ? <Navigate to="/dashboard" replace /> : <Login />} />
      <Route
        path="/forgot-password"
        element={user ? <Navigate to="/dashboard" replace /> : <ForgotPassword />}
      />

      {!user ? (
        <Route path="/*" element={<Navigate to="/login" replace />} />
      ) : (
        <Route element={<PrivateLayout sidebarOpen={sidebarOpen} setSidebarOpen={setSidebarOpen} />}>
          <Route path="/" element={<Navigate to="/dashboard" replace />} />
          <Route path="/dashboard" element={<Dashboard />} />

          {/* 📄 Documents */}
          <Route path="/documents" element={<Documents />} />
          <Route path="/documents/department/:departmentName" element={<DepartmentDocuments />} />

          {(user.role === 'admin' || user.role === 'department_head') && (
            <Route path="/staff" element={<StaffManagement />} />
          )}

          {user.role === 'admin' && <Route path="/system-admin" element={<SystemAdmin />} />}

          {(user.role === 'admin' || user.role === 'department_head') && (
            <Route path="/reports" element={<Reports />} />
          )}

          <Route path="/settings" element={<Settings />} />

          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Route>
      )}
    </Routes>
  );
}

function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}

export default App;
