import React from 'react';
import {
  AppBar,
  Toolbar,
  IconButton,
  Typography,
  Box,
  Avatar,
  Menu,
  MenuItem,
  Chip,
  useTheme,
  useMediaQuery,
  Divider,
} from '@mui/material';
import {
  Menu as MenuIcon,
  AccountCircle,
  Settings as SettingsIcon,
  Logout as LogoutIcon,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';

const Navbar = ({ onMenuClick }) => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [anchorEl, setAnchorEl] = React.useState(null);

  const handleProfileMenuOpen = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = () => {
    logout();
    handleMenuClose();
  };

  const handleSettings = () => {
    navigate('/settings');
    handleMenuClose();
  };

  return (
    <AppBar
      position="static"
      elevation={0}
      sx={{
        backgroundColor: 'background.paper',
        color: 'text.primary',
        boxShadow: 'none',
        borderBottom: `1px solid ${theme.palette.divider}`,
        zIndex: theme.zIndex.drawer + 1,
      }}
    >
      <Toolbar sx={{ px: { xs: 2, sm: 3 }, py: 1.5 }}>
        {isMobile && (
          <IconButton
            color="inherit"
            aria-label="open drawer"
            onClick={onMenuClick}
            edge="start"
            sx={{ 
              mr: 2,
              '&:hover': {
                bgcolor: 'action.hover',
              }
            }}
          >
            <MenuIcon />
          </IconButton>
        )}
        
        <Typography 
          variant="h6" 
          component="div" 
          sx={{ 
            flexGrow: 1,
            fontWeight: 600,
            fontSize: { xs: '1rem', sm: '1.25rem' },
            color: 'text.primary'
          }}
        >
          Document Tracking System
        </Typography>

        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Box sx={{ display: { xs: 'none', sm: 'flex' }, alignItems: 'center', gap: 1.5 }}>
            <Typography 
              variant="body2" 
              color="text.secondary"
              sx={{ 
                fontSize: '0.9rem',
                fontWeight: 500
              }}
            >
              Welcome, <Box component="span" sx={{ fontWeight: 600, color: 'text.primary' }}>{user?.name}</Box>
            </Typography>
            <Chip
              label={user?.role}
              size="small"
              sx={{
                height: 24,
                fontSize: '0.75rem',
                fontWeight: 600,
                textTransform: 'capitalize',
                backgroundColor: user?.role === 'admin' ? 'primary.main' : 'secondary.main',
                color: 'white',
                '& .MuiChip-label': {
                  px: 1.5,
                },
              }}
            />
          </Box>
          
          <IconButton
            size="medium"
            edge="end"
            aria-label="account of current user"
            aria-controls="primary-search-account-menu"
            aria-haspopup="true"
            onClick={handleProfileMenuOpen}
            color="inherit"
            sx={{
              '&:hover': {
                bgcolor: 'action.hover',
              }
            }}
          >
            <Avatar 
              sx={{ 
                width: 36, 
                height: 36, 
                bgcolor: 'primary.main',
                fontWeight: 600,
                fontSize: '0.95rem',
                border: '2px solid',
                borderColor: 'primary.light'
              }}
            >
              {user?.name?.charAt(0)?.toUpperCase()}
            </Avatar>
          </IconButton>
        </Box>

        <Menu
          anchorEl={anchorEl}
          anchorOrigin={{
            vertical: 'bottom',
            horizontal: 'right',
          }}
          keepMounted
          transformOrigin={{
            vertical: 'top',
            horizontal: 'right',
          }}
          open={Boolean(anchorEl)}
          onClose={handleMenuClose}
          PaperProps={{
            sx: {
              mt: 1.5,
              minWidth: 200,
              borderRadius: 2,
              boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
              border: '1px solid',
              borderColor: 'divider',
            }
          }}
        >
          <Box sx={{ px: 2, py: 1.5, borderBottom: '1px solid', borderColor: 'divider' }}>
            <Typography variant="body2" sx={{ fontWeight: 600, mb: 0.5 }}>
              {user?.name}
            </Typography>
            <Typography variant="caption" color="text.secondary">
              {user?.email}
            </Typography>
            <Chip
              label={user?.role}
              size="small"
              sx={{
                mt: 1,
                height: 20,
                fontSize: '0.7rem',
                fontWeight: 600,
                textTransform: 'capitalize',
                backgroundColor: user?.role === 'admin' ? 'primary.main' : 'secondary.main',
                color: 'white',
              }}
            />
          </Box>
          <MenuItem 
            onClick={handleSettings}
            sx={{
              py: 1.5,
              px: 2,
              '&:hover': {
                bgcolor: 'action.hover',
              }
            }}
          >
            <AccountCircle sx={{ mr: 2, fontSize: 20 }} />
            <Typography variant="body2">Settings</Typography>
          </MenuItem>
          <Divider />
          <MenuItem 
            onClick={handleLogout}
            sx={{
              py: 1.5,
              px: 2,
              color: 'error.main',
              '&:hover': {
                bgcolor: 'error.light',
                color: 'white',
              }
            }}
          >
            <LogoutIcon sx={{ mr: 2, fontSize: 20 }} />
            <Typography variant="body2">Logout</Typography>
          </MenuItem>
        </Menu>
      </Toolbar>
    </AppBar>
  );
};

export default Navbar;
