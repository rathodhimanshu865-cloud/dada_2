import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context);
    final productController = Provider.of<ProductController>(context);

    return UserPageLayout(
      controller: homeController,
      child: Column(
        children: [
          const SizedBox(height: 120),
          const Text('SHOP', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF0F4C5C))),
          const SizedBox(height: 40),
          if (productController.isLoading)
            const CircularProgressIndicator()
          else if (productController.visibleProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Text('No products available at the moment.'),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: productController.visibleProducts.length,
                itemBuilder: (context, index) {
                  final product = productController.visibleProducts[index];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/products/${product.slug}'),
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: product.images.isNotEmpty
                                ? Image.network(product.images.first, fit: BoxFit.cover)
                                : const Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                Text('₹${product.price ?? 0}', style: const TextStyle(color: Color(0xFFC19A6B), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 80),
          UserFooter(controller: homeController),
        ],
      ),
    );
  }
}
