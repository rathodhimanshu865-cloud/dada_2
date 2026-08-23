import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../utils/app_typography.dart';

class ProductHeader extends StatelessWidget {
  final bool isSticky;

  const ProductHeader({
    super.key,
    this.isSticky = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryTeal = const Color(0xFF0F4C5C);
    final Color darkCharcoal = const Color(0xFF2B2B2B);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 2.0,
          ),
        ),
        boxShadow: isSticky
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Group A: Quick Portals & Navigation Links
              Row(
                children: [
                  _navLink(context, 'Home Portal', '/product', darkCharcoal),
                  const SizedBox(width: 20),
                  _navLink(context, 'Product Catalogue', '/product', darkCharcoal),
                  const SizedBox(width: 20),
                  _navLink(context, 'Pu. Dada Teachings', '/about_dada', darkCharcoal),
                  const SizedBox(width: 20),
                  _navLink(context, 'Track Shipment', '/track', darkCharcoal),
                ],
              ),
              // Group B: Central Product Search Bar
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Group C: User Actions (Wishlist & Cart Counters)
              Row(
                children: [
                  _actionButton(context, Icons.favorite_border, 'Favorites', '/favorites', darkCharcoal),
                  const SizedBox(width: 20),
                  _cartButton(context, darkCharcoal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navLink(BuildContext context, String title, String route, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Text(
        title,
        style: AppTypography.bodyStyle(
          context,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, String route, Color color) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.bodyStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartButton(BuildContext context, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/cart');
      },
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.shopping_cart_outlined, color: color, size: 22),
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            'Cart',
            style: AppTypography.bodyStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
