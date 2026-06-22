import 'package:flutter/material.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';

class UpcomingKathaSection extends StatefulWidget {
  final HomePageController controller;
  const UpcomingKathaSection({super.key, required this.controller});

  @override
  State<UpcomingKathaSection> createState() => _UpcomingKathaSectionState();
}

class _UpcomingKathaSectionState extends State<UpcomingKathaSection> {
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
        title: const Text('Upcoming Katha Schedule', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text('Manage event details and registration links', style: TextStyle(fontSize: 12)),
        leading: const Icon(Icons.event_note_outlined, color: Colors.black),
        childrenPadding: const EdgeInsets.all(20),
        children: [
          ...widget.controller.upcomingKathas.asMap().entries.map((entry) {
            int index = entry.key;
            UpcomingKatha katha = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ExpansionTile(
                title: Text(
                  katha.name.isEmpty ? "New Event Listing" : katha.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.black, size: 20),
                  onPressed: () => setState(() => widget.controller.removeUpcomingKatha(index)),
                ),
                childrenPadding: const EdgeInsets.all(16),
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.image_outlined, size: 16),
                    label: const Text('UPLOAD EVENT BANNER'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Katha Name'),
                    onChanged: (v) => katha.name = v,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: katha.type,
                    items: ['General', 'Special', 'Festival'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => katha.type = v ?? 'General',
                    decoration: const InputDecoration(labelText: 'Katha Type'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Location (Venue Name)'),
                    onChanged: (v) => katha.location = v,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(decoration: const InputDecoration(labelText: 'State'), onChanged: (v) => katha.state = v)),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Country'), onChanged: (v) => katha.country = v)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Google Map Link'),
                    onChanged: (v) => katha.googleMapLink = v,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Published Status'),
                      const Spacer(),
                      Switch(
                        activeColor: Colors.black,
                        value: katha.status,
                        onChanged: (v) => setState(() => katha.status = v),
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
              onPressed: () => setState(() => widget.controller.addUpcomingKatha(UpcomingKatha())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('ADD UPCOMING EVENT'),
            ),
          ),
        ],
      ),
    );
  }
}
