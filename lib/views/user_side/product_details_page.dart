import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final Color backgroundCream = const Color(0xFFFDFBF7);

  final List<String> _availableFinishes = ['Glossy Crystal', 'Matte Finish', 'Premium Oak'];
  final List<String> _availableSizes = ['Standard Pocket Size (2 x 1.5 in)', 'Large Keyring Size (2.5 x 2 in)'];

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final productController = Provider.of<ProductController>(context);
    final String? productId = ModalRoute.of(context)?.settings.arguments as String?;

    return ProductCartLayout(
      controller: homeController,
      child: productId == null 
        ? const SizedBox(height: 600, child: Center(child: Text('No product selected. Please return to the catalogue.')))
        : StreamBuilder<ProductModel?>(
            stream: productController.getProductDetails(productId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 600, child: Center(child: CircularProgressIndicator(color: Color(0xFF07404C))));
              }
              if (snapshot.hasError) {
                return SizedBox(height: 600, child: Center(child: Text('Error loading product details: ${snapshot.error}')));
              }
              final p = snapshot.data;
              if (p == null) return const SizedBox(height: 600, child: Center(child: Text('Product not found.')));

          final images = p.imageUrls.isNotEmpty ? p.imageUrls : [p.imageUrl];
          if (_selectedImageIndex >= images.length) _selectedImageIndex = 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildTopHeader(context, p),
                const SizedBox(height: 24),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Gallery Column
                              Expanded(flex: 5, child: _buildGallery(images, p)),
                              const SizedBox(width: 64),
                              // 2. Info Column
                              Expanded(flex: 5, child: _buildProductInfo(context, p)),
                            ],
                          ),
                          const SizedBox(height: 80),
                          _buildBundledOffer(p),
                          const SizedBox(height: 80),
                          _buildDetailsTabs(p),
                          const SizedBox(height: 100),
                          _buildRecommendationSection(productController, "Similar & Related Devotional Items", p.categoryId),
                          const SizedBox(height: 60),
                          _buildRecommendationSection(productController, "More from ${p.categoryId}", p.categoryId, limit: 4),
                          const SizedBox(height: 100),
                          _buildBrowsingHistory(productController),
                          const SizedBox(height: 100),
                        ],
                      ),
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

  Widget _buildTopHeader(BuildContext context, ProductModel p) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            children: [
              Text('Sacred Catalog', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
              Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
              Text(p.categoryId, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
              Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
              Text(p.name, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)),
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
              decoration: BoxDecoration(
                color: const Color(0xFFFAF8F4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(imageUrl: images[_selectedImageIndex], fit: BoxFit.cover),
              ),
            ),
            if (p.isFeatured)
              Positioned(
                top: 24, left: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                  child: const Text('BESTSELLER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
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
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
                child: Row(children: [const Icon(Icons.verified_outlined, size: 14, color: Colors.green), const SizedBox(width: 8), Text('100% Genuine Atelier Stock', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade800))]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: images.asMap().entries.map((e) => GestureDetector(
            onTap: () => setState(() => _selectedImageIndex = e.key),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 120, height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _selectedImageIndex == e.key ? primaryTeal : Colors.grey.shade200, width: 2),
              ),
              child: ClipRRect(borderRadius: BorderRadius.circular(6), child: CachedNetworkImage(imageUrl: e.value, fit: BoxFit.cover)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 40),
        _buildVedicChantingBox(),
      ],
    );
  }

  Widget _buildVedicChantingBox() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: templeGold, size: 18),
              const SizedBox(width: 12),
              const Text('SACRED VEDIC CHANTING & MANTRA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFFC89A5B))),
              const Spacer(),
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.copy, size: 14), label: const Text('Copy', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {}, 
                icon: const Icon(Icons.volume_up, size: 14), 
                label: const Text('Listen 432Hz Aura', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF07404C), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('ॐ नमो भगवते वासुदेवाय ॥', style: GoogleFonts.notoSansDevanagari(fontSize: 28, fontWeight: FontWeight.bold, color: primaryTeal)),
          const SizedBox(height: 8),
          const Text('"Om Namo Bhagavate Vasudevaya"', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey)),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              children: [
                const TextSpan(text: 'Spiritual Significance: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                const TextSpan(text: 'Salutations to the Divine Supreme Being who resides within all hearts.'),
              ]
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context, ProductModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: primaryTeal.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
              child: Text(p.categoryId.toUpperCase(), style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
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
        const SizedBox(height: 24),
        Text(p.name, style: GoogleFonts.cormorantGaramond(fontSize: 48, fontWeight: FontWeight.w600, color: primaryTeal, height: 1.1)),
        const SizedBox(height: 12),
        Text(p.shortSummary, style: TextStyle(color: Colors.grey.shade500, fontSize: 16, height: 1.5)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFFAF8F4), borderRadius: BorderRadius.circular(12), border: Border.all(color: templeGold.withOpacity(0.1))),
          child: Row(
            children: [
              Icon(Icons.auto_fix_high, color: templeGold, size: 20),
              const SizedBox(width: 16),
              const Expanded(child: Text('Sanctified & Consecrated: Consecrated with holy Chandan & Rakshasutra blessing.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
          children: [
            Text('₹${p.price.toInt()}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
            const SizedBox(width: 16),
            if (p.comparePrice != null) ...[
              Text('MRP ₹${p.comparePrice!.toInt()}', style: const TextStyle(fontSize: 20, color: Colors.grey, decoration: TextDecoration.lineThrough)),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFF8B4513).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text('Save ₹${(p.comparePrice! - p.price).toInt()} (${p.discountPercentage}% OFF)', style: const TextStyle(color: Color(0xFF8B4513), fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFE6F7F0), borderRadius: BorderRadius.circular(30)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
              const SizedBox(width: 12),
              const Text('In Sanctified Stock — Auspicious 24-hr temple dispatch', style: TextStyle(color: Color(0xFF065F46), fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text('Selected Option / Finish:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 16),
        Row(
          children: [
            _variantCircle(const Color(0xFFE8E8E8), _selectedFinishIndex == 0, () => setState(() => _selectedFinishIndex = 0)),
            _variantCircle(const Color(0xFFD4810D), _selectedFinishIndex == 1, () => setState(() => _selectedFinishIndex = 1)),
            _variantCircle(const Color(0xFFE64A19), _selectedFinishIndex == 2, () => setState(() => _selectedFinishIndex = 2)),
            const SizedBox(width: 16),
            Text(_availableFinishes[_selectedFinishIndex], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
            const Spacer(),
            TextButton.icon(onPressed: () {}, icon: const Icon(Icons.straighten, size: 14), label: const Text('Deity & Altar Sizing Guide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Select Size / Edition:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 16),
        Row(
          children: [
            _sizeBtn(_availableSizes[0], _selectedSizeIndex == 0, () => setState(() => _selectedSizeIndex = 0)),
            const SizedBox(width: 16),
            _sizeBtn(_availableSizes[1], _selectedSizeIndex == 1, () => setState(() => _selectedSizeIndex = 1)),
          ],
        ),
        const SizedBox(height: 40),
        _buildComplimentaryItem('Complimentary Gangajal, Chandan Tika & Raksha Sutra Kit (Free)', 'Includes certified holy water from Haridwar and energized temple red thread.', _includeGangaJal, (v) => setState(() => _includeGangaJal = v!)),
        _buildComplimentaryItem('Auspicious Red-Saffron Gift Wrap & Devotional Card (₹49)', '', _includeGiftWrap, (v) => setState(() => _includeGiftWrap = v!)),
        const SizedBox(height: 48),
        Row(
          children: [
            _qtySelector(),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<CartController>(context, listen: false).addToCart(p, _quantity);
                  Scaffold.of(context).openEndDrawer();
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, padding: const EdgeInsets.symmetric(vertical: 25), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Text('ADD TO BAG • ₹${(p.price * _quantity).toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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
            backgroundColor: const Color(0xFFFF5722),
            padding: const EdgeInsets.symmetric(vertical: 25),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(double.infinity, 60),
          ),
          child: const Text('⚡ INSTANT SACRED CHECKOUT (COD / ONLINE)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
        ),
        const SizedBox(height: 16),
        _buildWhatsAppBtn(),
        const SizedBox(height: 48),
        _buildDeliveryChecker(),
        const SizedBox(height: 48),
        _buildTrustFeatures(),
      ],
    );
  }

  Widget _buildComplimentaryItem(String title, String subtitle, bool value, Function(bool?) onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: value ? primaryTeal : Colors.grey.shade200)),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged, activeColor: primaryTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
    decoration: BoxDecoration(color: const Color(0xFF25D366), borderRadius: BorderRadius.circular(8)),
    child: InkWell(
      onTap: () {},
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.chat_bubble, color: Colors.white, size: 20), SizedBox(width: 12), Text('Order / Inquire via WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
    ),
  );

  Widget _buildDeliveryChecker() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: const Color(0xFFFDFBF7), borderRadius: BorderRadius.circular(12), border: Border.all(color: templeGold.withOpacity(0.1))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(Icons.location_on_outlined, size: 16, color: templeGold), const SizedBox(width: 10), const Text('Delivery & Payment Availability', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), const Spacer(), const Text('Cash on Delivery Available', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: TextField(decoration: InputDecoration(hintText: 'Enter Pincode', fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18)), child: const Text('Check', style: TextStyle(color: Colors.white))),
          ],
        ),
        const SizedBox(height: 24),
        _deliveryInfoItem(Icons.local_shipping_outlined, 'FREE Standard Delivery by Wed, Sep 2', 'Order in the next 4 hrs 15 mins for sanctum dispatch today.'),
        const SizedBox(height: 16),
        _deliveryInfoItem(Icons.bolt, 'Express 24-hr Air Courier available at checkout', 'Delivers by Mon, Aug 31 to metro locations.'),
        const SizedBox(height: 16),
        _deliveryInfoItem(Icons.history, '7-Day Replacement & Zero-Breakage Transit Guarantee', 'If deity frame or sanctified item arrives damaged, we replace it instantly with consecrated batch.'),
      ],
    ),
  );

  Widget _deliveryInfoItem(IconData icon, String title, String sub) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: primaryTeal),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey))])),
    ],
  );

  Widget _buildTrustFeatures() => Wrap(
    spacing: 32, runSpacing: 24,
    children: [
      _trustIconItem(Icons.lock_outline, '100% Safe & Secure Payment Options', '256-Bit SSL Encrypted'),
      _trustIconItem(Icons.workspace_premium_outlined, '100% Vedic Pure', 'Natural wood, brass & silk'),
      _trustIconItem(Icons.inventory_2_outlined, 'Safe Sacred Transit', 'Zero breakage guarantee'),
      _trustIconItem(Icons.temple_hindu_outlined, 'Holy Dham Heritage', 'Direct artisan seva'),
    ],
  );

  Widget _trustIconItem(IconData icon, String title, String sub) => SizedBox(
    width: 250,
    child: Row(
      children: [
        Icon(icon, size: 24, color: primaryTeal.withOpacity(0.5)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey))])),
      ],
    ),
  );

  Widget _buildBundledOffer(ProductModel p) => Container(
    padding: const EdgeInsets.all(48),
    decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
    child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_awesome, color: templeGold, size: 20), const SizedBox(width: 12), const Text('Frequently Blessed Together — Save 10% on Complete Sacred Set', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _bundleItem(p.imageUrl, p.name, p.price),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Icon(Icons.add, color: Colors.grey)),
            _bundleItem(p.imageUrl, "Mobile Keychain", 119),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Icon(Icons.add, color: Colors.grey)),
            _bundleItem(p.imageUrl, "Dada's Photo + Radha Krishna", 149),
            const SizedBox(width: 64),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bundle Total (10% Off):', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                const Row(children: [Text('₹330.3', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), SizedBox(width: 12), Text('₹367', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey))]),
                const SizedBox(height: 24),
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined, size: 16), label: const Text('ADD COMPLETE SET TO BAG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20))),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  Widget _bundleItem(String img, String name, double price) => Row(
    children: [
      Checkbox(value: true, onChanged: (v) {}, activeColor: primaryTeal),
      const SizedBox(width: 12),
      ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: img, width: 60, height: 60, fit: BoxFit.cover)),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text('₹${price.toInt()}', style: const TextStyle(fontSize: 12, color: Colors.grey))]),
    ],
  );

  Widget _buildDetailsTabs(ProductModel p) => DefaultTabController(
    length: 5,
    child: Column(
      children: [
        TabBar(
          isScrollable: true, tabAlignment: TabAlignment.center,
          indicatorColor: primaryTeal, labelColor: primaryTeal, unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [Tab(text: 'Vedic Significance & Details'), Tab(text: 'Specifications & Dimensions'), Tab(text: 'Sacred Care & Purity'), Tab(text: 'Devotee Reviews (1)'), Tab(text: 'FAQs & Guidance')],
        ),
        const SizedBox(height: 60),
        SizedBox(
          height: 400,
          child: TabBarView(
            children: [
              _buildTabContent("Crafted with love and precision, ${p.name} features high-resolution sacred darshan sealed inside optical-grade, shatter-proof acrylic. Designed for car keys, house keys, and bags, ensuring continuous divine protection and auspiciousness in your daily journeys.", p.highlights),
              const Center(child: Text("Dimensions: 2 x 1.5 inches\nWeight: 15g\nMaterial: Premium Acrylic")),
              const Center(child: Text("Handle with reverence. Clean with a soft, dry cloth.")),
              const Center(child: Text("A very auspicious item! - Devotee from Gujarat")),
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
      Text(desc, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6)),
      const SizedBox(height: 40),
      const Text('DEVOTIONAL HIGHLIGHTS & ARTISANAL MERITS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
      const SizedBox(height: 24),
      GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 8, crossAxisSpacing: 32, mainAxisSpacing: 16),
        itemCount: highlights.length.clamp(0, 6),
        itemBuilder: (c, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFFFAF8F4), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [Icon(Icons.check, size: 14, color: primaryTeal), const SizedBox(width: 12), Expanded(child: Text(highlights[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)))]),
        ),
      ),
      const SizedBox(height: 32),
      Container(
        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [Icon(Icons.info_outline, size: 16, color: primaryTeal), const SizedBox(width: 12), const Text('Insured Devotional Transit: Dispatched within 24 hours in velvet devotional pouch.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
      ),
    ],
  );

  Widget _buildRecommendationSection(ProductController ctrl, String title, String catId, {int limit = 8}) {
    final products = ctrl.allProducts.where((p) => p.categoryId == catId).take(limit).toList();
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold)), TextButton(onPressed: () {}, child: const Text('EXPLORE FULL COLLECTION →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 40),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.72, crossAxisSpacing: 24, mainAxisSpacing: 40),
          itemCount: products.length,
          itemBuilder: (context, index) => ProductCard(product: products[index]),
        ),
      ],
    );
  }

  Widget _buildBrowsingHistory(ProductController ctrl) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [Icon(Icons.history, size: 20, color: templeGold), const SizedBox(width: 12), const Text('YOUR BROWSING HISTORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)), const Spacer(), TextButton(onPressed: () {}, child: const Text('Clear History', style: TextStyle(fontSize: 11, color: Colors.grey)))]),
      const SizedBox(height: 16),
      const Text('Recently Viewed Sacred Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 40),
      if (ctrl.allProducts.isNotEmpty) ProductCard(product: ctrl.allProducts.last),
    ],
  );

  Widget _circleIcon(IconData icon) => Container(
    padding: const EdgeInsets.all(10),
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
    child: Icon(icon, size: 18, color: Colors.black87),
  );

  Widget _variantCircle(Color color, bool selected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? primaryTeal : Colors.transparent, width: 2)),
      child: Container(width: 24, height: 24, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
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
    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
    child: Row(
      children: [
        IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove, size: 18)),
        Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add, size: 18)),
      ],
    ),
  );
}
