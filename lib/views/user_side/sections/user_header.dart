import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';

class UserHeader extends StatefulWidget {
  final HomePageController controller;
  const UserHeader({super.key, required this.controller});

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  String selectedLanguage = 'English';

  Widget _ramKathaDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'RAM KATHA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 0.8,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.brown),
          ],
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          _dropdownItem('About Ram Katha', isFirst: true),
          _dropdownItem('Full Katha List'),
          _dropdownItem('Upcoming Ram Kathas'),
          _dropdownItem('Katha Booklets'),
          _dropdownItem('Katha Chaupais'),
          _dropdownItem('Katha Glossary'),
        ],
      ),
    );
  }

  Widget _galleryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 30),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Colors.white,
        onSelected: (value) {
          if (value == 'Photos') {
            Navigator.pushNamed(context, '/photo_gallery');
          } else if (value == 'Videos') {
            Navigator.pushNamed(context, '/video_gallery');
          }
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GALLERY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 0.8,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.brown),
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
          color: isFirst ? Colors.brown[300] : Colors.blueGrey[700],
          fontWeight: isFirst ? FontWeight.bold : FontWeight.w400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Social Icons
              Row(
                children: [
                  _socialIcon(Icons.facebook),
                  _socialIcon(Icons.close),
                  _socialIcon(Icons.camera_alt_outlined),
                  _socialIcon(Icons.play_arrow),
                ],
              ),
              
              // Center: Logo
              Image.network(
                widget.controller.websiteSettings.logoUrl,
                height: 80,
                errorBuilder: (context, error, stackTrace) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '|| શ્રી રામ ||',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'serif'),
                    ),
                    Text(
                      widget.controller.websiteSettings.name.isNotEmpty 
                        ? widget.controller.websiteSettings.name.toUpperCase() 
                        : 'JIGNESHDADA',
                      style: const TextStyle(fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              
              // Right: Language & Admin
              Row(
                children: [
                  _languageDropdown(),
                  const SizedBox(width: 10),
                  const Icon(Icons.search, size: 20, color: Colors.black54),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                    onPressed: () => Navigator.pushNamed(context, '/admin_login'),
                    tooltip: 'Admin Login',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Navigation Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _navItem('Home', active: true, onTap: () => Navigator.pushNamed(context, '/')),
              _ramKathaDropdown(),
              _navItem('Stuti', onTap: () => Navigator.pushNamed(context, '/stotra')),
              _navItem('Live'),
              _galleryDropdown(),
              _navItem('Contact Us'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFF444444),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }

  Widget _languageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(2),
      ),
      child: DropdownButtonHideUnderline(
        child: SizedBox(
          height: 24,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _getFlag(value),
                    const SizedBox(width: 8),
                    Text(value),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _getFlag(String lang) {
    return Container(
      width: 20,
      height: 14,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(child: Container(color: lang == 'English' ? Colors.blue[900] : Colors.orange)),
          Expanded(child: Container(color: Colors.white)),
          Expanded(child: Container(color: lang == 'English' ? Colors.red : Colors.green)),
        ],
      ),
    );
  }

  Widget _navItem(String title, {bool active = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.w600,
            color: active ? Colors.brown[800] : Colors.black,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
