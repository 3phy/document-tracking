import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  TextField,
  Button,
  Grid,
  Alert,
  Divider,
  IconButton,
  InputAdornment,
  CircularProgress,
  Switch,
  FormControlLabel,
} from '@mui/material';
import {
  Visibility,
  VisibilityOff,
  Save as SaveIcon,
  Person as PersonIcon,
  Lock as LockIcon,
  DarkMode as DarkModeIcon,
  LightMode as LightModeIcon,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import { useThemeMode } from '../contexts/ThemeContext';
import axios from 'axios';
import API_BASE_URL from '../config/api';

const Settings = () => {
  const { user, setUser } = useAuth();
  const { mode, toggleColorMode } = useThemeMode();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // Profile fields
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');

  // Password fields
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(`${API_BASE_URL}/user/profile.php`, {
        headers: { Authorization: `Bearer ${token}` }
      });

      if (response.data.success) {
        const userData = response.data.user;
        setName(userData.name || '');
        setEmail(userData.email || '');
        // Update auth context with latest user data
        if (setUser) {
          setUser(userData);
        }
      } else {
        setError('Failed to load profile');
      }
    } catch (error) {
      console.error('Profile fetch error:', error);
      setError('Failed to load profile');
    } finally {
      setLoading(false);
    }
  };

  const handleSaveProfile = async () => {
    setSaving(true);
    setError('');
    setSuccess('');

    // Validate
    if (!name.trim()) {
      setError('Name is required');
      setSaving(false);
      return;
    }

    if (!email.trim()) {
      setError('Email is required');
      setSaving(false);
      return;
    }

    try {
      const token = localStorage.getItem('token');
      const updateData = {
        name: name.trim(),
        email: email.trim(),
      };

      // Only include password if new password is provided
      if (newPassword) {
        if (!currentPassword) {
          setError('Current password is required to change password');
          setSaving(false);
          return;
        }

        if (newPassword.length < 6) {
          setError('New password must be at least 6 characters');
          setSaving(false);
          return;
        }

        if (newPassword !== confirmPassword) {
          setError('New passwords do not match');
          setSaving(false);
          return;
        }

        updateData.current_password = currentPassword;
        updateData.password = newPassword;
      }

      const response = await axios.put(`${API_BASE_URL}/user/profile.php`, updateData, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (response.data.success) {
        setSuccess('Profile updated successfully!');
        
        // Update auth context
        if (setUser && response.data.user) {
          setUser(response.data.user);
        }

        // Clear password fields
        setCurrentPassword('');
        setNewPassword('');
        setConfirmPassword('');

        // Clear success message after 3 seconds
        setTimeout(() => setSuccess(''), 3000);
      } else {
        setError(response.data.message || 'Failed to update profile');
      }
    } catch (error) {
      console.error('Update error:', error);
      if (error.response?.data?.message) {
        setError(error.response.data.message);
      } else {
        setError('Failed to update profile. Please try again.');
      }
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Settings
      </Typography>
      <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
        Manage your profile and account settings
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError('')}>
          {error}
        </Alert>
      )}

      {success && (
        <Alert severity="success" sx={{ mb: 2 }} onClose={() => setSuccess('')}>
          {success}
        </Alert>
      )}

      <Grid container spacing={3}>
        {/* Profile Information */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" gap={1} mb={3}>
                <PersonIcon color="primary" />
                <Typography variant="h6">
                  Profile Information
                </Typography>
              </Box>

              <TextField
                fullWidth
                label="Full Name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                margin="normal"
                required
              />

              <TextField
                fullWidth
                label="Email Address"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                margin="normal"
                required
              />

              {user?.department_name && (
                <TextField
                  fullWidth
                  label="Department"
                  value={user.department_name}
                  margin="normal"
                  disabled
                  helperText="Department cannot be changed"
                />
              )}

              {user?.role && (
                <TextField
                  fullWidth
                  label="Role"
                  value={
                    user.role === 'admin' ? 'Administrator' :
                    user.role === 'department_head' ? 'Department Head' :
                    'Staff'
                  }
                  margin="normal"
                  disabled
                />
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* Appearance */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" gap={1} mb={3}>
                {mode === 'dark' ? <DarkModeIcon color="primary" /> : <LightModeIcon color="primary" />}
                <Typography variant="h6">
                  Appearance
                </Typography>
              </Box>
              <Box display="flex" alignItems="center" justifyContent="space-between">
                <Box display="flex" alignItems="center" gap={2}>
                  <Typography variant="body1">
                    {mode === 'dark' ? 'Dark Mode' : 'Light Mode'}
                  </Typography>
                </Box>
                <FormControlLabel
                  control={
                    <Switch
                      checked={mode === 'dark'}
                      onChange={toggleColorMode}
                      color="primary"
                    />
                  }
                  label={mode === 'dark' ? 'Dark' : 'Light'}
                />
              </Box>
              <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                Toggle between light and dark theme. Your preference will be saved automatically.
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        {/* Change Password */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" gap={1} mb={3}>
                <LockIcon color="primary" />
                <Typography variant="h6">
                  Change Password
                </Typography>
              </Box>

              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                Leave blank if you don't want to change your password
              </Typography>

              <TextField
                fullWidth
                label="Current Password"
                type={showCurrentPassword ? 'text' : 'password'}
                value={currentPassword}
                onChange={(e) => setCurrentPassword(e.target.value)}
                margin="normal"
                InputProps={{
                  endAdornment: (
                    <InputAdornment position="end">
                      <IconButton
                        onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                        edge="end"
                      >
                        {showCurrentPassword ? <VisibilityOff /> : <Visibility />}
                      </IconButton>
                    </InputAdornment>
                  ),
                }}
              />

              <TextField
                fullWidth
                label="New Password"
                type={showNewPassword ? 'text' : 'password'}
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                margin="normal"
                helperText="Minimum 6 characters"
                InputProps={{
                  endAdornment: (
                    <InputAdornment position="end">
                      <IconButton
                        onClick={() => setShowNewPassword(!showNewPassword)}
                        edge="end"
                      >
                        {showNewPassword ? <VisibilityOff /> : <Visibility />}
                      </IconButton>
                    </InputAdornment>
                  ),
                }}
              />

              <TextField
                fullWidth
                label="Confirm New Password"
                type={showConfirmPassword ? 'text' : 'password'}
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                margin="normal"
                InputProps={{
                  endAdornment: (
                    <InputAdornment position="end">
                      <IconButton
                        onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                        edge="end"
                      >
                        {showConfirmPassword ? <VisibilityOff /> : <Visibility />}
                      </IconButton>
                    </InputAdornment>
                  ),
                }}
              />
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Box sx={{ mt: 3, display: 'flex', gap: 2 }}>
        <Button
          variant="contained"
          startIcon={<SaveIcon />}
          onClick={handleSaveProfile}
          disabled={saving}
          size="large"
        >
          {saving ? 'Saving...' : 'Save Changes'}
        </Button>
      </Box>
    </Box>
  );
};

export default Settings;

