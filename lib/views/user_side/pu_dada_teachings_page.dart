import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import '../../utils/app_typography.dart';

class PuDadaTeachingsPage extends StatelessWidget {
  const PuDadaTeachingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF0F4C5C))));
    }

    final t = controller.homepageData.teachingsPage;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    
    final primaryTeal = const Color(0xFF0F4C5C);
    final goldAccent = const Color(0xFFC89A5B);
    final bgLight = const Color(0xFFF9F7F2);

    final bool isMobile = MediaQuery.of(context).size.width < 1100;

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          _buildHeroBanner(context, t, primaryTeal, goldAccent, lang, isMobile),
          SizedBox(height: isMobile ? 40 : 80),
          _buildDivinePurpose(context, t, primaryTeal, goldAccent, lang, isMobile),
          SizedBox(height: isMobile ? 60 : 80),
          _buildThreePillars(context, t, primaryTeal, goldAccent, lang, isMobile),
          const SizedBox(height: 60),
          _buildCTAButton(context, primaryTeal, isMobile),
          const SizedBox(height: 80),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, TeachingsPageData t, Color primaryColor, Color goldColor, String lang, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 120, horizontal: 20),
      decoration: BoxDecoration(
        color: primaryColor,
        image: t.heroImage.isNotEmpty 
          ? DecorationImage(
              image: NetworkImage(t.heroImage), 
              fit: BoxFit.cover, 
              colorFilter: ColorFilter.mode(primaryColor.withOpacity(0.8), BlendMode.multiply)
            ) 
          : null,
      ),
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
                    Text(
                      AppLocalizations.of(context)!.divineDiscourses.toUpperCase(),
                      style: const TextStyle(color: Color(0xFFC89A5B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                t.localizedHeroTitle(lang).isNotEmpty ? t.localizedHeroTitle(lang) : 'Divine Teachings of Pu. Dada',
                textAlign: TextAlign.center,
                style: AppTypography.headingStyle(context, fontSize: isMobile ? 32 : 56, fontWeight: FontWeight.bold, color: Colors.white).copyWith(height: 1.2),
              ),
              const SizedBox(height: 24),
              Text(
                t.localizedHeroSubtitle(lang).isNotEmpty ? t.localizedHeroSubtitle(lang) : 'Illuminating the path of devotion and inner peace.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyStyle(context, fontSize: isMobile ? 15 : 18, color: Colors.white.withOpacity(0.8)).copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivinePurpose(BuildContext context, TeachingsPageData t, Color primaryColor, Color goldColor, String lang, bool isMobile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Column(
                  crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.mission.toUpperCase(), style: TextStyle(color: goldColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    Text(
                      t.localizedDivinePurposeTitle(lang).isNotEmpty ? t.localizedDivinePurposeTitle(lang) : 'Our Divine Mission',
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      style: AppTypography.headingStyle(context, fontSize: isMobile ? 28 : 36, fontWeight: FontWeight.bold, color: primaryColor).copyWith(height: 1.2),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t.localizedDivinePurposeDesc1(lang).isNotEmpty ? t.localizedDivinePurposeDesc1(lang) : 'Spreading the message of love and spiritual growth.',
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      style: AppTypography.bodyStyle(context, fontSize: isMobile ? 14 : 16, color: Colors.grey.shade700).copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.localizedDivinePurposeDesc2(lang).isNotEmpty ? t.localizedDivinePurposeDesc2(lang) : 'Empowering devotees through sacred wisdom.',
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                      style: AppTypography.bodyStyle(context, fontSize: isMobile ? 14 : 16, color: Colors.grey.shade700).copyWith(height: 1.6),
                    ),
                  ],
                ),
              ),
              if (!isMobile) const SizedBox(width: 80),
              if (isMobile) const SizedBox(height: 40),
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Container(
                  height: isMobile ? 300 : 450,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(t.divinePurposeImage.isNotEmpty ? t.divinePurposeImage : 'https://via.placeholder.com/600x400'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThreePillars(BuildContext context, TeachingsPageData t, Color primaryColor, Color goldColor, String lang, bool isMobile) {
    final pillars = t.pillars;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.sacredFoundations,
                textAlign: TextAlign.center,
                style: AppTypography.headingStyle(context, fontSize: isMobile ? 26 : 36, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 40),
              if (pillars.isEmpty)
                _pillarCard(context, Icons.auto_awesome, 'Sacred Wisdom', 'Pure teachings for spiritual enlightenment.', goldColor, isMobile)
              else
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: pillars.map((p) => SizedBox(
                    width: isMobile ? double.infinity : 350,
                    child: _pillarCard(context, Icons.auto_awesome, p.localizedTitle(lang), p.localizedDescription(lang), goldColor, isMobile),
                  )).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pillarCard(BuildContext context, IconData icon, String title, String description, Color goldColor, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
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
            child: Icon(icon, color: goldColor, size: 24),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTypography.headingStyle(
              context,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F4C5C),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTypography.bodyStyle(
              context,
              fontSize: 14,
              color: Colors.grey.shade600,
            ).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context, Color primaryColor, bool isMobile) {
    return SizedBox(
      width: isMobile ? double.infinity : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/catalogue');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            AppLocalizations.of(context)!.exploreSacredProducts,
            style: AppTypography.bodyStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
