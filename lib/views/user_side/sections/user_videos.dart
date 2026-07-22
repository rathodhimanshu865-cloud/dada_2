import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../controllers/language_controller.dart';

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
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          // Centered Header (Exactly as shown in image)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_fill, color: Color(0xFFCD201F), size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Videos',
                    style: TextStyle(
                      fontSize: 32, 
                      fontFamily: 'serif', 
                      color: primaryTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(width: 40, height: 2, color: accentBrown),
            ],
          ),
          
          const SizedBox(height: 60),
          
          // Centered Video Grid
          Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Wrap(
              spacing: 30,
              runSpacing: 40,
              alignment: WrapAlignment.center,
              children: controller.videos.take(4).map((video) {
                return _buildVideoShortCard(video, primaryTeal, lang);
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 60),
          
          // View All Videos Button
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/video_gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text(
              'VIEW ALL VIDEOS', 
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoShortCard(dynamic video, Color primaryTeal, String lang) {
    return GestureDetector(
      onTap: () => _launchUrl(video.youtubeUrl),
      child: Container(
        width: 250, 
        height: 450,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15), 
              blurRadius: 15, 
              offset: const Offset(0, 8)
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  video.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey[200]),
                ),
              ),
              
              // Bottom Gradient Overlay for text
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.6, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Play Icon
              const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              
              // Text Content
              Positioned(
                bottom: 25,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.localizedTitle(lang).isEmpty ? 'RADHE RADHE' : video.localizedTitle(lang).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.yellow, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'YOUTUBE SHORTS',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
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
