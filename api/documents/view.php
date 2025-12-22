<?php
require_once '../config/cors.php';
require_once '../config/database.php';
require_once '../../vendor/autoload.php';

use setasign\Fpdi\Fpdi;
use Picqer\Barcode\BarcodeGeneratorPNG;
use Endroid\QrCode\QrCode;
use Endroid\QrCode\Writer\PngWriter;
use Dompdf\Dompdf;

/* ======================================================
   FETCH DOCUMENT
====================================================== */
$id = (int)($_GET['id'] ?? 0);
if (!$id) {
    http_response_code(400);
    exit('Invalid document ID');
}

$db = (new Database())->getConnection();

$stmt = $db->prepare("SELECT * FROM documents WHERE id = :id");
$stmt->bindParam(':id', $id, PDO::PARAM_INT);
$stmt->execute();
$doc = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$doc) {
    http_response_code(404);
    exit('Document not found');
}

/* ======================================================
   RESOLVE FILE PATH
====================================================== */
$barcodeValue = $doc['barcode'];
$uploadsRoot = realpath(__DIR__ . '/../../uploads');

$possiblePaths = [
    $uploadsRoot . '/' . ltrim($doc['file_path'], '/'),
    $uploadsRoot . '/' . basename($doc['file_path']),
    realpath(__DIR__ . '/../../' . ltrim($doc['file_path'], '/'))
];

$sourceFile = null;
foreach ($possiblePaths as $path) {
    if ($path && file_exists($path)) {
        $sourceFile = $path;
        break;
    }
}

if (!$sourceFile) {
    http_response_code(404);
    exit('File not found on server');
}


if (!$uploadsRoot || !file_exists($sourceFile)) {
    http_response_code(404);
    exit('File not found on server');
}

/* ======================================================
   PREPARE CONVERTED PDF
====================================================== */
$convertedDir = __DIR__ . '/../../uploads/converted/';
if (!is_dir($convertedDir)) {
    mkdir($convertedDir, 0777, true);
}
$convertedPDF = $convertedDir . $barcodeValue . '.pdf';

/* ======================================================
   CONVERT FILE TO PDF IF NEEDED
====================================================== */
$ext = strtolower(pathinfo($sourceFile, PATHINFO_EXTENSION));

if (!file_exists($convertedPDF)) {
    if (in_array($ext, ['jpg', 'jpeg', 'png'])) {
        $pdf = new Fpdi();
        $pdf->AddPage();
        $pdf->Image($sourceFile, 10, 10, 190);
        $pdf->Output($convertedPDF, 'F');

    } elseif (in_array($ext, ['doc', 'docx'])) {
        exec(
            'soffice --headless --convert-to pdf --outdir '
            . escapeshellarg($convertedDir) . ' '
            . escapeshellarg($sourceFile)
        );

    } elseif ($ext === 'txt') {
        $dompdf = new Dompdf();
        $dompdf->loadHtml('<pre>' . htmlspecialchars(file_get_contents($sourceFile)) . '</pre>');
        $dompdf->setPaper('A4');
        $dompdf->render();
        file_put_contents($convertedPDF, $dompdf->output());

    } elseif ($ext === 'pdf') {
        copy($sourceFile, $convertedPDF);

    } else {
        exit('Unsupported file type');
    }
}

if (!file_exists($convertedPDF) || filesize($convertedPDF) === 0) {
    exit('PDF generation failed');
}

/* ======================================================
   BARCODE + QR
====================================================== */
$barcodeImg = (new BarcodeGeneratorPNG())
    ->getBarcode($barcodeValue, BarcodeGeneratorPNG::TYPE_CODE_128);
$barcodeTmp = sys_get_temp_dir() . "/{$barcodeValue}_barcode.png";
file_put_contents($barcodeTmp, $barcodeImg);

$qrTmp = sys_get_temp_dir() . "/{$barcodeValue}_qr.png";
(new PngWriter())->write(
    QrCode::create("Document ID: $id")->setSize(80)
)->saveToFile($qrTmp);

/* ======================================================
   MERGE INTO FINAL PDF
====================================================== */
$pdf = new Fpdi();
$pageCount = $pdf->setSourceFile($convertedPDF);

for ($i = 1; $i <= $pageCount; $i++) {
    $tpl = $pdf->importPage($i);
    $size = $pdf->getTemplateSize($tpl);
    $pdf->AddPage();
    $pdf->useTemplate($tpl);

    if ($i === 1) {
        $pdf->Image($barcodeTmp, 150, 270, 40, 10);
        $pdf->Image($qrTmp, 190, 270, 15, 15);
    }
}

/* ======================================================
   OUTPUT INLINE
====================================================== */
if (ob_get_length()) ob_end_clean();

header('Content-Type: application/pdf');
header('Content-Disposition: inline; filename="preview.pdf"');
$pdf->Output('I');
exit;
