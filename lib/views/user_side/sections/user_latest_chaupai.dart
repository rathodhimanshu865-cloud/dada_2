import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';

class UserLatestChaupai extends StatelessWidget {
  final HomePageController controller;
  const UserLatestChaupai({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    final suvichar = controller.dailySuvichar;

    return Container(
      width: double.infinity,
      color: backgroundBeige,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          const Text(
            "Dada's Daily Suvichar",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryTeal,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: 600,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: primaryTeal,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
                ClipRRect(
                  child: Image.network(
                    suvichar.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[100],
                      child: const Icon(
                        Icons.image_outlined,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 25,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: primaryTeal,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        suvichar.date.isNotEmpty ? suvichar.date : '---',
                        style: const TextStyle(
                          fontSize: 16,
                          color: primaryTeal,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
