import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import 'sections/user_header.dart';
import 'sections/user_footer.dart';

class AboutKathaPage extends StatelessWidget {
  const AboutKathaPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    const accentBrown = Color(0xFFC19A6B);

    final controller = Provider.of<HomePageController>(context);
    final data = controller.aboutKathaPage;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),

            // 1. HERO SECTION
            Container(
              width: double.infinity,
              color: backgroundBeige,
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 60),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 40, height: 1, color: accentBrown),
                            const SizedBox(width: 10),
                            Text(
                              data.heroBadge.toUpperCase(),
                              style: const TextStyle(color: accentBrown, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          data.heroTitle,
                          style: const TextStyle(
                            fontSize: 42,
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          data.heroSubtitle,
                          style: const TextStyle(fontSize: 18, color: Colors.black54, height: 1.5, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Image.network(
                      data.heroImage.isNotEmpty ? data.heroImage : 'https://via.placeholder.com/600x400',
                      fit: BoxFit.contain,
                      errorBuilder: (c,e,s) => Container(height: 400, color: Colors.white24),
                    ),
                  ),
                ],
              ),
            ),

            // 2. BIOGRAPHY SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 80),
              child: Column(
                children: [
                  const Icon(Icons.wb_sunny_outlined, color: accentBrown, size: 30),
                  const SizedBox(height: 40),
                  Text(
                    data.bioText.isNotEmpty ? data.bioText : 'Biography details will appear here...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.8, letterSpacing: 0.2),
                  ),
                ],
              ),
            ),

            // 3. QUOTE SECTION
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 100),
              decoration: BoxDecoration(
                color: primaryTeal,
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.format_quote, color: accentBrown, size: 50),
                          const SizedBox(height: 20),
                          Text(
                            data.quoteText,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'serif', height: 1.4),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            '- ${data.quoteAuthor}',
                            style: const TextStyle(color: accentBrown, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Container(width: 40, height: 1, color: accentBrown),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Image.network(
                      data.quoteImage.isNotEmpty ? data.quoteImage : 'https://via.placeholder.com/600x400',
                      height: 400,
                      fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => Container(color: Colors.black26),
                    ),
                  ),
                ],
              ),
            ),

            // 4. PILLAR CARDS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 80),
              child: Row(
                children: [
                  _buildPillarCard(data.pillar1Title, Icons.menu_book, data.pillar1Desc, accentBrown),
                  const SizedBox(width: 30),
                  _buildPillarCard(data.pillar2Title, Icons.volunteer_activism, data.pillar2Desc, accentBrown),
                  const SizedBox(width: 30),
                  _buildPillarCard(data.pillar3Title, Icons.public, data.pillar3Desc, accentBrown),
                ],
              ),
            ),

            // 5. CTA BANNER
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 100),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 60),
              decoration: BoxDecoration(
                color: primaryTeal,
                borderRadius: BorderRadius.circular(4),
                image: const DecorationImage(
                  image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'), // Subtle pattern
                  opacity: 0.1,
                  repeat: ImageRepeat.repeat,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.temple_hindu_outlined, color: Colors.white54, size: 60),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.ctaTitle,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data.ctaSubtitle,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/katha_list'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundBeige,
                      foregroundColor: primaryTeal,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(data.ctaButtonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarCard(String title, IconData icon, String desc, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: accent.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: accent, size: 30),
            ),
            const SizedBox(height: 30),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1, color: Color(0xFF444444))),
            const SizedBox(height: 20),
            Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.6)),
            const SizedBox(height: 20),
            Container(width: 40, height: 2, color: accent.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
