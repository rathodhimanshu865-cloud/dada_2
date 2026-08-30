import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/product_cart_layout.dart';
import '../../utils/app_typography.dart';

class PuDadaTeachingsPage extends StatelessWidget {
  const PuDadaTeachingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    final t = controller.homepageData.teachingsPage;
    
    final primaryTeal = const Color(0xFF0F4C5C);
    final goldAccent = const Color(0xFFC89A5B);
    final bgLight = const Color(0xFFF9F7F2);

    return ProductCartLayout(
      controller: controller,
      child: Container(
        color: bgLight,
        child: Column(
          children: [
            _buildHeroBanner(context, t, primaryTeal, goldAccent),
            const SizedBox(height: 80),
            _buildDivinePurpose(context, t, primaryTeal, goldAccent),
            const SizedBox(height: 80),
            _buildThreePillars(context, t, primaryTeal, goldAccent),
            const SizedBox(height: 60),
            _buildCTAButton(context, primaryTeal),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, TeachingsPageData t, Color primaryColor, Color goldColor) {
    return Container(
      width: double.infinity,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      decoration: t.heroImage.isNotEmpty ? BoxDecoration(
        image: DecorationImage(image: NetworkImage(t.heroImage), fit: BoxFit.cover, colorFilter: ColorFilter.mode(primaryColor.withOpacity(0.8), BlendMode.multiply))
      ) : null,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: goldColor.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.spa, color: goldColor, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'PARAM PUJYA DADA BHAGWAN DEVOTIONAL SEVA',
                      style: TextStyle(color: Color(0xFFC89A5B), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                t.heroTitle,
                textAlign: TextAlign.center,
                style: AppTypography.headingStyle(context, fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white).copyWith(height: 1.2),
              ),
              const SizedBox(height: 24),
              Text(
                t.heroSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodyStyle(context, fontSize: 18, color: Colors.white.withOpacity(0.8)).copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivinePurpose(BuildContext context, TeachingsPageData t, Color primaryColor, Color goldColor) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('THE DIVINE PURPOSE', style: TextStyle(color: goldColor, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    Text(
                      t.divinePurposeTitle,
                      style: AppTypography.headingStyle(context, fontSize: 36, fontWeight: FontWeight.bold, color: primaryColor).copyWith(height: 1.2),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t.divinePurposeDesc1,
                      style: AppTypography.bodyStyle(context, fontSize: 16, color: Colors.grey.shade700).copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.divinePurposeDesc2,
                      style: AppTypography.bodyStyle(context, fontSize: 16, color: Colors.grey.shade700).copyWith(height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 80),
              Expanded(
                flex: 1,
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(t.divinePurposeImage.isNotEmpty ? t.divinePurposeImage : 'https://via.placeholder.com/600x400'),
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

  Widget _buildThreePillars(BuildContext context, TeachingsPageData t, Color primaryColor, Color goldColor) {
    final pillars = t.pillars.isNotEmpty ? t.pillars : [
      TeachingCard(title: '100% Consecrated Pure', description: 'Every sacred item is energized with Vedic protection mantras.', image: '', icon: 'verified_outlined'),
      TeachingCard(title: 'Handcrafted Masterpieces', description: 'Finely finished acrylics and durable materials.', image: '', icon: 'design_services_outlined'),
      TeachingCard(title: 'Non Profit Seva Spirit', description: 'All offerings support charitable devotee outreach.', image: '', icon: 'favorite_outline'),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'The Divine Pillars of Pu. Dada Devotional Store',
              textAlign: TextAlign.center,
              style: AppTypography.headingStyle(context, fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
            ),
            const SizedBox(height: 40),
            Row(
              children: pillars.map((p) => _pillarCard(context, Icons.auto_awesome, p.title, p.description, goldColor)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillarCard(BuildContext context, IconData icon, String title, String description, Color goldColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: goldColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: goldColor, size: 28),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTypography.headingStyle(
                context,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F4C5C),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: AppTypography.bodyStyle(
                context,
                fontSize: 15,
                color: Colors.grey.shade600,
              ).copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context, Color primaryColor) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/catalogue');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        'EXPLORE PU. DADA SACRED PRODUCT COLLECTIONS \u2192',
        style: AppTypography.bodyStyle(
          context,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
