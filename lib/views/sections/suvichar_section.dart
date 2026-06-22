import 'package:flutter/material.dart';
import '../../controllers/homepage_controller.dart';

class SuvicharSection extends StatelessWidget {
  final HomePageController controller;
  const SuvicharSection({super.key, required this.controller});

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
        title: const Text('Daily Suvichar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text('Inspirational quotes and author attribution', style: TextStyle(fontSize: 12)),
        leading: const Icon(Icons.format_quote_outlined, color: Colors.black),
        childrenPadding: const EdgeInsets.all(20),
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Suvichar Text Content'),
            maxLines: 3,
            onChanged: (v) => controller.suvichar.text = v,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Author Name'),
            onChanged: (v) => controller.suvichar.author = v,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.wallpaper_outlined, size: 18),
            label: const Text('UPLOAD BACKGROUND TEXTURE'),
          ),
        ],
      ),
    );
  }
}
