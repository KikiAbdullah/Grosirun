<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Cluster extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'code',
        'rw',
        'kelurahan',
        'kota',
    ];

    /**
     * Get users in this cluster
     */
    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    /**
     * Get campaigns in this cluster
     */
    public function campaigns(): HasMany
    {
        return $this->hasMany(Campaign::class);
    }

    /**
     * Get orders in this cluster
     */
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }
}
