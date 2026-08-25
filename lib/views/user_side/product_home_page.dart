import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import 'sections/product_cart_layout.dart';
import 'sections/product_card.dart';
import '../../utils/app_typography.dart';

class ProductHomePage extends StatelessWidget {
  const ProductHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final productController = Provider.of<ProductController>(context);

    return ProductCartLayout(
      controller: homeController,
      child: Column(
        children: [
          _buildHeroSection(context),
          const SizedBox(height: 60),
          _buildCategoriesSection(context),
          const SizedBox(height: 60),
          _buildFeaturedProductsSection(context, productController),
          const SizedBox(height: 60),
          _buildProcessSection(context),
          const SizedBox(height: 60),
          _buildTestimonialsSection(context),
          const SizedBox(height: 60),
          _buildWisdomSection(context),
          const SizedBox(height: 60),
          _buildNewsletterBanner(context),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F4C5C),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sacred Darshan, Consecrated\nAltars & Holy Granths',
                      style: AppTypography.headingStyle(
                        context,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ).copyWith(height: 1.2),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bring home the divine blessings. Every item is specially curated and consecrated to bring positive energy and spiritual upliftment to your living space.',
                      style: AppTypography.bodyStyle(
                        context,
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/catalogue');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC89A5B),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          ),
                          child: Text(
                            'EXPLORE COLLECTION >',
                            style: AppTypography.bodyStyle(context, fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/teachings');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          ),
                          child: Text(
                            'PU. DADA TEACHINGS',
                            style: AppTypography.bodyStyle(context, fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                flex: 1,
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/600x400/E8DCC4/0F4C5C?text=Hero+Image'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final categories = [
      {'title': 'Keychains', 'icon': '🔑', 'items': '12 Items'},
      {'title': 'Acrylic Photo Frames', 'icon': '🖼️', 'items': '24 Items'},
      {'title': 'Temple', 'icon': '⛩️', 'items': '8 Items'},
      {'title': 'Yantras & Malas', 'icon': '📿', 'items': '32 Items'},
      {'title': 'Idols', 'icon': '🕉️', 'items': '15 Items'},
      {'title': 'Puja Items', 'icon': '🪔', 'items': '40 Items'},
      {'title': 'Books & Granths', 'icon': '📚', 'items': '18 Items'},
      {'title': 'Apparel', 'icon': '👕', 'items': '10 Items'},
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth < 600 ? 1 : (screenWidth < 900 ? 2 : 4);
    final double aspectRatio = screenWidth < 600 ? 4.0 : 2.5;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'Sacred Offerings of Pu. Dada',
              style: AppTypography.headingStyle(context, fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF0F4C5C)),
            ),
            const SizedBox(height: 10),
            Text('Explore our diverse range of spiritual items carefully prepared for you.', style: AppTypography.bodyStyle(context, color: Colors.grey.shade600)),
            const SizedBox(height: 40),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: aspectRatio,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: InkWell(
                    onTap: () {
                      Provider.of<ProductController>(context, listen: false).selectCategory(cat['title']! as String);
                      Navigator.pushNamed(context, '/catalogue');
                    },
                    child: Row(
                      children: [
                        Text(cat['icon']! as String, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(cat['title']! as String, style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF2B2B2B))),
                              Text(cat['items']! as String, style: AppTypography.bodyStyle(context, fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProductsSection(BuildContext context, ProductController prod) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'Featured Products of Pu. Dada',
              style: AppTypography.headingStyle(context, fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF0F4C5C)),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: [
                _filterChip('All Products', true),
                _filterChip('Acrylic Photo Frames', false),
                _filterChip('Temple', false),
                _filterChip('Keychains / Malas', false),
                _filterChip('Books', false),
              ],
            ),
            const SizedBox(height: 40),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.6,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: prod.featuredProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: prod.featuredProducts[index]);
              },
            ),
            const SizedBox(height: 40),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/catalogue');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0F4C5C)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text('VIEW ALL PRODUCTS >', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, color: const Color(0xFF0F4C5C))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Chip(
      label: Text(label),
      backgroundColor: isSelected ? const Color(0xFF0F4C5C) : Colors.white,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w600),
      side: BorderSide(color: isSelected ? const Color(0xFF0F4C5C) : Colors.grey.shade300),
    );
  }

  Widget _buildProcessSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F4C5C),
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The Sacred Consecration Process',
                style: AppTypography.headingStyle(context, fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text('How we ensure purity and divinity in every item you receive.', style: AppTypography.bodyStyle(context, color: Colors.white70)),
              const SizedBox(height: 40),
              Row(
                children: [
                  _processCard('✔️', 'Complete Quality Check', 'Ensuring the physical perfection of the item.'),
                  const SizedBox(width: 20),
                  _processCard('💧', 'Holy Water Wash', 'Purification using sacred river waters.'),
                  const SizedBox(width: 20),
                  _processCard('🕉️', 'Vedic Mantras', 'Consecration through powerful ancient chants.'),
                  const SizedBox(width: 20),
                  _processCard('✨', 'Divine Blessing', 'Final blessing before it reaches your home.'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _processCard(String icon, String title, String desc) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Devotee Blessings & Testimonials',
              style: AppTypography.headingStyle(context, fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F4C5C)),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                _testimonialCard(),
                const SizedBox(width: 20),
                _testimonialCard(),
                const SizedBox(width: 20),
                _testimonialCard(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _testimonialCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFC89A5B), size: 16)),
            ),
            const SizedBox(height: 16),
            const Text('"The products are beautifully crafted and bring such a divine presence to our home altar. Highly recommended!"', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF2B2B2B), height: 1.5)),
            const SizedBox(height: 16),
            const Text('- Devotee Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F4C5C))),
          ],
        ),
      ),
    );
  }

  Widget _buildWisdomSection(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wisdom & Daily Aphorisms',
              style: AppTypography.headingStyle(context, fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F4C5C)),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _wisdomCard()),
                const SizedBox(width: 20),
                Expanded(child: _wisdomCard()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _wisdomCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC89A5B).withOpacity(0.3)),
      ),
      child: const Center(
        child: Text(
          '"True devotion is not in the rituals, but in the purity of the heart that performs them."',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Color(0xFF2B2B2B), height: 1.5),
        ),
      ),
    );
  }

  Widget _buildNewsletterBanner(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          decoration: BoxDecoration(
            color: const Color(0xFF0F4C5C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Need Guidance on Rituals or Sacred Articles?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Get in touch with our team for personalized spiritual assistance.', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC89A5B),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                ),
                child: const Text('CONTACT SUPPORT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
