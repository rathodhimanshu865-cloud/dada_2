import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/homepage_controller.dart';

class UserFooter extends StatelessWidget {
  final HomePageController controller;
  const UserFooter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);

    return Container(
      color: primaryTeal,
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
                      Text(
                        controller.websiteSettings.name.isNotEmpty 
                          ? controller.websiteSettings.name.toUpperCase() 
                          : 'JIGNESH DADA', 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5)
                      ),
                      const SizedBox(height: 20),
                      Text(
                        controller.footer.description,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
                _footerColumn(
                  'MAIN',
                  [
                    _footerLink(context, 'Home', '/'),
                    _footerLink(context, 'Contact Us', '/contact_us'),
                  ],
                ),
                _footerColumn(
                  'KATHA',
                  [
                    _footerLink(context, 'About Katha', '/about_katha'),
                    _footerLink(context, 'Full Katha List', '/katha_list'),
                    _footerLink(context, 'Upcoming Kathas', '/upcoming_ram_kathas'),
                  ],
                ),
                _footerColumn(
                  'STOTRA / BHAJAN / AARTI',
                  [
                    _footerLink(context, 'View Page', '/stotra'),
                  ],
                ),
                _footerColumn(
                  'GALLERY',
                  [
                    _footerLink(context, 'Photos', '/photo_gallery'),
                    _footerLink(context, 'Videos', '/video_gallery'),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 60),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(controller.footer.copyright, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              
              // Social Icons moved to the Right Side corner of Footer
              Row(
                children: [
                  _socialCircleIcon(Icons.facebook, controller.footer.facebookUrl, 'Facebook'),
                  _socialCircleIcon(Icons.camera_alt_outlined, controller.footer.instagramUrl, 'Instagram'),
                  _socialCircleIcon(Icons.play_arrow, controller.footer.youtubeUrl, 'YouTube'),
                  _socialCircleIcon(Icons.chat, controller.footer.whatsappUrl, 'WhatsApp'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/admin_login'),
            child: const Text(
              'Admin Panel',
              style: TextStyle(color: Colors.white38, fontSize: 10, decoration: TextDecoration.underline),
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
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
          const SizedBox(height: 20),
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
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }

  Future<void> _launchSocialUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _socialCircleIcon(IconData icon, String url, String tooltip) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () => _launchSocialUrl(url),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
