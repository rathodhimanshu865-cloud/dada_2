import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/homepage_controller.dart';

class UserVideos extends StatelessWidget {
  final HomePageController controller;
  const UserVideos({super.key, required this.controller});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const accentBrown = Color(0xFFC19A6B);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 60),
      child: Column(
        children: [
          // Centered Header (Matches Upcoming Kathas style)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_fill, color: Color(0xFFCD201F), size: 32),
                  const SizedBox(width: 15),
                  Text(
                    'Videos',
                    style: TextStyle(
                      fontSize: 36, 
                      fontFamily: 'serif', 
                      color: primaryTeal,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(width: 60, height: 3, color: accentBrown),
            ],
          ),
          
          const SizedBox(height: 80),
          
          // Centered Video Grid (Using Wrap for perfect alignment)
          Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Wrap(
              spacing: 30,
              runSpacing: 40,
              alignment: WrapAlignment.center,
              children: controller.videos.take(4).map((video) {
                return _buildVideoShortCard(video, primaryTeal);
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 80),
          
          // Main Action Button
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/video_gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 5,
            ),
            child: const Text(
              'VIEW ALL VIDEOS', 
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoShortCard(dynamic video, Color primaryTeal) {
    return GestureDetector(
      onTap: () => _launchUrl(video.youtubeUrl),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 250, // Perfect for Shorts/Vertical look
          height: 450,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15), 
                blurRadius: 25, 
                offset: const Offset(0, 10)
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(video.thumbnail),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // Bottom Gradient Overlay for text readability
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              
              // Play Icon Overlay
              const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 70,
                ),
              ),
              
              // Video Info
              Positioned(
                bottom: 25,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.yellow, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'YOUTUBE SHORTS',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
