import 'package:flutter/material.dart';
import '../../../models/category_model.dart';

class PosCategoryPills extends StatelessWidget {
  final List<CategoryModel> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryTap;

  const PosCategoryPills({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildPill('All', 'all'),
          ...categories.map((c) => _buildPill(c.name, c.slug)),
        ],
      ),
    );
  }

  Widget _buildPill(String label, String slug) {
    final isSelected = selectedCategory == slug;
    return GestureDetector(
      onTap: () => onCategoryTap(slug),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B00) : Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}