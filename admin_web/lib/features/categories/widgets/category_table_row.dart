import 'package:admin_web/data/models/category.dart';
import 'package:flutter/material.dart';


// ── Animated Row ──────────────────────────────────────────────────────────────

class AnimatedCategoryRow extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const AnimatedCategoryRow({
    super.key,
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final delay = (index * 0.07).clamp(0.0, 0.6);
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay,
        (delay + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }
}

// ── Table Row ─────────────────────────────────────────────────────────────────

class CategoryTableRow extends StatefulWidget {
  final int index;
  final Category category;   
  final int productCount;
  final Color dotColor;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const CategoryTableRow({
    super.key,
    required this.index,
    required this.category,
    required this.productCount,
    required this.dotColor,
    required this.onEdit,
    this.onDelete,
  });

  @override
  State<CategoryTableRow> createState() => _CategoryTableRowState();
}

class _CategoryTableRowState extends State<CategoryTableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovered ? const Color(0xFFFFF7F2) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Index
            Expanded(
              flex: 1,
              child: Text(
                '${widget.index + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Name + color dot
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  _ColorDot(color: widget.dotColor),
                  const SizedBox(width: 12),
                  Text(
                    widget.category.name,   // ✅ fixed
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D23),
                    ),
                  ),
                ],
              ),
            ),

            // Products badge
            Expanded(
              flex: 3,
              child: ProductCountBadge(count: widget.productCount),
            ),

            // Color hex
            Expanded(
              flex: 2,
              child: _ColorHexChip(
                hex: widget.category.color,   // ✅ fixed
                color: widget.dotColor,
              ),
            ),

            // Actions
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ActionIconButton(
                    icon: Icons.edit_rounded,
                    color: const Color(0xFFFF6B00),
                    tooltip: 'Edit',
                    onTap: widget.onEdit,
                  ),
                  const SizedBox(width: 4),
                  ActionIconButton(
                    icon: Icons.delete_rounded,
                    color: widget.onDelete != null
                        ? Colors.red
                        : const Color(0xFFD1D5DB),
                    tooltip: widget.onDelete != null ? 'Delete' : 'Has products',
                    onTap: widget.onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Color Dot ─────────────────────────────────────────────────────────────────

class _ColorDot extends StatelessWidget {
  final Color color;
  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

// ── Color Hex Chip ────────────────────────────────────────────────────────────

class _ColorHexChip extends StatelessWidget {
  final String hex;
  final Color color;
  const _ColorHexChip({required this.hex, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        hex,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

// ── Product Count Badge ───────────────────────────────────────────────────────

class ProductCountBadge extends StatelessWidget {
  final int count;
  const ProductCountBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final hasProducts = count > 0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: hasProducts
                ? const Color(0xFFFF6B00).withValues(alpha: 0.08)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasProducts
                  ? const Color(0xFFFF6B00).withValues(alpha: 0.2)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasProducts
                      ? const Color(0xFFFF6B00)
                      : const Color(0xFFD1D5DB),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$count ${count == 1 ? 'product' : 'products'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasProducts
                      ? const Color(0xFFFF6B00)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Action Icon Button ────────────────────────────────────────────────────────

class ActionIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  const ActionIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onTap,
  });

  @override
  State<ActionIconButton> createState() => _ActionIconButtonState();
}

class _ActionIconButtonState extends State<ActionIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _hovered && enabled
                  ? widget.color.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: 17,
              color: enabled ? widget.color : const Color(0xFFD1D5DB),
            ),
          ),
        ),
      ),
    );
  }
}
