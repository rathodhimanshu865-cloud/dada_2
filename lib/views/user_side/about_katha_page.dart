import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';

class AboutKathaPage extends StatelessWidget {
  const AboutKathaPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    const accentBrown = Color(0xFFC19A6B);

    final controller = Provider.of<HomePageController>(context);
    final data = controller.bhagvatKathaPage;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          
          // 1. HERO SECTION
          Container(
            width: double.infinity,
            color: backgroundBeige,
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 80),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 40, height: 1.5, color: accentBrown),
                          const SizedBox(width: 15),
                          Text(
                            data.heroBadge.toUpperCase(),
                            style: const TextStyle(color: accentBrown, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Text(
                        data.heroTitle,
                        style: const TextStyle(
                          fontSize: 48,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                          color: primaryTeal,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        data.heroDesc1,
                        style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.6, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        data.heroDesc2,
                        style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 60),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15)),
                      ],
                    ),
                    child: Image.network(
                      data.heroImage.isNotEmpty ? data.heroImage : 'https://via.placeholder.com/700x450',
                      fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => Container(height: 400, color: Colors.white24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. BIOGRAPHY SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 100),
            child: Column(
              children: [
                const Icon(Icons.wb_sunny_outlined, color: accentBrown, size: 35),
                const SizedBox(height: 50),
                Text(
                  data.bioText.isNotEmpty ? data.bioText : 'Full biography details will appear here as managed from the admin side.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF333333), height: 1.9, letterSpacing: 0.3),
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
                    padding: const EdgeInsets.all(80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote, color: accentBrown, size: 60),
                        const SizedBox(height: 30),
                        Text(
                          data.quoteText,
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontFamily: 'serif', height: 1.5),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          '- ${data.quoteAuthor}',
                          style: const TextStyle(color: accentBrown, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        Container(width: 50, height: 2, color: accentBrown),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Image.network(
                    data.quoteImage.isNotEmpty ? data.quoteImage : 'https://via.placeholder.com/600x600',
                    height: 500,
                    fit: BoxFit.cover,
                    errorBuilder: (c,e,s) => Container(color: Colors.black26),
                  ),
                ),
              ],
            ),
          ),

          // 4. HIGHLIGHTS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 100),
            child: Row(
              children: [
                _buildHighlightCard(data.highlight1Title, Icons.stars_rounded, data.highlight1Desc, accentBrown),
                const SizedBox(width: 40),
                _buildHighlightCard(data.highlight2Title, Icons.auto_awesome, data.highlight2Desc, accentBrown),
                const SizedBox(width: 40),
                _buildHighlightCard(data.highlight3Title, Icons.favorite_border_rounded, data.highlight3Desc, accentBrown),
              ],
            ),
          ),

          // 5. CTA BANNER
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 100),
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 80),
            decoration: BoxDecoration(
              color: primaryTeal,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.temple_hindu_outlined, color: Colors.white54, size: 70),
                const SizedBox(width: 50),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.ctaTitle,
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'serif'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.ctaSubtitle,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/katha_list'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundBeige,
                    foregroundColor: primaryTeal,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                    elevation: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(data.ctaButtonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 15),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 120),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(String title, IconData icon, String desc, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 25, offset: const Offset(0, 12)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 40),
            const SizedBox(height: 35),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2, color: Color(0xFF222222))),
            const SizedBox(height: 25),
            Text(desc, style: const TextStyle(color: Color(0xFF666666), fontSize: 15, height: 1.7)),
            const SizedBox(height: 30),
            Container(width: 40, height: 3, color: accent.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}
