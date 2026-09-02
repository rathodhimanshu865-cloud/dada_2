import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/review_controller.dart';
import '../../models/homepage_model.dart';
import '../../models/review_model.dart';
import '../../models/contact_model.dart';
import '../../services/translation_service.dart';
import 'biography_editor.dart';
import 'devotee_management_view.dart';

class CMSViewsHelper {
  static Widget buildCMSView(String type, HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    switch (type) {
      case 'settings': return _siteConfigGroupedView(controller, context, fieldLoading, setState);
      case 'home': return _homePageEditorGroupedView(controller, context, fieldLoading, setState);
      case 'about_page': return const BiographyEditor();
      case 'katha_pages': return _kathaPagesView(controller, context, fieldLoading, setState);
      case 'katha_list': return _kathaListView(controller, context, fieldLoading, setState);
      case 'upcoming': return _upcomingKathasView(controller, context, fieldLoading, setState);
      case 'stotra': return _stotraView(controller, context, fieldLoading, setState);
      case 'photo': return _photoGalleryView(controller, context, fieldLoading, setState);
      case 'video': return _videoGalleryView(controller, context, fieldLoading, setState);
      case 'news': return _newsView(controller, context, fieldLoading, setState);
      case 'contact': return _userDataGroupedView(controller, context, fieldLoading, setState);
      case 'home_portal': return _homePortalEditView(controller, context, fieldLoading, setState);
      case 'catalogue': return _catalogueSettingsView(controller, context, fieldLoading, setState);
      case 'teachings': return _teachingsEditorView(controller, context, fieldLoading, setState);
      default: return Center(child: Text(AppLocalizations.of(context)!.invalidViewType));
    }
  }

  static Widget _siteConfigGroupedView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [Tab(text: AppLocalizations.of(context)!.generalTab), Tab(text: AppLocalizations.of(context)!.headerTab), Tab(text: AppLocalizations.of(context)!.footerTab)],
            labelColor: const Color(0xFF0F4C5C),
            indicatorColor: Colors.amber,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _generalSettingsView(controller, context, fieldLoading, setState),
                _headerSettingsView(controller, context, fieldLoading, setState),
                _footerSettingsView(controller, context, fieldLoading, setState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _headerSettingsView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final s = controller.websiteSettings;
    final h = s.headerSettings;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader(AppLocalizations.of(context)!.headerCustomization),
        _buildToggle(AppLocalizations.of(context)!.stickyHeader, h.stickyHeaderEnabled, (v) => setState(() => h.stickyHeaderEnabled = v)),
        _buildToggle(AppLocalizations.of(context)!.searchVisibility, h.searchVisibility, (v) => setState(() => h.searchVisibility = v)),
        _buildField(AppLocalizations.of(context)!.announcementBarText, h.announcementBarText, (v) => h.announcementBarText = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.backgroundColorHex, h.headerBackgroundColor, (v) => h.headerBackgroundColor = v, context, fieldLoading, setState),
        
        _sectionHeader(AppLocalizations.of(context)!.headerCta),
        _buildToggle(AppLocalizations.of(context)!.enableDonationButton, h.donateButtonEnabled, (v) => setState(() => h.donateButtonEnabled = v)),
        _buildField(AppLocalizations.of(context)!.buttonLabel, h.donateButtonText, (v) => h.donateButtonText = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.redirectionUrl, h.donateButtonUrl, (v) => h.donateButtonUrl = v, context, fieldLoading, setState),
        
        const SizedBox(height: 40),
        ElevatedButton(onPressed: controller.publish, child: Text(AppLocalizations.of(context)!.saveHeaderSettings)),
      ],
    );
  }

  static Widget _homePageEditorGroupedView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final h = controller.homepageData;
    return Column(
      children: [
        _topActionBar(AppLocalizations.of(context)!.unifiedHomePageEditor, [
          ElevatedButton.icon(
            onPressed: controller.publish,
            icon: const Icon(Icons.publish),
            label: Text(AppLocalizations.of(context)!.saveAllChanges),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          ),
        ]),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _sectionHeader(AppLocalizations.of(context)!.homePageSectionsVisibility),
              Text(AppLocalizations.of(context)!.toggleSectionsDesc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              
              _homePageSectionWrapper(
                context: context,
                title: AppLocalizations.of(context)!.heroSection,
                isVisible: h.showHeroSlider,
                onToggle: (v) => controller.toggleHomeVisibility('hero'),
                child: _heroSliderView(controller, context, fieldLoading, setState, embedded: true),
              ),
              _homePageSectionWrapper(
                context: context,
                title: AppLocalizations.of(context)!.featuredQuoteSection,
                isVisible: h.showFeaturedQuote,
                onToggle: (v) => controller.toggleHomeVisibility('quote'),
                child: _featuredQuoteView(controller, context, fieldLoading, setState, embedded: true),
              ),
              _homePageSectionWrapper(
                context: context,
                title: AppLocalizations.of(context)!.aboutSection,
                isVisible: h.showAboutPreview,
                onToggle: (v) => controller.toggleHomeVisibility('about'),
                child: _homepageAboutView(controller, context, fieldLoading, setState, embedded: true),
              ),
              _homePageSectionWrapper(
                context: context,
                title: AppLocalizations.of(context)!.upcomingKathasTitle,
                isVisible: h.showUpcomingKathas,
                onToggle: (v) => controller.toggleHomeVisibility('katha'),
                child: _upcomingKathasView(controller, context, fieldLoading, setState, embedded: true),
              ),
              _homePageSectionWrapper(
                context: context,
                title: AppLocalizations.of(context)!.latestVideos,
                isVisible: h.showLatestVideos,
                onToggle: (v) => controller.toggleHomeVisibility('videos'),
                child: _videoGalleryView(controller, context, fieldLoading, setState, embedded: true, recentOnly: true),
              ),
              _homePageSectionWrapper(
                context: context,
                title: AppLocalizations.of(context)!.photoGalleryTitle,
                isVisible: h.showPhotoGallery,
                onToggle: (v) => controller.toggleHomeVisibility('gallery'),
                child: _photoGalleryView(controller, context, fieldLoading, setState, embedded: true, recentOnly: true),
              ),
              _homePageSectionWrapper(
                context: context,
                title: AppLocalizations.of(context)!.dailySuvicharTitle,
                isVisible: h.showDailySuvichar,
                onToggle: (v) => controller.toggleHomeVisibility('suvichar'),
                child: _dailySuvicharView(controller, context, fieldLoading, setState, embedded: true),
              ),
              _homePageSectionWrapper(
                context: context,
                title: AppLocalizations.of(context)!.ramKathaPreviewSection,
                isVisible: h.showRamKathaSection,
                onToggle: (v) => controller.toggleHomeVisibility('ramkatha'),
                child: _ramKathaView(controller, context, fieldLoading, setState, embedded: true),
              ),
              _homePageSectionWrapper(
                context: context,
                title: AppLocalizations.of(context)!.newsUpdatesTitle,
                isVisible: h.showNewsSection,
                onToggle: (v) => controller.toggleHomeVisibility('news'),
                child: _newsView(controller, context, fieldLoading, setState, embedded: true),
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _homePageSectionWrapper({required BuildContext context, required String title, required bool isVisible, required Function(bool) onToggle, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 32),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isVisible ? Colors.amber.withOpacity(0.3) : Colors.grey.shade200, width: 2)),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isVisible ? const Color(0xFF0F4C5C) : Colors.grey)),
        leading: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: isVisible ? Colors.amber : Colors.grey),
        trailing: Switch(value: isVisible, onChanged: onToggle, activeColor: Colors.amber),
        childrenPadding: const EdgeInsets.all(20),
        children: [
          if (!isVisible) Padding(padding: const EdgeInsets.only(bottom: 20), child: Text(AppLocalizations.of(context)!.sectionHiddenWarning, style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold))),
          child,
        ],
      ),
    );
  }

  static Widget _mediaContentGroupedView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [Tab(text: AppLocalizations.of(context)!.biographyTab), Tab(text: AppLocalizations.of(context)!.kathasTab), Tab(text: AppLocalizations.of(context)!.galleryTab), Tab(text: AppLocalizations.of(context)!.stotraTab), Tab(text: AppLocalizations.of(context)!.newsTab), Tab(text: AppLocalizations.of(context)!.kathaPagesTab)],
            labelColor: const Color(0xFF0F4C5C),
            indicatorColor: Colors.amber,
          ),
          Expanded(
            child: TabBarView(
              children: [
                const BiographyEditor(),
                _kathaListView(controller, context, fieldLoading, setState),
                _galleryTabsView(controller, context, fieldLoading, setState),
                _stotraView(controller, context, fieldLoading, setState),
                _newsView(controller, context, fieldLoading, setState),
                _kathaPagesView(controller, context, fieldLoading, setState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _galleryTabsView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(tabs: [Tab(text: AppLocalizations.of(context)!.photosTab), Tab(text: AppLocalizations.of(context)!.videosTab)], labelColor: Colors.black, indicatorColor: Colors.amber),
          Expanded(
            child: TabBarView(
              children: [
                _photoGalleryView(controller, context, fieldLoading, setState),
                _videoGalleryView(controller, context, fieldLoading, setState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _userDataGroupedView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [Tab(text: AppLocalizations.of(context)!.devoteeManagementTab), Tab(text: AppLocalizations.of(context)!.contactEnquiriesTab)], 
            labelColor: const Color(0xFF0F4C5C), 
            indicatorColor: Colors.amber,
          ),
          Expanded(
            child: TabBarView(
              children: [
                const DevoteeManagementView(),
                _contactPageView(controller, context, fieldLoading, setState),
              ],
            ),
          ),
        ],
      ),
    );
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

  static Widget _sectionHeaderWithAction(BuildContext context, String title, String buttonLabel, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Color(0xFF0F4C5C))),
              const SizedBox(height: 8),
              Container(height: 3, width: 60, decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(2))),
            ],
          ),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add, size: 18),
            label: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4C5C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _topActionBar(String title, List<Widget> actions) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Color(0xFF0F4C5C))),
              const SizedBox(height: 4),
              Container(height: 3, width: 40, decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(2))),
            ],
          ),
          Row(children: actions),
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

  static Widget _buildImageField(BuildContext context, String label, String currentUrl, Function(String) onUploaded, BuildContext contextRef, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
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
                Expanded(child: _buildField(AppLocalizations.of(context)!.imageUrl, currentUrl, onUploaded, contextRef, fieldLoading, setState)),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final controller = Provider.of<HomePageController>(contextRef, listen: false);
                    final url = await controller.uploadPhotoFromFile();
                    if (url != null) onUploaded(url);
                  },
                  child: Text(AppLocalizations.of(context)!.upload),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildListField(BuildContext context, String label, List<String> items, Function(List<String>) onUpdate, BuildContext contextRef, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
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
            }, contextRef, fieldLoading, setState)),
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
        }, icon: const Icon(Icons.add), label: Text(AppLocalizations.of(context)!.addItemTo(label))),
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
        _sectionHeader(AppLocalizations.of(context)!.generalTab.toUpperCase() + ' ' + AppLocalizations.of(context)!.storeSettingsTab.toUpperCase()),
        _buildField(AppLocalizations.of(context)!.organizationName, s.name, (v) => s.name = v, context, fieldLoading, setState),
        _buildImageField(context, AppLocalizations.of(context)!.websiteLogo, s.logoUrl, (v) => setState(() => s.logoUrl = v), context, fieldLoading, setState),

        _sectionHeader('GOOGLE CLOUD TRANSLATION'),
        _buildField('Google Cloud API Key', TranslationService.googleApiKey ?? '', (v) {
          TranslationService.init(apiKey: v);
        }, context, fieldLoading, setState),
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('Required for Google Translation functionality. Leave empty to use fallback provider.', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        
        _sectionHeader(AppLocalizations.of(context)!.headerTab.toUpperCase() + ' ' + AppLocalizations.of(context)!.storeSettingsTab.toUpperCase()),
        _buildToggle(AppLocalizations.of(context)!.stickyHeader, h.stickyHeaderEnabled, (v) => setState(() => h.stickyHeaderEnabled = v)),
        _buildToggle(AppLocalizations.of(context)!.searchVisibility, h.searchVisibility, (v) => setState(() => h.searchVisibility = v)),
        _buildField(AppLocalizations.of(context)!.announcementBar, h.announcementBarText, (v) => h.announcementBarText = v, context, fieldLoading, setState),
        
        _sectionHeader(AppLocalizations.of(context)!.headerCta),
        _buildToggle(AppLocalizations.of(context)!.enableDonationButton, h.donateButtonEnabled, (v) => setState(() => h.donateButtonEnabled = v)),
        _buildField(AppLocalizations.of(context)!.buttonLabel, h.donateButtonText, (v) => h.donateButtonText = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.redirectionUrl, h.donateButtonUrl, (v) => h.donateButtonUrl = v, context, fieldLoading, setState),
        
        _sectionHeader(AppLocalizations.of(context)!.headerTab.toUpperCase() + ' ' + 'APPEARANCE'),
        _buildField(AppLocalizations.of(context)!.backgroundColorHex, h.headerBackgroundColor, (v) => h.headerBackgroundColor = v, context, fieldLoading, setState),
        
        const SizedBox(height: 30),
        ElevatedButton(onPressed: controller.publish, child: Text(AppLocalizations.of(context)!.saveChanges.toUpperCase())),
      ],
    );
  }

  static Widget _heroSliderView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState, {bool embedded = false}) {
    final body = ListView(
      shrinkWrap: embedded,
      physics: embedded ? const NeverScrollableScrollPhysics() : null,
      padding: embedded ? EdgeInsets.zero : const EdgeInsets.all(24),
      children: [
        if (embedded) _sectionHeader(AppLocalizations.of(context)!.heroSlides),
        ...controller.heroSection.slides.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 24),
            elevation: embedded ? 0 : 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade100)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(AppLocalizations.of(context)!.slideNumber(i + 1), style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeHeroSlide(i))]),
                  _buildField(AppLocalizations.of(context)!.badgeLabel, s.badge, (v) => s.badge = v, context, fieldLoading, setState),
                  _buildField(AppLocalizations.of(context)!.headingLabel, s.heading, (v) => s.heading = v, context, fieldLoading, setState, maxLines: 2),
                  _buildField(AppLocalizations.of(context)!.subtitleLabel, s.subtitle, (v) => s.subtitle = v, context, fieldLoading, setState),
                  _buildField(AppLocalizations.of(context)!.descriptionLabel, s.description, (v) => s.description = v, context, fieldLoading, setState, maxLines: 3),
                  Row(
                    children: [
                      Expanded(child: _buildField(AppLocalizations.of(context)!.primaryCtaText, s.primaryCtaText, (v) => s.primaryCtaText = v, context, fieldLoading, setState)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField(AppLocalizations.of(context)!.primaryCtaUrl, s.primaryCtaUrl, (v) => s.primaryCtaUrl = v, context, fieldLoading, setState)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildField(AppLocalizations.of(context)!.secondaryCtaText, s.secondaryCtaText, (v) => s.secondaryCtaText = v, context, fieldLoading, setState)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField(AppLocalizations.of(context)!.secondaryCtaUrl, s.secondaryCtaUrl, (v) => s.secondaryCtaUrl = v, context, fieldLoading, setState)),
                    ],
                  ),
                  _buildImageField(context, AppLocalizations.of(context)!.slideImage, s.image, (v) => setState(() => s.image = v), context, fieldLoading, setState),
                ],
              ),
            ),
          );
        }),
        if (embedded) ElevatedButton.icon(onPressed: controller.addHeroSlide, icon: const Icon(Icons.add), label: Text(AppLocalizations.of(context)!.addSlide)),
      ],
    );

    if (embedded) return body;

    return Column(
      children: [
        _topActionBar(AppLocalizations.of(context)!.homepageHeroSlider, [
          ElevatedButton.icon(
            onPressed: controller.addHeroSlide,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addNewSlide),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: controller.publish,
            icon: const Icon(Icons.publish),
            label: Text(AppLocalizations.of(context)!.publish),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          ),
        ]),
        Expanded(child: body),
      ],
    );
  }

  static Widget _kathaPagesView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [Tab(text: AppLocalizations.of(context)!.shreemadBhagvatTab), Tab(text: AppLocalizations.of(context)!.devibhagvatTab), Tab(text: AppLocalizations.of(context)!.shivmahapuranTab)], 
            labelColor: Colors.black,
            indicatorColor: Colors.amber,
          ),
          Expanded(
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
        _sectionHeader(AppLocalizations.of(context)!.heroSection),
        _buildField(AppLocalizations.of(context)!.heroBadge, k.heroBadge, (v) => k.heroBadge = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.heroTitle, k.heroTitle, (v) => k.heroTitle = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.heroDesc1, k.heroDesc1, (v) => k.heroDesc1 = v, context, fieldLoading, setState, maxLines: 3),
        _buildField(AppLocalizations.of(context)!.heroDesc2, k.heroDesc2, (v) => k.heroDesc2 = v, context, fieldLoading, setState, maxLines: 3),
        _buildImageField(context, AppLocalizations.of(context)!.heroImageLabel, k.heroImage, (v) => setState(() => k.heroImage = v), context, fieldLoading, setState),
        
        _sectionHeader(AppLocalizations.of(context)!.biographyQuote),
        _buildField(AppLocalizations.of(context)!.biographyText, k.bioText, (v) => k.bioText = v, context, fieldLoading, setState, maxLines: 5),
        _buildField(AppLocalizations.of(context)!.quoteLabel, k.quoteText, (v) => k.quoteText = v, context, fieldLoading, setState, maxLines: 3),
        _buildField(AppLocalizations.of(context)!.quoteAuthor, k.quoteAuthor, (v) => k.quoteAuthor = v, context, fieldLoading, setState),
        _buildImageField(context, AppLocalizations.of(context)!.quoteImage, k.quoteImage, (v) => setState(() => k.quoteImage = v), context, fieldLoading, setState),
        
        _sectionHeader(AppLocalizations.of(context)!.highlights),
        _buildField(AppLocalizations.of(context)!.highlightTitle(1), k.highlight1Title, (v) => k.highlight1Title = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.highlightDesc(1), k.highlight1Desc, (v) => k.highlight1Desc = v, context, fieldLoading, setState, maxLines: 3),
        _buildField(AppLocalizations.of(context)!.highlightTitle(2), k.highlight2Title, (v) => k.highlight2Title = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.highlightDesc(2), k.highlight2Desc, (v) => k.highlight2Desc = v, context, fieldLoading, setState, maxLines: 3),
        _buildField(AppLocalizations.of(context)!.highlightTitle(3), k.highlight3Title, (v) => k.highlight3Title = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.highlightDesc(3), k.highlight3Desc, (v) => k.highlight3Desc = v, context, fieldLoading, setState, maxLines: 3),
        
        _sectionHeader(AppLocalizations.of(context)!.callToAction),
        _buildField(AppLocalizations.of(context)!.ctaTitle, k.ctaTitle, (v) => k.ctaTitle = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.ctaSubtitle, k.ctaSubtitle, (v) => k.ctaSubtitle = v, context, fieldLoading, setState, maxLines: 2),
        _buildField(AppLocalizations.of(context)!.ctaButtonText, k.ctaButtonText, (v) => k.ctaButtonText = v, context, fieldLoading, setState),
        
        const SizedBox(height: 40),
        ElevatedButton(onPressed: () => controller.publish(), child: Text(AppLocalizations.of(context)!.saveKathaPage)),
        const SizedBox(height: 60),
      ],
    );
  }

  static Widget _upcomingKathasView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState, {bool embedded = false}) {
    final body = ListView(
      shrinkWrap: embedded,
      physics: embedded ? const NeverScrollableScrollPhysics() : null,
      padding: embedded ? EdgeInsets.zero : const EdgeInsets.all(24),
      children: [
        if (embedded) _sectionHeader(AppLocalizations.of(context)!.eventList),
        ...controller.upcomingKathas.asMap().entries.map((entry) {
          final i = entry.key;
          final k = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            elevation: embedded ? 0 : 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade100)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(AppLocalizations.of(context)!.eventNumber(i+1), style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeKatha(i))]),
                  _buildField(AppLocalizations.of(context)!.kathaNumberLabel, k.kathaNumber, (v) => k.kathaNumber = v, context, fieldLoading, setState),
                  _buildField(AppLocalizations.of(context)!.kathaNameLabel, k.name, (v) => k.name = v, context, fieldLoading, setState),
                  _buildField(AppLocalizations.of(context)!.dateDisplayString, k.dateString, (v) => k.dateString = v, context, fieldLoading, setState),
                  _buildField(AppLocalizations.of(context)!.timingLabel, k.timing, (v) => k.timing = v, context, fieldLoading, setState),
                  _buildField(AppLocalizations.of(context)!.locationLabel, k.location, (v) => k.location = v, context, fieldLoading, setState),
                  _buildField(AppLocalizations.of(context)!.hostingLabel, k.hosting, (v) => k.hosting = v, context, fieldLoading, setState),
                  _buildField(AppLocalizations.of(context)!.descriptionLabel, k.description, (v) => k.description = v, context, fieldLoading, setState, maxLines: 3),
                ],
              ),
            ),
          );
        }),
        if (embedded) ElevatedButton.icon(onPressed: controller.addKatha, icon: const Icon(Icons.add), label: Text(AppLocalizations.of(context)!.addKathaButton)),
      ],
    );

    if (embedded) return body;

    return Column(
      children: [
        _topActionBar(AppLocalizations.of(context)!.upcomingKathasTitle, [
          ElevatedButton.icon(
            onPressed: controller.addKatha,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addKathaButton),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: controller.publish,
            icon: const Icon(Icons.publish),
            label: Text(AppLocalizations.of(context)!.publish),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          ),
        ]),
        Expanded(child: body),
      ],
    );
  }

  static Widget _homePageManagementView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final h = controller.homepageData;
    return Column(
      children: [
        _topActionBar(AppLocalizations.of(context)!.homePageManagement, [
          ElevatedButton.icon(
            onPressed: controller.publish,
            icon: const Icon(Icons.publish),
            label: Text(AppLocalizations.of(context)!.publishAll),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          ),
        ]),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _sectionHeader(AppLocalizations.of(context)!.sectionVisibilityAccess),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildToggle(AppLocalizations.of(context)!.heroSection, h.showHeroSlider, (v) => controller.toggleHomeVisibility('hero')),
                      _buildToggle(AppLocalizations.of(context)!.featuredQuoteSection, h.showFeaturedQuote, (v) => controller.toggleHomeVisibility('quote')),
                      _buildToggle(AppLocalizations.of(context)!.aboutSection, h.showAboutPreview, (v) => controller.toggleHomeVisibility('about')),
                      _buildToggle(AppLocalizations.of(context)!.upcomingKathasTitle, h.showUpcomingKathas, (v) => controller.toggleHomeVisibility('katha')),
                      _buildToggle(AppLocalizations.of(context)!.latestVideos, h.showLatestVideos, (v) => controller.toggleHomeVisibility('videos')),
                      _buildToggle(AppLocalizations.of(context)!.photoGalleryTitle, h.showPhotoGallery, (v) => controller.toggleHomeVisibility('gallery')),
              _buildToggle('Show Teachings Section', h.showTeachings, (v) => controller.toggleHomeVisibility('teachings')),
              _buildToggle(AppLocalizations.of(context)!.dailySuvicharTitle, h.showDailySuvichar, (v) => controller.toggleHomeVisibility('suvichar')),
                      _buildToggle(AppLocalizations.of(context)!.ramKathaPreview, h.showRamKathaSection, (v) => controller.toggleHomeVisibility('ramkatha')),
                      _buildToggle(AppLocalizations.of(context)!.newsUpdatesTitle, h.showNewsSection, (v) => controller.toggleHomeVisibility('news')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _homepageAboutView(controller, context, fieldLoading, setState, embedded: true),
              const Divider(height: 64, thickness: 1),
              _featuredQuoteView(controller, context, fieldLoading, setState, embedded: true),
              const Divider(height: 64, thickness: 1),
              _dailySuvicharView(controller, context, fieldLoading, setState, embedded: true),
              const Divider(height: 64, thickness: 1),
              _ramKathaView(controller, context, fieldLoading, setState, embedded: true),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _homepageAboutView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState, {bool embedded = false}) {
    final a = controller.aboutSection;
    final content = [
        _sectionHeader(AppLocalizations.of(context)!.biographySectionHome),
        _buildField(AppLocalizations.of(context)!.displayTitle, a.title, (v) => a.title = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.tagline, a.tagline, (v) => a.tagline = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.quoteLabel, a.quote, (v) => a.quote = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.mainIntroDesc, a.description, (v) => a.description = v, context, fieldLoading, setState, maxLines: 4),
        _buildImageField(context, AppLocalizations.of(context)!.biographyPhoto, a.photoUrl, (v) => setState(() => a.photoUrl = v), context, fieldLoading, setState),
        
        _sectionHeader(AppLocalizations.of(context)!.detailedParagraphs),
        _buildListField(context, AppLocalizations.of(context)!.paragraphsLabel, a.paragraphs, (v) => a.paragraphs = v, context, fieldLoading, setState),
        
        _sectionHeader(AppLocalizations.of(context)!.galleryImages),
        _buildListField(context, AppLocalizations.of(context)!.imageUrlsLabel, a.galleryImages, (v) => a.galleryImages = v, context, fieldLoading, setState),
    ];

    if (embedded) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: content);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ...content,
        const SizedBox(height: 40),
        ElevatedButton(onPressed: controller.publish, child: Text(AppLocalizations.of(context)!.saveAboutData)),
      ],
    );
  }

  static Widget _featuredQuoteView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState, {bool embedded = false}) {
    final q = controller.homepageData.featuredQuote;
    final content = [
        _sectionHeader(AppLocalizations.of(context)!.featuredQuoteSection),
        _buildField(AppLocalizations.of(context)!.quoteTextLabel, q.quote, (v) => q.quote = v, context, fieldLoading, setState, maxLines: 3),
        _buildField(AppLocalizations.of(context)!.authorLabel, q.author, (v) => q.author = v, context, fieldLoading, setState),
        _buildImageField(context, AppLocalizations.of(context)!.portraitImage, q.portrait, (v) => setState(() => q.portrait = v), context, fieldLoading, setState),
        _buildImageField(context, AppLocalizations.of(context)!.backgroundImage, q.background, (v) => setState(() => q.background = v), context, fieldLoading, setState),
    ];

    if (embedded) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: content);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ...content,
        const SizedBox(height: 40),
        ElevatedButton(onPressed: controller.publish, child: Text(AppLocalizations.of(context)!.saveQuote)),
      ],
    );
  }

  static Widget _dailySuvicharView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState, {bool embedded = false}) {
    final d = controller.dailySuvichar;
    final content = [
        _sectionHeader(AppLocalizations.of(context)!.dailySuvicharTitle),
        _buildField(AppLocalizations.of(context)!.dateLabel, d.date, (v) => d.date = v, context, fieldLoading, setState),
        _buildImageField(context, AppLocalizations.of(context)!.suvicharImage, d.imageUrl, (v) => setState(() => d.imageUrl = v), context, fieldLoading, setState),
    ];

    if (embedded) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: content);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ...content,
        const SizedBox(height: 40),
        ElevatedButton(onPressed: controller.publish, child: Text(AppLocalizations.of(context)!.saveSuvichar)),
      ],
    );
  }

  static Widget _ramKathaView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState, {bool embedded = false}) {
    final r = controller.ramKatha;
    final content = [
        _sectionHeader(AppLocalizations.of(context)!.ramKathaPreviewSection),
        _buildField(AppLocalizations.of(context)!.title, r.title, (v) => r.title = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.descPara1, r.description1, (v) => r.description1 = v, context, fieldLoading, setState, maxLines: 4),
        _buildField(AppLocalizations.of(context)!.descPara2, r.description2, (v) => r.description2 = v, context, fieldLoading, setState, maxLines: 4),
        _buildImageField(context, AppLocalizations.of(context)!.sectionPhoto, r.photoUrl, (v) => setState(() => r.photoUrl = v), context, fieldLoading, setState),
    ];

    if (embedded) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: content);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ...content,
        const SizedBox(height: 40),
        ElevatedButton(onPressed: controller.publish, child: Text(AppLocalizations.of(context)!.saveRamKathaSection)),
      ],
    );
  }

  static Widget _newsView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState, {bool embedded = false}) {
    final body = ListView(
      shrinkWrap: embedded,
      physics: embedded ? const NeverScrollableScrollPhysics() : null,
      padding: embedded ? EdgeInsets.zero : const EdgeInsets.all(24),
      children: [
        if (embedded) _sectionHeader(AppLocalizations.of(context)!.latestNewsItems),
        ...controller.homepageData.news.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          elevation: embedded ? 0 : 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade100)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(AppLocalizations.of(context)!.newsItemNumber(e.key + 1), style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => controller.homepageData.news.removeAt(e.key)))]),
              _buildField(AppLocalizations.of(context)!.title, e.value.title, (v) => e.value.title = v, context, fieldLoading, setState),
              _buildField(AppLocalizations.of(context)!.category, e.value.category, (v) => e.value.category = v, context, fieldLoading, setState),
              _buildField(AppLocalizations.of(context)!.dateDisplayString, e.value.date, (v) => e.value.date = v, context, fieldLoading, setState),
              _buildField(AppLocalizations.of(context)!.targetUrl, e.value.url, (v) => e.value.url = v, context, fieldLoading, setState),
              _buildImageField(context, AppLocalizations.of(context)!.newsImage, e.value.image, (v) => setState(() => e.value.image = v), context, fieldLoading, setState),
            ]),
          ),
        )),
        if (embedded) ElevatedButton.icon(onPressed: () => setState(() => controller.homepageData.news.add(NewsItem())), icon: const Icon(Icons.add), label: Text(AppLocalizations.of(context)!.addNewsButton)),
      ],
    );

    if (embedded) return body;

    return Column(
      children: [
        _topActionBar(AppLocalizations.of(context)!.newsUpdatesTitle, [
          ElevatedButton.icon(
            onPressed: () => setState(() => controller.homepageData.news.add(NewsItem())),
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addNewsButton),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: controller.publish,
            icon: const Icon(Icons.publish),
            label: Text(AppLocalizations.of(context)!.publish),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          ),
        ]),
        Expanded(child: body),
      ],
    );
  }

  static Widget _kathaListView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final kld = controller.kathaListPageData;
    return Column(
      children: [
        _topActionBar(AppLocalizations.of(context)!.fullKathaListTitle, [
          ElevatedButton.icon(
            onPressed: controller.addKathaRecord,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addRecord),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: controller.publish,
            icon: const Icon(Icons.publish),
            label: Text(AppLocalizations.of(context)!.publish),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          ),
        ]),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _sectionHeader(AppLocalizations.of(context)!.kathaListPageSettings),
              _buildImageField(context, AppLocalizations.of(context)!.mainListBannerImage, kld.bannerImageUrl, (v) => setState(() => kld.bannerImageUrl = v), context, fieldLoading, setState),

              _sectionHeader(AppLocalizations.of(context)!.fullKathaArchive),
              ...controller.allKathas.asMap().entries.map((e) => Card(
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(AppLocalizations.of(context)!.kathaRecordNumber(e.key + 1), style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeKathaRecord(e.key))]),
                    _buildField(AppLocalizations.of(context)!.kathaNumberLabel, e.value.kathaNumber, (v) => e.value.kathaNumber = v, context, fieldLoading, setState),
                    _buildField(AppLocalizations.of(context)!.yearLabel, e.value.year, (v) => e.value.year = v, context, fieldLoading, setState),
                    _buildField(AppLocalizations.of(context)!.datesLabel, e.value.dates, (v) => e.value.dates = v, context, fieldLoading, setState),
                    _buildField(AppLocalizations.of(context)!.topicSubject, e.value.topic, (v) => e.value.topic = v, context, fieldLoading, setState),
                    _buildField(AppLocalizations.of(context)!.locationLabel, e.value.location, (v) => e.value.location = v, context, fieldLoading, setState),
                    _buildField(AppLocalizations.of(context)!.countryLabel, e.value.country, (v) => e.value.country = v, context, fieldLoading, setState),
                    _buildField(AppLocalizations.of(context)!.lang, e.value.language, (v) => e.value.language = v, context, fieldLoading, setState),
                    _buildField(AppLocalizations.of(context)!.youtubePlaylistUrl, e.value.youtubePlaylistUrl, (v) => e.value.youtubePlaylistUrl = v, context, fieldLoading, setState),
                    _buildField(AppLocalizations.of(context)!.descriptionLabel, e.value.description, (v) => e.value.description = v, context, fieldLoading, setState, maxLines: 3),
                    _buildImageField(context, AppLocalizations.of(context)!.recordImage, e.value.imageUrl, (v) => setState(() => e.value.imageUrl = v), context, fieldLoading, setState),
                  ]),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _photoGalleryView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState, {bool embedded = false, bool recentOnly = false}) {
    final pgd = controller.photoGalleryData;
    final body = ListView(
      shrinkWrap: embedded,
      physics: embedded ? const NeverScrollableScrollPhysics() : null,
      padding: embedded ? EdgeInsets.zero : const EdgeInsets.all(24),
      children: [
        if (embedded) _sectionHeader(AppLocalizations.of(context)!.featuredPhotoAlbums),
        if (embedded) Text(AppLocalizations.of(context)!.manageSectionsDesc, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ...pgd.sections.toList().take(recentOnly ? 1 : 100).toList().asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          elevation: embedded ? 0 : 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade100)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.value.heading, style: const TextStyle(fontWeight: FontWeight.bold)), if(!embedded) IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removePhotoCategory(e.key))]),
              _buildField(AppLocalizations.of(context)!.headingLabel, e.value.heading, (v) => e.value.heading = v, context, fieldLoading, setState),
              _buildListField(context, AppLocalizations.of(context)!.photoUrlsLabel, e.value.photoUrls, (v) => e.value.photoUrls = v, context, fieldLoading, setState),
            ]),
          ),
        )),
      ],
    );

    if (embedded) return body;

    return Column(
      children: [
        _topActionBar(AppLocalizations.of(context)!.photoGalleryTitle, [
          ElevatedButton.icon(
            onPressed: controller.addPhotoCategory,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addSection),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: controller.publish,
            icon: const Icon(Icons.publish),
            label: Text(AppLocalizations.of(context)!.publish),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          ),
        ]),
        Expanded(child: body),
      ],
    );
  }

  static Widget _videoGalleryView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState, {bool embedded = false, bool recentOnly = false}) {
    final vgd = controller.videoGalleryData;
    final body = ListView(
      shrinkWrap: embedded,
      physics: embedded ? const NeverScrollableScrollPhysics() : null,
      padding: embedded ? EdgeInsets.zero : const EdgeInsets.all(24),
      children: [
        if (embedded) _sectionHeader(AppLocalizations.of(context)!.featuredVideos),
        if (embedded) Text(AppLocalizations.of(context)!.manageVideosDesc, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ...vgd.categories.toList().take(recentOnly ? 1 : 100).toList().asMap().entries.map((e) {
          final catIndex = e.key;
          final cat = e.value;
          return Card(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            elevation: embedded ? 0 : 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade100)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(cat.categoryTitle, style: const TextStyle(fontWeight: FontWeight.bold)), if(!embedded) IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeVideoCategory(catIndex))]),
                const Divider(),
                ...cat.videos.asMap().entries.map((ve) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildField(AppLocalizations.of(context)!.videoTitleLabel, ve.value.title, (v) => ve.value.title = v, context, fieldLoading, setState),
                            _buildField(AppLocalizations.of(context)!.youtubeUrlLabel, ve.value.youtubeUrl, (v) => ve.value.youtubeUrl = v, context, fieldLoading, setState),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeVideoFromCategory(catIndex, ve.key)),
                    ],
                  ),
                )),
                TextButton.icon(onPressed: () => controller.addVideoToCategory(catIndex), icon: const Icon(Icons.add, size: 14), label: Text(AppLocalizations.of(context)!.addVideoButton, style: const TextStyle(fontSize: 12))),
              ]),
            ),
          );
        }),
      ],
    );

    if (embedded) return body;

    return Column(
      children: [
        _topActionBar(AppLocalizations.of(context)!.videoGalleryTitle, [
          ElevatedButton.icon(
            onPressed: controller.addVideoCategory,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addCategory),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: controller.publish,
            icon: const Icon(Icons.publish),
            label: Text(AppLocalizations.of(context)!.publish),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          ),
        ]),
        Expanded(child: body),
      ],
    );
  }

  static Widget _stotraView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    return Column(
      children: [
        _topActionBar(AppLocalizations.of(context)!.stotraBhajanTitle, [
          ElevatedButton.icon(
            onPressed: controller.addStotraItem,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addItem),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: controller.publish,
            icon: const Icon(Icons.publish),
            label: Text(AppLocalizations.of(context)!.publish),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          ),
        ]),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _sectionHeader(AppLocalizations.of(context)!.stotraBhajanPageSettings),
              _buildField(AppLocalizations.of(context)!.pageTitle, controller.stotraSection.pageTitle, (v) => controller.stotraSection.pageTitle = v, context, fieldLoading, setState),
              _buildImageField(context, AppLocalizations.of(context)!.topHeaderImage, controller.stotraSection.topHeaderImage, (v) => setState(() => controller.stotraSection.topHeaderImage = v), context, fieldLoading, setState),
              
              _sectionHeader(AppLocalizations.of(context)!.stotraItems),
              ...controller.stotraSection.items.asMap().entries.map((e) => Card(
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(AppLocalizations.of(context)!.stotraItemNumber(e.key + 1), style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeStotraItem(e.key))]),
                    _buildField(AppLocalizations.of(context)!.itemTitle, e.value.title, (v) => e.value.title = v, context, fieldLoading, setState),
                    _buildField(AppLocalizations.of(context)!.englishPdfUrl, e.value.englishPdfUrl, (v) => e.value.englishPdfUrl = v, context, fieldLoading, setState),
                    _buildField(AppLocalizations.of(context)!.hindiPdfUrl, e.value.hindiPdfUrl, (v) => e.value.hindiPdfUrl = v, context, fieldLoading, setState),
                    _buildField(AppLocalizations.of(context)!.gujaratiPdfUrl, e.value.gujaratiPdfUrl, (v) => e.value.gujaratiPdfUrl = v, context, fieldLoading, setState),
                  ]),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _contactPageView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final c = controller.contactPageData;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader(AppLocalizations.of(context)!.contactPageSettings),
        _buildField(AppLocalizations.of(context)!.emailAddressLabel, c.email, (v) => c.email = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.phoneLabel, c.phone, (v) => c.phone = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.physicalAddress, c.address, (v) => c.address = v, context, fieldLoading, setState, maxLines: 3),
        _buildImageField(context, AppLocalizations.of(context)!.pageBannerImage, c.bannerImageUrl, (v) => setState(() => c.bannerImageUrl = v), context, fieldLoading, setState),
        
        const SizedBox(height: 12),
        ElevatedButton(onPressed: controller.publish, child: Text(AppLocalizations.of(context)!.publishContactSettings)),
        const SizedBox(height: 32),

        _sectionHeader(AppLocalizations.of(context)!.userInquiries),
        if (controller.inquiries.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(40), child: Text(AppLocalizations.of(context)!.noInquiriesYet)))
        else
          ...controller.inquiries.map((inq) => Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(inq.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(DateFormat('dd MMM yyyy, hh:mm a').format(inq.timestamp), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${AppLocalizations.of(context)!.email}: ${inq.email}', style: const TextStyle(fontSize: 12)),
                  Text('${AppLocalizations.of(context)!.phoneLabel}: ${inq.mobile}', style: const TextStyle(fontSize: 12)),
                  Text(AppLocalizations.of(context)!.countryPrefix(inq.country), style: const TextStyle(fontSize: 12)),
                  Text(AppLocalizations.of(context)!.typePrefix(inq.type), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F4C5C))),
                  const Divider(height: 24),
                  Text(AppLocalizations.of(context)!.messageHeader, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(inq.message, style: const TextStyle(fontSize: 13, height: 1.4)),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _replyOnWhatsApp(context, inq.mobile, inq.name),
                      icon: const Icon(Icons.chat, size: 14),
                      label: Text(AppLocalizations.of(context)!.replyOnWhatsApp, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          )),
      ],
    );
  }

  static Future<void> _replyOnWhatsApp(BuildContext context, String phone, String name) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final message = "Pranam $name! Regarding your inquiry on Jignesh Dada Official Website: ";
    final url = "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  static Widget _footerSettingsView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final f = controller.footer;
    return Column(
      children: [
        _topActionBar(AppLocalizations.of(context)!.footerSettings, [
          ElevatedButton.icon(
            onPressed: controller.publish,
            icon: const Icon(Icons.publish),
            label: Text(AppLocalizations.of(context)!.publish),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          ),
        ]),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _sectionHeader(AppLocalizations.of(context)!.footerContent),
              _buildField(AppLocalizations.of(context)!.descriptionLabel, f.description, (v) => f.description = v, context, fieldLoading, setState, maxLines: 4),
              _buildField(AppLocalizations.of(context)!.copyrightText, f.copyright, (v) => f.copyright = v, context, fieldLoading, setState),
              
              _sectionHeader(AppLocalizations.of(context)!.socialMediaLinks),
              _buildField(AppLocalizations.of(context)!.youtubeUrlLabel, f.youtubeUrl, (v) => f.youtubeUrl = v, context, fieldLoading, setState),
              _buildField(AppLocalizations.of(context)!.instagramUrl, f.instagramUrl, (v) => f.instagramUrl = v, context, fieldLoading, setState),
              _buildField(AppLocalizations.of(context)!.facebookUrl, f.facebookUrl, (v) => f.facebookUrl = v, context, fieldLoading, setState),
              _buildField(AppLocalizations.of(context)!.whatsappUrlLabel, f.whatsappUrl, (v) => f.whatsappUrl = v, context, fieldLoading, setState),

              _sectionHeader(AppLocalizations.of(context)!.bottomBarLinks),
              Row(
                children: [
                  Expanded(child: _buildField(AppLocalizations.of(context)!.privacyLabel, f.privacyLabel, (v) => f.privacyLabel = v, context, fieldLoading, setState)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(AppLocalizations.of(context)!.privacyUrl, f.privacyUrl, (v) => f.privacyUrl = v, context, fieldLoading, setState)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildField(AppLocalizations.of(context)!.termsLabel, f.termsLabel, (v) => f.termsLabel = v, context, fieldLoading, setState)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(AppLocalizations.of(context)!.termsUrl, f.termsUrl, (v) => f.termsUrl = v, context, fieldLoading, setState)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildField(AppLocalizations.of(context)!.cookieLabel, f.cookieLabel, (v) => f.cookieLabel = v, context, fieldLoading, setState)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(AppLocalizations.of(context)!.cookieUrl, f.cookieUrl, (v) => f.cookieUrl = v, context, fieldLoading, setState)),
                ],
              ),

              _sectionHeader(AppLocalizations.of(context)!.additionalLinkSections),
              ...f.linkSections.asMap().entries.map((se) {
                final si = se.key;
                final sec = se.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _buildField(AppLocalizations.of(context)!.sectionTitleLabel, sec.title, (v) => sec.title = v, context, fieldLoading, setState)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => controller.removeFooterLinkSection(si)),
                          ],
                        ),
                        const Divider(),
                        ...sec.links.asMap().entries.map((le) {
                          final li = le.key;
                          final link = le.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(child: _buildField(AppLocalizations.of(context)!.badgeLabel, link.label, (v) => link.label = v, context, fieldLoading, setState)),
                                const SizedBox(width: 8),
                                Expanded(child: _buildField('Route/URL', link.route, (v) => link.route = v, context, fieldLoading, setState)),
                                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => controller.removeFooterLink(si, li)),
                              ],
                            ),
                          );
                        }),
                        TextButton.icon(
                          onPressed: () => controller.addFooterLink(si),
                          icon: const Icon(Icons.add),
                          label: Text(AppLocalizations.of(context)!.addLinkToSection),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: controller.addFooterLinkSection,
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.addNewLinkSection),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ],
    );
  }

  // --- Specific Views for "Store & Settings" (Product Management) ---

  static Widget _homePortalEditView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final h = controller.homepageData.homePortal;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader(AppLocalizations.of(context)!.heroSectionContent),
        _buildField(AppLocalizations.of(context)!.heroMainHeading, h.heroHeading, (v) => h.heroHeading = v, context, fieldLoading, setState, maxLines: 2),
        _buildField(AppLocalizations.of(context)!.heroSubtitleIntro, h.heroSubtitle, (v) => h.heroSubtitle = v, context, fieldLoading, setState, maxLines: 3),
        Row(
          children: [
            Expanded(child: _buildField(AppLocalizations.of(context)!.ctaButton1Text, h.heroCta1Text, (v) => h.heroCta1Text = v, context, fieldLoading, setState)),
            const SizedBox(width: 16),
            Expanded(child: _buildField(AppLocalizations.of(context)!.ctaButton2Text, h.heroCta2Text, (v) => h.heroCta2Text = v, context, fieldLoading, setState)),
          ],
        ),
        _buildImageField(context, AppLocalizations.of(context)!.heroBackgroundImage, h.heroImage, (v) => setState(() => h.heroImage = v), context, fieldLoading, setState),
        
        _sectionHeader(AppLocalizations.of(context)!.heroSideCard),
        _buildField(AppLocalizations.of(context)!.cardTitle, h.heroCardTitle, (v) => h.heroCardTitle = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.cardSubtitle, h.heroCardSubtitle, (v) => h.heroCardSubtitle = v, context, fieldLoading, setState, maxLines: 2),
        _buildImageField(context, AppLocalizations.of(context)!.cardFeatureImage, h.heroSideImage, (v) => setState(() => h.heroSideImage = v), context, fieldLoading, setState),

        _sectionHeader(AppLocalizations.of(context)!.sectionHeadings),
        _buildField(AppLocalizations.of(context)!.offeringsCategoriesHeading, h.collectionsHeading, (v) => h.collectionsHeading = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.featuredProductsHeading, h.featuredHeading, (v) => h.featuredHeading = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.testimonialsHeading, h.testimonialsHeading, (v) => h.testimonialsHeading = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.wisdomSuvicharHeading, h.wisdomHeading, (v) => h.wisdomHeading = v, context, fieldLoading, setState),

        _sectionHeader(AppLocalizations.of(context)!.whatsappGuidanceBox),
        _buildField(AppLocalizations.of(context)!.guidanceTitle, h.whatsappTitle, (v) => h.whatsappTitle = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.guidanceSubtitle, h.whatsappSubtitle, (v) => h.whatsappSubtitle = v, context, fieldLoading, setState, maxLines: 2),
        _buildField(AppLocalizations.of(context)!.whatsappBtnText, h.whatsappBtnText, (v) => h.whatsappBtnText = v, context, fieldLoading, setState),

        const SizedBox(height: 60),
        ElevatedButton(
          onPressed: () => controller.publish(),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
          child: Text(AppLocalizations.of(context)!.saveHomePortalChanges, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
        _sectionHeader(AppLocalizations.of(context)!.productCatalogueHeadings),
        _buildField(AppLocalizations.of(context)!.displayTitle, s.catalogueHeading, (v) => s.catalogueHeading = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.subtitleLabel, s.catalogueSubtitle, (v) => s.catalogueSubtitle = v, context, fieldLoading, setState),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: controller.publish, child: Text(AppLocalizations.of(context)!.saveCatalogueSettings)),
      ],
    );
  }

  static Widget _teachingsEditorView(HomePageController controller, BuildContext context, Map<String, bool> fieldLoading, Function(VoidCallback) setState) {
    final t = controller.homepageData.teachingsPage;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionHeader(AppLocalizations.of(context)!.teachingsPageHero),
        _buildField(AppLocalizations.of(context)!.heroTitle, t.heroTitle, (v) => t.heroTitle = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.heroSubtitle, t.heroSubtitle, (v) => t.heroSubtitle = v, context, fieldLoading, setState, maxLines: 2),
        _buildImageField(context, AppLocalizations.of(context)!.heroBackground, t.heroImage, (v) => setState(() => t.heroImage = v), context, fieldLoading, setState),
        
        _sectionHeader(AppLocalizations.of(context)!.divinePurposeSection),
        _buildField(AppLocalizations.of(context)!.sectionTitleLabel, t.divinePurposeTitle, (v) => t.divinePurposeTitle = v, context, fieldLoading, setState),
        _buildField(AppLocalizations.of(context)!.descPara1, t.divinePurposeDesc1, (v) => t.divinePurposeDesc1 = v, context, fieldLoading, setState, maxLines: 3),
        _buildField(AppLocalizations.of(context)!.descPara2, t.divinePurposeDesc2, (v) => t.divinePurposeDesc2 = v, context, fieldLoading, setState, maxLines: 3),
        _buildImageField(context, AppLocalizations.of(context)!.sideImage, t.divinePurposeImage, (v) => setState(() => t.divinePurposeImage = v), context, fieldLoading, setState),
        
        _sectionHeader('SACRED PILLARS (3 SECTIONS)'),
        ...t.pillars.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pillar #${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
              _buildField('Title', p.title, (v) => p.title = v, context, fieldLoading, setState),
              _buildField('Description', p.description, (v) => p.description = v, context, fieldLoading, setState, maxLines: 3),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => t.pillars.removeAt(i)),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Remove Pillar', style: TextStyle(color: Colors.red)),
                ),
              ),
              const Divider(),
            ],
          );
        }),
        const SizedBox(height: 12),
        if (t.pillars.length < 3)
          ElevatedButton.icon(
            onPressed: () => setState(() => t.pillars.add(TeachingCard())),
            icon: const Icon(Icons.add),
            label: const Text('Add Pillar'),
          ),
        
        const SizedBox(height: 40),
        ElevatedButton(onPressed: controller.publish, child: Text(AppLocalizations.of(context)!.saveTeachingsPage)),
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
