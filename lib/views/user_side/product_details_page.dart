import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/review_controller.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart';
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
  bool _includeGangajalKit = true;
  bool _includeGiftWrap = false;
  
  final Color primaryTeal = const Color(0xFF07404C);
  final Color templeGold = const Color(0xFFC89A5B);
  
  Stream<ProductModel?>? _productStream;
  Stream<List<ReviewModel>>? _reviewsStream;
  String? _lastProductId;

  final TextEditingController _pincodeCtrl = TextEditingController();
  bool _isPincodeValid = false;
  String? _pincodeError;
  bool _isReviewFormOpen = false;

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
        final productController = Provider.of<ProductController>(context, listen: false);
        final reviewController = Provider.of<ReviewController>(context, listen: false);
        _productStream = productController.getProductDetails(productId);
        _reviewsStream = reviewController.getProductReviews(productId);
      }
    } catch (e) {}
  }

  void _validatePincode(String value) {
    setState(() {
      _isPincodeValid = value.trim().length == 6;
      if (_isPincodeValid) _pincodeError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final productController = Provider.of<ProductController>(context, listen: false);

    return StreamBuilder<ProductModel?>(
      stream: _productStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Oops! Product not found or failed to load.', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF07404C))));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('This sacred item is no longer available in the store.', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Return to Store')),
                ],
              ),
            ),
          );
        }

        final p = snapshot.data!;
        final List<String> images = p.imageUrls.isNotEmpty 
            ? p.imageUrls.where((url) => url.isNotEmpty).toList() 
            : (p.imageUrl.isNotEmpty ? [p.imageUrl] : <String>['https://via.placeholder.com/600']);

        List<Widget> contentSlivers = [
          SliverToBoxAdapter(child: _buildTopHeader(p)),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 900;
                      return Column(
                        children: [
                          if (isMobile) ...[
                            _buildGallery(images, p),
                            const SizedBox(height: 32),
                            _buildProductInfo(p),
                          ] else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: _buildGallery(images, p)),
                                const SizedBox(width: 48),
                                Expanded(flex: 5, child: _buildProductInfo(p)),
                              ],
                            ),
                          const SizedBox(height: 32),
                          _buildFrequentlyBlessedTogether(p, productController),
                          const SizedBox(height: 32),
                          _buildDetailsTabs(p),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: _buildRecommendationTitle("Similar Devotional Keychains"),
            ),
          ),
          _buildSimilarProductsGrid(productController, 'keychain'),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ];

        return ProductCartLayout(
          controller: homeController,
          slivers: contentSlivers,
          child: const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildTopHeader(ProductModel p) {
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            children: [
              Text('Sacred Catalog', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right, size: 12, color: Colors.grey.shade400),
              Text(p.categoryId.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right, size: 12, color: Colors.grey.shade400),
              Text(p.localizedName(lang), style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold)),
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
            GestureDetector(
              onTap: () => _showFullScreenImage(context, images[_selectedImageIndex]),
              child: Container(
                height: 550,
                width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(8)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: images[_selectedImageIndex], 
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.image_outlined, size: 100, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20, left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF07404C), borderRadius: BorderRadius.circular(30)),
                child: const Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
            Positioned(
              bottom: 20, right: 20,
              child: _circleIcon(Icons.zoom_in, onTap: () => _showFullScreenImage(context, images[_selectedImageIndex])),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: images.asMap().entries.map((e) => GestureDetector(
            onTap: () => setState(() => _selectedImageIndex = e.key),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 70, height: 70,
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
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade100)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_outlined, size: 12, color: Colors.green),
              const SizedBox(width: 8),
              Text('100% Genuine Atelier Stock', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain)),
            Positioned(top: 40, right: 40, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context))),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(ProductModel p) {
    final auth = Provider.of<AuthController>(context, listen: false);
    final cart = Provider.of<CartController>(context, listen: false);
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    final isOutOfStock = p.stock <= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.categoryId.toUpperCase(), style: TextStyle(color: templeGold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Text(p.localizedName(lang), style: GoogleFonts.cormorantGaramond(fontSize: 36, fontWeight: FontWeight.w700, color: primaryTeal)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < p.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  )),
                ),
                const SizedBox(height: 4),
                Text('${p.rating} (${p.reviewCount} reviews)', style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(p.localizedShortSummary(lang), style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.5)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFFDFBF7), borderRadius: BorderRadius.circular(6), border: Border.all(color: templeGold.withOpacity(0.1))),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: templeGold, size: 14),
              const SizedBox(width: 10),
              const Expanded(child: Text('Sanctified & Consecrated: Energized with holy temple mantras.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2B2B2B)))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
          children: [
            Text('₹${p.price.toInt()}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primaryTeal)),
            const SizedBox(width: 10),
            if (p.comparePrice != null) ...[
              Text('₹${p.comparePrice!.toInt()}', style: const TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF8B4513).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text('Save ₹${(p.comparePrice! - p.price).toInt()} (${p.discountPercentage}% OFF)', style: const TextStyle(color: Color(0xFF8B4513), fontWeight: FontWeight.w900, fontSize: 10)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: isOutOfStock ? Colors.red.shade50 : const Color(0xFFE6F7F0), borderRadius: BorderRadius.circular(4)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 5, height: 5, decoration: BoxDecoration(color: isOutOfStock ? Colors.red : const Color(0xFF10B981), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(isOutOfStock ? 'OUT OF STOCK — Sacred item currently unavailable' : 'In Sanctified Stock — Auspicious 24-hr temple dispatch', style: TextStyle(color: isOutOfStock ? Colors.red : const Color(0xFF065F46), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Attach divine positivity directly to your smartphone. Durable braided sacred loop with lightweight acrylic charm featuring Dada and Radhe Radhe blessing.', style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)),
        const SizedBox(height: 24),
        
        Row(
          children: [
            _qtySelector(),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: !isOutOfStock ? () {
                  if (!_isPincodeValid) {
                    setState(() => _pincodeError = 'Please enter a pincode');
                    return;
                  }
                  if (auth.isAuthenticated) {
                    cart.addToCart(p, _quantity);
                    Scaffold.of(context).openEndDrawer();
                  } else {
                    auth.toggleLoginPortal(true);
                  }
                } : null,
                style: ElevatedButton.styleFrom(backgroundColor: !isOutOfStock ? primaryTeal : Colors.grey.shade400, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                child: Text(!isOutOfStock ? 'ADD TO BAG • ₹${(p.price * _quantity).toInt()}' : 'OUT OF STOCK', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 12),
            _circleIcon(Icons.favorite_border, onTap: () {
               if (auth.isAuthenticated) {
                 Provider.of<ProductController>(context, listen: false).toggleLike(p.id);
               } else {
                 auth.toggleLoginPortal(true);
               }
            }),
            const SizedBox(width: 8),
            _circleIcon(Icons.share_outlined, onTap: () {
              final lang = Provider.of<LanguageController>(context, listen: false).locale.languageCode;
              final String url = 'https://dada-store.web.app/product_details?id=${p.id}';
              Share.share('Check out this sacred item: ${p.localizedName(lang)}\n$url');
            }),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: !isOutOfStock ? () {
            if (!_isPincodeValid) {
              setState(() => _pincodeError = 'Please enter a pincode');
              return;
            }
            if (auth.isAuthenticated) {
              cart.addToCart(p, _quantity);
              Navigator.pushNamed(context, '/checkout');
            } else {
              auth.toggleLoginPortal(true);
            }
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: !isOutOfStock ? templeGold : Colors.grey.shade300, 
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Text(!isOutOfStock ? '⚡ INSTANT SACRED CHECKOUT (COD / ONLINE)' : 'CURRENTLY UNAVAILABLE', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12, letterSpacing: 1)),
        ),
        const SizedBox(height: 12),
        _buildWhatsAppBtn(p, lang),
        const SizedBox(height: 24),
        _buildDeliveryChecker(),
        const SizedBox(height: 32),
        _buildTrustFeatures(),
      ],
    );
  }

  Widget _buildWhatsAppBtn(ProductModel p, String lang) => Container(
    height: 55,
    width: double.infinity,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF25D366))),
    child: InkWell(
      onTap: () async {
        const phone = "919876543210";
        final message = "Pranam! I would like to order: ${p.localizedName(lang)}\nQuantity: $_quantity\nPrice: ₹${p.price.toInt()}\nProduct Link: https://dada-store.web.app/product_details?id=${p.id}";
        final url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      },
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366), size: 16), SizedBox(width: 10), Text('Order / Inquire via WhatsApp', style: TextStyle(color: Color(0xFF25D366), fontWeight: FontWeight.bold, fontSize: 12))]),
    ),
  );

  Widget _buildDeliveryChecker() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFFFDFBF7), borderRadius: BorderRadius.circular(8), border: Border.all(color: templeGold.withOpacity(0.1))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(Icons.location_on_outlined, size: 14, color: templeGold), const SizedBox(width: 8), const Text('Delivery & Payment Availability', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), const Spacer(), const Text('Cash on Delivery Available', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _pincodeCtrl,
                onChanged: _validatePincode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Enter 6-digit Pincode', 
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  fillColor: Colors.white, 
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: _pincodeError != null ? Colors.red : Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: _pincodeError != null ? Colors.red : Colors.grey.shade200)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(onPressed: () => _validatePincode(_pincodeCtrl.text), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF07404C), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), child: const Text('Check', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          ],
        ),
        if (_pincodeError != null)
           Padding(
             padding: const EdgeInsets.only(top: 6, left: 4),
             child: Text(_pincodeError!, style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
           ),
        const SizedBox(height: 16),
        _deliveryInfoItem(Icons.local_shipping_outlined, 'FREE Standard Delivery', 'Ordered by 4 PM for same-day sanctum dispatch.'),
        const SizedBox(height: 12),
        _deliveryInfoItem(Icons.replay_outlined, '7-Day Replacement Guarantee', 'We replace damaged deity frames instantly.'),
      ],
    ),
  );

  Widget _deliveryInfoItem(IconData icon, String title, String sub) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 14, color: primaryTeal.withOpacity(0.6)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(sub, style: const TextStyle(fontSize: 9, color: Colors.grey))])),
    ],
  );

  Widget _buildTrustFeatures() => Column(
    children: [
       Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade100), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Row(children: [Icon(Icons.lock_outline, size: 12, color: primaryTeal), const SizedBox(width: 10), const Text('100% Safe & Secure Payment Options', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), const Spacer(), const Text('256-Bit SSL Encrypted', style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 _paymentMethodIcon(Icons.handshake_outlined, 'COD'),
                 _paymentMethodIcon(Icons.qr_code_scanner, 'UPI'),
                 _paymentMethodIcon(Icons.credit_card, 'Cards'),
                 _paymentMethodIcon(Icons.account_balance, 'Net Banking'),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 16, runSpacing: 12,
        children: [
          _trustIconItem(Icons.eco_outlined, '100% Vedic Pure', 'Natural materials'),
          _trustIconItem(Icons.auto_awesome, 'Abhimantrit', 'Mantra energized'),
        ],
      ),
    ],
  );

  Widget _paymentMethodIcon(IconData icon, String label) => Row(children: [Icon(icon, size: 12, color: Colors.grey), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold))]);

  Widget _trustIconItem(IconData icon, String title, String sub) => Container(
    width: 180,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade100), borderRadius: BorderRadius.circular(8)),
    child: Row(
      children: [
        Icon(icon, size: 18, color: templeGold.withOpacity(0.6)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(fontSize: 9, color: Colors.grey))])),
      ],
    ),
  );

  Widget _buildFrequentlyBlessedTogether(ProductModel p, ProductController ctrl) {
    final others = ctrl.allProducts.where((item) => item.id != p.id).take(2).toList();
    if (others.length < 2) return const SizedBox.shrink();

    double total = p.price + others[0].price + others[1].price;
    double discounted = total * 0.9;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: templeGold.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: templeGold, size: 18),
              const SizedBox(width: 12),
              Text("Frequently Blessed Together — Save 10% on Complete Sacred Set", style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold, color: primaryTeal)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _bundleItem(p, true),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.add, size: 14, color: Colors.grey)),
                      _bundleItem(others[0], true),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.add, size: 14, color: Colors.grey)),
                      _bundleItem(others[1], true),
                    ],
                  ),
                ),
              ),
              Container(height: 100, width: 1, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 32)),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Bundle Total (10% Off):", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("₹${discounted.toStringAsFixed(1)}", style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.w900, color: primaryTeal)),
                        const SizedBox(width: 10),
                        Text("₹${total.toInt()}", style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                         final cart = Provider.of<CartController>(context, listen: false);
                         cart.addToCart(p, 1);
                         cart.addToCart(others[0], 1);
                         cart.addToCart(others[1], 1);
                         Scaffold.of(context).openEndDrawer();
                      },
                      icon: const Icon(Icons.shopping_bag_outlined, size: 14),
                      label: const Text("ADD COMPLETE SET TO BAG", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bundleItem(ProductModel item, bool selected) {
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    return Container(
      width: 190,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(imageUrl: item.imageUrl, width: 45, height: 45, fit: BoxFit.cover, errorWidget: (c,u,e) => const Icon(Icons.image_outlined, size: 24)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.localizedName(lang), 
                  style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black87),
                  maxLines: 1, overflow: TextOverflow.ellipsis
                ),
                const SizedBox(height: 2),
                Text(
                  "₹${item.price.toInt()}", 
                  style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w800, fontSize: 10, color: primaryTeal),
                ),
              ],
            ),
          ),
          Checkbox(
            value: true, 
            onChanged: (v) {}, 
            activeColor: primaryTeal, 
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTabs(ProductModel p) {
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    return DefaultTabController(
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            indicatorColor: primaryTeal, labelColor: primaryTeal, unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              const Tab(text: 'Vedic Significance & Details'),
              const Tab(text: 'Specifications & Dimensions'),
              const Tab(text: 'Sacred Care & Purity'),
              Tab(text: 'Devotee Reviews (${p.reviewCount})'),
              const Tab(text: 'FAQs & Guidance')
            ],
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 300, maxHeight: 1000),
            child: SizedBox(
              height: 500,
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("About this Sacred Offering:", style: TextStyle(fontWeight: FontWeight.bold, color: primaryTeal, fontSize: 14)),
                        const SizedBox(height: 12),
                        Text(p.localizedDescription(lang), style: const TextStyle(height: 1.6, color: Colors.black87, fontSize: 13)),
                        const SizedBox(height: 20),
                        Text("Blessings & Significance:", style: TextStyle(fontWeight: FontWeight.bold, color: primaryTeal, fontSize: 13)),
                        const SizedBox(height: 8),
                        ...p.localizedHighlights(lang).map((h) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text("• $h", style: const TextStyle(height: 1.6, color: Colors.black54, fontSize: 12)),
                        )),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _specRow("Material", "Premium Consecrated Material / Sacred Wood"),
                        _specRow("SKU", "DADA-${p.id.substring(0, 5).toUpperCase()}"),
                        _specRow("Category", p.categoryId),
                        _specRow("Origin", "Authentic Ashram Atelier"),
                        _specRow("Weight", "Approx 50g - 150g"),
                      ],
                    ),
                  ),
                  const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Purity Standards:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 14)),
                        SizedBox(height: 12),
                        Text("• This item should be handled with spiritual reverence.\n• Avoid placing on the floor or in unclean areas.\n• Clean only with a dry, pure cotton cloth to maintain its consecrated energy.", style: TextStyle(height: 1.6, color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  _buildReviewsTab(p),
                  const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Q: Is this item already energized?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text("A: Yes, all our offerings are sanctified through a special Puja Seva before dispatch.", style: TextStyle(color: Colors.black54, fontSize: 12)),
                        SizedBox(height: 16),
                        Text("Q: Can I gift this to someone?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text("A: Absolutely. Giving a sacred offering is considered an act of great merit (Punya).", style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
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

  Widget _specRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 12))),
      ],
    ),
  );

  Widget _buildReviewsTab(ProductModel p) {
    final auth = Provider.of<AuthController>(context);
    
    if (_reviewsStream == null) {
       return const Center(child: CircularProgressIndicator(color: Color(0xFF07404C)));
    }

    return StreamBuilder<List<ReviewModel>>(
      stream: _reviewsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.grey, size: 48),
                const SizedBox(height: 16),
                Text("Unable to load reviews at this time.", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () => setState(() {}), child: const Text("Retry")),
              ],
            ),
          ));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(100),
            child: CircularProgressIndicator(color: Color(0xFF07404C)),
          ));
        }

        final reviews = snapshot.data ?? [];
        
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
               _buildReviewHeader(p),
               const SizedBox(height: 24),
               if (_isReviewFormOpen) ...[
                 _buildReviewForm(p.id, p.name, auth),
                 const SizedBox(height: 24),
               ],
               if (reviews.isEmpty)
                 const Center(child: Padding(
                   padding: EdgeInsets.all(40),
                   child: Text("No reviews yet. Be the first devotee to share your experience!"),
                 ))
               else
                 ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    separatorBuilder: (c, i) => const Divider(),
                    itemBuilder: (c, i) => _buildReviewItem(reviews[i]),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewHeader(ProductModel p) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.circular(16), 
      border: Border.all(color: Colors.grey.shade200)
    ),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              p.rating.toString(), 
              style: GoogleFonts.cormorantGaramond(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87)
            ),
            Row(children: List.generate(5, (i) => Icon(Icons.star, color: Colors.amber, size: 14))),
            const SizedBox(height: 6),
            Text(
              'Based on ${p.reviewCount} devotee reviews', 
              style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600)
            ),
          ],
        ),
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               _reviewSummaryRow(Icons.check_circle_outline, "100% Verified Devotee & Altar Reviews"),
               const SizedBox(height: 8),
               _reviewSummaryRow(Icons.verified_outlined, "Inspected for Vedic Authenticity & Material Integrity"),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => setState(() => _isReviewFormOpen = !_isReviewFormOpen),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF071C21), 
            foregroundColor: Colors.white, 
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
          ),
          child: Text(
            _isReviewFormOpen ? "CLOSE FORM" : "WRITE REVIEW", 
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)
          ),
        ),
      ],
    ),
  );

  Widget _reviewSummaryRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 14, color: Colors.green.shade600), 
      const SizedBox(width: 10), 
      Text(
        text, 
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)
      )
    ]
  );

  final _reviewNameCtrl = TextEditingController();
  final _reviewTitleCtrl = TextEditingController();
  final _reviewTextCtrl = TextEditingController();
  double _userRating = 5.0;

  Widget _buildReviewForm(String productId, String productName, AuthController auth) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Submit Your Devotional Review for $productName", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text("Rating: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (i) => IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    i < _userRating ? Icons.star : Icons.star_border, 
                    color: Colors.amber, 
                    size: 20
                  ),
                  onPressed: () => setState(() => _userRating = i + 1.0),
                )),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _reviewField("Your Full Name / Devotee Name *", "e.g. Radhika Sharma", _reviewNameCtrl)),
              const SizedBox(width: 20),
              Expanded(child: _reviewField("Review Title *", "e.g. Pure vibration and flawless finish", _reviewTitleCtrl)),
            ],
          ),
          const SizedBox(height: 20),
          _reviewField(
            "Your Detailed Experience / Feedback *", 
            "Share your feedback on the texture, finish, pooja experience, packaging...", 
            _reviewTextCtrl, 
            maxLines: 4
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              if (_reviewTextCtrl.text.isEmpty || !auth.isAuthenticated) {
                if (!auth.isAuthenticated) auth.toggleLoginPortal(true);
                return;
              }
              final review = ReviewModel(
                id: '', 
                productId: productId, 
                productName: productName,
                userId: auth.user!.uid, 
                userName: _reviewNameCtrl.text.isEmpty ? (auth.userModel?.name ?? 'Devotee') : _reviewNameCtrl.text,
                userPhone: auth.userModel?.phone ?? '', 
                rating: _userRating,
                comment: "[${_reviewTitleCtrl.text}] ${_reviewTextCtrl.text}", 
                createdAt: DateTime.now(),
              );
              await Provider.of<ReviewController>(context, listen: false).addReview(review);
              _reviewTextCtrl.clear(); 
              _reviewNameCtrl.clear(); 
              _reviewTitleCtrl.clear();
              setState(() {
                _userRating = 5.0;
                _isReviewFormOpen = false;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Testimonial published with blessings!'), backgroundColor: Colors.green)
                );
              }
            },
            icon: const Icon(Icons.send_rounded, size: 14),
            label: const Text(
              "PUBLISH REVIEW", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 11)
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF071C21), 
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewField(String label, String hint, TextEditingController ctrl, {int maxLines = 1}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
      ),
    ],
  );

  Widget _buildReviewItem(ReviewModel review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), const Spacer(), Text(review.createdAt.toString().split(' ')[0], style: const TextStyle(color: Colors.grey, fontSize: 10))]),
          const SizedBox(height: 4),
          Row(children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 12))),
          const SizedBox(height: 8),
          Text(review.comment, style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildRecommendationTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFF8B4513))),
        TextButton(onPressed: () {}, child: const Text('EXPLORE FULL COLLECTION →', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87))),
      ],
    );
  }

  Widget _buildSimilarProductsGrid(ProductController ctrl, String catId) {
    final products = ctrl.allProducts.where((p) => p.categoryId.toLowerCase().contains('keychain')).take(4).toList();
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.72, crossAxisSpacing: 20, mainAxisSpacing: 20),
        delegate: SliverChildBuilderDelegate((c, i) => ProductCard(product: products[i]), childCount: products.length),
      ),
    );
  }

  Widget _circleIcon(IconData icon, {VoidCallback? onTap}) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
      child: Icon(icon, size: 18, color: primaryTeal),
    ),
  );

  Widget _qtySelector() => Container(
    height: 55,
    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)),
    child: Row(
      children: [
        IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove, size: 14)),
        Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add, size: 14)),
      ],
    ),
  );
}
