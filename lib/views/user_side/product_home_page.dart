import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../models/store_config_model.dart';
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
          _buildHeroSection(context, productController),
          const SizedBox(height: 60),
          _buildCategoriesSection(context, productController),
          const SizedBox(height: 60),
          _buildFeaturedProductsSection(context, productController),
          const SizedBox(height: 60),
          _buildLatestProductsSection(context, productController),
          const SizedBox(height: 60),
          _buildPopularProductsSection(context, productController),
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

  Widget _buildHeroSection(BuildContext context, ProductController prod) {
    return StreamBuilder<StoreConfigModel>(
      stream: prod.storeConfigStream,
      builder: (context, snapshot) {
        final config = snapshot.data ?? StoreConfigModel();
        
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
                          config.storeName,
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
                              onPressed: () => Navigator.pushNamed(context, '/catalogue'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC89A5B),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                              ),
                              child: Text(
                                'EXPLORE COLLECTION >',
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
                    child: config.bannerUrl.isNotEmpty 
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(config.bannerUrl, height: 400, fit: BoxFit.cover, 
                              errorBuilder: (c, e, s) => Container(height: 400, color: Colors.white10, child: const Icon(Icons.storefront, color: Colors.white, size: 100))),
                        )
                      : Container(
                          height: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white10,
                          ),
                          child: const Icon(Icons.storefront, color: Colors.white, size: 100),
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildCategoriesSection(BuildContext context, ProductController prod) {
    return StreamBuilder<List<CategoryModel>>(
      stream: prod.categoriesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) return const SizedBox.shrink();

        final double screenWidth = MediaQuery.of(context).size.width;
        final int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 4 : 6);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                Text(
                  'Sacred Offerings',
                  style: AppTypography.headingStyle(context, fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF0F4C5C)),
                ),
                const SizedBox(height: 40),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return InkWell(
                      onTap: () {
                        // Navigate to catalogue with category filter
                        Navigator.pushNamed(context, '/catalogue', arguments: cat.id);
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: cat.imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(cat.imageUrl), fit: BoxFit.cover) : null,
                                color: Colors.grey.shade100,
                              ),
                              child: cat.imageUrl.isEmpty ? const Icon(Icons.category_outlined, color: Colors.grey) : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(cat.name, textAlign: TextAlign.center, style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildFeaturedProductsSection(BuildContext context, ProductController prod) {
    return _buildSection(
      context, 
      'Featured Sacred Items', 
      prod.featuredProductsStream,
    );
  }

  Widget _buildLatestProductsSection(BuildContext context, ProductController prod) {
    return _buildSection(
      context, 
      'Latest Arrivals', 
      prod.latestProductsStream,
    );
  }

  Widget _buildPopularProductsSection(BuildContext context, ProductController prod) {
    return _buildSection(
      context, 
      'Most Popular', 
      prod.popularProductsStream,
    );
  }

  Widget _buildSection(BuildContext context, String title, Stream<List<ProductModel>> stream) {
    return StreamBuilder<List<ProductModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) return const SizedBox.shrink();

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    title,
                    style: AppTypography.headingStyle(context, fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F4C5C)),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 420,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 20),
                    itemBuilder: (context, index) => SizedBox(
                      width: 280,
                      child: ProductCard(product: products[index]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  // Static content sections
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
              'Devotee Blessings',
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
