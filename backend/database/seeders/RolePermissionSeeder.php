<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolePermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // ============================================
        // CREATE PERMISSIONS
        // ============================================

        // Campaign Permissions
        $campaignPermissions = [
            ['name' => 'view_campaigns', 'description' => 'View all campaigns', 'group' => 'campaign'],
            ['name' => 'create_campaigns', 'description' => 'Create new campaigns', 'group' => 'campaign'],
            ['name' => 'update_campaigns', 'description' => 'Update own campaigns', 'group' => 'campaign'],
            ['name' => 'delete_campaigns', 'description' => 'Delete own campaigns', 'group' => 'campaign'],
            ['name' => 'extend_campaigns', 'description' => 'Extend campaign deadline', 'group' => 'campaign'],
            ['name' => 'cancel_campaigns', 'description' => 'Cancel campaigns', 'group' => 'campaign'],
            ['name' => 'complete_distribution', 'description' => 'Complete campaign distribution', 'group' => 'campaign'],
            ['name' => 'view_campaign_recap', 'description' => 'View campaign recap PDF', 'group' => 'campaign'],
            ['name' => 'manage_all_campaigns', 'description' => 'Manage all campaigns (admin)', 'group' => 'campaign'],
        ];

        // Order Permissions
        $orderPermissions = [
            ['name' => 'view_orders', 'description' => 'View own orders', 'group' => 'order'],
            ['name' => 'create_orders', 'description' => 'Create new orders', 'group' => 'order'],
            ['name' => 'cancel_orders', 'description' => 'Cancel own orders', 'group' => 'order'],
            ['name' => 'upload_proof', 'description' => 'Upload payment proof', 'group' => 'order'],
            ['name' => 'view_all_orders', 'description' => 'View all orders (initiator)', 'group' => 'order'],
            ['name' => 'validate_orders', 'description' => 'Validate order payments', 'group' => 'order'],
            ['name' => 'reject_orders', 'description' => 'Reject order payments', 'group' => 'order'],
            ['name' => 'batch_validate_orders', 'description' => 'Batch validate orders', 'group' => 'order'],
            ['name' => 'mark_orders_taken', 'description' => 'Mark orders as taken', 'group' => 'order'],
            ['name' => 'manage_all_orders', 'description' => 'Manage all orders (admin)', 'group' => 'order'],
        ];

        // Supplier Permissions
        $supplierPermissions = [
            ['name' => 'view_suppliers', 'description' => 'View suppliers', 'group' => 'supplier'],
            ['name' => 'create_suppliers', 'description' => 'Create suppliers', 'group' => 'supplier'],
            ['name' => 'update_suppliers', 'description' => 'Update suppliers', 'group' => 'supplier'],
            ['name' => 'verify_suppliers', 'description' => 'Verify supplier accounts', 'group' => 'supplier'],
            ['name' => 'manage_suppliers', 'description' => 'Manage all suppliers (admin)', 'group' => 'supplier'],
        ];

        // Offer Permissions
        $offerPermissions = [
            ['name' => 'view_offers', 'description' => 'View offers', 'group' => 'offer'],
            ['name' => 'create_offers', 'description' => 'Create offers', 'group' => 'offer'],
            ['name' => 'update_offers', 'description' => 'Update own offers', 'group' => 'offer'],
            ['name' => 'delete_offers', 'description' => 'Delete own offers', 'group' => 'offer'],
            ['name' => 'moderate_offers', 'description' => 'Moderate offers (admin)', 'group' => 'offer'],
            ['name' => 'manage_all_offers', 'description' => 'Manage all offers (admin)', 'group' => 'offer'],
        ];

        // Purchase Order Permissions
        $poPermissions = [
            ['name' => 'view_purchase_orders', 'description' => 'View purchase orders', 'group' => 'purchase_order'],
            ['name' => 'create_purchase_orders', 'description' => 'Create purchase orders', 'group' => 'purchase_order'],
            ['name' => 'accept_purchase_orders', 'description' => 'Accept/reject purchase orders', 'group' => 'purchase_order'],
            ['name' => 'confirm_payment', 'description' => 'Confirm purchase order payment', 'group' => 'purchase_order'],
            ['name' => 'update_po_status', 'description' => 'Update purchase order status', 'group' => 'purchase_order'],
            ['name' => 'manage_all_purchase_orders', 'description' => 'Manage all purchase orders (admin)', 'group' => 'purchase_order'],
        ];

        // User Permissions
        $userPermissions = [
            ['name' => 'view_users', 'description' => 'View user profiles', 'group' => 'user'],
            ['name' => 'update_own_profile', 'description' => 'Update own profile', 'group' => 'user'],
            ['name' => 'manage_users', 'description' => 'Manage all users (admin)', 'group' => 'user'],
            ['name' => 'suspend_users', 'description' => 'Suspend users (admin)', 'group' => 'user'],
            ['name' => 'delete_users', 'description' => 'Delete users (admin)', 'group' => 'user'],
        ];

        // Notification Permissions
        $notificationPermissions = [
            ['name' => 'view_notifications', 'description' => 'View own notifications', 'group' => 'notification'],
            ['name' => 'mark_notifications_read', 'description' => 'Mark notifications as read', 'group' => 'notification'],
            ['name' => 'send_notifications', 'description' => 'Send notifications', 'group' => 'notification'],
            ['name' => 'manage_all_notifications', 'description' => 'Manage all notifications (admin)', 'group' => 'notification'],
        ];

        // System Permissions
        $systemPermissions = [
            ['name' => 'view_dashboard', 'description' => 'View admin dashboard', 'group' => 'system'],
            ['name' => 'view_analytics', 'description' => 'View analytics', 'group' => 'system'],
            ['name' => 'manage_settings', 'description' => 'Manage system settings', 'group' => 'system'],
            ['name' => 'view_audit_logs', 'description' => 'View audit logs', 'group' => 'system'],
            ['name' => 'manage_feature_flags', 'description' => 'Manage feature flags', 'group' => 'system'],
            ['name' => 'access_super_admin', 'description' => 'Access super admin features', 'group' => 'system'],
        ];

        // Create all permissions
        $allPermissions = array_merge(
            $campaignPermissions,
            $orderPermissions,
            $supplierPermissions,
            $offerPermissions,
            $poPermissions,
            $userPermissions,
            $notificationPermissions,
            $systemPermissions
        );

        foreach ($allPermissions as $permission) {
            Permission::create([
                'name' => $permission['name'],
                'description' => $permission['description'],
                'group' => $permission['group'],
                'guard_name' => 'sanctum',
            ]);
        }

        // ============================================
        // CREATE ROLES
        // ============================================

        // Buyer Role
        $buyerRole = Role::create([
            'name' => 'buyer',
            'description' => 'Regular buyer who can join campaigns and place orders',
            'guard_name' => 'sanctum',
            'level' => 1,
            'is_system' => true,
        ]);

        $buyerRole->givePermissionTo([
            'view_campaigns',
            'view_orders',
            'create_orders',
            'cancel_orders',
            'upload_proof',
            'view_users',
            'update_own_profile',
            'view_notifications',
            'mark_notifications_read',
        ]);

        // Initiator Role
        $initiatorRole = Role::create([
            'name' => 'initiator',
            'description' => 'Campaign initiator who can create campaigns and validate orders',
            'guard_name' => 'sanctum',
            'level' => 2,
            'is_system' => true,
        ]);

        $initiatorRole->givePermissionTo([
            // Buyer permissions
            'view_campaigns',
            'view_orders',
            'create_orders',
            'cancel_orders',
            'upload_proof',
            'view_users',
            'update_own_profile',
            'view_notifications',
            'mark_notifications_read',
            
            // Initiator specific
            'create_campaigns',
            'update_campaigns',
            'delete_campaigns',
            'extend_campaigns',
            'cancel_campaigns',
            'complete_distribution',
            'view_campaign_recap',
            'view_all_orders',
            'validate_orders',
            'reject_orders',
            'batch_validate_orders',
            'mark_orders_taken',
            'view_offers',
            'view_purchase_orders',
            'create_purchase_orders',
            'send_notifications',
            'view_suppliers',
        ]);

        // Seller Role
        $sellerRole = Role::create([
            'name' => 'seller',
            'description' => 'Supplier seller who can manage offers and purchase orders',
            'guard_name' => 'sanctum',
            'level' => 2,
            'is_system' => true,
        ]);

        $sellerRole->givePermissionTo([
            // Basic permissions
            'view_users',
            'update_own_profile',
            'view_notifications',
            'mark_notifications_read',
            
            // Seller specific
            'view_offers',
            'create_offers',
            'update_offers',
            'delete_offers',
            'view_purchase_orders',
            'accept_purchase_orders',
            'confirm_payment',
            'update_po_status',
        ]);

        // Admin Role
        $adminRole = Role::create([
            'name' => 'admin',
            'description' => 'Platform administrator with full access',
            'guard_name' => 'sanctum',
            'level' => 3,
            'is_system' => true,
        ]);

        $adminRole->givePermissionTo([
            // All permissions except super admin
            'view_campaigns',
            'manage_all_campaigns',
            'view_orders',
            'manage_all_orders',
            'view_suppliers',
            'verify_suppliers',
            'manage_suppliers',
            'view_offers',
            'moderate_offers',
            'manage_all_offers',
            'view_purchase_orders',
            'manage_all_purchase_orders',
            'view_users',
            'manage_users',
            'suspend_users',
            'view_notifications',
            'manage_all_notifications',
            'send_notifications',
            'view_dashboard',
            'view_analytics',
            'manage_settings',
            'view_audit_logs',
            'manage_feature_flags',
        ]);

        // Super Admin Role
        $superAdminRole = Role::create([
            'name' => 'super_admin',
            'description' => 'Super administrator with all permissions',
            'guard_name' => 'sanctum',
            'level' => 4,
            'is_system' => true,
        ]);

        // Super admin gets all permissions
        $superAdminRole->givePermissionTo(Permission::all());

        // ============================================
        // CREATE DEFAULT ADMIN USER
        // ============================================

        $adminUser = \App\Models\User::firstOrCreate(
            ['phone_number' => '081234567890'],
            [
                'name' => 'Admin Grosirun',
                'role' => 'admin',
                'active_role' => 'admin',
                'cluster_id' => null,
                'consent_at' => now(),
                'consent_version' => '1.0',
                'tos_accepted_at' => now(),
                'tos_version' => '1.0',
            ]
        );

        $adminUser->assignRole('super_admin');

        // ============================================
        // OUTPUT SUMMARY
        // ============================================

        $this->command->info('✅ Roles created successfully!');
        $this->command->table(
            ['Role', 'Level', 'Permissions Count'],
            Role::all()->map(fn($role) => [
                $role->name,
                $role->level,
                $role->permissions->count(),
            ])->toArray()
        );

        $this->command->info('✅ Permissions created successfully!');
        $this->command->table(
            ['Group', 'Count'],
            Permission::selectRaw('`group`, count(*) as count')
                ->groupBy('group')
                ->get()
                ->map(fn($p) => [$p->group, $p->count])
                ->toArray()
        );

        $this->command->info('✅ Default admin user created:');
        $this->command->table(
            ['Name', 'Phone', 'Role'],
            [[$adminUser->name, $adminUser->phone_number, 'super_admin']]
        );
    }
}
