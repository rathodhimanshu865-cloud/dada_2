import 'package:flutter/material.dart';
import '../../controllers/homepage_controller.dart';

class WebsiteSettingsSection extends StatelessWidget {
  final HomePageController controller;
  const WebsiteSettingsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        title: const Text(
          'Website Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        subtitle: const Text('Name, tagline, and brand assets', style: TextStyle(fontSize: 12)),
        leading: const Icon(Icons.settings_outlined, color: Colors.black),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('General Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Website Name'),
                onChanged: (value) => controller.websiteSettings.name = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Website Tagline'),
                onChanged: (value) => controller.websiteSettings.tagline = value,
              ),
              const SizedBox(height: 24),
              const Text('Branding Assets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text('UPLOAD LOGO'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.language, size: 18),
                      label: const Text('UPLOAD FAVICON'),
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
}
