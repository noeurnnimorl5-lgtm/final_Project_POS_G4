import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../data/providers/products_notifier.dart';
import '../../data/providers/categories_notifier.dart';

Future<void> showAddProductDialog(BuildContext context, WidgetRef ref) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AddProductDialog(ref: ref),
  );
}

class _AddProductDialog extends StatefulWidget {
  final WidgetRef ref;
  const _AddProductDialog({required this.ref});

  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  String? selectedCategoryId;
  Uint8List? imageBytes;
  String? imageFileName;
  bool _isSaving = false;
  String? _errorMessage;

  static const Color primaryColor = Color(0xFFFF6B00);

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        imageBytes = bytes;
        imageFileName = picked.name;
      });
    }
  }

  Future<void> _save() async {
    if (nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Product name is required.');
      return;
    }
    if (selectedCategoryId == null) {
      setState(() => _errorMessage = 'Please select a category.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.ref.read(productsNotifierProvider.notifier).addProduct({
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'categoryId': int.parse(selectedCategoryId!),
        'price': double.tryParse(priceController.text) ?? 0,
        'stock': int.tryParse(stockController.text) ?? 0,
        'imageBytes': imageBytes,
        'imageName': imageFileName,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = widget.ref.watch(categoriesNotifierProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add Product',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Image upload
              GestureDetector(
                onTap: _isSaving ? null : _pickImage,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: imageBytes != null
                          ? primaryColor
                          : Colors.grey.shade300,
                      width: imageBytes != null ? 2 : 1,
                    ),
                  ),
                  child: imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(imageBytes!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('Click to upload image',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              _buildField(nameController, 'Product Name', Icons.fastfood_outlined),
              const SizedBox(height: 12),

              _buildField(descriptionController, 'Description',
                  Icons.description_outlined, maxLines: 2),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildField(priceController, 'Price',
                        Icons.attach_money,
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(stockController, 'Stock',
                        Icons.inventory_2_outlined,
                        keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category_outlined,
                        color: primaryColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: categories.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id.toString(),
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: _isSaving
                      ? null
                      : (val) => setState(() => selectedCategoryId = val),
                ),
                loading: () => const Center(
                    child: CircularProgressIndicator(color: primaryColor)),
                error: (err, _) => Text('Failed to load categories: $err',
                    style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Add Product',
                  style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: !_isSaving,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
