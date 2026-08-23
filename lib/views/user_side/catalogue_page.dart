import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import 'sections/product_cart_layout.dart';
import '../../utils/app_typography.dart';

class CataloguePage extends StatelessWidget {
  const CataloguePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context, listen: false);

    return ProductCartLayout(
      controller: controller,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Column(
            children: [
              Text(
                'Product Catalogue',
                style: AppTypography.headingStyle(
                  context,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F4C5C),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'This is the main Product Catalogue. More products will be listed here.',
                style: AppTypography.bodyStyle(context, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
