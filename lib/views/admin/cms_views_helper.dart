import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';
import '../../services/translation_service.dart';
import 'biography_editor.dart';

class CMSViewsHelper {
  static Widget buildCMSView(int index, HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    switch (index) {
      case 0: return _generalSettingsView(controller, context, fieldLoading, setState);
      case 1: return _heroSliderView(controller, context, fieldLoading, setState);
      case 2: return const BiographyEditor();
      case 3: return _kathaPagesView(controller, context, fieldLoading, setState);
      case 4: return _upcomingKathasView(controller, context, fieldLoading, setState);
      case 5: return _homepageDataView(controller, context, fieldLoading, setState);
      case 6: return _newsView(controller, context, fieldLoading, setState);
      case 7: return _kathaListView(controller, context, fieldLoading, setState);
      case 8: return _photoGalleryView(controller, context, fieldLoading, setState);
      case 9: return _videoGalleryView(controller, context, fieldLoading, setState);
      case 10: return _stotraView(controller, context, fieldLoading, setState);
      case 11: return _contactPageView(controller, context, fieldLoading, setState);
      case 12: return _footerSettingsView(controller, context, fieldLoading, setState);
      default: return const Center(child: Text('Select a menu'));
    }
  }

  static Future<void> _translateField(String key, String original, Function(String, String) onResult, Map<String, bool> fieldLoading, Function(VoidCallback) setState) async {
    if (original.trim().isEmpty) return;
    setState(() => fieldLoading[key] = true);
    final results = await TranslationService.translateToAll(original);
    onResult(results['hi'] ?? '', results['gu'] ?? '');
    setState(() => fieldLoading[key] = false);
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

  static Widget _buildField(String label, String value, Function(String) onChanged, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState, {int maxLines = 1, String? translateKey, Function(String, String)? onTranslated}) {
    return _AdminTextFieldWidget(
      label: label,
      initialValue: value,
      onChanged: onChanged,
      maxLines: maxLines,
      translateKey: translateKey,
      onTranslated: onTranslated,
      fieldLoading: fieldLoading,
      parentSetState: setState,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        bool useVertical = constraints.maxWidth < 600;
        Widget imageWidget = currentUrl.isNotEmpty 
          ? Image.network(currentUrl, width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 100, height: 100, color: Colors.grey.shade100, child: const Icon(Icons.broken_image)))
          : Container(width: 100, height: 100, color: Colors.grey.shade100, child: const Icon(Icons.image_outlined));

        return Card(
          margin: const EdgeInsets.only(bottom: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F4C5C))),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!useVertical) ...[ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget), const SizedBox(width: 24)],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildField('Image URL Link', currentUrl, onUploaded, context, fieldLoading, setState),
                          const Center(child: Text('OR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey))),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final url = await Provider.of<HomePageController>(context, listen: false).uploadPhotoFromFile();
                                if (url != null) onUploaded(url);
                              },
                              icon: const Icon(Icons.computer, size: 18),
                              label: const Text('UPLOAD FROM PC'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100, foregroundColor: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  static EdgeInsets _responsivePadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return EdgeInsets.all(width < 600 ? 16 : 40);
  }

  static Widget _generalSettingsView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final s = controller.websiteSettings;
    final h = s.headerSettings;
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('GENERAL WEBSITE SETTINGS'),
        _buildField('Organization Name', s.name, (v) => s.name = v, context, fieldLoading, setState, translateKey: 's_name', onTranslated: (hi, gu) { s.nameHi = hi; s.nameGu = gu; }),
        _buildImageField('Website Logo', s.logoUrl, (v) => setState(() => s.logoUrl = v), context, fieldLoading, setState),
        _sectionHeader('HEADER SETTINGS'),
        _buildToggle('Sticky Header', h.stickyHeaderEnabled, (v) => setState(() => h.stickyHeaderEnabled = v)),
        _buildToggle('Search Visibility', h.searchVisibility, (v) => setState(() => h.searchVisibility = v)),
        _buildField('Announcement Bar', h.announcementBarText, (v) => h.announcementBarText = v, context, fieldLoading, setState, translateKey: 'h_ann', onTranslated: (hi, gu) { h.announcementBarTextHi = hi; h.announcementBarTextGu = gu; }),
        _buildToggle('Donate Button', h.donateButtonEnabled, (v) => setState(() => h.donateButtonEnabled = v)),
        if (h.donateButtonEnabled) ...[
          _buildField('Donate Button Text', h.donateButtonText, (v) => h.donateButtonText = v, context, fieldLoading, setState, translateKey: 'h_don', onTranslated: (hi, gu) { h.donateButtonTextHi = hi; h.donateButtonTextGu = gu; }),
          _buildField('Donate URL', h.donateButtonUrl, (v) => h.donateButtonUrl = v, context, fieldLoading, setState),
        ],
        const SizedBox(height: 30),
        ElevatedButton(onPressed: controller.publish, child: const Text('SAVE GLOBAL SETTINGS')),
      ],
    );
  }

  static Widget _heroSliderView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
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
                  _buildField('Badge Text', s.badge, (v) => s.badge = v, context, fieldLoading, setState, translateKey: 'hs_badge_$i', onTranslated: (hi, gu) { s.badgeHi = hi; s.badgeGu = gu; }),
                  _buildField('Heading', s.heading, (v) => s.heading = v, context, fieldLoading, setState, translateKey: 'hs_head_$i', onTranslated: (hi, gu) { s.headingHi = hi; s.headingGu = gu; }),
                  _buildField('Subtitle', s.subtitle, (v) => s.subtitle = v, context, fieldLoading, setState, translateKey: 'hs_sub_$i', onTranslated: (hi, gu) { s.subtitleHi = hi; s.subtitleGu = gu; }),
                  _buildField('Description', s.description, (v) => s.description = v, context, fieldLoading, setState, maxLines: 3, translateKey: 'hs_desc_$i', onTranslated: (hi, gu) { s.descriptionHi = hi; s.descriptionGu = gu; }),
                  _buildImageField('Slide Image', s.image, (v) => setState(() => s.image = v), context, fieldLoading, setState),
                ],
              ),
            ),
          );
        }),
        ElevatedButton.icon(onPressed: controller.addHeroSlide, icon: const Icon(Icons.add), label: const Text('ADD NEW SLIDE')),
      ],
    );
  }

  static Widget _kathaPagesView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'Bhagvat'), Tab(text: 'Devi'), Tab(text: 'Shiv')], labelColor: Colors.black),
          Expanded(child: TabBarView(children: [
            _singleKathaPageView(controller.bhagvatKathaPage, context, fieldLoading, setState),
            _singleKathaPageView(controller.deviKathaPage, context, fieldLoading, setState),
            _singleKathaPageView(controller.shivKathaPage, context, fieldLoading, setState),
          ])),
        ],
      ),
    );
  }

  static Widget _singleKathaPageView(KathaAboutPageData k, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    String p = k.heroTitle.isNotEmpty ? k.heroTitle.substring(0, 3) : 'k';
    return ListView(
      padding: _responsivePadding(context),
      children: [
        _buildField('Hero Badge', k.heroBadge, (v) => k.heroBadge = v, context, fieldLoading, setState, translateKey: '${p}_badge', onTranslated: (hi, gu) { k.heroBadgeHi = hi; k.heroBadgeGu = gu; }),
        _buildField('Hero Title', k.heroTitle, (v) => k.heroTitle = v, context, fieldLoading, setState, translateKey: '${p}_title', onTranslated: (hi, gu) { k.heroTitleHi = hi; k.heroTitleGu = gu; }),
        _buildField('Desc 1', k.heroDesc1, (v) => k.heroDesc1 = v, context, fieldLoading, setState, maxLines: 4, translateKey: '${p}_d1', onTranslated: (hi, gu) { k.heroDesc1Hi = hi; k.heroDesc1Gu = gu; }),
        _buildField('Desc 2', k.heroDesc2, (v) => k.heroDesc2 = v, context, fieldLoading, setState, maxLines: 4, translateKey: '${p}_d2', onTranslated: (hi, gu) { k.heroDesc1Hi = hi; k.heroDesc2Gu = gu; }),
        _buildImageField('Main Image', k.heroImage, (v) => setState(() => k.heroImage = v), context, fieldLoading, setState),
        _buildField('Quote', k.quoteText, (v) => k.quoteText = v, context, fieldLoading, setState, maxLines: 3, translateKey: '${p}_q', onTranslated: (hi, gu) { k.quoteTextHi = hi; k.quoteTextGu = gu; }),
        _buildField('Author', k.quoteAuthor, (v) => k.quoteAuthor = v, context, fieldLoading, setState, translateKey: '${p}_qa', onTranslated: (hi, gu) { k.quoteAuthorHi = hi; k.quoteAuthorGu = gu; }),
        _sectionHeader('HIGHLIGHTS'),
        _buildField('H1 Title', k.highlight1Title, (v) => k.highlight1Title = v, context, fieldLoading, setState, translateKey: '${p}_h1t', onTranslated: (hi, gu) { k.highlight1TitleHi = hi; k.highlight1TitleGu = gu; }),
        _buildField('H1 Desc', k.highlight1Desc, (v) => k.highlight1Desc = v, context, fieldLoading, setState, translateKey: '${p}_h1d', onTranslated: (hi, gu) { k.highlight1DescHi = hi; k.highlight1DescGu = gu; }),
        _buildField('H2 Title', k.highlight2Title, (v) => k.highlight2Title = v, context, fieldLoading, setState, translateKey: '${p}_h2t', onTranslated: (hi, gu) { k.highlight2TitleHi = hi; k.highlight2TitleGu = gu; }),
        _buildField('H2 Desc', k.highlight2Desc, (v) => k.highlight2Desc = v, context, fieldLoading, setState, translateKey: '${p}_h2d', onTranslated: (hi, gu) { k.highlight2DescHi = hi; k.highlight2DescGu = gu; }),
        _buildField('H3 Title', k.highlight3Title, (v) => k.highlight3Title = v, context, fieldLoading, setState, translateKey: '${p}_h3t', onTranslated: (hi, gu) { k.highlight3TitleHi = hi; k.highlight3TitleGu = gu; }),
        _buildField('H3 Desc', k.highlight3Desc, (v) => k.highlight3Desc = v, context, fieldLoading, setState, translateKey: '${p}_h3d', onTranslated: (hi, gu) { k.highlight3DescHi = hi; k.highlight3DescGu = gu; }),
      ],
    );
  }

  static Widget _upcomingKathasView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
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
                  _buildField('Katha Number', k.kathaNumber, (v) => k.kathaNumber = v, context, fieldLoading, setState),
                  _buildField('Name', k.name, (v) => k.name = v, context, fieldLoading, setState, translateKey: 'uk_name_$i', onTranslated: (hi, gu) { k.nameHi = hi; k.nameGu = gu; }),
                  _buildField('Date (String)', k.dateString, (v) => k.dateString = v, context, fieldLoading, setState, translateKey: 'uk_date_$i', onTranslated: (hi, gu) { k.dateStringHi = hi; k.dateStringGu = gu; }),
                  _buildField('Timing', k.timing, (v) => k.timing = v, context, fieldLoading, setState, translateKey: 'uk_time_$i', onTranslated: (hi, gu) { k.timingHi = hi; k.timingGu = gu; }),
                  _buildField('Location', k.location, (v) => k.location = v, context, fieldLoading, setState, translateKey: 'uk_loc_$i', onTranslated: (hi, gu) { k.locationHi = hi; k.locationGu = gu; }),
                  _buildField('Hosting', k.hosting, (v) => k.hosting = v, context, fieldLoading, setState, translateKey: 'uk_host_$i', onTranslated: (hi, gu) { k.hostingHi = hi; k.hostingGu = gu; }),
                  _buildField('Description', k.description, (v) => k.description = v, context, fieldLoading, setState, maxLines: 5, translateKey: 'uk_desc_$i', onTranslated: (hi, gu) { k.descriptionHi = hi; k.descriptionGu = gu; }),
                ],
              ),
            ),
          );
        }),
        ElevatedButton(onPressed: controller.addKatha, child: const Text('ADD UPCOMING KATHA')),
      ],
    );
  }

  static Widget _homepageDataView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final q = controller.homepageData.featuredQuote;
    final a = controller.aboutSection;
    final r = controller.ramKatha;
    final d = controller.dailySuvichar;
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('1. SUVICHAR (THOUGHT OF THE DAY)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildField('Thought of the Day', q.quote, (v) => q.quote = v, context, fieldLoading, setState, maxLines: 3, translateKey: 'q_txt', onTranslated: (hi, gu) { q.quoteHi = hi; q.quoteGu = gu; }),
                _buildField('Author / Credit', q.author, (v) => q.author = v, context, fieldLoading, setState, translateKey: 'q_auth', onTranslated: (hi, gu) { q.authorHi = hi; q.authorGu = gu; }),
                _buildImageField('Small Icon/Portrait', q.portrait, (v) => setState(() => q.portrait = v), context, fieldLoading, setState),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        _sectionHeader('2. PUJYA DADA\'S SMALL BIOGRAPHY'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildField('Display Title', a.title, (v) => a.title = v, context, fieldLoading, setState, translateKey: 'ap_title', onTranslated: (hi, gu) { a.titleHi = hi; a.titleGu = gu; }),
                _buildField('Tagline', a.tagline, (v) => a.tagline = v, context, fieldLoading, setState, translateKey: 'ap_tag', onTranslated: (hi, gu) { a.taglineHi = hi; a.taglineGu = gu; }),
                _buildField('Short Biography (Intro)', a.description, (v) => a.description = v, context, fieldLoading, setState, maxLines: 5, translateKey: 'ap_desc', onTranslated: (hi, gu) { a.descriptionHi = hi; a.descriptionGu = gu; }),
                _buildImageField('Biography Photo', a.photoUrl, (v) => setState(() => a.photoUrl = v), context, fieldLoading, setState),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        _sectionHeader('5. DADA\'S DAILY SUVICHAR IMAGE'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildField('Image Date Label', d.date, (v) => d.date = v, context, fieldLoading, setState),
                _buildImageField('Daily Suvichar Image', d.imageUrl, (v) => setState(() => d.imageUrl = v), context, fieldLoading, setState),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        _sectionHeader('6. SHRIMAD BHAGWAT KATHA INTRODUCTION'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildField('Section Title', r.title, (v) => r.title = v, context, fieldLoading, setState),
                _buildField('Intro Paragraph 1', r.description1, (v) => r.description1 = v, context, fieldLoading, setState, maxLines: 4, translateKey: 'rk_d1', onTranslated: (hi, gu) { r.description1Hi = hi; r.description1Gu = gu; }),
                _buildField('Intro Paragraph 2', r.description2, (v) => r.description2 = v, context, fieldLoading, setState, maxLines: 4, translateKey: 'rk_d2', onTranslated: (hi, gu) { r.description2Hi = hi; r.description2Gu = gu; }),
                _buildImageField('Katha Section Image', r.photoUrl, (v) => setState(() => r.photoUrl = v), context, fieldLoading, setState),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () async {
            await controller.publish();
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Homepage Saved Successfully!')));
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white, padding: const EdgeInsets.all(20)),
          child: const Text('SAVE ALL HOMEPAGE DATA'),
        ),
      ],
    );
  }

  static Widget _newsView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('NEWS & UPDATES'),
        ...controller.homepageData.news.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _buildField('Title', e.value.title, (v) => e.value.title = v, context, fieldLoading, setState, translateKey: 'news_t_${e.key}', onTranslated: (hi, gu) { e.value.titleHi = hi; e.value.titleGu = gu; }),
              _buildField('Date', e.value.date, (v) => e.value.date = v, context, fieldLoading, setState),
              _buildImageField('News Image', e.value.image, (v) => setState(() => e.value.image = v), context, fieldLoading, setState),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => controller.homepageData.news.removeAt(e.key))),
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
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('FULL KATHA ARCHIVE'),
        ...controller.allKathas.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _buildField('Topic', e.value.topic, (v) => e.value.topic = v, context, fieldLoading, setState, translateKey: 'ka_t_${e.key}', onTranslated: (hi, gu) { e.value.topicHi = hi; e.value.topicGu = gu; }),
              _buildField('Location', e.value.location, (v) => e.value.location = v, context, fieldLoading, setState, translateKey: 'ka_l_${e.key}', onTranslated: (hi, gu) { e.value.locationHi = hi; e.value.locationGu = gu; }),
              _buildImageField('Archive Image', e.value.imageUrl, (v) => setState(() => e.value.imageUrl = v), context, fieldLoading, setState),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeKathaRecord(e.key)),
            ]),
          ),
        )),
        ElevatedButton.icon(onPressed: controller.addKathaRecord, icon: const Icon(Icons.add), label: const Text('ADD ARCHIVE')),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH ARCHIVE')),
      ],
    );
  }

  static Widget _photoGalleryView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('PHOTO GALLERY'),
        ...controller.photoGalleryData.sections.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _buildField('Heading', e.value.heading, (v) => e.value.heading = v, context, fieldLoading, setState, translateKey: 'pg_h_${e.key}', onTranslated: (hi, gu) { e.value.headingHi = hi; e.value.headingGu = gu; }),
              const SizedBox(height: 12),
              const Text('Category Photos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: [
                  ...e.value.photoUrls.asMap().entries.map((img) => Stack(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(img.value, width: 100, height: 100, fit: BoxFit.cover)),
                      Positioned(top: 0, right: 0, child: Container(color: Colors.black45, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 16), onPressed: () => setState(() => e.value.photoUrls.removeAt(img.key))))),
                    ],
                  )),
                  InkWell(
                    onTap: () => controller.addPhotoToCategoryFromPicker(e.key),
                    child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removePhotoCategory(e.key)),
            ]),
          ),
        )),
        ElevatedButton.icon(onPressed: controller.addPhotoCategory, icon: const Icon(Icons.add), label: const Text('ADD SECTION')),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH PHOTOS')),
      ],
    );
  }

  static Widget _videoGalleryView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('VIDEO GALLERY'),
        _buildImageField('Gallery Header Background', controller.videoGalleryData.headerImageUrl, (v) => setState(() => controller.videoGalleryData.headerImageUrl = v), context, fieldLoading, setState),
        ...controller.videoGalleryData.categories.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _buildField('Category Title', e.value.categoryTitle, (v) => e.value.categoryTitle = v, context, fieldLoading, setState, translateKey: 'vg_t_${e.key}', onTranslated: (hi, gu) { e.value.categoryTitleHi = hi; e.value.categoryTitleGu = gu; }),
              const Divider(),
              ...e.value.videos.asMap().entries.map((vEntry) => Row(children: [
                Expanded(child: _buildField('Video Title', vEntry.value.title, (v) => vEntry.value.title = v, context, fieldLoading, setState, translateKey: 'v_t_${e.key}_${vEntry.key}', onTranslated: (hi, gu) { vEntry.value.titleHi = hi; vEntry.value.titleGu = gu; })),
                const SizedBox(width: 12),
                Expanded(child: _buildField('YouTube URL', vEntry.value.youtubeUrl, (v) => vEntry.value.youtubeUrl = v, context, fieldLoading, setState)),
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => controller.removeVideoFromCategory(e.key, vEntry.key)),
              ])),
              TextButton.icon(onPressed: () => controller.addVideoToCategory(e.key), icon: const Icon(Icons.add), label: const Text('Add Video')),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeVideoCategory(e.key)),
            ]),
          ),
        )),
        ElevatedButton.icon(onPressed: controller.addVideoCategory, icon: const Icon(Icons.add), label: const Text('ADD CATEGORY')),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH VIDEOS')),
      ],
    );
  }

  static Widget _stotraView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('STOTRA / BHAJAN'),
        _buildImageField('Page Top Header Image', controller.stotraSection.topHeaderImage, (v) => setState(() => controller.stotraSection.topHeaderImage = v), context, fieldLoading, setState),
        _buildField('Page Title', controller.stotraSection.pageTitle, (v) => controller.stotraSection.pageTitle = v, context, fieldLoading, setState, translateKey: 'st_p_title', onTranslated: (hi, gu) { controller.stotraSection.pageTitleHi = hi; controller.stotraSection.pageTitleGu = gu; }),
        ...controller.stotraSection.items.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _buildField('Item Title', e.value.title, (v) => e.value.title = v, context, fieldLoading, setState, translateKey: 'st_t_${e.key}', onTranslated: (hi, gu) { e.value.titleHi = hi; e.value.titleGu = gu; }),
              _buildField('English PDF URL', e.value.englishPdfUrl, (v) => e.value.englishPdfUrl = v, context, fieldLoading, setState),
              _buildField('Hindi PDF URL', e.value.hindiPdfUrl, (v) => e.value.hindiPdfUrl = v, context, fieldLoading, setState),
              _buildField('Gujarati PDF URL', e.value.gujaratiPdfUrl, (v) => e.value.gujaratiPdfUrl = v, context, fieldLoading, setState),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeStotraItem(e.key)),
            ]),
          ),
        )),
        ElevatedButton.icon(onPressed: controller.addStotraItem, icon: const Icon(Icons.add), label: const Text('ADD STOTRA')),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH STOTRAS')),
      ],
    );
  }

  static Widget _contactPageView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final c = controller.contactPageData;
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('CONTACT SETTINGS'),
        _buildImageField('Header Banner Image', c.bannerImageUrl, (v) => setState(() => c.bannerImageUrl = v), context, fieldLoading, setState),
        _buildField('Email Address', c.email, (v) => c.email = v, context, fieldLoading, setState),
        _buildField('Phone Number', c.phone, (v) => c.phone = v, context, fieldLoading, setState),
        _buildField('Address', c.address, (v) => c.address = v, context, fieldLoading, setState, translateKey: 'c_addr', onTranslated: (hi, gu) { c.addressHi = hi; c.addressGu = gu; }),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH CONTACT')),
      ],
    );
  }

  static Widget _footerSettingsView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final f = controller.footer;
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('FOOTER SETTINGS'),
        _buildField('About Description', f.description, (v) => f.description = v, context, fieldLoading, setState, maxLines: 4, translateKey: 'f_desc', onTranslated: (hi, gu) { f.descriptionHi = hi; f.descriptionGu = gu; }),
        _buildField('Copyright Text', f.copyright, (v) => f.copyright = v, context, fieldLoading, setState),
        const SizedBox(height: 24),
        _sectionHeader('SOCIAL LINKS'),
        _buildField('YouTube', f.youtubeUrl, (v) => f.youtubeUrl = v, context, fieldLoading, setState),
        _buildField('Instagram', f.instagramUrl, (v) => f.instagramUrl = v, context, fieldLoading, setState),
        _buildField('Facebook', f.facebookUrl, (v) => f.facebookUrl = v, context, fieldLoading, setState),
        _buildField('WhatsApp', f.whatsappUrl, (v) => f.whatsappUrl = v, context, fieldLoading, setState),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH FOOTER')),
      ],
    );
  }
}

class _AdminTextFieldWidget extends StatefulWidget {
  final String label;
  final String initialValue;
  final Function(String) onChanged;
  final int maxLines;
  final String? translateKey;
  final Function(String, String)? onTranslated;
  final Map<String, bool> fieldLoading;
  final Function(VoidCallback) parentSetState;

  const _AdminTextFieldWidget({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    required this.maxLines,
    this.translateKey,
    this.onTranslated,
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
      final oldSelection = _controller.selection;
      _controller.text = widget.initialValue;
      try {
        _controller.selection = oldSelection;
      } catch (_) {
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool loading = widget.translateKey != null && (widget.fieldLoading[widget.translateKey] ?? false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              if (widget.translateKey != null && widget.onTranslated != null)
                TextButton.icon(
                  onPressed: loading ? null : () => CMSViewsHelper._translateField(widget.translateKey!, _controller.text, widget.onTranslated!, widget.fieldLoading, widget.parentSetState),
                  icon: loading 
                    ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber)) 
                    : const Icon(Icons.translate, size: 14, color: Colors.amber),
                  label: Text(loading ? 'Translating...' : 'Translate', style: const TextStyle(fontSize: 12, color: Colors.amber)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            maxLines: widget.maxLines,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
