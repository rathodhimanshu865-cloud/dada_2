import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/homepage_controller.dart';
import 'sections/user_header.dart';
import 'sections/user_footer.dart';

class StotraPage extends StatelessWidget {
  const StotraPage({super.key});

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
    final section = controller.stotraSection;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.black)));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),
            
            // Top Header Image
            if (section.topHeaderImage.isNotEmpty)
              Image.network(
                section.topHeaderImage, 
                width: double.infinity, 
                height: 400, 
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const SizedBox.shrink(),
              ),

            const SizedBox(height: 60),

            // Page Title
            Text(
              section.pageTitle,
              style: const TextStyle(fontSize: 32, fontFamily: 'serif', color: Color(0xFF444444)),
            ),
            const SizedBox(height: 10),
            const Text('Home > Stotra / Bhajan / Aarti', style: TextStyle(color: Colors.grey, fontSize: 12)),

            const SizedBox(height: 60),

            // List of Stotras
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Column(
                children: [
                  const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                  ...section.items.asMap().entries.map((entry) {
                    int index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              // Numbered Circle (Brown as per photo)
                              Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC19A6B),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              
                              // Stotra Name
                              Expanded(
                                flex: 4,
                                child: Text(
                                  item.title,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF444444), fontFamily: 'serif'),
                                ),
                              ),

                              const VerticalDivider(width: 40),

                              // English PDF
                              _pdfLink('English', item.englishPdfUrl),
                              
                              const VerticalDivider(width: 40),

                              // Hindi PDF
                              _pdfLink('Hindi', item.hindiPdfUrl),

                              const VerticalDivider(width: 40),

                              // Gujarati PDF
                              _pdfLink('Gujarati', item.gujaratiPdfUrl),

                              // NO AUDIO COLUMN AS PER REQUEST
                            ],
                          ),
                        ),
                        const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 100),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _pdfLink(String label, String url) {
    return Expanded(
      flex: 2,
      child: InkWell(
        onTap: () => _launchUrl(url),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf_outlined, size: 20, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              label, 
              style: const TextStyle(fontSize: 13, color: Color(0xFF444444), fontWeight: FontWeight.w400)
            ),
          ],
        ),
      ),
    );
  }
}
