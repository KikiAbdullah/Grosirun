<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Web\{WebAuthController,ConsentController,TosController,ProfileController,NotificationController,CampaignController,OrderController,DistributionController,PurchaseOrderController,ProductController,OfferController,AdminController,DashboardController};

Route::get('/', fn()=>auth()->check()?redirect('/dashboard'):redirect('/login'));
Route::middleware('guest')->group(function(){
    Route::get('/login',[WebAuthController::class,'showLogin'])->name('login');
    Route::post('/login',[WebAuthController::class,'login'])->name('login.submit');
    Route::get('/register',[WebAuthController::class,'showRegister'])->name('register');
    Route::post('/register',[WebAuthController::class,'register'])->name('register.submit');
});
Route::post('/auth/request-otp',[WebAuthController::class,'requestOtp'])->name('auth.request-otp');
Route::post('/logout',[WebAuthController::class,'logout'])->name('logout');

Route::middleware('auth')->group(function(){
    Route::get('/consent',[ConsentController::class,'show'])->name('consent.show');
    Route::post('/consent/accept',[ConsentController::class,'accept'])->name('consent.accept');
    Route::get('/tos',[TosController::class,'show'])->name('tos.show');
    Route::post('/tos/accept',[TosController::class,'accept'])->name('tos.accept');

    // Authenticated routes (simplified — skip full middleware for now)
    Route::get('/dashboard',[DashboardController::class,'index'])->name('dashboard');
    Route::get('/home',fn()=>redirect('/dashboard'))->name('home');
    Route::get('/profile',[ProfileController::class,'index'])->name('profile.index');
    Route::post('/profile/switch-role',[ProfileController::class,'switchRole'])->name('profile.switch-role');
    Route::get('/notifications',[NotificationController::class,'index'])->name('notifications.index');
    Route::get('/notifications/{id}',[NotificationController::class,'show'])->name('notifications.show');
    Route::post('/notifications/{id}/read',[NotificationController::class,'markAsRead'])->name('notifications.read');
    Route::post('/notifications/read-all',[NotificationController::class,'markAllAsRead'])->name('notifications.read-all');

    // Buyer
    Route::get('/campaigns',[CampaignController::class,'index'])->name('campaigns.index');
    Route::get('/campaigns/manage',[CampaignController::class,'manage'])->name('campaigns.manage');
    Route::get('/campaigns/create',[CampaignController::class,'create'])->name('campaigns.create');
    Route::post('/campaigns',[CampaignController::class,'store'])->name('campaigns.store');
    Route::get('/campaigns/{uuid}',[CampaignController::class,'show'])->name('campaigns.show');
    Route::get('/campaigns/{uuid}/edit',[CampaignController::class,'edit'])->name('campaigns.edit');
    Route::put('/campaigns/{uuid}',[CampaignController::class,'update'])->name('campaigns.update');
    Route::post('/campaigns/{uuid}/extend',[CampaignController::class,'extend'])->name('campaigns.extend');
    Route::post('/campaigns/{uuid}/cancel',[CampaignController::class,'cancel'])->name('campaigns.cancel');
    Route::post('/campaigns/{uuid}/complete',[CampaignController::class,'complete'])->name('campaigns.complete');
    Route::get('/campaigns/{uuid}/recap',[CampaignController::class,'recap'])->name('campaigns.recap');
    Route::post('/campaigns/{uuid}/join',[OrderController::class,'store'])->name('orders.store');
    Route::get('/orders',[OrderController::class,'index'])->name('orders.index');
    Route::get('/orders/validate',[OrderController::class,'validateIndex'])->name('orders.validate');
    Route::get('/orders/{uuid}',[OrderController::class,'show'])->name('orders.show');
    Route::delete('/orders/{uuid}',[OrderController::class,'destroy'])->name('orders.destroy');
    Route::post('/orders/{uuid}/proof',[OrderController::class,'uploadProof'])->name('orders.upload-proof');
    Route::post('/orders/{uuid}/take',[OrderController::class,'markAsTaken'])->name('orders.take');
    Route::post('/orders/{uuid}/validate',[OrderController::class,'validateOrder'])->name('orders.validate-order');
    Route::post('/orders/{uuid}/reject',[OrderController::class,'rejectOrder'])->name('orders.reject');
    Route::post('/orders/batch-validate',[OrderController::class,'batchValidate'])->name('orders.batch-validate');
    Route::get('/distribution',[DistributionController::class,'index'])->name('distribution.index');

    // Purchase Orders
    Route::get('/purchase-orders',[PurchaseOrderController::class,'index'])->name('purchase-orders.index');
    Route::get('/purchase-orders/create',[PurchaseOrderController::class,'create'])->name('purchase-orders.create');
    Route::post('/purchase-orders',[PurchaseOrderController::class,'store'])->name('purchase-orders.store');
    Route::get('/purchase-orders/{uuid}',[PurchaseOrderController::class,'show'])->name('purchase-orders.show');
    Route::post('/purchase-orders/{uuid}/accept',[PurchaseOrderController::class,'accept'])->name('purchase-orders.accept');
    Route::post('/purchase-orders/{uuid}/reject',[PurchaseOrderController::class,'reject'])->name('purchase-orders.reject');
    Route::post('/purchase-orders/{uuid}/confirm-payment',[PurchaseOrderController::class,'confirmPayment'])->name('purchase-orders.confirm-payment');
    Route::post('/purchase-orders/{uuid}/status',[PurchaseOrderController::class,'updateStatus'])->name('purchase-orders.update-status');
    Route::post('/purchase-orders/{uuid}/documents',[PurchaseOrderController::class,'uploadDocument'])->name('purchase-orders.upload-document');

    // Seller
    Route::get('/products',[ProductController::class,'index'])->name('products.index');
    Route::get('/products/create',[ProductController::class,'create'])->name('products.create');
    Route::post('/products',[ProductController::class,'store'])->name('products.store');
    Route::get('/products/{id}/edit',[ProductController::class,'edit'])->name('products.edit');
    Route::put('/products/{id}',[ProductController::class,'update'])->name('products.update');
    Route::delete('/products/{id}',[ProductController::class,'destroy'])->name('products.destroy');
    Route::get('/offers',[OfferController::class,'index'])->name('offers.index');
    Route::get('/offers/create',[OfferController::class,'create'])->name('offers.create');
    Route::post('/offers',[OfferController::class,'store'])->name('offers.store');
    Route::get('/offers/{id}/edit',[OfferController::class,'edit'])->name('offers.edit');
    Route::put('/offers/{id}',[OfferController::class,'update'])->name('offers.update');
    Route::delete('/offers/{id}',[OfferController::class,'destroy'])->name('offers.destroy');
    Route::post('/offers/{id}/submit',[OfferController::class,'submit'])->name('offers.submit');

    // Admin
    Route::prefix('admin')->group(function(){
        Route::get('/dashboard',[AdminController::class,'dashboard'])->name('admin.dashboard');
        Route::get('/suppliers/pending',[AdminController::class,'pendingSuppliers'])->name('admin.suppliers.pending');
        Route::post('/suppliers/{id}/verify',[AdminController::class,'verifySupplier'])->name('admin.suppliers.verify');
        Route::get('/offers/moderate',[AdminController::class,'moderateOffers'])->name('admin.offers.moderate');
        Route::post('/offers/{id}/moderate',[AdminController::class,'moderateOffer'])->name('admin.offers.moderate-action');
        Route::get('/users',[AdminController::class,'users'])->name('admin.users.index');
        Route::post('/users/{id}/roles',[AdminController::class,'manageRoles'])->name('admin.users.roles');
        Route::post('/users/{id}/suspend',[AdminController::class,'suspendUser'])->name('admin.users.suspend');
        Route::post('/users/{id}/unsuspend',[AdminController::class,'unsuspendUser'])->name('admin.users.unsuspend');
        Route::get('/audit-logs',[AdminController::class,'auditLogs'])->name('admin.audit-logs');
        Route::get('/disputes',[AdminController::class,'disputes'])->name('admin.disputes.index');
        Route::get('/disputes/{id}',[AdminController::class,'showDispute'])->name('admin.disputes.show');
        Route::post('/disputes/{id}/resolve',[AdminController::class,'resolveDispute'])->name('admin.disputes.resolve');
    });
});
Route::get('/health',fn()=>response()->json(['status'=>'ok','timestamp'=>now()->toIso8601String()]));
