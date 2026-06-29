import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';

class UserFooter extends StatelessWidget {
  final HomePageController controller;
  const UserFooter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
            LayoutBuilder(builder: (context, constraints) {
            return Wrap(
              spacing: 60,
              runSpacing: 40,
              alignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        controller.websiteSettings.logoUrl,
                        height: 50,
                        color: Colors.white,
                        errorBuilder: (context, error, stackTrace) => Text(
                          controller.websiteSettings.name.isNotEmpty 
                            ? controller.websiteSettings.name 
                            : 'JIGNESHDADA', 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        controller.footer.description,
                        style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
                _footerColumn('More', ['Home', 'Past Kathas']),
                _footerColumn('Sections', ['About', 'Upcoming Kathas', 'Chaupai', 'Videos', 'Gallery']),
                _footerColumn('Resources', ['Books', 'Photos', 'Audio', 'Downloads', 'Suvichar']),
                _footerColumn('Contact', ['Support']),
              ],
            );
          }),
          const SizedBox(height: 60),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(controller.footer.copyright, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Row(
                children: [
                  _socialIcon(Icons.facebook),
                  _socialIcon(Icons.camera_alt_outlined),
                  _socialIcon(Icons.play_circle_outline),
                  _socialIcon(Icons.send),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/admin_login'),
            child: const Text(
              'Admin Login', 
              style: TextStyle(color: Colors.white24, fontSize: 10, decoration: TextDecoration.underline)
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network('https://upload.wikimedia.org/wikipedia/commons/3/3c/Download_on_the_App_Store_Badge.svg', height: 40),
              const SizedBox(width: 15),
              Image.network('https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg', height: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerColumn(String title, List<String> items) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(item, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          )),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Icon(icon, size: 18, color: Colors.grey),
    );
  }
}
