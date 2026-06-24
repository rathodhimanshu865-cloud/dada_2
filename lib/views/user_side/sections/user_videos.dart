import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/homepage_controller.dart';

class UserVideos extends StatelessWidget {
  final HomePageController controller;
  const UserVideos({super.key, required this.controller});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_fill, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text(
                'Videos',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.brown, fontFamily: 'serif'),
              ),
            ],
          ),
          const SizedBox(height: 50),
          SizedBox(
            height: 450, // Increased height for vertical Shorts look
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              itemCount: controller.videos.length,
              itemBuilder: (context, index) {
                final video = controller.videos[index];
                return GestureDetector(
                  onTap: () => _launchUrl(video.youtubeUrl),
                  child: Container(
                    width: 250, // Narrower width for vertical Shorts look
                    margin: const EdgeInsets.only(right: 25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(video.thumbnail),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                            ),
                          ),
                        ),
                        const Center(
                          child: Icon(Icons.play_circle_outline, color: Colors.white, size: 60),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 15,
                          right: 15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title, 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'YouTube Shorts', 
                                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
