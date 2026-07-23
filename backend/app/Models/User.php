<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes, HasRoles;

    protected $fillable = [
        'name',
        'phone_number',
        'fcm_token',
        'role',
        'active_role',
        'cluster_id',
        'consent_at',
        'consent_version',
        'tos_accepted_at',
        'tos_version',
        'privacy_policy_accepted',
        'privacy_policy_accepted_at',
        'is_suspended',
        'suspended_at',
        'suspension_reason',
    ];

    protected $hidden = [
        'fcm_token',
    ];

    protected $casts = [
        'consent_at' => 'datetime',
        'tos_accepted_at' => 'datetime',
        'privacy_policy_accepted_at' => 'datetime',
        'suspended_at' => 'datetime',
        'is_suspended' => 'boolean',
        'privacy_policy_accepted' => 'boolean',
    ];

    /**
     * Get the cluster that the user belongs to
     */
    public function cluster(): BelongsTo
    {
        return $this->belongsTo(Cluster::class);
    }

    /**
     * Get campaigns created by this user (as initiator)
     */
    public function campaigns(): HasMany
    {
        return $this->hasMany(Campaign::class, 'initiator_id');
    }

    /**
     * Get orders created by this user
     */
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    /**
     * Get notifications for this user
     */
    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }

    /**
     * Check if user has given consent
     */
    public function hasConsent(): bool
    {
        return !is_null($this->consent_at);
    }

    /**
     * Check if user has accepted ToS
     */
    public function hasAcceptedTos(): bool
    {
        return !is_null($this->tos_accepted_at);
    }

    /**
     * Check if user is suspended
     */
    public function isSuspended(): bool
    {
        return $this->is_suspended;
    }

    /**
     * Check if user is an initiator (Spatie role)
     */
    public function isInitiator(): bool
    {
        return $this->hasRole('initiator');
    }

    /**
     * Check if user is a seller (Spatie role)
     */
    public function isSeller(): bool
    {
        return $this->hasRole('seller');
    }

    /**
     * Check if user is an admin (Spatie role)
     */
    public function isAdmin(): bool
    {
        return $this->hasRole(['admin', 'super_admin']);
    }

    /**
     * Check if user is a buyer (Spatie role)
     */
    public function isBuyer(): bool
    {
        return $this->hasRole('buyer');
    }

    /**
     * Check if user can create campaigns
     */
    public function canCreateCampaigns(): bool
    {
        return $this->can('create_campaigns');
    }

    /**
     * Check if user can validate orders
     */
    public function canValidateOrders(): bool
    {
        return $this->can('validate_orders');
    }

    /**
     * Check if user can manage suppliers
     */
    public function canManageSuppliers(): bool
    {
        return $this->can('manage_suppliers');
    }

    /**
     * Get user's primary role
     */
    public function getPrimaryRoleAttribute(): string
    {
        $roles = $this->roles->sortByDesc('level');
        return $roles->first()?->name ?? 'buyer';
    }

    /**
     * Check if user has higher role than given role
     */
    public function hasHigherRoleThan(string $roleName): bool
    {
        $givenRole = \Spatie\Permission\Models\Role::findByName($roleName, 'sanctum');
        return $this->roles->max('level') > $givenRole->level;
    }

    /**
     * Scope to filter by active role
     */
    public function scopeWithActiveRole($query, string $role)
    {
        return $query->where('active_role', $role);
    }

    /**
     * Scope to filter by cluster
     */
    public function scopeInCluster($query, int $clusterId)
    {
        return $query->where('cluster_id', $clusterId);
    }

    /**
     * Anonymize user data (for account deletion)
     */
    public function anonymize(): void
    {
        $this->update([
            'name' => "Deleted User {$this->id}",
            'phone_number' => "DELETED_{$this->id}",
            'fcm_token' => null,
        ]);
        
        // Revoke all tokens
        $this->tokens()->delete();
    }
}
