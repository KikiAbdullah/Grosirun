<?php
namespace App\Http\Controllers\Web;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $r)
    {
        $search = $r->get('search');
        $read   = $r->get('read');
        $query = auth()->user()->notifications()
            ->when($search, fn($q)=>$q->where(function($s) use ($search){
                $s->where('data->title','like',"%$search%")->orWhere('data->body','like',"%$search%");
            }))
            ->when($read==='1', fn($q)=>$q->whereNotNull('read_at'))
            ->when($read==='0', fn($q)=>$q->whereNull('read_at'))
            ->latest();
        $notifications = $query->paginate(20)->withQueryString();
        return view('notifications.index', compact('notifications','search','read'));
    }
    public function show(int $id) { return back(); }
    public function markAsRead(int $id) { auth()->user()->notifications()->where('id',$id)->update(['read_at'=>now()]); return back(); }
    public function markAllAsRead() { auth()->user()->unreadNotifications->markAsRead(); return back()->with('success','Semua dibaca'); }
}
