import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';

class UserLatestChaupai extends StatelessWidget {
  final HomePageController controller;
  const UserLatestChaupai({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final suvichar = controller.dailySuvichar;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          const Text(
            "Dada's Daily Suvichar",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.brown, fontFamily: 'serif'),
          ),
          const SizedBox(height: 40),
          Container(
            width: 600, // Slightly wider for professional image display
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image Section
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(
                    suvichar.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[100],
                      child: const Icon(Icons.image_outlined, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                // Date Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text(
                        suvichar.date.isNotEmpty ? suvichar.date : '---',
                        style: const TextStyle(
                          fontSize: 16, 
                          color: Color(0xFF444444), 
                          fontWeight: FontWeight.w500,
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
