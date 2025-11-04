<?php
require __DIR__ . '/vendor/autoload.php';

use Endroid\QrCode\QrCode;
use Endroid\QrCode\Writer\PngWriter;

$qr = QrCode::create('Test QR Code')->setSize(150);
$writer = new PngWriter();
$result = $writer->write($qr);

header('Content-Type: image/png');
echo $result->getString();
