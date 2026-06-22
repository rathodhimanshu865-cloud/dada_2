import 'package:flutter/material.dart';
import '../../controllers/homepage_controller.dart';

class ContactInfoSection extends StatelessWidget {
  final HomePageController controller;
  const ContactInfoSection({super.key, required this.controller});

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
        title: const Text('Contact Information', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text('Office address and support channels', style: TextStyle(fontSize: 12)),
        leading: const Icon(Icons.contact_support_outlined, color: Colors.black),
        childrenPadding: const EdgeInsets.all(20),
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Physical Address'),
            maxLines: 2,
            onChanged: (v) => controller.contactInfo.address = v,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Mobile Number', prefixText: '+91 '),
                  onChanged: (v) => controller.contactInfo.mobile = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'WhatsApp Number', prefixText: '+91 '),
                  onChanged: (v) => controller.contactInfo.whatsapp = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Official Email Address'),
            onChanged: (v) => controller.contactInfo.email = v,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Google Maps Location Link'),
            onChanged: (v) => controller.contactInfo.googleMapLink = v,
          ),
        ],
      ),
    );
  }
}
