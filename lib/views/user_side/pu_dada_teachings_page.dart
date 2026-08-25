import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import 'sections/product_cart_layout.dart';
import '../../utils/app_typography.dart';

class PuDadaTeachingsPage extends StatelessWidget {
  const PuDadaTeachingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context, listen: false);
    final primaryTeal = const Color(0xFF0F4C5C);
    final goldAccent = const Color(0xFFC89A5B);
    final bgLight = const Color(0xFFF9F7F2); // very light warm background color

    return ProductCartLayout(
      controller: controller,
      child: Container(
        color: bgLight,
        child: Column(
          children: [
            _buildHeroBanner(context, primaryTeal, goldAccent),
            const SizedBox(height: 80),
            _buildDivinePurpose(context, primaryTeal, goldAccent),
            const SizedBox(height: 80),
            _buildThreePillars(context, primaryTeal, goldAccent),
            const SizedBox(height: 60),
            _buildCTAButton(context, primaryTeal),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, Color primaryColor, Color goldColor) {
    return Container(
      width: double.infinity,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
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
                    Icon(Icons.spa, color: goldColor, size: 16), // leaf/spa icon for devotion
                    const SizedBox(width: 8),
                    Text(
                      'PARAM PUJYA DADA BHAGWAN DEVOTIONAL SEVA',
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Spiritual Grace, Eternal Darshan & Sacred\nTeachings',
                textAlign: TextAlign.center,
                style: AppTypography.headingStyle(
                  context,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ).copyWith(height: 1.2),
              ),
              const SizedBox(height: 24),
              Text(
                'Bringing consecrated darshan photos, sacred padukas, akhand jyot mandirs, and holy\nspiritual essentials into the homes of seekers and devotees worldwide.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyStyle(
                  context,
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ).copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivinePurpose(BuildContext context, Color primaryColor, Color goldColor) {
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
                    Text(
                      'THE DIVINE PURPOSE',
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Living Darshan & Pure\nSpiritual Vibration',
                      style: AppTypography.headingStyle(
                        context,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ).copyWith(height: 1.2),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Pu. Dada\'s eternal presence and profound spiritual teachings illuminate the path of self-realization, inner harmony, and pure devotion to Bhagwan Sri Radha Krishna.',
                      style: AppTypography.bodyStyle(context, fontSize: 16, color: Colors.grey.shade700).copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Every photo frame, keychain, car dashboard idol, and sacred paduka is consecrated following traditional Vedic vidhi — purified with sacred Ganga jal and energized with Vedic protection mantras so your mandir radiates divine peace.',
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
                    image: const DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/600x400/E8DCC4/0F4C5C?text=Consecrated+at+Sacred+Tirth+Mandir'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(24),
                  child: const Text(
                    'Consecrated at Sacred Tirth Mandir',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThreePillars(BuildContext context, Color primaryColor, Color goldColor) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'The Three Pillars of Pu. Dada Devotional Store',
              textAlign: TextAlign.center,
              style: AppTypography.headingStyle(
                context,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                _pillarCard(
                  context,
                  Icons.verified_outlined,
                  '100% Consecrated Pure',
                  'Every sacred item is washed with pure Ganga jal, touched with Chandan paste, and energized with Vedic protection mantras prior to dispatch.',
                  goldColor,
                ),
                const SizedBox(width: 24),
                _pillarCard(
                  context,
                  Icons.design_services_outlined,
                  'Handcrafted Masterpieces',
                  'Finely finished acrylics, solid brass pooja padukas, durable diamond cut keychains, and high-definition waterproof stickers.',
                  goldColor,
                ),
                const SizedBox(width: 24),
                _pillarCard(
                  context,
                  Icons.favorite_outline,
                  'Non Profit Seva Spirit',
                  'All offerings directly support charitable devotee outreach, spiritual literature publication, and holy temple maintenance.',
                  goldColor,
                ),
              ],
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
