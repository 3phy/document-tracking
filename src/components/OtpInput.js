import React, { useEffect, useMemo, useRef } from 'react';
import { Box, TextField } from '@mui/material';

/**
 * Reusable OTP input (default 6 digits).
 *
 * Props:
 * - length: number (default 6)
 * - value: string (digits only)
 * - onChange: (nextValue: string) => void
 * - disabled: boolean
 */
const OtpInput = ({ length = 6, value, onChange, disabled = false }) => {
  const inputsRef = useRef([]);

  const digits = useMemo(() => {
    const clean = (value || '').replace(/\D/g, '').slice(0, length);
    return Array.from({ length }, (_, i) => clean[i] || '');
  }, [value, length]);

  useEffect(() => {
    inputsRef.current = inputsRef.current.slice(0, length);
  }, [length]);

  const focusIndex = (idx) => {
    const el = inputsRef.current[idx];
    if (el) el.focus();
  };

  const setAt = (idx, char) => {
    const cleanChar = (char || '').replace(/\D/g, '').slice(-1);
    const next = [...digits];
    next[idx] = cleanChar;
    const nextValue = next.join('');
    onChange(nextValue);
  };

  const handleChange = (idx) => (e) => {
    const raw = e.target.value;
    const clean = raw.replace(/\D/g, '');

    // If user typed/pasted multiple digits into one box, spread them forward
    if (clean.length > 1) {
      const next = [...digits];
      let cursor = idx;
      clean.split('').forEach((c) => {
        if (cursor < length) {
          next[cursor] = c;
          cursor += 1;
        }
      });
      onChange(next.join(''));
      focusIndex(Math.min(cursor, length - 1));
      return;
    }

    setAt(idx, clean);
    if (clean && idx < length - 1) focusIndex(idx + 1);
  };

  const handleKeyDown = (idx) => (e) => {
    if (e.key === 'Backspace') {
      if (digits[idx]) {
        setAt(idx, '');
        return;
      }
      if (idx > 0) {
        focusIndex(idx - 1);
        setAt(idx - 1, '');
      }
    }
    if (e.key === 'ArrowLeft' && idx > 0) focusIndex(idx - 1);
    if (e.key === 'ArrowRight' && idx < length - 1) focusIndex(idx + 1);
  };

  const handlePaste = (idx) => (e) => {
    e.preventDefault();
    const paste = (e.clipboardData.getData('text') || '').replace(/\D/g, '');
    if (!paste) return;
    const next = [...digits];
    let cursor = idx;
    paste.split('').forEach((c) => {
      if (cursor < length) {
        next[cursor] = c;
        cursor += 1;
      }
    });
    onChange(next.join(''));
    focusIndex(Math.min(cursor, length - 1));
  };

  return (
    <Box sx={{ display: 'flex', gap: 1.25, justifyContent: 'center' }}>
      {digits.map((d, idx) => (
        <TextField
          key={idx}
          inputRef={(el) => (inputsRef.current[idx] = el)}
          value={d}
          onChange={handleChange(idx)}
          onKeyDown={handleKeyDown(idx)}
          onPaste={handlePaste(idx)}
          disabled={disabled}
          inputProps={{
            inputMode: 'numeric',
            pattern: '[0-9]*',
            maxLength: 1,
            style: { textAlign: 'center', fontSize: 18, fontWeight: 700 },
          }}
          sx={{ width: 48 }}
        />
      ))}
    </Box>
  );
};

export default OtpInput;


