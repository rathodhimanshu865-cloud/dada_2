import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/homepage_controller.dart';
import 'sections/user_header.dart';
import 'sections/user_footer.dart';

class VideoGalleryPage extends StatelessWidget {
  const VideoGalleryPage({super.key});

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
    const accentBrown = Color(0xFFC19A6B);

    final controller = Provider.of<HomePageController>(context);
    final data = controller.videoGalleryData;

    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryTeal)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),

            // Hero Title Section (Matches Photo Gallery style)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 80),
              color: backgroundBeige.withOpacity(0.5),
              child: Column(
                children: [
                  const Text(
                    'Video Gallery',
                    style: TextStyle(fontSize: 52, fontFamily: 'serif', color: primaryTeal, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Home > Gallery > Videos', style: TextStyle(color: primaryTeal.withOpacity(0.6), fontSize: 16, letterSpacing: 0.5)),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // Categories and Video Grids
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Column(
                children: data.categories
                    .map((category) => _buildVideoSection(context, category, primaryTeal, accentBrown))
                    .toList(),
              ),
            ),

            const SizedBox(height: 100),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection(BuildContext context, dynamic category, Color primaryTeal, Color accentBrown) {
    if (category.videos.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Category Heading
        Column(
          children: [
            Text(
              category.categoryTitle.toUpperCase(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF444444), letterSpacing: 2),
            ),
            const SizedBox(height: 15),
            Container(width: 60, height: 3, color: accentBrown),
          ],
        ),
        
        const SizedBox(height: 60),

        // Multi-row Grid for Videos (Not horizontal scroll for better organization)
        LayoutBuilder(builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
          
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 30,
              mainAxisSpacing: 50,
              childAspectRatio: 1.1,
            ),
            itemCount: category.videos.length,
            itemBuilder: (context, index) {
              return _buildVideoCard(category.videos[index], primaryTeal);
            },
          );
        }),
        
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildVideoCard(dynamic video, Color primaryTeal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _launchUrl(video.youtubeUrl),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      video.thumbnail,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: Colors.grey[200], height: 220),
                    ),
                    Container(height: 220, color: Colors.black.withOpacity(0.15)),
                    const Icon(Icons.play_circle_outline, color: Colors.white, size: 60),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Text(
          video.title.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF444444), height: 1.4, letterSpacing: 0.5),
        ),
      ],
    );
  }
}
