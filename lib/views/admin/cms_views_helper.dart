import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/review_controller.dart';
import '../../models/homepage_model.dart';
import '../../models/review_model.dart';
import 'biography_editor.dart';

class CMSViewsHelper {
  static Widget buildCMSView(int index, HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    switch (index) {
      case 0: return _generalSettingsView(controller, context, fieldLoading, setState);
      case 1: return _heroSliderView(controller, context, fieldLoading, setState);
      case 2: return const BiographyEditor();
      case 3: return _kathaPagesView(controller, context, fieldLoading, setState);
      case 4: return _upcomingKathasView(controller, context, fieldLoading, setState);
      case 5: return _homepageAboutView(controller, context, fieldLoading, setState);
      case 6: return _featuredQuoteView(controller, context, fieldLoading, setState);
      case 7: return _dailySuvicharView(controller, context, fieldLoading, setState);
      case 8: return _ramKathaView(controller, context, fieldLoading, setState);
      case 9: return _newsView(controller, context, fieldLoading, setState);
      case 10: return _kathaListView(controller, context, fieldLoading, setState);
      case 11: return _photoGalleryView(controller, context, fieldLoading, setState);
      case 12: return _videoGalleryView(controller, context, fieldLoading, setState);
      case 13: return _stotraView(controller, context, fieldLoading, setState);
      case 14: return _contactPageView(controller, context, fieldLoading, setState);
      case 15: return _footerSettingsView(controller, context, fieldLoading, setState);
      case 16: return _reviewsManagementView(context);
      
      case 100: return _homePortalEditView(controller, context, fieldLoading, setState);
      case 101: return _catalogueSettingsView(controller, context, fieldLoading, setState);
      case 102: return _teachingsEditorView(controller, context, fieldLoading, setState);
      
      default: return const Center(child: Text('Select a menu'));
    }
  }

  static Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Color(0xFF0F4C5C))),
          const SizedBox(height: 8),
          Container(height: 3, width: 60, decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }

  static Widget _buildField(String label, String value, Function(String) onChanged, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState, {int maxLines = 1}) {
    return _AdminTextFieldWidget(
      label: label,
      initialValue: value,
      onChanged: onChanged,
      maxLines: maxLines,
      fieldLoading: fieldLoading,
      parentSetState: setState,
    );
  }

  static Widget _reviewsManagementView(BuildContext context) {
    final reviewCtrl = Provider.of<ReviewController>(context);
    return StreamBuilder<List<ReviewModel>>(
      stream: reviewCtrl.getAllReviews(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final reviews = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _sectionHeader('DEVOTEE REVIEWS MANAGEMENT'),
            ...reviews.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text('${r.userName} - ${r.rating} Stars'),
                subtitle: Text(r.comment),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => reviewCtrl.deleteReview(r.id),
                ),
              ),
            )),
          ],
        );
      },
    );
  }

  static Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.amber,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  static Widget _buildImageField(String label, String currentUrl, Function(String) onUploaded, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return Card(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: currentUrl.isNotEmpty 
                    ? Image.network(currentUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image))
                    : Container(width: 60, height: 60, color: Colors.grey.shade100, child: const Icon(Icons.image_outlined)),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildField('Image URL', currentUrl, onUploaded, context, fieldLoading, setState)),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final controller = Provider.of<HomePageController>(context, listen: false);
                    final url = await controller.uploadPhotoFromFile();
                    if (url != null) onUploaded(url);
                  },
                  child: const Text('Upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildListField(String label, List<String> items, Function(List<String>) onUpdate, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((e) => Row(
          children: [
            Expanded(child: _buildField('Item ${e.key + 1}', e.value, (v) {
              items[e.key] = v;
              onUpdate(items);
            }, context, fieldLoading, setState)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
              items.removeAt(e.key);
              onUpdate(items);
              setState(() {});
            }),
          ],
        )),
        TextButton.icon(onPressed: () {
          items.add('');
          onUpdate(items);
          setState(() {});
        }, icon: const Icon(Icons.add), label: Text('Add to $label')),
        const SizedBox(height: 16),
      ],
    );
  }

  // --- Views ---

  static Widget _generalSettingsView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final s = controller.websiteSettings;
    final h = s.headerSettings;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('GENERAL WEBSITE SETTINGS'),
        _buildField('Organization Name', s.name, (v) => s.name = v, context, fieldLoading, setState),
        _buildImageField('Website Logo', s.logoUrl, (v) => setState(() => s.logoUrl = v), context, fieldLoading, setState),
        
        _sectionHeader('HEADER SETTINGS'),
        _buildToggle('Sticky Header', h.stickyHeaderEnabled, (v) => setState(() => h.stickyHeaderEnabled = v)),
        _buildToggle('Search Visibility', h.searchVisibility, (v) => setState(() => h.searchVisibility = v)),
        _buildField('Announcement Bar', h.announcementBarText, (v) => h.announcementBarText = v, context, fieldLoading, setState),
        
        _sectionHeader('HEADER CTA'),
        _buildToggle('Enable Donate Button', h.donateButtonEnabled, (v) => setState(() => h.donateButtonEnabled = v)),
        _buildField('Donate Button Text', h.donateButtonText, (v) => h.donateButtonText = v, context, fieldLoading, setState),
        _buildField('Donate Button URL', h.donateButtonUrl, (v) => h.donateButtonUrl = v, context, fieldLoading, setState),
        
        _sectionHeader('HEADER APPEARANCE'),
        _buildField('Background Color (Hex)', h.headerBackgroundColor, (v) => h.headerBackgroundColor = v, context, fieldLoading, setState),
        
        const SizedBox(height: 30),
        ElevatedButton(onPressed: controller.publish, child: const Text('SAVE SETTINGS')),
      ],
    );
  }

  static Widget _heroSliderView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return ListView(
      padding: const EdgeInsets.all(24),
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
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Slide #${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeHeroSlide(i))]),
                  _buildField('Badge (Small text above)', s.badge, (v) => s.badge = v, context, fieldLoading, setState),
                  _buildField('Heading', s.heading, (v) => s.heading = v, context, fieldLoading, setState, maxLines: 2),
                  _buildField('Subtitle', s.subtitle, (v) => s.subtitle = v, context, fieldLoading, setState),
                  _buildField('Description', s.description, (v) => s.description = v, context, fieldLoading, setState, maxLines: 3),
                  Row(
                    children: [
                      Expanded(child: _buildField('Primary CTA Text', s.primaryCtaText, (v) => s.primaryCtaText = v, context, fieldLoading, setState)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('Primary CTA URL', s.primaryCtaUrl, (v) => s.primaryCtaUrl = v, context, fieldLoading, setState)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildField('Secondary CTA Text', s.secondaryCtaText, (v) => s.secondaryCtaText = v, context, fieldLoading, setState)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField('Secondary CTA URL', s.secondaryCtaUrl, (v) => s.secondaryCtaUrl = v, context, fieldLoading, setState)),
                    ],
                  ),
                  _buildImageField('Slide Image', s.image, (v) => setState(() => s.image = v), context, fieldLoading, setState),
                ],
              ),
            ),
          );
        }),
        ElevatedButton.icon(onPressed: controller.addHeroSlide, icon: const Icon(Icons.add), label: const Text('ADD NEW SLIDE')),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH SLIDER')),
      ],
    );
  }

  static Widget _kathaPagesView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'Bhagvat'), Tab(text: 'Devi'), Tab(text: 'Shiv')], labelColor: Colors.black),
          SizedBox(
            height: 800,
            child: TabBarView(children: [
              _singleKathaPageView(controller.bhagvatKathaPage, controller, context, fieldLoading, setState),
              _singleKathaPageView(controller.deviKathaPage, controller, context, fieldLoading, setState),
              _singleKathaPageView(controller.shivKathaPage, controller, context, fieldLoading, setState),
            ]),
          ),
        ],
      ),
    );
  }

  static Widget _singleKathaPageView(KathaAboutPageData k, HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('HERO SECTION'),
        _buildField('Hero Badge', k.heroBadge, (v) => k.heroBadge = v, context, fieldLoading, setState),
        _buildField('Hero Title', k.heroTitle, (v) => k.heroTitle = v, context, fieldLoading, setState),
        _buildField('Hero Description 1', k.heroDesc1, (v) => k.heroDesc1 = v, context, fieldLoading, setState, maxLines: 3),
        _buildField('Hero Description 2', k.heroDesc2, (v) => k.heroDesc2 = v, context, fieldLoading, setState, maxLines: 3),
        _buildImageField('Hero Image', k.heroImage, (v) => setState(() => k.heroImage = v), context, fieldLoading, setState),
        
        _sectionHeader('BIOGRAPHY & QUOTE'),
        _buildField('Biography Text', k.bioText, (v) => k.bioText = v, context, fieldLoading, setState, maxLines: 5),
        _buildField('Quote', k.quoteText, (v) => k.quoteText = v, context, fieldLoading, setState, maxLines: 3),
        _buildField('Quote Author', k.quoteAuthor, (v) => k.quoteAuthor = v, context, fieldLoading, setState),
        _buildImageField('Quote Image', k.quoteImage, (v) => setState(() => k.quoteImage = v), context, fieldLoading, setState),
        
        _sectionHeader('HIGHLIGHTS'),
        _buildField('Highlight 1 Title', k.highlight1Title, (v) => k.highlight1Title = v, context, fieldLoading, setState),
        _buildField('Highlight 1 Description', k.highlight1Desc, (v) => k.highlight1Desc = v, context, fieldLoading, setState, maxLines: 3),
        _buildField('Highlight 2 Title', k.highlight2Title, (v) => k.highlight2Title = v, context, fieldLoading, setState),
        _buildField('Highlight 2 Description', k.highlight2Desc, (v) => k.highlight2Desc = v, context, fieldLoading, setState, maxLines: 3),
        _buildField('Highlight 3 Title', k.highlight3Title, (v) => k.highlight3Title = v, context, fieldLoading, setState),
        _buildField('Highlight 3 Description', k.highlight3Desc, (v) => k.highlight3Desc = v, context, fieldLoading, setState, maxLines: 3),
        
        _sectionHeader('CALL TO ACTION'),
        _buildField('CTA Title', k.ctaTitle, (v) => k.ctaTitle = v, context, fieldLoading, setState),
        _buildField('CTA Subtitle', k.ctaSubtitle, (v) => k.ctaSubtitle = v, context, fieldLoading, setState, maxLines: 2),
        _buildField('CTA Button Text', k.ctaButtonText, (v) => k.ctaButtonText = v, context, fieldLoading, setState),
        
        const SizedBox(height: 40),
        ElevatedButton(onPressed: () => controller.publish(), child: const Text('SAVE KATHA PAGE')),
        const SizedBox(height: 60),
      ],
    );
  }

  static Widget _upcomingKathasView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return ListView(
      padding: const EdgeInsets.all(24),
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
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Event #${i+1}', style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeKatha(i))]),
                  _buildField('Katha Number', k.kathaNumber, (v) => k.kathaNumber = v, context, fieldLoading, setState),
                  _buildField('Katha Name', k.name, (v) => k.name = v, context, fieldLoading, setState),
                  _buildField('Date Display String', k.dateString, (v) => k.dateString = v, context, fieldLoading, setState),
                  _buildField('Timing (e.g. 3:00 PM to 7:00 PM)', k.timing, (v) => k.timing = v, context, fieldLoading, setState),
                  _buildField('Location', k.location, (v) => k.location = v, context, fieldLoading, setState),
                  _buildField('Hosting / Organizer', k.hosting, (v) => k.hosting = v, context, fieldLoading, setState),
                  _buildField('Description', k.description, (v) => k.description = v, context, fieldLoading, setState, maxLines: 3),
                ],
              ),
            ),
          );
        }),
        ElevatedButton(onPressed: controller.addKatha, child: const Text('ADD UPCOMING KATHA')),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH KATHAS')),
      ],
    );
  }

  static Widget _homepageAboutView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final a = controller.aboutSection;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('BIOGRAPHY SECTION (HOME)'),
        _buildField('Display Title', a.title, (v) => a.title = v, context, fieldLoading, setState),
        _buildField('Tagline', a.tagline, (v) => a.tagline = v, context, fieldLoading, setState),
        _buildField('Quote', a.quote, (v) => a.quote = v, context, fieldLoading, setState),
        _buildField('Main Intro Description', a.description, (v) => a.description = v, context, fieldLoading, setState, maxLines: 4),
        _buildImageField('Biography Photo', a.photoUrl, (v) => setState(() => a.photoUrl = v), context, fieldLoading, setState),
        
        _sectionHeader('DETAILED PARAGRAPHS'),
        _buildListField('Paragraphs', a.paragraphs, (v) => a.paragraphs = v, context, fieldLoading, setState),
        
        _sectionHeader('GALLERY IMAGES'),
        _buildListField('Image URLs', a.galleryImages, (v) => a.galleryImages = v, context, fieldLoading, setState),
        
        const SizedBox(height: 40),
        ElevatedButton(onPressed: controller.publish, child: const Text('SAVE ABOUT DATA')),
      ],
    );
  }

  static Widget _featuredQuoteView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final q = controller.homepageData.featuredQuote;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('FEATURED QUOTE SECTION'),
        _buildField('Quote Text', q.quote, (v) => q.quote = v, context, fieldLoading, setState, maxLines: 3),
        _buildField('Author', q.author, (v) => q.author = v, context, fieldLoading, setState),
        _buildImageField('Portrait Image', q.portrait, (v) => setState(() => q.portrait = v), context, fieldLoading, setState),
        _buildImageField('Background Image', q.background, (v) => setState(() => q.background = v), context, fieldLoading, setState),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: controller.publish, child: const Text('SAVE QUOTE')),
      ],
    );
  }

  static Widget _dailySuvicharView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final d = controller.dailySuvichar;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('DAILY SUVICHAR'),
        _buildField('Date Label', d.date, (v) => d.date = v, context, fieldLoading, setState),
        _buildImageField('Suvichar Image', d.imageUrl, (v) => setState(() => d.imageUrl = v), context, fieldLoading, setState),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: controller.publish, child: const Text('SAVE SUVICHAR')),
      ],
    );
  }

  static Widget _ramKathaView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final r = controller.ramKatha;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('RAM KATHA PREVIEW SECTION'),
        _buildField('Title', r.title, (v) => r.title = v, context, fieldLoading, setState),
        _buildField('Description Para 1', r.description1, (v) => r.description1 = v, context, fieldLoading, setState, maxLines: 4),
        _buildField('Description Para 2', r.description2, (v) => r.description2 = v, context, fieldLoading, setState, maxLines: 4),
        _buildImageField('Section Photo', r.photoUrl, (v) => setState(() => r.photoUrl = v), context, fieldLoading, setState),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: controller.publish, child: const Text('SAVE RAM KATHA SECTION')),
      ],
    );
  }

  static Widget _newsView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('NEWS & UPDATES'),
        ...controller.homepageData.news.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('News Item #${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => controller.homepageData.news.removeAt(e.key)))]),
              _buildField('Title', e.value.title, (v) => e.value.title = v, context, fieldLoading, setState),
              _buildField('Category', e.value.category, (v) => e.value.category = v, context, fieldLoading, setState),
              _buildField('Date String', e.value.date, (v) => e.value.date = v, context, fieldLoading, setState),
              _buildField('Target URL (Read More)', e.value.url, (v) => e.value.url = v, context, fieldLoading, setState),
              _buildImageField('News Image', e.value.image, (v) => setState(() => e.value.image = v), context, fieldLoading, setState),
            ]),
          ),
        )),
        ElevatedButton.icon(onPressed: () => setState(() => controller.homepageData.news.add(NewsItem())), icon: const Icon(Icons.add), label: const Text('ADD NEWS')),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH NEWS')),
      ],
    );
  }

  static Widget _kathaListView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final kld = controller.kathaListPageData;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('KATHA LIST PAGE SETTINGS'),
        _buildImageField('Main List Banner Image', kld.bannerImageUrl, (v) => setState(() => kld.bannerImageUrl = v), context, fieldLoading, setState),

        _sectionHeader('FULL KATHA ARCHIVE'),
        ...controller.allKathas.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Katha Record #${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeKathaRecord(e.key))]),
              _buildField('Katha Number', e.value.kathaNumber, (v) => e.value.kathaNumber = v, context, fieldLoading, setState),
              _buildField('Year', e.value.year, (v) => e.value.year = v, context, fieldLoading, setState),
              _buildField('Dates (e.g. 1st Jan - 9th Jan)', e.value.dates, (v) => e.value.dates = v, context, fieldLoading, setState),
              _buildField('Topic / Subject', e.value.topic, (v) => e.value.topic = v, context, fieldLoading, setState),
              _buildField('Location', e.value.location, (v) => e.value.location = v, context, fieldLoading, setState),
              _buildField('Country', e.value.country, (v) => e.value.country = v, context, fieldLoading, setState),
              _buildField('Language', e.value.language, (v) => e.value.language = v, context, fieldLoading, setState),
              _buildField('YouTube Playlist URL', e.value.youtubePlaylistUrl, (v) => e.value.youtubePlaylistUrl = v, context, fieldLoading, setState),
              _buildField('Description', e.value.description, (v) => e.value.description = v, context, fieldLoading, setState, maxLines: 3),
              _buildImageField('Record Image', e.value.imageUrl, (v) => setState(() => e.value.imageUrl = v), context, fieldLoading, setState),
            ]),
          ),
        )),
        ElevatedButton.icon(onPressed: controller.addKathaRecord, icon: const Icon(Icons.add), label: const Text('ADD ARCHIVE RECORD')),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH ARCHIVE')),
      ],
    );
  }

  static Widget _photoGalleryView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final pgd = controller.photoGalleryData;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('PHOTO GALLERY PAGE SETTINGS'),
        _buildField('Gallery Main Title', pgd.title, (v) => pgd.title = v, context, fieldLoading, setState),
        _buildImageField('Gallery Header Image', pgd.headerImageUrl, (v) => setState(() => pgd.headerImageUrl = v), context, fieldLoading, setState),

        _sectionHeader('PHOTO GALLERY SECTIONS'),
        ...pgd.sections.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Section #${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removePhotoCategory(e.key))]),
              _buildField('Heading', e.value.heading, (v) => e.value.heading = v, context, fieldLoading, setState),
              _buildListField('Photo URLs', e.value.photoUrls, (v) => e.value.photoUrls = v, context, fieldLoading, setState),
            ]),
          ),
        )),
        ElevatedButton.icon(onPressed: controller.addPhotoCategory, icon: const Icon(Icons.add), label: const Text('ADD PHOTO SECTION')),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH PHOTOS')),
      ],
    );
  }

  static Widget _videoGalleryView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final vgd = controller.videoGalleryData;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('VIDEO GALLERY PAGE SETTINGS'),
        _buildImageField('Gallery Header Image', vgd.headerImageUrl, (v) => setState(() => vgd.headerImageUrl = v), context, fieldLoading, setState),

        _sectionHeader('VIDEO GALLERY CATEGORIES'),
        ...vgd.categories.asMap().entries.map((e) {
          final catIndex = e.key;
          final cat = e.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Category #${catIndex + 1}', style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeVideoCategory(catIndex))]),
                _buildField('Category Title', cat.categoryTitle, (v) => cat.categoryTitle = v, context, fieldLoading, setState),
                const Divider(),
                const Text('Videos in this category:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ...cat.videos.asMap().entries.map((ve) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildField('Video Title', ve.value.title, (v) => ve.value.title = v, context, fieldLoading, setState),
                            _buildField('YouTube URL', ve.value.youtubeUrl, (v) => ve.value.youtubeUrl = v, context, fieldLoading, setState),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeVideoFromCategory(catIndex, ve.key)),
                    ],
                  ),
                )),
                TextButton.icon(onPressed: () => controller.addVideoToCategory(catIndex), icon: const Icon(Icons.add), label: const Text('Add Video')),
              ]),
            ),
          );
        }),
        ElevatedButton.icon(onPressed: controller.addVideoCategory, icon: const Icon(Icons.add), label: const Text('ADD VIDEO CATEGORY')),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH VIDEOS')),
      ],
    );
  }

  static Widget _stotraView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('STOTRA / BHAJAN PAGE'),
        _buildField('Page Title', controller.stotraSection.pageTitle, (v) => controller.stotraSection.pageTitle = v, context, fieldLoading, setState),
        _buildImageField('Top Header Image', controller.stotraSection.topHeaderImage, (v) => setState(() => controller.stotraSection.topHeaderImage = v), context, fieldLoading, setState),
        
        ...controller.stotraSection.items.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Item #${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeStotraItem(e.key))]),
              _buildField('Item Title', e.value.title, (v) => e.value.title = v, context, fieldLoading, setState),
              _buildField('English PDF URL', e.value.englishPdfUrl, (v) => e.value.englishPdfUrl = v, context, fieldLoading, setState),
              _buildField('Hindi PDF URL', e.value.hindiPdfUrl, (v) => e.value.hindiPdfUrl = v, context, fieldLoading, setState),
              _buildField('Gujarati PDF URL', e.value.gujaratiPdfUrl, (v) => e.value.gujaratiPdfUrl = v, context, fieldLoading, setState),
            ]),
          ),
        )),
        ElevatedButton.icon(onPressed: controller.addStotraItem, icon: const Icon(Icons.add), label: const Text('ADD STOTRA ITEM')),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH STOTRAS')),
      ],
    );
  }

  static Widget _contactPageView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final c = controller.contactPageData;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('CONTACT PAGE SETTINGS'),
        _buildField('Email Address', c.email, (v) => c.email = v, context, fieldLoading, setState),
        _buildField('Phone Number', c.phone, (v) => c.phone = v, context, fieldLoading, setState),
        _buildField('Physical Address', c.address, (v) => c.address = v, context, fieldLoading, setState, maxLines: 3),
        _buildImageField('Page Banner Image', c.bannerImageUrl, (v) => setState(() => c.bannerImageUrl = v), context, fieldLoading, setState),
        
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH CONTACT SETTINGS')),
      ],
    );
  }

  static Widget _footerSettingsView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final f = controller.footer;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('FOOTER CONTENT'),
        _buildField('About Description', f.description, (v) => f.description = v, context, fieldLoading, setState, maxLines: 4),
        _buildField('Copyright Text', f.copyright, (v) => f.copyright = v, context, fieldLoading, setState),
        
        _sectionHeader('SOCIAL MEDIA LINKS'),
        _buildField('YouTube URL', f.youtubeUrl, (v) => f.youtubeUrl = v, context, fieldLoading, setState),
        _buildField('Instagram URL', f.instagramUrl, (v) => f.instagramUrl = v, context, fieldLoading, setState),
        _buildField('Facebook URL', f.facebookUrl, (v) => f.facebookUrl = v, context, fieldLoading, setState),
        _buildField('WhatsApp Group/Number URL', f.whatsappUrl, (v) => f.whatsappUrl = v, context, fieldLoading, setState),
        
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH FOOTER')),
      ],
    );
  }

  // --- Specific Views for "Store & Settings" (Product Management) ---

  static Widget _homePortalEditView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final h = controller.homepageData.homePortal;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('1. HERO SECTION CONTENT'),
        _buildField('Hero Main Heading', h.heroHeading, (v) => h.heroHeading = v, context, fieldLoading, setState, maxLines: 2),
        _buildField('Hero Subtitle / Intro', h.heroSubtitle, (v) => h.heroSubtitle = v, context, fieldLoading, setState, maxLines: 3),
        Row(
          children: [
            Expanded(child: _buildField('CTA Button 1 Text', h.heroCta1Text, (v) => h.heroCta1Text = v, context, fieldLoading, setState)),
            const SizedBox(width: 16),
            Expanded(child: _buildField('CTA Button 2 Text', h.heroCta2Text, (v) => h.heroCta2Text = v, context, fieldLoading, setState)),
          ],
        ),
        _buildImageField('Hero Background Image', h.heroImage, (v) => setState(() => h.heroImage = v), context, fieldLoading, setState),
        
        _sectionHeader('2. HERO SIDE CARD (FEATURED)'),
        _buildField('Card Title', h.heroCardTitle, (v) => h.heroCardTitle = v, context, fieldLoading, setState),
        _buildField('Card Subtitle', h.heroCardSubtitle, (v) => h.heroCardSubtitle = v, context, fieldLoading, setState, maxLines: 2),
        _buildImageField('Card Feature Image', h.heroSideImage, (v) => setState(() => h.heroSideImage = v), context, fieldLoading, setState),

        _sectionHeader('3. SECTION HEADINGS'),
        _buildField('Offerings / Categories Heading', h.collectionsHeading, (v) => h.collectionsHeading = v, context, fieldLoading, setState),
        _buildField('Featured Products Heading', h.featuredHeading, (v) => h.featuredHeading = v, context, fieldLoading, setState),
        _buildField('Testimonials Heading', h.testimonialsHeading, (v) => h.testimonialsHeading = v, context, fieldLoading, setState),
        _buildField('Wisdom / Suvichar Heading', h.wisdomHeading, (v) => h.wisdomHeading = v, context, fieldLoading, setState),

        _sectionHeader('4. WHATSAPP GUIDANCE BOX'),
        _buildField('Guidance Title', h.whatsappTitle, (v) => h.whatsappTitle = v, context, fieldLoading, setState),
        _buildField('Guidance Subtitle', h.whatsappSubtitle, (v) => h.whatsappSubtitle = v, context, fieldLoading, setState, maxLines: 2),
        _buildField('WhatsApp Button Text', h.whatsappBtnText, (v) => h.whatsappBtnText = v, context, fieldLoading, setState),

        const SizedBox(height: 60),
        ElevatedButton(
          onPressed: () => controller.publish(),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
          child: const Text('SAVE ALL HOME PORTAL CHANGES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  static Widget _catalogueSettingsView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final s = controller.websiteSettings;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('PRODUCT CATALOGUE HEADINGS'),
        _buildField('Main Heading', s.catalogueHeading, (v) => s.catalogueHeading = v, context, fieldLoading, setState),
        _buildField('Sub-heading', s.catalogueSubtitle, (v) => s.catalogueSubtitle = v, context, fieldLoading, setState),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: controller.publish, child: const Text('SAVE CATALOGUE SETTINGS')),
      ],
    );
  }

  static Widget _teachingsEditorView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final t = controller.homepageData.teachingsPage;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader('TEACHINGS PAGE HERO'),
        _buildField('Hero Title', t.heroTitle, (v) => t.heroTitle = v, context, fieldLoading, setState),
        _buildField('Hero Subtitle', t.heroSubtitle, (v) => t.heroSubtitle = v, context, fieldLoading, setState, maxLines: 2),
        _buildImageField('Hero Background', t.heroImage, (v) => setState(() => t.heroImage = v), context, fieldLoading, setState),
        
        _sectionHeader('DIVINE PURPOSE SECTION'),
        _buildField('Section Title', t.divinePurposeTitle, (v) => t.divinePurposeTitle = v, context, fieldLoading, setState),
        _buildField('Description Para 1', t.divinePurposeDesc1, (v) => t.divinePurposeDesc1 = v, context, fieldLoading, setState, maxLines: 3),
        _buildField('Description Para 2', t.divinePurposeDesc2, (v) => t.divinePurposeDesc2 = v, context, fieldLoading, setState, maxLines: 3),
        _buildImageField('Side Image', t.divinePurposeImage, (v) => setState(() => t.divinePurposeImage = v), context, fieldLoading, setState),
        
        const SizedBox(height: 40),
        ElevatedButton(onPressed: controller.publish, child: const Text('SAVE TEACHINGS PAGE')),
      ],
    );
  }
}

class _AdminTextFieldWidget extends StatefulWidget {
  final String label;
  final String initialValue;
  final Function(String) onChanged;
  final int maxLines;
  final Map<String, bool> fieldLoading;
  final Function(VoidCallback) parentSetState;

  const _AdminTextFieldWidget({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    required this.maxLines,
    required this.fieldLoading,
    required this.parentSetState,
  });

  @override
  State<_AdminTextFieldWidget> createState() => _AdminTextFieldWidgetState();
}

class _AdminTextFieldWidgetState extends State<_AdminTextFieldWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_AdminTextFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            maxLines: widget.maxLines,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
