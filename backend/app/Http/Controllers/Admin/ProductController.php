<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Str;
use App\Services\CloudinaryService;

class ProductController extends Controller
{
    /**
     * Generate a unique slug for product name.
     */
    private function generateUniqueSlug(string $name, ?int $id = null): string
    {
        $slug = Str::slug($name);
        $originalSlug = $slug;
        $count = 1;

        while (
            Product::where('slug', $slug)
                   ->when($id, fn($q) => $q->where('id', '!=', $id))
                   ->exists()
        ) {
            $slug = $originalSlug . '-' . $count++;
        }

        return $slug;
    }

    public function index(Request $request): AnonymousResourceCollection
    {
        $products = Product::query()
            ->with('category')
            ->when($request->search, fn($q) =>
                $q->where('name', 'like', "%{$request->search}%")
            )
            ->orderBy('name')
            ->paginate($request->integer('per_page', 15));

        return ProductResource::collection($products);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'category_id' => ['required', 'exists:categories,id'],
            'name'        => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'price'       => ['required', 'numeric', 'min:0'],
            'stock'       => ['required', 'integer', 'min:0'],
            'image'       => ['nullable', 'image', 'max:2048'],
            'is_active'   => ['nullable'],
        ]);

        if ($request->hasFile('image')) {
            $cloudinary = new CloudinaryService();
            $result = $cloudinary->upload($request->file('image')->getRealPath());

            $validated['image_url'] = $result['secure_url'];
            $validated['image_public_id'] = $result['public_id'];
        }

        $validated['slug'] = $this->generateUniqueSlug($validated['name']);
        $validated['is_active'] = true;
        unset($validated['image']);

        $product = Product::create($validated);

        return response()->json([
            'message' => 'Product created successfully.',
            'data'    => new ProductResource($product->load('category')),
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        $product = Product::with('category')->findOrFail($id);
        return response()->json(['data' => new ProductResource($product)]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $product = Product::findOrFail($id);

        $validated = $request->validate([
            'category_id' => ['sometimes', 'exists:categories,id'],
            'name'        => ['sometimes', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'price'       => ['sometimes', 'numeric', 'min:0'],
            'stock'       => ['sometimes', 'integer', 'min:0'],
            'image'       => ['nullable', 'image', 'max:2048'],
            'is_active'   => ['sometimes', 'boolean'],
        ]);

        if ($request->hasFile('image')) {
            $cloudinary = new CloudinaryService();

            if ($product->image_public_id) {
                $cloudinary->delete($product->image_public_id);
            }

            $result = $cloudinary->upload($request->file('image')->getRealPath());

            $validated['image_url'] = $result['secure_url'];
            $validated['image_public_id'] = $result['public_id'];
        }

        if (isset($validated['name'])) {
            $validated['slug'] = $this->generateUniqueSlug($validated['name'], $product->id);
        }

        unset($validated['image']);
        $product->update($validated);

        return response()->json([
            'message' => 'Product updated successfully.',
            'data'    => new ProductResource($product->load('category')),
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $product = Product::findOrFail($id);

        if ($product->image_public_id) {
            $cloudinary = new CloudinaryService();
            $cloudinary->delete($product->image_public_id);
        }

        $product->delete();

        return response()->json(['message' => 'Product deleted.']);
    }
}
