import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import 'sections/user_header.dart';
import 'sections/user_footer.dart';

class PhotoGalleryPage extends StatelessWidget {
  const PhotoGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
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
            
            // Header Image
            if (data.headerImageUrl.isNotEmpty)
              Image.network(
                data.headerImageUrl, 
                width: double.infinity, 
                height: 450, 
                fit: BoxFit.cover,
                errorBuilder: (c,e,s) => const SizedBox.shrink(),
              ),

            const SizedBox(height: 60),

            // Page Title
            Text(
              data.title.isNotEmpty ? data.title : 'Photos',
              style: TextStyle(fontSize: 42, fontFamily: 'serif', color: primaryTeal, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Home > Gallery > Photos', style: TextStyle(color: Colors.grey, fontSize: 12)),

            const SizedBox(height: 80),

            // Galleries
            ...data.sections.map((section) => _buildPhotoGrid(section, primaryTeal)).toList(),

            const SizedBox(height: 100),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(dynamic section, Color primaryTeal) {
    return Column(
      children: [
        Text(
          section.heading.toUpperCase(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal, letterSpacing: 1),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.5,
            ),
            itemCount: section.photoUrls.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  section.photoUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
