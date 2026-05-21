import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/product_model.dart';

class PosProductCard extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;

  const PosProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stockStatus == 'out_of_stock';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 120,
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B00),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 120,
                    color: Colors.grey[100],
                    child: Icon(
                      Icons.fastfood,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Price
                    Text(
                      product.priceFormatted,
                      style: const TextStyle(
                        color: Color(0xFFFF6B00),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Description
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                    const SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Add Button or Stepper
                    quantity == 0
                        ? SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: ElevatedButton(
                              onPressed: isOutOfStock ? null : onAdd,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B00),
                                disabledBackgroundColor: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                isOutOfStock ? 'Out of Stock' : 'Add',
                                style: TextStyle(
                                  color: isOutOfStock
                                      ? Colors.grey[600]
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _StepperButton(icon: Icons.remove, onTap: onRemove),
                              Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              _StepperButton(icon: Icons.add, onTap: onIncrement),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),

          // Out of Stock Overlay
          if (isOutOfStock)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Out of Stock',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Private Stepper Button ──────────────────────────────
class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B00),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}