import 'package:flutter/material.dart';
import '../../../utils/app_typography.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../controllers/language_controller.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../utils/responsive_utils.dart';
import 'package:provider/provider.dart';

class UserAboutPreview extends StatelessWidget {
  final HomePageController controller;
  const UserAboutPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final String lang = Provider.of<LanguageController>(context).locale.languageCode;
    final about = controller.aboutSection;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 120, horizontal: isMobile ? 20 : 40),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(builder: (context, constraints) {
            Widget leftContent = Column(
              crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.discoverTheJourney,
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: const TextStyle(color: Color(0xFFC89A5B), letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 25),
                Text(
                  about.localizedTitle(lang),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: AppTypography.headingStyle(
                    context,
                    fontSize: isMobile ? 32 : 48,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F4C5C),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  about.localizedTagline(lang),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: TextStyle(fontSize: isMobile ? 18 : 20, color: const Color(0xFFC89A5B), fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 40),
                Text(
                  about.localizedDescription(lang),
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                  style: TextStyle(fontSize: isMobile ? 16 : 18, height: 1.8, color: const Color(0xFF2B2B2B), letterSpacing: 0.2),
                ),
                const SizedBox(height: 50),
                Center(
                  child: isMobile ? ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/about_dada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4C5C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(AppLocalizations.of(context)!.readFullBiography, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ) : Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/about_dada'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C5C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text(AppLocalizations.of(context)!.readFullBiography, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ),
                ),
              ],
            );

            Widget rightImage = Stack(
              alignment: Alignment.center,
              children: [
                // Decorative Background Shape
                if (!isMobile) Transform.translate(
                  offset: const Offset(30, 30),
                  child: Container(
                    width: 400, height: 500,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFC89A5B).withOpacity(0.2), width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                
                // Main Photo
                Container(
                  width: isMobile ? context.screenWidth * 0.85 : 400, 
                  height: isMobile ? context.screenWidth * 0.85 * 1.25 : 500,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EEE6),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20)),
                    ],
                  ),
                  child: ClipRRect(
                    child: about.photoUrl.isNotEmpty
                        ? Image.network(about.photoUrl, fit: BoxFit.cover)
                        : const Icon(Icons.person, size: 100, color: Colors.white),
                  ),
                ),
              ],
            );

            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
