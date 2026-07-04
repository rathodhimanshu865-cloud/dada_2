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
                            const Text(
                              'ABOUT KATHA &',
                              style: TextStyle(color: accentBrown, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'PU. JIGNESH DADA\n(RADHE RADHE)',
                          style: TextStyle(
                            fontSize: 42,
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'A divine journey of knowledge, devotion\nand self-realization through\nShrimad Bhagwat Katha.',
                          style: TextStyle(fontSize: 18, color: Colors.black54, height: 1.5, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Image.network(
                      data.topHeaderImage.isNotEmpty ? data.topHeaderImage : 'https://via.placeholder.com/600x400',
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
                    data.midSectionPara1.isNotEmpty ? data.midSectionPara1 : 'Shrimad Bhagwat Katha is one of the most sacred scriptures in Hinduism...',
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
                          const Text(
                            'Bhagwat Katha is not just a narration, it is a life transformation. It connects the soul with the supreme through the path of devotion.',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'serif', height: 1.4),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            '- Jignesh Dada',
                            style: TextStyle(color: accentBrown, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Container(width: 40, height: 1, color: accentBrown),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Image.network(
                      data.midSectionImage.isNotEmpty ? data.midSectionImage : 'https://via.placeholder.com/600x400',
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
                  _buildPillarCard('OUR KATHA', Icons.menu_book, 'Shrimad Bhagwat Katha is a timeless treasure that enlightens the heart...', accentBrown),
                  const SizedBox(width: 30),
                  _buildPillarCard('OUR MISSION', Icons.volunteer_activism, 'To spread the divine wisdom of Bhagwat through Katha, inspire devotion...', accentBrown),
                  const SizedBox(width: 30),
                  _buildPillarCard('OUR VISION', Icons.public, 'A world filled with love, peace, compassion and righteousness where every soul...', accentBrown),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join us in this Divine Journey',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Listen, reflect and experience the nectar of Bhagwat Katha. Let devotion lead your life towards peace and purpose.',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('EXPLORE KATHA', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 10),
                        Icon(Icons.chevron_right, size: 18),
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
