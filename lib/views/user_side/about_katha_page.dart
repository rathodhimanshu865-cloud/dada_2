import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import 'sections/user_header.dart';
import 'sections/user_footer.dart';

class AboutKathaPage extends StatelessWidget {
  const AboutKathaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    final data = controller.aboutKathaPage;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.black)));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),
            
            // Top Main Image (Centered)
            if (data.topHeaderImage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 40),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    constraints: const BoxConstraints(maxWidth: 1100),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        data.topHeaderImage, 
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 20),

            // Title & Main Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Column(
                children: [
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, fontFamily: 'serif', color: Color(0xFF444444)),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    data.mainItalicDesc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Color(0xFF666666), height: 1.6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Three Sub-Description Columns
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: LayoutBuilder(builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 800;
                return Flex(
                  direction: isDesktop ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: Text(data.subDescCol1, style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5))),
                    if (isDesktop) const SizedBox(width: 40),
                    Expanded(flex: 1, child: Text(data.subDescCol2, style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5))),
                    if (isDesktop) const SizedBox(width: 40),
                    Expanded(flex: 1, child: Text(data.subDescCol3, style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5))),
                  ],
                );
              }),
            ),

            const SizedBox(height: 80),

            // Middle Section with Side Photo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: LayoutBuilder(builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 900;
                
                Widget imagePart = ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    data.midSectionImage.isNotEmpty ? data.midSectionImage : 'https://via.placeholder.com/400x500',
                    width: isDesktop ? 400 : double.infinity,
                    height: isDesktop ? 500 : null,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey[200], height: 400, child: const Icon(Icons.person)),
                  ),
                );

                Widget textPart = Container(
                  padding: const EdgeInsets.all(60),
                  color: const Color(0xFFF2E8DF), 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.midSectionTitle,
                        style: const TextStyle(
                          fontSize: 24, 
                          fontStyle: FontStyle.italic, 
                          fontFamily: 'serif',
                          color: Color(0xFF444444),
                          height: 1.4
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        data.midSectionPara1,
                        style: const TextStyle(
                          fontSize: 14, 
                          color: Colors.black87, 
                          height: 1.8,
                          letterSpacing: 0.2
                        ),
                      ),
                    ],
                  ),
                );

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      imagePart,
                      const SizedBox(width: 40),
                      Expanded(child: textPart),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      imagePart,
                      const SizedBox(height: 20),
                      textPart,
                    ],
                  );
                }
              }),
            ),

            const SizedBox(height: 100),

            // Calligraphy / Signature Section (Modified to align image on the left of paragraphs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: LayoutBuilder(builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 800;
                
                Widget imagePart = data.signatureImage.isNotEmpty 
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Image.network(data.signatureImage, height: 140, fit: BoxFit.contain),
                    )
                  : const SizedBox.shrink();

                Widget textPart = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(data.bottomPara1, style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.6))),
                    const SizedBox(width: 40),
                    Expanded(child: Text(data.bottomPara2, style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.6))),
                  ],
                );

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.signatureImage.isNotEmpty) ...[
                        SizedBox(width: 250, child: imagePart),
                        const SizedBox(width: 40),
                      ],
                      Expanded(child: textPart),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imagePart,
                      textPart,
                    ],
                  );
                }
              }),
            ),

            const SizedBox(height: 60),

            // Large Bottom Image
            if (data.largeBottomImage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Image.network(data.largeBottomImage, width: double.infinity, fit: BoxFit.cover),
              ),

            const SizedBox(height: 80),

            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }
}
