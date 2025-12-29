import React from 'react';
import { Box, Typography, CircularProgress } from '@mui/material';

const LoadingScreen = ({ status = 'Initializing system...' }) => {
  return (
    <Box
      sx={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        zIndex: 9999,
      }}
    >
      <Box
        sx={{
          textAlign: 'center',
          color: 'white',
        }}
      >
        <Typography
          variant="h4"
          component="h1"
          gutterBottom
          sx={{
            fontWeight: 'bold',
            mb: 4,
            fontSize: { xs: '1.75rem', sm: '2.5rem' },
          }}
        >
          Document Tracking System
        </Typography>
        
        <CircularProgress
          size={60}
          thickness={4}
          sx={{
            color: 'white',
            mb: 3,
          }}
        />
        
        <Typography
          variant="body1"
          sx={{
            fontSize: '1.1rem',
            fontWeight: 500,
            opacity: 0.9,
          }}
        >
          {status}
        </Typography>
      </Box>
    </Box>
  );
};

export default LoadingScreen;

