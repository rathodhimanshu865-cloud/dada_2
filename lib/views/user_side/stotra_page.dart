import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class StotraPage extends StatelessWidget {
  const StotraPage({super.key});

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    final controller = Provider.of<HomePageController>(context);
    final section = controller.stotraSection;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 80),
            color: backgroundBeige.withOpacity(0.5),
            child: Column(
              children: [
                Text(section.localizedPageTitle(lang), style: const TextStyle(fontSize: 52, fontFamily: 'serif', color: primaryTeal, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.homeStotra, style: TextStyle(color: primaryTeal.withOpacity(0.6), fontSize: 16, letterSpacing: 0.5)),
              ],
            ),
          ),
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                  decoration: BoxDecoration(color: primaryTeal.withOpacity(0.04), border: Border(bottom: BorderSide(color: primaryTeal.withOpacity(0.15), width: 2))),
                  child: Row(children: [_colHeader(AppLocalizations.of(context)!.idColumn, flex: 1), _colHeader(AppLocalizations.of(context)!.nameTitle, flex: 5), _colHeader(AppLocalizations.of(context)!.englishCol, flex: 2, center: true), _colHeader(AppLocalizations.of(context)!.hindiCol, flex: 2, center: true), _colHeader(AppLocalizations.of(context)!.gujaratiCol, flex: 2, center: true)]),
                ),
                ...section.items.asMap().entries.map((entry) {
                  int index = entry.key;
                  final item = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: _circleId('${index + 1}', primaryTeal)),
                        Expanded(flex: 5, child: Text(item.localizedTitle(lang).toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF444444), letterSpacing: 0.5))),
                        _pdfLink(AppLocalizations.of(context)!.download, item.englishPdfUrl, primaryTeal, flex: 2),
                        _pdfLink(AppLocalizations.of(context)!.download, item.hindiPdfUrl, primaryTeal, flex: 2),
                        _pdfLink(AppLocalizations.of(context)!.download, item.gujaratiPdfUrl, primaryTeal, flex: 2),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 120),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _pdfLink(String label, String url, Color color, {required int flex}) {
    bool hasUrl = url.isNotEmpty;
    return Expanded(
      flex: flex,
      child: Center(
        child: InkWell(
          onTap: hasUrl ? () => _launchUrl(url) : null,
          child: Opacity(
            opacity: hasUrl ? 1.0 : 0.2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.picture_as_pdf_outlined, size: 24, color: color),
                const SizedBox(width: 10),
                Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF444444), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _colHeader(String title, {required int flex, bool center = false}) {
    const primaryTeal = Color(0xFF0F4C5C);
    return Expanded(flex: flex, child: Text(title, textAlign: center ? TextAlign.center : TextAlign.start, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryTeal.withOpacity(0.7), letterSpacing: 1.5)));
  }

  Widget _circleId(String id, Color color) {
    return Container(width: 40, height: 40, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 3))]), child: Center(child: Text(id, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))));
  }
}
