<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Get notifications for user
     * GET /api/v1/notifications
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        $notifications = Notification::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->limit(50)
            ->get();

        return response()->json([
            'notifications' => $notifications,
        ]);
    }

    /**
     * Get unread count
     * GET /api/v1/notifications/unread-count
     */
    public function unreadCount(Request $request)
    {
        $user = $request->user();
        
        $count = Notification::where('user_id', $user->id)
            ->whereNull('read_at')
            ->count();

        return response()->json([
            'unread_count' => $count,
        ]);
    }

    /**
     * Mark notification as read
     * POST /api/v1/notifications/{id}/read
     */
    public function markAsRead(Request $request, int $id)
    {
        $user = $request->user();
        
        $notification = Notification::where('id', $id)
            ->where('user_id', $user->id)
            ->firstOrFail();

        $notification->update(['read_at' => now()]);

        return response()->json([
            'message' => 'Notification marked as read',
        ]);
    }

    /**
     * Mark all notifications as read
     * POST /api/v1/notifications/read-all
     */
    public function markAllAsRead(Request $request)
    {
        $user = $request->user();
        
        Notification::where('user_id', $user->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json([
            'message' => 'All notifications marked as read',
        ]);
    }

    /**
     * Create notification (internal use)
     */
    public static function create(int $userId, string $title, string $body, ?array $data = null): Notification
    {
        return Notification::create([
            'user_id' => $userId,
            'title' => $title,
            'body' => $body,
            'data' => $data,
        ]);
    }
}
