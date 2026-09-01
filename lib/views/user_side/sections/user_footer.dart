import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../utils/responsive_utils.dart';

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
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    final bool isMobile = context.isMobile;
    final bool isTablet = context.isTablet;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0F4C5C), // Deep Teal from the image
      ),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80, 
        horizontal: isMobile ? 20 : (isTablet ? 40 : 80)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding
          Text(
            controller.websiteSettings.localizedName(lang).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          Text(
            controller.footer.localizedDescription(lang),
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 30),
          
          // Social Icons
          Row(
            children: [
              _buildSocialIcon(Icons.facebook, controller.footer.facebookUrl),
              _buildSocialIcon(Icons.camera_alt_outlined, controller.footer.instagramUrl),
              _buildSocialIcon(Icons.play_arrow_rounded, controller.footer.youtubeUrl),
              _buildSocialIcon(Icons.chat_bubble_outline, controller.footer.whatsappUrl),
            ],
          ),
          
          const SizedBox(height: 50),
          
          // Section-wise Links
          Wrap(
            spacing: isMobile ? 40 : (isTablet ? 60 : 100),
            runSpacing: 40,
            children: [
              _buildLinkSection(context, AppLocalizations.of(context)!.organization, [
                {'label': AppLocalizations.of(context)!.home, 'route': '/'},
                {'label': AppLocalizations.of(context)!.aboutDada, 'route': '/about_dada'},
                {'label': AppLocalizations.of(context)!.pujyaDadaTeachings, 'route': '/teachings'},
                {'label': AppLocalizations.of(context)!.newsAndEvents, 'route': '/news'},
              ]),
              _buildLinkSection(context, AppLocalizations.of(context)!.katha, [
                {'label': AppLocalizations.of(context)!.shrimadBhagvatKatha, 'route': '/about_katha'},
                {'label': AppLocalizations.of(context)!.deviBhagvatKatha, 'route': '/about_devi_katha'},
                {'label': AppLocalizations.of(context)!.shivmahapuranKatha, 'route': '/about_shiv_katha'},
                {'label': AppLocalizations.of(context)!.fullKathaList, 'route': '/katha_list'},
                {'label': AppLocalizations.of(context)!.upcomingKathas, 'route': '/upcoming_ram_kathas'},
              ]),
              _buildLinkSection(context, AppLocalizations.of(context)!.resources, [
                {'label': AppLocalizations.of(context)!.photoGallery, 'route': '/photo_gallery'},
                {'label': AppLocalizations.of(context)!.videoGallery, 'route': '/video_gallery'},
                {'label': AppLocalizations.of(context)!.stotraBhajan, 'route': '/stotra'},
                {'label': AppLocalizations.of(context)!.contactUs, 'route': '/contact_us'},
                {'label': AppLocalizations.of(context)!.sacredProducts, 'route': '/product'},
              ]),
              // Dynamic Sections from Admin
              ...controller.footer.linkSections.map((sec) => _buildLinkSection(context, sec.localizedTitle(lang), 
                sec.links.map((l) => {'label': l.localizedLabel(lang), 'route': l.route}).toList())),
            ],
          ),
          
          const SizedBox(height: 60),
          const Divider(color: Colors.white12),
          const SizedBox(height: 30),
          
          // Bottom Bar
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.center,
            children: [
              Text(
                controller.footer.localizedCopyright(lang),
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
              ),
              if (isMobile) const SizedBox(height: 20),
              Wrap(
                alignment: isMobile ? WrapAlignment.center : WrapAlignment.end,
                spacing: 30,
                runSpacing: 10,
                children: [
                  _buildBottomLink(controller.footer.localizedPrivacyLabel(lang), controller.footer.privacyUrl),
                  _buildBottomLink(controller.footer.localizedTermsLabel(lang), controller.footer.termsUrl),
                  _buildBottomLink(controller.footer.localizedCookieLabel(lang), controller.footer.cookieUrl),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/admin_login'),
                    child: Text(
                      AppLocalizations.of(context)!.adminAccess,
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.only(right: 25),
      child: InkWell(
        onTap: () => _launchUrl(url),
        child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 22),
      ),
    );
  }

  Widget _buildLinkSection(BuildContext context, String title, List<Map<String, String>> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        const SizedBox(height: 25),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, link['route']!),
            child: Text(
              link['label']!,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildBottomLink(String text, String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
      ),
    );
  }
}
