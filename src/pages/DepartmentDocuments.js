import React, { useEffect, useState } from 'react';
import {
  Box,
  Grid,
  Card,
  CardContent,
  Typography,
  Chip,
  CircularProgress,
  Dialog,
  DialogTitle,
  DialogContent,
  Divider,
} from '@mui/material';
import {
  Description as DocIcon,
  Schedule as TimeIcon,
} from '@mui/icons-material';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import API_BASE_URL from '../config/api';
import DocumentTimeline from '../components/DocumentTimeline';

const DepartmentDocuments = () => {
  const { departmentName } = useParams();
  const decodedDept = decodeURIComponent(departmentName);

  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedDoc, setSelectedDoc] = useState(null);

  useEffect(() => {
    fetchDepartmentDocuments();
    // eslint-disable-next-line
  }, [departmentName]);

  const fetchDepartmentDocuments = async () => {
    try {
      const token = localStorage.getItem('token');

      const res = await axios.get(`${API_BASE_URL}/documents/list.php`, {
        headers: { Authorization: `Bearer ${token}` },
      });

      if (res.data.success) {
        const filtered = res.data.documents.filter(
          (doc) =>
            doc.current_department_name === decodedDept ||
            doc.department_name === decodedDept
        );
        setDocuments(filtered);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" mt={6}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Typography variant="h5" mb={3}>
        {decodedDept} Department Documents
      </Typography>

      {/* 📁 DOCUMENT GRID */}
      <Grid container spacing={3}>
        {documents.map((doc) => (
          <Grid item xs={12} sm={6} md={4} lg={3} key={doc.id}>
            <Card
              onClick={() => setSelectedDoc(doc)}
              sx={{
                height: 220,
                cursor: 'pointer',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'space-between',
                '&:hover': { boxShadow: 6 },
              }}
            >
              <CardContent>
                <DocIcon color="primary" />
                <Typography
                  variant="subtitle1"
                  fontWeight="bold"
                  noWrap
                  mt={1}
                >
                  {doc.title}
                </Typography>

                <Typography
                  variant="caption"
                  color="text.secondary"
                  display="block"
                  mt={0.5}
                  noWrap
                >
                  {doc.description || 'No description'}
                </Typography>
              </CardContent>

              <Box
                px={2}
                pb={2}
                display="flex"
                justifyContent="space-between"
                alignItems="center"
              >
                <Chip
                  label={doc.status}
                  size="small"
                  color={
                    doc.status === 'received'
                      ? 'success'
                      : doc.status === 'pending'
                      ? 'warning'
                      : doc.status === 'outgoing'
                      ? 'primary'
                      : 'default'
                  }
                  sx={{ textTransform: 'capitalize' }}
                />
                <TimeIcon fontSize="small" color="disabled" />
              </Box>
            </Card>
          </Grid>
        ))}
      </Grid>

      {/* ===================== */}
      {/* 📄 GOOGLE DRIVE MODAL */}
      {/* ===================== */}
      <Dialog
        open={Boolean(selectedDoc)}
        onClose={() => setSelectedDoc(null)}
        maxWidth="xl"
        fullWidth
      >
        <DialogTitle>
          {selectedDoc?.title}
        </DialogTitle>

        <DialogContent
          dividers
          sx={{ height: '80vh', p: 0 }}
        >
          {selectedDoc && (
            <Box display="flex" height="100%">
              {/* LEFT — DOCUMENT PREVIEW */}
              <Box
                sx={{
                  flex: 2,
                  bgcolor: '#f5f5f5',
                  p: 2,
                }}
              >
                {selectedDoc.file_path ? (
                  <Box
                    component="iframe"
                    src={`${API_BASE_URL}/documents/view.php?id=${selectedDoc.id}`}
                    sx={{
                      width: '100%',
                      height: '100%',
                      border: 'none',
                      bgcolor: 'white',
                    }}
                  />
                ) : (
                  <Typography
                    color="text.secondary"
                    align="center"
                    mt={10}
                  >
                    No preview available
                  </Typography>
                )}
              </Box>

              {/* RIGHT — INFO + TIMELINE */}
              <Box
                sx={{
                  flex: 1,
                  borderLeft: '1px solid #ddd',
                  p: 3,
                  overflowY: 'auto',
                }}
              >
                <Typography variant="subtitle1" fontWeight="bold">
                  Document Information
                </Typography>

                <Divider sx={{ my: 1.5 }} />

                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <Typography variant="body2" component="span">
                    <strong>Status:</strong>{' '}
                  </Typography>
                  <Chip
                    label={selectedDoc.status}
                    size="small"
                    color="primary"
                    sx={{ textTransform: 'capitalize' }}
                  />
                </Box>

                <Typography variant="body2" mt={1}>
                  <strong>Department:</strong>{' '}
                  {selectedDoc.current_department_name ||
                    selectedDoc.department_name}
                </Typography>

                <Typography variant="body2" mt={1}>
                  <strong>Description:</strong>
                </Typography>

                <Typography
                  variant="body2"
                  color="text.secondary"
                  mb={2}
                >
                  {selectedDoc.description || 'No description'}
                </Typography>

                {/* 🕒 TIMELINE */}
                <Divider sx={{ my: 2 }} />
                <Typography
                  variant="subtitle2"
                  fontWeight="bold"
                  mb={1}
                >
                  Document Timeline
                </Typography>

                <DocumentTimeline document={selectedDoc} />
              </Box>
            </Box>
          )}
        </DialogContent>
      </Dialog>
    </Box>
  );
};

export default DepartmentDocuments;
