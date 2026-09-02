import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dada_2/controllers/language_controller.dart';
import 'package:dada_2/controllers/cart_controller.dart';
import 'package:dada_2/controllers/auth_controller.dart';
import 'package:dada_2/controllers/product_controller.dart';
import 'package:dada_2/models/product_model.dart';
import 'package:dada_2/utils/app_typography.dart';

class QuickViewDialog extends StatefulWidget {
  final ProductModel product;

  const QuickViewDialog({super.key, required this.product});

  @override
  State<QuickViewDialog> createState() => _QuickViewDialogState();
}

class _QuickViewDialogState extends State<QuickViewDialog> {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  final TextEditingController _pincodeCtrl = TextEditingController();
  bool _isPincodeValid = false;

  late List<String> _productImages;

  @override
  void initState() {
    super.initState();
    _productImages = widget.product.imageUrls.isNotEmpty 
      ? widget.product.imageUrls 
      : [widget.product.imageUrl];
    if (_productImages.isEmpty) {
      _productImages = ['https://via.placeholder.com/600x800/FAF8F4/0F4C5C?text=No+Image'];
    }
  }

  @override
  void dispose() {
    _pincodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF07404C);
    const Color accentGold = Color(0xFFC89A5B);
    final cartController = Provider.of<CartController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      backgroundColor: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 700;
          return Container(
            width: 1000,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogHeader(primaryTeal, accentGold),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 20 : 32),
                    child: isMobile ? Column(
                      children: [
                        _buildImageSection(primaryTeal, accentGold),
                        const SizedBox(height: 32),
                        _buildInfoSection(context, primaryTeal, accentGold, cartController, authController),
                      ],
                    ) : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _buildImageSection(primaryTeal, accentGold)),
                        const SizedBox(width: 40),
                        Expanded(flex: 5, child: _buildInfoSection(context, primaryTeal, accentGold, cartController, authController)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogHeader(Color teal, Color gold) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: teal.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: teal.withOpacity(0.1))), child: Text('QUICK VIEW', style: AppTypography.bodyStyle(context, color: teal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
          const SizedBox(width: 16),
          Text('SKU: DADA-PROD-${widget.product.id.substring(0, 4).toUpperCase()}', style: AppTypography.bodyStyle(context, color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 24, color: Colors.grey), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ],
      ),
    );
  }

  Widget _buildImageSection(Color teal, Color gold) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => _showFullScreenImage(context, _productImages[_selectedImageIndex]),
              child: Container(
                height: 480, 
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), 
                  border: Border.all(color: Colors.grey.shade100),
                  color: Colors.grey.shade50,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: _productImages[_selectedImageIndex],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start, 
          children: _productImages.asMap().entries.map((e) => GestureDetector(
            onTap: () => setState(() => _selectedImageIndex = e.key), 
            child: Container(
              margin: const EdgeInsets.only(right: 12), 
              width: 70, 
              height: 70, 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), 
                border: Border.all(color: _selectedImageIndex == e.key ? teal : Colors.grey.shade200, width: 2), 
              ), 
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: e.value,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) => const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            )
          )).toList()
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain)),
            Positioned(top: 40, right: 40, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 32), onPressed: () => Navigator.pop(context))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, Color teal, Color gold, CartController cart, AuthController auth) {
    final p = widget.product;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: teal.withOpacity(0.05), borderRadius: BorderRadius.circular(4)), child: Text(p.categoryId.toUpperCase(), style: AppTypography.bodyStyle(context, color: teal, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5))),
        const SizedBox(height: 15),
        Text(p.localizedName(lang), style: AppTypography.headingStyle(context, fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 8),
        Text(p.localizedShortSummary(lang), style: AppTypography.bodyStyle(context, color: Colors.grey.shade600, fontSize: 14, height: 1.5)),
        const SizedBox(height: 25),
        Text('₹${p.price.toInt()}', style: AppTypography.headingStyle(context, fontSize: 32, color: teal, fontWeight: FontWeight.w900)),
        const SizedBox(height: 32),
        
        // Pincode Check
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Delivery Pincode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 10),
              TextField(
                controller: _pincodeCtrl,
                onChanged: (val) => setState(() => _isPincodeValid = val.trim().length == 6),
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(hintText: 'Enter 6-digit Pincode', counterText: '', isDense: true, border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        Row(children: [_buildQuantitySelector(teal), const SizedBox(width: 15), Expanded(child: _buildAddButton(context, teal, cart))]),
        const SizedBox(height: 15),
        _buildBuyNowButton(context, teal, gold, auth, cart),
      ],
    );
  }

  Widget _buildQuantitySelector(Color teal) => Container(height: 55, padding: const EdgeInsets.symmetric(horizontal: 8), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8), color: const Color(0xFFF9F9F9)), child: Row(children: [IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove, size: 16)), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('$_quantity', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w800, fontSize: 15))), IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add, size: 16))]));
  
  Widget _buildAddButton(BuildContext context, Color teal, CartController cart) {
    final p = widget.product;
    return SizedBox(height: 55, child: ElevatedButton(onPressed: p.stock > 0 ? (_isPincodeValid ? () { 
      if (Provider.of<AuthController>(context, listen: false).isAuthenticated) {
        cart.addToCart(p, _quantity); 
        Navigator.pop(context); 
        Scaffold.of(context).openEndDrawer(); 
      } else {
        Provider.of<AuthController>(context, listen: false).toggleLoginPortal(true);
      }
    } : null) : null, style: ElevatedButton.styleFrom(backgroundColor: p.stock > 0 ? teal : Colors.grey, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text(p.stock > 0 ? (_isPincodeValid ? 'ADD TO BAG' : 'ENTER 6-DIGIT PINCODE') : 'OUT OF STOCK', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white))));
  }

  Widget _buildBuyNowButton(BuildContext context, Color teal, Color gold, AuthController auth, CartController cart) {
    final p = widget.product;
    return SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: p.stock > 0 ? (_isPincodeValid ? () { if (auth.isAuthenticated) { cart.addToCart(p, _quantity); Navigator.pop(context); Navigator.pushNamed(context, '/checkout'); } else { Navigator.pop(context); auth.toggleLoginPortal(true); } } : null) : null, style: ElevatedButton.styleFrom(backgroundColor: p.stock > 0 ? gold : Colors.grey.shade300, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text(p.stock > 0 ? '⚡ Buy Now - Direct Checkout' : 'CURRENTLY UNAVAILABLE', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))));
  }
}
