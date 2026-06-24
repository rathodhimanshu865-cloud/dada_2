import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Widget _buildField(String label, String? initialValue, Function(String) onChanged, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue ?? '',
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[50],
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('WEBSITE CONTENT MANAGER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.admin_panel_settings, color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () => controller.publish(),
              icon: controller.isLoading 
                ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.cloud_done, size: 18),
              label: const Text('PUBLISH TO LIVE SITE'),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: controller.isLoading && controller.websiteSettings.name.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
              children: [
                _sectionHeader('1. BRANDING & HEADER'),
                _buildField('Website Name', controller.websiteSettings.name, (v) => controller.websiteSettings.name = v),
                _buildField('Logo URL', controller.websiteSettings.logoUrl, (v) => controller.websiteSettings.logoUrl = v),

                _sectionHeader('2. HERO SECTION (SLIDER - 8 PHOTOS)'),
                ...List.generate(8, (index) => _buildField(
                  'Hero Image URL ${index + 1}', 
                  index < controller.heroSection.bannerUrls.length ? controller.heroSection.bannerUrls[index] : '', 
                  (v) {
                    if (index < controller.heroSection.bannerUrls.length) {
                      controller.heroSection.bannerUrls[index] = v;
                    } else {
                      while (controller.heroSection.bannerUrls.length <= index) {
                        controller.heroSection.bannerUrls.add('');
                      }
                      controller.heroSection.bannerUrls[index] = v;
                    }
                  }
                )),

                _sectionHeader('3. UPCOMING KATHAS LIST'),
                ...controller.upcomingKathas.asMap().entries.map((entry) => Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(4)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildField('Katha Number (ID)', entry.value.kathaNumber, (v) => entry.value.kathaNumber = v),
                        _buildField('Katha Name', entry.value.name, (v) => entry.value.name = v),
                        _buildField('Display Date String', entry.value.dateString, (v) => entry.value.dateString = v),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(entry.value.startDate == null ? 'Select Start Date' : 'Start: ${entry.value.startDate!.toLocal()}'.split(' ')[0]),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: entry.value.startDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() => entry.value.startDate = picked);
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(entry.value.endDate == null ? 'Select End Date' : 'End: ${entry.value.endDate!.toLocal()}'.split(' ')[0]),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: entry.value.endDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() => entry.value.endDate = picked);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => controller.removeKatha(entry.key),
                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                            label: const Text('Remove', style: TextStyle(color: Colors.red)),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
                OutlinedButton.icon(
                  onPressed: controller.addKatha, 
                  icon: const Icon(Icons.add), 
                  label: const Text('ADD NEW KATHA ENTRY'),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                ),

                _sectionHeader('4. ABOUT SECTION'),
                _buildField('Dada Photo URL', controller.aboutSection.photoUrl, (v) {
                  controller.aboutSection.photoUrl = v;
                  setState(() {});
                }),
                if (controller.aboutSection.photoUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Image.network(controller.aboutSection.photoUrl, height: 100, errorBuilder: (c, e, s) => const Text('Invalid Image URL')),
                  ),
                _buildField('Description Text', controller.aboutSection.description, (v) => controller.aboutSection.description = v, maxLines: 6),

                _sectionHeader('5. DADA\'S DAILY SUVICHAR'),
                _buildField('Suvichar Image URL', controller.dailySuvichar.imageUrl, (v) {
                  controller.dailySuvichar.imageUrl = v.trim();
                  setState(() {});
                }),
                if (controller.dailySuvichar.imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Image.network(controller.dailySuvichar.imageUrl, height: 100, errorBuilder: (c, e, s) => const Text('Invalid Image URL')),
                  ),
                _buildField('Display Date (e.g. 24 June 2024)', controller.dailySuvichar.date, (v) => controller.dailySuvichar.date = v),

              _sectionHeader('6. VIDEO GALLERY (YOUTUBE SHORTS)'),
                ...controller.videos.asMap().entries.map((entry) => Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(4)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildField('Video Title', entry.value.title, (v) => entry.value.title = v),
                        _buildField('YouTube Shorts URL', entry.value.youtubeUrl, (v) {
                          entry.value.youtubeUrl = v.trim();
                          setState(() {});
                        }),
                        if (entry.value.youtubeUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Image.network(entry.value.thumbnail, height: 100, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => controller.removeVideo(entry.key),
                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                            label: const Text('Remove Video', style: TextStyle(color: Colors.red)),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
                OutlinedButton.icon(
                  onPressed: controller.addVideo, 
                  icon: const Icon(Icons.video_call), 
                  label: const Text('ADD VIDEO TO LIST'),
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                ),

                _sectionHeader('7. RAM KATHA (BOTTOM SECTION)'),
                _buildField('Section Title', controller.ramKatha.title, (v) => controller.ramKatha.title = v),
                _buildField('Paragraph 1', controller.ramKatha.description1, (v) => controller.ramKatha.description1 = v, maxLines: 4),
                _buildField('Paragraph 2', controller.ramKatha.description2, (v) => controller.ramKatha.description2 = v, maxLines: 4),
                _buildField('Side Image URL', controller.ramKatha.photoUrl, (v) => controller.ramKatha.photoUrl = v),

                _sectionHeader('8. FOOTER SETTINGS'),
                _buildField('Footer Description', controller.footer.description, (v) => controller.footer.description = v, maxLines: 3),
                _buildField('Copyright Text', controller.footer.copyright, (v) => controller.footer.copyright = v),

                const SizedBox(height: 100),
              ],
            ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const Divider(thickness: 2, color: Colors.black),
        ],
      ),
    );
  }
}
