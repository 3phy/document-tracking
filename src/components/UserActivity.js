import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Button,
  Alert,
  CircularProgress,
  Avatar,
  InputAdornment,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
} from '@mui/material';
import {
  Person as PersonIcon,
  Login as LoginIcon,
  Logout as LogoutIcon,
  Upload as UploadIcon,
  Download as DownloadIcon,
  Visibility as ViewIcon,
  Search as SearchIcon,
  FilterList as FilterIcon,
} from '@mui/icons-material';
import axios from 'axios';
import API_BASE_URL from '../config/api';

const UserActivity = () => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [activities, setActivities] = useState([]);
  const [users, setUsers] = useState([]);
  const [exporting, setExporting] = useState(false);
  const [exportDialogOpen, setExportDialogOpen] = useState(false);
  const [exportPassword, setExportPassword] = useState('');
  const [filters, setFilters] = useState({
    user: 'all',
    action: 'all',
    dateFrom: '',
    dateTo: '',
    search: ''
  });
  const [stats, setStats] = useState({
    totalUsers: 0,
    activeUsers: 0,
    totalActivities: 0,
    todayActivities: 0
  });

  useEffect(() => {
    fetchActivities();
    fetchUsers();
    fetchStats();
  }, []);

  const fetchActivities = async () => {
    setLoading(true);
    setError('');

    try {
      const token = localStorage.getItem('token');
      const params = new URLSearchParams();
      
      if (filters.user !== 'all') params.append('user_id', filters.user);
      if (filters.action !== 'all') params.append('action', filters.action);
      if (filters.dateFrom) params.append('date_from', filters.dateFrom);
      if (filters.dateTo) params.append('date_to', filters.dateTo);
      // Search is handled client-side (like Documents page) to keep the typed value visible
      // and to avoid backend errors on older DB schemas.

      const response = await axios.get(`${API_BASE_URL}/admin/activities.php?${params}`, {
        headers: { Authorization: `Bearer ${token}` }
      });

      if (response.data.success) {
        setActivities(response.data.activities);
      } else {
        setError('Failed to fetch activities');
      }
    } catch (error) {
      console.error('Activities error:', error);
      setError('Failed to fetch activities');
    } finally {
      setLoading(false);
    }
  };

  const fetchUsers = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(`${API_BASE_URL}/staff/list.php`, {
        headers: { Authorization: `Bearer ${token}` }
      });

      if (response.data.success) {
        setUsers(response.data.staff);
      }
    } catch (error) {
      console.error('Users error:', error);
    }
  };

  const fetchStats = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(`${API_BASE_URL}/admin/activity-stats.php`, {
        headers: { Authorization: `Bearer ${token}` }
      });

      if (response.data.success) {
        setStats(response.data.stats);
      }
    } catch (error) {
      console.error('Stats error:', error);
    }
  };

  const handleFilterChange = (field, value) => {
    setFilters({ ...filters, [field]: value });
  };

  const handleSearch = () => {
    fetchActivities();
  };

  const openExportDialog = () => {
    setError('');
    setExportPassword('');
    setExportDialogOpen(true);
  };

  const closeExportDialog = () => {
    if (exporting) return;
    setExportDialogOpen(false);
    setExportPassword('');
  };

  const handleConfirmAndExport = async () => {
    const token = localStorage.getItem('token');
    if (!exportPassword.trim()) {
      setError('Password is required to export user activities.');
      return;
    }

    try {
      setExporting(true);

      // Step-up auth: confirm password for this sensitive action
      const confirm = await axios.post(`${API_BASE_URL}/auth/confirm-password.php`, {
        password: exportPassword,
        purpose: 'activities_export',
      }, {
        headers: { Authorization: `Bearer ${token}` }
      });

      const confirmToken = confirm?.data?.confirm_token;
      if (!confirmToken) {
        setError('Password confirmation failed. Please try again.');
        return;
      }

      const params = new URLSearchParams();
      if (filters.user !== 'all') params.append('user_id', filters.user);
      if (filters.action !== 'all') params.append('action', filters.action);
      if (filters.dateFrom) params.append('date_from', filters.dateFrom);
      if (filters.dateTo) params.append('date_to', filters.dateTo);
      if ((filters.search || '').trim()) params.append('search', (filters.search || '').trim());

      const response = await axios.get(`${API_BASE_URL}/admin/activities-export.php?${params}`, {
        headers: {
          Authorization: `Bearer ${token}`,
          'X-Confirm-Token': confirmToken
        },
        responseType: 'blob'
      });

      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `user-activities-${new Date().toISOString().split('T')[0]}.csv`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
      closeExportDialog();
    } catch (e) {
      console.error('Export activities error:', e);
      setError('Export failed. Please confirm your password and try again.');
    } finally {
      setExporting(false);
    }
  };

  const searchTerm = (filters.search || '').trim().toLowerCase();
  const filteredActivities = searchTerm
    ? activities.filter((a) => {
        const haystack = [
          a.user_name,
          a.user_email,
          a.action,
          a.description,
          a.ip_address
        ]
          .filter(Boolean)
          .join(' ')
          .toLowerCase();
        return haystack.includes(searchTerm);
      })
    : activities;

  const getActionIcon = (action) => {
    switch (action) {
      case 'login': return <LoginIcon />;
      case 'logout': return <LogoutIcon />;
      case 'upload': return <UploadIcon />;
      case 'download': return <DownloadIcon />;
      case 'view': return <ViewIcon />;
      default: return <PersonIcon />;
    }
  };

  const getActionColor = (action) => {
    switch (action) {
      case 'login': return 'success';
      case 'logout': return 'warning';
      case 'upload': return 'primary';
      case 'download': return 'info';
      case 'view': return 'default';
      default: return 'default';
    }
  };

  if (loading && activities.length === 0) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      {error && (
        <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError('')}>
          {error}
        </Alert>
      )}

      {/* Stats Cards */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center">
                <Avatar sx={{ bgcolor: 'primary.main', mr: 2 }}>
                  <PersonIcon />
                </Avatar>
                <Box>
                  <Typography variant="h4" component="div">
                    {stats.totalUsers}
                  </Typography>
                  <Typography color="text.secondary">
                    Total Users
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center">
                <Avatar sx={{ bgcolor: 'success.main', mr: 2 }}>
                  <LoginIcon />
                </Avatar>
                <Box>
                  <Typography variant="h4" component="div">
                    {stats.activeUsers}
                  </Typography>
                  <Typography color="text.secondary">
                    Active Users
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center">
                <Avatar sx={{ bgcolor: 'info.main', mr: 2 }}>
                  <ViewIcon />
                </Avatar>
                <Box>
                  <Typography variant="h4" component="div">
                    {stats.totalActivities}
                  </Typography>
                  <Typography color="text.secondary">
                    Total Activities
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center">
                <Avatar sx={{ bgcolor: 'warning.main', mr: 2 }}>
                  <FilterIcon />
                </Avatar>
                <Box>
                  <Typography variant="h4" component="div">
                    {stats.todayActivities}
                  </Typography>
                  <Typography color="text.secondary">
                    Today's Activities
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Filters */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Box display="flex" alignItems="center" justifyContent="space-between" gap={2} sx={{ mb: 1 }}>
            <Typography variant="h6">
              Filter Activities
            </Typography>
            <Button
              variant="outlined"
              startIcon={<DownloadIcon />}
              onClick={openExportDialog}
              disabled={exporting}
            >
              Export
            </Button>
          </Box>
          <Grid container spacing={2} alignItems="center">
            <Grid item xs={12} sm={6} md={2}>
              <FormControl fullWidth size="small">
                <InputLabel>User</InputLabel>
                <Select
                  value={filters.user}
                  onChange={(e) => handleFilterChange('user', e.target.value)}
                  label="User"
                >
                  <MenuItem value="all">All Users</MenuItem>
                  {users.map((user) => (
                    <MenuItem key={user.id} value={user.id}>
                      {user.name}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} sm={6} md={2}>
              <FormControl fullWidth size="small">
                <InputLabel>Action</InputLabel>
                <Select
                  value={filters.action}
                  onChange={(e) => handleFilterChange('action', e.target.value)}
                  label="Action"
                >
                  <MenuItem value="all">All Actions</MenuItem>
                  <MenuItem value="login">Login</MenuItem>
                  <MenuItem value="logout">Logout</MenuItem>
                  <MenuItem value="upload">Upload</MenuItem>
                  <MenuItem value="download">Download</MenuItem>
                  <MenuItem value="view">View</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} sm={6} md={2}>
              <TextField
                fullWidth
                size="small"
                label="Date From"
                type="date"
                value={filters.dateFrom}
                onChange={(e) => handleFilterChange('dateFrom', e.target.value)}
                InputLabelProps={{ shrink: true }}
              />
            </Grid>
            <Grid item xs={12} sm={6} md={2}>
              <TextField
                fullWidth
                size="small"
                label="Date To"
                type="date"
                value={filters.dateTo}
                onChange={(e) => handleFilterChange('dateTo', e.target.value)}
                InputLabelProps={{ shrink: true }}
              />
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <TextField
                fullWidth
                size="small"
                label="Search"
                value={filters.search}
                onChange={(e) => handleFilterChange('search', e.target.value)}
                placeholder="Search activities..."
                  InputProps={{
                    startAdornment: (
                      <InputAdornment position="start">
                        <SearchIcon color="action" />
                      </InputAdornment>
                    )
                  }}
              />
            </Grid>
            <Grid item xs={12} sm={6} md={1}>
              <Button
                fullWidth
                variant="contained"
                startIcon={<SearchIcon />}
                onClick={handleSearch}
                disabled={loading}
              >
                Search
              </Button>
            </Grid>
          </Grid>
            {filters.search?.trim() && (
              <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
                Showing results matching: <strong>{filters.search.trim()}</strong>
              </Typography>
            )}
        </CardContent>
      </Card>

      {/* Activities Table */}
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            User Activities
          </Typography>
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>User</TableCell>
                  <TableCell>Action</TableCell>
                  <TableCell>Description</TableCell>
                  <TableCell>IP Address</TableCell>
                  <TableCell>Timestamp</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredActivities.map((activity) => (
                  <TableRow key={activity.id}>
                    <TableCell>
                      <Box display="flex" alignItems="center" gap={1}>
                        <Avatar sx={{ width: 32, height: 32 }}>
                          {activity.user_name ? activity.user_name.charAt(0).toUpperCase() : 'U'}
                        </Avatar>
                        <Box>
                          <Typography variant="body2" fontWeight="medium">
                            {activity.user_name || 'Unknown User'}
                          </Typography>
                          <Typography variant="caption" color="text.secondary">
                            {activity.user_email}
                          </Typography>
                        </Box>
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Chip
                        icon={getActionIcon(activity.action)}
                        label={activity.action}
                        color={getActionColor(activity.action)}
                        size="small"
                        sx={{ textTransform: 'capitalize' }}
                      />
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">
                        {activity.description}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" fontFamily="monospace">
                        {activity.ip_address}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">
                        {new Date(activity.created_at).toLocaleString()}
                      </Typography>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
          
          {filteredActivities.length === 0 && !loading && (
            <Box textAlign="center" py={4}>
              <Typography variant="body2" color="text.secondary">
                {filters.search?.trim()
                  ? `No activities found matching "${filters.search.trim()}".`
                  : 'No activities found matching your criteria'}
              </Typography>
            </Box>
          )}
        </CardContent>
      </Card>

      {/* Export Password Dialog */}
      <Dialog open={exportDialogOpen} onClose={closeExportDialog} maxWidth="xs" fullWidth>
        <DialogTitle>Confirm Password</DialogTitle>
        <DialogContent>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Please enter your password to export user activities.
          </Typography>
          <TextField
            fullWidth
            type="password"
            label="Password"
            value={exportPassword}
            onChange={(e) => setExportPassword(e.target.value)}
            autoFocus
            onKeyDown={(e) => {
              if (e.key === 'Enter') handleConfirmAndExport();
            }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={closeExportDialog} disabled={exporting}>Cancel</Button>
          <Button onClick={handleConfirmAndExport} variant="contained" disabled={exporting}>
            {exporting ? 'Please wait...' : 'Export'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default UserActivity;
