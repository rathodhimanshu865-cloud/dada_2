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
    final controller = Provider.of<HomePageController>(context);
    final data = controller.videoGalleryData;

    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),

            // Header Image (exactly like photo)
            if (data.headerImageUrl.isNotEmpty)
              Image.network(
                data.headerImageUrl,
                width: double.infinity,
                height: 450,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const SizedBox.shrink(),
              ),

            const SizedBox(height: 60),

            // Page Title
            const Text(
              'Videos',
              style: TextStyle(
                fontSize: 42,
                fontFamily: 'serif',
                color: Color(0xFF444444),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Home > Gallery > Videos',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const SizedBox(height: 80),

            // Categories and Videos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Column(
                children: data.categories
                    .map((category) => _buildCategorySection(context, category))
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

  Widget _buildCategorySection(BuildContext context, dynamic category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.categoryTitle.toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF444444),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 25),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: category.videos.length,
            itemBuilder: (context, index) {
              final video = category.videos[index];
              return _buildVideoCard(video);
            },
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildVideoCard(dynamic video) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _launchUrl(video.youtubeUrl),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      video.thumbnail,
                      height: 160,
                      width: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Container(color: Colors.grey[200], height: 160),
                    ),
                    Container(
                      height: 160,
                      width: 280,
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                    const Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            video.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
