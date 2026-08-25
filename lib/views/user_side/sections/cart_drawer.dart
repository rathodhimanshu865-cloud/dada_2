import 'package:flutter/material.dart';
import '../../../utils/app_typography.dart';

class CartDrawer extends StatelessWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF0F4C5C);
    const Color templeGold = Color(0xFFC89A5B);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double drawerWidth = screenWidth > 600 ? 450 : screenWidth * 0.85;
    
    return Drawer(
      width: drawerWidth,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header: Icon | Title | Count | Close
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 22, color: primaryTeal),
                  const SizedBox(width: 12),
                  Text(
                    'Your Shopping Bag',
                    style: AppTypography.headingStyle(
                      context,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '0',
                      style: AppTypography.bodyStyle(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryTeal,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // Shipping Progress Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 16, color: primaryTeal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.bodyStyle(
                              context,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            children: [
                              const TextSpan(text: 'Add '),
                              TextSpan(
                                text: '₹499.00',
                                style: const TextStyle(fontWeight: FontWeight.w800, color: primaryTeal),
                              ),
                              const TextSpan(text: ' more for Free Express Shipping'),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        '0%',
                        style: AppTypography.bodyStyle(
                          context,
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: 0.0,
                      backgroundColor: const Color(0xFFEEEEEE),
                      valueColor: const AlwaysStoppedAnimation<Color>(templeGold),
                      minHeight: 2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // Empty State Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: primaryTeal.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 44,
                        color: primaryTeal.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Your bag is empty',
                      style: AppTypography.headingStyle(
                        context,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Discover handcrafted timepieces, bespoke ceramics, fine merino knitwear, and leather goods.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyStyle(
                        context,
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/catalogue');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'EXPLORE CATALOG',
                          style: AppTypography.bodyStyle(
                            context,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: Colors.white,
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
      ),
    );
  }
}
