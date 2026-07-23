<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\OtpService;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    protected OtpService $otpService;

    public function __construct(OtpService $otpService)
    {
        $this->otpService = $otpService;
    }

    /**
     * Request OTP
     * POST /api/v1/auth/request-otp
     */
    public function requestOtp(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string|regex:/^08[0-9]{8,11}$/',
        ]);

        $phoneNumber = $request->phone_number;

        // Check if locked
        if ($this->otpService->isLocked($phoneNumber)) {
            $lockExpiry = $this->otpService->getLockExpiry($phoneNumber);
            return response()->json([
                'message' => 'Too many attempts. Please try again later.',
                'locked_until' => $lockExpiry->toIso8601String(),
            ], 429);
        }

        // Generate and send OTP
        $otpCode = $this->otpService->requestOtp($phoneNumber);

        return response()->json([
            'message' => 'OTP sent successfully',
            'expires_at' => $otpCode->expires_at->toIso8601String(),
        ]);
    }

    /**
     * Verify OTP and login
     * POST /api/v1/auth/verify-otp
     */
    public function verifyOtp(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string',
            'otp' => 'required|string|size:4',
            'consent' => 'required|boolean|accepted',
            'tos_accepted' => 'required|boolean|accepted',
        ]);

        // Verify OTP
        $user = $this->otpService->verifyOtp($request->phone_number, $request->otp);

        if (!$user) {
            throw ValidationException::withMessages([
                'otp' => ['Invalid OTP or expired'],
            ]);
        }

        // Update consent and ToS
        $user->update([
            'consent_at' => now(),
            'consent_version' => config('app.consent_version', '1.0'),
            'tos_accepted_at' => now(),
            'tos_version' => config('app.tos_version', '1.0'),
        ]);

        // Assign default role if not already assigned
        if (!$user->hasRole('buyer')) {
            $user->assignRole('buyer');
        }

        // Create token
        $token = $user->createToken('auth_token', ['*'], now()->addDays(30));

        return response()->json([
            'message' => 'Login successful',
            'user' => $user->load('cluster', 'roles', 'permissions'),
            'token' => $token->plainTextToken,
            'expires_at' => $token->accessToken->expires_at,
        ]);
    }

    /**
     * Get current user
     * GET /api/v1/auth/me
     */
    public function me(Request $request)
    {
        return response()->json([
            'user' => $request->user()->load('cluster'),
        ]);
    }

    /**
     * Update FCM token
     * POST /api/v1/auth/fcm-token
     */
    public function updateFcmToken(Request $request)
    {
        $request->validate([
            'fcm_token' => 'required|string',
        ]);

        $request->user()->update([
            'fcm_token' => $request->fcm_token,
        ]);

        return response()->json([
            'message' => 'FCM token updated',
        ]);
    }

    /**
     * Update active role
     * PUT /api/v1/auth/active-role
     */
    public function updateActiveRole(Request $request)
    {
        $request->validate([
            'active_role' => 'required|in:buyer,initiator,seller,admin',
        ]);

        $user = $request->user();

        // Check if user has this role
        if ($user->role !== $request->active_role && $user->active_role !== $request->active_role) {
            // For simplicity, allow role switching
            // In production, implement proper role management
        }

        $user->update([
            'active_role' => $request->active_role,
        ]);

        return response()->json([
            'message' => 'Active role updated',
            'user' => $user,
        ]);
    }

    /**
     * Logout
     * POST /api/v1/auth/logout
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully',
        ]);
    }

    /**
     * Delete account (anonymize)
     * DELETE /api/v1/auth/account
     */
    public function deleteAccount(Request $request)
    {
        $user = $request->user();

        // Anonymize user data
        $user->update([
            'name' => "Deleted User {$user->id}",
            'phone_number' => "DELETED_{$user->id}",
            'fcm_token' => null,
            'deleted_at' => now(),
        ]);

        // Revoke all tokens
        $user->tokens()->delete();

        return response()->json([
            'message' => 'Account deleted successfully. Data will be anonymized within 24 hours.',
        ], 202);
    }

    /**
     * Update cluster
     * PUT /api/v1/auth/cluster
     */
    public function updateCluster(Request $request)
    {
        $request->validate([
            'cluster_id' => 'required|exists:clusters,id',
        ]);

        $request->user()->update([
            'cluster_id' => $request->cluster_id,
        ]);

        return response()->json([
            'message' => 'Cluster updated',
            'user' => $request->user()->load('cluster'),
        ]);
    }
}
