import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import 'sections/user_header.dart';
import 'sections/user_footer.dart';

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

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),
            
            // Hero Title Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 80),
              color: backgroundBeige.withOpacity(0.5),
              child: Column(
                children: [
                  Text(
                    data.title.isNotEmpty ? data.title : 'Photo Gallery',
                    style: const TextStyle(fontSize: 52, fontFamily: 'serif', color: primaryTeal, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Home > Gallery > Photos', style: TextStyle(color: primaryTeal.withOpacity(0.6), fontSize: 16, letterSpacing: 0.5)),
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
                    String heading = entry.value.heading;
                    bool isActive = activeSectionIndex == idx;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        onTap: () => setState(() => activeSectionIndex = idx),
                        hoverColor: Colors.transparent,
                        child: Column(
                          children: [
                            Text(
                              heading.toUpperCase(),
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                color: isActive ? primaryTeal : Colors.black45,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 4, 
                              width: isActive ? 60 : 0, 
                              color: primaryTeal,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 80),

            // Content of Active Section
            if (data.sections.isNotEmpty && activeSectionIndex < data.sections.length)
              _buildPhotoSection(context, data.sections[activeSectionIndex], primaryTeal, accentBrown),

            const SizedBox(height: 100),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context, dynamic section, Color primaryTeal, Color accentBrown) {
    if (section.photoUrls.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Text('No photos added to this section yet.', style: TextStyle(color: Colors.grey, fontSize: 18)),
      );
    }

    return Column(
      children: [
        // Responsive Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: LayoutBuilder(builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : 2);
            
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                childAspectRatio: 1.2,
              ),
              itemCount: section.photoUrls.length,
              itemBuilder: (context, index) {
                return _buildPhotoCard(context, section.photoUrls[index]);
              },
            );
          }),
        ),
        
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildPhotoCard(BuildContext context, String url) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _showFullScreenImage(context, url),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(color: Colors.grey[50], child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
            },
            errorBuilder: (c, e, s) => Container(
              color: Colors.grey[100],
              child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
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
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 40),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
