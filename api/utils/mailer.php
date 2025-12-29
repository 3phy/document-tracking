<?php
/**
 * Mailer Utility (PHPMailer)
 * Centralizes PHPMailer configuration via .env settings.
 */
require_once __DIR__ . '/../config/env.php';

// Prefer Composer autoload if present
$composerAutoload = __DIR__ . '/../../vendor/autoload.php';
if (file_exists($composerAutoload)) {
    require_once $composerAutoload;
}

// Fallback: repo-local PHPMailer (api/libs/PHPMailer)
if (!class_exists('\\PHPMailer\\PHPMailer\\PHPMailer')) {
    $localBase = __DIR__ . '/../libs/PHPMailer/src/';
    require_once $localBase . 'Exception.php';
    require_once $localBase . 'PHPMailer.php';
    require_once $localBase . 'SMTP.php';
}

use PHPMailer\PHPMailer\PHPMailer;

class Mailer {
    /**
     * Create a configured PHPMailer instance.
     * @return PHPMailer
     * @throws Exception
     */
    public static function create(): PHPMailer {
        $host = Env::get('SMTP_HOST');
        $port = (int)Env::get('SMTP_PORT', '587');
        $user = Env::get('SMTP_USER', '');
        $pass = Env::get('SMTP_PASS', '');
        $secure = strtolower(trim(Env::get('SMTP_SECURE', 'tls'))); // tls|ssl|none

        $fromEmail = Env::get('SMTP_FROM_EMAIL', $user);
        $fromName  = Env::get('SMTP_FROM_NAME', 'Document Progress Tracking System');

        if (empty($host) || empty($fromEmail)) {
            throw new Exception('Email service is not configured (SMTP_HOST/SMTP_FROM_EMAIL).');
        }

        $mail = new PHPMailer(true);
        $mail->isSMTP();
        $mail->Host = $host;
        $mail->Port = $port ?: 587;

        // Auth is optional if your SMTP supports it (but most require it)
        $mail->SMTPAuth = !empty($user);
        if (!empty($user)) {
            $mail->Username = $user;
            $mail->Password = $pass;
        }

        if ($secure === 'ssl') {
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
        } elseif ($secure === 'tls') {
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        } else {
            $mail->SMTPSecure = false;
            $mail->SMTPAutoTLS = false;
        }

        $mail->CharSet = 'UTF-8';
        $mail->setFrom($fromEmail, $fromName);

        return $mail;
    }

    /**
     * Send a password reset OTP email.
     * @param string $toEmail
     * @param string|null $toName
     * @param string $otp
     * @param int $expiresMinutes
     * @return void
     */
    public static function sendPasswordResetOtp(string $toEmail, ?string $toName, string $otp, int $expiresMinutes): void {
        $appName = Env::get('APP_NAME', 'Document Progress Tracking System');

        $mail = self::create();
        $mail->addAddress($toEmail, $toName ?: '');
        $mail->isHTML(true);
        $mail->Subject = "{$appName} - Password Reset OTP";
        $mail->Body = "
            <div style=\"font-family: Arial, sans-serif; line-height: 1.6;\">
              <h2 style=\"margin:0 0 8px 0;\">Password Reset OTP</h2>
              <p style=\"margin:0 0 12px 0;\">Use the OTP below to reset your password:</p>
              <div style=\"
                display:inline-block;
                font-size:22px;
                letter-spacing:6px;
                padding:12px 16px;
                border:1px solid #ddd;
                border-radius:10px;
                background:#fafafa;
                font-weight:700;
              \">{$otp}</div>
              <p style=\"margin:12px 0 0 0; color:#555;\">This code expires in {$expiresMinutes} minutes.</p>
              <p style=\"margin:12px 0 0 0; color:#777; font-size:12px;\">If you didn’t request this, you can ignore this email.</p>
            </div>
        ";
        $mail->AltBody = "Your password reset OTP is: {$otp}. It expires in {$expiresMinutes} minutes.";

        $mail->send();
    }
}


