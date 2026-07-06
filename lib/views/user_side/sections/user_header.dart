import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/homepage_controller.dart';

class UserHeader extends StatefulWidget {
  final HomePageController controller;
  const UserHeader({super.key, required this.controller});

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  String selectedLanguage = 'English';
  final primaryTeal = const Color(0xFF0F4C5C);
  int _logoTapCount = 0;
  Timer? _logoTapResetTimer;

  @override
  void dispose() {
    _logoTapResetTimer?.cancel();
    super.dispose();
  }

  void _handleLogoTap() {
    _logoTapResetTimer?.cancel();
    _logoTapResetTimer = Timer(const Duration(seconds: 2), () {
      setState(() => _logoTapCount = 0);
    });

    setState(() => _logoTapCount++);

    if (_logoTapCount >= 5) {
      _logoTapResetTimer?.cancel();
      setState(() => _logoTapCount = 0);
      Navigator.pushNamed(context, '/admin_login');
    }
  }

  Widget _ramKathaDropdown(String currentRoute) {
    bool isActive = currentRoute == '/about_katha' || 
                    currentRoute == '/about_devi_katha' || 
                    currentRoute == '/about_shiv_katha' || 
                    currentRoute == '/katha_list' || 
                    currentRoute == '/upcoming_ram_kathas';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 40),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: Colors.white,
        onSelected: (value) {
          if (value == 'About Shreemad Bhagvat Katha') {
            Navigator.pushNamed(context, '/about_katha');
          } else if (value == 'Shreemad Devi Bhagvat Katha') {
            Navigator.pushNamed(context, '/about_devi_katha');
          } else if (value == 'Shree Shivmahapuran Katha') {
            Navigator.pushNamed(context, '/about_shiv_katha');
          } else if (value == 'Full Katha List') {
            Navigator.pushNamed(context, '/katha_list');
          } else if (value == 'Upcoming Kathas') {
            Navigator.pushNamed(context, '/upcoming_ram_kathas');
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'KATHA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? primaryTeal : const Color(0xFF444444),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 20, color: isActive ? primaryTeal : Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isActive ? 30 : 0,
              color: isActive ? primaryTeal : Colors.transparent,
            ),
          ],
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          _dropdownItem('About Shreemad Bhagvat Katha', isFirst: true),
          _dropdownItem('Shreemad Devi Bhagvat Katha'),
          _dropdownItem('Shree Shivmahapuran Katha'),
          const PopupMenuDivider(),
          _dropdownItem('Full Katha List'),
          _dropdownItem('Upcoming Kathas'),
        ],
      ),
    );
  }

  Widget _galleryDropdown(String currentRoute) {
    bool isActive = currentRoute == '/photo_gallery' || 
                    currentRoute == '/video_gallery';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 40),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: Colors.white,
        onSelected: (value) {
          if (value == 'Videos') {
            Navigator.pushNamed(context, '/video_gallery');
          } else if (value == 'Photos') {
            Navigator.pushNamed(context, '/photo_gallery');
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GALLERY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? primaryTeal : const Color(0xFF444444),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 20, color: isActive ? primaryTeal : Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isActive ? 30 : 0,
              color: isActive ? primaryTeal : Colors.transparent,
            ),
          ],
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(value: 'Photos', child: Text('Photos')),
          const PopupMenuItem<String>(value: 'Videos', child: Text('Videos')),
        ],
      ),
    );
  }

  PopupMenuItem<String> _dropdownItem(String title, {bool isFirst = false}) {
    return PopupMenuItem<String>(
      value: title,
      height: 40,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isFirst ? primaryTeal : Colors.blueGrey[700],
          fontWeight: isFirst ? FontWeight.bold : FontWeight.w400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Social Icons
              Row(
                children: [
                  _socialCircleIcon(Icons.facebook, widget.controller.footer.facebookUrl, 'Facebook'),
                  _socialCircleIcon(Icons.camera_alt_outlined, widget.controller.footer.instagramUrl, 'Instagram'),
                  _socialCircleIcon(Icons.play_arrow, widget.controller.footer.youtubeUrl, 'YouTube'),
                  _socialCircleIcon(Icons.chat, widget.controller.footer.whatsappUrl, 'WhatsApp'),
                ],
              ),
              
              // Center: Logo
              GestureDetector(
                onTap: _handleLogoTap,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryTeal.withOpacity(0.15), width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(widget.controller.websiteSettings.logoUrl),
                      fit: BoxFit.cover,
                      onError: (e, s) {},
                    ),
                  ),
                  child: widget.controller.websiteSettings.logoUrl.isEmpty 
                    ? const Icon(Icons.person, color: Colors.grey, size: 50) 
                    : null,
                ),
              ),
              
              // Right: Language & Search
              Row(
                children: [
                  _languageDropdown(),
                  const SizedBox(width: 25),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryTeal.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.search, size: 28, color: primaryTeal),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 35),
          // Navigation Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _navItem('Home', active: currentRoute == '/', onTap: () => Navigator.pushNamed(context, '/')),
              _ramKathaDropdown(currentRoute),
              _navItem('Stotra / Bhajan / Aarti', active: currentRoute == '/stotra', onTap: () => Navigator.pushNamed(context, '/stotra')),
              _galleryDropdown(currentRoute),
              _navItem('Contact Us', active: currentRoute == '/contact_us', onTap: () => Navigator.pushNamed(context, '/contact_us')),
            ],
          ),
        ],
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
      padding: const EdgeInsets.only(right: 12),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () => _launchSocialUrl(url),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryTeal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: primaryTeal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _languageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: SizedBox(
          height: 34,
          child: DropdownButton<String>(
            value: selectedLanguage,
            icon: Icon(Icons.keyboard_arrow_down, size: 24, color: primaryTeal),
            elevation: 1,
            style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
            onChanged: (String? newValue) {
              setState(() {
                selectedLanguage = newValue!;
              });
            },
            items: <String>['English', 'Gujarati', 'Hindi']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _navItem(String title, {bool active = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: active ? primaryTeal : const Color(0xFF444444),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: active ? 30 : 0,
              color: active ? primaryTeal : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
