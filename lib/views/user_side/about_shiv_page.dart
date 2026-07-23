import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';

class AboutShivPage extends StatelessWidget {
  const AboutShivPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    const accentBrown = Color(0xFFC19A6B);

    final controller = Provider.of<HomePageController>(context);
    final data = controller.shivKathaPage;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    final isMobile = MediaQuery.of(context).size.width < 900;
    final horizontalPad = isMobile ? 20.0 : 100.0;

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          
          // 1. HERO SECTION
          Container(
            width: double.infinity,
            color: backgroundBeige,
            padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: isMobile ? 40 : 80),
            child: Builder(builder: (context) {
              Widget heroText = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 40, height: 1.5, color: accentBrown),
                      const SizedBox(width: 15),
                      Text(
                        data.localizedHeroBadge(lang).toUpperCase(),
                        style: const TextStyle(color: accentBrown, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    data.localizedHeroTitle(lang),
                    style: TextStyle(fontSize: isMobile ? 30 : 48, fontFamily: 'serif', fontWeight: FontWeight.bold, color: primaryTeal, height: 1.2, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    data.localizedHeroDesc1(lang),
                    style: TextStyle(fontSize: isMobile ? 15 : 18, color: Colors.black87, height: 1.6, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    data.localizedHeroDesc2(lang),
                    style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.black54, height: 1.6),
                  ),
                ],
              );

              Widget heroImg = Container(
                decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))]),
                child: Image.network(data.heroImage.isNotEmpty ? data.heroImage : 'https://via.placeholder.com/700x450', fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(height: 250, color: Colors.white24)),
              );

              if (isMobile) {
                return Column(
                  children: [
                    heroText,
                    const SizedBox(height: 40),
                    heroImg,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 1, child: heroText),
                  const SizedBox(width: 60),
                  Expanded(flex: 1, child: heroImg),
                ],
              );
            }),
          ),

          // 2. BIOGRAPHY SECTION
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 150, vertical: isMobile ? 50 : 100),
            child: Column(
              children: [
                const Icon(Icons.wb_sunny_outlined, color: accentBrown, size: 35),
                const SizedBox(height: 50),
                Text(
                  data.localizedBioText(lang).isNotEmpty ? data.localizedBioText(lang) : 'Full biography details will appear here as managed from the admin side.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isMobile ? 14 : 16, color: const Color(0xFF333333), height: 1.9, letterSpacing: 0.3),
                ),
              ],
            ),
          ),

          // 3. QUOTE SECTION
          Container(
            margin: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100),
            decoration: BoxDecoration(color: primaryTeal, borderRadius: BorderRadius.circular(4)),
            clipBehavior: Clip.antiAlias,
            child: Builder(builder: (context) {
              Widget quoteText = Padding(
                padding: EdgeInsets.all(isMobile ? 30 : 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote, color: accentBrown, size: 60),
                    const SizedBox(height: 30),
                    Text(data.localizedQuoteText(lang), style: TextStyle(color: Colors.white, fontSize: isMobile ? 18 : 26, fontFamily: 'serif', height: 1.5)),
                    const SizedBox(height: 40),
                    Text('- ${data.localizedQuoteAuthor(lang)}', style: TextStyle(color: accentBrown, fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Container(width: 50, height: 2, color: accentBrown),
                  ],
                ),
              );

              Widget quoteImg = Image.network(data.quoteImage.isNotEmpty ? data.quoteImage : 'https://via.placeholder.com/600x600', height: isMobile ? 250 : 500, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.black26));

              if (isMobile) {
                return Column(
                  children: [
                    quoteText,
                    quoteImg,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: quoteText),
                  Expanded(child: quoteImg),
                ],
              );
            }),
          ),

          // 4. HIGHLIGHTS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100, vertical: isMobile ? 50 : 100),
            child: isMobile 
              ? Column(
                  children: [
                    _buildHighlightCard(data.localizedHighlight1Title(lang), Icons.stars_rounded, data.localizedHighlight1Desc(lang), accentBrown),
                    const SizedBox(height: 25),
                    _buildHighlightCard(data.localizedHighlight2Title(lang), Icons.auto_awesome, data.localizedHighlight2Desc(lang), accentBrown),
                    const SizedBox(height: 25),
                    _buildHighlightCard(data.localizedHighlight3Title(lang), Icons.favorite_border_rounded, data.localizedHighlight3Desc(lang), accentBrown),
                  ],
                )
              : Row(
                  children: [
                    _buildHighlightCard(data.localizedHighlight1Title(lang), Icons.stars_rounded, data.localizedHighlight1Desc(lang), accentBrown),
                    const SizedBox(width: 40),
                    _buildHighlightCard(data.localizedHighlight2Title(lang), Icons.auto_awesome, data.localizedHighlight2Desc(lang), accentBrown),
                    const SizedBox(width: 40),
                    _buildHighlightCard(data.localizedHighlight3Title(lang), Icons.favorite_border_rounded, data.localizedHighlight3Desc(lang), accentBrown),
                  ],
                ),
          ),

          // 5. CTA BANNER
          Container(
            margin: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100),
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: isMobile ? 20 : 80),
            decoration: BoxDecoration(color: primaryTeal, borderRadius: BorderRadius.circular(4)),
            child: isMobile
              ? Column(
                  children: [
                    const Icon(Icons.temple_hindu_outlined, color: Colors.white54, size: 50),
                    const SizedBox(height: 20),
                    Text(data.localizedCtaTitle(lang), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                    const SizedBox(height: 10),
                    Text(data.localizedCtaSubtitle(lang), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/katha_list'),
                      style: ElevatedButton.styleFrom(backgroundColor: backgroundBeige, foregroundColor: primaryTeal, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), elevation: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(data.localizedCtaButtonText(lang), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Icon(Icons.temple_hindu_outlined, color: Colors.white54, size: 70),
                    const SizedBox(width: 50),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.localizedCtaTitle(lang), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                          const SizedBox(height: 12),
                          Text(data.localizedCtaSubtitle(lang), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/katha_list'),
                      style: ElevatedButton.styleFrom(backgroundColor: backgroundBeige, foregroundColor: primaryTeal, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25), elevation: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(data.localizedCtaButtonText(lang), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 25, offset: const Offset(0, 12))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 40),
          const SizedBox(height: 25),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2, color: Color(0xFF222222))),
          const SizedBox(height: 15),
          Text(desc, style: const TextStyle(color: Color(0xFF666666), fontSize: 15, height: 1.7)),
          const SizedBox(height: 20),
          Container(width: 40, height: 3, color: accent.withOpacity(0.4)),
        ],
      ),
    );
  }
}
