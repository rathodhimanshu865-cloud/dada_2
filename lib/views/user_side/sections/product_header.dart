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
                  _buildCatalogueDropdown(context, darkCharcoal, primaryTeal),
                  const SizedBox(width: 20),
                  _navLink(context, 'Pu. Dada Teachings', '/teachings', darkCharcoal),
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

  Widget _buildCatalogueDropdown(BuildContext context, Color textColor, Color primaryColor) {
    final categories = [
      {'title': 'Keychains', 'icon': '🔑'},
      {'title': 'Acrylic Photo Frames', 'icon': '🖼️'},
      {'title': 'Temple', 'icon': '⛩️'},
      {'title': 'Idols', 'icon': '🕉️'},
      {'title': 'Books & Granths', 'icon': '📚'},
      {'title': 'Yantras & Malas', 'icon': '📿'},
      {'title': 'Puja Items', 'icon': '🪔'},
      {'title': 'Apparel', 'icon': '👕'},
    ];

    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 45),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        color: Colors.white,
        tooltip: '',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Product Catalogue',
              style: AppTypography.bodyStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16, color: textColor),
          ],
        ),
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            enabled: false,
            padding: const EdgeInsets.all(0),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sacred Categories',
                    style: AppTypography.headingStyle(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: categories.map((cat) {
                      return SizedBox(
                        width: 200,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context); // Close popup
                            Navigator.pushNamed(context, '/catalogue');
                          },
                          child: Row(
                            children: [
                              Text(cat['icon']!, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  cat['title']!,
                                  style: AppTypography.bodyStyle(
                                    context,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2B2B2B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close popup
                        Navigator.pushNamed(context, '/catalogue');
                      },
                      child: Text(
                        'Explore All Products >',
                        style: AppTypography.bodyStyle(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
