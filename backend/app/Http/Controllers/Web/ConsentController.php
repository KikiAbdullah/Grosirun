<?php
namespace App\Http\Controllers\Web;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ConsentController extends Controller
{
    public function show() { return view('auth.consent'); }
    public function accept(Request $r)
    {
        $r->validate(['agree' => 'accepted']);
        auth()->user()->update(['consent_at' => now(), 'consent_version' => 'v1.0']);
        return redirect('/tos');
    }
}
