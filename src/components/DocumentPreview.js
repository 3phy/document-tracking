import React from 'react';
import { Box, Typography } from '@mui/material';

const DocumentPreview = ({ fileUrl, fileType }) => {
  if (!fileUrl) {
    return (
      <Box
        sx={{
          height: '100%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: 'text.secondary',
        }}
      >
        No preview available
      </Box>
    );
  }

  // 🖼 IMAGE
  if (['jpg', 'jpeg', 'png', 'webp'].includes(fileType)) {
    return (
      <Box
        component="img"
        src={fileUrl}
        alt="Document Preview"
        sx={{
          maxWidth: '100%',
          maxHeight: '100%',
          objectFit: 'contain',
        }}
      />
    );
  }

  // 📄 PDF
  if (fileType === 'pdf') {
    return (
      <iframe
        src={fileUrl}
        title="PDF Preview"
        width="100%"
        height="100%"
        style={{ border: 'none' }}
      />
    );
  }

  // 📝 DOCX / XLSX / PPTX → Google Viewer
  if (['docx', 'xlsx', 'pptx'].includes(fileType)) {
    return (
      <iframe
        src={`https://docs.google.com/gview?url=${encodeURIComponent(
          fileUrl
        )}&embedded=true`}
        title="Document Preview"
        width="100%"
        height="100%"
        style={{ border: 'none' }}
      />
    );
  }

  // ❓ FALLBACK
  return (
    <Typography color="text.secondary">
      Preview not supported for this file type.
    </Typography>
  );
};

export default DocumentPreview;
