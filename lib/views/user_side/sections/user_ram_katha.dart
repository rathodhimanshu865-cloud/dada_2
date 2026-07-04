import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';

class UserRamKatha extends StatelessWidget {
  final HomePageController controller;
  const UserRamKatha({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    final ramKatha = controller.ramKatha;

    return Container(
      width: double.infinity,
      color: backgroundBeige,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: LayoutBuilder(builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;
        return Flex(
          direction: isDesktop ? Axis.horizontal : Axis.vertical,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ram Katha',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryTeal, fontFamily: 'serif'),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    ramKatha.description1,
                    style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    ramKatha.description2,
                    style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/about_katha'),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryTeal),
                    child: const Text('ENTER RAM KATHA JOURNEY'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 60, height: 40),
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  ramKatha.photoUrl.isNotEmpty 
                    ? ramKatha.photoUrl 
                    : 'https://via.placeholder.com/400x500',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.white, height: 400),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
