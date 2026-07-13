import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';

class UserDailySuvichar extends StatelessWidget {
  final HomePageController controller;
  const UserDailySuvichar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final suvichar = controller.dailySuvichar;
    if (suvichar.imageUrl.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
      color: const Color(0xFFF3EEE6),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20)),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF2ECE3))),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        "DADA'S DAILY SUVICHAR",
                        style: TextStyle(color: Color(0xFFC89A5B), letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        suvichar.date,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF6D6D6D), fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Image
              Padding(
                padding: const EdgeInsets.all(40),
                child: ClipRRect(
                  child: Image.network(
                    suvichar.imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
              
              // Footer Action
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildShareIcon(Icons.share_outlined),
                    const SizedBox(width: 30),
                    _buildShareIcon(Icons.download_outlined),
                    const SizedBox(width: 30),
                    _buildShareIcon(Icons.favorite_border_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareIcon(IconData icon) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFC89A5B).withOpacity(0.2)),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFFC89A5B)),
    );
  }
}
