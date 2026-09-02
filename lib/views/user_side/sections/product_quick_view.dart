import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../controllers/language_controller.dart';
import '../../../models/product_model.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/responsive_utils.dart';

class ProductQuickView extends StatefulWidget {
  final ProductModel product;
  const ProductQuickView({super.key, required this.product});

  @override
  State<ProductQuickView> createState() => _ProductQuickViewState();
}

class _ProductQuickViewState extends State<ProductQuickView> {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  final Color primaryTeal = const Color(0xFF07404C);
  final Color templeGold = const Color(0xFFC89A5B);

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
  Widget build(BuildContext context) {
    final p = widget.product;
    final cart = Provider.of<CartController>(context, listen: false);
    final auth = Provider.of<AuthController>(context, listen: false);
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    final bool isMobile = Responsive.isMobile(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 40, vertical: isMobile ? 12 : 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 16 : 24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1100, 
          maxHeight: MediaQuery.of(context).size.height * 0.9
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFAF3E0), borderRadius: BorderRadius.circular(30)),
                    child: Text(l10n.quickView.toUpperCase(), style: TextStyle(color: templeGold, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.skuLabel(p.sku), overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                  IconButton(
                    onPressed: () => Navigator.pop(context), 
                    icon: const Icon(Icons.close, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Flexible(
                child: SingleChildScrollView(
                  child: isMobile 
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSection(p, isMobile),
                          const SizedBox(height: 24),
                          _buildInfoSection(p, lang, auth, cart, isMobile),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _buildImageSection(p, isMobile)),
                          const SizedBox(width: 40),
                          Expanded(flex: 6, child: _buildInfoSection(p, lang, auth, cart, isMobile)),
                        ],
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(ProductModel p, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => _showFullScreenImage(context, _productImages[_selectedImageIndex]),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: _productImages[_selectedImageIndex],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              if (p.isFeatured)
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFD42E2E), borderRadius: BorderRadius.circular(4)),
                    child: Text(l10n.bestseller, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                  ),
                ),
              Positioned(
                bottom: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                  child: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _productImages.asMap().entries.map((e) => GestureDetector(
              onTap: () => setState(() => _selectedImageIndex = e.key),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                width: isMobile ? 55 : 65, height: isMobile ? 55 : 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _selectedImageIndex == e.key ? primaryTeal : Colors.grey.shade200, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(imageUrl: e.value, fit: BoxFit.cover),
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(ProductModel p, String lang, AuthController auth, CartController cart, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: primaryTeal.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
          child: Text(p.categoryId.toUpperCase(), style: TextStyle(color: primaryTeal, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
        const SizedBox(height: 12),
        Text(p.localizedName(lang), style: GoogleFonts.cormorantGaramond(fontSize: isMobile ? 26 : 32, fontWeight: FontWeight.w700, color: primaryTeal, height: 1.1)),
        const SizedBox(height: 8),
        Text(p.localizedShortSummary(lang), style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5)),
        const SizedBox(height: 16),
        Row(
          children: [
            Row(children: List.generate(5, (i) => Icon(Icons.star, color: Colors.amber, size: 14))),
            const SizedBox(width: 8),
            Text(l10n.ratingReviews(p.rating, p.reviewCount), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('₹${p.price.toInt()}', style: TextStyle(fontSize: isMobile ? 28 : 32, fontWeight: FontWeight.w900, color: primaryTeal)),
            const SizedBox(width: 12),
            if (p.comparePrice != null && p.comparePrice! > p.price) ...[
              Text('₹${p.comparePrice!.toInt()}', style: const TextStyle(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE6F7F0), borderRadius: BorderRadius.circular(4)),
                child: Text(l10n.offPercentage(p.discountPercentage), style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w900)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFE6F7F0), borderRadius: BorderRadius.circular(30)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Flexible(child: Text(l10n.inSanctifiedStock, style: const TextStyle(color: Color(0xFF065F46), fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            _qtySelector(),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (auth.isAuthenticated) {
                    cart.addToCart(p, _quantity);
                    Navigator.pop(context);
                    Scaffold.of(context).openEndDrawer();
                  } else {
                    auth.toggleLoginPortal(true);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Text(l10n.addWithPrice((p.price * _quantity).toInt()), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
              ),
            ),
            const SizedBox(width: 12),
            _favBtn(p.id),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            if (auth.isAuthenticated) {
              cart.addToCart(p, _quantity);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/checkout');
            } else {
              auth.toggleLoginPortal(true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: templeGold,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(l10n.instantCheckout, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/product_details', arguments: p.id);
            },
            icon: Text(l10n.viewDetailedSpecs, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
            label: const Icon(Icons.arrow_forward, size: 14, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black.withOpacity(0.9), width: double.infinity, height: double.infinity),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8, maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 40, right: 40,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtySelector() => Container(
    height: 58,
    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
    child: Row(
      children: [
        IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove, size: 16)),
        Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add, size: 16)),
      ],
    ),
  );

  Widget _favBtn(String id) => Consumer<ProductController>(
    builder: (context, prodCtrl, _) {
      bool isLiked = prodCtrl.isLiked(id);
      return GestureDetector(
        onTap: () {
          if (Provider.of<AuthController>(context, listen: false).isAuthenticated) {
            prodCtrl.toggleLike(id);
          } else {
            Provider.of<AuthController>(context, listen: false).toggleLoginPortal(true);
          }
        },
        child: Container(
          width: 58, height: 58,
          decoration: BoxDecoration(color: const Color(0xFFFFF1F1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFFDEDE))),
          child: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: const Color(0xFFFF2D55), size: 20),
        ),
      );
    }
  );
}
