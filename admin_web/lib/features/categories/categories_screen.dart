import 'package:admin_web/features/categories/widgets/add_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/categories_notifier.dart';
import 'add_category_dialog.dart';
import 'edit_category_dialog.dart';
import 'widgets/category_dialogs.dart';
import 'widgets/category_stat_card.dart';
import 'widgets/category_table_row.dart';
import 'widgets/empty_error_states.dart';
import '../../data/models/category.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFFFF6B00);
  static const Color _bg = Color(0xFFF5F6FA);
  static const Color _textDark = Color(0xFF1A1D23);
  static const Color _textMid = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);

  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    Future.microtask(() {
      ref.read(categoriesNotifierProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────

  void _showAddDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddCategoryDialog(
        onSubmit: (name, color) => ref
            .read(categoriesNotifierProvider.notifier)
            .createCategory(name, color: color),
      ),
    );
  }

  void _showEditDialog(Category category) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditCategoryDialog(
        categoryId: category.id,
        initialName: category.name,
        initialColor: category.color ?? '#FF6B00',
        onSubmit: (name, color) => ref
            .read(categoriesNotifierProvider.notifier)
            .updateCategory(category.id, name, color: color),
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    final int count = category.productsCount;
    final String name = category.name;
    final int id = category.id;

    if (count > 0) {
      await showDialog(
        context: context,
        builder: (_) => CategoryWarningDialog(
          title: 'Cannot Delete',
          message:
              '"$name" contains $count product${count == 1 ? '' : 's'}.\nRemove or reassign them first.',
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(categoryName: name),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(categoriesNotifierProvider.notifier).deleteCategory(id);
        if (mounted) _toast('Category deleted', Colors.green);
      } catch (e) {
        if (mounted) _toast('Error: $e', Colors.red);
      }
    }
  }

  void _toast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(36, 36, 36, 24),
        child: categoriesAsync.when(
          data: (categories) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildStatsRow(categories),
              const SizedBox(height: 24),
              Expanded(child: _buildBody(categories)),
            ],
          ),
          loading: () => const Center(
              child: CircularProgressIndicator(color: _primary, strokeWidth: 2.5)),
          error: (err, _) => CategoryErrorState(
            message: err.toString(),
            onRetry: () =>
                ref.read(categoriesNotifierProvider.notifier).loadCategories(),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your product categories',
              style: TextStyle(fontSize: 14, color: _textMid),
            ),
          ],
        ),
        const Spacer(),
        AddButton(onTap: _showAddDialog),
      ],
    );
  }

  Widget _buildStatsRow(List<Category> categories) {
    final total = categories.length;
    final active = categories.where((c) => c.productsCount > 0).length;
    final empty = total - active;

    return Row(
      children: [
        CategoryStatCard(
          label: 'Total',
          value: '$total',
          icon: Icons.category_rounded,
          color: _primary,
        ),
        const SizedBox(width: 16),
        CategoryStatCard(
          label: 'Active',
          value: '$active',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(width: 16),
        CategoryStatCard(
          label: 'Empty',
          value: '$empty',
          icon: Icons.radio_button_unchecked,
          color: _textMid,
        ),
      ],
    );
  }

  Widget _buildBody(List<Category> categories) {
    if (categories.isEmpty) {
      return CategoryEmptyState(onAdd: _showAddDialog);
    }
    return _buildTable(categories);
  }

  // ─── Table ────────────────────────────────────────────────────────────────

  Widget _buildTable(List<Category> categories) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _buildTableHeader(),
            Expanded(child: _buildTableRows(categories)),
            _buildTableFooter(categories),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFB),
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          _headerCell('#', flex: 1),
          _headerCell('Category', flex: 4),
          _headerCell('Products', flex: 3),
          _headerCell('Color', flex: 2),
          _headerCell('Actions', flex: 2, align: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildTableRows(List<Category> categories) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: categories.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: _border),
      itemBuilder: (context, index) {
        final category = categories[index];
        final productCount = category.productsCount;
        final dotColor = _parseColor(category.color);

        return AnimatedCategoryRow(
          index: index,
          controller: _animCtrl,
          child: CategoryTableRow(
            index: index,
            category: category,
            productCount: productCount,
            dotColor: dotColor,
            onEdit: () => _showEditDialog(category),
            onDelete: productCount > 0 ? null : () => _deleteCategory(category),
          ),
        );
      },
    );
  }

  Widget _buildTableFooter(List<Category> categories) {
    final count = categories.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
   
      decoration: BoxDecoration(

        color: const Color(0xFFFAFAFB),
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Text(
        'Showing $count categor${count == 1 ? 'y' : 'ies'}',
        style: TextStyle(fontSize: 13, color: _textMid),
      ),
    );
  }

  Widget _headerCell(String label,
      {int flex = 1, TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9CA3AF),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null) return _primary;
    try {
      final s = hex.replaceAll('#', '');
      if (s.length == 6) return Color(int.parse('FF$s', radix: 16));
      if (s.length == 8) return Color(int.parse(s, radix: 16));
    } catch (_) {}
    return _primary;
  }
}