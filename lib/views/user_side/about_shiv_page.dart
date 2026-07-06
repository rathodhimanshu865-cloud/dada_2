import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import 'sections/user_header.dart';
import 'sections/user_footer.dart';

class AboutShivPage extends StatelessWidget {
  const AboutShivPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    final controller = Provider.of<HomePageController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 80),
              color: backgroundBeige.withOpacity(0.5),
              child: const Column(
                children: [
                  Text(
                    'Shree Shivmahapuran Katha',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 42, fontFamily: 'serif', color: primaryTeal, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('Home > About > Shivmahapuran', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(100),
              child: Text(
                'Full details about Shree Shivmahapuran Katha will be displayed here. This page is now properly linked and ready for content.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }
}
