import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Rnd } from 'react-rnd';
import { Box, Button, Paper, TextField, Typography } from '@mui/material';
import JsBarcode from 'jsbarcode';
import QRCode from 'qrcode';

const clamp = (n, min, max) => Math.max(min, Math.min(max, n));

/**
 * Movable (pixel-positioned) barcode + QR stamp constrained to its parent.
 * - Drag to move
 * - Arrow keys nudge by 1px (Shift = 10px)
 * - X/Y inputs allow exact pixel positioning
 * - Position persists via localStorage (optional)
 */
const MovableBarcodeQrStamp = ({
  value,
  title = 'Barcode / QR',
  storageKey,
  defaultPosition = { x: 16, y: 16 },
  defaultAnchor = 'topLeft', // 'topLeft' | 'topRight' | 'bottomLeft' | 'bottomRight'
  anchorMargin = 16,
  size = { width: 320, height: 210 },
  disabled = false,
}) => {
  const barcodeCanvasRef = useRef(null);
  const qrCanvasRef = useRef(null);
  const containerRef = useRef(null);

  const [hasStoredPos, setHasStoredPos] = useState(false);

  const initialPos = useMemo(() => {
    if (!storageKey) return defaultPosition;
    try {
      const raw = localStorage.getItem(storageKey);
      if (!raw) return defaultPosition;
      const parsed = JSON.parse(raw);
      if (typeof parsed?.x === 'number' && typeof parsed?.y === 'number') return parsed;
      return defaultPosition;
    } catch {
      return defaultPosition;
    }
  }, [storageKey, defaultPosition]);

  const [pos, setPos] = useState(initialPos);

  // If the caller changes storageKey/value (new doc), rehydrate position.
  useEffect(() => {
    setPos(initialPos);
    if (!storageKey) {
      setHasStoredPos(false);
      return;
    }
    try {
      const raw = localStorage.getItem(storageKey);
      setHasStoredPos(Boolean(raw));
    } catch {
      setHasStoredPos(false);
    }
  }, [initialPos]);

  useEffect(() => {
    if (!value) return;

    if (barcodeCanvasRef.current) {
      try {
        JsBarcode(barcodeCanvasRef.current, String(value), {
          format: 'CODE128',
          width: 2,
          height: 60,
          displayValue: true,
          fontSize: 12,
          margin: 6,
        });
      } catch (e) {
        // Avoid crashing preview if barcode fails for some values
        // eslint-disable-next-line no-console
        console.error('Barcode generation error:', e);
      }
    }

    if (qrCanvasRef.current) {
      QRCode.toCanvas(qrCanvasRef.current, String(value), { width: 96, margin: 1 }).catch((e) => {
        // eslint-disable-next-line no-console
        console.error('QR generation error:', e);
      });
    }
  }, [value]);

  const persist = (next) => {
    if (!storageKey) return;
    try {
      localStorage.setItem(storageKey, JSON.stringify(next));
    } catch {
      // ignore
    }
  };

  const setPosAndPersist = (next) => {
    setPos(next);
    persist(next);
  };

  // If there's no saved position, anchor the stamp inside the parent once we can measure it.
  useEffect(() => {
    if (disabled) return;
    if (hasStoredPos) return;
    if (!containerRef.current?.parentElement) return;

    const parent = containerRef.current.parentElement.getBoundingClientRect();
    const maxX = Math.max(0, Math.floor(parent.width - size.width));
    const maxY = Math.max(0, Math.floor(parent.height - size.height));

    const anchored = (() => {
      switch (defaultAnchor) {
        case 'topRight':
          return { x: clamp(maxX - anchorMargin, 0, maxX), y: clamp(anchorMargin, 0, maxY) };
        case 'bottomLeft':
          return { x: clamp(anchorMargin, 0, maxX), y: clamp(maxY - anchorMargin, 0, maxY) };
        case 'bottomRight':
          return { x: clamp(maxX - anchorMargin, 0, maxX), y: clamp(maxY - anchorMargin, 0, maxY) };
        case 'topLeft':
        default:
          return { x: clamp(anchorMargin, 0, maxX), y: clamp(anchorMargin, 0, maxY) };
      }
    })();

    setPosAndPersist(anchored);
  }, [disabled, hasStoredPos, defaultAnchor, anchorMargin, size.width, size.height, storageKey]);

  const nudge = (dx, dy) => {
    const bounds = containerRef.current?.parentElement?.getBoundingClientRect();
    if (!bounds) {
      setPosAndPersist({ x: pos.x + dx, y: pos.y + dy });
      return;
    }

    // Clamp to parent bounds (approx; Rnd will also enforce bounds on drag)
    const maxX = Math.max(0, Math.floor(bounds.width - size.width));
    const maxY = Math.max(0, Math.floor(bounds.height - size.height));
    setPosAndPersist({
      x: clamp(pos.x + dx, 0, maxX),
      y: clamp(pos.y + dy, 0, maxY),
    });
  };

  const handleKeyDown = (e) => {
    if (disabled) return;
    const step = e.shiftKey ? 10 : 1;

    switch (e.key) {
      case 'ArrowLeft':
        e.preventDefault();
        nudge(-step, 0);
        break;
      case 'ArrowRight':
        e.preventDefault();
        nudge(step, 0);
        break;
      case 'ArrowUp':
        e.preventDefault();
        nudge(0, -step);
        break;
      case 'ArrowDown':
        e.preventDefault();
        nudge(0, step);
        break;
      default:
        break;
    }
  };

  return (
    <Rnd
      bounds="parent"
      disableDragging={disabled}
      enableResizing={false}
      size={size}
      position={pos}
      onDragStop={(e, d) => setPosAndPersist({ x: Math.round(d.x), y: Math.round(d.y) })}
      style={{ zIndex: 20 }}
    >
      <Paper
        ref={containerRef}
        tabIndex={disabled ? -1 : 0}
        onKeyDown={disabled ? undefined : handleKeyDown}
        elevation={6}
        sx={{
          width: '100%',
          height: '100%',
          outline: 'none',
          border: disabled ? 'none' : '1px dashed rgba(0,0,0,0.35)',
          bgcolor: disabled ? 'transparent' : 'rgba(255,255,255,0.98)',
          p: 1,
          cursor: disabled ? 'default' : 'move',
          userSelect: 'none',
        }}
      >
        {!disabled && (
          <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 0.5 }}>
            <Typography variant="caption" sx={{ fontWeight: 700 }}>
              {title}
            </Typography>
            <Typography variant="caption" color="text.secondary">
              X:{pos.x}px Y:{pos.y}px
            </Typography>
          </Box>
        )}

        <Box sx={{ display: 'flex', gap: 1 }}>
          <Box sx={{ flex: 1, minWidth: 0 }}>
            <canvas ref={barcodeCanvasRef} style={{ width: '100%', height: 'auto' }} />
          </Box>
          <Box sx={{ width: 110, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <canvas ref={qrCanvasRef} />
          </Box>
        </Box>

        {!disabled && (
          <Box sx={{ display: 'flex', gap: 1, mt: 0.75, alignItems: 'center' }}>
            <TextField
              label="X"
              size="small"
              value={pos.x}
              onChange={(e) => {
                const nextX = Number(e.target.value);
                if (Number.isFinite(nextX)) setPosAndPersist({ x: Math.round(nextX), y: pos.y });
              }}
              inputProps={{ inputMode: 'numeric' }}
              sx={{ width: 90 }}
            />
            <TextField
              label="Y"
              size="small"
              value={pos.y}
              onChange={(e) => {
                const nextY = Number(e.target.value);
                if (Number.isFinite(nextY)) setPosAndPersist({ x: pos.x, y: Math.round(nextY) });
              }}
              inputProps={{ inputMode: 'numeric' }}
              sx={{ width: 90 }}
            />
            <Button size="small" variant="outlined" onClick={() => setPosAndPersist(defaultPosition)}>
              Reset
            </Button>
            <Typography variant="caption" color="text.secondary" sx={{ ml: 'auto' }}>
              Drag or use arrows (Shift=10px)
            </Typography>
          </Box>
        )}
      </Paper>
    </Rnd>
  );
};

export default MovableBarcodeQrStamp;


