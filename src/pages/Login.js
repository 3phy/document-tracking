import React, { useState } from 'react';
import {
  Box,
  TextField,
  Button,
  Typography,
  Alert,
  Container,
  Paper,
  ThemeProvider,
  createTheme,
  Link,
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

// Light theme for login page (always light mode)
const lightTheme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#4a5d23',
      light: '#6b8e23',
      dark: '#2d3d1a',
    },
    secondary: {
      main: '#f50057',
      light: '#ff5983',
      dark: '#c51162',
    },
    background: {
      default: '#f5f5f5',
      paper: '#ffffff',
    },
    text: {
      primary: '#333333',
      secondary: '#666666',
    },
  },
});

const Login = () => {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    const result = await login(email, password);
    
    if (!result.success) {
      setError(result.message);
    }
    
    setLoading(false);
  };

  return (
    <ThemeProvider theme={lightTheme}>
      <Box
        sx={{
          minHeight: '100vh',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          p: 2,
        }}
      >
        <Container maxWidth="sm">
          <Paper
            elevation={10}
            sx={{
              p: { xs: 3, sm: 4, md: 5 },
              borderRadius: 3,
              background: 'rgba(255, 255, 255, 0.95)',
              backdropFilter: 'blur(10px)',
            }}
          >
            <Box sx={{ textAlign: 'center', mb: 5 }}>
              <Typography 
                variant="h4" 
                component="h1" 
                gutterBottom 
                color="primary" 
                fontWeight="bold"
                sx={{ mb: 1 }}
              >
                Document Progress Tracking System
              </Typography>
              <Typography 
                variant="h6" 
                color="text.secondary"
                sx={{ mb: 1.5, fontWeight: 400 }}
              >
                Document Tracking System
              </Typography>
              <Typography 
                variant="body2" 
                color="text.secondary"
                sx={{ mt: 1.5 }}
              >
                Sign in to access your account
              </Typography>
            </Box>

            {error && (
              <Alert 
                severity="error" 
                sx={{ 
                  mb: 3,
                  borderRadius: 2,
                  '& .MuiAlert-message': {
                    fontSize: '0.95rem',
                  }
                }}
              >
                {error}
              </Alert>
            )}

            <Box component="form" onSubmit={handleSubmit} sx={{ mb: 3 }}>
              <TextField
                fullWidth
                label="Email Address"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                margin="normal"
                required
                autoFocus
                sx={{ 
                  mb: 2.5,
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 2,
                  }
                }}
              />
              <TextField
                fullWidth
                label="Password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                margin="normal"
                required
                sx={{ 
                  mb: 3.5,
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 2,
                  }
                }}
              />
              <Button
                type="submit"
                fullWidth
                variant="contained"
                size="large"
                disabled={loading}
                sx={{
                  py: 1.75,
                  fontSize: '1rem',
                  fontWeight: 600,
                  borderRadius: 2,
                  textTransform: 'none',
                  letterSpacing: '0.5px',
                  background: 'linear-gradient(45deg, #4a5d23 30%, #f50057 90%)',
                  '&:hover': {
                    background: 'linear-gradient(45deg, #2d3d1a 30%, #c51162 90%)',
                  },
                  '&:disabled': {
                    background: 'rgba(0, 0, 0, 0.12)',
                  },
                }}
              >
                {loading ? 'Signing In...' : 'Sign In'}
              </Button>
            </Box>

            <Box sx={{ mt: 3, textAlign: 'center' }}>
              <Link
                component="button"
                type="button"
                onClick={() => navigate('/forgot-password')}
                underline="hover"
                sx={{ 
                  fontSize: '0.9rem',
                  fontWeight: 500,
                  color: 'primary.main',
                  '&:hover': {
                    color: 'primary.dark',
                  }
                }}
              >
                Forgot password?
              </Link>
            </Box>

            <Box 
              sx={{ 
                mt: 4, 
                pt: 3,
                borderTop: '1px solid',
                borderColor: 'divider',
                textAlign: 'center' 
              }}
            >
              <Typography 
                variant="body2" 
                color="text.secondary"
                sx={{ 
                  mb: 2,
                  fontWeight: 600,
                  fontSize: '0.85rem',
                  textTransform: 'uppercase',
                  letterSpacing: '0.5px'
                }}
              >
                Demo Credentials
              </Typography>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1.5 }}>
                <Typography 
                  variant="body2" 
                  color="text.secondary"
                  sx={{ 
                    fontSize: '0.875rem',
                    fontFamily: 'monospace',
                    bgcolor: 'grey.50',
                    p: 1.5,
                    borderRadius: 1.5,
                    border: '1px solid',
                    borderColor: 'divider'
                  }}
                >
                  <Box component="span" sx={{ fontWeight: 600, color: 'primary.main' }}>Admin:</Box> admin@doctrack.com / password123
                </Typography>
                <Typography 
                  variant="body2" 
                  color="text.secondary"
                  sx={{ 
                    fontSize: '0.875rem',
                    fontFamily: 'monospace',
                    bgcolor: 'grey.50',
                    p: 1.5,
                    borderRadius: 1.5,
                    border: '1px solid',
                    borderColor: 'divider'
                  }}
                >
                  <Box component="span" sx={{ fontWeight: 600, color: 'primary.main' }}>Staff:</Box> staff@doctrack.com / password123
                </Typography>
                <Typography 
                  variant="body2" 
                  color="text.secondary"
                  sx={{ 
                    fontSize: '0.875rem',
                    fontFamily: 'monospace',
                    bgcolor: 'grey.50',
                    p: 1.5,
                    borderRadius: 1.5,
                    border: '1px solid',
                    borderColor: 'divider'
                  }}
                >
                  <Box component="span" sx={{ fontWeight: 600, color: 'primary.main' }}>Staff:</Box> barangan.jb.bscs@gmail.com / password123
                </Typography>
              </Box>
            </Box>
          </Paper>
        </Container>
      </Box>
    </ThemeProvider>
  );
};

export default Login;
