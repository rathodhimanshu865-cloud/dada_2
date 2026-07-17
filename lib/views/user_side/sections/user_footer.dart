import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../controllers/homepage_controller.dart';

class UserFooter extends StatelessWidget {
  final HomePageController controller;
  const UserFooter({super.key, required this.controller});

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentGold = Color(0xFFC89A5B);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0A303B), // Deep Peacock Blue
        image: DecorationImage(
          image: const NetworkImage('https://www.transparenttextures.com/patterns/dark-matter.png'), // Luxury pattern
          opacity: 0.15,
          colorFilter: ColorFilter.mode(accentGold.withOpacity(0.05), BlendMode.srcATop),
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        children: [
          // Golden texture bar at the top
          Container(
            height: 4,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, accentGold, Colors.transparent],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 80),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Branding
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.websiteSettings.name.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'serif'),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: 400,
                            child: Text(
                              controller.footer.description,
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15, height: 1.8),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: [
                              _buildSocialIcon(Icons.facebook, controller.footer.facebookUrl),
                              _buildSocialIcon(Icons.camera_alt_outlined, controller.footer.instagramUrl),
                              _buildSocialIcon(Icons.play_arrow_rounded, controller.footer.youtubeUrl),
                              _buildSocialIcon(Icons.chat_bubble_outline, controller.footer.whatsappUrl),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Links
                    _buildFooterColumn(context, AppLocalizations.of(context)!.organization, [
                      {"label": AppLocalizations.of(context)!.home, "route": "/"},
                      {"label": AppLocalizations.of(context)!.aboutDada, "route": "/about_dada"},
                      {"label": AppLocalizations.of(context)!.mission, "route": "/about_dada"},
                      {"label": AppLocalizations.of(context)!.contactUs, "route": "/contact_us"},
                    ]),
                    
                    _buildFooterColumn(context, AppLocalizations.of(context)!.katha, [
                      {"label": AppLocalizations.of(context)!.upcomingKathas, "route": "/upcoming_ram_kathas"},
                      {"label": AppLocalizations.of(context)!.fullKathaList, "route": "/katha_list"},
                      {"label": AppLocalizations.of(context)!.bhagvatKatha, "route": "/about_katha"},
                      {"label": AppLocalizations.of(context)!.shivmahapuran, "route": "/about_shiv_katha"},
                    ]),
                    
                    _buildFooterColumn(context, AppLocalizations.of(context)!.resources, [
                      {"label": AppLocalizations.of(context)!.stotraBhajan, "route": "/stotra"},
                      {"label": AppLocalizations.of(context)!.photoGallery, "route": "/photo_gallery"},
                      {"label": AppLocalizations.of(context)!.videoGallery, "route": "/video_gallery"},
                      {"label": AppLocalizations.of(context)!.adminPanel, "route": "/admin_login"},
                    ]),
                  ],
                ),
                
                const SizedBox(height: 100),
                const Divider(color: Colors.white10),
                const SizedBox(height: 40),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.footer.copyright,
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                    ),
                    Row(
                      children: [
                        _buildBottomLink(AppLocalizations.of(context)!.privacyPolicy),
                        const SizedBox(width: 30),
                        _buildBottomLink(AppLocalizations.of(context)!.termsOfService),
                        const SizedBox(width: 30),
                        _buildBottomLink(AppLocalizations.of(context)!.cookiePolicy),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(BuildContext context, String title, List<Map<String, dynamic>> links) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFFC89A5B), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 2),
          ),
          const SizedBox(height: 35),
          ...links.map((link) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, link['route'] ?? '/'),
              child: Text(
                (link['label'] ?? '') as String,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15, fontWeight: FontWeight.w300),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.only(right: 25),
      child: InkWell(
        onTap: () => _launchUrl(url),
        child: Icon(icon, color: Colors.white.withOpacity(0.4), size: 22),
      ),
    );
  }

  Widget _buildBottomLink(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
    );
  }
}
