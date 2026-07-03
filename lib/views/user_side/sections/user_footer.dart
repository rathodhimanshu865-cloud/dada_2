import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
                _footerColumn(
                  'Main',
                  [
                    _footerLink(context, 'Home', '/'),
                    _footerLink(context, 'Contact Us', '/contact_us'),
                  ],
                ),
                _footerColumn(
                  'Katha',
                  [
                    _footerLink(context, 'About Kathas', '/about_katha'),
                    _footerLink(context, 'Full Katha List', '/katha_list'),
                    _footerLink(context, 'Upcoming Kathas', '/upcoming_ram_kathas'),
                  ],
                ),
                _footerColumn(
                  'Stotra / Bhajan / Aarti',
                  [
                    _footerLink(context, 'View Page', '/stotra'),
                  ],
                ),
                _footerColumn(
                  'Gallery',
                  [
                    _footerLink(context, 'Photos', '/photo_gallery'),
                    _footerLink(context, 'Videos', '/video_gallery'),
                  ],
                ),
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
                  _socialIcon(Icons.play_circle_outline, controller.websiteSettings.youtubeUrl, 'YouTube', const Color(0xFFCD201F)),
                  _socialIcon(Icons.camera_alt_outlined, controller.websiteSettings.instagramUrl, 'Instagram', const Color(0xFFC13584)),
                  _socialIcon(Icons.facebook, controller.websiteSettings.facebookUrl, 'Facebook', const Color(0xFF1877F2)),
                  _socialIcon(Icons.chat, controller.websiteSettings.whatsappUrl, 'WhatsApp', const Color(0xFF25D366)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/admin_login'),
            child: const Text(
              'Admin Panel',
              style: TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerColumn(String title, List<Widget> items) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: item,
          )),
        ],
      ),
    );
  }

  Widget _footerLink(BuildContext context, String label, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Text(
        label,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }

  Future<void> _launchSocialUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _socialIcon(IconData icon, String url, String tooltip, Color backgroundColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () => _launchSocialUrl(url),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
