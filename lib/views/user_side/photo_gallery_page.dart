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

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          
          // Hero Title Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 80),
            color: backgroundBeige.withOpacity(0.5),
            child: Column(
              children: [
                Text(data.localizedTitle(lang).isNotEmpty ? data.localizedTitle(lang) : 'Photo Gallery', style: const TextStyle(fontSize: 52, fontFamily: 'serif', color: primaryTeal, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.homeGalleryPhotos, style: TextStyle(color: primaryTeal.withOpacity(0.6), fontSize: 16, letterSpacing: 0.5)),
              ],
            ),
          ),

          const SizedBox(height: 60),

          // Section Switcher (Tabs)
          if (data.sections.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
    if (section.photoUrls.isEmpty) {
      return Padding(padding: const EdgeInsets.symmetric(vertical: 100), child: Text(AppLocalizations.of(context)!.noPhotosAdded, style: const TextStyle(color: Colors.grey, fontSize: 18)));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: LayoutBuilder(builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : 2);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, crossAxisSpacing: 30, mainAxisSpacing: 30, childAspectRatio: 1.2),
              itemCount: section.photoUrls.length,
              itemBuilder: (context, index) => _buildPhotoCard(context, section.photoUrls[index]),
            );
          }),
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildPhotoCard(BuildContext context, String url) {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _showFullScreenImage(context, url),
          child: Image.network(url, fit: BoxFit.contain, errorBuilder: (c, e, s) => Container(color: Colors.grey[100], child: const Icon(Icons.broken_image_outlined, color: Colors.grey))),
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
