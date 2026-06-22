import 'package:flutter/material.dart';
import '../../controllers/homepage_controller.dart';

class NoticeBarSection extends StatefulWidget {
  final HomePageController controller;
  const NoticeBarSection({super.key, required this.controller});

  @override
  State<NoticeBarSection> createState() => _NoticeBarSectionState();
}

class _NoticeBarSectionState extends State<NoticeBarSection> {
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
        title: const Text('Top Notice Bar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text('Promotional alerts and announcements', style: TextStyle(fontSize: 12)),
        leading: const Icon(Icons.campaign_outlined, color: Colors.black),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable Notice Bar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('Show or hide the bar at the top of the site'),
            activeColor: Colors.black,
            value: widget.controller.noticeBar.enabled,
            onChanged: (value) {
              setState(() {
                widget.controller.noticeBar.enabled = value;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Notice Text'),
            onChanged: (value) => widget.controller.noticeBar.text = value,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Action Link (URL)'),
            onChanged: (value) => widget.controller.noticeBar.link = value,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Open In New Tab', style: TextStyle(fontSize: 13)),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Colors.black,
            value: widget.controller.noticeBar.openInNewTab,
            onChanged: (value) {
              setState(() {
                widget.controller.noticeBar.openInNewTab = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }
}
