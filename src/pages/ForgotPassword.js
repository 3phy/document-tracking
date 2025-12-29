import React, { useEffect, useMemo, useState } from 'react';
import axios from 'axios';
import {
  Box,
  Button,
  Container,
  Paper,
  TextField,
  Typography,
  Alert,
  ThemeProvider,
  createTheme,
  Link,
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import API_BASE_URL from '../config/api';
import OtpInput from '../components/OtpInput';

const normalizeCooldownSeconds = (value, maxSeconds = 60) => {
  const n = Number(value);
  if (!Number.isFinite(n)) return 0;
  const i = Math.floor(n);
  return Math.max(0, Math.min(maxSeconds, i));
};

// Light theme for public auth pages
const lightTheme = createTheme({
  palette: {
    mode: 'light',
    primary: { main: '#4a5d23' },
    secondary: { main: '#f50057' },
    background: { default: '#f5f5f5', paper: '#ffffff' },
  },
});

const ForgotPassword = () => {
  const navigate = useNavigate();

  // 0=email, 1=otp, 2=new password, 3=done
  const [step, setStep] = useState(0);

  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [resetToken, setResetToken] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [info, setInfo] = useState('');
  const [resendIn, setResendIn] = useState(0);

  const canVerifyOtp = useMemo(() => otp.replace(/\D/g, '').length === 6, [otp]);

  useEffect(() => {
    // Tick countdown whenever we are in a cooldown window (step 0 or step 1)
    if (resendIn <= 0) return undefined;
    const t = setInterval(() => {
      setResendIn((s) => {
        const next = normalizeCooldownSeconds(s, 60);
        return next > 0 ? next - 1 : 0;
      });
    }, 1000);
    return () => clearInterval(t);
  }, [resendIn]);

  const requestOtp = async () => {
    setError('');
    setInfo('');
    setLoading(true);
    try {
      const res = await axios.post(`${API_BASE_URL}/auth/forgot-password/request-otp.php`, { email });
      if (!res.data?.success) {
        setError(res.data?.message || 'Failed to request OTP.');
        return;
      }
      setInfo(res.data?.message || 'OTP sent.');
      setStep(1);
      setResendIn(60);
    } catch (e) {
      const retryAfter =
        e?.response?.data?.errors?.retry_after_seconds ?? e?.response?.headers?.['retry-after'];
      const retryAfterSeconds = normalizeCooldownSeconds(retryAfter, 60);
      if (e?.response?.status === 429 && retryAfterSeconds > 0) {
        setResendIn(retryAfterSeconds);
        setError(`Please wait ${retryAfterSeconds}s before requesting another OTP.`);
      } else {
        setError(e?.response?.data?.message || 'Failed to request OTP. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  const verifyOtp = async () => {
    setError('');
    setInfo('');
    setLoading(true);
    try {
      const res = await axios.post(`${API_BASE_URL}/auth/forgot-password/verify-otp.php`, { email, otp });
      if (!res.data?.success) {
        setError(res.data?.message || 'OTP verification failed.');
        return;
      }
      setResetToken(res.data.reset_token);
      setStep(2);
      setInfo('OTP verified. Set your new password.');
    } catch (e) {
      setError(e?.response?.data?.message || 'OTP verification failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const resetPassword = async () => {
    setError('');
    setInfo('');
    if (newPassword.length < 8) {
      setError('Password must be at least 8 characters.');
      return;
    }
    if (newPassword !== confirmPassword) {
      setError('Passwords do not match.');
      return;
    }

    setLoading(true);
    try {
      const res = await axios.post(`${API_BASE_URL}/auth/forgot-password/reset-password.php`, {
        email,
        reset_token: resetToken,
        new_password: newPassword,
      });
      if (!res.data?.success) {
        setError(res.data?.message || 'Password reset failed.');
        return;
      }
      setStep(3);
      setInfo('Password reset successfully. You can now sign in.');
    } catch (e) {
      setError('Password reset failed. Please try again.');
    } finally {
      setLoading(false);
    }
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
              p: 4,
              borderRadius: 3,
              background: 'rgba(255, 255, 255, 0.95)',
              backdropFilter: 'blur(10px)',
            }}
          >
            <Box sx={{ textAlign: 'center', mb: 3 }}>
              <Typography variant="h5" fontWeight="bold" color="primary">
                Forgot Password
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
                Reset your password using an email OTP.
              </Typography>
            </Box>

            {(error || info) && (
              <Alert severity={error ? 'error' : 'info'} sx={{ mb: 2 }}>
                {error || info}
              </Alert>
            )}

            {step === 0 && (
              <>
                <TextField
                  fullWidth
                  label="Email Address"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  margin="normal"
                  required
                  autoFocus
                />
                <Button
                  fullWidth
                  variant="contained"
                  size="large"
                  disabled={loading || !email || resendIn > 0}
                  onClick={requestOtp}
                  sx={{ mt: 2, py: 1.5, borderRadius: 2 }}
                >
                  {loading ? 'Sending OTP...' : resendIn > 0 ? `Send OTP (${resendIn}s)` : 'Send OTP'}
                </Button>
              </>
            )}

            {step === 1 && (
              <>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 2, textAlign: 'center' }}>
                  Enter the 6-digit OTP sent to <b>{email}</b>
                </Typography>
                <OtpInput value={otp} onChange={setOtp} disabled={loading} />
                <Button
                  fullWidth
                  variant="contained"
                  size="large"
                  disabled={loading || !canVerifyOtp}
                  onClick={verifyOtp}
                  sx={{ mt: 2, py: 1.5, borderRadius: 2 }}
                >
                  {loading ? 'Verifying...' : 'Verify'}
                </Button>
                <Button
                  fullWidth
                  variant="text"
                  disabled={loading || resendIn > 0}
                  onClick={requestOtp}
                  sx={{ mt: 1 }}
                >
                  {resendIn > 0 ? `Resend OTP (${resendIn}s)` : 'Resend OTP'}
                </Button>
                <Button
                  fullWidth
                  variant="text"
                  disabled={loading}
                  onClick={() => {
                    setStep(0);
                    setOtp('');
                    setResendIn(0);
                  }}
                >
                  Change email
                </Button>
              </>
            )}

            {step === 2 && (
              <>
                <TextField
                  fullWidth
                  label="New Password"
                  type="password"
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  margin="normal"
                  required
                  autoFocus
                />
                <TextField
                  fullWidth
                  label="Confirm Password"
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  margin="normal"
                  required
                />
                <Button
                  fullWidth
                  variant="contained"
                  size="large"
                  disabled={loading}
                  onClick={resetPassword}
                  sx={{ mt: 2, py: 1.5, borderRadius: 2 }}
                >
                  {loading ? 'Resetting...' : 'Reset Password'}
                </Button>
              </>
            )}

            {step === 3 && (
              <>
                <Button
                  fullWidth
                  variant="contained"
                  size="large"
                  onClick={() => navigate('/login')}
                  sx={{ mt: 1, py: 1.5, borderRadius: 2 }}
                >
                  Back to Login
                </Button>
              </>
            )}

            <Box sx={{ mt: 3, textAlign: 'center' }}>
              <Link
                component="button"
                type="button"
                onClick={() => navigate('/login')}
                underline="hover"
                sx={{ fontSize: 14 }}
              >
                Back to Login
              </Link>
            </Box>
          </Paper>
        </Container>
      </Box>
    </ThemeProvider>
  );
};

export default ForgotPassword;


