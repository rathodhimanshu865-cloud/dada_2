import 'package:flutter/material.dart';
import '../../controllers/homepage_controller.dart';

class FooterSettingsSection extends StatelessWidget {
  final HomePageController controller;
  const FooterSettingsSection({super.key, required this.controller});

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
        title: const Text('Footer Configuration', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text('Copyright notice and policy links', style: TextStyle(fontSize: 12)),
        leading: const Icon(Icons.info_outline, color: Colors.black),
        childrenPadding: const EdgeInsets.all(20),
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Footer Description Text'),
            maxLines: 2,
            onChanged: (v) => controller.footerSettings.description = v,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Copyright Copyright Attribution'),
            onChanged: (v) => controller.footerSettings.copyrightText = v,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Privacy Policy URL'),
                  onChanged: (v) => controller.footerSettings.privacyPolicyLink = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Terms & Conditions URL'),
                  onChanged: (v) => controller.footerSettings.termsConditionsLink = v,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
