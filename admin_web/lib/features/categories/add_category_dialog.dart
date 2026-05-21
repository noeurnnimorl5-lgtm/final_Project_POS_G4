import 'package:flutter/material.dart';
import 'widgets/category_dialogs.dart';

class AddCategoryDialog extends StatefulWidget {
  final Future<void> Function(String name, String color) onSubmit;

  const AddCategoryDialog({super.key, required this.onSubmit});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  static const Color _primary = Color(0xFFFF6B00);

  final _nameController = TextEditingController();
  final _colorController = TextEditingController(text: '#FF6B00');
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter a category name', Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.onSubmit(
        _nameController.text.trim(),
        _colorController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Category created successfully!', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackBar('Error: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.category_rounded, color: _primary, size: 18),
          ),
          const SizedBox(width: 12),
          const Text(
            'New Category',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            CategoryDialogField(
              controller: _nameController,
              label: 'Category Name',
              hint: 'e.g. Beverages, Snacks…',
              icon: Icons.label_rounded,
              enabled: !_isSaving,
              autofocus: true,
            ),
            const SizedBox(height: 14),
            CategoryDialogField(
              controller: _colorController,
              label: 'Color Code',
              hint: '#FF6B00',
              icon: Icons.palette_rounded,
              enabled: !_isSaving,
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}