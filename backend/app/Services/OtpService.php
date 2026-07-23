<?php

namespace App\Services;

use App\Models\OtpCode;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class OtpService
{
    /**
     * Generate and send OTP to phone number
     */
    public function requestOtp(string $phoneNumber): OtpCode
    {
        // Generate 4-digit OTP
        $otp = str_pad(rand(0, 9999), 4, '0', STR_PAD_LEFT);
        
        // Hash OTP for security
        $otpHash = Hash::make($otp);
        
        // Create OTP record (expires in 5 minutes)
        $otpCode = OtpCode::create([
            'phone_number' => $phoneNumber,
            'otp_hash' => $otpHash,
            'expires_at' => Carbon::now()->addMinutes(5),
        ]);

        // Send OTP via WhatsApp (Fonnte)
        $this->sendOtpViaWhatsApp($phoneNumber, $otp);

        return $otpCode;
    }

    /**
     * Verify OTP code
     */
    public function verifyOtp(string $phoneNumber, string $otp): ?User
    {
        // Find valid OTP for this phone number
        $otpCode = OtpCode::forPhone($phoneNumber)
            ->valid()
            ->latest()
            ->first();

        if (!$otpCode) {
            return null;
        }

        // Check if OTP matches
        if (!Hash::check($otp, $otpCode->otp_hash)) {
            // Increment attempts and lock if exceeded
            $otpCode->incrementAttempts(5);
            return null;
        }

        // Mark OTP as verified
        $otpCode->markAsVerified();

        // Find or create user
        $user = User::firstOrCreate(
            ['phone_number' => $phoneNumber],
            [
                'name' => 'User ' . Str::random(8),
                'role' => 'buyer',
            ]
        );

        return $user;
    }

    /**
     * Send OTP via WhatsApp API (Fonnte)
     */
    private function sendOtpViaWhatsApp(string $phoneNumber, string $otp): void
    {
        $token = config('services.fonnte.token');
        $url = config('services.fonnte.url');

        if (!$token || !$url) {
            // Fallback: log OTP for development
            logger()->info("OTP for {$phoneNumber}: {$otp}");
            return;
        }

        try {
            Http::withToken($token)
                ->post($url, [
                    'target' => $phoneNumber,
                    'message' => "🔐 Kode OTP Grosirun Anda: *{$otp}*\n\nKode ini berlaku selama 5 menit. Jangan bagikan kepada siapapun.\n\n_Yuk, Grosirun Bareng!_",
                ]);
        } catch (\Exception $e) {
            logger()->error("Failed to send OTP via WhatsApp: " . $e->getMessage());
            // Fallback: log OTP for debugging
            logger()->info("OTP for {$phoneNumber}: {$otp}");
        }
    }

    /**
     * Check if phone number is locked (too many attempts)
     */
    public function isLocked(string $phoneNumber): bool
    {
        $otpCode = OtpCode::forPhone($phoneNumber)
            ->latest()
            ->first();

        return $otpCode && $otpCode->isLocked();
    }

    /**
     * Get lock expiry time
     */
    public function getLockExpiry(string $phoneNumber): ?Carbon
    {
        $otpCode = OtpCode::forPhone($phoneNumber)
            ->latest()
            ->first();

        return $otpCode?->locked_until;
    }

    /**
     * Clean up expired OTPs (scheduled job)
     */
    public function cleanupExpired(): int
    {
        return OtpCode::where('expires_at', '<', Carbon::now())
            ->delete();
    }
}
