import 'package:flutter/material.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';

class LatestVideosSection extends StatefulWidget {
  final HomePageController controller;
  const LatestVideosSection({super.key, required this.controller});

  @override
  State<LatestVideosSection> createState() => _LatestVideosSectionState();
}

class _LatestVideosSectionState extends State<LatestVideosSection> {
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
        title: const Text('Latest YouTube Videos', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text('Video library and media gallery', style: TextStyle(fontSize: 12)),
        leading: const Icon(Icons.video_library_outlined, color: Colors.black),
        childrenPadding: const EdgeInsets.all(20),
        children: [
          ...widget.controller.latestVideos.asMap().entries.map((entry) {
            int index = entry.key;
            LatestVideo video = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[100]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[200],
                  child: const Icon(Icons.play_circle_outline, color: Colors.black),
                ),
                title: Text(
                  video.title.isEmpty ? "New Video Reference" : video.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(video.youtubeUrl.isEmpty ? 'No URL provided' : video.youtubeUrl, style: const TextStyle(fontSize: 11)),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => widget.controller.removeLatestVideo(index)),
                ),
                onTap: () {
                  // Edit logic
                },
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => widget.controller.addLatestVideo(LatestVideo())),
              icon: const Icon(Icons.video_call_outlined, size: 18),
              label: const Text('ADD VIDEO ENTRY'),
            ),
          ),
        ],
      ),
    );
  }
}
