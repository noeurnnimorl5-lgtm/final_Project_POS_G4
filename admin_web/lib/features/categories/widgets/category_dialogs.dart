import 'package:flutter/material.dart';

class CategoryDialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool enabled;
  final bool autofocus;

  const CategoryDialogField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      autofocus: autofocus,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFFFF6B00)),
        filled: true,
        fillColor: const Color(0xFFFAFAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle:
            const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
      ),
    );
  }
}

// ── Warning Dialog ────────────────────────────────────────────────────────────

class CategoryWarningDialog extends StatelessWidget {
  final String title;
  final String message;

  const CategoryWarningDialog({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 26,
        ),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ),
      ],
    );
  }
}

// ── Confirm Delete Dialog ─────────────────────────────────────────────────────

class ConfirmDeleteDialog extends StatelessWidget {
  final String categoryName;

  const ConfirmDeleteDialog({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.red,
          size: 26,
        ),
      ),
      title: const Text(
        'Delete Category',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
      content: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          children: [
            const TextSpan(text: 'Are you sure you want to delete '),
            TextSpan(
              text: '"$categoryName"',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D23),
              ),
            ),
            const TextSpan(text: '? This cannot be undone.'),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Delete',
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