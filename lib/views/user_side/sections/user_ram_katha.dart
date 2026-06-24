import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';

class UserRamKatha extends StatelessWidget {
  final HomePageController controller;
  const UserRamKatha({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final ramKatha = controller.ramKatha;
    return Container(
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
                    ramKatha.title,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.brown),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    ramKatha.description1,
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    ramKatha.description2,
                    style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey[600]),
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
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
