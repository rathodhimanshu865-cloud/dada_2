import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
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

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    const accentBrown = Color(0xFFC19A6B);

    final controller = Provider.of<HomePageController>(context);
    final newsList = controller.homepageData.news;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          
          // Hero Title Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 80),
            color: backgroundBeige.withOpacity(0.5),
            child: Column(
              children: [
                const Text(
                  'Latest News',
                  style: TextStyle(fontSize: 52, fontFamily: 'serif', color: primaryTeal, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('Home > News', style: TextStyle(color: primaryTeal.withOpacity(0.6), fontSize: 16, letterSpacing: 0.5)),
              ],
            ),
          ),

          const SizedBox(height: 80),

          // News Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: LayoutBuilder(builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 50,
                  childAspectRatio: 0.85,
                ),
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  return _buildNewsCard(context, newsList[index], accentBrown, primaryTeal, lang);
                },
              );
            }),
          ),

          const SizedBox(height: 120),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, NewsItem item, Color accentGold, Color primaryTeal, String lang) {
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
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.image.isNotEmpty 
                  ? Image.network(item.image, fit: BoxFit.cover)
                  : const Icon(Icons.newspaper_rounded, size: 50, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Text(
          item.localizedCategory(lang).toUpperCase(),
          style: TextStyle(color: accentGold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 15),
        Text(
          item.localizedTitle(lang),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), fontFamily: 'serif', height: 1.3),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.date,
              style: const TextStyle(color: Color(0xFF6D6D6D), fontSize: 14, fontWeight: FontWeight.w300),
            ),
            if (item.url.isNotEmpty)
              TextButton(
                onPressed: () => _launchUrl(item.url),
                child: Text("READ MORE", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
          ],
        ),
      ],
    );
  }
}
