<?php
namespace App\Http\Controllers\Web;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function index() { return view('profile.index'); }
    public function switchRole(Request $r)
    {
        $r->validate(['role' => 'required|in:buyer,initiator,seller,admin']);
        auth()->user()->update(['active_role' => $r->role]);
        session(['active_role' => $r->role]);
        return back()->with('success', 'Role aktif diubah ke '.ucfirst($r->role));
    }
}
