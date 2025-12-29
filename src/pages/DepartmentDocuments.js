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
  Tabs,
  Tab,
} from '@mui/material';
import { useTheme } from '@mui/material/styles';
import {
  Description as DocIcon,
  Schedule as TimeIcon,
} from '@mui/icons-material';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import API_BASE_URL from '../config/api';

const DepartmentDocuments = () => {
  const theme = useTheme();
  const { departmentName } = useParams();
  const decodedDept = decodeURIComponent(departmentName);

  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedDoc, setSelectedDoc] = useState(null);
  const [dynamicRoutingData, setDynamicRoutingData] = useState(null);
  const [statusFilter, setStatusFilter] = useState('all');

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

  const fetchRoutingData = async (document) => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(`${API_BASE_URL}/documents/routing-history.php?document_id=${document.id}`, {
        headers: { Authorization: `Bearer ${token}` }
      });

      if (response.data.success) {
        setDynamicRoutingData(response.data);
      }
    } catch (error) {
      // Silently fail - routing history not critical
      setDynamicRoutingData(null);
    }
  };

  const getStatusColor = (status) => {
    const s = (status || '').toLowerCase();
    switch (s) {
      case 'outgoing': return 'primary';
      case 'pending': return 'warning';
      case 'received': return 'success';
      case 'rejected': return 'error';
      case 'cancelled': return 'error';
      case 'canceled': return 'error';
      default: return 'default';
    }
  };

  const getDisplayStatus = (doc) => {
    const raw = (doc.display_status || doc.status || '').toLowerCase();
    // Map backend 'rejected' status to 'cancelled' for display
    if (raw === 'rejected' || ['cancelled', 'canceled'].includes(raw)) return 'cancelled';
    return raw;
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const handleDocumentSelect = (doc) => {
    setSelectedDoc(doc);
    setDynamicRoutingData(null);
    if (doc) {
      fetchRoutingData(doc);
    }
  };

  const handleStatusFilterChange = (event, newValue) => {
    setStatusFilter(newValue);
  };

  // Filter documents based on selected status
  const filteredDocuments = documents.filter((doc) => {
    if (statusFilter === 'all') return true;
    
    const displayStatus = getDisplayStatus(doc);
    const docStatus = (doc.status || '').toLowerCase();
    
    if (statusFilter === 'cancelled') {
      // Include both cancelled and rejected (getDisplayStatus maps rejected to cancelled)
      return displayStatus === 'cancelled';
    }
    
    return docStatus === statusFilter;
  });

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" mt={6}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 600, mb: 1 }}>
          {decodedDept} Department Documents
        </Typography>
        <Typography variant="body2" color="text.secondary" sx={{ fontSize: '0.95rem' }}>
          View and manage documents for this department
        </Typography>
      </Box>

      {/* 📊 STATUS FILTER */}
      <Box sx={{ mb: 4 }}>
        <Tabs
          value={statusFilter}
          onChange={handleStatusFilterChange}
          variant="scrollable"
          scrollButtons="auto"
          sx={{
            borderBottom: 2,
            borderColor: 'divider',
            '& .MuiTab-root': {
              textTransform: 'none',
              fontWeight: 500,
              fontSize: '0.95rem',
              minHeight: 48,
              px: 3,
            },
            '& .Mui-selected': {
              fontWeight: 600,
            },
          }}
        >
          <Tab label={`All (${documents.length})`} value="all" />
          <Tab label={`Outgoing (${documents.filter(d => (d.status || '').toLowerCase() === 'outgoing').length})`} value="outgoing" />
          <Tab label={`Pending (${documents.filter(d => (d.status || '').toLowerCase() === 'pending').length})`} value="pending" />
          <Tab label={`Received (${documents.filter(d => (d.status || '').toLowerCase() === 'received').length})`} value="received" />
          <Tab 
            label={`Cancelled/Rejected (${documents.filter(d => getDisplayStatus(d) === 'cancelled').length})`} 
            value="cancelled" 
          />
        </Tabs>
      </Box>

      {/* 📁 DOCUMENT GRID */}
      <Grid container spacing={3}>
        {filteredDocuments.length > 0 ? (
          filteredDocuments.map((doc) => (
          <Grid item xs={12} sm={6} md={4} lg={3} key={doc.id}>
            <Card
              onClick={() => handleDocumentSelect(doc)}
              sx={{
                height: '100%',
                minHeight: 240,
                cursor: 'pointer',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'space-between',
                transition: 'transform 0.2s, box-shadow 0.2s',
                '&:hover': { 
                  transform: 'translateY(-4px)',
                  boxShadow: 6 
                },
              }}
            >
              <CardContent sx={{ p: 3, flex: 1, display: 'flex', flexDirection: 'column' }}>
                <Box sx={{ mb: 2 }}>
                  <Box
                    sx={{
                      display: 'inline-flex',
                      p: 1.5,
                      borderRadius: 2,
                      bgcolor: 'primary.main',
                      color: 'white',
                      mb: 1.5
                    }}
                  >
                    <DocIcon />
                  </Box>
                </Box>
                <Typography
                  variant="subtitle1"
                  fontWeight="bold"
                  sx={{
                    mb: 1,
                    fontSize: '1rem',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    display: '-webkit-box',
                    WebkitLineClamp: 2,
                    WebkitBoxOrient: 'vertical',
                    lineHeight: 1.4,
                    minHeight: '2.8em'
                  }}
                >
                  {doc.title}
                </Typography>

                <Typography
                  variant="caption"
                  color="text.secondary"
                  sx={{
                    fontSize: '0.8rem',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    display: '-webkit-box',
                    WebkitLineClamp: 2,
                    WebkitBoxOrient: 'vertical',
                    lineHeight: 1.4,
                    flex: 1
                  }}
                >
                  {doc.description || 'No description'}
                </Typography>
              </CardContent>

              <Box
                sx={{
                  px: 3,
                  pb: 3,
                  pt: 2,
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  borderTop: '1px solid',
                  borderColor: 'divider'
                }}
              >
                <Chip
                  label={getDisplayStatus(doc)}
                  size="small"
                  color={getStatusColor(getDisplayStatus(doc))}
                  sx={{ 
                    textTransform: 'capitalize',
                    fontWeight: 500,
                    minWidth: 80
                  }}
                />
                <TimeIcon fontSize="small" color="disabled" />
              </Box>
            </Card>
          </Grid>
          ))
        ) : (
          <Grid item xs={12}>
            <Box
              sx={{
                textAlign: 'center',
                py: 10,
                px: 2,
              }}
            >
              <Typography variant="h6" color="text.secondary" gutterBottom sx={{ fontWeight: 500, mb: 1 }}>
                No documents found
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ fontSize: '0.95rem' }}>
                {statusFilter === 'all'
                  ? 'No documents available for this department.'
                  : `No documents with "${statusFilter}" status found.`}
              </Typography>
            </Box>
          </Grid>
        )}
      </Grid>

      {/* ===================== */}
      {/* 📄 GOOGLE DRIVE MODAL */}
      {/* ===================== */}
      <Dialog
        open={Boolean(selectedDoc)}
        onClose={() => {
          setSelectedDoc(null);
          setDynamicRoutingData(null);
        }}
        maxWidth="xl"
        fullWidth
      >
        <DialogTitle sx={{ pb: 2, fontWeight: 600, fontSize: '1.25rem' }}>
          Document Routing Path
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
                  bgcolor: theme.palette.mode === 'dark' ? 'grey.900' : '#f5f5f5',
                  p: 3,
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
                      borderRadius: 2,
                      bgcolor: 'white',
                      boxShadow: 2,
                    }}
                  />
                ) : (
                  <Box
                    sx={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      height: '100%',
                      bgcolor: 'grey.100',
                      borderRadius: 2,
                    }}
                  >
                    <Typography
                      color="text.secondary"
                      sx={{ fontSize: '1rem' }}
                    >
                      No preview available
                    </Typography>
                  </Box>
                )}
              </Box>

              {/* RIGHT — ROUTING PATH */}
              <Box
                sx={{
                  flex: 1,
                  borderLeft: `1px solid ${theme.palette.divider}`,
                  p: 3,
                  overflowY: 'auto',
                }}
              >
                {selectedDoc && (
                  <Box>
                    <Box sx={{ mb: 3, p: 2, bgcolor: 'grey.50', borderRadius: 2 }}>
                      <Typography variant="body1" gutterBottom sx={{ fontWeight: 600, mb: 1, fontSize: '1rem' }}>
                        Document: {selectedDoc.title}
                      </Typography>

                      {selectedDoc.description && (
                        <Typography variant="body2" color="text.secondary" sx={{ fontSize: '0.9rem', lineHeight: 1.6 }}>
                          {selectedDoc.description}
                        </Typography>
                      )}
                    </Box>

                    {dynamicRoutingData?.routing_details?.length > 0 ? (
                      <Box>
                        <Typography variant="body2" gutterBottom sx={{ fontWeight: 600, mb: 2, fontSize: '0.95rem' }}>
                          Routing Path & Status:
                        </Typography>

                        <Box sx={{ p: 2.5, bgcolor: theme.palette.mode === 'dark' ? 'grey.800' : 'grey.100', borderRadius: 2 }}>
                          {dynamicRoutingData.routing_details.map((step, index) => {
                            const isFirst = index === 0;
                            const isLast = index === dynamicRoutingData.routing_details.length - 1;

                            // Determine status: only show if actually received or if it's the last step
                            const displayStatus = getDisplayStatus(selectedDoc);
                            const isDocumentCancelled = displayStatus === 'cancelled';
                            
                            let stepStatus = null;
                            if (isFirst) {
                              // Source department shows cancelled if document is cancelled
                              stepStatus = isDocumentCancelled ? 'cancelled' : null;
                            } else {
                              if (step.was_received || step.action === 'received') {
                                // If received, show received status (or cancelled if document is cancelled and it's the last step)
                                stepStatus = isDocumentCancelled && isLast ? 'cancelled' : 'received';
                              } else {
                                // If not received yet, show cancelled if document is cancelled, otherwise pending
                                stepStatus = isDocumentCancelled ? 'cancelled' : 'pending';
                              }
                            }

                            const isCancelledAtSource =
                              isFirst && displayStatus === 'cancelled';

                            return (
                              <Box key={index}>
                                <Box sx={{ display: 'flex', alignItems: 'flex-start' }}>
                                  <Box
                                    sx={{
                                      mt: 0.75,
                                      mr: 1.5,
                                      width: 10,
                                      height: 10,
                                      borderRadius: '50%',
                                      bgcolor: isCancelledAtSource
                                        ? 'error.main'
                                        : isFirst
                                          ? theme.palette.mode === 'dark' ? 'grey.400' : 'grey.700'
                                          : isLast
                                            ? 'success.main'
                                            : 'info.main',
                                    }}
                                  />
                                  <Box sx={{ flex: 1 }}>
                                    <Typography variant="body2" fontWeight="medium">
                                      {step.department_name || 'Unknown Department'}{' '}
                                      <Typography component="span" variant="body2" color="text.secondary">
                                        ({isFirst ? 'Source' : (step.was_received || step.action === 'received') ? 'Received' : isLast ? 'Destination' : 'Forwarded'})
                                      </Typography>
                                    </Typography>

                                    <Box sx={{ ml: 3, mt: 0.5, borderLeft: `2px dotted ${theme.palette.divider}`, pl: 2 }}>
                                      <Typography variant="caption" color="text.secondary" display="block" sx={{ mb: 0.5, fontSize: '0.8rem' }}>
                                        • {isFirst ? 'Created on:' : (step.was_received || step.action === 'received' ? 'Received on:' : 'Forwarded on:')}{' '}
                                        {step.timestamp ? formatDate(step.timestamp) : 'Unknown'}
                                      </Typography>

                                      {/* Show user name only for created (first step) or received steps, not for pending */}
                                      {(isFirst || step.was_received || step.action === 'received') && (
                                        <Typography variant="caption" color="text.secondary" display="block" sx={{ mb: 0.5, fontSize: '0.8rem' }}>
                                          • {isFirst ? 'Created by:' : 'Received by:'}{' '}
                                          <Box
                                            component="span"
                                            sx={{
                                              color: isCancelledAtSource
                                                ? theme.palette.error.main
                                                : isFirst
                                                  ? theme.palette.primary.main
                                                  : isLast
                                                    ? theme.palette.success.main
                                                    : theme.palette.info.main,
                                              fontWeight: 500
                                            }}
                                          >
                                            {step.user_name || 'System User'}
                                          </Box>
                                        </Typography>
                                      )}

                                      {stepStatus && (
                                        <Box component="span" sx={{ display: 'block', mt: 0.5 }}>
                                          <Typography variant="caption" color="text.secondary" component="span" sx={{ fontSize: '0.8rem' }}>
                                            • Status:{' '}
                                          </Typography>
                                          <Chip
                                            label={stepStatus.charAt(0).toUpperCase() + stepStatus.slice(1)}
                                            color={getStatusColor(stepStatus)}
                                            size="small"
                                            sx={{
                                              textTransform: 'capitalize',
                                              fontSize: '0.7rem',
                                              fontWeight: 500,
                                              verticalAlign: 'middle',
                                            }}
                                          />
                                        </Box>
                                      )}

                                      {/* show cancellation note right under source */}
                                      {isCancelledAtSource && (
                                        <Box
                                          sx={{
                                            mt: 1.5,
                                            p: 2,
                                            bgcolor: 'error.main',
                                            borderRadius: 2,
                                            color: 'error.contrastText',
                                            boxShadow: theme.palette.mode === 'dark' ? '0 2px 6px rgba(0,0,0,0.5)' : '0 2px 6px rgba(0,0,0,0.2)',
                                            border: `1px solid ${theme.palette.error.dark}`,
                                          }}
                                        >
                                          <Typography
                                            variant="subtitle2"
                                            sx={{
                                              display: 'flex',
                                              alignItems: 'center',
                                              gap: 1,
                                              fontWeight: 'bold',
                                            }}
                                          >
                                            ❌ Cancelled by: {dynamicRoutingData.document.canceled_by || 'Unknown User'}
                                          </Typography>

                                          <Typography
                                            variant="body2"
                                            sx={{ mt: 0.5, fontStyle: 'italic', color: 'error.contrastText' }}
                                          >
                                            Reason:&nbsp;
                                            {dynamicRoutingData.document.cancel_note || 'No reason provided.'}
                                          </Typography>

                                          {dynamicRoutingData.document.canceled_at && (
                                            <Typography
                                              variant="caption"
                                              sx={{ mt: 0.5, display: 'block', opacity: 0.9, color: 'error.contrastText' }}
                                            >
                                              Date: {new Date(dynamicRoutingData.document.canceled_at).toLocaleString()}
                                            </Typography>
                                          )}
                                        </Box>
                                      )}
                                    </Box>
                                  </Box>
                                </Box>
                                {!isLast && (
                                  <Box
                                    sx={{
                                      ml: 1.9,
                                      my: 1.2,
                                      borderLeft: `2px dotted ${theme.palette.divider}`,
                                      height: 20,
                                    }}
                                  />
                                )}
                              </Box>
                            );
                          })}

                          {/* ✅ Show Cancellation Details at the End */}
                          {getDisplayStatus(selectedDoc) === 'cancelled' && (
                            <>
                              <Box
                                sx={{
                                  my: 2,
                                  borderTop: '2px solid',
                                  borderColor: 'error.main',
                                  opacity: 0.4,
                                }}
                              />

                              <Box
                                sx={{
                                  mt: 2,
                                  p: 2.5,
                                  bgcolor: 'error.main',
                                  borderRadius: 2,
                                  color: 'error.contrastText',
                                  border: `1px solid ${theme.palette.error.dark}`,
                                  boxShadow: theme.palette.mode === 'dark' ? '0 2px 6px rgba(0,0,0,0.5)' : '0 2px 6px rgba(0,0,0,0.2)',
                                }}
                              >
                                <Typography
                                  variant="subtitle1"
                                  sx={{
                                    fontWeight: 'bold',
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: 1,
                                  }}
                                >
                                  ❌ Cancelled by{' '}
                                  {selectedDoc.canceled_by_name || 'Unknown User'}
                                </Typography>

                                <Typography variant="body2" sx={{ mt: 1, color: 'error.contrastText' }}>
                                  <strong>Reason:</strong>{' '}
                                  {selectedDoc.cancel_note || 'No reason provided.'}
                                </Typography>

                                {selectedDoc.canceled_at && (
                                  <Typography
                                    variant="caption"
                                    sx={{
                                      mt: 0.75,
                                      display: 'block',
                                      opacity: 0.9,
                                      color: 'error.contrastText',
                                    }}
                                  >
                                    Date:{' '}
                                    {new Date(selectedDoc.canceled_at).toLocaleString()}
                                  </Typography>
                                )}
                              </Box>
                            </>
                          )}
                        </Box>
                      </Box>
                    ) : (
                      <Box
                        sx={{
                          mt: 2,
                          p: 3,
                          bgcolor: 'warning.light',
                          borderRadius: 2,
                          border: '1px solid',
                          borderColor: 'warning.main',
                        }}
                      >
                        <Typography variant="body2" color="warning.contrastText" sx={{ fontSize: '0.95rem' }}>
                          No routing history available.
                        </Typography>
                      </Box>
                    )}
                  </Box>
                )}
              </Box>
            </Box>
          )}
        </DialogContent>
      </Dialog>
    </Box>
  );
};

export default DepartmentDocuments;
