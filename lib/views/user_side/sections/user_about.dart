import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';

class UserAbout extends StatelessWidget {
  final HomePageController controller;
  const UserAbout({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final about = controller.aboutSection;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: const Color(0xFFFDF9F6),
      child: LayoutBuilder(builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;
        
        Widget imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            about.photoUrl.isNotEmpty 
              ? about.photoUrl 
              : 'https://via.placeholder.com/400x500',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              height: 400,
              width: double.infinity,
              child: const Icon(Icons.person, size: 100, color: Colors.grey),
            ),
          ),
        );

        return Flex(
          direction: isDesktop ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
              Expanded(
                flex: 1,
                child: imageWidget,
              ),
              const SizedBox(width: 60),
            ],
            if (!isDesktop) ...[
              imageWidget,
              const SizedBox(height: 40),
            ],
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.brown, fontFamily: 'serif'),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    about.description.isNotEmpty 
                      ? about.description 
                      : 'No description provided.',
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/about_katha'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('More', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        Icon(Icons.arrow_right, color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
