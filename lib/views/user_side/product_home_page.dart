import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/language_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/homepage_model.dart';
import '../../models/category_model.dart';
import 'sections/product_cart_layout.dart';
import 'sections/product_card.dart';
import '../../utils/app_typography.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/animation_utils.dart';

class ProductHomePage extends StatefulWidget {
  const ProductHomePage({super.key});

  @override
  State<ProductHomePage> createState() => _ProductHomePageState();
}

class _ProductHomePageState extends State<ProductHomePage> {
  final Color primaryGreen = const Color(0xFF07404C);
  final Color templeGold = const Color(0xFFC89A5B);
  final Color bgCream = const Color(0xFFFDFBF7);
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context);
    final productController = Provider.of<ProductController>(context);
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    final h = homeController.homepageData.homePortal;
    final bool isMobile = Responsive.isMobile(context);

    return VisibilityDetector(
      key: const Key('product-home-visibility'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.05 && !_isVisible) {
          if (mounted) setState(() => _isVisible = true);
        }
      },
      child: ProductCartLayout(
        controller: homeController,
        slivers: [
          // 1. Hero Section
          SliverToBoxAdapter(
            child: FadeIn(
              duration: const Duration(milliseconds: 1000),
              child: ZoomIn(
                duration: const Duration(milliseconds: 1500),
                child: _buildHeroSection(context, h, lang, isMobile),
              ),
            ),
          ),
          
          // 2. Categories
          SliverToBoxAdapter(child: _buildSacredOfferingsSection(context, h, productController, lang, isMobile)),
          
          // 3. Featured Products
          SliverToBoxAdapter(child: _buildFeaturedProductsSection(context, h, productController, lang, isMobile)),
          
          // 4. Consecration Process
          SliverToBoxAdapter(child: _buildProcessSection(context, isMobile)),
          
          // 5. Testimonials
          SliverToBoxAdapter(child: _buildTestimonialsSection(context, h, lang, isMobile)),
          
          // 6. Wisdom Aphorisms
          SliverToBoxAdapter(child: _buildWisdomSection(context, h, lang, isMobile)),
          
          // 7. Help Bar
          SliverToBoxAdapter(child: _buildHelpBar(context, h, lang, isMobile)),
        ],
        child: const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, HomePortalData h, String lang, bool isMobile) {
    final bool isTablet = Responsive.isTablet(context);
    final double paddingH = isMobile ? 20 : (isTablet ? 40 : 80);
    final double paddingV = isMobile ? 40 : (isTablet ? 60 : 100);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: paddingV, horizontal: paddingH),
      decoration: BoxDecoration(
        color: primaryGreen,
        image: h.heroImage.isNotEmpty ? DecorationImage(
          image: NetworkImage(h.heroImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(primaryGreen.withOpacity(0.8), BlendMode.multiply),
        ) : null,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: !Responsive.isDesktop(context) 
            ? Column(
                children: [
                  _heroContent(context, h, lang, isMobile),
                  const SizedBox(height: 40),
                  _buildHeroFeaturedCard(context, h, lang, isMobile),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 5, child: _heroContent(context, h, lang, isMobile)),
                  const SizedBox(width: 60),
                  Expanded(flex: 4, child: _buildHeroFeaturedCard(context, h, lang, isMobile)),
                ],
              ),
        ),
      ),
    );
  }

  Widget _heroContent(BuildContext context, HomePortalData h, String lang, bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        FadeInDown(
          animate: true,
          duration: const Duration(milliseconds: 600),
          child: Row(
            mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              const Icon(Icons.stars, color: Color(0xFFC89A5B), size: 20), 
              const SizedBox(width: 10), 
              Text(AppLocalizations.of(context)!.officialStoreLabel, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5))
            ]
          ),
        ),
        const SizedBox(height: 30),
        FadeInLeft(
          animate: true,
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 200),
          child: Text(h.localizedHeroHeading(lang).isNotEmpty ? h.localizedHeroHeading(lang) : 'Sacred Offerings for Your Spiritual Journey', 
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: GoogleFonts.cormorantGaramond(
              fontSize: isMobile ? 40 : 64,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.1,
            )),
        ),
        const SizedBox(height: 30),
        FadeInUp(
          animate: true,
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 400),
          child: Text(h.localizedHeroSubtitle(lang).isNotEmpty ? h.localizedHeroSubtitle(lang) : 'Experience the divine presence with our consecrated artifacts.', 
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: AppTypography.bodyStyle(context, color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.6)),
        ),
        const SizedBox(height: 50),
        FadeInUp(
          animate: true,
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 600),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/catalogue'), 
                style: ElevatedButton.styleFrom(backgroundColor: templeGold, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                child: Row(mainAxisSize: MainAxisSize.min, children: [Text(h.localizedHeroCta1Text(lang).isNotEmpty ? h.localizedHeroCta1Text(lang).toUpperCase() : 'SHOP NOW', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)), const SizedBox(width: 12), const Icon(Icons.arrow_forward, size: 16)])),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/teachings'), 
                icon: const Icon(Icons.menu_book_outlined, size: 18), 
                label: Text(h.localizedHeroCta2Text(lang).isNotEmpty ? h.localizedHeroCta2Text(lang) : 'LEARN MORE', style: const TextStyle(fontWeight: FontWeight.bold)), 
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 25), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
            ],
          ),
        ),
        const SizedBox(height: 50),
        FadeIn(
          animate: true,
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 800),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _heroFeature(Icons.verified_user_outlined, '100% Consecrated Pure'), 
                const SizedBox(width: 30), 
                _heroFeature(Icons.local_shipping_outlined, 'Cash on Delivery'), 
                const SizedBox(width: 30), 
                _heroFeature(Icons.chat_bubble_outline, 'WhatsApp Support')
              ]
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroFeature(IconData icon, String text) => Row(children: [Icon(icon, color: Colors.amber.shade200, size: 18), const SizedBox(width: 10), Text(text, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w500))]);

  Widget _buildHeroFeaturedCard(BuildContext context, HomePortalData h, String lang, bool isMobile) {
    return FadeInRight(
      animate: true,
      duration: const Duration(milliseconds: 1000),
      delay: const Duration(milliseconds: 400),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), 
                child: h.heroSideImage.isNotEmpty 
                  ? Image.network(h.heroSideImage, height: isMobile ? 300 : 400, width: double.infinity, fit: BoxFit.cover)
                  : Image.network('https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=800', height: isMobile ? 300 : 400, width: double.infinity, fit: BoxFit.cover)), 
              Positioned(bottom: 20, left: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: templeGold, borderRadius: BorderRadius.circular(4)), child: const Text('SANCTUM DARSHAN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))))]),
            Padding(
              padding: EdgeInsets.all(isMobile ? 20 : 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), const SizedBox(width: 6), Text('4.9 (15,000+ Devotees)', style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 16),
                  Text(h.localizedHeroCardTitle(lang).isNotEmpty ? h.localizedHeroCardTitle(lang) : 'Divine Consecration', style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.w900, color: primaryGreen)),
                  const SizedBox(height: 12),
                  Text(h.localizedHeroCardSubtitle(lang).isNotEmpty ? h.localizedHeroCardSubtitle(lang) : 'Handcrafted items blessed with ancient Vedic rituals.', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
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
      ),
    );
  }

  Widget _buildSacredOfferingsSection(BuildContext context, HomePortalData h, ProductController prod, String lang, bool isMobile) {
    return Container(
      color: const Color(0xFFFAF8F4), padding: EdgeInsets.symmetric(vertical: 80, horizontal: isMobile ? 20 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Row(children: [Icon(Icons.auto_awesome, color: templeGold, size: 20), const SizedBox(width: 10), Text(AppLocalizations.of(context)!.organization, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFFC89A5B)))]), 
                      const SizedBox(height: 16), 
                      Text(h.localizedCollectionsHeading(lang).isNotEmpty ? h.localizedCollectionsHeading(lang) : 'Sacred Collections', 
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: isMobile ? 36 : 56,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF07404C),
                          letterSpacing: 0.5,
                        )), 
                      const SizedBox(height: 12), 
                      Text(AppLocalizations.of(context)!.exploreCollectionsDesc, 
                        style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontSize: 16, letterSpacing: 0.5))
                    ]
                  ),
                  if (isMobile) const SizedBox(height: 20),
                  TextButton(onPressed: () => Navigator.pushNamed(context, '/catalogue'), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(AppLocalizations.of(context)!.viewAllCollections, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: Colors.black87)), const SizedBox(width: 8), const Icon(Icons.arrow_forward, size: 16, color: Colors.black87)])),
                ],
              ),
              const SizedBox(height: 60),
              GridView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.isDesktop(context) ? 4 : (Responsive.isTablet(context) ? 3 : 2),
                  crossAxisSpacing: 24, 
                  mainAxisSpacing: 24, 
                  childAspectRatio: Responsive.isDesktop(context) ? 1.4 : 0.85
                ),
                itemCount: prod.categoryObjects.length.clamp(0, 8),
                itemBuilder: (context, index) {
                  final cat = prod.categoryObjects[index];
                  final count = prod.getProductCountInCategory(cat.id);
                  return FadeInUp(
                    animate: _isVisible,
                    duration: const Duration(milliseconds: 600),
                    delay: Duration(milliseconds: index * 60),
                    child: _CategoryTile(cat: cat, count: count, lang: lang, isMobile: isMobile, primaryGreen: primaryGreen),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedProductsSection(BuildContext context, HomePortalData h, ProductController prod, String lang, bool isMobile) {
    final products = prod.allProducts;
    return Container(
      color: Colors.white, padding: EdgeInsets.symmetric(vertical: 100, horizontal: isMobile ? 20 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_fix_normal_outlined, color: templeGold, size: 20), const SizedBox(width: 10), const Flexible(child: Text('HANDPICKED SACRED TREASURES', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFFC89A5B))))]),
              const SizedBox(height: 16),
              Text(h.localizedFeaturedHeading(lang).isNotEmpty ? h.localizedFeaturedHeading(lang) : 'Featured Treasures', textAlign: TextAlign.center, style: AppTypography.headingStyle(context, fontSize: isMobile ? 32 : 44, fontWeight: FontWeight.w900, color: primaryGreen)),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.featuredProductsDesc, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
              const SizedBox(height: 60),
              if (products.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Color(0xFF0F4C5C)),
                )
              else
                GridView.builder(
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.isDesktop(context) ? 4 : (Responsive.isTablet(context) ? 3 : 2),
                    crossAxisSpacing: isMobile ? 12 : 24, 
                    mainAxisSpacing: isMobile ? 24 : 40, 
                    childAspectRatio: Responsive.isDesktop(context) ? 0.72 : 0.65
                  ),
                  itemCount: products.length.clamp(0, 8), // Show exactly 2 rows (8 items)
                  itemBuilder: (context, index) => FadeInUp(
                    animate: _isVisible,
                    duration: const Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 100 * index),
                    child: ProductCard(product: products[index]),
                  ),
                ),
              const SizedBox(height: 60),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/catalogue'), style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('${AppLocalizations.of(context)!.browseCompleteCatalog} (${products.length} ITEMS)', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessSection(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity, color: const Color(0xFF073842), padding: EdgeInsets.symmetric(vertical: 100, horizontal: isMobile ? 20 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)),
                child: Text(AppLocalizations.of(context)!.vedicAssuranceLabel, style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.sacredConsecrationTitle, 
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: isMobile ? 36 : 56,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.vedicSanctityDesc, 
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.white.withOpacity(0.5), letterSpacing: 0.5)),
              const SizedBox(height: 80),
              isMobile 
                ? Column(
                    children: [
                      _processItem(Icons.water_drop_outlined, AppLocalizations.of(context)!.gangaJalTitle, AppLocalizations.of(context)!.gangaJalDesc, true, 0),
                      const SizedBox(height: 40),
                      _processItem(Icons.auto_fix_high_outlined, AppLocalizations.of(context)!.vedicMantraTitle, AppLocalizations.of(context)!.vedicMantraDesc, true, 1),
                      const SizedBox(height: 40),
                      _processItem(Icons.inventory_2_outlined, AppLocalizations.of(context)!.zeroBreakageTitle, AppLocalizations.of(context)!.zeroBreakageDesc, true, 2),
                      const SizedBox(height: 40),
                      _processItem(Icons.payments_outlined, AppLocalizations.of(context)!.codAvailableTitle, AppLocalizations.of(context)!.codAvailableDesc, true, 3),
                    ],
                  )
                : Row(
                    children: [
                      _processItem(Icons.water_drop_outlined, AppLocalizations.of(context)!.gangaJalTitle, AppLocalizations.of(context)!.gangaJalDesc, false, 0),
                      const SizedBox(width: 40),
                      _processItem(Icons.auto_fix_high_outlined, AppLocalizations.of(context)!.vedicMantraTitle, AppLocalizations.of(context)!.vedicMantraDesc, false, 1),
                      const SizedBox(width: 40),
                      _processItem(Icons.inventory_2_outlined, AppLocalizations.of(context)!.zeroBreakageTitle, AppLocalizations.of(context)!.zeroBreakageDesc, false, 2),
                      const SizedBox(width: 40),
                      _processItem(Icons.payments_outlined, AppLocalizations.of(context)!.codAvailableTitle, AppLocalizations.of(context)!.codAvailableDesc, false, 3),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _processItem(IconData icon, String title, String desc, bool isMobile, int index) {
    final Widget content = Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start, 
      children: [
        _ProcessIcon(icon: icon, index: index, animate: _isVisible), 
        const SizedBox(height: 24), 
        FadeInUp(
          animate: _isVisible,
          delay: Duration(milliseconds: 200 + (index * 100)),
          child: Text(title, textAlign: isMobile ? TextAlign.center : TextAlign.start, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
        ), 
        const SizedBox(height: 16), 
        FadeInUp(
          animate: _isVisible,
          delay: Duration(milliseconds: 300 + (index * 100)),
          child: Text(desc, textAlign: isMobile ? TextAlign.center : TextAlign.start, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.6))
        )
      ]
    );
    return isMobile ? content : Expanded(child: content);
  }

  Widget _buildTestimonialsSection(BuildContext context, HomePortalData h, String lang, bool isMobile) {
    return Container(
      color: Colors.white, padding: EdgeInsets.symmetric(vertical: 100, horizontal: isMobile ? 20 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  Column(crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start, children: [Text(AppLocalizations.of(context)!.devoteeExperiences, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)), const SizedBox(height: 12), Text(h.localizedTestimonialsHeading(lang).isNotEmpty ? h.localizedTestimonialsHeading(lang) : 'Words of Devotion', textAlign: isMobile ? TextAlign.center : TextAlign.start, style: AppTypography.headingStyle(context, fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.w900, color: primaryGreen))]), 
                  if (isMobile) const SizedBox(height: 20),
                  Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, color: Colors.amber, size: 18), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.averageRatingText, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold))])
                ]
              ),
              const SizedBox(height: 80),
              isMobile 
                ? Column(
                    children: [
                      _testimonialCard('Bhavin & Jigna Patel', 'Ahmedabad, Gujarat', 'Akhand Jyot Home Mandir + Pu. Dada Frame', 'The acrylic frame arrived with holy Ganga jal scent and Chandan tika. When placed in our home mandir, the entire room felt transformed with serene divine grace. Truly authentic seva!', isMobile),
                      const SizedBox(height: 24),
                      _testimonialCard('Maheshbhai Shah', 'Mumbai, Maharashtra', 'Sacred Car Dashboard Acrylic Idol & Keychain', 'Superb diamond-polished finish! Pu. Dada\'s darshan photo remains crystal clear on the car dashboard. Packaging was completely break-proof and reached in 48 hours with Cash on Delivery.', isMobile),
                      const SizedBox(height: 24),
                      _testimonialCard('Dr. Rekhaben Joshi', 'Surat, Gujarat', 'Solid Brass Padukas & Rakshasutra Set', 'The sacred padukas have exquisite weight and traditional Vedic detailing. We do daily chandan archana. Heartfelt gratitude to Himanshubhai and the entire seva team.', isMobile),
                    ],
                  )
                : Row(
                    children: [
                      _testimonialCard('Bhavin & Jigna Patel', 'Ahmedabad, Gujarat', 'Akhand Jyot Home Mandir + Pu. Dada Frame', 'The acrylic frame arrived with holy Ganga jal scent and Chandan tika. When placed in our home mandir, the entire room felt transformed with serene divine grace. Truly authentic seva!', isMobile),
                      const SizedBox(width: 24),
                      _testimonialCard('Maheshbhai Shah', 'Mumbai, Maharashtra', 'Sacred Car Dashboard Acrylic Idol & Keychain', 'Superb diamond-polished finish! Pu. Dada\'s darshan photo remains crystal clear on the car dashboard. Packaging was completely break-proof and reached in 48 hours with Cash on Delivery.', isMobile),
                      const SizedBox(width: 24),
                      _testimonialCard('Dr. Rekhaben Joshi', 'Surat, Gujarat', 'Solid Brass Padukas & Rakshasutra Set', 'The sacred padukas have exquisite weight and traditional Vedic detailing. We do daily chandan archana. Heartfelt gratitude to Himanshubhai and the entire seva team.', isMobile),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _testimonialCard(String name, String city, String order, String quote, bool isMobile) {
    final Widget content = Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 16))), const Spacer(), const Text('Verified Devotee • 2 days ago', style: TextStyle(color: Colors.grey, fontSize: 10))]), const SizedBox(height: 24), Text('"$quote"', style: TextStyle(color: Colors.black87.withOpacity(0.7), fontSize: 14, height: 1.7, fontStyle: FontStyle.italic)), const SizedBox(height: 40), Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF07404C))), const SizedBox(height: 4), Text('$city', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)), const SizedBox(height: 8), Text('Ordered: $order', style: TextStyle(color: templeGold, fontSize: 10, fontWeight: FontWeight.bold))]));
    return isMobile ? content : Expanded(child: content);
  }

  Widget _buildWisdomSection(BuildContext context, HomePortalData h, String lang, bool isMobile) {
    return Container(
      color: const Color(0xFFFAF8F4), padding: EdgeInsets.symmetric(vertical: 100, horizontal: isMobile ? 20 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.spiritualEssence, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)), const SizedBox(height: 12), Text(h.localizedWisdomHeading(lang).isNotEmpty ? h.localizedWisdomHeading(lang) : 'Spiritual Wisdom', textAlign: TextAlign.center, style: AppTypography.headingStyle(context, fontSize: isMobile ? 32 : 44, fontWeight: FontWeight.w900, color: primaryGreen)), const SizedBox(height: 80),
              isMobile 
                ? Column(
                    children: [
                      _wisdomCard('True religion is that which brings inner peace, removes all worries, and sees the pure divine soul in every living being.', 'Param Pujya Dadaji', 'Inner Peace & Harmony', isMobile),
                      const SizedBox(height: 24),
                      _wisdomCard('Keep the sacred presence of the Lord with you in your heart, in your home, and in all your actions. Auspiciousness will follow effortlessly.', 'Spiritual Aphorisms', 'Constant Remembrance', isMobile),
                      const SizedBox(height: 24),
                      _wisdomCard('Where there is no clash, no deceit, and only pure love and devotion, that place becomes the highest temple of God.', 'Vedic Satsang', 'Purity of Devotion', isMobile),
                    ],
                  )
                : Row(
                    children: [
                      _wisdomCard('True religion is that which brings inner peace, removes all worries, and sees the pure divine soul in every living being.', 'Param Pujya Dadaji', 'Inner Peace & Harmony', isMobile),
                      const SizedBox(width: 24),
                      _wisdomCard('Keep the sacred presence of the Lord with you in your heart, in your home, and in all your actions. Auspiciousness will follow effortlessly.', 'Spiritual Aphorisms', 'Constant Remembrance', isMobile),
                      const SizedBox(width: 24),
                      _wisdomCard('Where there is no clash, no deceit, and only pure love and devotion, that place becomes the highest temple of God.', 'Vedic Satsang', 'Purity of Devotion', isMobile),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wisdomCard(String quote, String author, String tag, bool isMobile) {
    final Widget content = Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: templeGold.withOpacity(0.1))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.format_quote, color: templeGold.withOpacity(0.3), size: 40), const SizedBox(height: 20), Text(quote, style: TextStyle(color: primaryGreen.withOpacity(0.8), fontSize: 16, height: 1.8, fontWeight: FontWeight.w500)), const SizedBox(height: 40), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(author, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87)), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFAF8F4), borderRadius: BorderRadius.circular(20), border: Border.all(color: templeGold.withOpacity(0.2))), child: Text(tag, style: TextStyle(color: templeGold, fontSize: 10, fontWeight: FontWeight.bold)))])]));
    return isMobile ? content : Expanded(child: content);
  }

  Widget _buildHelpBar(BuildContext context, HomePortalData h, String lang, bool isMobile) {
    return FadeInUp(
      animate: _isVisible,
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 400),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Container(
              padding: EdgeInsets.all(isMobile ? 20 : 40), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
              child: Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                children: [
                  Container(width: 56, height: 56, decoration: BoxDecoration(color: primaryGreen, shape: BoxShape.circle), child: const Icon(Icons.forum_outlined, color: Colors.white, size: 24)),
                  const SizedBox(width: 24, height: 24),
                  Expanded(flex: isMobile ? 0 : 1, child: Column(crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start, children: [Text(h.localizedWhatsappTitle(lang).isNotEmpty ? h.localizedWhatsappTitle(lang) : 'Connect via WhatsApp', textAlign: isMobile ? TextAlign.center : TextAlign.start, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF07404C))), const SizedBox(height: 8), Text(h.localizedWhatsappSubtitle(lang).isNotEmpty ? h.localizedWhatsappSubtitle(lang) : 'Our seva team is here to guide you.', textAlign: isMobile ? TextAlign.center : TextAlign.start, style: const TextStyle(color: Colors.grey, fontSize: 14))])),
                  if (isMobile) const SizedBox(height: 24),
                  ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.chat_bubble, size: 18), label: Text(h.localizedWhatsappBtnText(lang).isNotEmpty ? h.localizedWhatsappBtnText(lang).toUpperCase() : 'CHAT NOW', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)), style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 25), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  final dynamic cat;
  final int count;
  final String lang;
  final bool isMobile;
  final Color primaryGreen;

  const _CategoryTile({
    required this.cat, 
    required this.count, 
    required this.lang, 
    required this.isMobile,
    required this.primaryGreen
  });

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/catalogue', arguments: widget.cat.id);
      },
      onHover: (v) => setState(() => _isHovered = v),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.03), 
              blurRadius: _isHovered ? 30 : 10, 
              offset: Offset(0, _isHovered ? 15 : 4)
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 48, height: 48, 
                  decoration: BoxDecoration(
                    color: _isHovered ? const Color(0xFFC89A5B).withOpacity(0.1) : const Color(0xFFFDFBF7), 
                    borderRadius: BorderRadius.circular(12)
                  ), 
                  child: Center(
                    child: widget.cat.imageUrl.isNotEmpty 
                      ? AnimatedScale(
                          duration: const Duration(milliseconds: 400),
                          scale: _isHovered ? 1.15 : 1.0,
                          child: Image.network(widget.cat.imageUrl, width: 28, height: 28, fit: BoxFit.contain)
                        ) 
                      : Icon(Icons.category_outlined, color: widget.primaryGreen, size: 24)
                  )
                ), 
                if (!widget.isMobile) 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6)), 
                    child: Text('${widget.count} items', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400))
                  )
              ]
            ),
            const SizedBox(height: 20),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: AppTypography.headingStyle(
                context, 
                fontWeight: FontWeight.w900, 
                fontSize: 16, 
                color: _isHovered ? const Color(0xFFC89A5B) : const Color(0xFF2B2B2B)
              ),
              child: Text(widget.cat.localizedName(widget.lang)),
            ),
            const SizedBox(height: 8),
            Text(
              widget.cat.localizedDescription(widget.lang).isNotEmpty 
                ? widget.cat.localizedDescription(widget.lang) 
                : 'Authentic sacred items consecrated with love.', 
              style: AppTypography.bodyStyle(context, color: Colors.grey.shade500, fontSize: 11, height: 1.4), 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis
            ),
            const Spacer(),
            Row(
              children: [
                Text('Explore', style: AppTypography.bodyStyle(context, fontSize: 12, fontWeight: FontWeight.w900, color: widget.primaryGreen)),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(left: _isHovered ? 6 : 0),
                  child: Icon(Icons.arrow_forward_ios, size: 10, color: widget.primaryGreen)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessIcon extends StatelessWidget {
  final IconData icon;
  final int index;
  final bool animate;

  const _ProcessIcon({required this.icon, required this.index, required this.animate});

  @override
  Widget build(BuildContext context) {
    return ElasticIn(
      animate: animate,
      delay: Duration(milliseconds: index * 150),
      child: Container(
        width: 56, height: 56, 
        decoration: BoxDecoration(
          color: Colors.white12, 
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1))
        ), 
        child: Icon(icon, color: Colors.amber.shade200, size: 28)
      ),
    );
  }
}
