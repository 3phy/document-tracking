import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  TextField,
  Button,
  Switch,
  FormControlLabel,
  Alert,
  CircularProgress,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  IconButton,
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
} from '@mui/icons-material';
import axios from 'axios';
import API_BASE_URL from '../config/api';

const SystemSettings = () => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // Departments management
  const [departments, setDepartments] = useState([]);
  const [newDepartment, setNewDepartment] = useState({ name: '', description: '' });
  const [editingDepartment, setEditingDepartment] = useState(null);
  const [departmentDialogOpen, setDepartmentDialogOpen] = useState(false);

  useEffect(() => {
    fetchDepartments();
    setLoading(false);
  }, []);

  const fetchDepartments = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(`${API_BASE_URL}/departments/list.php`, {
        headers: { Authorization: `Bearer ${token}` }
      });

      if (response.data.success) {
        setDepartments(response.data.departments);
      }
    } catch (error) {
      console.error('Departments error:', error);
    }
  };


  const handleAddDepartment = () => {
    setNewDepartment({ name: '', description: '' });
    setEditingDepartment(null);
    setDepartmentDialogOpen(true);
  };

  const handleEditDepartment = (department) => {
    setNewDepartment({ name: department.name, description: department.description || '' });
    setEditingDepartment(department);
    setDepartmentDialogOpen(true);
  };

  const handleSaveDepartment = async () => {
    if (!newDepartment.name.trim()) {
      setError('Department name is required');
      return;
    }

    try {
      const token = localStorage.getItem('token');
      const url = editingDepartment 
        ? `${API_BASE_URL}/departments/update.php`
        : `${API_BASE_URL}/departments/create.php`;
      
      const data = editingDepartment 
        ? { id: editingDepartment.id, ...newDepartment }
        : newDepartment;

      const response = await axios.post(url, data, {
        headers: { 
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      console.log('Department API Response:', response.data);
      
      if (response.data.success) {
        setDepartmentDialogOpen(false);
        fetchDepartments();
        setSuccess(editingDepartment ? 'Department updated successfully!' : 'Department created successfully!');
      } else {
        setError(response.data.message || 'Failed to save department');
      }
    } catch (error) {
      console.error('Department error:', error);
      console.error('Error response:', error.response?.data);
      if (error.response?.data?.message) {
        setError(error.response.data.message);
      } else {
        setError('Failed to save department. Please try again.');
      }
    }
  };

  const handleDeleteDepartment = async (departmentId) => {
    if (!window.confirm('Are you sure you want to delete this department?')) {
      return;
    }

    try {
      const token = localStorage.getItem('token');
      const response = await axios.post(`${API_BASE_URL}/departments/delete.php`, 
        { id: departmentId },
        { 
          headers: { 
            Authorization: `Bearer ${token}`,
            'Content-Type': 'application/json'
          } 
        }
      );

      console.log('Delete API Response:', response.data);

      if (response.data.success) {
        fetchDepartments();
        setSuccess('Department deleted successfully!');
      } else {
        setError(response.data.message || 'Failed to delete department');
      }
    } catch (error) {
      console.error('Delete department error:', error);
      console.error('Error response:', error.response?.data);
      if (error.response?.data?.message) {
        setError(error.response.data.message);
      } else {
        setError('Failed to delete department. Please try again.');
      }
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
        {/* Departments Management */}
        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
                <Typography variant="h6">
                  Departments
                </Typography>
                <Button
                  variant="outlined"
                  size="small"
                  startIcon={<AddIcon />}
                  onClick={handleAddDepartment}
                >
                  Add
                </Button>
              </Box>

              <TableContainer component={Paper} variant="outlined">
                <Table size="small">
                  <TableHead>
                    <TableRow>
                      <TableCell sx={{ width: 90 }}><strong>ID</strong></TableCell>
                      <TableCell><strong>Name</strong></TableCell>
                      <TableCell><strong>Description</strong></TableCell>
                      <TableCell align="right" sx={{ width: 120 }}><strong>Actions</strong></TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {departments.map((dept) => (
                      <TableRow key={dept.id} hover>
                        <TableCell sx={{ fontFamily: 'monospace' }}>{dept.id}</TableCell>
                        <TableCell>{dept.name}</TableCell>
                        <TableCell>{dept.description || ''}</TableCell>
                        <TableCell align="right">
                          <IconButton
                            size="small"
                            onClick={() => handleEditDepartment(dept)}
                            aria-label="Edit department"
                          >
                            <EditIcon />
                          </IconButton>
                          <IconButton
                            size="small"
                            onClick={() => handleDeleteDepartment(dept.id)}
                            color="error"
                            aria-label="Delete department"
                          >
                            <DeleteIcon />
                          </IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                    {departments.length === 0 && (
                      <TableRow>
                        <TableCell colSpan={4} align="center">
                          <Typography variant="body2" color="text.secondary">
                            No departments found
                          </Typography>
                        </TableCell>
                      </TableRow>
                    )}
                  </TableBody>
                </Table>
              </TableContainer>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Department Dialog */}
      <Dialog open={departmentDialogOpen} onClose={() => setDepartmentDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>
          {editingDepartment ? 'Edit Department' : 'Add New Department'}
        </DialogTitle>
        <DialogContent>
          <TextField
            fullWidth
            label="Department Name"
            value={newDepartment.name}
            onChange={(e) => setNewDepartment({ ...newDepartment, name: e.target.value })}
            margin="normal"
            required
          />
          <TextField
            fullWidth
            label="Description"
            value={newDepartment.description}
            onChange={(e) => setNewDepartment({ ...newDepartment, description: e.target.value })}
            margin="normal"
            multiline
            rows={3}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDepartmentDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleSaveDepartment} variant="contained">
            {editingDepartment ? 'Update' : 'Create'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default SystemSettings;
