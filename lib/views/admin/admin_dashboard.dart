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
    'Video Gallery',
    'Photo Gallery',
    'Navigation Settings'
  ];

  Widget _buildField(String label, String? initialValue, Function(String) onChanged, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: Key(initialValue ?? ''), // Force rebuild if initial value changes from external (like picker)
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

  Widget _imagePreview(String url) {
    if (url.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          url,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            height: 100,
            width: 150,
            color: Colors.grey[200],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.grey),
                Text('Invalid Link', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ),
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
      case 4: return _videoGalleryView(controller);
      case 5: return _photoGalleryView(controller);
      default: return const Center(child: Text('Section not yet implemented'));
    }
  }

  Widget _videoGalleryView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const Text('Video Gallery Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(),
        _buildField('Header Image URL', controller.videoGalleryData.headerImageUrl, (v) => controller.videoGalleryData.headerImageUrl = v),
        _imagePreview(controller.videoGalleryData.headerImageUrl),
        const SizedBox(height: 20),
        const Text('Manage Video Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...controller.videoGalleryData.categories.asMap().entries.map((catEntry) {
          int catIdx = catEntry.key;
          VideoCategory cat = catEntry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: ExpansionTile(
              title: Text('Category: ${cat.categoryTitle.isEmpty ? "New Category" : cat.categoryTitle}'),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeVideoCategory(catIdx)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildField('Category Title', cat.categoryTitle, (v) => setState(() => cat.categoryTitle = v)),
                      const SizedBox(height: 10),
                      const Text('Videos in this category', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(),
                      ...cat.videos.asMap().entries.map((vidEntry) {
                        int vidIdx = vidEntry.key;
                        VideoGalleryEntry vid = vidEntry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(4)),
                          child: Column(
                            children: [
                              _buildField('Video Title', vid.title, (v) => vid.title = v),
                              _buildField('YouTube URL', vid.youtubeUrl, (v) => setState(() => vid.youtubeUrl = v.trim())),
                              if (vid.youtubeUrl.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Image.network(vid.thumbnail, height: 60, errorBuilder: (c,e,s) => const Icon(Icons.broken_image)),
                                ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => controller.removeVideoFromCategory(catIdx, vidIdx),
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 16),
                                  label: const Text('Remove Video', style: TextStyle(color: Colors.red, fontSize: 12)),
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                      ElevatedButton.icon(
                        onPressed: () => controller.addVideoToCategory(catIdx),
                        icon: const Icon(Icons.add),
                        label: const Text('ADD VIDEO TO CATEGORY'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
        ElevatedButton.icon(
          onPressed: controller.addVideoCategory,
          icon: const Icon(Icons.create_new_folder),
          label: const Text('CREATE NEW VIDEO CATEGORY'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _photoGalleryView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const Text('Photo Gallery Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildField('Header Image URL', controller.photoGalleryData.headerImageUrl, (v) => controller.photoGalleryData.headerImageUrl = v),
        _imagePreview(controller.photoGalleryData.headerImageUrl),
        _buildField('Gallery Title', controller.photoGalleryData.title, (v) => controller.photoGalleryData.title = v),
        const SizedBox(height: 20),
        const Text('Photo Gallery Headings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...controller.photoGalleryData.sections.asMap().entries.map((sectionEntry) {
          int sectionIdx = sectionEntry.key;
          final section = sectionEntry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: ExpansionTile(
              title: Text('Heading ${sectionIdx + 1}: ${section.heading.isEmpty ? "Untitled" : section.heading}'),
                  children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildField('Heading Text', section.heading, (v) => setState(() => section.heading = v)),
                      const SizedBox(height: 10),
                      const Text('Images in this section', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: section.photoUrls.asMap().entries.map((photoEntry) {
                          int photoIdx = photoEntry.key;
                          final photoUrl = photoEntry.value;
                          return Container(
                            width: 200,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(4)),
                            child: Column(
                              children: [
                                _imagePreview(photoUrl),
                                TextFormField(
                                  initialValue: photoUrl,
                                  decoration: const InputDecoration(labelText: 'Image URL'),
                                  onChanged: (v) => setState(() => section.photoUrls[photoIdx] = v),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                                    onPressed: () => controller.removePhotoFromCategory(sectionIdx, photoIdx),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => controller.addPhotoUrlToSection(sectionIdx),
                              icon: const Icon(Icons.link),
                              label: const Text('ADD IMAGE LINK'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => controller.addPhotoToCategoryFromPicker(sectionIdx),
                              icon: const Icon(Icons.upload_file),
                              label: const Text('UPLOAD FROM PC'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _kathaListView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const Text('Katha List Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildField('Katha List Page Banner Image URL', controller.kathaListPageData.bannerImageUrl, (v) => controller.kathaListPageData.bannerImageUrl = v),
        _imagePreview(controller.kathaListPageData.bannerImageUrl),
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
                      _imagePreview(k.imageUrl),
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
                _imagePreview(controller.websiteSettings.logoUrl),

                _sectionHeader('2. HERO SECTION'),
                ...List.generate(8, (index) => Column(
                  children: [
                    _buildField(
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
                        setState(() {});
                      }
                    ),
                    if (index < controller.heroSection.bannerUrls.length)
                      _imagePreview(controller.heroSection.bannerUrls[index]),
                  ],
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
                _buildField('Dada Photo URL', controller.aboutSection.photoUrl, (v) {
                  controller.aboutSection.photoUrl = v;
                  setState(() {});
                }),
                _imagePreview(controller.aboutSection.photoUrl),
                _buildField('Description', controller.aboutSection.description, (v) => controller.aboutSection.description = v, maxLines: 5),

                _sectionHeader('5. DAILY SUVICHAR'),
                _buildField('Suvichar Image URL', controller.dailySuvichar.imageUrl, (v) {
                  controller.dailySuvichar.imageUrl = v;
                  setState(() {});
                }),
                _imagePreview(controller.dailySuvichar.imageUrl),
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
                _buildField('Para 1', controller.ramKatha.description1, (v) => controller.ramKatha.description1 = v, maxLines: 4),
                _buildField('Para 2', controller.ramKatha.description2, (v) => controller.ramKatha.description2 = v, maxLines: 4),
                _buildField('Photo URL', controller.ramKatha.photoUrl, (v) {
                  controller.ramKatha.photoUrl = v;
                  setState(() {});
                }),
                _imagePreview(controller.ramKatha.photoUrl),

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
        _imagePreview(controller.stotraSection.topHeaderImage),
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
                _buildField('Top Header Image URL', controller.aboutKathaPage.topHeaderImage, (v) {
                  controller.aboutKathaPage.topHeaderImage = v;
                  setState(() {});
                }),
                _imagePreview(controller.aboutKathaPage.topHeaderImage),
                _buildField('Page Title', controller.aboutKathaPage.title, (v) => controller.aboutKathaPage.title = v),
                _buildField('Main Description', controller.aboutKathaPage.mainItalicDesc, (v) => controller.aboutKathaPage.mainItalicDesc = v, maxLines: 5),
                _buildField('Col 1', controller.aboutKathaPage.subDescCol1, (v) => controller.aboutKathaPage.subDescCol1 = v, maxLines: 3),
                _buildField('Col 2', controller.aboutKathaPage.subDescCol2, (v) => controller.aboutKathaPage.subDescCol2 = v, maxLines: 3),
                _buildField('Col 3', controller.aboutKathaPage.subDescCol3, (v) => controller.aboutKathaPage.subDescCol3 = v, maxLines: 3),
                _buildField('Bio Image', controller.aboutKathaPage.midSectionImage, (v) {
                  controller.aboutKathaPage.midSectionImage = v;
                  setState(() {});
                }),
                _imagePreview(controller.aboutKathaPage.midSectionImage),
                _buildField('Bio Heading', controller.aboutKathaPage.midSectionTitle, (v) => controller.aboutKathaPage.midSectionTitle = v),
                _buildField('Bio Paragraph', controller.aboutKathaPage.midSectionPara1, (v) => controller.aboutKathaPage.midSectionPara1 = v, maxLines: 5),
                _buildField('Calligraphy URL', controller.aboutKathaPage.signatureImage, (v) {
                  controller.aboutKathaPage.signatureImage = v;
                  setState(() {});
                }),
                _imagePreview(controller.aboutKathaPage.signatureImage),
                _buildField('Bottom Para 1', controller.aboutKathaPage.bottomPara1, (v) => controller.aboutKathaPage.bottomPara1 = v, maxLines: 3),
                _buildField('Bottom Para 2', controller.aboutKathaPage.bottomPara2, (v) => controller.aboutKathaPage.bottomPara2 = v, maxLines: 3),
                _buildField('Large Bottom Image', controller.aboutKathaPage.largeBottomImage, (v) {
                  controller.aboutKathaPage.largeBottomImage = v;
                  setState(() {});
                }),
                _imagePreview(controller.aboutKathaPage.largeBottomImage),
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
