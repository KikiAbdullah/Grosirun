<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CampaignController;
use App\Http\Controllers\Api\V1\OrderController;
use App\Http\Controllers\Api\V1\NotificationController;

/*
|--------------------------------------------------------------------------
| API Routes - Grosirun V1
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Health check
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now()->toIso8601String(),
        'version' => '1.0.0',
    ]);
});

// Authentication routes (public)
Route::prefix('auth')->group(function () {
    Route::post('/request-otp', [AuthController::class, 'requestOtp']);
    Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
});

// Protected routes (require authentication)
Route::middleware('auth:sanctum')->group(function () {
    
    // Auth routes
    Route::prefix('auth')->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/fcm-token', [AuthController::class, 'updateFcmToken']);
        Route::put('/active-role', [AuthController::class, 'updateActiveRole']);
        Route::put('/cluster', [AuthController::class, 'updateCluster']);
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::delete('/account', [AuthController::class, 'deleteAccount']);
    });

    // Campaign routes
    Route::prefix('campaigns')->group(function () {
        // List campaigns - anyone can view
        Route::get('/', [CampaignController::class, 'index'])
            ->middleware('permission:view_campaigns');
        
        // Create campaign - initiator only
        Route::post('/', [CampaignController::class, 'store'])
            ->middleware('permission:create_campaigns');
        
        // View campaign detail - anyone can view
        Route::get('/{uuid}', [CampaignController::class, 'show'])
            ->middleware('permission:view_campaigns');
        
        // Campaign stats - initiator or admin
        Route::get('/{uuid}/stats', [CampaignController::class, 'stats'])
            ->middleware('permission:view_campaigns');
        
        // Campaign recap - initiator only
        Route::get('/{uuid}/recap', [CampaignController::class, 'recap'])
            ->middleware('permission:view_campaign_recap');
        
        // Extend campaign - initiator only
        Route::post('/{uuid}/extend', [CampaignController::class, 'extend'])
            ->middleware('permission:extend_campaigns');
        
        // Cancel campaign - initiator only
        Route::post('/{uuid}/cancel', [CampaignController::class, 'cancel'])
            ->middleware('permission:cancel_campaigns');
        
        // Complete distribution - initiator only
        Route::post('/{uuid}/complete-distribution', [CampaignController::class, 'completeDistribution'])
            ->middleware('permission:complete_distribution');
        
        // Campaign orders for validation - initiator only
        Route::get('/{uuid}/orders/pending', [OrderController::class, 'pendingValidation'])
            ->middleware('permission:view_all_orders');
        
        // Campaign orders for distribution - initiator only
        Route::get('/{uuid}/orders/distribution', [OrderController::class, 'distribution'])
            ->middleware('permission:view_all_orders');
    });

    // Order routes
    Route::prefix('orders')->group(function () {
        // List own orders
        Route::get('/', [OrderController::class, 'index'])
            ->middleware('permission:view_orders');
        
        // Create order - buyer and initiator
        Route::post('/', [OrderController::class, 'store'])
            ->middleware('permission:create_orders');
        
        // Batch validate - initiator only
        Route::post('/batch-validate', [OrderController::class, 'batchValidate'])
            ->middleware('permission:batch_validate_orders');
        
        // View order detail
        Route::get('/{uuid}', [OrderController::class, 'show'])
            ->middleware('permission:view_orders');
        
        // Cancel own order
        Route::delete('/{uuid}', [OrderController::class, 'destroy'])
            ->middleware('permission:cancel_orders');
        
        // Upload payment proof
        Route::post('/{uuid}/proof', [OrderController::class, 'uploadProof'])
            ->middleware('permission:upload_proof');
        
        // Get proof URL
        Route::get('/{uuid}/proof-url', [OrderController::class, 'proofUrl'])
            ->middleware('permission:view_orders');
        
        // Validate order - initiator only
        Route::post('/{uuid}/validate', [OrderController::class, 'validate'])
            ->middleware('permission:validate_orders');
        
        // Reject order - initiator only
        Route::post('/{uuid}/reject', [OrderController::class, 'reject'])
            ->middleware('permission:reject_orders');
        
        // Mark order as taken - initiator only
        Route::post('/{uuid}/take', [OrderController::class, 'markAsTaken'])
            ->middleware('permission:mark_orders_taken');
    });

    // Notification routes
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index'])
            ->middleware('permission:view_notifications');
        
        Route::get('/unread-count', [NotificationController::class, 'unreadCount'])
            ->middleware('permission:view_notifications');
        
        Route::post('/{id}/read', [NotificationController::class, 'markAsRead'])
            ->middleware('permission:mark_notifications_read');
        
        Route::post('/read-all', [NotificationController::class, 'markAllAsRead'])
            ->middleware('permission:mark_notifications_read');
    });
});
