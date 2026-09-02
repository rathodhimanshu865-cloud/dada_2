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
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);
    final l10n = AppLocalizations.of(context)!;

    const Color primaryTeal = Color(0xFF0F4C5C);
    const Color templeGold = Color(0xFFC89A5B);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryTeal,
        border: Border(top: BorderSide(color: templeGold.withOpacity(0.3), width: 4)),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100, 
        horizontal: isMobile ? 24 : (isTablet ? 60 : 120)
      ),
      child: Column(
        children: [
          // MAIN FOOTER CONTENT
          LayoutBuilder(
            builder: (context, constraints) {
              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBranding(lang, primaryTeal, templeGold),
                    const SizedBox(height: 60),
                    _buildLinksGrid(context, lang, isMobile, isTablet, l10n),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildBranding(lang, primaryTeal, templeGold)),
                  const SizedBox(width: 80),
                  Expanded(flex: 7, child: _buildLinksGrid(context, lang, isMobile, isTablet, l10n)),
                ],
              );
            },
          ),
          
          const SizedBox(height: 80),
          Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
          const SizedBox(height: 40),
          
          // BOTTOM BAR: COPYRIGHT & LEGAL
          LayoutBuilder(
            builder: (context, constraints) {
              if (isMobile) {
                return Column(
                  children: [
                    Text(
                      controller.footer.localizedCopyright(lang),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 10,
                      children: [
                        _buildBottomLink(controller.footer.localizedPrivacyLabel(lang), controller.footer.privacyUrl),
                        _buildBottomLink(controller.footer.localizedTermsLabel(lang), controller.footer.termsUrl),
                        _buildBottomLink(controller.footer.localizedCookieLabel(lang), controller.footer.cookieUrl),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildAdminLink(context, l10n),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      controller.footer.localizedCopyright(lang),
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, letterSpacing: 0.5),
                    ),
                  ),
                  Row(
                    children: [
                      _buildBottomLink(controller.footer.localizedPrivacyLabel(lang), controller.footer.privacyUrl),
                      const _DotDivider(),
                      _buildBottomLink(controller.footer.localizedTermsLabel(lang), controller.footer.termsUrl),
                      const _DotDivider(),
                      _buildBottomLink(controller.footer.localizedCookieLabel(lang), controller.footer.cookieUrl),
                      const SizedBox(width: 40),
                      _buildAdminLink(context, l10n),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBranding(String lang, Color bg, Color gold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.websiteSettings.localizedName(lang).toUpperCase(),
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 32, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 3,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          controller.footer.localizedDescription(lang),
          style: TextStyle(
            color: Colors.white.withOpacity(0.7), 
            fontSize: 16, 
            height: 1.8,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            _buildSocialIcon(Icons.facebook_rounded, controller.footer.facebookUrl),
            _buildSocialIcon(Icons.camera_alt_rounded, controller.footer.instagramUrl),
            _buildSocialIcon(Icons.play_circle_fill_rounded, controller.footer.youtubeUrl),
            _buildSocialIcon(Icons.chat_bubble_outline, controller.footer.whatsappUrl),
          ],
        ),
      ],
    );
  }

  Widget _buildLinksGrid(BuildContext context, String lang, bool isMobile, bool isTablet, AppLocalizations l10n) {
    return Wrap(
      spacing: isMobile ? 40 : (isTablet ? 40 : 60),
      runSpacing: 50,
      alignment: WrapAlignment.start,
      children: [
        _buildLinkSection(context, l10n.organization, [
          {'label': l10n.home, 'route': '/'},
          {'label': l10n.aboutDada, 'route': '/about_dada'},
          {'label': l10n.pujyaDadaTeachings, 'route': '/teachings'},
          {'label': l10n.newsAndEvents, 'route': '/news'},
        ]),
        _buildLinkSection(context, l10n.katha, [
          {'label': l10n.shrimadBhagvatKatha, 'route': '/about_katha'},
          {'label': l10n.deviBhagvatKatha, 'route': '/about_devi_katha'},
          {'label': l10n.shivmahapuranKatha, 'route': '/about_shiv_katha'},
          {'label': l10n.fullKathaList, 'route': '/katha_list'},
          {'label': l10n.upcomingKathas, 'route': '/upcoming_ram_kathas'},
        ]),
        _buildLinkSection(context, l10n.resources, [
          {'label': l10n.photoGallery, 'route': '/photo_gallery'},
          {'label': l10n.videoGallery, 'route': '/video_gallery'},
          {'label': l10n.stotraBhajan, 'route': '/stotra'},
          {'label': l10n.trackShipment, 'route': '/track'},
          {'label': l10n.contactUs, 'route': '/contact_us'},
          {'label': l10n.sacredProducts, 'route': '/product'},
          {'label': l10n.myShoppingBag, 'route': '/cart'},
        ]),
        // Dynamic Sections from Admin
        ...controller.footer.linkSections.map((sec) => _buildLinkSection(context, sec.localizedTitle(lang), 
          sec.links.map((l) => {'label': l.localizedLabel(lang), 'route': l.route}).toList())),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        ),
      ),
    );
  }

  Widget _buildLinkSection(BuildContext context, String title, List<Map<String, String>> links) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 14, 
              fontWeight: FontWeight.w800, 
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 30),
          ...links.map((link) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, link['route']!),
              child: Text(
                link['label']!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6), 
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomLink(String text, String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5), 
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAdminLink(BuildContext context, AppLocalizations l10n) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/admin_login'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.4), size: 14),
            const SizedBox(width: 8),
            Text(
              l10n.adminAccess,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotDivider extends StatelessWidget {
  const _DotDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
