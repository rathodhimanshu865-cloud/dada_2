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

  Widget _ramKathaDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 30),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Colors.white,
        onSelected: (value) {
          if (value == 'About Ram Katha') {
            Navigator.pushNamed(context, '/about_katha');
          } else if (value == 'Full Katha List') {
            Navigator.pushNamed(context, '/katha_list');
          } else if (value == 'Upcoming Ram Kathas') {
            Navigator.pushNamed(context, '/upcoming_ram_kathas');
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'KATHA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
                letterSpacing: 0.5,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 14, color: primaryTeal),
          ],
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          _dropdownItem('About Ram Katha', isFirst: true),
          _dropdownItem('Full Katha List'),
          _dropdownItem('Upcoming Ram Kathas'),
        ],
      ),
    );
  }

  Widget _galleryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 30),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Colors.white,
        onSelected: (value) {
          if (value == 'Videos') {
            Navigator.pushNamed(context, '/video_gallery');
          } else if (value == 'Photos') {
            Navigator.pushNamed(context, '/photo_gallery');
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GALLERY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
                letterSpacing: 0.5,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 14, color: primaryTeal),
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
          fontSize: 13,
          color: isFirst ? primaryTeal : Colors.blueGrey[700],
          fontWeight: isFirst ? FontWeight.bold : FontWeight.w400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Social Icons
              Row(
                children: [
                  _socialIcon(Icons.facebook, widget.controller.websiteSettings.facebookUrl, 'Facebook'),
                  _socialIcon(Icons.camera_alt_outlined, widget.controller.websiteSettings.instagramUrl, 'Instagram'),
                  _socialIcon(Icons.play_arrow, widget.controller.websiteSettings.youtubeUrl, 'YouTube'),
                  _socialIcon(Icons.chat, widget.controller.websiteSettings.whatsappUrl, 'WhatsApp'),
                ],
              ),
              
              // Center: Circular Logo
              GestureDetector(
                onTap: _handleLogoTap,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[200]!),
                    image: DecorationImage(
                      image: NetworkImage(widget.controller.websiteSettings.logoUrl),
                      fit: BoxFit.cover,
                      onError: (e, s) {},
                    ),
                  ),
                  child: widget.controller.websiteSettings.logoUrl.isEmpty 
                    ? const Icon(Icons.person, color: Colors.grey) 
                    : null,
                ),
              ),
              
              // Right: Language & Search
              Row(
                children: [
                  _languageDropdown(),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: Icon(Icons.search, size: 22, color: primaryTeal),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Navigation Menu (Exactly like photo)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _navItem('Home', active: true, onTap: () => Navigator.pushNamed(context, '/')),
              _ramKathaDropdown(),
              _navItem('Stotra / Bhajan / Aarti', onTap: () => Navigator.pushNamed(context, '/stotra')),
              _galleryDropdown(),
              _navItem('Contact Us', onTap: () => Navigator.pushNamed(context, '/contact_us')),
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

  Widget _socialIcon(IconData icon, String url, String tooltip) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: primaryTeal,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16, color: Colors.white),
        onPressed: () => _launchSocialUrl(url),
        tooltip: tooltip,
      ),
    );
  }

  Widget _languageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: SizedBox(
          height: 28,
          child: DropdownButton<String>(
            value: selectedLanguage,
            icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
            elevation: 1,
            style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
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
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.w600,
            color: active ? primaryTeal : const Color(0xFF444444),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
