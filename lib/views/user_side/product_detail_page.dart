import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../../utils/app_typography.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';

class ProductDetailPage extends StatefulWidget {
  final String slug;
  const ProductDetailPage({super.key, required this.slug});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final Color _teal = const Color(0xFF0F4C5C);
  final Color _gold = const Color(0xFFC19A6B);
  final Color _slate = const Color(0xFF4A5568);
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context);
    final productController = Provider.of<ProductController>(context);
    
    final product = productController.getProductBySlug(widget.slug);
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return UserPageLayout(
      controller: homeController,
      child: Column(
        children: [
          const SizedBox(height: 120),
          if (productController.isLoading)
             const SizedBox(height: 500, child: Center(child: CircularProgressIndicator(color: Color(0xFF0F4C5C))))
          else if (product == null)
            _buildNotFound(context)
          else
            _buildProductDetail(context, product, isMobile),
          
          UserFooter(controller: homeController),
        ],
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Container(
      height: 600,
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text('PRODUCT NOT FOUND', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 16),
          const Text('The product you are looking for does not exist or has been removed.'),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/products'),
            style: ElevatedButton.styleFrom(backgroundColor: _teal, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
            child: const Text('BACK TO ALL PRODUCTS'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetail(BuildContext context, Product product, bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isMobile 
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(product, true),
                  const SizedBox(height: 40),
                  _buildProductInfo(product),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildImageGallery(product, false)),
                  const SizedBox(width: 80),
                  Expanded(flex: 1, child: _buildProductInfo(product)),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(Product product, bool isMobile) {
    if (product.images.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.image_not_supported_outlined, size: 80, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Main Image
        AspectRatio(
          aspectRatio: 0.85,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(product.images[_selectedImageIndex], fit: BoxFit.cover),
            ),
          ),
        ),
        
        // Thumbnails
        if (product.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: product.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => setState(() => _selectedImageIndex = i),
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _selectedImageIndex == i ? _teal : Colors.grey[300]!, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(product.images[i], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfo(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('BACK TO PRODUCTS'),
          style: TextButton.styleFrom(foregroundColor: _gold, padding: EdgeInsets.zero),
        ),
        const SizedBox(height: 20),
        
        Text(
          product.category.toUpperCase(),
          style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.5),
        ),
        const SizedBox(height: 12),
        Text(
          product.title,
          style: AppTypography.headingStyle(context, fontSize: 40, fontWeight: FontWeight.bold, color: _teal, height: 1.1),
        ),
        const SizedBox(height: 20),
        if (product.price != null) ...[
          Text(
            '₹${product.price}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 30),
        ],
        
        const Divider(height: 40),
        
        const Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5, color: Colors.grey)),
        const SizedBox(height: 16),
        Text(
          product.description,
          style: AppTypography.bodyStyle(context, fontSize: 16, height: 1.8, color: _slate),
        ),
        
        const SizedBox(height: 50),
        
        // Inquiry CTA
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: const Color(0xFFFAF8F4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE9E4DE))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Interested in this product?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F4C5C))),
              const SizedBox(height: 10),
              const Text('For inquiries regarding availability, shipping, or details, please contact us.', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/contact_us'),
                icon: const Icon(Icons.mail_outline),
                label: const Text('ENQUIRE NOW'),
                style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
