<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

class OtpCode extends Model
{
    use HasFactory;

    protected $fillable = [
        'phone_number',
        'otp_hash',
        'expires_at',
        'attempts',
        'locked_until',
        'verified',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'locked_until' => 'datetime',
        'verified' => 'boolean',
    ];

    /**
     * Check if OTP is expired
     */
    public function isExpired(): bool
    {
        return $this->expires_at->isPast();
    }

    /**
     * Check if OTP is locked
     */
    public function isLocked(): bool
    {
        return $this->locked_until && $this->locked_until->isFuture();
    }

    /**
     * Check if OTP is valid (not expired, not locked, not verified)
     */
    public function isValid(): bool
    {
        return !$this->isExpired() && !$this->isLocked() && !$this->verified;
    }

    /**
     * Increment attempts and lock if exceeded
     */
    public function incrementAttempts(int $maxAttempts = 5): void
    {
        $this->increment('attempts');
        
        if ($this->attempts >= $maxAttempts) {
            $this->update([
                'locked_until' => Carbon::now()->addMinutes(15),
            ]);
        }
    }

    /**
     * Mark OTP as verified
     */
    public function markAsVerified(): void
    {
        $this->update(['verified' => true]);
    }

    /**
     * Scope to filter by phone number
     */
    public function scopeForPhone($query, string $phoneNumber)
    {
        return $query->where('phone_number', $phoneNumber);
    }

    /**
     * Scope to filter valid OTPs
     */
    public function scopeValid($query)
    {
        return $query->where('verified', false)
                    ->where('expires_at', '>', Carbon::now())
                    ->where(function ($q) {
                        $q->whereNull('locked_until')
                          ->orWhere('locked_until', '<', Carbon::now());
                    });
    }
}
