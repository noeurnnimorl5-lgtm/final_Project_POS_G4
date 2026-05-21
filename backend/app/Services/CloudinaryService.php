<?php
namespace App\Services;

use Cloudinary\Cloudinary;
use Cloudinary\Configuration\Configuration;

class CloudinaryService{
    private Cloudinary $cloudinary;

    public function __construct()
    {
        $this->cloudinary=new Cloudinary(
            Configuration::instance([
                'cloud' => [
                    'cloud_name' => env('CLOUDINARY_CLOUD_NAME'),
                    'api_key'    => env('CLOUDINARY_API_KEY'),
                    'api_secret' => env('CLOUDINARY_API_SECRET'),
                ],
                'url' =>[
                    'secure' =>true,
                ]
            ])

        );
    }

   public function upload(string $filePath,string $folder ='pos_products'):array
{
    $result = $this->cloudinary->uploadApi()->upload($filePath, [
        'folder' => $folder,
        'transformation' => [
            'width' => 800,
            'height' => 800,
            'crop' => 'fill',
            'quality' => 'auto',
        ],
    ]);

    return [
        'secure_url' => $result['secure_url'],
        'public_id'  => $result['public_id'],
    ];
}

    public function delete(string $publicId):void
    { 
        $this->cloudinary->uploadApi()->destroy($publicId);

    }

}