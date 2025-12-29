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
  FormControlLabel,
  Checkbox,
  Divider,
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

// Light theme for login page
const lightTheme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#4a5d23',
    },
    background: {
      default: '#f5f5f5',
      paper: '#ffffff',
    },
  },
});

const Login = () => {
  const navigate = useNavigate();
  const { login } = useAuth();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    const result = await login(email, password, rememberMe);
    if (!result.success) setError(result.message);

    setLoading(false);
  };

  return (
    <ThemeProvider theme={lightTheme}>
      <Box
        sx={{
          height: '100vh',
          width: '100vw',
          overflow: 'hidden',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          position: 'fixed',
          inset: 0,
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        }}
      >
        <Container maxWidth="md">
          <Paper
            elevation={10}
            sx={{
              p: { xs: 3, md: 4 },
              borderRadius: 3,
            }}
          >
            <Box
              sx={{
                display: 'grid',
                gridTemplateColumns: { xs: '1fr', md: '1fr 1px 1fr' },
                gap: 3,
                alignItems: 'stretch',
              }}
            >
              {/* LEFT — LOGIN FORM */}
              <Box>
                <Typography variant="h4" fontWeight="bold" color="primary" mb={1}>
                  Document Progress Tracking System
                </Typography>
                <Typography color="text.secondary" mb={3}>
                  Sign in to your account
                </Typography>

                {error && (
                  <Alert severity="error" sx={{ mb: 2 }}>
                    {error}
                  </Alert>
                )}

                <Box component="form" onSubmit={handleSubmit}>
                  <TextField
                    fullWidth
                    label="Email Address"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    margin="normal"
                    required
                  />

                  <TextField
                    fullWidth
                    label="Password"
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    margin="normal"
                    required
                  />

                  <FormControlLabel
                    control={
                      <Checkbox
                        checked={rememberMe}
                        onChange={(e) => setRememberMe(e.target.checked)}
                      />
                    }
                    label="Remember Me"
                    sx={{ mt: 1 }}
                  />

                  <Button
                    type="submit"
                    fullWidth
                    variant="contained"
                    size="large"
                    disabled={loading}
                    sx={{
                      mt: 2,
                      py: 1.5,
                      borderRadius: 2,
                      textTransform: 'none',
                      fontWeight: 600,
                    }}
                  >
                    {loading ? 'Signing In...' : 'Sign In'}
                  </Button>
                </Box>

                <Box textAlign="center" mt={2}>
                  <Link
                    component="button"
                    onClick={() => navigate('/forgot-password')}
                    underline="hover"
                  >
                    Forgot password?
                  </Link>
                </Box>
              </Box>

              {/* DIVIDER */}
              <Divider orientation="vertical" flexItem sx={{ display: { xs: 'none', md: 'block' } }} />

              {/* RIGHT — DEMO CREDENTIALS */}
              <Box>
                <Typography
                  variant="subtitle2"
                  color="text.secondary"
                  fontWeight={700}
                  mb={2}
                  textTransform="uppercase"
                  letterSpacing={1}
                >
                  Demo Credentials
                </Typography>

                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                  {[
                    ['Admin', 'admin@doctrack.com', 'password123'],
                    ['Staff', 'staff@doctrack.com', 'password123'],
                    ['Staff', 'barangan.jb.bscs@gmail.com', 'password123'],
                  ].map(([role, email, pass], index) => (
                    <Box
                      key={index}
                      sx={{
                        p: 2,
                        borderRadius: 2,
                        border: '1px solid',
                        borderColor: 'divider',
                        backgroundColor: 'grey.50',
                        fontFamily: 'monospace',
                        fontSize: '0.85rem',
                      }}
                    >
                      <Typography fontWeight={600} color="primary.main">
                        {role}
                      </Typography>
                      <Typography>{email}</Typography>
                      <Typography>{pass}</Typography>
                    </Box>
                  ))}
                </Box>
              </Box>
            </Box>
          </Paper>
        </Container>
      </Box>
    </ThemeProvider>
  );
};

export default Login;
