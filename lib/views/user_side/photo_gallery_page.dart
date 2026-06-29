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
  int selectedSectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    final data = controller.photoGalleryData;

    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    final sections = data.sections;
    final selectedSection = sections.isNotEmpty ? sections[selectedSectionIndex] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),
            if (data.headerImageUrl.isNotEmpty)
              Image.network(
                data.headerImageUrl,
                width: double.infinity,
                height: 420,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const SizedBox.shrink(),
              ),
            const SizedBox(height: 40),
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 42,
                fontFamily: 'serif',
                color: Color(0xFF444444),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Gallery',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),
            if (sections.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Row(
                  children: sections.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final section = entry.value;
                    final isSelected = idx == selectedSectionIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedSectionIndex = idx),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              section.heading.isEmpty ? 'Heading ${idx + 1}' : section.heading,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 40),
            if (selectedSection != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: _buildSection(context, selectedSection),
              ),
            const SizedBox(height: 80),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, dynamic section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.heading.toUpperCase(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: section.photoUrls.map<Widget>((url) {
            return _buildPhotoCard(url);
          }).toList(),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildPhotoCard(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 48)),
          ),
        ),
      ),
    );
  }
}
