import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class PhotoGalleryPage extends StatefulWidget {
  const PhotoGalleryPage({super.key});

  @override
  State<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  int activeSectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    const accentBrown = Color(0xFFC19A6B);
    
    final controller = Provider.of<HomePageController>(context);
    final data = controller.photoGalleryData;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    final isMobile = MediaQuery.of(context).size.width < 900;

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          
          // Hero Title Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80),
            color: backgroundBeige.withOpacity(0.5),
            child: Column(
              children: [
                Text(data.localizedTitle(lang).isNotEmpty ? data.localizedTitle(lang) : 'Photo Gallery', style: TextStyle(fontSize: isMobile ? 32 : 52, fontFamily: 'serif', color: primaryTeal, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.homeGalleryPhotos, style: TextStyle(color: primaryTeal.withOpacity(0.6), fontSize: isMobile ? 14 : 16, letterSpacing: 0.5)),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 30 : 60),

          // Section Switcher (Tabs)
          if (data.sections.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: isMobile ? 10 : 20,
                runSpacing: 15,
                children: data.sections.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String heading = entry.value.localizedHeading(lang);
                  bool isActive = activeSectionIndex == idx;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      onTap: () => setState(() => activeSectionIndex = idx),
                      hoverColor: Colors.transparent,
                      child: Column(
                        children: [
                          Text(heading.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? primaryTeal : Colors.black45, letterSpacing: 1.5)),
                          const SizedBox(height: 10),
                          AnimatedContainer(duration: const Duration(milliseconds: 300), height: 4, width: isActive ? 60 : 0, color: primaryTeal),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 80),

          if (data.sections.isNotEmpty && activeSectionIndex < data.sections.length)
            _buildPhotoSection(context, data.sections[activeSectionIndex], primaryTeal, accentBrown),

          const SizedBox(height: 100),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context, dynamic section, Color primaryTeal, Color accentBrown) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    if (section.photoUrls.isEmpty) {
      return Padding(padding: const EdgeInsets.symmetric(vertical: 100), child: Text(AppLocalizations.of(context)!.noPhotosAdded, style: const TextStyle(color: Colors.grey, fontSize: 18)));
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100),
          child: LayoutBuilder(builder: (context, constraints) {
            int cols = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1));
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(cols, (colIdx) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: colIdx < cols - 1 ? (isMobile ? 15 : 30) : 0),
                    child: Column(
                      children: section.photoUrls.asMap().entries
                          .where((e) => e.key % cols == colIdx)
                          .map((e) => _buildPhotoCard(context, e.value, isMobile))
                          .toList(),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
        SizedBox(height: isMobile ? 50 : 120),
      ],
    );
  }

  Widget _buildPhotoCard(BuildContext context, String url, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 15 : 30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () => _showFullScreenImage(context, url),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => Container(color: Colors.grey[100], child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 50)),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(40),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url, fit: BoxFit.contain))),
            IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 40), onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
