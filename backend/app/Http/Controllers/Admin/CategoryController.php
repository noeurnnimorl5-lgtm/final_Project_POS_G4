<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Category;
use Illuminate\Support\Str;

class CategoryController extends Controller
{
    public function index()
    {
        return response()->json(Category::withCount('products')->latest()->get());
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name'      => 'required|string|max:100|unique:categories',
            'is_active' => 'boolean',
        ]);

        $data['slug'] = Str::slug($data['name']);
        return response()->json(Category::create($data), 201);
    }

    public function show(Category $category)
    {
        return response()->json($category->load('products'));
    }

    public function update(Request $request, Category $category)
    {
        $data = $request->validate([
            'name'      => 'sometimes|string|max:100|unique:categories,name,' . $category->id,
            'is_active' => 'boolean',
        ]);

        if (isset($data['name'])) {
            $data['slug'] = Str::slug($data['name']);
        }

        $category->update($data);
        return response()->json($category);
    }

    public function destroy(Category $category)
    {
        if ($category->products()->exists()) {
            return response()->json(['message' => 'Cannot delete category with products.'], 422);
        }

        $category->delete();
        return response()->json(['message' => 'Category deleted.']);
    }
}
