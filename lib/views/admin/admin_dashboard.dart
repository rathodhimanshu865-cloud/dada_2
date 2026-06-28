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
    'Stotra Section',
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
      case 1: return _stotraView(controller);
      case 2: return _kathaListView(controller);
      case 3: return _aboutKathaView(controller);
      default: return const Center(child: Text('Section not yet implemented'));
    }
  }

  Widget _kathaListView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const Text('Katha List Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildField('Katha List Page Banner Image URL', controller.kathaListPageData.bannerImageUrl, (v) => controller.kathaListPageData.bannerImageUrl = v),
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

                _sectionHeader('2. HERO SECTION'),
                ...List.generate(8, (index) => _buildField(
                  'Hero Image URL ${index + 1}', 
                  index < controller.heroSection.bannerUrls.length ? controller.heroSection.bannerUrls[index] : '', 
                  (v) {
                    if (index < controller.heroSection.bannerUrls.length) {
                      controller.heroSection.bannerUrls[index] = v;
                    }
                  }
                )),

                _sectionHeader('3. UPCOMING KATHAS'),
                ...controller.upcomingKathas.asMap().entries.map((entry) => Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildField('Katha Number', entry.value.kathaNumber, (v) => entry.value.kathaNumber = v),
                        _buildField('Katha Name', entry.value.name, (v) => entry.value.name = v),
                        _buildField('Katha Date', entry.value.dateString, (v) => entry.value.dateString = v),
                        _buildField('Timing', entry.value.timing, (v) => entry.value.timing = v),
                        _buildField('Location', entry.value.location, (v) => entry.value.location = v),
                        _buildField('Hosting', entry.value.hosting, (v) => entry.value.hosting = v),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeKatha(entry.key)),
                      ],
                    ),
                  ),
                )),
                ElevatedButton(onPressed: controller.addKatha, child: const Text('Add Upcoming Katha')),

                _sectionHeader('4. ABOUT SECTION'),
                _buildField('Dada Photo URL', controller.aboutSection.photoUrl, (v) => controller.aboutSection.photoUrl = v),
                _buildField('Description', controller.aboutSection.description, (v) => controller.aboutSection.description = v, maxLines: 5),

                _sectionHeader('5. DAILY SUVICHAR'),
                _buildField('Suvichar Image URL', controller.dailySuvichar.imageUrl, (v) => controller.dailySuvichar.imageUrl = v),
                _buildField('Date', controller.dailySuvichar.date, (v) => controller.dailySuvichar.date = v),

                _sectionHeader('6. VIDEOS'),
                ...controller.videos.asMap().entries.map((entry) => Column(
                  children: [
                    _buildField('Video Title', entry.value.title, (v) => entry.value.title = v),
                    _buildField('YouTube URL', entry.value.youtubeUrl, (v) => entry.value.youtubeUrl = v),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeVideo(entry.key)),
                    const Divider(),
                  ],
                )),
                ElevatedButton(onPressed: controller.addVideo, child: const Text('Add Video')),

                _sectionHeader('7. RAM KATHA BOTTOM'),
                _buildField('Title', controller.ramKatha.title, (v) => controller.ramKatha.title = v),
                _buildField('Para 1', controller.ramKatha.description1, (v) => controller.ramKatha.description1 = v, maxLines: 4),
                _buildField('Para 2', controller.ramKatha.description2, (v) => controller.ramKatha.description2 = v, maxLines: 4),
                _buildField('Photo URL', controller.ramKatha.photoUrl, (v) => controller.ramKatha.photoUrl = v),

                _sectionHeader('8. FOOTER'),
                _buildField('Footer Desc', controller.footer.description, (v) => controller.footer.description = v, maxLines: 3),
                _buildField('Copyright', controller.footer.copyright, (v) => controller.footer.copyright = v),
      ],
    );
  }

  Widget _stotraView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const Text('Stotra / Bhajan / Aarti Section', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(),
        _buildField('Page Title', controller.stotraSection.pageTitle, (v) => controller.stotraSection.pageTitle = v),
        _buildField('Header Image URL', controller.stotraSection.topHeaderImage, (v) => controller.stotraSection.topHeaderImage = v),
        ...controller.stotraSection.items.asMap().entries.map((entry) => Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(entry.value.title.isEmpty ? 'New Item' : entry.value.title),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildField('Title', entry.value.title, (v) => entry.value.title = v),
                    _buildField('English PDF URL', entry.value.englishPdfUrl, (v) => entry.value.englishPdfUrl = v),
                    _buildField('Hindi PDF URL', entry.value.hindiPdfUrl, (v) => entry.value.hindiPdfUrl = v),
                    _buildField('Gujarati PDF URL', entry.value.gujaratiPdfUrl, (v) => entry.value.gujaratiPdfUrl = v),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeStotraItem(entry.key)),
                  ],
                ),
              )
            ],
          ),
        )),
        ElevatedButton(onPressed: controller.addStotraItem, child: const Text('Add New Item')),
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
                _buildField('Main Description', controller.aboutKathaPage.mainItalicDesc, (v) => controller.aboutKathaPage.mainItalicDesc = v, maxLines: 5),
                _buildField('Col 1', controller.aboutKathaPage.subDescCol1, (v) => controller.aboutKathaPage.subDescCol1 = v, maxLines: 3),
                _buildField('Col 2', controller.aboutKathaPage.subDescCol2, (v) => controller.aboutKathaPage.subDescCol2 = v, maxLines: 3),
                _buildField('Col 3', controller.aboutKathaPage.subDescCol3, (v) => controller.aboutKathaPage.subDescCol3 = v, maxLines: 3),
                _buildField('Bio Image', controller.aboutKathaPage.midSectionImage, (v) => controller.aboutKathaPage.midSectionImage = v),
                _buildField('Bio Heading', controller.aboutKathaPage.midSectionTitle, (v) => controller.aboutKathaPage.midSectionTitle = v),
                _buildField('Bio Paragraph', controller.aboutKathaPage.midSectionPara1, (v) => controller.aboutKathaPage.midSectionPara1 = v, maxLines: 5),
                _buildField('Calligraphy URL', controller.aboutKathaPage.signatureImage, (v) => controller.aboutKathaPage.signatureImage = v),
                _buildField('Bottom Para 1', controller.aboutKathaPage.bottomPara1, (v) => controller.aboutKathaPage.bottomPara1 = v, maxLines: 3),
                _buildField('Bottom Para 2', controller.aboutKathaPage.bottomPara2, (v) => controller.aboutKathaPage.bottomPara2 = v, maxLines: 3),
                _buildField('Large Bottom Image', controller.aboutKathaPage.largeBottomImage, (v) => controller.aboutKathaPage.largeBottomImage = v),
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
