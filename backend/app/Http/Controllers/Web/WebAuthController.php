<?php
namespace App\Http\Controllers\Web;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class WebAuthController extends Controller
{
    public function showLogin() { return view('auth.login'); }
    public function showRegister() { return view('auth.register'); }

    public function login(Request $r)
    {
        $r->validate([
            'phone_number' => 'required|string|min:10',
            'consent'      => 'accepted',
        ]);

        // Demo login: create or find user
        if ($r->has('demo_role')) {
            $user = User::firstOrCreate(
                ['phone_number' => $r->phone_number],
                ['name' => 'Demo User', 'password' => Hash::make('password')]
            );
            $user->update(['active_role' => $r->demo_role, 'consent_at' => now(), 'tos_accepted_at' => now()]);
            Auth::login($user);
            $r->session()->put('active_role', $r->demo_role);
            return redirect('/dashboard');
        }

        // Real OTP flow: store phone in session, redirect to OTP screen
        $r->session()->put('login_phone', $r->phone_number);
        return redirect('/otp');
    }

    public function register(Request $r)
    {
        $r->validate([
            'name'         => 'required|string|max:255',
            'phone_number' => 'required|string|min:10',
            'cluster_code' => 'nullable|string|max:20',
            'consent'      => 'accepted',
        ]);

        $user = User::firstOrCreate(
            ['phone_number' => $r->phone_number],
            ['name' => $r->name, 'password' => Hash::make('password'), 'active_role' => 'buyer']
        );
        $user->update(['name' => $r->name]);
        Auth::login($user);
        return redirect('/consent');
    }

    public function requestOtp(Request $r)
    {
        $r->validate(['phone_number' => 'required|string']);
        // In production: call OTP service
        return response()->json(['message' => 'OTP terkirim ke WhatsApp', 'otp' => '1234']);
    }

    public function logout(Request $r)
    {
        Auth::logout();
        $r->session()->invalidate();
        $r->session()->regenerateToken();
        return redirect('/login');
    }
}
