import React from 'react';
import { Box, Typography, Chip } from '@mui/material';
import ArrowDownwardIcon from '@mui/icons-material/ArrowDownward';

const formatDate = (date) =>
  date ? new Date(date).toLocaleString() : '—';

const statusColor = (status) => {
  switch (status) {
    case 'created':
      return 'default';
    case 'received':
      return 'success';
    case 'forwarded':
      return 'info';
    case 'cancelled':
    case 'rejected':
      return 'error';
    default:
      return 'default';
  }
};

const DocumentTimeline = ({ document }) => {
  // ✅ Fallback-safe routing steps
  const steps =
    document.routing_history?.length > 0
      ? document.routing_history
      : [
          {
            status: 'created',
            department: document.upload_department_name,
            user: document.uploaded_by_name,
            date: document.uploaded_at,
          },
          document.received_at && {
            status: 'received',
            department: document.current_department_name,
            user: document.received_by_name,
            date: document.received_at,
          },
        ].filter(Boolean);

  return (
    <Box>
      <Typography variant="subtitle1" fontWeight="bold" mb={2}>
        Routing Timeline
      </Typography>

      {steps.map((step, index) => {
        const isLast = index === steps.length - 1;

        return (
          <Box key={index} display="flex" alignItems="flex-start" mb={3}>
            {/* LEFT: DOT → LINE → ARROW */}
            <Box
              mr={2}
              display="flex"
              flexDirection="column"
              alignItems="center"
            >
              {/* ● DOT */}
              <Box
                sx={{
                  width: 12,
                  height: 12,
                  borderRadius: '50%',
                  bgcolor: 'primary.main',
                }}
              />

              {/* │ LINE */}
              {!isLast && (
                <Box
                  sx={{
                    width: 2,
                    height: 50,
                    bgcolor: 'divider',
                  }}
                />
              )}

              {/* ⬇️ ARROW */}
              {!isLast && (
                <ArrowDownwardIcon
                  fontSize="small"
                  sx={{
                    color: 'text.disabled',
                    my: 0.1,
                  }}
                />
              )}
            </Box>

            {/* RIGHT: CONTENT */}
            <Box>
              <Box display="flex" alignItems="center" gap={1}>
                <Typography fontWeight="bold" variant="body2">
                  {step.department || 'System'}
                </Typography>
                <Chip
                  label={step.status}
                  size="small"
                  color={statusColor(step.status)}
                  sx={{ textTransform: 'capitalize' }}
                />
              </Box>

              <Typography
                variant="caption"
                color="text.secondary"
                display="block"
              >
                {formatDate(step.date)}
              </Typography>

              <Typography variant="caption" color="text.secondary">
                {step.user || 'System'}
              </Typography>
            </Box>
          </Box>
        );
      })}
    </Box>
  );
};

export default DocumentTimeline;
