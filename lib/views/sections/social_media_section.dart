import 'package:flutter/material.dart';
import '../../controllers/homepage_controller.dart';

class SocialMediaSection extends StatelessWidget {
  final HomePageController controller;
  const SocialMediaSection({super.key, required this.controller});

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
        title: const Text('Social Media Integration', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text('Official platform links and handles', style: TextStyle(fontSize: 12)),
        leading: const Icon(Icons.share_outlined, color: Colors.black),
        childrenPadding: const EdgeInsets.all(20),
        children: [
          _buildSocialField('Facebook URL', Icons.facebook, (v) => controller.socialMedia.facebook = v),
          const SizedBox(height: 12),
          _buildSocialField('Instagram URL', Icons.camera_alt_outlined, (v) => controller.socialMedia.instagram = v),
          const SizedBox(height: 12),
          _buildSocialField('YouTube Channel', Icons.play_circle_outline, (v) => controller.socialMedia.youtube = v),
          const SizedBox(height: 12),
          _buildSocialField('WhatsApp Number', Icons.chat_bubble_outline, (v) => controller.socialMedia.whatsapp = v),
          const SizedBox(height: 12),
          _buildSocialField('Telegram Link', Icons.send_outlined, (v) => controller.socialMedia.telegram = v),
          const SizedBox(height: 12),
          _buildSocialField('Twitter / X Handle', Icons.alternate_email, (v) => controller.socialMedia.twitter = v),
        ],
      ),
    );
  }

  Widget _buildSocialField(String label, IconData icon, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: Colors.black),
      ),
      onChanged: onChanged,
    );
  }
}
