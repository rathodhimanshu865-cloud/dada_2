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
    const primaryTeal = Color(0xFF0F4C5C);
    final controller = Provider.of<HomePageController>(context);
    final section = controller.stotraSection;

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
              style: const TextStyle(
                fontSize: 32,
                fontFamily: 'serif',
                color: primaryTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Home > Stotra / Bhajan / Aarti',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

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
                              // Numbered Circle (Teal)
                              Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: primaryTeal,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),

                              // Stotra Name
                              Expanded(
                                flex: 4,
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF444444),
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ),

                              const VerticalDivider(width: 40),

                              _pdfLink('English', item.englishPdfUrl, primaryTeal),
                              const VerticalDivider(width: 40),
                              _pdfLink('Hindi', item.hindiPdfUrl, primaryTeal),
                              const VerticalDivider(width: 40),
                              _pdfLink('Gujarati', item.gujaratiPdfUrl, primaryTeal),
                            ],
                          ),
                        ),
                        const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                      ],
                    );
                  }),
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

  Widget _pdfLink(String label, String url, Color color) {
    return Expanded(
      flex: 2,
      child: InkWell(
        onTap: () => _launchUrl(url),
        child: Row(
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF444444),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
