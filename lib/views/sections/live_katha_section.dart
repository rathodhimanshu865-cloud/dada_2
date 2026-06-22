import 'package:flutter/material.dart';
import '../../controllers/homepage_controller.dart';

class LiveKathaSection extends StatefulWidget {
  final HomePageController controller;
  const LiveKathaSection({super.key, required this.controller});

  @override
  State<LiveKathaSection> createState() => _LiveKathaSectionState();
}

class _LiveKathaSectionState extends State<LiveKathaSection> {
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
        title: const Text('Live Katha Section', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text('YouTube live stream settings', style: TextStyle(fontSize: 12)),
        leading: const Icon(Icons.live_tv_outlined, color: Colors.black),
        childrenPadding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show Live Section', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            activeColor: Colors.black,
            value: widget.controller.liveKatha.showLiveSection,
            onChanged: (v) => setState(() => widget.controller.liveKatha.showLiveSection = v),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Section Title'),
            onChanged: (v) => widget.controller.liveKatha.title = v,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Section Description'),
            maxLines: 2,
            onChanged: (v) => widget.controller.liveKatha.description = v,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'YouTube Live URL'),
            onChanged: (v) => widget.controller.liveKatha.youtubeLiveUrl = v,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.image_outlined, size: 18),
            label: const Text('UPLOAD VIDEO THUMBNAIL'),
          ),
        ],
      ),
    );
  }
}
