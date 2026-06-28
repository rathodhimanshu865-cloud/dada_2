import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentMenuIndex = 0;

  final List<String> menuItems = [
    'Homepage Sections',
    'Full Katha List',
    'About Katha Page',
    'Navigation Settings'
  ];

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
        title: Text('ADMIN - ${menuItems[currentMenuIndex].toUpperCase()}'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu, color: Colors.black), onPressed: () => Scaffold.of(context).openDrawer())),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            onPressed: () => controller.publish(),
            icon: controller.isLoading ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.publish),
            label: const Text('PUBLISH ALL CHANGES'),
          ),
          const SizedBox(width: 20),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(child: Center(child: Text('DADA PANEL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)))),
            ...menuItems.asMap().entries.map((e) => ListTile(
              title: Text(e.value),
              selected: currentMenuIndex == e.key,
              onTap: () {
                setState(() => currentMenuIndex = e.key);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
      body: controller.isLoading && controller.websiteSettings.name.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _buildCurrentView(controller),
    );
  }

  Widget _buildCurrentView(HomePageController controller) {
    switch (currentMenuIndex) {
      case 0: return _homepageView(controller);
      case 1: return _kathaListView(controller);
      case 2: return _aboutKathaView(controller);
      default: return const Center(child: Text('Select a section from the menu'));
    }
  }

  Widget _kathaListView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const Text('Katha List Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildField('Katha List Page Banner Image URL', controller.kathaListPageData.bannerImageUrl, (v) => controller.kathaListPageData.bannerImageUrl = v),
        if (controller.kathaListPageData.bannerImageUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Image.network(controller.kathaListPageData.bannerImageUrl, height: 100, errorBuilder: (c,e,s) => const Text('Invalid Image URL')),
          ),
        const Divider(),
        const SizedBox(height: 20),
        const Text('Manage Full Katha List Records', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(),
        ...controller.allKathas.asMap().entries.map((entry) {
          int index = entry.key;
          KathaRecord k = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: ExpansionTile(
              title: Text('Katha #${k.kathaNumber}: ${k.topic} (${k.location})'),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeKathaRecord(index)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildField('Katha #', k.kathaNumber, (v) => k.kathaNumber = v)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildField('Year', k.year, (v) => k.year = v)),
                        ],
                      ),
                      _buildField('Display Dates', k.dates, (v) => k.dates = v),
                      _buildField('Katha Topic / Heading', k.topic, (v) => k.topic = v),
                      _buildField('Location', k.location, (v) => k.location = v),
                      Row(
                        children: [
                          Expanded(child: _buildField('Country', k.country, (v) => k.country = v)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildField('Language', k.language, (v) => k.language = v)),
                        ],
                      ),
                      _buildField('YouTube Playlist URL', k.youtubePlaylistUrl, (v) => k.youtubePlaylistUrl = v),
                      _buildField('Image URL', k.imageUrl, (v) => setState(() => k.imageUrl = v)),
                      _buildField('Description', k.description, (v) => k.description = v, maxLines: 5),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        ElevatedButton.icon(onPressed: controller.addKathaRecord, icon: const Icon(Icons.add), label: const Text('ADD NEW KATHA RECORD')),
      ],
    );
  }

  Widget _homepageView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.all(40),
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

                _sectionHeader('3. UPCOMING KATHAS LIST (HOMEPAGE)'),
                ...controller.upcomingKathas.asMap().entries.map((entry) => Card(
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
                          child: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeKatha(entry.key)),
                        )
                      ],
                    ),
                  ),
                )),
                ElevatedButton(onPressed: controller.addKatha, child: const Text('Add Home Page Katha')),

                _sectionHeader('4. ABOUT SECTION (HOMEPAGE)'),
                _buildField('Dada Photo URL', controller.aboutSection.photoUrl, (v) => controller.aboutSection.photoUrl = v),
                _buildField('Description', controller.aboutSection.description, (v) => controller.aboutSection.description = v, maxLines: 5),

                _sectionHeader('5. DADA\'S DAILY SUVICHAR'),
                _buildField('Suvichar Image URL', controller.dailySuvichar.imageUrl, (v) => controller.dailySuvichar.imageUrl = v),
                _buildField('Display Date', controller.dailySuvichar.date, (v) => controller.dailySuvichar.date = v),

              _sectionHeader('6. VIDEO GALLERY (SHORTS)'),
                ...controller.videos.asMap().entries.map((entry) => Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildField('Video Title', entry.value.title, (v) => entry.value.title = v),
                        _buildField('YouTube URL', entry.value.youtubeUrl, (v) => entry.value.youtubeUrl = v),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeVideo(entry.key)),
                        )
                      ],
                    ),
                  ),
                )),
                ElevatedButton(onPressed: controller.addVideo, child: const Text('Add Video')),

                _sectionHeader('7. RAM KATHA (BOTTOM SECTION)'),
                _buildField('Paragraph 1', controller.ramKatha.description1, (v) => controller.ramKatha.description1 = v, maxLines: 4),
                _buildField('Paragraph 2', controller.ramKatha.description2, (v) => controller.ramKatha.description2 = v, maxLines: 4),
                _buildField('Photo URL', controller.ramKatha.photoUrl, (v) => controller.ramKatha.photoUrl = v),

                _sectionHeader('8. FOOTER SETTINGS'),
                _buildField('Footer Description', controller.footer.description, (v) => controller.footer.description = v, maxLines: 3),
                _buildField('Copyright Text', controller.footer.copyright, (v) => controller.footer.copyright = v),
      ],
    );
  }

  Widget _aboutKathaView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
                _sectionHeader('ABOUT KATHA PAGE CONTENT'),
                _buildField('Top Header Image URL', controller.aboutKathaPage.topHeaderImage, (v) => controller.aboutKathaPage.topHeaderImage = v),
                _buildField('Page Title', controller.aboutKathaPage.title, (v) => controller.aboutKathaPage.title = v),
                _buildField('Main Description (Italic)', controller.aboutKathaPage.mainItalicDesc, (v) => controller.aboutKathaPage.mainItalicDesc = v, maxLines: 5),
                _buildField('Sub Desc Column 1', controller.aboutKathaPage.subDescCol1, (v) => controller.aboutKathaPage.subDescCol1 = v, maxLines: 3),
                _buildField('Sub Desc Column 2', controller.aboutKathaPage.subDescCol2, (v) => controller.aboutKathaPage.subDescCol2 = v, maxLines: 3),
                _buildField('Sub Desc Column 3', controller.aboutKathaPage.subDescCol3, (v) => controller.aboutKathaPage.subDescCol3 = v, maxLines: 3),
                const Divider(),
                const Text('Biography Section', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildField('Biography Image URL', controller.aboutKathaPage.midSectionImage, (v) => controller.aboutKathaPage.midSectionImage = v),
                _buildField('Biography Heading', controller.aboutKathaPage.midSectionTitle, (v) => controller.aboutKathaPage.midSectionTitle = v),
                _buildField('Biography Paragraph', controller.aboutKathaPage.midSectionPara1, (v) => controller.aboutKathaPage.midSectionPara1 = v, maxLines: 5),
                const Divider(),
                const Text('Bottom Section', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildField('Calligraphy URL', controller.aboutKathaPage.signatureImage, (v) => controller.aboutKathaPage.signatureImage = v),
                _buildField('Bottom Para 1', controller.aboutKathaPage.bottomPara1, (v) => controller.aboutKathaPage.bottomPara1 = v, maxLines: 3),
                _buildField('Bottom Para 2', controller.aboutKathaPage.bottomPara2, (v) => controller.aboutKathaPage.bottomPara2 = v, maxLines: 3),
                _buildField('Large Bottom Image URL', controller.aboutKathaPage.largeBottomImage, (v) => controller.aboutKathaPage.largeBottomImage = v),
      ],
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
