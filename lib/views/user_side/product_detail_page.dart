import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart';
import '../../utils/app_typography.dart';
import 'components/product_card.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';

class ProductDetailPage extends StatefulWidget {
  final String slug;
  const ProductDetailPage({super.key, required this.slug});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  static const Color _teal     = Color(0xFF0F4C5C);
  static const Color _darkTeal = Color(0xFF07303D);
  static const Color _gold     = Color(0xFFC19A6B);
  static const Color _slate    = Color(0xFF4A5568);
  static const Color _beige    = Color(0xFFF9F3EA);

  int _selectedImageIndex = 0;
  int _quantity = 1;
  String? _selectedFormat;
  String? _selectedSize;
  final Set<String> _selectedAddOns = {};
  String _pincode = '';
  int _selectedTab = 0;
  final List<bool> _expandedFaqs = [];
  // bundle section: tracks which slugs are checked; null = not yet initialised
  Set<String>? _bundleChecked;

  void _prevImage(int total) =>
      setState(() => _selectedImageIndex = (_selectedImageIndex - 1 + total) % total);
  void _nextImage(int total) =>
      setState(() => _selectedImageIndex = (_selectedImageIndex + 1) % total);

  @override
  Widget build(BuildContext context) {
    final homeCtrl    = Provider.of<HomePageController>(context);
    final productCtrl = Provider.of<ProductController>(context);
    final product     = productCtrl.getProductBySlug(widget.slug);
    final isMobile    = MediaQuery.of(context).size.width < 900;

    return UserPageLayout(
      controller: homeCtrl,
      child: Column(
        children: [
          const SizedBox(height: 100),
          if (productCtrl.isLoading)
            const SizedBox(height: 500, child: Center(child: CircularProgressIndicator(color: _teal)))
          else if (product == null)
            _buildNotFound(context)
          else
            _buildPage(context, product, isMobile, homeCtrl),
          UserFooter(controller: homeCtrl),
        ],
      ),
    );
  }

  // ─── NOT FOUND ───────────────────────────────────────────
  Widget _buildNotFound(BuildContext context) {
    return Container(
      height: 600, width: double.infinity, color: Colors.white,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.search_off_outlined, size: 80, color: Colors.grey),
        const SizedBox(height: 24),
        const Text('PRODUCT NOT FOUND',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 16),
        const Text('The product you are looking for does not exist or has been removed.'),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          style: ElevatedButton.styleFrom(backgroundColor: _teal,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
          child: const Text('GO TO HOME'),
        ),
      ]),
    );
  }

  // ─── PAGE LAYOUT ─────────────────────────────────────────
  Widget _buildPage(BuildContext context, Product product, bool isMobile, HomePageController home) {
    final productCtrl = Provider.of<ProductController>(context, listen: false);
    return Container(
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildBreadcrumb(context, product, home, isMobile),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isMobile
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildGallery(product, isMobile: true),
                      const SizedBox(height: 48),
                      _buildProductInfo(product),
                    ])
                  : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 1, child: _buildGallery(product, isMobile: false)),
                      const SizedBox(width: 80),
                      Expanded(flex: 1, child: _buildProductInfo(product)),
                    ]),
            ),
          ),
        ),
        // ─── FULL-WIDTH TABS SECTION ─────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _buildTabsSection(product, productCtrl),
            ),
          ),
        ),
        const SizedBox(height: 48),
        // ─── BUNDLE / CROSS-SELL SECTION ──────────────────────
        if (product.bundleProductSlugs.isNotEmpty && product.bundleDiscountPercent > 0)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: _buildBundleSection(product, productCtrl, isMobile),
              ),
            ),
          ),
        
        const SizedBox(height: 64),
        // ─── RELATED PRODUCTS SECTION ─────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _buildRelatedProducts(product, productCtrl, isMobile),
            ),
          ),
        ),
        
        const SizedBox(height: 80),
      ]),
    );
  }


  // ─── BUNDLE / CROSS-SELL SECTION ─────────────────────────
  Widget _buildBundleSection(Product currentProduct, ProductController ctrl, bool isMobile) {
    // Resolve companion products from slugs
    final companions = currentProduct.bundleProductSlugs
        .map((s) => ctrl.getProductBySlug(s))
        .whereType<Product>()
        .toList();

    if (companions.isEmpty) return const SizedBox(); // still hide if slugs resolve to nothing

    // Build full list: current product first, then companions
    final allItems = <Product>[currentProduct, ...companions];

    // Initialise checkbox state on first render (all checked by default)
    _bundleChecked ??= {for (final p in allItems) p.slug};

    final discountPct = currentProduct.bundleDiscountPercent;

    // Live totals
    double originalTotal = 0;
    double discountedTotal = 0;
    for (final p in allItems) {
      if (_bundleChecked!.contains(p.slug)) {
        final price = p.salePrice ?? p.price ?? 0;
        originalTotal += p.price ?? price;
        discountedTotal += price * (1 - discountPct / 100);
      }
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _beige,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9E4DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── SECTION HEADER ──────────────────────────────────
          Row(children: [
            Icon(Icons.auto_awesome_rounded, color: _gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 17, color: Colors.black87),
                  children: [
                    const TextSpan(text: 'Complete Sacred Set — Save '),
                    TextSpan(
                      text: '${discountPct.toStringAsFixed(0)}%',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                    ),
                    const TextSpan(text: ' when you buy together'),
                  ],
                ),
              ),
            ),
          ]),

          const SizedBox(height: 28),

          // ── BUNDLE ITEMS ROW ────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: allItems.asMap().entries.expand((entry) {
                final idx = entry.key;
                final p = entry.value;
                final isChecked = _bundleChecked!.contains(p.slug);
                final thumb = p.images.isNotEmpty ? p.images.first : '';
                final price = p.salePrice ?? p.price ?? 0;

                final card = Container(
                  width: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isChecked ? Colors.white : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isChecked ? _teal : Colors.grey[300]!,
                      width: isChecked ? 1.5 : 1,
                    ),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Checkbox row
                    Row(children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          if (isChecked) {
                            _bundleChecked!.remove(p.slug);
                          } else {
                            _bundleChecked!.add(p.slug);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: isChecked ? _teal : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: isChecked ? _teal : Colors.grey[400]!),
                          ),
                          child: isChecked
                              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(
                        idx == 0 ? 'This item' : 'Add-on',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      )),
                    ]),
                    const SizedBox(height: 10),
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: thumb.isNotEmpty
                          ? Image.network(thumb, width: 136, height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  width: 136, height: 110, color: Colors.grey[200],
                                  child: const Icon(Icons.image_outlined, color: Colors.grey)))
                          : Container(width: 136, height: 110, color: Colors.grey[200],
                              child: const Icon(Icons.image_outlined, color: Colors.grey)),
                    ),
                    const SizedBox(height: 10),
                    Text(p.title,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.4)),
                    const SizedBox(height: 4),
                    Text('₹${price.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _teal)),
                  ]),
                );

                // Append "+" separator between cards (but not after the last)
                if (idx < allItems.length - 1) {
                  return [
                    card,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Icon(Icons.add_rounded, size: 18, color: Colors.black54),
                        ),
                      ]),
                    ),
                  ];
                }
                return [card];
              }).toList(),
            ),
          ),

          const SizedBox(height: 28),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 20),

          // ── BUNDLE SUMMARY & ACTION ─────────────────────────
          isMobile
              ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  _bundleSummary(originalTotal, discountedTotal, discountPct),
                  const SizedBox(height: 16),
                  _addBundleButton(allItems, ctrl),
                ])
              : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _bundleSummary(originalTotal, discountedTotal, discountPct),
                  const SizedBox(width: 32),
                  _addBundleButton(allItems, ctrl),
                ]),
        ],
      ),
    );
  }

  Widget _bundleSummary(double originalTotal, double discountedTotal, double discountPct) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('Bundle Total (${discountPct.toStringAsFixed(0)}% Off): ',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        Text('₹${discountedTotal.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F4C5C))),
        const SizedBox(width: 10),
        Text('₹${originalTotal.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14, color: Colors.grey[400],
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.grey[400],
            )),
      ]),
      const SizedBox(height: 4),
      Text('You save ₹${(originalTotal - discountedTotal).toStringAsFixed(0)} on this sacred set!',
          style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _addBundleButton(List<Product> allItems, ProductController ctrl) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          final cartCtrl = Provider.of<CartController>(context, listen: false);
          int added = 0;
          for (final p in allItems) {
            if (_bundleChecked != null && _bundleChecked!.contains(p.slug)) {
              cartCtrl.addToCart(p);
              added++;
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$added sacred items added to your cart!'),
            action: SnackBarAction(
                label: 'VIEW CART',
                onPressed: () => Navigator.pushNamed(context, '/cart')),
          ));
        },
        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
        label: const Text('ADD COMPLETE SET TO CART',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // ─── RELATED PRODUCTS SECTION ─────────────────────────
  Widget _buildRelatedProducts(Product currentProduct, ProductController ctrl, bool isMobile) {
    // Basic related products logic: same category, excluding current
    final related = ctrl.allProducts
        .where((p) => p.category == currentProduct.category && p.id != currentProduct.id)
        .take(4)
        .toList();
        
    if (related.isEmpty) return const SizedBox();

    final int crossAxisCount = isMobile ? 1 : (MediaQuery.of(context).size.width > 1200 ? 4 : 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RECOMMENDATIONS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: _teal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Similar & Related ${currentProduct.category} Items',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => Navigator.pushNamed(context, '/products', arguments: currentProduct.category),
              child: Row(
                children: [
                  Text(
                    'Explore Full Collection',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _gold),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: _gold),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: related.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.65,
            crossAxisSpacing: 24,
            mainAxisSpacing: 32,
          ),
          itemBuilder: (context, index) {
            return ProductCard(product: related[index]);
          },
        ),
      ],
    );
  }

  // ─── TABS SECTION ────────────────────────────────────────
  Widget _buildTabsSection(Product product, ProductController productCtrl) {
    return StreamBuilder<List<Review>>(
      stream: productCtrl.getProductReviews(product.id),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? [];

        final tabs = [
          _TabDef(icon: Icons.auto_stories_rounded, label: 'Vedic Significance & Details'),
          _TabDef(icon: Icons.straighten_rounded, label: 'Specifications & Dimensions'),
          _TabDef(icon: Icons.spa_rounded, label: 'Sacred Care & Purity'),
          _TabDef(icon: Icons.star_rounded, label: 'Devotee Reviews (${reviews.length})'),
          _TabDef(icon: Icons.help_outline_rounded, label: 'FAQs & Guidance'),
        ];

        // Ensure FAQ expansion list is properly sized
        if (_expandedFaqs.length != product.faqs.length) {
          _expandedFaqs.clear();
          _expandedFaqs.addAll(List.filled(product.faqs.length, false));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TAB BAR ──────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1.5)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tabs.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final tab = entry.value;
                    final isActive = _selectedTab == idx;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTab = idx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isActive ? _teal : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(tab.icon, size: 16,
                                color: isActive ? _teal : Colors.grey[500]),
                            const SizedBox(width: 8),
                            Text(tab.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                                  color: isActive ? _teal : Colors.grey[500],
                                  letterSpacing: isActive ? 0.2 : 0,
                                )),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ── TAB PANEL ────────────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _beige,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9E4DE)),
              ),
              child: _buildActiveTabContent(product, reviews),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveTabContent(Product product, List<Review> reviews) {
    switch (_selectedTab) {
      case 0: return _buildDetailsTab(product);
      case 1: return _buildSpecsTab(product);
      case 2: return _buildCareTab(product);
      case 3: return _buildReviewsTab(reviews);
      case 4: return _buildFaqsTab(product);
      default: return _buildDetailsTab(product);
    }
  }

  // TAB 1 — Vedic Significance & Details
  Widget _buildDetailsTab(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description paragraph
        if (product.description.isNotEmpty)
          Text(product.description,
              style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.75)),
        if (product.description.isNotEmpty) const SizedBox(height: 32),

        // Highlights section
        if (product.keyHighlights.isNotEmpty) ...[
          const Text('DEVOTIONAL HIGHLIGHTS & ARTISANAL MERITS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,
                  letterSpacing: 1.2, color: Color(0xFF4A5568))),
          const SizedBox(height: 20),
          // 2-column grid
          LayoutBuilder(builder: (ctx, constraints) {
            final cols = constraints.maxWidth > 600 ? 2 : 1;
            final items = product.keyHighlights;
            return Wrap(
              spacing: 16,
              runSpacing: 12,
              children: items.map((h) {
                return SizedBox(
                  width: (constraints.maxWidth - (cols - 1) * 16) / cols,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded, size: 13, color: Colors.green[700]),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(h,
                        style: const TextStyle(fontSize: 13, height: 1.5))),
                  ]),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 32),
        ],

        // Info box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE9E4DE)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline_rounded, color: _teal, size: 20),
            const SizedBox(width: 12),
            Expanded(child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.6),
                children: const [
                  TextSpan(text: 'Insured Devotional Transit: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Every item is individually wrapped in sacred cloth, '
                      'bubble-cushioned, and dispatched with full insurance coverage '
                      'to ensure it arrives in pristine consecrated condition.'),
                ],
              ),
            )),
          ]),
        ),

        if (product.description.isEmpty && product.keyHighlights.isEmpty)
          _buildEmptyState('No details have been added for this product yet.'),
      ],
    );
  }

  // TAB 2 — Specifications & Dimensions
  Widget _buildSpecsTab(Product product) {
    if (product.specifications.isEmpty && product.weight == null && product.dimensions == null) {
      return _buildEmptyState('No specifications have been added for this product yet.');
    }

    // Merge model-level fields + the map
    final Map<String, String> specs = {
      if (product.dimensions != null && product.dimensions!.isNotEmpty)
        'Dimensions': product.dimensions!,
      if (product.weight != null) 'Weight': '${product.weight} kg',
      if (product.shippingClass != null && product.shippingClass!.isNotEmpty)
        'Shipping Class': product.shippingClass!,
      if (product.sku.isNotEmpty) 'SKU': product.sku,
      ...product.specifications,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...specs.entries.toList().asMap().entries.map((entry) {
          final isEven = entry.key.isEven;
          final kv = entry.value;
          return Container(
            color: isEven ? Colors.white : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 200,
                    child: Text(kv.key,
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 13, color: Color(0xFF4A5568)))),
                const SizedBox(width: 24),
                Expanded(child: Text(kv.value,
                    style: const TextStyle(fontSize: 13, color: Colors.black87))),
              ],
            ),
          );
        }),
      ],
    );
  }

  // TAB 3 — Sacred Care & Purity
  Widget _buildCareTab(Product product) {
    if (product.careInstructions.isEmpty) {
      return _buildEmptyState('No care instructions have been added for this product yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: product.careInstructions.map((instruction) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.spa_rounded, size: 13, color: Colors.orange[600]),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(instruction,
              style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.6))),
        ]),
      )).toList(),
    );
  }

  // TAB 4 — Devotee Reviews
  Widget _buildReviewsTab(List<Review> reviews) {
    if (reviews.isEmpty) {
      return _buildEmptyState('No reviews yet. Be the first to share your experience!');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reviews.map((review) => Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9E4DE)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Name, city, verified
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _teal,
                child: Text(review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                if (review.userCity.isNotEmpty)
                  Text(review.userCity, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ]),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(children: List.generate(5, (i) => Icon(
                i < review.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 14, color: _gold))),
              if (review.createdAt != null)
                Text(
                  '${review.createdAt!.day}/${review.createdAt!.month}/${review.createdAt!.year}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ]),
          ]),
          if (review.title.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(review.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
          const SizedBox(height: 8),
          Text(review.body,
              style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.6)),
          if (review.verifiedPurchase)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(children: [
                Icon(Icons.verified_rounded, size: 13, color: Colors.green[600]),
                const SizedBox(width: 4),
                Text('Verified Purchase', style: TextStyle(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.w600)),
              ]),
            ),
        ]),
      )).toList(),
    );
  }

  // TAB 5 — FAQs & Guidance
  Widget _buildFaqsTab(Product product) {
    if (product.faqs.isEmpty) {
      return _buildEmptyState('No FAQs have been added for this product yet.');
    }

    // Sync list size
    while (_expandedFaqs.length < product.faqs.length) _expandedFaqs.add(false);

    return Column(
      children: product.faqs.asMap().entries.map((entry) {
        final idx = entry.key;
        final faq = entry.value;
        final q = faq['question'] ?? '';
        final a = faq['answer'] ?? '';
        final isOpen = idx < _expandedFaqs.length && _expandedFaqs[idx];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isOpen ? _teal : const Color(0xFFE9E4DE)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() {
                    if (idx < _expandedFaqs.length) _expandedFaqs[idx] = !_expandedFaqs[idx];
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(children: [
                      Expanded(child: Text(q,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
                              color: isOpen ? _teal : Colors.black87))),
                      Icon(isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: isOpen ? _teal : Colors.grey[500]),
                    ]),
                  ),
                ),
                if (isOpen)
                  Container(
                    width: double.infinity,
                    color: _beige,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(a,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.65)),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Shared empty state
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[400])),
        ]),
      ),
    );
  }

  // ─── BREADCRUMB ──────────────────────────────────────────
  Widget _buildBreadcrumb(BuildContext context, Product product,
      HomePageController home, bool isMobile) {
    final catalogName = home.websiteSettings.name.isEmpty
        ? 'Sacred Catalog'
        : '${home.websiteSettings.name} Sacred Catalog';

    Widget crumbLink(String label, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          child: Text(label,
              style: TextStyle(
                color: _gold, fontSize: 13, fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: _gold.withOpacity(0.4),
              )),
        );

    Widget chevron() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey[400]),
        );

    return Container(
      width: double.infinity,
      color: _beige,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 16),
      child: Row(children: [
        crumbLink(catalogName, () => Navigator.pushNamed(context, '/products')),
        chevron(),
        crumbLink(
          product.category.isEmpty ? 'All Products' : product.category,
          () => Navigator.pushNamed(context, '/products', arguments: product.category),
        ),
        chevron(),
        Flexible(
          child: Text(product.title,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _slate, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  // ─── IMAGE GALLERY (left column) ─────────────────────────
  Widget _buildGallery(Product product, {required bool isMobile}) {
    final images = product.images;
    final hasDiscount = product.salePrice != null && product.salePrice! < (product.price ?? 0);
    final currentUrl = images.isNotEmpty
        ? images[_selectedImageIndex]
        : 'https://via.placeholder.com/600x700?text=No+Image';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MAIN IMAGE
        AspectRatio(
          aspectRatio: isMobile ? 1.0 : 0.82,
          child: Stack(children: [
            // Image with fade transition on change
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                child: Image.network(
                  currentUrl,
                  key: ValueKey(currentUrl),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Container(
                        color: Colors.grey[100],
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2, color: _teal)));
                  },
                  errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.broken_image_outlined, size: 60, color: Colors.grey)),
                ),
              ),
            ),

            // Top gradient for badge readability
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.28), Colors.transparent],
                  ),
                ),
              ),
            ),

            // TOP-LEFT: status badge + discount badge
            Positioned(
              top: 14, left: 14,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (product.badges.isNotEmpty)
                  _pill(product.badges.first.toUpperCase(), bg: _darkTeal, fg: Colors.white),
                if (hasDiscount)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _pill(
                      '${(((product.price! - product.salePrice!) / product.price!) * 100).round()}% OFF',
                      bg: _beige, fg: _gold, bordered: true,
                    ),
                  ),
              ]),
            ),

            // TOP-RIGHT: share + expand/fullscreen
            Positioned(
              top: 14, right: 14,
              child: Column(children: [
                _circleBtn(Icons.share_rounded, tooltip: 'Share',
                    onTap: () => ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Link copied to clipboard!')))),
                const SizedBox(height: 10),
                _circleBtn(Icons.open_in_full_rounded,
                    tooltip: 'View Fullscreen', onTap: () => _fullscreen(context, currentUrl)),
              ]),
            ),

            // CENTER: magnify / zoom icon
            Positioned.fill(
              child: Center(
                child: GestureDetector(
                  onTap: () => _fullscreen(context, currentUrl),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.18), shape: BoxShape.circle),
                    child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),

            // PREV arrow
            if (images.length > 1)
              Positioned(
                left: 12, top: 0, bottom: 0,
                child: Center(
                    child: _arrow(Icons.chevron_left_rounded, () => _prevImage(images.length))),
              ),

            // NEXT arrow
            if (images.length > 1)
              Positioned(
                right: 12, top: 0, bottom: 0,
                child: Center(
                    child: _arrow(Icons.chevron_right_rounded, () => _nextImage(images.length))),
              ),

            // Dot indicator (pill style)
            if (images.length > 1)
              Positioned(
                bottom: 14, left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _selectedImageIndex == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _selectedImageIndex == i ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ),

        // GENUINE STOCK BADGE
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _beige,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _gold.withOpacity(0.35)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.verified_rounded, size: 15, color: _gold),
            const SizedBox(width: 8),
            const Text('100% Genuine Atelier Stock',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: _teal, letterSpacing: 0.4)),
          ]),
        ),

        // THUMBNAIL STRIP
        if (images.length > 1) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final sel = _selectedImageIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedImageIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: sel ? _teal : Colors.grey[200]!, width: sel ? 2.5 : 1.5),
                      boxShadow: sel
                          ? [BoxShadow(color: _teal.withOpacity(0.2), blurRadius: 8)]
                          : [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(images[i], fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        // MANTRA / CHANTING BOX
        if (product.mantraText != null && product.mantraText!.isNotEmpty)
          _buildMantraBox(product),
      ],
    );
  }

  // ─── MANTRA / CHANTING BOX ──────────────────────────────────
  Widget _buildMantraBox(Product product) {
    return Container(
      margin: const EdgeInsets.only(top: 48),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange[50], // Light rounded container
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: Colors.orange[400]!, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top row: Heading + Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.local_fire_department_rounded, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  const Text('SACRED VEDIC CHANTING & MANTRA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                ],
              ),
              Row(
                children: [
                  _circleBtn(Icons.copy_rounded, tooltip: 'Copy Mantra', onTap: () {
                    // Clipboard logic here
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mantra copied to clipboard!')));
                  }),
                  const SizedBox(width: 12),
                  if (product.mantraAudioUrl != null && product.mantraAudioUrl!.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {}, // Play audio logic
                      icon: const Icon(Icons.volume_up_rounded, size: 16),
                      label: const Text('Listen 432Hz Aura', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _slate,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Mantra Text
          Text(
            product.mantraText ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.w600, 
              color: _darkTeal,
              height: 1.5,
            ),
          ),
          
          if (product.mantraTransliteration != null && product.mantraTransliteration!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              product.mantraTransliteration!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15, 
                fontStyle: FontStyle.italic, 
                color: Colors.grey[700],
              ),
            ),
          ],
          
          if (product.mantraSignificance != null && product.mantraSignificance!.isNotEmpty) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.5),
                  children: [
                    const TextSpan(text: 'Spiritual Significance: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: product.mantraSignificance!),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── SMALL HELPERS ───────────────────────────────────────
  Widget _pill(String text,
          {required Color bg, required Color fg, bool bordered = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: bordered ? Border.all(color: _gold.withOpacity(0.4)) : null,
        ),
        child: Text(text,
            style: TextStyle(
                color: fg, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
      );

  Widget _circleBtn(IconData icon,
          {required String tooltip, required VoidCallback onTap}) =>
      Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
            child: Icon(icon, size: 18, color: Colors.black87),
          ),
        ),
      );

  Widget _arrow(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: Icon(icon, size: 24, color: Colors.black87),
        ),
      );

  void _fullscreen(BuildContext context, String imageUrl) => showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(alignment: Alignment.center, children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration:
                      const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 20),
                ),
              ),
            ),
          ]),
        ),
      );

  // ─── PRODUCT INFO (right column) ──────────────
  Widget _buildProductInfo(Product product) {
    final bool hasDiscount = product.salePrice != null && product.salePrice! < (product.price ?? 0);
    final bool isSanctified = product.badges.map((b) => b.toLowerCase()).contains('sanctified') || product.keyHighlights.any((h) => h.toLowerCase().contains('sanctified'));
    final double rating = 4.95; // Mocked rating as it's not in the model yet
    final int reviewCount = 218; // Mocked review count

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. CATEGORY & RATING ROW
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pill(product.category.toUpperCase(), bg: Colors.grey[100]!, fg: Colors.grey[700]!),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(rating.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 4),
                Text('($reviewCount reviews)', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 2. PRODUCT TITLE & SUBTITLE
        Text(
          product.title,
          style: AppTypography.headingStyle(context,
              fontSize: 38, fontWeight: FontWeight.bold, color: _teal, height: 1.1),
        ),
        const SizedBox(height: 8),
        Text(
          product.metaDescription ?? product.aboutItem ?? 'A beautifully crafted sacred item to bring divine presence and auspiciousness into your daily life.',
          style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 24),

        // 3. INFO BANNER (Certification/Consecration)
        if (isSanctified) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _gold.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: _gold, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: _teal, fontSize: 13, height: 1.5),
                      children: [
                        TextSpan(text: 'Sanctified & Consecrated: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'This item has been specially blessed and energised before dispatch.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // 4. PRICE BLOCK
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\u20B9${hasDiscount ? product.salePrice : (product.price ?? 0)}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), height: 1),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '\u20B9${product.price}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough, height: 1),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    'Save \u20B9${(product.price! - product.salePrice!).toStringAsFixed(0)} (${(((product.price! - product.salePrice!) / product.price!) * 100).round()}% OFF)',
                    style: TextStyle(color: Colors.green[700], fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),

        // 5. STOCK STATUS LINE
        Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: product.stockQuantity > 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              product.stockQuantity > 0 
                  ? 'In Stock — Auspicious 24-hr temple dispatch'
                  : 'Out of Stock — Will be restocked soon',
              style: TextStyle(color: product.stockQuantity > 0 ? Colors.green[700] : Colors.red[700], fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // 6. DESCRIPTION BOX
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            product.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(height: 32),

        // 7. COLOR / FINISH SELECTOR
        if (product.variants.where((v) => v.format.isNotEmpty).isNotEmpty)
          _buildColorSelector(product),

        // 8. SIZE / EDITION SELECTOR
        if (product.variants.where((v) => v.size.isNotEmpty).isNotEmpty)
          _buildSizeSelector(product),

        // 9. ADD-ONS LIST
        if (product.addOns.isNotEmpty)
          _buildAddOnsList(product),

        // 10. QUANTITY & PRIMARY ACTIONS ROW
        _buildQuantityAndPrimaryActions(product),

        // 11. SECONDARY ACTION BUTTONS
        _buildSecondaryActions(product),

        // 12. DELIVERY & PAYMENT AVAILABILITY BOX
        _buildDeliveryBox(),
        
        const SizedBox(height: 32),

        // 13. SECURE PAYMENT ROW
        _buildSecurePaymentRow(),

        // 14. TRUST BADGES
        _buildTrustBadges(product),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSecurePaymentRow() {
    final home = Provider.of<HomePageController>(context, listen: false);
    final methods = home.websiteSettings.supportedPaymentMethods;
    if (methods.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: Colors.green[700], size: 18),
                const SizedBox(width: 8),
                const Text('100% Safe & Secure Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
              ],
            ),
            Text('256-Bit SSL Encrypted', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: methods.map((method) {
            IconData icon = Icons.payment;
            if (method.toLowerCase().contains('cod') || method.toLowerCase().contains('cash')) icon = Icons.money_rounded;
            if (method.toLowerCase().contains('upi') || method.toLowerCase().contains('gpay')) icon = Icons.bolt_rounded;
            if (method.toLowerCase().contains('card')) icon = Icons.credit_card_rounded;
            if (method.toLowerCase().contains('net') || method.toLowerCase().contains('bank')) icon = Icons.account_balance_rounded;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: _slate),
                  const SizedBox(width: 8),
                  Text(method, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTrustBadges(Product product) {
    final highlights = product.keyHighlights;
    if (highlights.isEmpty) return const SizedBox();

    return Column(
      children: [
        Divider(color: Colors.grey[200]),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.5,
          ),
          itemCount: highlights.length > 4 ? 4 : highlights.length,
          itemBuilder: (context, index) {
            final text = highlights[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _beige,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.verified_user_outlined, color: _gold, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                      const SizedBox(height: 2),
                      Text('Verified by Atelier', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildColorSelector(Product product) {
    final formats = product.variants.map((v) => v.format).toSet().toList();
    if (formats.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Selected Option / Finish: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
            Text(_selectedFormat ?? formats.first, style: TextStyle(color: _teal, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: formats.map((format) {
            final isSelected = (_selectedFormat ?? formats.first) == format;
            // Mock color based on format name length for visual distinction
            final mockColor = HSLColor.fromAHSL(1.0, (format.length * 50).toDouble() % 360, 0.6, 0.4).toColor();
            
            return GestureDetector(
              onTap: () => setState(() => _selectedFormat = format),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: mockColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? _teal : Colors.transparent, width: isSelected ? 3 : 0),
                  boxShadow: [if (isSelected) BoxShadow(color: _teal.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSizeSelector(Product product) {
    final sizes = product.variants.map((v) => v.size).where((s) => s.isNotEmpty).toSet().toList();
    if (sizes.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Select Size / Edition:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
            GestureDetector(
              onTap: () {}, // Open sizing guide
              child: Row(
                children: [
                  Icon(Icons.straighten_rounded, size: 14, color: _gold),
                  const SizedBox(width: 4),
                  Text('Sizing Guide', style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: _gold.withOpacity(0.5))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: sizes.map((size) {
            final isSelected = (_selectedSize ?? sizes.first) == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? _darkTeal : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? _darkTeal : Colors.grey[300]!, width: 1.5),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAddOnsList(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enhance your purchase:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: product.addOns.map((addon) {
              final name = addon['name'] ?? '';
              final desc = addon['description'] ?? '';
              final price = addon['price'] ?? 0;
              final bool isFree = price == 0;
              final bool isSelected = _selectedAddOns.contains(name) || (isFree && !_selectedAddOns.contains('!'+name));
              
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isFree) {
                      if (isSelected) _selectedAddOns.add('!'+name);
                      else _selectedAddOns.remove('!'+name);
                    } else {
                      if (isSelected) _selectedAddOns.remove(name);
                      else _selectedAddOns.add(name);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: isSelected ? _teal : Colors.grey[400]),
                      const SizedBox(width: 12),
                      Icon(Icons.stars_rounded, color: _gold, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name + (isFree ? ' (Free)' : ' (+\u20B9$price)'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildQuantityAndPrimaryActions(Product product) {
    final double basePrice = product.salePrice ?? product.price ?? 0;
    // Calculate addons price
    double addonsPrice = 0;
    for (var addon in product.addOns) {
      final name = addon['name'] ?? '';
      final price = (addon['price'] ?? 0).toDouble();
      final bool isFree = price == 0;
      final bool isSelected = _selectedAddOns.contains(name) || (isFree && !_selectedAddOns.contains('!'+name));
      if (isSelected) addonsPrice += price;
    }
    
    final double totalPrice = (basePrice + addonsPrice) * _quantity;

    return Row(
      children: [
        // Quantity Stepper
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                color: Colors.black87,
              ),
              SizedBox(
                width: 32,
                child: Text('$_quantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () => setState(() => _quantity++),
                color: Colors.black87,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Add to Cart Button
        Expanded(
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                final cartCtrl = Provider.of<CartController>(context, listen: false);
                for (int i = 0; i < _quantity; i++) {
                  cartCtrl.addToCart(product); // Ideally, we'd pass variants/addons here
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.title} added to cart'),
                    action: SnackBarAction(label: 'VIEW CART', onPressed: () => Navigator.pushNamed(context, '/cart')),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Add to Cart \u2022 \u20B9${totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Wishlist
        _circleBtn(Icons.favorite_border_rounded, tooltip: 'Add to Wishlist', onTap: () {}),
        const SizedBox(width: 12),
        // Share
        _circleBtn(Icons.share_outlined, tooltip: 'Share', onTap: () {}),
      ],
    );
  }

  Widget _buildSecondaryActions(Product product) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 40),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/checkout'),
              icon: const Icon(Icons.bolt_rounded, color: Colors.white),
              label: const Text('Instant Sacred Checkout (COD / Online)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E22), // Orange
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {}, // WhatsApp logic
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
              label: const Text('Order / Inquire via WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: _teal, size: 20),
                  const SizedBox(width: 8),
                  const Text('Delivery & Payment Availability', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              _pill('Cash on Delivery Available', bg: Colors.green[50]!, fg: Colors.green[700]!),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    onChanged: (val) => _pincode = val,
                    decoration: InputDecoration(
                      hintText: 'Enter Pincode',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0F4C5C))),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Trigger pincode check
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  child: const Text('Check', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.local_shipping_outlined, color: Colors.grey[600], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FREE Standard Delivery by Friday, 26 Aug', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Order within 4 hrs 30 mins for same-day dispatch.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper for tab definitions
class _TabDef {
  final IconData icon;
  final String label;
  const _TabDef({required this.icon, required this.label});
}
