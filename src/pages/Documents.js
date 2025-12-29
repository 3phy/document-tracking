import React, { useState, useEffect } from 'react';
import { Visibility as VisibilityIcon, Print as PrintIcon } from '@mui/icons-material';

import {
    Box,
    Typography,
    Button,
    Card,
    CardContent,
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    Chip,
    IconButton,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    TextField,
    Alert,
    CircularProgress,
    Tooltip,
    InputAdornment,
    LinearProgress,
    Menu,
    MenuItem,
    ListItemIcon,
    ListItemText,
    FormControlLabel,
    Checkbox,
    FormGroup,
    FormControl,
    FormLabel,
} from '@mui/material';
import {
    Add as AddIcon,
    Upload as UploadIcon,
    QrCodeScanner as ScannerIcon,
    Download as DownloadIcon,
    Visibility as ViewIcon,
    QrCode as QrCodeIcon,
    Forward as ForwardIcon,
    Search as SearchIcon,
    Cancel as CancelIcon,
    MoreVert as MoreVertIcon,
    ContentCopy as ContentCopyIcon,
    Error as ErrorIcon,
} from '@mui/icons-material';
import { useTheme } from '@mui/material/styles';
import { useAuth } from '../contexts/AuthContext';
import axios from 'axios';
import API_BASE_URL from '../config/api';
import BarcodeGenerator from '../components/BarcodeGenerator';
import BarcodeScanner from '../components/BarcodeScanner';

const Documents = () => {
    const theme = useTheme();
    const { user } = useAuth();
    const [documents, setDocuments] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [uploadDialogOpen, setUploadDialogOpen] = useState(false);
    const [scannerDialogOpen, setScannerDialogOpen] = useState(false);
    const [barcodeDialogOpen, setBarcodeDialogOpen] = useState(false);
    const [selectedDocument, setSelectedDocument] = useState(null);
    const [uploadData, setUploadData] = useState({
        description: '',
        department_ids: [], // Changed to array for multi-select
        files: [], // Changed to array for multiple files
        fileTitles: {}, // Object mapping file index to title for individual file titles
    });
    const [dragActive, setDragActive] = useState(false);
    const [departments, setDepartments] = useState([]);
    const [successMessage, setSuccessMessage] = useState('');
    const [routingInfo, setRoutingInfo] = useState([]);
    const [routingDialogOpen, setRoutingDialogOpen] = useState(false);
    const [selectedDocumentForRouting, setSelectedDocumentForRouting] = useState(null);
    const [errorDialogOpen, setErrorDialogOpen] = useState(false);
    const [dynamicRoutingData, setDynamicRoutingData] = useState(null);
    const [forwardDialogOpen, setForwardDialogOpen] = useState(false);
    const [selectedDocumentForForward, setSelectedDocumentForForward] = useState(null);
    const [forwardSearchTerm, setForwardSearchTerm] = useState('');
    const [forwardingStatus, setForwardingStatus] = useState('');
    const [cancelDialogOpen, setCancelDialogOpen] = useState(false);
    const [selectedDocumentForCancel, setSelectedDocumentForCancel] = useState(null);
    const [cancellingStatus, setCancellingStatus] = useState('');
    const [cancelNote, setCancelNote] = useState('');
    const [actionMenuAnchor, setActionMenuAnchor] = useState(null);
    const [selectedDocumentForAction, setSelectedDocumentForAction] = useState(null);
    const [previewDialogOpen, setPreviewDialogOpen] = useState(false);
    const [previewDocument, setPreviewDocument] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');
    const [availableDepartmentsForForward, setAvailableDepartmentsForForward] = useState([]);


    useEffect(() => {
        fetchDocuments();
        fetchRoutingInfo();
    }, [user]);

    useEffect(() => {
        if (user) {
            fetchDepartments();
        }
    }, [user]);

    useEffect(() => {
        if (error) setErrorDialogOpen(true);
    }, [error]);

    const fetchDocuments = async () => {
        try {
            const token = localStorage.getItem('token');
            const response = await axios.get(`${API_BASE_URL}/documents/list.php`, {
                headers: { Authorization: `Bearer ${token}` }
            });
            if (response.data.success) {
                setDocuments(response.data.documents);
            } else {
                setError('Failed to load documents');
            }
        } catch (error) {
            setError('Failed to load documents');
        } finally {
            setLoading(false);
        }
    };

    const fetchDepartments = async () => {
        try {
            const token = localStorage.getItem('token');
            const response = await axios.get(`${API_BASE_URL}/departments/list.php`, {
                headers: { Authorization: `Bearer ${token}` }
            });

            if (response.data.success) {
                // Filter out user's own department by default
                const userDeptId = user?.department_id;
                const filteredDepts = userDeptId 
                    ? response.data.departments.filter(dept => dept.id != userDeptId)
                    : response.data.departments;
                setDepartments(filteredDepts);
            }
        } catch (error) {
            // Silently fail - departments not critical
        }
    };

    const fetchRoutingInfo = async () => {
        try {
            const token = localStorage.getItem('token');
            const response = await axios.get(`${API_BASE_URL}/documents/routing.php`, {
                headers: { Authorization: `Bearer ${token}` }
            });

            if (response.data.success) {
                setRoutingInfo(response.data.routing_info || []);
            }
        } catch (error) {
            // Set empty routing info on error
            setRoutingInfo([]);
        }
    };

    const handleFileUpload = (event) => {
        const files = Array.from(event.target.files || []);
        if (files.length > 0) {
            addFiles(files);
        }
    };

    const handleDrag = (e) => {
        e.preventDefault();
        e.stopPropagation();
        if (e.type === "dragenter" || e.type === "dragover") {
            setDragActive(true);
        } else if (e.type === "dragleave") {
            setDragActive(false);
        }
    };

    const handleDrop = (e) => {
        e.preventDefault();
        e.stopPropagation();
        setDragActive(false);
        
        const files = Array.from(e.dataTransfer.files || []);
        if (files.length > 0) {
            addFiles(files);
        }
    };

    const addFiles = (newFiles) => {
        // Filter valid file types
        const allowedTypes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'text/plain', 'image/jpeg', 'image/jpg', 'image/png'];
        const validFiles = newFiles.filter(file => {
            const ext = file.name.split('.').pop()?.toLowerCase();
            return ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'].includes(ext);
        });

        if (validFiles.length === 0) {
            setError('Please select valid files (PDF, DOC, DOCX, TXT, JPG, PNG)');
            return;
        }

        // Add files to existing list
        const updatedFiles = [...uploadData.files, ...validFiles];
        
        // Set default title for each new file (filename without extension)
        const updatedTitles = { ...uploadData.fileTitles };
        const startIndex = uploadData.files.length;
        
        validFiles.forEach((file, index) => {
            const fileIndex = startIndex + index;
            const fileName = file.name;
            const lastDotIndex = fileName.lastIndexOf('.');
            const fileNameWithoutExt = lastDotIndex > 0 
                ? fileName.substring(0, lastDotIndex) 
                : fileName;
            // Only set if not already set (preserve user edits)
            if (!updatedTitles[fileIndex]) {
                updatedTitles[fileIndex] = fileNameWithoutExt;
            }
        });
        
        setUploadData({ ...uploadData, files: updatedFiles, fileTitles: updatedTitles });
    };

    const removeFile = (index) => {
        const updatedFiles = uploadData.files.filter((_, i) => i !== index);
        // Rebuild fileTitles object with correct indices
        const updatedTitles = {};
        updatedFiles.forEach((file, newIndex) => {
            // Try to preserve title from old index, or use filename
            const oldIndex = uploadData.files.findIndex((f, i) => i === newIndex && i < index) !== -1 
                ? newIndex 
                : uploadData.files.findIndex((f, i) => i > index && i - 1 === newIndex);
            
            if (oldIndex !== -1 && uploadData.fileTitles[oldIndex]) {
                updatedTitles[newIndex] = uploadData.fileTitles[oldIndex];
            } else {
                const fileName = file.name;
                const lastDotIndex = fileName.lastIndexOf('.');
                updatedTitles[newIndex] = lastDotIndex > 0 
                    ? fileName.substring(0, lastDotIndex) 
                    : fileName;
            }
        });
        setUploadData({ ...uploadData, files: updatedFiles, fileTitles: updatedTitles });
    };

    const updateFileTitle = (index, title) => {
        setUploadData({
            ...uploadData,
            fileTitles: {
                ...uploadData.fileTitles,
                [index]: title
            }
        });
    };

    const handleCloseUploadDialog = () => {
        setUploadDialogOpen(false);
        // Reset form when dialog closes
        setUploadData({ description: '', department_ids: [], files: [], fileTitles: {} });
        setError('');
        setDragActive(false);
    };

    const handleUpload = async () => {
        if (!uploadData.files || uploadData.files.length === 0) {
            setError('Please select at least one file');
            return;
        }

        if (!uploadData.department_ids || uploadData.department_ids.length === 0) {
            setError('Please select at least one department');
            return;
        }

        // CRITICAL: Validate department_ids is an array with valid IDs
        if (!Array.isArray(uploadData.department_ids)) {
            console.error('ERROR: department_ids is not an array!', typeof uploadData.department_ids, uploadData.department_ids);
            setError('Invalid department selection. Please try again.');
            return;
        }
        
        // CRITICAL: Ensure all department IDs are valid numbers
        const validDeptIds = uploadData.department_ids.filter(id => {
            const numId = Number(id);
            return !isNaN(numId) && numId > 0;
        });
        
        if (validDeptIds.length !== uploadData.department_ids.length) {
            console.error('ERROR: Some department IDs are invalid!', uploadData.department_ids);
            setError('Invalid department selection. Please try again.');
            return;
        }
        
        if (validDeptIds.length === 0) {
            setError('Please select at least one valid department');
            return;
        }

        try {
            // CRITICAL: Single authoritative state - array of numbers
            const selectedDepartmentIds = validDeptIds.map(id => Number(id)); // Force to numbers
            console.log('=== FRONTEND: Department IDs State ===');
            console.log('selectedDepartmentIds:', selectedDepartmentIds);
            console.log('Count:', selectedDepartmentIds.length);
            console.log('Types:', selectedDepartmentIds.map(id => typeof id));
            
            const formData = new FormData();
            formData.append('description', uploadData.description);
            
            // CRITICAL: FormData construction - MUST use this exact format
            // Loop through each department ID and append with array notation
            selectedDepartmentIds.forEach((deptId, index) => {
                const deptIdString = String(deptId); // Convert to string for FormData
                formData.append('department_ids[]', deptIdString); // MUST use append(), NOT set()
                console.log(`FormData.append('department_ids[]', '${deptIdString}')`);
            });
            
            // CRITICAL: Verify FormData entries BEFORE axios.post()
            const formDataEntries = [...formData.entries()];
            console.log('=== FRONTEND: FormData Entries Verification ===');
            console.log('Total FormData entries:', formDataEntries.length);
            
            const deptIdEntries = formDataEntries.filter(([key]) => key.startsWith('department_ids'));
            console.log('department_ids[] entries found:', deptIdEntries.length);
            console.log('department_ids[] entries:');
            deptIdEntries.forEach(([key, value], index) => {
                console.log(`  [${index}] ${key} → ${value}`);
            });
            
            // CRITICAL: Hard validation - must match expected count
            if (deptIdEntries.length !== selectedDepartmentIds.length) {
                console.error('=== CRITICAL ERROR: FormData department_ids count mismatch ===');
                console.error('Expected:', selectedDepartmentIds.length, 'Found:', deptIdEntries.length);
                console.error('Expected IDs:', selectedDepartmentIds);
                console.error('Found entries:', deptIdEntries.map(([k, v]) => v));
                setError(`Failed to prepare department data. Expected ${selectedDepartmentIds.length} departments but found ${deptIdEntries.length}. Please try again.`);
                return;
            }
            
            // CRITICAL: Verify values match
            const sentValues = deptIdEntries.map(([k, v]) => Number(v)).sort((a, b) => a - b);
            const expectedValues = [...selectedDepartmentIds].sort((a, b) => a - b);
            if (JSON.stringify(sentValues) !== JSON.stringify(expectedValues)) {
                console.error('=== CRITICAL ERROR: FormData department_ids values mismatch ===');
                console.error('Expected:', expectedValues);
                console.error('Found:', sentValues);
                setError('Department IDs mismatch. Please try again.');
                return;
            }
            
            console.log('✓ FormData validation passed - all department IDs correctly added');
            
            // Append each file with its individual title (defaulting to filename)
            // Use 'files[]' notation for PHP to properly receive as array
            uploadData.files.forEach((file, index) => {
                formData.append('files[]', file);
                // Use individual file title if set, otherwise use filename without extension
                const fileTitle = uploadData.fileTitles[index] || (() => {
                    const fileName = file.name;
                    const lastDotIndex = fileName.lastIndexOf('.');
                    return lastDotIndex > 0 
                        ? fileName.substring(0, lastDotIndex) 
                        : fileName;
                })();
                formData.append('titles[]', fileTitle);
            });

            const token = localStorage.getItem('token');
            const response = await axios.post(`${API_BASE_URL}/documents/upload.php`, formData, {
                headers: {
                    Authorization: `Bearer ${token}`,
                    // Don't set Content-Type - axios will set it automatically with correct boundary for FormData
                }
            });

            if (response.data.success) {
                handleCloseUploadDialog();
                fetchDocuments();
                const fileCount = uploadData.files.length;
                const deptCount = selectedDepartmentIds.length;
                setSuccessMessage(`${fileCount} file${fileCount > 1 ? 's' : ''} uploaded successfully to ${deptCount} department${deptCount > 1 ? 's' : ''}!`);
                // Clear success message after 3 seconds
                setTimeout(() => setSuccessMessage(''), 3000);
            } else {
                setError(response.data.message || 'Upload failed');
            }
        } catch (error) {
            if (error.response?.data?.message) {
                setError(error.response.data.message || 'Upload failed. Please try again.');
            } else {
                setError('Upload failed. Please try again.');
            }
        }
    };

    const handleDownload = async (document) => {
        try {
            const token = localStorage.getItem('token');
            const response = await axios.get(
                `${API_BASE_URL}/documents/download.php?id=${document.id}`,
                {
                    headers: { Authorization: `Bearer ${token}` },
                    responseType: 'blob', // ensure binary data
                }
            );

            // ✅ Validate response content
            const contentType = response.headers['content-type'];
            if (!contentType || contentType.includes('json')) {
                const reader = new FileReader();
                reader.onload = () => {
                    try {
                        const data = JSON.parse(reader.result);
                        setError(data.message || 'Download failed.');
                    } catch {
                        setError('Invalid file response from server.');
                    }
                };
                reader.readAsText(response.data);
                return;
            }

            // ✅ Determine file name
            const fileName =
                document.filename ||
                `${document.title || 'document'}.pdf`;

            // ✅ Create download link
            const blobUrl = window.URL.createObjectURL(new Blob([response.data]));
            const link = window.document.createElement('a');
            link.href = blobUrl;
            link.setAttribute('download', fileName);
            window.document.body.appendChild(link);
            link.click();
            link.remove();
            window.URL.revokeObjectURL(blobUrl);

            setSuccessMessage('File downloaded successfully!');
            setTimeout(() => setSuccessMessage(''), 3000);
        } catch (error) {
            if (error.response?.data) {
                // Try to read error message from blob
                const reader = new FileReader();
                reader.onload = () => {
                    try {
                        const data = JSON.parse(reader.result);
                        setError(data.message || 'Download failed.');
                    } catch {
                        setError('Download failed. Please try again.');
                    }
                };
                reader.readAsText(error.response.data);
            } else {
                setError('Download failed. Please try again.');
            }
        }
    };

    const handlePreviewDocument = (document) => {
        setPreviewDocument(document);
        setPreviewDialogOpen(true);
    };

    const handlePrintDocument = () => {
        if (!previewDocument?.id) return;
      
        const pdfUrl = `${API_BASE_URL}/documents/view.php?id=${previewDocument.id}`;
        const printWindow = window.open(pdfUrl, '_blank');
      
        if (printWindow) {
          printWindow.onload = () => {
            printWindow.focus();
            printWindow.print();
          };
        }
      };
      






    const handleScanResult = async (barcode) => {
        try {
            const token = localStorage.getItem('token');

            if (!barcode || !barcode.trim()) {
                setError('Invalid barcode. Please scan again.');
                return;
            }

            // Try to receive the document via QR code scan
            const response = await axios.post(`${API_BASE_URL}/documents/receive.php`, {
                barcode: barcode.trim()
            }, {
                headers: {
                    Authorization: `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });

            if (response.data.success) {
                setScannerDialogOpen(false);
                fetchDocuments();
                setError('');
                setSuccessMessage(response.data.message || 'Document received successfully!');
                // Clear success message after 3 seconds
                setTimeout(() => setSuccessMessage(''), 3000);
            } else {
                setError(response.data.message || 'Document not found or not available for receiving');
            }
        } catch (error) {
            if (error.response?.data?.message) {
                setError(error.response.data.message);
            } else if (error.response?.status === 403) {
                setError('Document is not pending in your department. Make sure the document is forwarded to your department first.');
            } else if (error.response?.status === 404) {
                setError('Document not found. Please check the barcode and try again.');
            } else {
                setError('Failed to receive document. Please try again.');
            }
        }
    };



    const handleForwardDocument = async (document) => {
        setSelectedDocumentForForward(document);
        setForwardSearchTerm('');
        setForwardingStatus('');
        setForwardDialogOpen(true);

        // Fetch available departments for this document
        try {
            const token = localStorage.getItem('token');
            const response = await axios.get(`${API_BASE_URL}/documents/available-departments.php?document_id=${document.id}`, {
                headers: { Authorization: `Bearer ${token}` }
            });

            if (response.data.success) {
                // Store available departments for this document
                setAvailableDepartmentsForForward(response.data.departments || []);
            }
        } catch (error) {
            // Silently fail - available departments not critical
            setAvailableDepartmentsForForward([]);
        }
    };

    const handleForwardToDepartment = async (toDepartmentId) => {
        if (!selectedDocumentForForward) return;

        setForwardingStatus('forwarding');

        try {
            const token = localStorage.getItem('token');
            const response = await axios.post(`${API_BASE_URL}/documents/forward.php`, {
                document_id: selectedDocumentForForward.id,
                to_department_id: toDepartmentId
            }, {
                headers: {
                    Authorization: `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });

            if (response.data.success) {
                setForwardingStatus('success');
                fetchDocuments();
                setError('');
                setSuccessMessage(response.data.message);
                setTimeout(() => {
                    setForwardDialogOpen(false);
                    setSelectedDocumentForForward(null);
                    setForwardingStatus('');
                }, 1500);
                // Clear success message after 3 seconds
                setTimeout(() => setSuccessMessage(''), 3000);
            } else {
                setForwardingStatus('error');
                setError(response.data.message || 'Failed to forward document');
            }
        } catch (error) {
            setForwardingStatus('error');
            if (error.response?.data?.message) {
                setError(error.response.data.message);
            } else {
                setError('Failed to forward document. Please try again.');
            }
        }
    };

    const handleCancelDocument = (document) => {
        setSelectedDocumentForCancel(document);
        setCancellingStatus('');
        setCancelDialogOpen(true);
    };

    const handleConfirmCancel = async () => {
        if (!selectedDocumentForCancel) return;
        if (!cancelNote.trim()) {
            setError('Please provide a reason for cancelling the document.');
            return;
        }

        setCancellingStatus('cancelling');

        try {
            const token = localStorage.getItem('token');
            const response = await axios.post(`${API_BASE_URL}/documents/cancel.php`, {
                document_id: selectedDocumentForCancel.id,
                note: cancelNote.trim()
            }, {
                headers: {
                    Authorization: `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });

            if (response.data.success) {
                setCancellingStatus('success');
                fetchDocuments();
                setError('');
                setSuccessMessage(response.data.message);
                setTimeout(() => {
                    setCancelDialogOpen(false);
                    setSelectedDocumentForCancel(null);
                    setCancelNote('');
                    setCancellingStatus('');
                }, 1500);
                // Clear success message after 3 seconds
                setTimeout(() => setSuccessMessage(''), 3000);
            } else {
                setCancellingStatus('error');
                setError(response.data.message || 'Failed to cancel document');
            }
        } catch (error) {
            setCancellingStatus('error');
            if (error.response?.data?.message) {
                setError(error.response.data.message);
            } else {
                setError('Failed to cancel document. Please try again.');
            }
        }
    };

    const handleActionMenuOpen = (event, document) => {
        setActionMenuAnchor(event.currentTarget);
        setSelectedDocumentForAction(document);
    };

    const handleActionMenuClose = () => {
        setActionMenuAnchor(null);
        setSelectedDocumentForAction(null);
    };

    const handleActionMenuAction = (action) => {
        if (!selectedDocumentForAction) return;

        switch (action) {
            case 'download':
                handleDownload(selectedDocumentForAction);
                break;
            case 'barcode':
                setSelectedDocument(selectedDocumentForAction);
                setBarcodeDialogOpen(true);
                break;
            case 'forward':
                handleForwardDocument(selectedDocumentForAction);
                break;
            case 'cancel':
                handleCancelDocument(selectedDocumentForAction);
                break;
            case 'routing':
                handleShowRouting(selectedDocumentForAction);
                break;
            case 'preview':
                handlePreviewDocument(selectedDocumentForAction);
                break;

            default:
                break;
        }

        handleActionMenuClose();
    };

    const handleShowRouting = async (document) => {
        setSelectedDocumentForRouting(document);
        setDynamicRoutingData(null);
        setRoutingDialogOpen(true);

        // Fetch dynamic routing data
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
        }
    };

    const handleCopyBarcode = async (document) => {
        const value = (document?.barcode || document?.id) ? String(document.barcode || document.id) : '';
        if (!value) {
            setError('No barcode available to copy.');
            return;
        }

        try {
            if (navigator?.clipboard?.writeText) {
                await navigator.clipboard.writeText(value);
            } else {
                // Fallback for older browsers / non-secure contexts
                const textarea = window.document.createElement('textarea');
                textarea.value = value;
                textarea.setAttribute('readonly', '');
                textarea.style.position = 'fixed';
                textarea.style.left = '-9999px';
                window.document.body.appendChild(textarea);
                textarea.select();
                window.document.execCommand('copy');
                textarea.remove();
            }

            setSuccessMessage('Barcode copied to clipboard!');
            setTimeout(() => setSuccessMessage(''), 2000);
        } catch (e) {
            setError('Failed to copy barcode. Please try again.');
        }
    };

    const getFilteredDepartments = () => {
        if (!forwardSearchTerm) return availableDepartmentsForForward;

        return availableDepartmentsForForward.filter(dept =>
            dept.name.toLowerCase().includes(forwardSearchTerm.toLowerCase())
        );
    };

    const getRoutingPathForDocument = (document) => {
        if (!document.department_id) return null;

        const routing = routingInfo.find(r => r.to_department_id == document.department_id);
        return routing ? routing.routing_path : null;
    };

    const getCreatedDepartmentForDocument = (document) => {
        const path = getRoutingPathForDocument(document);
        if (document.created_department_name) return document.created_department_name;
        if (document.source_department_name) return document.source_department_name;
        if (document.uploaded_by_department_name) return document.uploaded_by_department_name;
        if (path && path.length > 0) return path[0];
        // Avoid using current/receiving department as a fallback so it never changes after scan
        return 'No Department';
    };

    const getSourceDepartmentForDocument = (document) => {
        const path = getRoutingPathForDocument(document);
        if (path && path.length > 0) return path[0];
        // Fallbacks if routing info is unavailable
        return document.source_department_name || document.current_department_name || document.department_name || 'No Department';
    };

    const canForwardDocument = (document) => {
        // ❌ Must have a valid department
        if (!user?.department_id) {
            return false;
        }

        // ✅ Only the current department can forward (same as cancel logic)
        if (document.current_department_id !== user.department_id) {
            return false;
        }

        // ✅ Only forward if it's already received
        const status = getDisplayStatus(document);
        if (status !== 'received') {
            return false;
        }

        // ✅ Prevent sender from forwarding their own document
        if (document.uploaded_by === user?.id) {
            return false;
        }

        return true;
    };


    const canCancelDocument = (document) => {
        // Check if user is not the sender
        if (document.uploaded_by === user?.id) {
            return false;
        }

        // Check if user has a department
        if (!user?.department_id) {
            return false;
        }

        // Check if document is in a cancellable state
        const status = (document.status || '').toLowerCase();
        if (!['pending', 'outgoing', 'received'].includes(status)) {
            return false;
        }

        // Only the current department can cancel the document
        return document.current_department_id === user?.department_id;
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

    // ✅ Adjust displayed status based on user's department and backend field naming
    const getAdjustedStatus = (doc) => {
        const raw = (doc.status || '').toLowerCase();

        // Identify the receiving department ID — your backend may use department_id or receiving_department_id
        const receivingDeptId = doc.receiving_department_id || doc.department_id;

        // If outgoing and the current user belongs to the receiving department, show as pending
        if (raw === 'outgoing' && user?.department_id && user.department_id == receivingDeptId) {
            return 'pending';
        }

        // Otherwise, return the normal display status
        return getDisplayStatus(doc);
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

    if (loading) {
        return (
            <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
                <CircularProgress />
            </Box>
        );
    }

    return (
        <Box>
            <Box 
                display="flex" 
                justifyContent="space-between" 
                alignItems={{ xs: 'flex-start', sm: 'center' }}
                mb={4}
                sx={{ flexDirection: { xs: 'column', sm: 'row' }, gap: 2 }}
            >
                <Box>
                    <Typography variant="h4" sx={{ fontWeight: 600, mb: 1 }}>
                        Documents
                    </Typography>
                    {user?.current_department_name && (
                        <Typography variant="body2" color="text.secondary" sx={{ fontSize: '0.9rem' }}>
                            Showing documents for <Box component="span" sx={{ fontWeight: 500, color: 'primary.main' }}>{user.current_department_name}</Box> department
                        </Typography>
                    )}
                </Box>
                <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', width: { xs: '100%', sm: 'auto' } }}>
                    <Button
                        variant="contained"
                        startIcon={<AddIcon />}
                        onClick={() => setUploadDialogOpen(true)}
                        sx={{ 
                            borderRadius: 2,
                            textTransform: 'none',
                            fontWeight: 600,
                            px: 3,
                            py: 1.25
                        }}
                    >
                        Upload Document
                    </Button>
                    <Button
                        variant="outlined"
                        startIcon={<ScannerIcon />}
                        onClick={() => setScannerDialogOpen(true)}
                        sx={{ 
                            borderRadius: 2,
                            textTransform: 'none',
                            fontWeight: 500,
                            px: 3,
                            py: 1.25
                        }}
                    >
                        Scan QR to Receive
                    </Button>
                </Box>
            </Box>

            {successMessage && (
                <Alert 
                    severity="success" 
                    sx={{ 
                        mb: 3,
                        borderRadius: 2,
                        '& .MuiAlert-message': {
                            fontSize: '0.95rem',
                        }
                    }} 
                    onClose={() => setSuccessMessage('')}
                >
                    {successMessage}
                </Alert>
            )}
            <Box display="flex" justifyContent="flex-end" mb={3}>
                <TextField
                    variant="outlined"
                    size="small"
                    placeholder="Search by title, department, or received by..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    InputProps={{
                        startAdornment: (
                            <InputAdornment position="start">
                                <SearchIcon color="action" />
                            </InputAdornment>
                        ),
                    }}
                    sx={{ 
                        width: { xs: '100%', sm: 400 },
                        '& .MuiOutlinedInput-root': {
                            borderRadius: 2,
                        }
                    }}
                />
            </Box>


            <Card>
                <CardContent sx={{ p: 0 }}>
                    <TableContainer>
                        <Table>
                            <TableHead>
                                <TableRow>
                                    <TableCell sx={{ fontWeight: 600, fontSize: '0.95rem', py: 2 }}>Title</TableCell>
                                    <TableCell sx={{ fontWeight: 600, fontSize: '0.95rem', py: 2 }}>Source Department</TableCell>
                                    <TableCell sx={{ fontWeight: 600, fontSize: '0.95rem', py: 2 }}>Current Department</TableCell>
                                    <TableCell sx={{ fontWeight: 600, fontSize: '0.95rem', py: 2 }}>Receiving Department</TableCell>
                                    <TableCell sx={{ fontWeight: 600, fontSize: '0.95rem', py: 2 }}>Status</TableCell>
                                    <TableCell sx={{ fontWeight: 600, fontSize: '0.95rem', py: 2 }}>Created By</TableCell>
                                    <TableCell sx={{ fontWeight: 600, fontSize: '0.95rem', py: 2 }}>Actions</TableCell>
                                </TableRow>
                            </TableHead>

                            <TableBody>
                                {documents
                                    .filter((doc) => {
                                        const term = searchTerm.toLowerCase();
                                        return (
                                            doc.title?.toLowerCase().includes(term) ||
                                            doc.department_name?.toLowerCase().includes(term) ||
                                            doc.current_department_name?.toLowerCase().includes(term) ||
                                            doc.uploaded_by_name?.toLowerCase().includes(term)
                                        );
                                    })
                                    .map((doc) => (
                                        <TableRow
                                            key={doc.id}
                                            hover
                                            sx={{ 
                                                cursor: 'pointer',
                                                '&:hover': {
                                                    bgcolor: 'action.hover'
                                                }
                                            }}
                                            onClick={() => handleShowRouting(doc)}
                                        >

                                            {/* 🧾 Title */}
                                            <TableCell sx={{ py: 2.5 }}>
                                                <Typography variant="body2" fontWeight="medium" sx={{ mb: 0.5, fontSize: '0.95rem' }}>
                                                    {doc.title}
                                                </Typography>
                                                {doc.description && (
                                                    <Typography variant="caption" color="text.secondary" sx={{ fontSize: '0.8rem', display: 'block', mt: 0.5 }}>
                                                        {doc.description}
                                                    </Typography>
                                                )}
                                            </TableCell>

                                            {/* 🏢 Source Department */}
                                            <TableCell sx={{ py: 2.5 }}>
                                                <Typography variant="body2" fontWeight="medium" sx={{ mb: 0.5, fontSize: '0.95rem' }}>
                                                    {doc.upload_department_name || 'No Department'}
                                                </Typography>
                                                <Typography variant="caption" color="text.secondary" sx={{ fontSize: '0.75rem', display: 'block' }}>
                                                    Source Department
                                                </Typography>
                                            </TableCell>

                                            {/* 🏢 Current Department */}
                                            <TableCell sx={{ py: 2.5 }}>
                                                <Typography variant="body2" fontWeight="medium" sx={{ mb: 0.5, fontSize: '0.95rem' }}>
                                                    {doc.current_department_name || 'No Department'}
                                                </Typography>
                                                <Typography variant="caption" color="text.secondary" sx={{ fontSize: '0.75rem', display: 'block' }}>
                                                    Current Department
                                                </Typography>
                                            </TableCell>

                                            {/* 🏢 Receiving Department */}
                                            <TableCell sx={{ py: 2.5 }}>
                                                <Typography variant="body2" fontWeight="medium" sx={{ mb: 0.5, fontSize: '0.95rem' }}>
                                                    {doc.department_name || 'No Department'}
                                                </Typography>
                                                <Typography variant="caption" color="text.secondary" sx={{ fontSize: '0.75rem', display: 'block' }}>
                                                    Receiving Department
                                                </Typography>
                                            </TableCell>

                                            {/* 📊 Status */}
                                            <TableCell sx={{ py: 2.5 }}>
                                                <Tooltip
                                                    title={
                                                        getAdjustedStatus(doc) === 'cancelled'
                                                            ? doc.cancel_note
                                                                ? `Reason: ${doc.cancel_note}`
                                                                : 'Cancelled — no reason provided.'
                                                            : ''
                                                    }
                                                    arrow
                                                >
                                                    <Chip
                                                        label={getAdjustedStatus(doc)}
                                                        color={getStatusColor(getAdjustedStatus(doc))}
                                                        size="small"
                                                        sx={{
                                                            textTransform: 'capitalize',
                                                            cursor: getAdjustedStatus(doc) === 'cancelled' ? 'pointer' : 'default',
                                                            fontWeight: 500,
                                                            minWidth: 80
                                                        }}
                                                    />
                                                </Tooltip>
                                            </TableCell>

                                            {/* 👤 Created By */}
                                            <TableCell sx={{ py: 2.5 }}>
                                                <Typography variant="body2" sx={{ mb: 0.5, fontSize: '0.95rem' }}>
                                                    {doc.uploaded_by_name || 'Unknown'}
                                                </Typography>
                                                <Typography variant="caption" color="text.secondary" sx={{ fontSize: '0.75rem', display: 'block' }}>
                                                    {new Date(doc.uploaded_at).toLocaleDateString()}{" "}
                                                    {new Date(doc.uploaded_at).toLocaleTimeString()}
                                                </Typography>
                                            </TableCell>

                                            {/* ⚙️ Actions */}
                                            <TableCell sx={{ py: 2.5 }}>
                                                <Box sx={{ display: 'flex', gap: 0.5, alignItems: 'center' }}>
                                                    {/* Copy Barcode */}
                                                    <Tooltip title="Copy Barcode" arrow>
                                                        <IconButton
                                                            size="small"
                                                            onClick={(e) => {
                                                                e.stopPropagation();
                                                                handleCopyBarcode(doc);
                                                            }}
                                                            sx={{ 
                                                                '&:hover': {
                                                                    bgcolor: 'primary.light',
                                                                    color: 'white'
                                                                }
                                                            }}
                                                        >
                                                            <ContentCopyIcon fontSize="small" />
                                                        </IconButton>
                                                    </Tooltip>

                                                    {/* Cancel */}
                                                    {canCancelDocument(doc) && (
                                                        <Tooltip title="Cancel Document" arrow>
                                                            <IconButton
                                                                size="small"
                                                                onClick={(e) => {
                                                                    e.stopPropagation();
                                                                    handleCancelDocument(doc);
                                                                }}
                                                                color="error"
                                                                sx={{ 
                                                                    '&:hover': {
                                                                        bgcolor: 'error.dark',
                                                                        color: 'white'
                                                                    }
                                                                }}
                                                            >
                                                                <CancelIcon fontSize="small" />
                                                            </IconButton>
                                                        </Tooltip>
                                                    )}

                                                    {/* Forward */}
                                                    {canForwardDocument(doc) && (
                                                        <Tooltip title="Forward Document" arrow>
                                                            <IconButton
                                                                size="small"
                                                                onClick={(e) => {
                                                                    e.stopPropagation();
                                                                    handleForwardDocument(doc);
                                                                }}
                                                                color="secondary"
                                                                sx={{ 
                                                                    '&:hover': {
                                                                        bgcolor: 'secondary.dark',
                                                                        color: 'white'
                                                                    }
                                                                }}
                                                            >
                                                                <ForwardIcon fontSize="small" />
                                                            </IconButton>
                                                        </Tooltip>
                                                    )}

                                                    {/* More actions */}
                                                    <Tooltip title="Document Actions" arrow>
                                                        <IconButton
                                                            size="small"
                                                            onClick={(e) => {
                                                                e.stopPropagation();
                                                                handleActionMenuOpen(e, doc);
                                                            }}
                                                            sx={{ 
                                                                '&:hover': {
                                                                    bgcolor: 'action.hover'
                                                                }
                                                            }}
                                                        >
                                                            <MoreVertIcon fontSize="small" />
                                                        </IconButton>
                                                    </Tooltip>
                                                </Box>
                                            </TableCell>
                                        </TableRow>
                                    ))}
                            </TableBody>
                            {documents.filter((doc) => {
                                const term = searchTerm.toLowerCase();
                                return (
                                    doc.title?.toLowerCase().includes(term) ||
                                    doc.department_name?.toLowerCase().includes(term) ||
                                    doc.current_department_name?.toLowerCase().includes(term) ||
                                    doc.uploaded_by_name?.toLowerCase().includes(term)
                                );
                            }).length === 0 && (
                                    <TableRow>
                                        <TableCell colSpan={7} align="center" sx={{ py: 6 }}>
                                            <Typography variant="body2" color="text.secondary" sx={{ fontSize: '0.95rem' }}>
                                                No matching documents found.
                                            </Typography>
                                        </TableCell>
                                    </TableRow>
                                )}

                        </Table>
                    </TableContainer>
                </CardContent>
            </Card>


            {/* Upload Dialog */}
            <Dialog open={uploadDialogOpen} onClose={handleCloseUploadDialog} maxWidth="sm" fullWidth>
                <DialogTitle sx={{ pb: 2, fontWeight: 600, fontSize: '1.25rem' }}>
                    Upload New Document
                </DialogTitle>
                <DialogContent dividers sx={{ pt: 3 }}>
                    {error && (
                        <Alert severity="error" sx={{ mb: 3, borderRadius: 2 }}>
                            {error}
                        </Alert>
                    )}
                    <Box sx={{ mb: 3 }}>
                        <Typography variant="body2" color="text.secondary" sx={{ mb: 1.5, fontWeight: 500 }}>
                            Select Files (Drag & Drop or Click to Browse)
                        </Typography>
                        <input
                            accept=".pdf,.doc,.docx,.txt,.jpg,.jpeg,.png"
                            style={{ display: 'none' }}
                            id="file-upload"
                            type="file"
                            multiple
                            onChange={handleFileUpload}
                        />
                        <Box
                            onDragEnter={handleDrag}
                            onDragLeave={handleDrag}
                            onDragOver={handleDrag}
                            onDrop={handleDrop}
                                sx={{ 
                                border: '2px dashed',
                                borderColor: dragActive ? 'primary.main' : 'divider',
                                    borderRadius: 2,
                                p: 4,
                                textAlign: 'center',
                                bgcolor: dragActive ? 'action.hover' : 'background.paper',
                                transition: 'all 0.2s ease',
                                cursor: 'pointer',
                                '&:hover': {
                                    borderColor: 'primary.main',
                                    bgcolor: 'action.hover',
                                }
                            }}
                            onClick={() => document.getElementById('file-upload').click()}
                        >
                            <UploadIcon sx={{ fontSize: 48, color: 'text.secondary', mb: 2 }} />
                            <Typography variant="body1" sx={{ mb: 1, fontWeight: 500 }}>
                                {dragActive ? 'Drop files here' : 'Drag & drop files here or click to browse'}
                            </Typography>
                            <Typography variant="caption" color="text.secondary">
                                Supports: PDF, DOC, DOCX, TXT, JPG, PNG (Multiple files allowed)
                            </Typography>
                        </Box>
                        {uploadData.files.length > 0 && (
                            <Box sx={{ mt: 2 }}>
                                <Typography variant="body2" sx={{ mb: 1, fontWeight: 500 }}>
                                    Selected Files ({uploadData.files.length}):
                                </Typography>
                                {uploadData.files.map((file, index) => (
                                    <Box
                                        key={index}
                                        sx={{
                                            p: 2,
                                            mb: 2,
                                            bgcolor: 'grey.50',
                                            borderRadius: 2,
                                            border: '1px solid',
                                            borderColor: 'divider',
                                        }}
                                    >
                                        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 1.5 }}>
                                            <Typography variant="body2" sx={{ fontWeight: 500 }}>
                                                {file.name} ({(file.size / 1024).toFixed(2)} KB)
                                            </Typography>
                                            <IconButton
                                                size="small"
                                                onClick={(e) => {
                                                    e.stopPropagation();
                                                    removeFile(index);
                                                }}
                                                sx={{ color: 'error.main' }}
                                            >
                                                <CancelIcon fontSize="small" />
                                            </IconButton>
                    </Box>
                    <TextField
                        fullWidth
                                            size="small"
                                            label={`Document Title ${index + 1}`}
                                            value={uploadData.fileTitles[index] || ''}
                                            onChange={(e) => updateFileTitle(index, e.target.value)}
                                            placeholder="Leave empty to use filename"
                        sx={{ 
                            '& .MuiOutlinedInput-root': {
                                borderRadius: 2,
                            }
                        }}
                    />
                                    </Box>
                                ))}
                            </Box>
                        )}
                    </Box>
                    <TextField
                        fullWidth
                        label="Description"
                        value={uploadData.description}
                        onChange={(e) => setUploadData({ ...uploadData, description: e.target.value })}
                        margin="normal"
                        multiline
                        rows={3}
                        sx={{ 
                            mb: 2,
                            '& .MuiOutlinedInput-root': {
                                borderRadius: 2,
                            }
                        }}
                    />
                    <FormControl fullWidth margin="normal" required sx={{ mb: 2 }}>
                        <FormLabel sx={{ mb: 1.5, fontWeight: 500, fontSize: '0.875rem' }}>
                            Destination (Select One or More Departments)
                        </FormLabel>
                        <Box
                        sx={{ 
                                border: '1px solid',
                                borderColor: 'divider',
                                borderRadius: 2,
                                p: 2,
                                maxHeight: 200,
                                overflowY: 'auto',
                                bgcolor: 'background.paper',
                        }}
                    >
                            <FormGroup>
                                {departments.length > 0 ? (
                                    departments.map((dept) => (
                                        <FormControlLabel
                                            key={dept.id}
                                            control={
                                                <Checkbox
                                                    checked={uploadData.department_ids.some(id => Number(id) === Number(dept.id))}
                                                    onChange={(e) => {
                                                        const isChecked = e.target.checked;
                                                        const deptIdNum = Number(dept.id); // Ensure consistent number type
                                                        
                                                        setUploadData({
                                                            ...uploadData,
                                                            department_ids: isChecked
                                                                ? [...uploadData.department_ids.filter(id => Number(id) !== deptIdNum), deptIdNum] // Remove if exists, then add
                                                                : uploadData.department_ids.filter(id => Number(id) !== deptIdNum) // Remove if unchecked
                                                        });
                                                    }}
                                                />
                                            }
                                            label={dept.name}
                                        />
                                    ))
                                ) : (
                                    <Typography variant="body2" color="text.secondary" sx={{ fontStyle: 'italic' }}>
                                        No departments available
                                    </Typography>
                                )}
                            </FormGroup>
                        </Box>
                        {uploadData.department_ids.length > 0 && (
                            <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
                                {uploadData.department_ids.length} department{uploadData.department_ids.length > 1 ? 's' : ''} selected
                            </Typography>
                        )}
                    </FormControl>
                    {uploadData.department_ids.length > 0 && (
                        <Box sx={{ mt: 2, p: 2.5, bgcolor: 'info.light', borderRadius: 2, border: '1px solid', borderColor: 'info.main' }}>
                            <Typography variant="body2" color="info.contrastText" sx={{ fontWeight: 600, mb: 1 }}>
                                Document Routing:
                            </Typography>
                            {uploadData.department_ids.length === 1 ? (
                                (() => {
                                    const routing = routingInfo.find(r => r.to_department_id == uploadData.department_ids[0]);
                                if (routing) {
                                    return (
                                        <Typography variant="body2" color="info.contrastText" sx={{ fontSize: '0.9rem', lineHeight: 1.6 }}>
                                            Your document will be sent through: <Box component="span" sx={{ fontWeight: 600 }}>{routing.routing_path.join(' → ')}</Box>
                                            {routing.has_intermediate && (
                                                <Typography variant="caption" display="block" sx={{ mt: 1.5, fontStyle: 'italic' }}>
                                                    Note: Document will first go to {routing.intermediate_department_name} before reaching the final destination.
                                                </Typography>
                                            )}
                                        </Typography>
                                    );
                                } else if (routingInfo.length === 0) {
                                    return (
                                        <Typography variant="body2" color="info.contrastText" sx={{ fontSize: '0.9rem' }}>
                                            Routing information not available. Document will be sent directly to selected department.
                                        </Typography>
                                    );
                                } else {
                                    return (
                                        <Typography variant="body2" color="info.contrastText" sx={{ fontSize: '0.9rem' }}>
                                            Direct routing to selected department.
                                        </Typography>
                                    );
                                }
                                })()
                            ) : (
                                <Typography variant="body2" color="info.contrastText" sx={{ fontSize: '0.9rem', lineHeight: 1.6 }}>
                                    Separate tracking records will be created for each selected department. Each department will receive the document independently.
                                </Typography>
                            )}
                        </Box>
                    )}
                </DialogContent>
                <DialogActions sx={{ p: 2.5, gap: 1 }}>
                    <Button 
                        onClick={handleCloseUploadDialog}
                        sx={{ 
                            borderRadius: 2,
                            textTransform: 'none',
                            px: 3
                        }}
                    >
                        Cancel
                    </Button>
                    <Button 
                        onClick={handleUpload} 
                        variant="contained"
                        sx={{ 
                            borderRadius: 2,
                            textTransform: 'none',
                            px: 3,
                            fontWeight: 600
                        }}
                    >
                        Upload
                    </Button>
                </DialogActions>
            </Dialog>

            {/* Scanner Dialog */}
            <BarcodeScanner
                open={scannerDialogOpen}
                onClose={() => setScannerDialogOpen(false)}
                onScan={handleScanResult}
                title="Scan QR Code to Receive Document"
            />

            {/* Barcode Dialog */}
            <Dialog open={barcodeDialogOpen} onClose={() => setBarcodeDialogOpen(false)} maxWidth="sm" fullWidth>
                <DialogTitle>Document Barcode</DialogTitle>
                <DialogContent>
                    {selectedDocument && (
                        <BarcodeGenerator
                            barcode={selectedDocument.barcode}
                            title={selectedDocument.title}
                        />
                    )}
                </DialogContent>
                <DialogActions>
                    <Button onClick={() => setBarcodeDialogOpen(false)}>Close</Button>
                </DialogActions>
            </Dialog>

            {/* Error Dialog */}
            <Dialog 
                open={errorDialogOpen} 
                onClose={() => { setErrorDialogOpen(false); setError(''); }} 
                maxWidth="sm" 
                fullWidth
            >
                <DialogTitle sx={{ pb: 2 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                        <ErrorIcon color="error" />
                        <Typography variant="h6" component="span" sx={{ fontWeight: 600 }}>
                            Error
                        </Typography>
                    </Box>
                </DialogTitle>
                <DialogContent dividers sx={{ pt: 3 }}>
                    <Typography variant="body1" color="text.primary" sx={{ fontSize: '0.95rem', lineHeight: 1.6 }}>
                        {error || 'An error occurred. Please try again.'}
                    </Typography>
                </DialogContent>
                <DialogActions sx={{ p: 2.5 }}>
                    <Button 
                        onClick={() => { setErrorDialogOpen(false); setError(''); }} 
                        variant="contained"
                        color="primary"
                        sx={{ 
                            borderRadius: 2,
                            textTransform: 'none',
                            px: 3,
                            fontWeight: 600
                        }}
                    >
                        Close
                    </Button>
                </DialogActions>
            </Dialog>



            {/* Routing Dialog */}
            <Dialog
                open={routingDialogOpen}
                onClose={() => setRoutingDialogOpen(false)}
                maxWidth="md"
                fullWidth
            >
                <DialogTitle>Document Routing Path</DialogTitle>
                <DialogContent>
                    {selectedDocumentForRouting && (
                        <Box>
                            <Typography variant="body1" gutterBottom>
                                <strong>Document:</strong> {selectedDocumentForRouting.title}
                            </Typography>

                            {selectedDocumentForRouting.description && (
                                <Typography variant="body2" color="text.secondary" gutterBottom>
                                    {selectedDocumentForRouting.description}
                                </Typography>
                            )}

                            {dynamicRoutingData?.routing_details?.length > 0 ? (
                                <Box sx={{ mt: 2 }}>
                                    <Typography variant="body2" gutterBottom>
                                        <strong>Routing Path & Status:</strong>
                                    </Typography>

                                    <Box sx={{ p: 2, bgcolor: theme.palette.mode === 'dark' ? 'grey.800' : 'grey.100', borderRadius: 1 }}>
                                        {dynamicRoutingData.routing_details.map((step, index) => {
                                            const isFirst = index === 0;
                                            const isLast = index === dynamicRoutingData.routing_details.length - 1;

                                            // Determine status: only show if actually received or if it's the last step
                                            const displayStatus = getDisplayStatus(selectedDocumentForRouting);
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
                                                                <Typography variant="caption" color="text.secondary" display="block">
                                                                    • {isFirst ? 'Created on:' : (step.was_received || step.action === 'received' ? 'Received on:' : 'Forwarded on:')}{' '}
                                                                    {step.timestamp ? formatDate(step.timestamp) : 'Unknown'}
                                                                </Typography>

                                                                {/* Show user name only for created (first step) or received steps, not for pending */}
                                                                {(isFirst || step.was_received || step.action === 'received') && (
                                                                    <Typography variant="caption" color="text.secondary" display="block">
                                                                        • {isFirst ? 'Created by:' : 'Received by:'}{' '}
                                                                        <span
                                                                            style={{
                                                                            color: isCancelledAtSource
                                                                                    ? theme.palette.error.main
                                                                                : isFirst
                                                                                        ? theme.palette.primary.main
                                                                                    : isLast
                                                                                            ? theme.palette.success.main
                                                                                            : theme.palette.info.main,
                                                                            }}
                                                                        >
                                                                            {step.user_name || 'System User'}
                                                                        </span>
                                                                    </Typography>
                                                                )}

                                                                {stepStatus && (
                                                                    <Box component="span" sx={{ display: 'block' }}>
                                                                        <Typography variant="caption" color="text.secondary" component="span">
                                                                            • Status:{' '}
                                                                        </Typography>
                                                                        <Chip
                                                                            label={stepStatus.charAt(0).toUpperCase() + stepStatus.slice(1)}
                                                                            color={getStatusColor(stepStatus)}
                                                                            size="small"
                                                                            sx={{
                                                                                textTransform: 'capitalize',
                                                                                fontSize: '0.7rem',
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
                                                                borderLeft: (theme) => `2px dotted ${theme.palette.divider}`,
                                                                height: 20,
                                                            }}
                                                        />
                                                    )}
                                                </Box>
                                            );
                                        })}

                                        {/* ✅ Show Cancellation Details at the End */}
                                        {getDisplayStatus(selectedDocumentForRouting) === 'cancelled' && (
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
                                                        {selectedDocumentForRouting.canceled_by_name || 'Unknown User'}
                                                    </Typography>

                                                    <Typography variant="body2" sx={{ mt: 1, color: 'error.contrastText' }}>
                                                        <strong>Reason:</strong>{' '}
                                                        {selectedDocumentForRouting.cancel_note || 'No reason provided.'}
                                                    </Typography>

                                                    {selectedDocumentForRouting.canceled_at && (
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
                                                            {new Date(selectedDocumentForRouting.canceled_at).toLocaleString()}
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
                                        p: 2,
                                        bgcolor: 'warning.light',
                                        borderRadius: 1,
                                    }}
                                >
                                    <Typography variant="body2" color="warning.contrastText">
                                        No routing history available.
                                    </Typography>
                                </Box>
                            )}
                        </Box>
                    )}
                </DialogContent>
                <DialogActions>
                    <Button onClick={() => setRoutingDialogOpen(false)}>Close</Button>
                </DialogActions>
            </Dialog>



            {/* Forward Dialog */}
            <Dialog open={forwardDialogOpen} onClose={() => setForwardDialogOpen(false)} maxWidth="md" fullWidth>
                <DialogTitle sx={{ pb: 2, fontWeight: 600, fontSize: '1.25rem' }}>
                    Forward Document
                </DialogTitle>
                <DialogContent dividers sx={{ pt: 3 }}>
                    {selectedDocumentForForward && (
                        <Box>
                            <Box sx={{ mb: 3, p: 2, bgcolor: 'grey.50', borderRadius: 2 }}>
                                <Typography variant="body1" gutterBottom sx={{ fontWeight: 600, mb: 1 }}>
                                    Document: {selectedDocumentForForward.title}
                                </Typography>
                                {selectedDocumentForForward.description && (
                                    <Typography variant="body2" color="text.secondary" sx={{ fontSize: '0.9rem' }}>
                                        {selectedDocumentForForward.description}
                                    </Typography>
                                )}
                            </Box>

                            {/* Search Bar */}
                            <TextField
                                fullWidth
                                placeholder="Search departments..."
                                value={forwardSearchTerm}
                                onChange={(e) => setForwardSearchTerm(e.target.value)}
                                sx={{ 
                                    mb: 3,
                                    '& .MuiOutlinedInput-root': {
                                        borderRadius: 2,
                                    }
                                }}
                                InputProps={{
                                    startAdornment: (
                                        <InputAdornment position="start">
                                            <SearchIcon />
                                        </InputAdornment>
                                    ),
                                }}
                            />

                            <Typography variant="body2" gutterBottom sx={{ fontWeight: 600, mb: 2, fontSize: '0.95rem' }}>
                                Select destination department:
                            </Typography>

                            {/* Status Display */}
                            {forwardingStatus === 'forwarding' && (
                                <Box sx={{ mt: 2, mb: 3 }}>
                                    <LinearProgress sx={{ borderRadius: 1, mb: 1.5 }} />
                                    <Typography variant="body2" color="primary" sx={{ fontWeight: 500 }}>
                                        Forwarding document...
                                    </Typography>
                                </Box>
                            )}

                            {forwardingStatus === 'success' && (
                                <Box sx={{ mt: 2, mb: 3 }}>
                                    <Alert severity="success" sx={{ borderRadius: 2 }}>
                                        Document forwarded successfully!
                                    </Alert>
                                </Box>
                            )}

                            {forwardingStatus === 'error' && (
                                <Box sx={{ mt: 2, mb: 3 }}>
                                    <Alert severity="error" sx={{ borderRadius: 2 }}>
                                        Failed to forward document. Please try again.
                                    </Alert>
                                </Box>
                            )}

                            {/* Department List */}
                            <Box
                                sx={{
                                    maxHeight: 280,
                                    overflowY: 'auto',
                                    display: 'flex',
                                    flexDirection: 'column',
                                    gap: 1.5,
                                    pr: 1
                                }}
                            >
                                {getFilteredDepartments().length > 0 ? (
                                    <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1.5 }}>
                                        {getFilteredDepartments().map((dept) => (
                                            <Button
                                                key={dept.id}
                                                variant="outlined"
                                                sx={{
                                                    textTransform: 'none',
                                                    minWidth: 200,
                                                    borderRadius: 2,
                                                    py: 1.25,
                                                    fontWeight: 500
                                                }}
                                                onClick={() => handleForwardToDepartment(dept.id)}
                                                disabled={forwardingStatus === 'forwarding'}
                                            >
                                                {dept.name}
                                            </Button>
                                        ))}
                                    </Box>

                                ) : (
                                    <Box sx={{ textAlign: 'center', py: 4 }}>
                                        <Typography
                                            variant="body2"
                                            color="text.secondary"
                                            sx={{ fontSize: '0.95rem' }}
                                        >
                                            {forwardSearchTerm
                                                ? 'No departments found matching your search.'
                                                : 'No available departments for forwarding.'}
                                        </Typography>
                                    </Box>
                                )}
                            </Box>

                        </Box>
                    )}
                </DialogContent>
                <DialogActions sx={{ p: 2.5, gap: 1 }}>
                    <Button
                        onClick={() => setForwardDialogOpen(false)}
                        disabled={forwardingStatus === 'forwarding'}
                        sx={{ 
                            borderRadius: 2,
                            textTransform: 'none',
                            px: 3
                        }}
                    >
                        Cancel
                    </Button>
                </DialogActions>
            </Dialog>

            {/* Action Menu */}
            <Menu
                anchorEl={actionMenuAnchor}
                open={Boolean(actionMenuAnchor)}
                onClose={handleActionMenuClose}
                anchorOrigin={{
                    vertical: 'bottom',
                    horizontal: 'right',
                }}
                transformOrigin={{
                    vertical: 'top',
                    horizontal: 'right',
                }}
            >
                {/* Preview Action */}
                <MenuItem onClick={() => handleActionMenuAction('preview')}>
                    <ListItemIcon>
                        <VisibilityIcon fontSize="small" />
                    </ListItemIcon>
                    <ListItemText>Preview Document</ListItemText>
                </MenuItem>

                {/* Download Action */}
                <MenuItem onClick={() => handleActionMenuAction('download')}>
                    <ListItemIcon>
                        <DownloadIcon fontSize="small" />
                    </ListItemIcon>
                    <ListItemText>Download Document</ListItemText>
                </MenuItem>

                {/* Barcode Action */}
                <MenuItem onClick={() => handleActionMenuAction('barcode')}>
                    <ListItemIcon>
                        <QrCodeIcon fontSize="small" />
                    </ListItemIcon>
                    <ListItemText>View Barcode</ListItemText>
                </MenuItem>

                {/* Forward Action - only show if document can be forwarded */}
                {selectedDocumentForAction && canForwardDocument(selectedDocumentForAction) && (
                    <MenuItem onClick={() => handleActionMenuAction('forward')}>
                        <ListItemIcon>
                            <ForwardIcon fontSize="small" color="secondary" />
                        </ListItemIcon>
                        <ListItemText>Forward Document</ListItemText>
                    </MenuItem>
                )}

                {/* Cancel Action - only show if document can be cancelled */}
                {selectedDocumentForAction && canCancelDocument(selectedDocumentForAction) && (
                    <MenuItem onClick={() => handleActionMenuAction('cancel')}>
                        <ListItemIcon>
                            <CancelIcon fontSize="small" color="error" />
                        </ListItemIcon>
                        <ListItemText>Cancel Document</ListItemText>
                    </MenuItem>
                )}


            </Menu>
            {/* 📄 Preview Dialog */}
            <Dialog
                open={previewDialogOpen}
                onClose={() => setPreviewDialogOpen(false)}
                maxWidth="md"
                fullWidth
            >
                <DialogTitle>Document Preview</DialogTitle>
                <DialogContent dividers>
                    {previewDocument ? (
                        <Box
                            id="printable-area"
                            sx={{
                                position: "relative",
                                backgroundColor: "#fff",
                                p: 2,
                                minHeight: "600px",
                                borderRadius: 1,
                                overflow: "hidden",
                            }}
                        >
                            {/* ✅ File preview frame */}
                            <Box
                                component="iframe"
                                src={`${API_BASE_URL}/documents/view.php?id=${previewDocument.id}`}
                                width="100%"
                                height="600px"
                                sx={{
                                    border: '1px solid #ccc',
                                    borderRadius: 1,
                                }}
                            />


                        </Box>
                    ) : (
                        <Typography>Loading document...</Typography>
                    )}
                </DialogContent>

                <DialogActions>
                    <Button onClick={() => setPreviewDialogOpen(false)}>Close</Button>
                    <Button
                        variant="contained"
                        color="primary"
                        startIcon={<PrintIcon />}
                        onClick={() => handlePrintDocument()}
                    >
                        Print
                    </Button>
                </DialogActions>
            </Dialog>

            {/* Cancel Dialog */}
            <Dialog open={cancelDialogOpen} onClose={() => setCancelDialogOpen(false)} maxWidth="sm" fullWidth>
                <DialogTitle sx={{ pb: 2, fontWeight: 600, fontSize: '1.25rem' }}>
                    Cancel Document
                </DialogTitle>
                <DialogContent dividers sx={{ pt: 3 }}>
                    {selectedDocumentForCancel && (
                        <Box>
                            <Box sx={{ mb: 3, p: 2, bgcolor: 'grey.50', borderRadius: 2 }}>
                                <Typography variant="body1" gutterBottom sx={{ fontWeight: 600, mb: 1 }}>
                                    Document: {selectedDocumentForCancel.title}
                                </Typography>
                                {selectedDocumentForCancel.description && (
                                    <Typography variant="body2" color="text.secondary" sx={{ fontSize: '0.9rem' }}>
                                        {selectedDocumentForCancel.description}
                                    </Typography>
                                )}
                            </Box>

                            <Alert severity="warning" sx={{ mt: 2, mb: 3, borderRadius: 2 }}>
                                <Typography variant="body2" sx={{ fontSize: '0.9rem', lineHeight: 1.6 }}>
                                    <strong>Warning:</strong> Cancelling this document will mark it as rejected and remove it from the workflow.
                                    This action cannot be undone.
                                </Typography>
                            </Alert>
                            <TextField
                                fullWidth
                                label="Reason for cancellation"
                                value={cancelNote}
                                onChange={(e) => setCancelNote(e.target.value)}
                                margin="normal"
                                multiline
                                minRows={3}
                                required
                                placeholder="Please provide a reason for cancelling this document..."
                                sx={{ 
                                    mb: 2,
                                    '& .MuiOutlinedInput-root': {
                                        borderRadius: 2,
                                    }
                                }}
                            />

                            {/* Status Display */}
                            {cancellingStatus === 'cancelling' && (
                                <Box sx={{ mt: 2, mb: 2 }}>
                                    <LinearProgress sx={{ borderRadius: 1, mb: 1.5 }} />
                                    <Typography variant="body2" color="primary" sx={{ fontWeight: 500 }}>
                                        Cancelling document...
                                    </Typography>
                                </Box>
                            )}

                            {cancellingStatus === 'success' && (
                                <Box sx={{ mt: 2, mb: 2 }}>
                                    <Alert severity="success" sx={{ borderRadius: 2 }}>
                                        Document cancelled successfully!
                                    </Alert>
                                </Box>
                            )}

                            {cancellingStatus === 'error' && (
                                <Box sx={{ mt: 2, mb: 2 }}>
                                    <Alert severity="error" sx={{ borderRadius: 2 }}>
                                        Failed to cancel document. Please try again.
                                    </Alert>
                                </Box>
                            )}
                        </Box>
                    )}
                </DialogContent>
                <DialogActions sx={{ p: 2.5, gap: 1 }}>
                    <Button
                        onClick={() => setCancelDialogOpen(false)}
                        disabled={cancellingStatus === 'cancelling'}
                        sx={{ 
                            borderRadius: 2,
                            textTransform: 'none',
                            px: 3
                        }}
                    >
                        Cancel
                    </Button>
                    <Button
                        onClick={handleConfirmCancel}
                        variant="contained"
                        color="error"
                        disabled={cancellingStatus === 'cancelling'}
                        sx={{ 
                            borderRadius: 2,
                            textTransform: 'none',
                            px: 3,
                            fontWeight: 600
                        }}
                    >
                        Confirm Cancel
                    </Button>
                </DialogActions>
            </Dialog>
        </Box>
    );
};

export default Documents;