import React from 'react';
import {
  Drawer,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Divider,
  Typography,
  Box,
  useTheme,
  useMediaQuery,
} from '@mui/material';
import {
  Dashboard as DashboardIcon,
  Description as DocumentsIcon,
  People as PeopleIcon,
  Assessment as ReportsIcon,
  Settings as SettingsIcon,
  AccountCircle as AccountIcon,
  Logout as LogoutIcon,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate, useLocation } from 'react-router-dom';

const drawerWidth = 240;

const Sidebar = ({ open, onToggle }) => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const menuItems = [
    {
      text: 'Dashboard',
      icon: <DashboardIcon />,
      path: '/dashboard',
      roles: ['admin', 'staff', 'department_head']
    },
    {
      text: 'Documents',
      icon: <DocumentsIcon />,
      path: '/documents',
      roles: ['admin', 'staff', 'department_head']
    },
    {
      text: 'Staff Management',
      icon: <PeopleIcon />,
      path: '/staff',
      roles: ['admin', 'department_head']
    },
    {
      text: 'Reports',
      icon: <ReportsIcon />,
      path: '/reports',
      roles: ['admin', 'department_head']
    },
    {
      text: 'System Admin',
      icon: <SettingsIcon />,
      path: '/system-admin',
      roles: ['admin']
    },
    {
      text: 'Settings',
      icon: <AccountIcon />,
      path: '/settings',
      roles: ['admin', 'staff', 'department_head']
    }
  ];

  const filteredMenuItems = menuItems.filter(item => 
    item.roles.includes(user?.role)
  );

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  const drawer = (
    <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column', bgcolor: 'background.paper' }}>
      {/* Header Section */}
      <Box 
        sx={{ 
          p: 3, 
          textAlign: 'center',
          bgcolor: 'primary.main',
          color: 'white',
          borderBottom: '1px solid',
          borderColor: 'divider'
        }}
      >
        <Typography 
          variant="h6" 
          sx={{ 
            fontWeight: 700,
            mb: 0.5,
            fontSize: '1.1rem',
            letterSpacing: '0.5px'
          }}
        >
          Document Tracking System
        </Typography>
        <Typography 
          variant="caption" 
          sx={{ 
            fontSize: '0.75rem',
            opacity: 0.9,
            display: 'block'
          }}
        >
          Office Document Progress Tracking System
        </Typography>
      </Box>
      
      <Divider />
      
      {/* Menu Items */}
      <List sx={{ flexGrow: 1, pt: 2, px: 1.5 }}>
        {filteredMenuItems.map((item) => {
          const isSelected = location.pathname === item.path;
          return (
            <ListItem
              key={item.text}
              button
              onClick={() => navigate(item.path)}
              selected={isSelected}
              sx={{
                mb: 0.75,
                borderRadius: 2,
                py: 1.25,
                px: 2,
                transition: 'all 0.2s ease-in-out',
                '&:hover': {
                  bgcolor: isSelected ? 'primary.dark' : 'action.hover',
                  transform: 'translateX(4px)',
                },
                '&.Mui-selected': {
                  backgroundColor: theme.palette.primary.main,
                  color: 'white',
                  boxShadow: `0 2px 8px ${theme.palette.primary.main}40`,
                  '&:hover': {
                    backgroundColor: theme.palette.primary.dark,
                    transform: 'translateX(4px)',
                  },
                  '& .MuiListItemIcon-root': {
                    color: 'white',
                  },
                  '& .MuiListItemText-primary': {
                    fontWeight: 600,
                  },
                },
              }}
            >
              <ListItemIcon sx={{ minWidth: 40 }}>
                {item.icon}
              </ListItemIcon>
              <ListItemText 
                primary={item.text}
                primaryTypographyProps={{
                  fontSize: '0.95rem',
                  fontWeight: isSelected ? 600 : 500,
                }}
              />
            </ListItem>
          );
        })}
      </List>
      
      <Divider />
      
      {/* Logout Section */}
      <List sx={{ px: 1.5, pb: 2 }}>
        <ListItem
          button
          onClick={handleLogout}
          sx={{
            borderRadius: 2,
            py: 1.25,
            px: 2,
            color: theme.palette.error.main,
            transition: 'all 0.2s ease-in-out',
            '&:hover': {
              backgroundColor: theme.palette.error.main,
              color: 'white',
              transform: 'translateX(4px)',
              boxShadow: `0 2px 8px ${theme.palette.error.main}40`,
            },
          }}
        >
          <ListItemIcon sx={{ color: 'inherit', minWidth: 40 }}>
            <LogoutIcon />
          </ListItemIcon>
          <ListItemText 
            primary="Logout"
            primaryTypographyProps={{
              fontSize: '0.95rem',
              fontWeight: 500,
            }}
          />
        </ListItem>
      </List>
    </Box>
  );

  return (
    <Drawer
      variant={isMobile ? 'temporary' : 'persistent'}
      open={open}
      onClose={onToggle}
      sx={{
        width: drawerWidth,
        flexShrink: 0,
        '& .MuiDrawer-paper': {
          width: drawerWidth,
          boxSizing: 'border-box',
          borderRight: '1px solid',
          borderColor: 'divider',
        },
      }}
    >
      {drawer}
    </Drawer>
  );
};

export default Sidebar;
