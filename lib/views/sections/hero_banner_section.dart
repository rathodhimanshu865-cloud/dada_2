import 'package:flutter/material.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';

class HeroBannerSection extends StatefulWidget {
  final HomePageController controller;
  const HeroBannerSection({super.key, required this.controller});

  @override
  State<HeroBannerSection> createState() => _HeroBannerSectionState();
}

class _HeroBannerSectionState extends State<HeroBannerSection> {
  void _addNewBanner() {
    setState(() {
      widget.controller.addHeroBanner(HeroBanner());
    });
  }

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
        title: const Text('Hero Banner Section', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text('Main website sliders and call-to-actions', style: TextStyle(fontSize: 12)),
        leading: const Icon(Icons.view_carousel_outlined, color: Colors.black),
        childrenPadding: const EdgeInsets.all(20),
        children: [
          if (widget.controller.heroBanners.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No banners added yet.', style: TextStyle(color: Colors.grey[400])),
              ),
            ),
          ...widget.controller.heroBanners.asMap().entries.map((entry) {
            int index = entry.key;
            HeroBanner banner = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ExpansionTile(
                title: Text(
                  'Banner #${index + 1}: ${banner.heading.isEmpty ? "Untitled" : banner.heading}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.black, size: 20),
                  onPressed: () => setState(() => widget.controller.removeHeroBanner(index)),
                ),
                childrenPadding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.desktop_windows_outlined, size: 16),
                          label: const Text('DESKTOP IMAGE', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.smartphone_outlined, size: 16),
                          label: const Text('MOBILE IMAGE', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Banner Heading'),
                    onChanged: (v) => banner.heading = v,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Sub-Heading / Description'),
                    maxLines: 2,
                    onChanged: (v) => banner.subHeading = v,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'Button 1 Text'),
                          onChanged: (v) => banner.button1Text = v,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'Button 1 URL'),
                          onChanged: (v) => banner.button1Link = v,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'Sort Order'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => banner.sortOrder = int.tryParse(v) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Active Status'),
                      Switch(
                        activeColor: Colors.black,
                        value: banner.status,
                        onChanged: (v) => setState(() => banner.status = v),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addNewBanner,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('ADD NEW HERO BANNER'),
            ),
          ),
        ],
      ),
    );
  }
}
