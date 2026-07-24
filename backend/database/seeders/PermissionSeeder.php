<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

/**
 * Permission Seeder - Grosirun
 * 
 * Creates all permissions and assigns them to roles using Spatie Laravel Permission v8
 * Reference: https://spatie.be/docs/laravel-permission/v8/introduction
 * 
 * Roles:
 * - buyer: Regular buyer who can join campaigns
 * - initiator: Campaign initiator who manages campaigns and validates orders
 * - seller: Supplier seller who manages products, offers, and purchase orders
 * - admin: Platform administrator with full access
 * - super_admin: Super administrator with all permissions
 */
class PermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Reset cached roles and permissions
        app(PermissionRegistrar::class)->forgetCachedPermissions();

        // ═══════════════════════════════════════════════════════
        // STEP 1: CREATE ALL PERMISSIONS
        // ═══════════════════════════════════════════════════════

        $permissions = $this->getAllPermissions();

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(
                ['name' => $permission, 'guard_name' => 'web']
            );
        }

        $this->command->info("✅ Created " . count($permissions) . " permissions");

        // ═══════════════════════════════════════════════════════
        // STEP 2: CREATE ROLES
        // ═══════════════════════════════════════════════════════

        $roles = [
            'buyer' => 'Regular buyer who can join campaigns and place orders',
            'initiator' => 'Campaign initiator who manages campaigns and validates orders',
            'seller' => 'Supplier seller who manages products, offers, and purchase orders',
            'admin' => 'Platform administrator with moderation and management access',
            'super_admin' => 'Super administrator with full system access',
        ];

        foreach ($roles as $roleName => $description) {
            Role::firstOrCreate(
                ['name' => $roleName, 'guard_name' => 'web'],
                ['description' => $description]
            );
        }

        $this->command->info("✅ Created " . count($roles) . " roles");

        // ═══════════════════════════════════════════════════════
        // STEP 3: ASSIGN PERMISSIONS TO ROLES
        // ═══════════════════════════════════════════════════════

        $this->assignPermissionsToBuyer();
        $this->assignPermissionsToInitiator();
        $this->assignPermissionsToSeller();
        $this->assignPermissionsToAdmin();
        $this->assignPermissionsToSuperAdmin();

        $this->command->info("✅ Assigned permissions to all roles");

        // ═══════════════════════════════════════════════════════
        // STEP 4: OUTPUT SUMMARY
        // ═══════════════════════════════════════════════════════

        $this->outputSummary();
    }

    /**
     * Get all permissions organized by category
     */
    private function getAllPermissions(): array
    {
        return [
            // Dashboard
            'dashboard_view',

            // Campaign Permissions
            'campaign_view',
            'campaign_create',
            'campaign_edit',
            'campaign_delete',
            'campaign_extend',
            'campaign_cancel',
            'campaign_complete',
            'campaign_recap',

            // Order Permissions
            'order_view',
            'order_create',
            'order_cancel',
            'order_validate',
            'order_reject',
            'order_batch_validate',
            'order_upload_proof',
            'order_mark_taken',

            // Supplier Permissions
            'supplier_view',
            'supplier_create',
            'supplier_verify',
            'supplier_edit',
            'supplier_delete',

            // Offer Permissions
            'offer_view',
            'offer_create',
            'offer_edit',
            'offer_moderate',
            'offer_submit',
            'offer_delete',

            // Product Permissions
            'product_view',
            'product_create',
            'product_edit',
            'product_delete',

            // Purchase Order Permissions
            'purchase_order_view',
            'purchase_order_create',
            'purchase_order_accept',
            'purchase_order_reject',
            'purchase_order_confirm_payment',
            'purchase_order_update_status',
            'purchase_order_upload_document',

            // User Management Permissions
            'user_view',
            'user_manage',
            'user_suspend',
            'user_unsuspend',
            'user_delete',

            // Dispute Permissions
            'dispute_view',
            'dispute_create',
            'dispute_resolve',

            // Notification Permissions
            'notification_view',
            'notification_mark_read',
            'notification_mark_all_read',

            // Profile Permissions
            'profile_view',
            'profile_edit',
            'profile_switch_role',

            // Audit Permissions
            'audit_view',
            'audit_export',

            // System Permissions
            'system_settings',
            'system_maintenance',
            'system_backup',
        ];
    }

    /**
     * Assign permissions to Buyer role
     */
    private function assignPermissionsToBuyer(): void
    {
        $role = Role::where('name', 'buyer')->first();
        
        $role->syncPermissions([
            // Dashboard
            'dashboard_view',

            // Campaign
            'campaign_view',

            // Order
            'order_view',
            'order_create',
            'order_cancel',
            'order_upload_proof',
            'order_mark_taken',

            // Notification
            'notification_view',
            'notification_mark_read',
            'notification_mark_all_read',

            // Profile
            'profile_view',
            'profile_edit',
            'profile_switch_role',
        ]);

        $this->command->info("✅ Buyer: 13 permissions assigned");
    }

    /**
     * Assign permissions to Initiator role
     */
    private function assignPermissionsToInitiator(): void
    {
        $role = Role::where('name', 'initiator')->first();
        
        $role->syncPermissions([
            // Dashboard
            'dashboard_view',

            // Campaign - Full management
            'campaign_view',
            'campaign_create',
            'campaign_edit',
            'campaign_delete',
            'campaign_extend',
            'campaign_cancel',
            'campaign_complete',
            'campaign_recap',

            // Order - Validation & management
            'order_view',
            'order_create',
            'order_validate',
            'order_reject',
            'order_batch_validate',
            'order_mark_taken',

            // Offer - View only
            'offer_view',

            // Purchase Order - Create & view
            'purchase_order_view',
            'purchase_order_create',

            // Supplier - View only
            'supplier_view',

            // Notification
            'notification_view',
            'notification_mark_read',
            'notification_mark_all_read',

            // Profile
            'profile_view',
            'profile_edit',
            'profile_switch_role',
        ]);

        $this->command->info("✅ Initiator: 24 permissions assigned");
    }

    /**
     * Assign permissions to Seller role
     */
    private function assignPermissionsToSeller(): void
    {
        $role = Role::where('name', 'seller')->first();
        
        $role->syncPermissions([
            // Dashboard
            'dashboard_view',

            // Product - Full CRUD
            'product_view',
            'product_create',
            'product_edit',
            'product_delete',

            // Offer - Management
            'offer_view',
            'offer_create',
            'offer_edit',
            'offer_submit',

            // Purchase Order - Handling
            'purchase_order_view',
            'purchase_order_accept',
            'purchase_order_reject',
            'purchase_order_confirm_payment',
            'purchase_order_update_status',
            'purchase_order_upload_document',

            // Notification
            'notification_view',
            'notification_mark_read',
            'notification_mark_all_read',

            // Profile
            'profile_view',
            'profile_edit',
            'profile_switch_role',
        ]);

        $this->command->info("✅ Seller: 16 permissions assigned");
    }

    /**
     * Assign permissions to Admin role
     */
    private function assignPermissionsToAdmin(): void
    {
        $role = Role::where('name', 'admin')->first();
        
        $role->syncPermissions([
            // Dashboard
            'dashboard_view',

            // Campaign - View only
            'campaign_view',

            // Order - View only
            'order_view',

            // Supplier - Verification & management
            'supplier_view',
            'supplier_verify',
            'supplier_edit',

            // Offer - Moderation
            'offer_view',
            'offer_moderate',

            // Purchase Order - View only
            'purchase_order_view',

            // User Management
            'user_view',
            'user_manage',
            'user_suspend',
            'user_unsuspend',

            // Dispute
            'dispute_view',
            'dispute_resolve',

            // Audit
            'audit_view',

            // Notification
            'notification_view',
            'notification_mark_read',
            'notification_mark_all_read',

            // Profile
            'profile_view',
            'profile_edit',
            'profile_switch_role',
        ]);

        $this->command->info("✅ Admin: 22 permissions assigned");
    }

    /**
     * Assign permissions to Super Admin role
     */
    private function assignPermissionsToSuperAdmin(): void
    {
        $role = Role::where('name', 'super_admin')->first();
        
        // Super admin gets ALL permissions
        $role->syncPermissions(Permission::all());

        $this->command->info("✅ Super Admin: All permissions assigned");
    }

    /**
     * Output summary table
     */
    private function outputSummary(): void
    {
        $this->command->newLine();
        $this->command->info("═══════════════════════════════════════════════════");
        $this->command->info("✅ PERMISSION SEEDER COMPLETED SUCCESSFULLY");
        $this->command->info("═══════════════════════════════════════════════════");
        $this->command->newLine();

        // Permissions summary
        $this->command->table(
            ['Category', 'Count', 'Example'],
            [
                ['Dashboard', '1', 'dashboard_view'],
                ['Campaign', '8', 'campaign_create, campaign_edit'],
                ['Order', '8', 'order_validate, order_reject'],
                ['Supplier', '5', 'supplier_verify, supplier_edit'],
                ['Offer', '6', 'offer_moderate, offer_create'],
                ['Product', '4', 'product_create, product_delete'],
                ['Purchase Order', '7', 'purchase_order_accept'],
                ['User Management', '5', 'user_manage, user_suspend'],
                ['Dispute', '3', 'dispute_view, dispute_resolve'],
                ['Notification', '3', 'notification_view'],
                ['Profile', '3', 'profile_view, profile_edit'],
                ['Audit', '2', 'audit_view, audit_export'],
                ['System', '3', 'system_settings, system_backup'],
                ['TOTAL', '50+', 'All permissions created'],
            ]
        );

        $this->command->newLine();

        // Roles summary
        $this->command->table(
            ['Role', 'Permissions Count', 'Description'],
            Role::all()->map(fn($role) => [
                $role->name,
                $role->permissions->count(),
                $role->description ?? 'N/A',
            ])->toArray()
        );

        $this->command->newLine();
        $this->command->info("📚 Documentation: backend/PERMISSIONS.md");
        $this->command->info("📋 Quick Reference: backend/PERMISSION_QUICK_REFERENCE.md");
        $this->command->info("🔗 Spatie Docs: https://spatie.be/docs/laravel-permission/v8");
    }
}
