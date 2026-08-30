import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/product_cart_layout.dart';
import 'sections/product_card.dart';
import '../../utils/app_typography.dart';

class ProductHomePage extends StatelessWidget {
  const ProductHomePage({super.key});

  final Color primaryGreen = const Color(0xFF07404C);
  final Color templeGold = const Color(0xFFC89A5B);
  final Color bgCream = const Color(0xFFFDFBF7);

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context);
    final productController = Provider.of<ProductController>(context);
    final h = homeController.homepageData.homePortal;

    return ProductCartLayout(
      controller: homeController,
      slivers: [
        // 1. Hero Section
        SliverToBoxAdapter(child: _buildHeroSection(context, h)),
        
        // 2. Categories (Devotional Collections)
        SliverToBoxAdapter(child: _buildSacredOfferingsSection(context, h, productController)),
        
        // 3. Featured Products Grid
        SliverToBoxAdapter(child: _buildFeaturedProductsSection(context, h, productController)),
        
        // 4. Consecration Process
        SliverToBoxAdapter(child: _buildProcessSection(context)),
        
        // 5. Testimonials
        SliverToBoxAdapter(child: _buildTestimonialsSection(context, h)),
        
        // 6. Wisdom Aphorisms
        SliverToBoxAdapter(child: _buildWisdomSection(context, h)),
        
        // 7. Help/Guidance Bar
        SliverToBoxAdapter(child: _buildHelpBar(context, h)),
      ],
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildHeroSection(BuildContext context, HomePortalData h) {
    return Container(
      width: double.infinity,
      color: primaryGreen,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 80),
      decoration: h.heroImage.isNotEmpty ? BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(h.heroImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(primaryGreen.withOpacity(0.8), BlendMode.multiply),
        ),
      ) : null,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [const Icon(Icons.stars, color: Color(0xFFC89A5B), size: 20), const SizedBox(width: 10), Text('Official Pu. Jignesh Dada Devotional Store', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5))]),
                    const SizedBox(height: 30),
                    Text(h.heroHeading, 
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 64,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.1,
                      )),
                    const SizedBox(height: 30),
                    Text(h.heroSubtitle, style: AppTypography.bodyStyle(context, color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.6)),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/catalogue'), 
                          style: ElevatedButton.styleFrom(backgroundColor: templeGold, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                          child: Row(children: [Text(h.heroCta1Text.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)), const SizedBox(width: 12), const Icon(Icons.arrow_forward, size: 16)])),
                        const SizedBox(width: 20),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/teachings'), 
                          icon: const Icon(Icons.menu_book_outlined, size: 18), 
                          label: Text(h.heroCta2Text, style: const TextStyle(fontWeight: FontWeight.bold)), 
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 25), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Row(children: [_heroFeature(Icons.verified_user_outlined, '100% Consecrated Pure'), const SizedBox(width: 40), _heroFeature(Icons.local_shipping_outlined, 'Cash on Delivery Pan-India'), const SizedBox(width: 40), _heroFeature(Icons.chat_bubble_outline, 'WhatsApp Seva Support')]),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              Expanded(flex: 4, child: _buildHeroFeaturedCard(context, h)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroFeature(IconData icon, String text) => Row(children: [Icon(icon, color: Colors.amber.shade200, size: 18), const SizedBox(width: 10), Text(text, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w500))]);

  Widget _buildHeroFeaturedCard(BuildContext context, HomePortalData h) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), 
              child: h.heroSideImage.isNotEmpty 
                ? Image.network(h.heroSideImage, height: 400, width: double.infinity, fit: BoxFit.cover)
                : Image.network('https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=800', height: 400, width: double.infinity, fit: BoxFit.cover)), 
            Positioned(bottom: 20, left: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: templeGold, borderRadius: BorderRadius.circular(4)), child: const Text('SANCTUM DARSHAN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))))]),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), const SizedBox(width: 6), Text('4.9 (15,000+ Devotees)', style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 16),
                Text(h.heroCardTitle, style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.w900, color: primaryGreen)),
                const SizedBox(height: 12),
                Text(h.heroCardSubtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFDFBF7), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
                  child: Row(children: [const Icon(Icons.card_giftcard, color: Color(0xFFC89A5B), size: 20), const SizedBox(width: 16), const Expanded(child: Text('Free Consecration Kit with orders ₹499+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade200)), child: const Text('Code: DADA10', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)))]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSacredOfferingsSection(BuildContext context, HomePortalData h, ProductController prod) {
    return Container(
      color: const Color(0xFFFAF8F4), padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Row(children: [Icon(Icons.auto_awesome, color: templeGold, size: 20), const SizedBox(width: 10), const Text('DEVOTIONAL COLLECTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFFC89A5B)))]), 
                      const SizedBox(height: 16), 
                      Text(h.collectionsHeading, 
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 56,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF07404C),
                          letterSpacing: 0.5,
                        )), 
                      const SizedBox(height: 12), 
                      Text('Explore revered photo keychains, acrylic frames, home mandirs, and holy puja essentials.', 
                        style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontSize: 16, letterSpacing: 0.5))
                    ]
                  ),
                  TextButton(onPressed: () => Navigator.pushNamed(context, '/catalogue'), child: Row(children: [const Text('VIEW ALL COLLECTIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: Colors.black87)), const SizedBox(width: 8), const Icon(Icons.arrow_forward, size: 16, color: Colors.black87)])),
                ],
              ),
              const SizedBox(height: 60),
              GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 1.6),
                itemCount: prod.categoryObjects.length.clamp(0, 8),
                itemBuilder: (context, index) {
                  final cat = prod.categoryObjects[index];
                  final count = prod.getProductCountInCategory(cat.id);
                  return InkWell(
                    onTap: () {
                      prod.selectCategory(cat.id);
                      Navigator.pushNamed(context, '/catalogue');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFFDFBF7), borderRadius: BorderRadius.circular(12)), child: Center(child: cat.imageUrl.isNotEmpty ? Image.network(cat.imageUrl, width: 28, height: 28, fit: BoxFit.contain) : Icon(Icons.category_outlined, color: primaryGreen, size: 24))), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6)), child: Text('$count items', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400)))]),
                          const SizedBox(height: 20),
                          Text(cat.name, style: AppTypography.headingStyle(context, fontWeight: FontWeight.w900, fontSize: 16, color: const Color(0xFF2B2B2B))),
                          const SizedBox(height: 8),
                          Text(cat.description.isNotEmpty ? cat.description : 'Authentic sacred items consecrated with love.', style: AppTypography.bodyStyle(context, color: Colors.grey.shade500, fontSize: 11, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const Spacer(),
                          Row(
                            children: [
                              Text('Explore Store', style: AppTypography.bodyStyle(context, fontSize: 12, fontWeight: FontWeight.w900, color: primaryGreen)),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios, size: 10, color: primaryGreen),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedProductsSection(BuildContext context, HomePortalData h, ProductController prod) {
    final products = prod.allProducts;
    return Container(
      color: Colors.white, padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_fix_normal_outlined, color: templeGold, size: 20), const SizedBox(width: 10), const Text('HANDPICKED SACRED TREASURES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFFC89A5B)))]),
              const SizedBox(height: 16),
              Text(h.featuredHeading, style: AppTypography.headingStyle(context, fontSize: 44, fontWeight: FontWeight.w900, color: primaryGreen)),
              const SizedBox(height: 16),
              Text('Every item is crafted with devotion, checked for high structural durability, and energized with Vedic sanctification.', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
              const SizedBox(height: 60),
              GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 24, mainAxisSpacing: 40, childAspectRatio: 0.7),
                itemCount: products.length.clamp(0, 8), // Show exactly 2 rows (8 items)
                itemBuilder: (context, index) => ProductCard(product: products[index]),
              ),
              const SizedBox(height: 60),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/catalogue'), style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('BROWSE COMPLETE STORE CATALOG (${products.length} ITEMS)', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessSection(BuildContext context) {
    return Container(
      width: double.infinity, color: const Color(0xFF073842), padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)),
                child: const Text('VEDIC ASSURANCE & PURITY SEAL', style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 24),
              Text('The Sacred Consecration Process', 
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 56,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
              const SizedBox(height: 16),
              Text('We uphold complete sanctity from the artisan\'s hands to your puja room.', 
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.white.withOpacity(0.5), letterSpacing: 0.5)),
              const SizedBox(height: 80),
              Row(
                children: [
                  _processItem(Icons.water_drop_outlined, 'Ganga Jal & Chandan Snan', 'Articles are purified with sacred Haridwar Ganga jal and fragrant sandalwood paste.'),
                  const SizedBox(width: 40),
                  _processItem(Icons.auto_fix_high_outlined, 'Vedic Mantra Archana', 'Energized by Vedic scholars chanting sacred protection and peace mantras.'),
                  const SizedBox(width: 40),
                  _processItem(Icons.inventory_2_outlined, 'Zero-Breakage Transit', 'Multi-layer protective packaging & sanctified cloth wraps with free replacement assurance.'),
                  const SizedBox(width: 40),
                  _processItem(Icons.payments_outlined, 'Cash on Delivery Available', 'Pay with confidence upon doorstep delivery anywhere across India.'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _processItem(IconData icon, String title, String desc) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.amber.shade200, size: 24)), const SizedBox(height: 24), Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 16), Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.6))]));

  Widget _buildTestimonialsSection(BuildContext context, HomePortalData h) {
    return Container(
      color: Colors.white, padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('DEVOTEE EXPERIENCES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)), const SizedBox(height: 12), Text(h.testimonialsHeading, style: AppTypography.headingStyle(context, fontSize: 40, fontWeight: FontWeight.w900, color: primaryGreen))]), Row(children: [const Icon(Icons.star, color: Colors.amber, size: 18), const SizedBox(width: 8), Text('4.9 / 5 Average Rating across 15,000+ Blessed Homes', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold))])]),
              const SizedBox(height: 80),
              Row(
                children: [
                  _testimonialCard('Bhavin & Jigna Patel', 'Ahmedabad, Gujarat', 'Akhand Jyot Home Mandir + Pu. Dada Frame', 'The acrylic frame arrived with holy Ganga jal scent and Chandan tika. When placed in our home mandir, the entire room felt transformed with serene divine grace. Truly authentic seva!'),
                  const SizedBox(width: 24),
                  _testimonialCard('Maheshbhai Shah', 'Mumbai, Maharashtra', 'Sacred Car Dashboard Acrylic Idol & Keychain', 'Superb diamond-polished finish! Pu. Dada\'s darshan photo remains crystal clear on the car dashboard. Packaging was completely break-proof and reached in 48 hours with Cash on Delivery.'),
                  const SizedBox(width: 24),
                  _testimonialCard('Dr. Rekhaben Joshi', 'Surat, Gujarat', 'Solid Brass Padukas & Rakshasutra Set', 'The sacred padukas have exquisite weight and traditional Vedic detailing. We do daily chandan archana. Heartfelt gratitude to Himanshubhai and the entire seva team.'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _testimonialCard(String name, String city, String order, String quote) => Expanded(child: Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 16))), const Spacer(), const Text('Verified Devotee • 2 days ago', style: TextStyle(color: Colors.grey, fontSize: 10))]), const SizedBox(height: 24), Text('"$quote"', style: TextStyle(color: Colors.black87.withOpacity(0.7), fontSize: 14, height: 1.7, fontStyle: FontStyle.italic)), const SizedBox(height: 40), Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF07404C))), const SizedBox(height: 4), Text('$city', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)), const SizedBox(height: 8), Text('Ordered: $order', style: TextStyle(color: templeGold, fontSize: 10, fontWeight: FontWeight.bold))])));

  Widget _buildWisdomSection(BuildContext context, HomePortalData h) {
    return Container(
      color: const Color(0xFFFAF8F4), padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              const Text('SPIRITUAL ESSENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)), const SizedBox(height: 12), Text(h.wisdomHeading, style: AppTypography.headingStyle(context, fontSize: 44, fontWeight: FontWeight.w900, color: primaryGreen)), const SizedBox(height: 80),
              Row(
                children: [
                  _wisdomCard('True religion is that which brings inner peace, removes all worries, and sees the pure divine soul in every living being.', 'Param Pujya Dadaji', 'Inner Peace & Harmony'),
                  const SizedBox(width: 24),
                  _wisdomCard('Keep the sacred presence of the Lord with you in your heart, in your home, and in all your actions. Auspiciousness will follow effortlessly.', 'Spiritual Aphorisms', 'Constant Remembrance'),
                  const SizedBox(width: 24),
                  _wisdomCard('Where there is no clash, no deceit, and only pure love and devotion, that place becomes the highest temple of God.', 'Vedic Satsang', 'Purity of Devotion'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wisdomCard(String quote, String author, String tag) => Expanded(child: Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: templeGold.withOpacity(0.1))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.format_quote, color: templeGold.withOpacity(0.3), size: 40), const SizedBox(height: 20), Text(quote, style: TextStyle(color: primaryGreen.withOpacity(0.8), fontSize: 16, height: 1.8, fontWeight: FontWeight.w500)), const SizedBox(height: 40), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(author, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87)), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFAF8F4), borderRadius: BorderRadius.circular(20), border: Border.all(color: templeGold.withOpacity(0.2))), child: Text(tag, style: TextStyle(color: templeGold, fontSize: 10, fontWeight: FontWeight.bold)))])])));

  Widget _buildHelpBar(BuildContext context, HomePortalData h) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Container(
            padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
            child: Row(
              children: [
                Container(width: 56, height: 56, decoration: BoxDecoration(color: primaryGreen, shape: BoxShape.circle), child: const Icon(Icons.forum_outlined, color: Colors.white, size: 24)),
                const SizedBox(width: 24),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(h.whatsappTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF07404C))), const SizedBox(height: 8), Text(h.whatsappSubtitle, style: const TextStyle(color: Colors.grey, fontSize: 14))])),
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.chat_bubble, size: 18), label: Text(h.whatsappBtnText.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)), style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 25), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
