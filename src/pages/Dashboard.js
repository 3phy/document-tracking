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

  // 🔹 Group documents by department
  const groupedDepartments = Object.entries(
    documents.reduce((acc, doc) => {
      const dept =
        doc.current_department_name ||
        doc.department_name ||
        'No Department';

      acc[dept] = acc[dept] || [];
      acc[dept].push(doc);
      return acc;
    }, {})
  );

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
      <Typography variant="h4" gutterBottom>
        Dashboard
      </Typography>

      <Typography variant="body1" color="text.secondary" mb={3}>
        Welcome back, {user?.name}!
        {userDepartment && (
          <> You're viewing documents for <strong>{userDepartment}</strong>.</>
        )}
      </Typography>

      {/* 📊 STATS */}
      <Grid container spacing={3} mb={3}>
        {[
          { label: 'Total Documents', value: stats.totalDocuments, icon: <DocumentIcon />, color: 'primary.main' },
          { label: 'Outgoing', value: stats.outgoingDocuments, icon: <UploadIcon />, color: 'primary.light' },
          { label: 'Pending', value: stats.pendingDocuments, icon: <PendingIcon />, color: 'warning.main' },
          { label: 'Received', value: stats.receivedDocuments, icon: <ReceivedIcon />, color: 'success.main' },
        ].map((item, i) => (
          <Grid item xs={12} sm={6} md={3} key={i}>
            <Card>
              <CardContent>
                <Box display="flex" alignItems="center">
                  <Box sx={{ p: 2, borderRadius: 2, bgcolor: item.color, color: 'white', mr: 2 }}>
                    {item.icon}
                  </Box>
                  <Box>
                    <Typography variant="h4">{item.value}</Typography>
                    <Typography color="text.secondary">{item.label}</Typography>
                  </Box>
                </Box>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      {/* 🏢 DEPARTMENTS */}
      <Typography variant="h6" mb={2}>
        Departments
      </Typography>

      <Grid container spacing={3} mb={4}>
        {groupedDepartments.map(([deptName, docs]) => (
          <Grid item xs={12} sm={6} md={4} key={deptName}>
            <Card
              sx={{ cursor: 'pointer', '&:hover': { boxShadow: 6 } }}
              onClick={() =>
                navigate(`/documents/department/${encodeURIComponent(deptName)}`)
              }
            >
              <CardContent>
                <Box display="flex" alignItems="center" gap={2}>
                  <DepartmentIcon color="primary" />
                  <Box>
                    <Typography variant="subtitle1" fontWeight="bold">
                      {deptName}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
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
          <Card>
            <CardContent>
              <Box display="flex" justifyContent="space-between" mb={2}>
                <Typography variant="h6">Recent Documents</Typography>
                <TextField
                  size="small"
                  placeholder="Search..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  InputProps={{
                    startAdornment: (
                      <InputAdornment position="start">
                        <SearchIcon />
                      </InputAdornment>
                    ),
                  }}
                />
              </Box>

              {filteredRecentDocs.length ? (
                <List>
                  {filteredRecentDocs.map((doc, i) => (
                    <ListItem key={i} divider>
                      <ListItemIcon>{getStatusIcon(doc.status)}</ListItemIcon>
                      <ListItemText
                        primary={doc.title}
                        secondary={doc.department_name}
                      />
                      <Chip
                        label={doc.status}
                        size="small"
                        color={getStatusColor(doc.status)}
                        sx={{ textTransform: 'capitalize' }}
                      />
                    </ListItem>
                  ))}
                </List>
              ) : (
                <Typography color="text.secondary" textAlign="center">
                  No documents found
                </Typography>
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* ⚡ QUICK ACTIONS — NOT REMOVED */}
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Quick Actions
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                <Button
                  variant="contained"
                  startIcon={<UploadIcon />}
                  fullWidth
                  onClick={() => navigate('/documents')}
                >
                  Upload Document
                </Button>
                <Button
                  variant="outlined"
                  startIcon={<DocumentIcon />}
                  fullWidth
                  onClick={() => navigate('/documents')}
                >
                  View All Documents
                </Button>
                {user?.role === 'admin' && (
                  <Button
                    variant="outlined"
                    startIcon={<TrendingIcon />}
                    fullWidth
                    onClick={() => navigate('/reports')}
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
