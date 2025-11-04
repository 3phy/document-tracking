<?php
require_once '../config/database.php';
require_once '../../vendor/autoload.php';

use setasign\Fpdi\Fpdi;
use Picqer\Barcode\BarcodeGeneratorPNG;
use Endroid\QrCode\QrCode;
use Endroid\QrCode\Writer\PngWriter;
use Dompdf\Dompdf;

$id = intval($_GET['id'] ?? 0);
$db = (new Database())->getConnection();

// ✅ Fetch document info
$stmt = $db->prepare("SELECT * FROM documents WHERE id = :id");
$stmt->bindParam(':id', $id);
$stmt->execute();
$doc = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$doc) {
    http_response_code(404);
    exit("Document not found.");
}

$barcodeValue = $doc['barcode'];
$relativePath = str_replace(['../', './', '\\'], '', $doc['file_path']);
$sourceFile = realpath(__DIR__ . '/../../' . $relativePath);

if (!$sourceFile || !file_exists($sourceFile)) {
    http_response_code(404);
    exit("File not found on server.");
}

// ✅ Prepare converted folder
$convertedDir = __DIR__ . '/../../uploads/converted/';
if (!file_exists($convertedDir)) mkdir($convertedDir, 0777, true);
$convertedPDF = $convertedDir . $barcodeValue . '.pdf';

// ✅ Convert file to PDF if necessary
$ext = strtolower(pathinfo($sourceFile, PATHINFO_EXTENSION));
if (!file_exists($convertedPDF)) {
    if (in_array($ext, ['jpg', 'jpeg', 'png'])) {
        $pdf = new Fpdi();
        $pdf->AddPage();
        $pdf->Image($sourceFile, 10, 10, 190);
        $pdf->Output($convertedPDF, 'F');
    } elseif (in_array($ext, ['doc', 'docx'])) {
        $cmd = "soffice --headless --convert-to pdf --outdir " . escapeshellarg($convertedDir) . " " . escapeshellarg($sourceFile);
        exec($cmd);
    } elseif ($ext === 'txt') {
        $text = nl2br(htmlspecialchars(file_get_contents($sourceFile)));
        $html = "<pre style='font-family: DejaVu Sans, monospace;'>$text</pre>";
        $dompdf = new Dompdf();
        $dompdf->loadHtml($html);
        $dompdf->setPaper('A4');
        $dompdf->render();
        file_put_contents($convertedPDF, $dompdf->output());
    } elseif ($ext === 'pdf') {
        copy($sourceFile, $convertedPDF);
    } else {
        exit("Unsupported file type for preview.");
    }
}

if (!file_exists($convertedPDF) || filesize($convertedPDF) === 0) {
    exit("Conversion failed or invalid PDF generated.");
}

// ✅ Generate barcode
$generator = new BarcodeGeneratorPNG();
$barcodeImg = $generator->getBarcode($barcodeValue, $generator::TYPE_CODE_128);
$barcodeTmp = sys_get_temp_dir() . '/' . $barcodeValue . '_barcode.png';
file_put_contents($barcodeTmp, $barcodeImg);

// ✅ Generate QR Code (link to this document)
$qrCode = QrCode::create('http://localhost/document-tracking/view.php?id=' . $id)
    ->setSize(80);
$writer = new PngWriter();
$qrResult = $writer->write($qrCode);
$qrTmp = sys_get_temp_dir() . '/' . $barcodeValue . '_qr.png';
$qrResult->saveToFile($qrTmp);

// ✅ Merge Barcode + QR (only on first page)
$pdf = new Fpdi();
try {
    $pageCount = $pdf->setSourceFile($convertedPDF);
} catch (Exception $e) {
    $pdf->AddPage('P', 'A4');
    $pageCount = 1;
}

for ($pageNo = 1; $pageNo <= $pageCount; $pageNo++) {
    try {
        $tpl = $pdf->importPage($pageNo);
        $size = $pdf->getTemplateSize($tpl);
        $orientation = $size['width'] > $size['height'] ? 'L' : 'P';
        $pdf->AddPage($orientation, [$size['width'], $size['height']]);
        $pdf->useTemplate($tpl, 0, 0, $size['width'], $size['height']);
    } catch (Exception $e) {
        $pdf->AddPage('P', 'A4');
    }

    // ✅ Add Barcode + QR only on FIRST PAGE
if ($pageNo === 1) {
    // --- A4 page geometry (mm) ---
    $pageWidth  = $pdf->GetPageWidth();   // ~210
    $pageHeight = $pdf->GetPageHeight();  // ~297

    // --- Margins + sizes ---
    $marginRight  = 10;
    $marginBottom = 10;
    $qrSize        = 18;
    $barcodeWidth  = 26;
    $barcodeHeight = 8;
    $spacing       = 2;

    // --- Position side-by-side at bottom-right ---
    $qrX = $pageWidth - $qrSize - $marginRight;
    $qrY = $pageHeight - $qrSize - $marginBottom;
    $barcodeX = $qrX - $barcodeWidth - $spacing;
    $barcodeY = $qrY + ($qrSize - $barcodeHeight) / 2;

    // --- White background to prevent overlap ---
    $pdf->SetFillColor(255, 255, 255);
    $pdf->Rect(
        $barcodeX - 2,
        $qrY - 2,
        $barcodeWidth + $qrSize + $spacing + 4,
        $qrSize + 4,
        'F'
    );

    // --- Barcode ---
    $pdf->Image($barcodeTmp, $barcodeX, $barcodeY, $barcodeWidth, $barcodeHeight);

    // --- QR ---
    $pdf->Image($qrTmp, $qrX, $qrY, $qrSize, $qrSize);
}



}

// ✅ Output as inline PDF
header('Content-Type: application/pdf');
$pdf->Output('I', $barcodeValue . '_preview.pdf');
?>
