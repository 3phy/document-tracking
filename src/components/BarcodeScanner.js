import React, { useState, useRef, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Box,
  Typography,
  Alert,
} from '@mui/material';
import { Html5Qrcode } from 'html5-qrcode';

const BarcodeScanner = ({ open, onClose, onScan, title = "Scan Document Barcode" }) => {
  const [error, setError] = useState('');
  const [manualInput, setManualInput] = useState('');
  const [scanMode, setScanMode] = useState(null); // null | 'camera' | 'manual'
  const [scanning, setScanning] = useState(false);
  const scannerRef = useRef(null);
  const html5QrCode = useRef(null);

  // Initialize and cleanup camera
  useEffect(() => {
    if (scanMode === 'camera' && open) {
      const startScanner = async () => {
        try {
          setError('');
          const cameraList = await Html5Qrcode.getCameras();
          if (!cameraList.length) {
            setError('No camera device found.');
            return;
          }

          html5QrCode.current = new Html5Qrcode('qr-reader');
          setScanning(true);

          await html5QrCode.current.start(
            { facingMode: 'environment' },
            { fps: 10, qrbox: { width: 250, height: 250 } },
            (decodedText) => {
              stopScanner();
              onScan(decodedText);
            },
            (scanError) => {
              // Ignore read errors, only log to console
              console.log('Scan error:', scanError);
            }
          );
        } catch (err) {
          console.error(err);
          setError('Camera access error: ' + err.message);
          stopScanner();
        }
      };

      startScanner();
    }

    // Cleanup on close or mode change
    return () => stopScanner();
  }, [scanMode, open]);

  const stopScanner = async () => {
    if (html5QrCode.current && scanning) {
      try {
        await html5QrCode.current.stop();
        await html5QrCode.current.clear();
      } catch (err) {
        console.warn('Stop scanner warning:', err.message);
      } finally {
        html5QrCode.current = null;
        setScanning(false);
      }
    }
  };

  const handleManualSubmit = () => {
    if (manualInput.trim()) {
      onScan(manualInput.trim());
      setManualInput('');
    } else {
      setError('Please enter a valid QR or barcode.');
    }
  };

  const handleClose = () => {
    stopScanner();
    setError('');
    setManualInput('');
    setScanMode(null);
    onClose();
  };

  const handleModeSelect = (mode) => {
    stopScanner();
    setScanMode(mode);
    setError('');
    if (mode === 'manual') {
      setTimeout(() => {
        const input = document.querySelector('input[placeholder="Paste or type the QR code here"]');
        if (input) input.focus();
      }, 150);
    }
  };

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
      <DialogTitle>{title}</DialogTitle>
      <DialogContent>
        <Box sx={{ textAlign: 'center', mb: 3 }}>
          {/* Default menu */}
          {!scanMode ? (
            <Box>
              <Typography variant="h6" gutterBottom>
                Choose Scanning Method
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                Select how you want to scan the document barcode
              </Typography>

              <Box sx={{ display: 'flex', gap: 3, justifyContent: 'center', flexWrap: 'wrap' }}>
                <Button
                  variant="contained"
                  size="large"
                  onClick={() => handleModeSelect('camera')}
                  sx={{
                    minWidth: 180,
                    height: 100,
                    flexDirection: 'column',
                    gap: 1,
                    borderRadius: 2,
                    boxShadow: 3,
                    '&:hover': {
                      boxShadow: 6,
                      transform: 'translateY(-2px)',
                      transition: 'all 0.2s ease-in-out',
                    },
                  }}
                >
                  <span style={{ fontSize: '2rem' }}>📷</span>
                  <Typography variant="h6" fontWeight="bold">
                    Camera Scan
                  </Typography>
                  <Typography variant="caption" sx={{ opacity: 0.8 }}>
                    Use device camera to scan QR or barcode
                  </Typography>
                </Button>

                <Button
                  variant="outlined"
                  size="large"
                  onClick={() => handleModeSelect('manual')}
                  sx={{
                    minWidth: 180,
                    height: 100,
                    flexDirection: 'column',
                    gap: 1,
                    borderRadius: 2,
                    borderWidth: 2,
                    '&:hover': {
                      borderWidth: 3,
                      transform: 'translateY(-2px)',
                      transition: 'all 0.2s ease-in-out',
                    },
                  }}
                >
                  <span style={{ fontSize: '2rem' }}>⌨️</span>
                  <Typography variant="h6" fontWeight="bold">
                    Manual Input
                  </Typography>
                  <Typography variant="caption" sx={{ opacity: 0.8 }}>
                    Type or paste the barcode manually
                  </Typography>
                </Button>
              </Box>
            </Box>
          ) : scanMode === 'camera' ? (
            // Camera scanning
            <Box>
              <Typography variant="body1" gutterBottom>
                Position the barcode/QR code within the camera view
              </Typography>
              <Box
                ref={scannerRef}
                id="qr-reader"
                sx={{
                  width: '100%',
                  maxWidth: 400,
                  height: 300,
                  mx: 'auto',
                  mb: 2,
                  border: '2px dashed #888',
                  borderRadius: 2,
                }}
              />
              <Button variant="outlined" onClick={() => handleModeSelect(null)} sx={{ mb: 2 }}>
                ← Back to Options
              </Button>
            </Box>
          ) : (
            // Manual input
            <Box>
              <Typography variant="body1" gutterBottom>
                Enter the barcode or QR code manually
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                Type or paste the code below
              </Typography>

              <TextField
                fullWidth
                label="Enter Code"
                value={manualInput}
                onChange={(e) => setManualInput(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleManualSubmit()}
                autoFocus
                placeholder="Paste or type the QR code here"
                sx={{ mb: 2 }}
              />

              <Button variant="outlined" onClick={() => handleModeSelect(null)} sx={{ mb: 2 }}>
                ← Back to Options
              </Button>
            </Box>
          )}

          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {error}
            </Alert>
          )}
        </Box>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose}>Cancel</Button>
        {scanMode === 'manual' && (
          <Button onClick={handleManualSubmit} variant="contained" disabled={!manualInput.trim()}>
            Submit
          </Button>
        )}
      </DialogActions>
    </Dialog>
  );
};

export default BarcodeScanner;
