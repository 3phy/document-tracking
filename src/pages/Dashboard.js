import React, { useState, useEffect } from 'react';
import {
  Box,
  Grid,
  Card,
  CardContent,
  Typography,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  Chip,
  CircularProgress,
  Alert,
  Button,
  TextField,
  InputAdornment,
} from '@mui/material';
import {
  Description as DocumentIcon,
  Upload as UploadIcon,
  CheckCircle as ReceivedIcon,
  Pending as PendingIcon,
  TrendingUp as TrendingIcon,
  Search as SearchIcon,
  Business as DepartmentIcon,
} from '@mui/icons-material';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import API_BASE_URL from '../config/api';

const Dashboard = () => {
  const { user } = useAuth();
  const navigate = useNavigate();

  const [stats, setStats] = useState({
    totalDocuments: 0,
    outgoingDocuments: 0,
    pendingDocuments: 0,
    receivedDocuments: 0,
  });

  const [recentDocuments, setRecentDocuments] = useState([]);
  const [documents, setDocuments] = useState([]);
  const [userDepartment, setUserDepartment] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const token = localStorage.getItem('token');

      const userResponse = await axios.get(`${API_BASE_URL}/auth/verify.php`, {
        headers: { Authorization: `Bearer ${token}` },
      });

      if (userResponse.data.success) {
        setUserDepartment(userResponse.data.user.department_name);
      }

      const [statsRes, docsRes] = await Promise.all([
        axios.get(`${API_BASE_URL}/dashboard/stats.php`, {
          headers: { Authorization: `Bearer ${token}` },
        }),
        axios.get(`${API_BASE_URL}/documents/list.php`, {
          headers: { Authorization: `Bearer ${token}` },
        }),
      ]);

      if (statsRes.data.success) {
        setStats(statsRes.data.stats);
        setRecentDocuments(statsRes.data.recentDocuments || []);
      }

      if (docsRes.data.success) {
        setDocuments(docsRes.data.documents);
      }
    } catch (err) {
      console.error(err);
      setError('Failed to load dashboard data');
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'outgoing':
        return 'primary';
      case 'pending':
        return 'warning';
      case 'received':
        return 'success';
      default:
        return 'default';
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'outgoing':
        return <UploadIcon />;
      case 'pending':
        return <PendingIcon />;
      case 'received':
        return <ReceivedIcon />;
      default:
        return <DocumentIcon />;
    }
  };

  const filteredRecentDocs = recentDocuments.filter((doc) =>
    searchQuery
      ? doc.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        doc.department_name?.toLowerCase().includes(searchQuery.toLowerCase())
      : true
  );

  // 🔹 Group documents by department - count same way as DepartmentDocuments.js filters
  // Get all unique department names (from both current_department_name and department_name)
  const allDepartmentNames = new Set();
  documents.forEach((doc) => {
    if (doc.current_department_name) {
      allDepartmentNames.add(doc.current_department_name);
    }
    if (doc.department_name) {
      allDepartmentNames.add(doc.department_name);
    }
  });

  // Count documents for each department (matching DepartmentDocuments.js filter logic)
  const groupedDepartments = Array.from(allDepartmentNames).map((deptName) => {
    const docs = documents.filter(
      (doc) =>
        doc.current_department_name === deptName ||
        doc.department_name === deptName
    );
    return [deptName, docs];
  });

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" minHeight="400px">
        <CircularProgress />
      </Box>
    );
  }

  if (error) {
    return <Alert severity="error">{error}</Alert>;
  }

  return (
    <Box>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" gutterBottom sx={{ fontWeight: 600, mb: 1 }}>
          Dashboard
        </Typography>
        <Typography variant="body1" color="text.secondary" sx={{ fontSize: '1rem' }}>
          Welcome back, <Box component="span" sx={{ fontWeight: 500 }}>{user?.name}</Box>!
          {userDepartment && (
            <> You're viewing documents for <Box component="strong" sx={{ color: 'primary.main' }}>{userDepartment}</Box>.</>
          )}
        </Typography>
      </Box>

      {/* 📊 STATS */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        {[
          { label: 'Total Documents', value: stats.totalDocuments, icon: <DocumentIcon />, color: 'primary.main' },
          { label: 'Outgoing', value: stats.outgoingDocuments, icon: <UploadIcon />, color: 'primary.light' },
          { label: 'Pending', value: stats.pendingDocuments, icon: <PendingIcon />, color: 'warning.main' },
          { label: 'Received', value: stats.receivedDocuments, icon: <ReceivedIcon />, color: 'success.main' },
        ].map((item, i) => (
          <Grid item xs={12} sm={6} md={3} key={i}>
            <Card 
              sx={{ 
                height: '100%',
                transition: 'transform 0.2s, box-shadow 0.2s',
                '&:hover': {
                  transform: 'translateY(-4px)',
                  boxShadow: 4,
                }
              }}
            >
              <CardContent sx={{ p: 3 }}>
                <Box display="flex" alignItems="center">
                  <Box 
                    sx={{ 
                      p: 2, 
                      borderRadius: 2, 
                      bgcolor: item.color, 
                      color: 'white', 
                      mr: 2,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      minWidth: 56,
                      height: 56
                    }}
                  >
                    {item.icon}
                  </Box>
                  <Box sx={{ flex: 1, minWidth: 0 }}>
                    <Typography 
                      variant="h4" 
                      sx={{ 
                        fontWeight: 700,
                        mb: 0.5,
                        fontSize: { xs: '1.75rem', sm: '2rem' }
                      }}
                    >
                      {item.value}
                    </Typography>
                    <Typography 
                      color="text.secondary" 
                      sx={{ 
                        fontSize: '0.875rem',
                        fontWeight: 500
                      }}
                    >
                      {item.label}
                    </Typography>
                  </Box>
                </Box>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      {/* 🏢 DEPARTMENTS */}
      <Box sx={{ mb: 3 }}>
        <Typography variant="h6" sx={{ fontWeight: 600, mb: 2.5 }}>
          Departments
        </Typography>
      </Box>

      <Grid container spacing={3} sx={{ mb: 5 }}>
        {groupedDepartments.map(([deptName, docs]) => (
          <Grid item xs={12} sm={6} md={4} key={deptName}>
            <Card
              sx={{ 
                cursor: 'pointer', 
                height: '100%',
                transition: 'transform 0.2s, box-shadow 0.2s',
                '&:hover': { 
                  transform: 'translateY(-4px)',
                  boxShadow: 6 
                } 
              }}
              onClick={() =>
                navigate(`/documents/department/${encodeURIComponent(deptName)}`)
              }
            >
              <CardContent sx={{ p: 3 }}>
                <Box display="flex" alignItems="center" gap={2}>
                  <Box
                    sx={{
                      p: 1.5,
                      borderRadius: 2,
                      bgcolor: 'primary.main',
                      color: 'white',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}
                  >
                    <DepartmentIcon />
                  </Box>
                  <Box sx={{ flex: 1, minWidth: 0 }}>
                    <Typography 
                      variant="subtitle1" 
                      fontWeight="bold"
                      sx={{ 
                        mb: 0.5,
                        fontSize: '1rem',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        whiteSpace: 'nowrap'
                      }}
                    >
                      {deptName}
                    </Typography>
                    <Typography 
                      variant="body2" 
                      color="text.secondary"
                      sx={{ fontSize: '0.875rem' }}
                    >
                      {docs.length} document{docs.length !== 1 && 's'}
                    </Typography>
                  </Box>
                </Box>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      <Grid container spacing={3}>
        {/* 🕘 RECENT DOCUMENTS */}
        <Grid item xs={12} md={8}>
          <Card sx={{ height: '100%' }}>
            <CardContent sx={{ p: 3 }}>
              <Box 
                display="flex" 
                justifyContent="space-between" 
                alignItems="center"
                sx={{ mb: 3, flexWrap: { xs: 'wrap', sm: 'nowrap' }, gap: 2 }}
              >
                <Typography variant="h6" sx={{ fontWeight: 600 }}>
                  Recent Documents
                </Typography>
                <TextField
                  size="small"
                  placeholder="Search documents..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  sx={{ 
                    minWidth: { xs: '100%', sm: 250 },
                    '& .MuiOutlinedInput-root': {
                      borderRadius: 2,
                    }
                  }}
                  InputProps={{
                    startAdornment: (
                      <InputAdornment position="start">
                        <SearchIcon fontSize="small" />
                      </InputAdornment>
                    ),
                  }}
                />
              </Box>

              {filteredRecentDocs.length ? (
                <List sx={{ p: 0 }}>
                  {filteredRecentDocs.map((doc, i) => (
                    <ListItem 
                      key={i} 
                      divider={i < filteredRecentDocs.length - 1}
                      sx={{ 
                        py: 2,
                        px: 0,
                        '&:hover': {
                          bgcolor: 'action.hover',
                          borderRadius: 1,
                        }
                      }}
                    >
                      <ListItemIcon sx={{ minWidth: 40 }}>
                        {getStatusIcon(doc.status)}
                      </ListItemIcon>
                      <ListItemText
                        primary={
                          <Typography variant="body1" sx={{ fontWeight: 500, mb: 0.5 }}>
                            {doc.title}
                          </Typography>
                        }
                        secondary={
                          <Typography variant="body2" color="text.secondary">
                            {doc.department_name}
                          </Typography>
                        }
                        sx={{ mr: 2 }}
                      />
                      <Chip
                        label={doc.status}
                        size="small"
                        color={getStatusColor(doc.status)}
                        sx={{ 
                          textTransform: 'capitalize',
                          fontWeight: 500,
                          minWidth: 80
                        }}
                      />
                    </ListItem>
                  ))}
                </List>
              ) : (
                <Box sx={{ py: 4, textAlign: 'center' }}>
                  <Typography color="text.secondary" sx={{ fontSize: '0.95rem' }}>
                    No documents found
                  </Typography>
                </Box>
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* ⚡ QUICK ACTIONS — NOT REMOVED */}
        <Grid item xs={12} md={4}>
          <Card sx={{ height: '100%' }}>
            <CardContent sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom sx={{ fontWeight: 600, mb: 3 }}>
                Quick Actions
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                <Button
                  variant="contained"
                  startIcon={<UploadIcon />}
                  fullWidth
                  onClick={() => navigate('/documents')}
                  sx={{
                    py: 1.5,
                    borderRadius: 2,
                    textTransform: 'none',
                    fontWeight: 600,
                    fontSize: '0.95rem'
                  }}
                >
                  Upload Document
                </Button>
                <Button
                  variant="outlined"
                  startIcon={<DocumentIcon />}
                  fullWidth
                  onClick={() => navigate('/documents')}
                  sx={{
                    py: 1.5,
                    borderRadius: 2,
                    textTransform: 'none',
                    fontWeight: 500,
                    fontSize: '0.95rem'
                  }}
                >
                  View All Documents
                </Button>
                {user?.role === 'admin' && (
                  <Button
                    variant="outlined"
                    startIcon={<TrendingIcon />}
                    fullWidth
                    onClick={() => navigate('/reports')}
                    sx={{
                      py: 1.5,
                      borderRadius: 2,
                      textTransform: 'none',
                      fontWeight: 500,
                      fontSize: '0.95rem'
                    }}
                  >
                    Generate Report
                  </Button>
                )}
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Dashboard;
