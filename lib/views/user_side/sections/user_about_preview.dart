import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../controllers/homepage_controller.dart';

class UserAboutPreview extends StatelessWidget {
  final HomePageController controller;
  const UserAboutPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final about = controller.aboutSection;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Narrative Content
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DISCOVER THE JOURNEY".tr(),
                      style: const TextStyle(color: Color(0xFFC89A5B), letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      about.title.tr(),
                      style: const TextStyle(fontSize: 48, fontFamily: 'serif', fontWeight: FontWeight.w900, color: Color(0xFF0F4C5C), height: 1.1),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      about.tagline.tr(),
                      style: const TextStyle(fontSize: 20, color: Color(0xFFC89A5B), fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      about.description.tr(),
                      style: const TextStyle(fontSize: 18, height: 1.8, color: Color(0xFF2B2B2B), letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/about_dada'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C5C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('READ FULL BIOGRAPHY'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ],
                ),
              ),
              
              if (!isMobile) const SizedBox(width: 80),
              if (isMobile) const SizedBox(height: 60),

              // Right: Premium Portrait Canvas
              Expanded(
                flex: 5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Decorative Background Shape
                    Transform.translate(
                      offset: const Offset(30, 30),
                      child: Container(
                        width: 400, height: 500,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFC89A5B).withOpacity(0.2), width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    
                    // Main Photo
                    Container(
                      width: 400, height: 500,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EEE6),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20)),
                        ],
                      ),
                      child: ClipRRect(
                        child: about.photoUrl.isNotEmpty
                            ? Image.network(about.photoUrl, fit: BoxFit.cover)
                            : const Icon(Icons.person, size: 100, color: Colors.white),
                      ),
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
