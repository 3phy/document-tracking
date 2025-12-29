<?php
// api/utils/document_processor.php
// Utility functions for processing documents (barcode/QR embedding)

require_once __DIR__ . '/../../vendor/autoload.php';

use setasign\Fpdi\Fpdi;
use Picqer\Barcode\BarcodeGeneratorPNG;
use Endroid\QrCode\QrCode;
use Endroid\QrCode\Writer\PngWriter;
use Dompdf\Dompdf;

/**
 * Embed barcode and QR code on the first page of a document
 * @param string $sourceFile Path to source file
 * @param string $barcodeValue Barcode value to embed
 * @param int $documentId Document ID for QR code
 * @return string|false Path to processed file, or false on failure
 */
function embedBarcodeAndQR($sourceFile, $barcodeValue, $documentId) {
    try {
        $ext = strtolower(pathinfo($sourceFile, PATHINFO_EXTENSION));
        $uploadDir = dirname(dirname(__DIR__)) . DIRECTORY_SEPARATOR . 'uploads' . DIRECTORY_SEPARATOR . 'documents';
        
        // Generate barcode image
        $barcodeGenerator = new BarcodeGeneratorPNG();
        $barcodeImg = $barcodeGenerator->getBarcode($barcodeValue, BarcodeGeneratorPNG::TYPE_CODE_128);
        $barcodeTmp = sys_get_temp_dir() . DIRECTORY_SEPARATOR . "{$barcodeValue}_barcode_" . uniqid() . ".png";
        file_put_contents($barcodeTmp, $barcodeImg);
        
        // Generate QR code image
        $qrTmp = sys_get_temp_dir() . DIRECTORY_SEPARATOR . "{$barcodeValue}_qr_" . uniqid() . ".png";
        $qrWriter = new PngWriter();
        $qrCode = QrCode::create("Document ID: {$documentId}")->setSize(80);
        $qrWriter->write($qrCode)->saveToFile($qrTmp);
        
        // Convert source file to PDF if needed
        $convertedPDF = sys_get_temp_dir() . DIRECTORY_SEPARATOR . "{$barcodeValue}_converted_" . uniqid() . ".pdf";
        
        if (in_array($ext, ['jpg', 'jpeg', 'png'])) {
            // Convert image to PDF
            $pdf = new Fpdi();
            $pdf->AddPage();
            $pdf->Image($sourceFile, 10, 10, 190);
            $pdf->Output($convertedPDF, 'F');
        } elseif (in_array($ext, ['doc', 'docx'])) {
            // Try to convert using LibreOffice (if available)
            $convertedDir = sys_get_temp_dir();
            $outputFile = $convertedDir . DIRECTORY_SEPARATOR . basename($sourceFile, ".{$ext}") . ".pdf";
            
            $command = "soffice --headless --convert-to pdf --outdir " 
                . escapeshellarg($convertedDir) . " " 
                . escapeshellarg($sourceFile) . " 2>&1";
            
            exec($command, $output, $returnCode);
            
            if ($returnCode === 0 && file_exists($outputFile)) {
                copy($outputFile, $convertedPDF);
                @unlink($outputFile);
            } else {
                // Fallback: create a simple PDF with file info
                $pdf = new Fpdi();
                $pdf->AddPage();
                $pdf->SetFont('Arial', 'B', 16);
                $pdf->Cell(0, 10, 'Document: ' . basename($sourceFile), 0, 1);
                $pdf->SetFont('Arial', '', 12);
                $pdf->Cell(0, 10, 'This document requires conversion. Original file preserved.', 0, 1);
                $pdf->Output($convertedPDF, 'F');
            }
        } elseif ($ext === 'txt') {
            // Convert text to PDF
            $dompdf = new Dompdf();
            $content = file_get_contents($sourceFile);
            $dompdf->loadHtml('<pre style="font-family: monospace;">' . htmlspecialchars($content) . '</pre>');
            $dompdf->setPaper('A4');
            $dompdf->render();
            file_put_contents($convertedPDF, $dompdf->output());
        } elseif ($ext === 'pdf') {
            // Already PDF, just copy
            copy($sourceFile, $convertedPDF);
        } else {
            @unlink($barcodeTmp);
            @unlink($qrTmp);
            return false;
        }
        
        if (!file_exists($convertedPDF) || filesize($convertedPDF) === 0) {
            @unlink($barcodeTmp);
            @unlink($qrTmp);
            return false;
        }
        
        // Embed barcode and QR code on first page
        $pdf = new Fpdi();
        $pageCount = $pdf->setSourceFile($convertedPDF);
        
        for ($i = 1; $i <= $pageCount; $i++) {
            $tpl = $pdf->importPage($i);
            $size = $pdf->getTemplateSize($tpl);
            $pdf->AddPage($size['orientation'], [$size['width'], $size['height']]);
            $pdf->useTemplate($tpl);
            
            // Embed on first page only
            if ($i === 1) {
                // Position barcode and QR code at bottom right
                $pageWidth = $size['width'];
                $pageHeight = $size['height'];
                
                // Barcode: 40mm wide, 10mm high, positioned at bottom right
                $barcodeWidth = 40;
                $barcodeHeight = 10;
                $barcodeX = $pageWidth - $barcodeWidth - 10; // 10mm from right edge
                $barcodeY = $pageHeight - $barcodeHeight - 10; // 10mm from bottom
                
                // QR code: 15mm x 15mm, positioned next to barcode
                $qrSize = 15;
                $qrX = $pageWidth - $qrSize - 10;
                $qrY = $barcodeY - $qrSize - 5; // 5mm above barcode
                
                $pdf->Image($barcodeTmp, $barcodeX, $barcodeY, $barcodeWidth, $barcodeHeight);
                $pdf->Image($qrTmp, $qrX, $qrY, $qrSize, $qrSize);
            }
        }
        
        // Determine output file path
        // For non-PDF files, we'll save as PDF with barcode embedded
        // For PDF files, we'll replace the original
        $ext = strtolower(pathinfo($sourceFile, PATHINFO_EXTENSION));
        if ($ext === 'pdf') {
            // For PDFs, replace the original file
            $outputFile = $sourceFile;
        } else {
            // For other formats, save as PDF
            $outputFile = dirname($sourceFile) . DIRECTORY_SEPARATOR . 
                         pathinfo($sourceFile, PATHINFO_FILENAME) . '.pdf';
        }
        
        // Save processed PDF
        $pdf->Output($outputFile, 'F');
        
        // Cleanup temp files
        @unlink($barcodeTmp);
        @unlink($qrTmp);
        @unlink($convertedPDF);
        
        // Return the output file path
        if (file_exists($outputFile)) {
            return $outputFile;
        }
        
        return false;
    } catch (Exception $e) {
        error_log('Barcode embedding failed: ' . $e->getMessage());
        return false;
    }
}

