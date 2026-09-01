import 'package:flutter/material.dart';
import '../../../utils/app_typography.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../controllers/homepage_controller.dart';

class UserRamKatha extends StatelessWidget {
  final HomePageController controller;
  const UserRamKatha({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFFAF8F4);
    const accentGold = Color(0xFFC89A5B);
    final kathaData = controller.ramKatha;
    final lang = Localizations.localeOf(context).languageCode;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;

    return Container(
      width: double.infinity,
      color: backgroundBeige,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 120, horizontal: isMobile ? 20 : 40),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Builder(builder: (context) {
            Widget leftContent = Column(
              crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.divineDiscourses,
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: const TextStyle(color: accentGold, letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 25),
                Text(
                  AppLocalizations.of(context)!.shreemadBhagwatKatha,
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: AppTypography.headingStyle(
                    context,
                    fontSize: isMobile ? 32 : 48,
                    fontWeight: FontWeight.w900,
                    color: primaryTeal,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  kathaData.localizedDescription1(lang),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: TextStyle(fontSize: isMobile ? 16 : 18, height: 1.8, color: const Color(0xFF2B2B2B), letterSpacing: 0.2),
                ),
                if (kathaData.description2.isNotEmpty) ...[
                  const SizedBox(height: 25),
                  Text(
                    kathaData.localizedDescription2(lang),
                    textAlign: isMobile ? TextAlign.center : TextAlign.start,
                    style: const TextStyle(fontSize: 16, height: 1.7, color: Color(0xFF6D6D6D)),
                  ),
                ],
                const SizedBox(height: 50),
                Center(
                  child: isMobile ? ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/about_katha'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(AppLocalizations.of(context)!.exploreKathaJourney, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ) : Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/about_katha'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text(AppLocalizations.of(context)!.exploreKathaJourney, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ),
                ),
              ],
            );

            Widget rightImage = Container(
              height: isMobile ? 300 : 500,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 40, offset: const Offset(0, 20)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: kathaData.photoUrl.isNotEmpty
                    ? Image.network(kathaData.photoUrl, fit: BoxFit.cover)
                    : const Icon(Icons.temple_hindu_outlined, size: 80, color: Color(0xFFEEEEEE)),
              ),
            );

            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  leftContent,
                  const SizedBox(height: 60),
                  rightImage,
                ],
              );
            } else {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 6, child: leftContent),
                  const SizedBox(width: 80),
                  Expanded(flex: 5, child: rightImage),
                ],
              );
            }
          }),
        ),
      ),
    );
  }
}
