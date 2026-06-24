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
              // Left: Social Icons (Exactly like photo)
              Row(
                children: [
                  _socialIcon(Icons.facebook),
                  _socialIcon(Icons.close), // X (Twitter)
                  _socialIcon(Icons.camera_alt_outlined), // Instagram
                  _socialIcon(Icons.play_arrow), // YouTube
                ],
              ),
              
              // Center: Logo (Adjustable from Admin)
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
              
              // Right: Language Dropdown (Exactly like photo)
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
              _navItem('Home', active: true),
              _navItem('Past Kathas'),
              _navItem('Live'),
              _navItem('Gallery'),
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
    // Small Indian flag colored container for Gujarati/Hindi, UK for English
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

  Widget _navItem(String title, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: active ? FontWeight.bold : FontWeight.w600,
          color: active ? Colors.brown[800] : Colors.black,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
