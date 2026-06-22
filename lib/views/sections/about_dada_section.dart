import 'package:flutter/material.dart';
import '../../controllers/homepage_controller.dart';

class AboutDadaSection extends StatelessWidget {
  final HomePageController controller;
  const AboutDadaSection({super.key, required this.controller});

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
        title: const Text('About Pu. Jigneshdada', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text('Biography and short profile', style: TextStyle(fontSize: 12)),
        leading: const Icon(Icons.person_outline, color: Colors.black),
        childrenPadding: const EdgeInsets.all(20),
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Section Title'),
            onChanged: (v) => controller.aboutDada.title = v,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_a_photo_outlined, size: 18),
            label: const Text('UPLOAD PROFILE PHOTO'),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Short Description',
              hintText: 'Rich text editor placeholder...',
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            onChanged: (v) => controller.aboutDada.description = v,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Read More Button Text'),
                  onChanged: (v) => controller.aboutDada.readMoreText = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Read More URL'),
                  onChanged: (v) => controller.aboutDada.readMoreLink = v,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
