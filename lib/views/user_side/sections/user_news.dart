import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';

class UserNews extends StatelessWidget {
  final HomePageController controller;
  const UserNews({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final news = controller.homepageData.news;
    if (news.isEmpty) return const SizedBox.shrink();

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

          // News Grid
          Container(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: LayoutBuilder(builder: (context, constraints) {
              int cols = constraints.maxWidth > 1100 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 50,
                  childAspectRatio: 0.9,
                ),
                itemCount: news.length,
                itemBuilder: (context, index) => _buildNewsCard(news[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(NewsItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EEE6),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: item.image.isNotEmpty 
              ? Image.network(item.image, fit: BoxFit.cover)
              : const Icon(Icons.newspaper_rounded, size: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 25),
        Text(
          item.category.toUpperCase(),
          style: const TextStyle(color: Color(0xFFC89A5B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 15),
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), fontFamily: 'serif', height: 1.3),
        ),
        const SizedBox(height: 15),
        Text(
          item.date,
          style: const TextStyle(color: Color(0xFF6D6D6D), fontSize: 14, fontWeight: FontWeight.w300),
        ),
      ],
    );
  }
}
