import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/product_model.dart';
import 'sections/product_cart_layout.dart';
import 'sections/product_card.dart';
import '../../utils/app_typography.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  int _selectedFinishIndex = 0;
  int _selectedSizeIndex = 0;
  bool _includeGangaJal = true;
  bool _includeGiftWrap = false;
  
  final Color primaryTeal = const Color(0xFF07404C);
  final Color templeGold = const Color(0xFFC89A5B);
  
  Stream<ProductModel?>? _productStream;
  String? _lastProductId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      String? productId;
      
      if (args is String) {
        productId = args;
      } else if (args is Map) {
        productId = args['id']?.toString() ?? args['productId']?.toString();
      }

      if (productId != null && productId != _lastProductId) {
        _lastProductId = productId;
        // Fetch stream only once per ID
        final productController = Provider.of<ProductController>(context, listen: false);
        _productStream = productController.getProductDetails(productId);
      }
    } catch (e) {
      // Extraction error handled silently
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to HomePageController for footer/branding, but only on relevant changes
    final homeController = Provider.of<HomePageController>(context, listen: false);
    // Use listen: false for ProductController to prevent global rebuilds
    final productController = Provider.of<ProductController>(context, listen: false);

    return StreamBuilder<ProductModel?>(
      stream: _productStream,
      builder: (context, snapshot) {
        List<Widget> contentSlivers = [];

        if (_lastProductId == null) {
          contentSlivers = [
            const SliverToBoxAdapter(child: SizedBox(height: 500, child: Center(child: Text('Initializing sacred item details...'))))
          ];
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          contentSlivers = [
            const SliverToBoxAdapter(child: SizedBox(height: 600, child: Center(child: CircularProgressIndicator(color: Color(0xFF07404C)))))
          ];
        } else if (snapshot.hasError) {
          contentSlivers = [
            SliverToBoxAdapter(child: SizedBox(height: 500, child: Center(child: Text('Error: ${snapshot.error}'))))
          ];
        } else if (!snapshot.hasData || snapshot.data == null) {
          contentSlivers = [
            const SliverToBoxAdapter(child: SizedBox(height: 500, child: Center(child: Text('Item not found in our records.'))))
          ];
        } else {
          final p = snapshot.data!;
          final List<String> images = p.imageUrls.isNotEmpty 
              ? p.imageUrls.where((url) => url.isNotEmpty).toList() 
              : (p.imageUrl.isNotEmpty ? [p.imageUrl] : <String>[]);
          
          if (images.isEmpty) images.add('');
          if (_selectedImageIndex >= images.length) _selectedImageIndex = 0;

          contentSlivers = [
            SliverToBoxAdapter(child: _buildTopHeader(p)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: _buildGallery(images, p)),
                            const SizedBox(width: 64),
                            Expanded(flex: 5, child: _buildProductInfo(p)),
                          ],
                        ),
                        const SizedBox(height: 80),
                        _buildBundledOffer(p),
                        const SizedBox(height: 80),
                        _buildDetailsTabs(p),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: _buildRecommendationTitle("Similar & Related Devotional Items"),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
            _buildRecommendationGrid(productController, p.categoryId, limit: 4),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
            _buildBrowsingHistory(productController),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ];
        }

        return ProductCartLayout(
          controller: homeController,
          slivers: contentSlivers.isEmpty ? [const SliverToBoxAdapter(child: SizedBox.shrink())] : contentSlivers,
          child: const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildTopHeader(ProductModel p) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            children: [
              Text('Sacred Catalog', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
              Text(p.categoryId, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
              Text(p.name, style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGallery(List<String> images, ProductModel p) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 700,
              width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (images.isNotEmpty && images[_selectedImageIndex].isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: images[_selectedImageIndex], 
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(Icons.image_outlined, size: 100, color: Colors.grey),
                    )
                  : const Icon(Icons.image_outlined, size: 100, color: Colors.grey),
              ),
            ),
            Positioned(
              top: 24, left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF07404C), borderRadius: BorderRadius.circular(30)),
                child: const Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
            Positioned(
              top: 24, right: 24,
              child: Row(
                children: [
                  _circleIcon(Icons.share_outlined),
                  const SizedBox(width: 12),
                  _circleIcon(Icons.zoom_in_map_outlined),
                ],
              ),
            ),
            Positioned(
              bottom: 24, left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, size: 14, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('100% Genuine Atelier Stock', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: images.asMap().entries.map((e) {
              if (e.value.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => setState(() => _selectedImageIndex = e.key),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _selectedImageIndex == e.key ? primaryTeal : Colors.grey.shade200, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6), 
                    child: CachedNetworkImage(
                      imageUrl: e.value, 
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(Icons.image_outlined),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(ProductModel p) {
    final finishes = p.finishes.isNotEmpty ? p.finishes : ['Standard Finish'];
    final sizes = p.sizes.isNotEmpty ? p.sizes : ['Standard Edition'];
    
    if (_selectedFinishIndex >= finishes.length) _selectedFinishIndex = 0;
    if (_selectedSizeIndex >= sizes.length) _selectedSizeIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFF9F6F0), borderRadius: BorderRadius.circular(4)),
              child: Text(p.categoryId.toUpperCase(), style: const TextStyle(color: Color(0xFFC89A5B), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
            Row(
              children: [
                Row(children: List.generate(5, (i) => Icon(Icons.star, color: Colors.amber, size: 16))),
                const SizedBox(width: 8),
                Text('${p.rating}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(' (${p.reviewCount} reviews)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(p.name, style: GoogleFonts.cormorantGaramond(fontSize: 48, fontWeight: FontWeight.w600, color: primaryTeal, height: 1.1)),
        const SizedBox(height: 8),
        Text(p.shortSummary, style: TextStyle(color: Colors.grey.shade500, fontSize: 16, height: 1.5)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(color: const Color(0xFFFDFBF7), borderRadius: BorderRadius.circular(8), border: Border.all(color: templeGold.withOpacity(0.1))),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: templeGold, size: 18),
              const SizedBox(width: 16),
              const Expanded(child: Text('Sanctified & Consecrated: Energized with holy temple mantras.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2B2B2B)))),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
          children: [
            Text('₹${p.price.toInt()}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF07404C))),
            const SizedBox(width: 12),
            if (p.comparePrice != null) ...[
              Text('₹${p.comparePrice!.toInt()}', style: const TextStyle(fontSize: 18, color: Colors.grey, decoration: TextDecoration.lineThrough)),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF8B4513).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text('Save ₹${(p.comparePrice! - p.price).toInt()} (${p.discountPercentage}% OFF)', style: const TextStyle(color: Color(0xFF8B4513), fontWeight: FontWeight.w900, fontSize: 11)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFE6F7F0), borderRadius: BorderRadius.circular(4)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
              const SizedBox(width: 12),
              const Text('In Sanctified Stock — Auspicious 24-hr temple dispatch', style: TextStyle(color: Color(0xFF065F46), fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text('Attach divine positivity directly to your smartphone. Durable braided sacred loop with lightweight acrylic charm featuring Dada and Radhe Radhe blessing.', style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
        const SizedBox(height: 40),
        RichText(text: TextSpan(style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold), children: [const TextSpan(text: 'Selected Option / Finish:   '), TextSpan(text: finishes[_selectedFinishIndex], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal))])),
        const SizedBox(height: 16),
        Row(
          children: [
            _variantCircle(const Color(0xFFF7C325), _selectedFinishIndex == 0, () => setState(() => _selectedFinishIndex = 0)),
            if (finishes.length > 1) ...[
              _variantCircle(const Color(0xFFAD3B1D), _selectedFinishIndex == 1, () => setState(() => _selectedFinishIndex = 1)),
              if (finishes.length > 2) _variantCircle(const Color(0xFFE35400), _selectedFinishIndex == 2, () => setState(() => _selectedFinishIndex = 2)),
            ]
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Select Size / Edition:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            TextButton.icon(onPressed: () {}, icon: const Icon(Icons.straighten, size: 14, color: Colors.grey), label: const Text('Deity & Altar Sizing Guide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, decoration: TextDecoration.underline))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _sizeBtn(sizes[0], _selectedSizeIndex == 0, () => setState(() => _selectedSizeIndex = 0)),
            if (sizes.length > 1) ...[
              const SizedBox(width: 16),
              _sizeBtn(sizes[1], _selectedSizeIndex == 1, () => setState(() => _selectedSizeIndex = 1)),
            ],
          ],
        ),
        const SizedBox(height: 40),
        _buildComplimentaryItem('Complimentary Gangajal, Chandan Tika & Raksha Sutra Kit (Free)', 'Includes certified holy water from Haridwar and energized temple red thread.', _includeGangaJal, (v) => setState(() => _includeGangaJal = v!)),
        _buildComplimentaryItem('Auspicious Red-Saffron Gift Wrap & Devotional Card (₹49)', '', _includeGiftWrap, (v) => setState(() => _includeGiftWrap = v!)),
        const SizedBox(height: 40),
        Row(
          children: [
            _qtySelector(),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<CartController>(context, listen: false).addToCart(p, _quantity);
                  Scaffold.of(context).openEndDrawer();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF07404C), padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                child: Text('ADD TO BAG • ₹${(p.price * _quantity).toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
            const SizedBox(width: 16),
            _circleIcon(Icons.favorite_border),
            const SizedBox(width: 12),
            _circleIcon(Icons.share_outlined),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFAD8B63),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            minimumSize: const Size(double.infinity, 60),
          ),
          child: const Text('⚡ INSTANT SACRED CHECKOUT (COD / ONLINE)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        ),
        const SizedBox(height: 16),
        _buildWhatsAppBtn(),
        const SizedBox(height: 40),
        _buildDeliveryChecker(),
        const SizedBox(height: 48),
        _buildTrustFeatures(),
      ],
    );
  }

  Widget _buildComplimentaryItem(String title, String subtitle, bool value, Function(bool?) onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          SizedBox(width: 24, height: 24, child: Checkbox(value: value, onChanged: onChanged, activeColor: primaryTeal, side: const BorderSide(color: Colors.grey))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2B2B2B))),
                if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildWhatsAppBtn() => Container(
    height: 60,
    width: double.infinity,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF25D366))),
    child: InkWell(
      onTap: () {},
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366), size: 18), SizedBox(width: 12), Text('Order / Inquire via WhatsApp', style: TextStyle(color: Color(0xFF25D366), fontWeight: FontWeight.bold, fontSize: 13))]),
    ),
  );

  Widget _buildDeliveryChecker() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: const Color(0xFFFDFBF7), borderRadius: BorderRadius.circular(8), border: Border.all(color: templeGold.withOpacity(0.1))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(Icons.location_on_outlined, size: 16, color: templeGold), const SizedBox(width: 10), const Text('Delivery & Payment Availability', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), const Spacer(), const Text('Cash on Delivery Available', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '380001', 
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  fillColor: Colors.white, 
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF07404C), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), child: const Text('Check', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 24),
        _deliveryInfoItem(Icons.local_shipping_outlined, 'FREE Standard Delivery by Wed, Sep 2', 'Order in the next 4 hrs 15 mins for sanctum dispatch today.'),
        const SizedBox(height: 16),
        _deliveryInfoItem(Icons.bolt, 'Express 24-hr Air Courier available at checkout', 'Delivers by Mon, Aug 31 to metro locations.'),
      ],
    ),
  );

  Widget _deliveryInfoItem(IconData icon, String title, String sub) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: Colors.green.shade600),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey))])),
    ],
  );

  Widget _buildTrustFeatures() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade100), borderRadius: BorderRadius.circular(8)),
    child: Wrap(
      spacing: 40, runSpacing: 24,
      children: [
        _trustIconItem(Icons.lock_outline, '100% Safe & Secure Payment Options', '256-Bit SSL Encrypted'),
        _trustIconItem(Icons.workspace_premium_outlined, '100% Vedic Pure', 'Natural wood, brass & silk'),
        _trustIconItem(Icons.inventory_2_outlined, 'Safe Sacred Transit', 'Zero breakage guarantee'),
        _trustIconItem(Icons.temple_hindu_outlined, 'Holy Dham Heritage', 'Direct artisan seva'),
      ],
    ),
  );

  Widget _trustIconItem(IconData icon, String title, String sub) => SizedBox(
    width: 250,
    child: Row(
      children: [
        Icon(icon, size: 24, color: templeGold.withOpacity(0.6)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey))])),
      ],
    ),
  );

  Widget _buildBundledOffer(ProductModel p) => Container(
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(color: const Color(0xFFFDFBF7), borderRadius: BorderRadius.circular(8), border: Border.all(color: templeGold.withOpacity(0.1))),
    child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [Icon(Icons.auto_awesome, color: templeGold, size: 20), const SizedBox(width: 12), const Text('Frequently Blessed Together — Save 10% on Complete Sacred Set', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2B2B2B)))]),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _bundleItem(p.imageUrl, p.name, p.price),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Icon(Icons.add, color: Colors.grey, size: 16)),
                _bundleItem(p.imageUrl, "Mobile Keychain", 119),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Icon(Icons.add, color: Colors.grey, size: 16)),
                _bundleItem(p.imageUrl, "Dada's Photo + Radha Krishna", 149),
              ],
            ),
            const SizedBox(width: 60),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Bundle Total (10% Off):', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                Row(children: [const Text('₹330.3', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF07404C))), const SizedBox(width: 12), Text('₹367', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 16))]),
                const SizedBox(height: 20),
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.shopping_bag_outlined, size: 16), label: const Text('ADD COMPLETE SET TO BAG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF07404C), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  Widget _bundleItem(String img, String name, double price) => Row(
    children: [
      SizedBox(width: 20, height: 20, child: Checkbox(value: true, onChanged: (v) {}, activeColor: primaryTeal)),
      const SizedBox(width: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(4), 
        child: img.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: img, 
              width: 60, height: 60, 
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.image_outlined),
            )
          : Container(width: 60, height: 60, color: Colors.grey.shade100, child: const Icon(Icons.image_outlined)),
      ),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2B2B2B))), Text('₹${price.toInt()}', style: const TextStyle(fontSize: 12, color: Colors.grey))]),
    ],
  );

  Widget _buildDetailsTabs(ProductModel p) => DefaultTabController(
    length: 5,
    child: Column(
      children: [
        TabBar(
          isScrollable: true,
          indicatorColor: primaryTeal, labelColor: primaryTeal, unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [Tab(text: 'Vedic Significance & Details'), Tab(text: 'Specifications & Dimensions'), Tab(text: 'Sacred Care & Purity'), Tab(text: 'Devotee Reviews (0)'), Tab(text: 'FAQs & Guidance')],
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 350,
          child: TabBarView(
            children: [
              _buildTabContent("Features an ultra-strong tensile nylon lanyard loop that fits through any speaker hole or phone case lanyard port, paired with a miniature sacred acrylic pendant.", p.highlights),
              const Center(child: Text("Dimensions: 2 x 1.5 inches\nWeight: 15g\nMaterial: Premium Acrylic")),
              const Center(child: Text("Handle with reverence. Clean with a soft, dry cloth.")),
              const Center(child: Text("No reviews yet. Be the first to share your blessing!")),
              const Center(child: Text("Can I take this to office? Yes, it is designed for daily use.")),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildTabContent(String desc, List<String> highlights) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(desc, style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.6)),
      const SizedBox(height: 32),
      const Text('DEVOTIONAL HIGHLIGHTS & ARTISANAL MERITS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black87)),
      const SizedBox(height: 24),
      // Replace GridView with Wrap or Column for better stability in slivers
      Wrap(
        spacing: 32,
        runSpacing: 16,
        children: List.generate(
          highlights.isNotEmpty ? highlights.length.clamp(0, 4) : 4,
          (i) {
            final text = (highlights.isNotEmpty && i < highlights.length) 
                ? highlights[i] 
                : (i == 0 ? 'Universal attachment for all smartphone cases and bags' : i == 1 ? 'High-tensile braided nylon cord' : i == 2 ? 'Featherlight design' : 'Sacred blessing emblem');
            return SizedBox(
              width: 300, // Approximate half-width for 2-column effect
              child: Row(
                children: [
                  Icon(Icons.check, size: 14, color: Colors.green.shade600),
                  const SizedBox(width: 12),
                  Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black54))),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );

  Widget _buildRecommendationTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, color: Color(0xFF8B4513))), 
        TextButton(onPressed: () {}, child: const Text('EXPLORE FULL COLLECTION →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)))
      ],
    );
  }

  Widget _buildRecommendationGrid(ProductController ctrl, String catId, {int limit = 8}) {
    final products = ctrl.allProducts.where((p) => p.categoryId == catId).take(limit).toList();
    if (products.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.75,
          crossAxisSpacing: 24,
          mainAxisSpacing: 40,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProductCard(product: products[index]),
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildBrowsingHistory(ProductController ctrl) {
    if (ctrl.allProducts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.history, size: 18, color: templeGold), const SizedBox(width: 12), const Text('YOUR BROWSING HISTORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.grey)), const Spacer(), TextButton(onPressed: () {}, child: const Text('Clear History', style: TextStyle(fontSize: 11, color: Colors.grey)))]),
            const SizedBox(height: 8),
            const Text('Recently Viewed Sacred Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            SizedBox(
              width: 300,
              height: 400,
              child: ProductCard(product: ctrl.allProducts.last),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon(IconData icon) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
    child: Icon(icon, size: 18, color: Colors.black54),
  );

  Widget _variantCircle(Color color, bool selected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? primaryTeal : Colors.transparent, width: 2)),
      child: Container(width: 28, height: 28, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    ),
  );

  Widget _sizeBtn(String label, bool selected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: selected ? primaryTeal : Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: selected ? primaryTeal : Colors.grey.shade300)),
      child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
    ),
  );

  Widget _qtySelector() => Container(
    height: 60,
    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
    child: Row(
      children: [
        IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove, size: 18)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add, size: 18)),
      ],
    ),
  );
}
