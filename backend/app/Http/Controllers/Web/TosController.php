<?php
namespace App\Http\Controllers\Web;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class TosController extends Controller
{
    public function show() { return view('auth.tos'); }
    public function accept(Request $r)
    {
        $r->validate(['agree' => 'accepted']);
        auth()->user()->update(['tos_accepted_at' => now(), 'tos_version' => 'v1.0']);
        return redirect('/dashboard');
    }
}
