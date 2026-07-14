import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';

class UserNews extends StatelessWidget {
  final HomePageController controller;
  const UserNews({super.key, required this.controller});

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final news = controller.homepageData.news;
    if (news.isEmpty) return const SizedBox.shrink();

    // Only show 4-5 pictures (limiting to 4 for balanced grid)
    final displayNews = news.take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
      color: const Color(0xFFFAF8F4),
      child: Column(
        children: [
          // Header
          Column(
            children: [
              const Text(
                "LATEST UPDATES",
                style: TextStyle(color: Color(0xFFC89A5B), letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 20),
              const Text(
                "News & Events",
                style: TextStyle(fontSize: 42, fontFamily: 'serif', fontWeight: FontWeight.w900, color: Color(0xFF0F4C5C)),
              ),
              const SizedBox(height: 30),
              Container(height: 1, width: 80, color: const Color(0xFFC89A5B)),
            ],
          ),
          
          const SizedBox(height: 80),

          // News Grid (Showing only limited items)
          Container(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: LayoutBuilder(builder: (context, constraints) {
              int cols = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 700 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 40,
                  childAspectRatio: 0.8,
                ),
                itemCount: displayNews.length,
                itemBuilder: (context, index) => _buildNewsCard(context, displayNews[index]),
              );
            }),
          ),

          const SizedBox(height: 60),

          // Redirect button to dedicated News Page
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/news'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4C5C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('VIEW ALL NEWS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ],
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
                borderRadius: BorderRadius.circular(12),
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

  Widget _buildNewsCard(BuildContext context, NewsItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showFullScreenImage(context, item.image),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEE6),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.image.isNotEmpty 
                  ? Image.network(item.image, fit: BoxFit.cover)
                  : const Icon(Icons.newspaper_rounded, size: 50, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        GestureDetector(
          onTap: () => _launchUrl(item.url),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.category.toUpperCase(),
                style: const TextStyle(color: Color(0xFFC89A5B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), fontFamily: 'serif'),
              ),
              const SizedBox(height: 10),
              Text(
                item.date,
                style: const TextStyle(color: Color(0xFF6D6D6D), fontSize: 13, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
