<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver;

class ImageService
{
    protected ImageManager $manager;

    public function __construct()
    {
        $this->manager = new ImageManager(new Driver());
    }

    /**
     * Upload and compress image
     */
    public function upload(UploadedFile $file, string $folder, int $maxSize = 2048): string
    {
        // Validate file size (KB)
        if ($file->getSize() / 1024 > $maxSize) {
            throw new \Exception("File size exceeds {$maxSize}KB limit");
        }

        // Validate file type
        $allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
        if (!in_array($file->getMimeType(), $allowedTypes)) {
            throw new \Exception('Invalid file type. Only JPG and PNG allowed');
        }

        // Generate unique filename
        $filename = $folder . '/' . Str::uuid() . '.jpg';

        // Read and compress image
        $image = $this->manager->read($file->getPathname());

        // Resize if too large (max 1200px width)
        $image->scaleDown(width: 1200);

        // Compress to 70% quality
        $compressed = $image->toJpeg(70);

        // Save to S3
        Storage::disk('s3')->put($filename, $compressed->encode());

        return $filename;
    }

    /**
     * Get temporary URL for image (1 hour expiry)
     */
    public function getTemporaryUrl(string $path): string
    {
        return Storage::disk('s3')->temporaryUrl($path, now()->addHour());
    }

    /**
     * Delete image from storage
     */
    public function delete(string $path): void
    {
        if (Storage::disk('s3')->exists($path)) {
            Storage::disk('s3')->delete($path);
        }
    }

    /**
     * Compress image without uploading
     */
    public function compress(UploadedFile $file, int $quality = 70): string
    {
        $image = $this->manager->read($file->getPathname());
        $image->scaleDown(width: 1200);
        
        $compressed = $image->toJpeg($quality);
        
        $tempPath = sys_get_temp_dir() . '/' . Str::uuid() . '.jpg';
        $compressed->save($tempPath);

        return $tempPath;
    }

    /**
     * Upload proof image with compression
     */
    public function uploadProof(UploadedFile $file): string
    {
        return $this->upload($file, 'order_proofs', config('services.storage.proof_max_size', 2048));
    }

    /**
     * Upload campaign image
     */
    public function uploadCampaignImage(UploadedFile $file): string
    {
        return $this->upload($file, 'campaign_images', config('services.storage.campaign_image_max_size', 5120));
    }

    /**
     * Upload product image
     */
    public function uploadProductImage(UploadedFile $file): string
    {
        return $this->upload($file, 'product_images', config('services.storage.campaign_image_max_size', 5120));
    }

    /**
     * Clean up old proof images (scheduled job)
     */
    public function cleanupOldProofs(int $days = 90): int
    {
        $cutoffDate = now()->subDays($days);
        
        $proofs = \App\Models\Order::where('proof_uploaded_at', '<', $cutoffDate)
            ->whereNotNull('proof_path')
            ->get();

        $deleted = 0;
        foreach ($proofs as $proof) {
            $this->delete($proof->proof_path);
            $proof->update(['proof_path' => null]);
            $deleted++;
        }

        return $deleted;
    }
}
