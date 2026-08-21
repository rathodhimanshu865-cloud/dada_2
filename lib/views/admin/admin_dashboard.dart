import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';
import 'about_profile_management.dart';
import 'order_management_view.dart';
import 'products/admin_product_list.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentMenuIndex = 0;
  final Map<String, double> _uploadProgress = {};

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  final List<String> menuItems = [
    'Branding & Hero Slider',
    'Biography (About Dada)',
    'Detailed Katha Pages',
    'Homepage Sections',
    'Stotra / Bhajan / Aarti',
    'Upcoming Kathas',
    'Latest Videos',
    'Latest News',
    'Full Katha List',
    'Photo Gallery',
    'Video Gallery',
    'Orders',
    'Enquiries',
    'Contact Page Settings',
    'Footer Settings',
    'Products Management'
  ];

  Widget _buildField(String label, String? initialValue, Function(String) onChanged, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: Key(initialValue ?? ''), 
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

  Widget _buildDateField(String label, DateTime? initialDate, Function(DateTime) onDateSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: initialDate ?? DateTime.now(),
            firstDate: DateTime(2024),
            lastDate: DateTime(2030),
          );
          if (date != null) onDateSelected(date);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.grey[50],
            border: const OutlineInputBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(initialDate != null ? DateFormat('dd MMM yyyy').format(initialDate) : 'Select Date'),
              const Icon(Icons.calendar_month, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageField(String label, String? initialValue, Function(String) onChanged) {
    final controller = Provider.of<HomePageController>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: Key(initialValue ?? ''),
                  initialValue: initialValue ?? '',
                  decoration: InputDecoration(
                    hintText: 'Paste image URL or upload file...',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: controller.isUploading ? null : () async {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Starting upload...')));
                  final url = await controller.uploadPhotoFromFile();
                  if (url != null) {
                    onChanged(url);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload Successful!')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload Failed. Check Firebase Storage/Rules.')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                icon: controller.isUploading 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.upload_file, size: 18),
                label: Text(controller.isUploading ? 'UPLOADING...' : 'UPLOAD'),
              ),
            ],
          ),
          if (initialValue != null && initialValue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _imagePreview(initialValue),
            ),
        ],
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
                Text('Image loading...', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = MediaQuery.of(context).size.width < 700;
            return Text(
              isNarrow
                  ? menuItems[currentMenuIndex]
                  : 'ADMIN — ${menuItems[currentMenuIndex].toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Builder(builder: (context) {
            final isNarrow = MediaQuery.of(context).size.width < 900;
            if (isNarrow) {
              // On mobile: collapse actions into a popup menu
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onSelected: (value) async {
                  if (value == 'translate') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🌐 Translating... please wait'),
                        duration: Duration(seconds: 60),
                        backgroundColor: Colors.teal,
                      ),
                    );
                    await controller.translateAndPublish();
                    if (mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Translated & published!'), backgroundColor: Colors.green),
                      );
                    }
                  } else if (value == 'publish') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🚀 Publishing... please wait'),
                        duration: Duration(seconds: 10),
                        backgroundColor: Colors.black,
                      ),
                    );
                    await controller.publish();
                    if (mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Published!'), backgroundColor: Colors.green),
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'translate',
                    child: Row(children: [
                      Icon(Icons.translate, color: Colors.teal),
                      SizedBox(width: 12),
                      Text('Translate & Publish'),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'publish',
                    child: Row(children: [
                      Icon(Icons.publish, color: Colors.black),
                      SizedBox(width: 12),
                      Text('Publish Media (Fast)'),
                    ]),
                  ),
                ],
              );
            }
            // Desktop: full buttons
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[800],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: controller.isLoading ? null : () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🌐 Translating text to Hindi & Gujarati... please wait'),
                        duration: Duration(seconds: 60),
                        backgroundColor: Colors.teal,
                      ),
                    );
                    await controller.translateAndPublish();
                    if (mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Text translated & published successfully!'), backgroundColor: Colors.green),
                      );
                    }
                  },
                  icon: controller.isLoading
                      ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.translate),
                  label: const Text('TRANSLATE & PUBLISH TEXT'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: controller.isLoading ? null : () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🚀 Publishing media and changes... please wait'),
                        duration: Duration(seconds: 10),
                        backgroundColor: Colors.black,
                      ),
                    );
                    await controller.publish();
                    if (mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Media/Changes published successfully!'), backgroundColor: Colors.green),
                      );
                    }
                  },
                  icon: controller.isLoading
                      ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.publish),
                  label: const Text('PUBLISH MEDIA (FAST)'),
                ),
                const SizedBox(width: 20),
              ],
            );
          }),
        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Center(child: Text('DADA PANEL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white))),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 50),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    title: Text(menuItems[index], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    selected: currentMenuIndex == index,
                    selectedTileColor: Colors.grey[200],
                    selectedColor: Colors.black,
                    onTap: () {
                      setState(() => currentMenuIndex = index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
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
      case 0: return _heroSliderView(controller);
      case 1: return _aboutDadaView(controller);
      case 2: return _kathaPagesView(controller);
      case 3: return _homepageSectionsView(controller);
      case 4: return _stotraView(controller);
      case 5: return _upcomingKathasView(controller);
      case 6: return _latestVideosView(controller);
      case 7: return _newsView(controller);
      case 8: return _kathaListView(controller);
      case 9: return _photoGalleryView(controller);
      case 10: return _videoGalleryView(controller);
      case 11: return const OrderManagementView();
      case 12: return _inquiryView(controller);
      case 13: return _contactPageView(controller);
      case 14: return _footerSettingsView(controller);
      case 15: return const AdminProductList();
      default: return const Center(child: Text('Section not yet implemented'));
    }
  }

  Widget _heroSliderView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('HEADER & BRANDING'),
        _buildField('Website Name', controller.websiteSettings.name, (v) => controller.websiteSettings.name = v),
        _buildImageField('Logo URL', controller.websiteSettings.logoUrl, (v) => controller.websiteSettings.logoUrl = v),
        
        _sectionHeader('HERO SLIDER MANAGEMENT'),
        ...controller.heroSection.slides.asMap().entries.map((entry) {
          int i = entry.key;
          HeroSlide s = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 30),
            child: ExpansionTile(
              title: Text('Slide ${i + 1}: ${s.heading.isEmpty ? "New Slide" : s.heading}'),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeHeroSlide(i)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildImageField('Background Image', s.image, (v) => setState(() => s.image = v)),
                      _buildField('Badge (Overhead)', s.badge, (v) => s.badge = v),
                      _buildField('Main Heading', s.heading, (v) => s.heading = v),
                      _buildField('Subtitle', s.subtitle, (v) => s.subtitle = v),
                      _buildField('Short Description', s.description, (v) => s.description = v, maxLines: 3),
                      Row(
                        children: [
                          Expanded(child: _buildField('Primary CTA Text', s.primaryCtaText, (v) => s.primaryCtaText = v)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildField('Primary CTA URL', s.primaryCtaUrl, (v) => s.primaryCtaUrl = v)),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
        ElevatedButton.icon(onPressed: controller.addHeroSlide, icon: const Icon(Icons.add), label: const Text('ADD NEW HERO SLIDE')),
      ],
    );
  }

  Widget _aboutDadaView(HomePageController controller) {
    final data = controller.aboutDadaPage;
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Biography Page Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const Divider(),
                  const SizedBox(height: 20),
                  
                  _sectionHeader('1. HERO CANVAS SETTINGS'),
                  _buildField('Hero Title (Banner Name)', data.heroTitle, (v) => data.heroTitle = v),
                  _buildField('Main Designation / Subtitle', data.heroSubtitle, (v) => data.heroSubtitle = v),
                  _buildImageField('Main Spotlight Portrait', data.heroImage, (v) => setState(() => data.heroImage = v)),
                ],
              ),
            ),
          ),
        ];
      },
      body: const AboutProfileEditor(),
    );
  }

  Widget _homepageSectionsView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('HOMEPAGE "ABOUT" PREVIEW'),
        _buildField('Title', controller.aboutSection.title, (v) => controller.aboutSection.title = v),
        _buildField('Tagline', controller.aboutSection.tagline, (v) => controller.aboutSection.tagline = v),
        _buildField('Short Description', controller.aboutSection.description, (v) => controller.aboutSection.description = v, maxLines: 6),
        _buildImageField('Portrait Photo', controller.aboutSection.photoUrl, (v) => setState(() => controller.aboutSection.photoUrl = v)),
        
        _sectionHeader('HOMEPAGE "KATHA" PREVIEW'),
        _buildField('Description Line 1', controller.ramKatha.description1, (v) => controller.ramKatha.description1 = v, maxLines: 6),
        _buildField('Description Line 2', controller.ramKatha.description2, (v) => controller.ramKatha.description2 = v, maxLines: 6),
        _buildImageField('Katha Section Image', controller.ramKatha.photoUrl, (v) => setState(() => controller.ramKatha.photoUrl = v)),
        
        _sectionHeader('DAILY SUVICHAR'),
        _buildField('Display Date', controller.dailySuvichar.date, (v) => controller.dailySuvichar.date = v),
        _buildImageField('Suvichar Image', controller.dailySuvichar.imageUrl, (v) => setState(() => controller.dailySuvichar.imageUrl = v)),

        _sectionHeader('FEATURED HOMEPAGE QUOTE'),
        _buildField('The Quote', controller.homepageData.featuredQuote.quote, (v) => controller.homepageData.featuredQuote.quote = v, maxLines: 5),
        _buildField('Author Name', controller.homepageData.featuredQuote.author, (v) => controller.homepageData.featuredQuote.author = v),
      ],
    );
  }

  Widget _stotraView(HomePageController controller) {
    final section = controller.stotraSection;
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        const Text('Stotra / Bhajan / Aarti Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const Divider(),
        const SizedBox(height: 30),
        _buildField('Page Title', section.pageTitle, (v) => section.pageTitle = v),
        
        _sectionHeader('MANAGE ITEMS'),
        ...section.items.asMap().entries.map((entry) {
          int i = entry.key;
          StotraItem item = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: ExpansionTile(
              title: Text('Item ${i + 1}: ${item.title.isEmpty ? "New Item" : item.title}'),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => section.items.removeAt(i))),
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildField('Title', item.title, (v) => setState(() => item.title = v)),
                      _buildField('English PDF URL', item.englishPdfUrl, (v) => item.englishPdfUrl = v),
                      _buildField('Hindi PDF URL', item.hindiPdfUrl, (v) => item.hindiPdfUrl = v),
                      _buildField('Gujarati PDF URL', item.gujaratiPdfUrl, (v) => item.gujaratiPdfUrl = v),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
        ElevatedButton.icon(
          onPressed: () => setState(() => controller.addStotraItem()), 
          icon: const Icon(Icons.add), 
          label: const Text('ADD NEW ITEM')
        ),
      ],
    );
  }

  Widget _kathaPagesView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('INDIVIDUAL KATHA PAGES'),
        ListTile(title: const Text('Shrimad Bhagvat Katha'), trailing: const Icon(Icons.arrow_forward_ios), onTap: () => _showGenericAboutDialog(controller.bhagvatKathaPage, "Shrimad Bhagvat")),
        ListTile(title: const Text('Devi Bhagvat Katha'), trailing: const Icon(Icons.arrow_forward_ios), onTap: () => _showGenericAboutDialog(controller.deviKathaPage, "Devi Bhagvat")),
        ListTile(title: const Text('Shivmahapuran Katha'), trailing: const Icon(Icons.arrow_forward_ios), onTap: () => _showGenericAboutDialog(controller.shivKathaPage, "Shivmahapuran")),
      ],
    );
  }

  void _showGenericAboutDialog(KathaAboutPageData data, String title) {
    showDialog(context: context, builder: (context) => Dialog(child: Container(width: 800, padding: const EdgeInsets.all(20), child: _genericKathaView(data, title))));
  }

  Widget _genericKathaView(KathaAboutPageData data, String kathaName) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('$kathaName Page Settings', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const Divider(),
        const SizedBox(height: 30),
        _sectionHeader('1. HERO SECTION'),
        _buildField('Badge (e.g., DIVINE GRACE)', data.heroBadge, (v) => data.heroBadge = v),
        _buildField('Title', data.heroTitle, (v) => data.heroTitle = v),
        _buildField('Description Line 1', data.heroDesc1, (v) => data.heroDesc1 = v, maxLines: 3),
        _buildField('Description Line 2', data.heroDesc2, (v) => data.heroDesc2 = v, maxLines: 3),
        _buildImageField('Hero Portrait Image', data.heroImage, (v) => setState(() => data.heroImage = v)),
        
        _sectionHeader('2. BIOGRAPHY / DESCRIPTION'),
        _buildField('Detailed Narrative', data.bioText, (v) => data.bioText = v, maxLines: 15),
        
        _sectionHeader('3. QUOTE SECTION'),
        _buildField('Quote Text', data.quoteText, (v) => data.quoteText = v, maxLines: 5),
        _buildField('Quote Author', data.quoteAuthor, (v) => data.quoteAuthor = v),
        _buildImageField('Quote Side Image', data.quoteImage, (v) => setState(() => data.quoteImage = v)),
        
        _sectionHeader('4. HIGHLIGHTS'),
        _buildField('Highlight 1 Title', data.highlight1Title, (v) => data.highlight1Title = v),
        _buildField('Highlight 1 Desc', data.highlight1Desc, (v) => data.highlight1Desc = v, maxLines: 3),
        _buildField('Highlight 2 Title', data.highlight2Title, (v) => data.highlight2Title = v),
        _buildField('Highlight 2 Desc', data.highlight2Desc, (v) => data.highlight2Desc = v, maxLines: 3),
        _buildField('Highlight 3 Title', data.highlight3Title, (v) => data.highlight3Title = v),
        _buildField('Highlight 3 Desc', data.highlight3Desc, (v) => data.highlight3Desc = v, maxLines: 3),
        
        _sectionHeader('5. CALL TO ACTION'),
        _buildField('CTA Title', data.ctaTitle, (v) => data.ctaTitle = v),
        _buildField('CTA Subtitle', data.ctaSubtitle, (v) => data.ctaSubtitle = v),
        _buildField('CTA Button Text', data.ctaButtonText, (v) => data.ctaButtonText = v),
      ],
    );
  }

  Widget _latestVideosView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('LATEST VIDEOS MANAGEMENT'),
        ...controller.videos.asMap().entries.map((entry) => Column(
          children: [
            _buildField('Video Title', entry.value.title, (v) => entry.value.title = v),
            _buildField('YouTube URL', entry.value.youtubeUrl, (v) => entry.value.youtubeUrl = v),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeVideo(entry.key)),
            const Divider(),
          ],
        )),
        ElevatedButton(onPressed: controller.addVideo, child: const Text('Add Video')),
      ],
    );
  }

  Widget _featuredQuoteView(HomePageController controller) {
    final q = controller.homepageData.featuredQuote;
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('FEATURED HOMEPAGE QUOTE'),
        _buildField('The Quote', q.quote, (v) => q.quote = v, maxLines: 5),
        _buildField('Author Name', q.author, (v) => q.author = v),
        _buildImageField('Portrait Image (Optional)', q.portrait, (v) => setState(() => q.portrait = v)),
      ],
    );
  }

  Widget _newsView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('LATEST NEWS & UPDATES'),
        const Text('Note: Only the first 4 items will appear on the homepage. All items will be visible on the dedicated News Page.', 
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey)),
        const SizedBox(height: 20),
        ...controller.homepageData.news.asMap().entries.map((entry) {
          int i = entry.key;
          NewsItem n = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: ExpansionTile(
              title: Text('News: ${n.title}'),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                setState(() => controller.homepageData.news.removeAt(i));
              }),
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildField('Title', n.title, (v) => n.title = v),
                      _buildField('Category', n.category, (v) => n.category = v),
                      _buildField('Date', n.date, (v) => n.date = v),
                      _buildField('News External Link / URL', n.url, (v) => n.url = v),
                      _buildImageField('News Image', n.image, (v) => setState(() => n.image = v)),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
        ElevatedButton.icon(onPressed: () => setState(() => controller.homepageData.news.add(NewsItem())), icon: const Icon(Icons.add), label: const Text('ADD NEWS ITEM')),
      ],
    );
  }

  Widget _upcomingKathasView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('UPCOMING KATHAS CALENDAR'),
        ...controller.upcomingKathas.asMap().entries.map((entry) {
          int index = entry.key;
          UpcomingKatha k = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text('Upcoming Katha #${k.kathaNumber}: ${k.name}'),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeKatha(index)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildField('Katha Number', k.kathaNumber, (v) => k.kathaNumber = v),
                      _buildField('Katha Name', k.name, (v) => k.name = v),
                      _buildField('Katha Date (Display Text)', k.dateString, (v) => k.dateString = v),
                      Row(
                        children: [
                          Expanded(child: _buildDateField('Start Date', k.startDate, (v) => setState(() => k.startDate = v))),
                          const SizedBox(width: 10),
                          Expanded(child: _buildDateField('End Date', k.endDate, (v) => setState(() => k.endDate = v))),
                        ],
                      ),
                      _buildField('Timing', k.timing, (v) => k.timing = v),
                      _buildField('Location', k.location, (v) => k.location = v),
                      _buildField('Hosting', k.hosting, (v) => k.hosting = v),
                      _buildField('More Details / Description', k.description, (v) => k.description = v, maxLines: 5),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
        ElevatedButton(onPressed: controller.addKatha, child: const Text('Add Upcoming Katha')),
      ],
    );
  }

  Widget _kathaListView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        const Text('Full Katha List Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      Row(children: [Expanded(child: _buildField('Katha #', k.kathaNumber, (v) => k.kathaNumber = v)), const SizedBox(width: 10), Expanded(child: _buildField('Year', k.year, (v) => k.year = v))]),
                      _buildField('Display Dates', k.dates, (v) => k.dates = v),
                      _buildField('Katha Topic / Heading', k.topic, (v) => k.topic = v),
                      _buildField('Location', k.location, (v) => k.location = v),
                      _buildField('YouTube Playlist URL', k.youtubePlaylistUrl, (v) => k.youtubePlaylistUrl = v),
                      _buildImageField('Image URL', k.imageUrl, (v) => setState(() => k.imageUrl = v)),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
        ElevatedButton.icon(onPressed: controller.addKathaRecord, icon: const Icon(Icons.add), label: const Text('ADD NEW KATHA RECORD')),
      ],
    );
  }

  Widget _photoGalleryView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('DIRECT PHOTO UPLOAD PANEL'),
        const Text(
          'Select one or multiple photos to upload directly to Firebase Storage and add them automatically to the public Photo Gallery. In accordance with strict rules, photos uploaded cannot be modified or deleted.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        
        // Direct Upload Action
        Center(
          child: Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add_photo_alternate, size: 24),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C5C),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                ),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    allowMultiple: true,
                    withData: true,
                  );
                  if (result == null || result.files.isEmpty) return;
                  
                  for (final file in result.files) {
                    if (file.bytes == null) continue;
                    final fileName = file.name;
                    setState(() {
                      _uploadProgress[fileName] = 0.0;
                    });
                    
                    controller.uploadPhotoWithProgress(fileName, file.bytes!).listen((progress) {
                      setState(() {
                        _uploadProgress[fileName] = progress;
                      });
                    }, onDone: () {
                      setState(() {
                        _uploadProgress.remove(fileName);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Uploaded $fileName successfully!')),
                      );
                    }, onError: (err) {
                      setState(() {
                        _uploadProgress.remove(fileName);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to upload $fileName: $err')),
                      );
                    });
                  }
                },
                label: const Text('SELECT & UPLOAD PHOTOS', style: TextStyle(fontSize: 16)),
              ),
              if (_uploadProgress.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Active Uploads', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ..._uploadProgress.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: entry.value,
                                    color: const Color(0xFF0F4C5C),
                                    backgroundColor: Colors.grey[200],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('${(entry.value * 100).toStringAsFixed(0)}%'),
                              ],
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 40),
        _sectionHeader('CURRENT LIVE PHOTOS'),
        
        // Show current live photos without deletion option
        controller.realTimePhotos.isEmpty
            ? const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text('No photos uploaded yet.', style: TextStyle(color: Colors.grey)),
              ))
            : LayoutBuilder(builder: (context, constraints) {
                int cols = constraints.maxWidth > 1200 ? 5 : (constraints.maxWidth > 800 ? 3 : 2);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: controller.realTimePhotos.length,
                  itemBuilder: (context, index) {
                    final photo = controller.realTimePhotos[index];
                    final url = photo['url'] ?? '';
                    final name = photo['fileName'] ?? '';
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                          Positioned(
                            bottom: 0, left: 0, right: 0,
                            child: Container(
                              color: Colors.black.withOpacity(0.6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
      ],
    );
  }

  Widget _videoGalleryView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('VIDEO GALLERY CATEGORIES'),
        ...controller.videoGalleryData.categories.asMap().entries.map((catEntry) {
          int catIdx = catEntry.key;
          VideoCategory cat = catEntry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: ExpansionTile(
              title: Text('Category: ${cat.categoryTitle}'),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeVideoCategory(catIdx)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildField('Category Title', cat.categoryTitle, (v) => setState(() => cat.categoryTitle = v)),
                      ...cat.videos.asMap().entries.map((vidEntry) {
                        int vidIdx = vidEntry.key;
                        VideoGalleryEntry vid = vidEntry.value;
                        return Card(
                          color: Colors.grey[50],
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: _buildField('Video Title', vid.title, (v) => vid.title = v)),
                                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => controller.removeVideoFromCategory(catIdx, vidIdx))),
                                  ],
                                ),
                                _buildField('YouTube URL', vid.youtubeUrl, (v) => setState(() => vid.youtubeUrl = v)),
                                if (vid.youtubeUrl.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: GestureDetector(
                                      onTap: () => _launchUrl(vid.youtubeUrl),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.network(vid.thumbnail, height: 150, width: 250, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[300], height: 150, width: 250)),
                                            const Icon(Icons.play_circle_outline, color: Colors.white, size: 50),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        onPressed: () => controller.addVideoToCategory(catIdx), 
                        label: const Text('ADD VIDEO')
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
        ElevatedButton(onPressed: controller.addVideoCategory, child: const Text('CREATE NEW CATEGORY')),
      ],
    );
  }


  Widget _inquiryView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('CONTACT ENQUIRIES'),
        ...controller.inquiries.map((inq) => Card(margin: const EdgeInsets.only(bottom: 16), child: ListTile(title: Text('${inq.name} (${inq.type})'), subtitle: Text(inq.message)))),
      ],
    );
  }

  Widget _contactPageView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('CONTACT PAGE SETTINGS'),
        _buildImageField(
          'Banner Image',
          controller.contactPageData.bannerImageUrl,
          (v) => setState(() => controller.contactPageData.bannerImageUrl = v),
        ),
        _buildField(
          'Contact Email',
          controller.contactPageData.email,
          (v) => controller.contactPageData.email = v,
        ),
        _buildField(
          'Contact Phone',
          controller.contactPageData.phone,
          (v) => controller.contactPageData.phone = v,
        ),
        _buildField(
          'Address',
          controller.contactPageData.address,
          (v) => controller.contactPageData.address = v,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _footerSettingsView(HomePageController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 100),
      children: [
        _sectionHeader('FOOTER CONFIGURATION'),
        _buildField('Footer Description', controller.footer.description, (v) => controller.footer.description = v, maxLines: 4),
        _buildField('Copyright Text', controller.footer.copyright, (v) => controller.footer.copyright = v),
        _buildField('Facebook URL', controller.footer.facebookUrl, (v) => controller.footer.facebookUrl = v),
        _buildField('Instagram URL', controller.footer.instagramUrl, (v) => controller.footer.instagramUrl = v),
        _buildField('YouTube URL', controller.footer.youtubeUrl, (v) => controller.footer.youtubeUrl = v),
        _buildField('WhatsApp URL', controller.footer.whatsappUrl, (v) => controller.footer.whatsappUrl = v),
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
