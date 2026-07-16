import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../controllers/homepage_controller.dart';

class UserRamKatha extends StatelessWidget {
  final HomePageController controller;
  const UserRamKatha({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFFAF8F4);
    const accentGold = Color(0xFFC89A5B);
    final kathaData = controller.ramKatha;
    
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      width: double.infinity,
      color: backgroundBeige,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
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
                      "DIVINE DISCOURSES".tr(),
                      style: const TextStyle(color: accentGold, letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Shreemad Bhagwat Katha".tr(),
                      style: const TextStyle(fontSize: 48, fontFamily: 'serif', fontWeight: FontWeight.w900, color: primaryTeal, height: 1.1),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      kathaData.description1.tr(),
                      style: const TextStyle(fontSize: 18, height: 1.8, color: Color(0xFF2B2B2B), letterSpacing: 0.2),
                    ),
                    if (kathaData.description2.isNotEmpty) ...[
                      const SizedBox(height: 25),
                      Text(
                        kathaData.description2.tr(),
                        style: const TextStyle(fontSize: 16, height: 1.7, color: Color(0xFF6D6D6D)),
                      ),
                    ],
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/about_katha'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('EXPLORE KATHA JOURNEY'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ],
                ),
              ),
              
              if (!isMobile) const SizedBox(width: 80),
              if (isMobile) const SizedBox(height: 60),

              // Right: Image Canvas
              Expanded(
                flex: 5,
                child: Container(
                  height: 500,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 40, offset: const Offset(0, 20)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: kathaData.photoUrl.isNotEmpty
                        ? Image.network(kathaData.photoUrl, fit: BoxFit.cover)
                        : const Icon(Icons.temple_hindu_outlined, size: 80, color: Color(0xFFEEEEEE)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
