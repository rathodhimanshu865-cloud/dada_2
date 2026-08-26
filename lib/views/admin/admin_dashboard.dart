import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';
import 'about_profile_management.dart';
import 'order_management_view.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentMenuIndex = 0;
  final Map<String, double> _uploadProgress = {};

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN CONTROL CENTER'),
        actions: [
          ElevatedButton.icon(
            onPressed: controller.translateAndPublish,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('TRANSLATE & PUBLISH ALL'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
          ),
          const SizedBox(width: 20),
          IconButton(onPressed: controller.loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildMainContent(controller)),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final menus = [
      {'title': 'General Settings', 'icon': Icons.settings},
      {'title': 'Hero Slider', 'icon': Icons.burst_mode},
      {'title': 'About Jignesh Dada', 'icon': Icons.person},
      {'title': 'Katha Pages (3)', 'icon': Icons.menu_book},
      {'title': 'Upcoming Kathas', 'icon': Icons.event},
      {'title': 'Homepage Data', 'icon': Icons.home},
      {'title': 'News & Updates', 'icon': Icons.newspaper},
      {'title': 'Full Katha List', 'icon': Icons.list_alt},
      {'title': 'Photo Gallery', 'icon': Icons.photo_library},
      {'title': 'Video Gallery', 'icon': Icons.video_library},
      {'title': 'Stotra / Bhajan', 'icon': Icons.music_note},
      {'title': 'Contact / Inquiries', 'icon': Icons.contact_mail},
      {'title': 'Footer Settings', 'icon': Icons.south},
      {'title': 'Orders / Store', 'icon': Icons.shopping_cart},
    ];

    return Container(
      width: 280,
      color: const Color(0xFF1A1A1A),
      child: ListView.builder(
        itemCount: menus.length,
        itemBuilder: (context, i) => ListTile(
          leading: Icon(menus[i]['icon'] as IconData, color: currentMenuIndex == i ? Colors.amber : Colors.white60),
          title: Text(menus[i]['title'] as String, style: TextStyle(color: currentMenuIndex == i ? Colors.white : Colors.white70, fontWeight: currentMenuIndex == i ? FontWeight.bold : FontWeight.normal)),
          selected: currentMenuIndex == i,
          onTap: () => setState(() => currentMenuIndex = i),
        ),
      ),
    );
  }

  Widget _buildMainContent(HomePageController controller) {
    switch (currentMenuIndex) {
      case 0: return _generalSettingsView(controller);
      case 1: return _heroSliderView(controller);
      case 2: return _biographyView(controller);
      case 3: return _kathaPagesView(controller);
      case 4: return _upcomingKathasView(controller);
      case 5: return _homepageDataView(controller);
      case 6: return _newsView(controller);
      case 7: return _kathaListView(controller);
      case 8: return _photoGalleryView(controller);
      case 9: return _videoGalleryView(controller);
      case 10: return _stotraView(controller);
      case 11: return _contactPageView(controller);
      case 12: return _footerSettingsView(controller);
      case 13: return const OrderManagementView();
      default: return const Center(child: Text('Select a menu'));
    }
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

  Widget _buildField(String label, String value, Function(String) onChanged, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
        onChanged: onChanged,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _buildImageField(String label, String currentUrl, Function(String) onUploaded) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (currentUrl.isNotEmpty) Image.network(currentUrl, width: 60, height: 60, fit: BoxFit.cover),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
            ElevatedButton(
              onPressed: () async {
                final url = await Provider.of<HomePageController>(context, listen: false).uploadPhotoFromFile();
                if (url != null) onUploaded(url);
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _generalSettingsView(HomePageController controller) {
    final s = controller.websiteSettings;
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        _sectionHeader('GENERAL WEBSITE SETTINGS'),
        _buildImageField('Website Logo', s.logoUrl, (v) => setState(() => s.logoUrl = v)),
        _buildField('Announcement Bar Text', s.headerSettings.announcementBarText, (v) => s.headerSettings.announcementBarText = v),
        _buildField('Donate Button Text', s.headerSettings.donateButtonText, (v) => s.headerSettings.donateButtonText = v),
      ],
    );
  }

  Widget _heroSliderView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('HOMEPAGE HERO SLIDER'),
        ...controller.heroSection.slides.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Slide #${i + 1}'), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeHeroSlide(i))]),
                  _buildField('Badge Text (e.g. NAMASTE)', s.badge, (v) => s.badge = v),
                  _buildField('Main Heading', s.heading, (v) => s.heading = v),
                  _buildField('Subtitle', s.subtitle, (v) => s.subtitle = v),
                  _buildField('Description', s.description, (v) => s.description = v, maxLines: 3),
                  _buildImageField('Slide Background Image', s.image, (v) => setState(() => s.image = v)),
                ],
              ),
            ),
          );
        }),
        ElevatedButton.icon(onPressed: controller.addHeroSlide, icon: const Icon(Icons.add), label: const Text('ADD NEW SLIDE')),
      ],
    );
  }

  Widget _biographyView(HomePageController controller) {
    final b = controller.aboutDadaPage;
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('BIOGRAPHY PAGE CONTENT'),
        _buildField('Hero Title', b.heroTitle, (v) => b.heroTitle = v),
        _buildField('Hero Subtitle', b.heroSubtitle, (v) => b.heroSubtitle = v),
        ...b.phases.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 30),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Life Phase #${i+1}'), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeBiographyPhase(i))]),
                  _buildField('Phase Title', p.title, (v) => p.title = v),
                  _buildField('Phase Subtitle', p.subtitle, (v) => p.subtitle = v),
                  _buildField('Content / Story', p.content, (v) => p.content = v, maxLines: 10),
                  _sectionHeader('Phase Images'),
                  Wrap(
                    children: [
                      ...p.images.asMap().entries.map((img) => Stack(
                        children: [
                          Image.network(img.value, width: 100, height: 100, fit: BoxFit.cover),
                          IconButton(icon: const Icon(Icons.cancel, color: Colors.white), onPressed: () => controller.removeImageFromPhase(i, img.key)),
                        ],
                      )),
                      IconButton(icon: const Icon(Icons.add_a_photo, size: 40), onPressed: () async {
                        final url = await controller.uploadPhotoFromFile();
                        if (url != null) controller.addImageToPhase(i, url);
                      }),
                    ],
                  )
                ],
              ),
            ),
          );
        }),
        ElevatedButton(onPressed: controller.addBiographyPhase, child: const Text('Add Life Phase')),
      ],
    );
  }

  Widget _kathaPagesView(HomePageController controller) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'Bhagvat Katha'), Tab(text: 'Devi Katha'), Tab(text: 'Shiv Katha')], labelColor: Colors.black),
          Expanded(child: TabBarView(children: [
            _singleKathaPageView(controller.bhagvatKathaPage),
            _singleKathaPageView(controller.deviKathaPage),
            _singleKathaPageView(controller.shivKathaPage),
          ])),
        ],
      ),
    );
  }

  Widget _singleKathaPageView(KathaAboutPageData k) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        _buildField('Hero Badge', k.heroBadge, (v) => k.heroBadge = v),
        _buildField('Hero Title', k.heroTitle, (v) => k.heroTitle = v),
        _buildField('Description 1', k.heroDesc1, (v) => k.heroDesc1 = v, maxLines: 4),
        _buildField('Description 2', k.heroDesc2, (v) => k.heroDesc2 = v, maxLines: 4),
        _buildImageField('Katha Main Image', k.heroImage, (v) => setState(() => k.heroImage = v)),
        _buildField('Quote Text', k.quoteText, (v) => k.quoteText = v, maxLines: 3),
        _buildField('Quote Author', k.quoteAuthor, (v) => k.quoteAuthor = v),
      ],
    );
  }

  Widget _upcomingKathasView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('UPCOMING KATHAS'),
        ...controller.upcomingKathas.asMap().entries.map((entry) {
          final i = entry.key;
          final k = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Event #${i+1}'), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeKatha(i))]),
                  _buildField('Katha Name', k.name, (v) => k.name = v),
                  _buildField('Location', k.location, (v) => k.location = v),
                  _buildField('Date (String)', k.dateString, (v) => k.dateString = v),
                ],
              ),
            ),
          );
        }),
        ElevatedButton(onPressed: controller.addKatha, child: const Text('Add Upcoming Katha')),
      ],
    );
  }

  Widget _homepageDataView(HomePageController controller) {
    return const Center(child: Text('Homepage Data view here'));
  }

  Widget _newsView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('LATEST NEWS'),
        ...controller.homepageData.news.asMap().entries.map((entry) => Card(
          child: Column(
            children: [
              _buildField('Title', entry.value.title, (v) => entry.value.title = v),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => controller.homepageData.news.removeAt(entry.key))),
            ],
          ),
        )),
        ElevatedButton(onPressed: () => setState(() => controller.homepageData.news.add(NewsItem())), child: const Text('Add News')),
      ],
    );
  }

  Widget _kathaListView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('FULL KATHA ARCHIVE'),
        ...controller.allKathas.asMap().entries.map((entry) => Card(
          child: Column(
            children: [
              _buildField('Topic', entry.value.topic, (v) => entry.value.topic = v),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeKathaRecord(entry.key)),
            ],
          ),
        )),
        ElevatedButton(onPressed: controller.addKathaRecord, child: const Text('Add Archive Entry')),
      ],
    );
  }

  Widget _photoGalleryView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('PHOTO GALLERY UPLOAD'),
        ElevatedButton.icon(
          icon: const Icon(Icons.upload),
          label: const Text('UPLOAD NEW PHOTOS'),
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);
            if (result != null) {
              for (var file in result.files) {
                if (file.bytes != null) {
                  controller.uploadPhotoWithProgress(file.name, file.bytes!).listen((p) {});
                }
              }
            }
          },
        ),
      ],
    );
  }

  Widget _videoGalleryView(HomePageController controller) {
    return const Center(child: Text('Video Gallery management here'));
  }

  Widget _stotraView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('STOTRA / BHAJAN'),
        ...controller.stotraSection.items.asMap().entries.map((entry) => Card(
          child: Column(
            children: [
              _buildField('Title', entry.value.title, (v) => entry.value.title = v),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeStotraItem(entry.key)),
            ],
          ),
        )),
        ElevatedButton(onPressed: controller.addStotraItem, child: const Text('Add Stotra')),
      ],
    );
  }

  Widget _contactPageView(HomePageController controller) {
    return const Center(child: Text('Contact Page view here'));
  }

  Widget _footerSettingsView(HomePageController controller) {
    return const Center(child: Text('Footer Settings here'));
  }
}
