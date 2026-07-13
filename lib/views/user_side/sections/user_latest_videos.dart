import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/homepage_controller.dart';

class UserLatestVideos extends StatelessWidget {
  final HomePageController controller;
  const UserLatestVideos({super.key, required this.controller});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.videos.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Column(
            children: [
              const Text(
                "WATCH & REFLECT",
                style: TextStyle(color: Color(0xFFC89A5B), letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 20),
              const Text(
                "Latest Videos",
                style: TextStyle(fontSize: 42, fontFamily: 'serif', fontWeight: FontWeight.w900, color: Color(0xFF0F4C5C)),
              ),
              const SizedBox(height: 30),
              Container(height: 1, width: 80, color: const Color(0xFFC89A5B)),
            ],
          ),
          
          const SizedBox(height: 80),

          // Refined Video Grid
          Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 40,
                  childAspectRatio: 1.2,
                ),
                itemCount: controller.videos.take(6).length,
                itemBuilder: (context, index) => _buildVideoCard(controller.videos[index]),
              );
            }),
          ),
          
          const SizedBox(height: 80),
          
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/video_gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4C5C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('VIEW ALL VIDEOS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(dynamic video) {
    return GestureDetector(
      onTap: () => _launchUrl(video.youtubeUrl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      video.thumbnail,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    // Glassy play button
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, size: 30, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            video.title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          const Text(
            "YOUTUBE DISCOURSE",
            style: TextStyle(color: Color(0xFFC89A5B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
