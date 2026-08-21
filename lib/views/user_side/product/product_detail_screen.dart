import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/product_detail_provider.dart';
import '../../../models/product_model.dart';
import '../../../models/product_variant_model.dart';
import '../../../models/review_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductDetailProvider>(context, listen: false).setProduct(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE), // Ivory
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A1F1F), // Maroon
        title: Text(widget.product.title, style: const TextStyle(fontFamily: 'Poppins')),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
        ],
      ),
      body: Consumer<ProductDetailProvider>(
        builder: (context, provider, child) {
          if (provider.product == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGallery(provider),
                _buildTitleAndPrice(provider),
                _buildVariants(provider),
                _buildPurchaseAction(provider),
                _buildDivider(),
                _buildHighlights(provider),
                _buildDivider(),
                _buildDescription(provider),
                _buildDivider(),
                _buildReviews(provider),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildStickyBottomBar(),
    );
  }

  Widget _buildGallery(ProductDetailProvider provider) {
    final images = provider.product?.images ?? [];
    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image, size: 100, color: Colors.white)),
      );
    }
    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: images.length,
        onPageChanged: (idx) => provider.setCurrentImageIndex(idx),
        itemBuilder: (context, index) {
          return Image.network(images[index], fit: BoxFit.contain);
        },
      ),
    );
  }

  Widget _buildTitleAndPrice(ProductDetailProvider provider) {
    final p = provider.product!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.badges.isNotEmpty)
            Wrap(
              spacing: 8.0,
              children: p.badges.map((b) => Chip(
                label: Text(b, style: const TextStyle(fontSize: 10, color: Colors.white)),
                backgroundColor: const Color(0xFFD4A017), // Gold accent
              )).toList(),
            ),
          const SizedBox(height: 8),
          Text(
            p.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B1B12), fontFamily: 'Poppins'),
          ),
          Text(
            'By ${p.author}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF1B4B66)), // Peacock blue
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '₹${provider.currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)), // Saffron
              ),
              if (p.price != null && p.salePrice != null) ...[
                const SizedBox(width: 8),
                Text(
                  '₹${p.price?.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey, decoration: TextDecoration.lineThrough),
                ),
              ]
            ],
          ),
          const SizedBox(height: 8),
          Text(
            provider.isOutOfStock ? 'Sold Out' : 'In Stock',
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold, 
              color: provider.isOutOfStock ? const Color(0xFFC1440E) : const Color(0xFF2E7D32)
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVariants(ProductDetailProvider provider) {
    if (provider.product!.variants.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: provider.product!.variants.map((v) {
              final isSelected = provider.selectedVariant?.id == v.id;
              return ChoiceChip(
                label: Text(v.name),
                selected: isSelected,
                selectedColor: const Color(0xFFFF7A00).withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFFFF7A00) : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                ),
                onSelected: (selected) {
                  if (selected) provider.selectVariant(v);
                },
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildPurchaseAction(ProductDetailProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.remove), onPressed: provider.decrementQuantity),
                Text('${provider.quantity}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add), onPressed: provider.incrementQuantity),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: provider.isOutOfStock ? null : () {
                // Add to cart logic
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart!')));
              },
              child: const Text('ADD TO CART', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHighlights(ProductDetailProvider provider) {
    final highlights = provider.product!.keyHighlights;
    if (highlights.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Key Highlights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          ...highlights.map((h) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, size: 16, color: Color(0xFFD4A017)),
                const SizedBox(width: 8),
                Expanded(child: Text(h)),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildDescription(ProductDetailProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          Text(
            provider.product!.description,
            style: const TextStyle(color: Color(0xFF2B1B12), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews(ProductDetailProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Devotee Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              TextButton(onPressed: () {}, child: const Text('Write a Review', style: TextStyle(color: Color(0xFF1B4B66)))),
            ],
          ),
          const SizedBox(height: 8),
          const Text('No reviews yet. Be the first to share your experience!'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Divider(color: Color(0xFFD4A017), thickness: 0.5),
    );
  }

  Widget _buildStickyBottomBar() {
    return Consumer<ProductDetailProvider>(
      builder: (context, provider, child) {
        if (provider.product == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF7A00), side: const BorderSide(color: Color(0xFFFF7A00)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {},
                    child: const Text('BUY NOW'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
