import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/homepage_model.dart';
import 'order_management_view.dart';
import 'biography_editor.dart';
import 'product_management_view.dart';
import 'admin_settings_view.dart';
import 'admin_users_view.dart';
import 'admin_notifications_view.dart';
import '../../services/translation_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentMenuIndex = 13; // Default to Product Management as it contains the dashboard logic now
  bool _isSidebarVisible = true;

  final Map<String, bool> _fieldLoading = {};

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    
    if (!auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final controller = Provider.of<HomePageController>(context);
    final prof = Provider.of<ProfileController>(context);
    final bool globalLoading = controller.isLoading || prof.isLoading;

    bool isMobile = MediaQuery.of(context).size.width <= 900;

    return Scaffold(
      appBar: AppBar(
        bottom: globalLoading ? const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: LinearProgressIndicator(backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation<Color>(Colors.amber)),
        ) : null,
        title: const Text('ADMIN PORTAL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(_isSidebarVisible ? Icons.menu_open : Icons.menu),
          onPressed: () {
            if (isMobile) {
              Scaffold.of(context).openDrawer();
            } else {
              setState(() => _isSidebarVisible = !_isSidebarVisible);
            }
          },
        ),
        actions: [
          if (MediaQuery.of(context).size.width > 750) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton.icon(
                onPressed: controller.isLoading ? null : () async {
                   final prof = Provider.of<ProfileController>(context, listen: false);
                   await Future.wait([
                     controller.translateAndPublish(),
                     prof.translateAll(),
                   ]);
                   if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All Sections Translated & Published!')));
                },
                icon: controller.isLoading ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.auto_awesome, size: 14),
                label: Text(controller.isLoading ? 'WORKING...' : 'TRANSLATE & PUBLISH', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, 
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          IconButton(
            tooltip: 'Refresh Data',
            onPressed: controller.loadData, 
            icon: const Icon(Icons.refresh, size: 20)
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isMobile ? Drawer(child: _buildSidebar(isMobile)) : null,
      body: Row(
        children: [
          if (!isMobile && _isSidebarVisible) _buildSidebar(isMobile),
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              child: _buildMainContent(controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isMobile) {
    // ── ROLE-BASED ADMIN SIDEBAR MENU ──────────────────────────────────────
    // Content sections (indices 0-14 = existing content pages)
    final contentMenus = [
      {'title': 'General Settings', 'icon': Icons.settings},
      {'title': 'Hero Slider', 'icon': Icons.burst_mode},
      {'title': 'Biography Editor', 'icon': Icons.person},
      {'title': 'Katha About Pages', 'icon': Icons.menu_book},
      {'title': 'Upcoming Kathas', 'icon': Icons.event},
      {'title': 'Home Page Section', 'icon': Icons.home},
      {'title': 'News & Updates', 'icon': Icons.newspaper},
      {'title': 'Full Katha List', 'icon': Icons.list_alt},
      {'title': 'Photo Gallery', 'icon': Icons.photo_library},
      {'title': 'Video Gallery', 'icon': Icons.video_library},
      {'title': 'Stotra / Bhajan', 'icon': Icons.music_note},
      {'title': 'Contact / Inquiries', 'icon': Icons.contact_mail},
      {'title': 'Footer Settings', 'icon': Icons.south},
      {'title': 'Product Management', 'icon': Icons.shopping_bag_outlined},
      {'title': 'Orders', 'icon': Icons.shopping_cart},
      {'title': 'Users', 'icon': Icons.people_outline},
      {'title': 'Notifications', 'icon': Icons.notifications_outlined},
      {'title': 'Store Settings', 'icon': Icons.admin_panel_settings},
    ];

    return Container(
      width: 280,
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: contentMenus.length,
              itemBuilder: (context, i) => ListTile(
                leading: Icon(contentMenus[i]['icon'] as IconData,
                    color: currentMenuIndex == i ? Colors.amber : Colors.white60),
                title: Text(contentMenus[i]['title'] as String,
                    style: TextStyle(
                        color: currentMenuIndex == i ? Colors.white : Colors.white70,
                        fontWeight: currentMenuIndex == i ? FontWeight.bold : FontWeight.normal)),
                selected: currentMenuIndex == i,
                onTap: () {
                  setState(() => currentMenuIndex = i);
                  if (isMobile) Navigator.pop(context);
                },
              ),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // ── PROFILE & LOGOUT (role-based action items) ──
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined, color: Colors.blueAccent),
            title: const Text('My Profile', style: TextStyle(color: Colors.white70, fontSize: 13)),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
              if (isMobile) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
            onTap: () async {
              if (isMobile) Navigator.pop(context);
              final auth = Provider.of<AuthController>(context, listen: false);
              await auth.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                auth.toggleLoginPortal(true);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.public, color: Colors.blueAccent),
            title: const Text('BACK TO WEBSITE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMainContent(HomePageController controller) {
    switch (currentMenuIndex) {
      case 0:  return _generalSettingsView(controller);
      case 1:  return _heroSliderView(controller);
      case 2:  return const BiographyEditor();
      case 3:  return _kathaPagesView(controller);
      case 4:  return _upcomingKathasView(controller);
      case 5:  return _homepageDataView(controller);
      case 6:  return _newsView(controller);
      case 7:  return _kathaListView(controller);
      case 8:  return _photoGalleryView(controller);
      case 9:  return _videoGalleryView(controller);
      case 10: return _stotraView(controller);
      case 11: return _contactPageView(controller);
      case 12: return _footerSettingsView(controller);
      case 13: return const ProductManagementView();
      case 14: return const OrderManagementView();
      case 15: return const AdminUsersView();
      case 16: return const AdminNotificationsView();
      case 17: return const AdminSettingsView();
      default: return const Center(child: Text('Select a menu'));
    }
  }

  Future<void> _translateField(String key, String original, Function(String, String) onResult) async {
    if (original.trim().isEmpty) return;
    setState(() => _fieldLoading[key] = true);
    final results = await TranslationService.translateToAll(original);
    onResult(results['hi'] ?? '', results['gu'] ?? '');
    setState(() => _fieldLoading[key] = false);
  }

  Widget _sectionHeader(String title) {
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

  Widget _buildField(String label, String value, Function(String) onChanged, {int maxLines = 1, String? translateKey, Function(String, String)? onTranslated}) {
    final bool loading = translateKey != null && (_fieldLoading[translateKey] ?? false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              if (translateKey != null && onTranslated != null)
                TextButton.icon(
                  onPressed: loading ? null : () => _translateField(translateKey, value, onTranslated),
                  icon: loading 
                    ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber)) 
                    : const Icon(Icons.translate, size: 14, color: Colors.amber),
                  label: Text(loading ? 'Translating...' : 'Translate', style: const TextStyle(fontSize: 12, color: Colors.amber)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
            onChanged: onChanged,
            maxLines: maxLines,
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

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
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

  Widget _buildImageField(String label, String currentUrl, Function(String) onUploaded) {
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
                          _buildField('Image URL Link', currentUrl, onUploaded),
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

  EdgeInsets _responsivePadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return EdgeInsets.all(width < 600 ? 16 : 40);
  }

  Widget _generalSettingsView(HomePageController controller) {
    final s = controller.websiteSettings;
    final h = s.headerSettings;
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('GENERAL WEBSITE SETTINGS'),
        _buildField('Organization Name', s.name, (v) => s.name = v, translateKey: 's_name', onTranslated: (hi, gu) { s.nameHi = hi; s.nameGu = gu; }),
        _buildImageField('Website Logo', s.logoUrl, (v) => setState(() => s.logoUrl = v)),
        _sectionHeader('HEADER SETTINGS'),
        _buildToggle('Sticky Header', h.stickyHeaderEnabled, (v) => setState(() => h.stickyHeaderEnabled = v)),
        _buildToggle('Search Visibility', h.searchVisibility, (v) => setState(() => h.searchVisibility = v)),
        _buildField('Announcement Bar', h.announcementBarText, (v) => h.announcementBarText = v, translateKey: 'h_ann', onTranslated: (hi, gu) { h.announcementBarTextHi = hi; h.announcementBarTextGu = gu; }),
        _buildToggle('Donate Button', h.donateButtonEnabled, (v) => setState(() => h.donateButtonEnabled = v)),
        if (h.donateButtonEnabled) ...[
          _buildField('Donate Button Text', h.donateButtonText, (v) => h.donateButtonText = v, translateKey: 'h_don', onTranslated: (hi, gu) { h.donateButtonTextHi = hi; h.donateButtonTextGu = gu; }),
          _buildField('Donate URL', h.donateButtonUrl, (v) => h.donateButtonUrl = v),
        ],
        const SizedBox(height: 30),
        ElevatedButton(onPressed: controller.publish, child: const Text('SAVE GLOBAL SETTINGS')),
      ],
    );
  }

  Widget _heroSliderView(HomePageController controller) {
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
                  _buildField('Badge Text', s.badge, (v) => s.badge = v, translateKey: 'hs_badge_$i', onTranslated: (hi, gu) { s.badgeHi = hi; s.badgeGu = gu; }),
                  _buildField('Heading', s.heading, (v) => s.heading = v, translateKey: 'hs_head_$i', onTranslated: (hi, gu) { s.headingHi = hi; s.headingGu = gu; }),
                  _buildField('Subtitle', s.subtitle, (v) => s.subtitle = v, translateKey: 'hs_sub_$i', onTranslated: (hi, gu) { s.subtitleHi = hi; s.subtitleGu = gu; }),
                  _buildField('Description', s.description, (v) => s.description = v, maxLines: 3, translateKey: 'hs_desc_$i', onTranslated: (hi, gu) { s.descriptionHi = hi; s.descriptionGu = gu; }),
                  _buildImageField('Slide Image', s.image, (v) => setState(() => s.image = v)),
                ],
              ),
            ),
          );
        }),
        ElevatedButton.icon(onPressed: controller.addHeroSlide, icon: const Icon(Icons.add), label: const Text('ADD NEW SLIDE')),
      ],
    );
  }

  Widget _kathaPagesView(HomePageController controller) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'Bhagvat'), Tab(text: 'Devi'), Tab(text: 'Shiv')], labelColor: Colors.black),
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
    String p = k.heroTitle.isNotEmpty ? k.heroTitle.substring(0, 3) : 'k';
    return ListView(
      padding: _responsivePadding(context),
      children: [
        _buildField('Hero Badge', k.heroBadge, (v) => k.heroBadge = v, translateKey: '${p}_badge', onTranslated: (hi, gu) { k.heroBadgeHi = hi; k.heroBadgeGu = gu; }),
        _buildField('Hero Title', k.heroTitle, (v) => k.heroTitle = v, translateKey: '${p}_title', onTranslated: (hi, gu) { k.heroTitleHi = hi; k.heroTitleGu = gu; }),
        _buildField('Desc 1', k.heroDesc1, (v) => k.heroDesc1 = v, maxLines: 4, translateKey: '${p}_d1', onTranslated: (hi, gu) { k.heroDesc1Hi = hi; k.heroDesc1Gu = gu; }),
        _buildField('Desc 2', k.heroDesc2, (v) => k.heroDesc2 = v, maxLines: 4, translateKey: '${p}_d2', onTranslated: (hi, gu) { k.heroDesc2Hi = hi; k.heroDesc2Gu = gu; }),
        _buildImageField('Main Image', k.heroImage, (v) => setState(() => k.heroImage = v)),
        _buildField('Quote', k.quoteText, (v) => k.quoteText = v, maxLines: 3, translateKey: '${p}_q', onTranslated: (hi, gu) { k.quoteTextHi = hi; k.quoteTextGu = gu; }),
        _buildField('Author', k.quoteAuthor, (v) => k.quoteAuthor = v, translateKey: '${p}_qa', onTranslated: (hi, gu) { k.quoteAuthorHi = hi; k.quoteAuthorGu = gu; }),
        _sectionHeader('HIGHLIGHTS'),
        _buildField('H1 Title', k.highlight1Title, (v) => k.highlight1Title = v, translateKey: '${p}_h1t', onTranslated: (hi, gu) { k.highlight1TitleHi = hi; k.highlight1TitleGu = gu; }),
        _buildField('H1 Desc', k.highlight1Desc, (v) => k.highlight1Desc = v, translateKey: '${p}_h1d', onTranslated: (hi, gu) { k.highlight1DescHi = hi; k.highlight1DescGu = gu; }),
        _buildField('H2 Title', k.highlight2Title, (v) => k.highlight2Title = v, translateKey: '${p}_h2t', onTranslated: (hi, gu) { k.highlight2TitleHi = hi; k.highlight2TitleGu = gu; }),
        _buildField('H2 Desc', k.highlight2Desc, (v) => k.highlight2Desc = v, translateKey: '${p}_h2d', onTranslated: (hi, gu) { k.highlight2DescHi = hi; k.highlight2DescGu = gu; }),
        _buildField('H3 Title', k.highlight3Title, (v) => k.highlight3Title = v, translateKey: '${p}_h3t', onTranslated: (hi, gu) { k.highlight3TitleHi = hi; k.highlight3TitleGu = gu; }),
        _buildField('H3 Desc', k.highlight3Desc, (v) => k.highlight3Desc = v, translateKey: '${p}_h3d', onTranslated: (hi, gu) { k.highlight3DescHi = hi; k.highlight3DescGu = gu; }),
      ],
    );
  }

  Widget _upcomingKathasView(HomePageController controller) {
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
                  _buildField('Katha Number', k.kathaNumber, (v) => k.kathaNumber = v),
                  _buildField('Name', k.name, (v) => k.name = v, translateKey: 'uk_name_$i', onTranslated: (hi, gu) { k.nameHi = hi; k.nameGu = gu; }),
                  _buildField('Date (String)', k.dateString, (v) => k.dateString = v, translateKey: 'uk_date_$i', onTranslated: (hi, gu) { k.dateStringHi = hi; k.dateStringGu = gu; }),
                  _buildField('Timing', k.timing, (v) => k.timing = v, translateKey: 'uk_time_$i', onTranslated: (hi, gu) { k.timingHi = hi; k.timingGu = gu; }),
                  _buildField('Location', k.location, (v) => k.location = v, translateKey: 'uk_loc_$i', onTranslated: (hi, gu) { k.locationHi = hi; k.locationGu = gu; }),
                  _buildField('Hosting', k.hosting, (v) => k.hosting = v, translateKey: 'uk_host_$i', onTranslated: (hi, gu) { k.hostingHi = hi; k.hostingGu = gu; }),
                  _buildField('Description', k.description, (v) => k.description = v, maxLines: 5, translateKey: 'uk_desc_$i', onTranslated: (hi, gu) { k.descriptionHi = hi; k.descriptionGu = gu; }),
                ],
              ),
            ),
          );
        }),
        ElevatedButton(onPressed: controller.addKatha, child: const Text('ADD UPCOMING KATHA')),
      ],
    );
  }

  Widget _homepageDataView(HomePageController controller) {
    final q = controller.homepageData.featuredQuote;
    final a = controller.aboutSection;
    final r = controller.ramKatha;
    final d = controller.dailySuvichar;
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        // SECTION 1: SUVICHAR (THOUGHT OF THE DAY)
        _sectionHeader('1. SUVICHAR (THOUGHT OF THE DAY)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildField('Thought of the Day', q.quote, (v) => q.quote = v, maxLines: 3, translateKey: 'q_txt', onTranslated: (hi, gu) { q.quoteHi = hi; q.quoteGu = gu; }),
                _buildField('Author / Credit', q.author, (v) => q.author = v, translateKey: 'q_auth', onTranslated: (hi, gu) { q.authorHi = hi; q.authorGu = gu; }),
                _buildImageField('Small Icon/Portrait', q.portrait, (v) => setState(() => q.portrait = v)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),
        // SECTION 2: SMALL BIOGRAPHY PREVIEW
        _sectionHeader('2. PUJYA DADA\'S SMALL BIOGRAPHY'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildField('Display Title', a.title, (v) => a.title = v, translateKey: 'ap_title', onTranslated: (hi, gu) { a.titleHi = hi; a.titleGu = gu; }),
                _buildField('Tagline', a.tagline, (v) => a.tagline = v, translateKey: 'ap_tag', onTranslated: (hi, gu) { a.taglineHi = hi; a.taglineGu = gu; }),
                _buildField('Short Biography (Intro)', a.description, (v) => a.description = v, maxLines: 5, translateKey: 'ap_desc', onTranslated: (hi, gu) { a.descriptionHi = hi; a.descriptionGu = gu; }),
                _buildImageField('Biography Photo', a.photoUrl, (v) => setState(() => a.photoUrl = v)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),
        // SECTION 3: UPCOMING KATHAS PREVIEW
        _sectionHeader('3. UPCOMING KATHAS (DISPLAY ONLY)'),
        _buildInfoBox('The first 3 kathas from the "Upcoming Kathas" page are displayed here. Use the sidebar menu to edit them.', Icons.info_outline),
        ...controller.upcomingKathas.take(3).map((k) => ListTile(
          dense: true,
          leading: const Icon(Icons.check_circle, color: Colors.green, size: 16),
          title: Text(k.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(k.location, style: const TextStyle(fontSize: 11)),
        )),

        const SizedBox(height: 32),
        // SECTION 4: LATEST VIDEOS PREVIEW
        _sectionHeader('4. LATEST VIDEOS (DISPLAY ONLY)'),
        _buildInfoBox('The first 3 videos from the "Video Gallery" page are displayed here. Use the sidebar menu to edit them.', Icons.video_library_outlined),
        ...controller.videos.take(3).map((v) => ListTile(
          dense: true,
          leading: const Icon(Icons.play_circle_fill, color: Colors.amber, size: 16),
          title: Text(v.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        )),

        const SizedBox(height: 32),
        // SECTION 5: DAILY SUVICHAR IMAGE
        _sectionHeader('5. DADA\'S DAILY SUVICHAR IMAGE'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildField('Image Date Label', d.date, (v) => d.date = v),
                _buildImageField('Daily Suvichar Image', d.imageUrl, (v) => setState(() => d.imageUrl = v)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),
        // SECTION 6: KATHA SHORT INTRODUCTION
        _sectionHeader('6. SHRIMAD BHAGWAT KATHA INTRODUCTION'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildField('Section Title', r.title, (v) => r.title = v),
                _buildField('Intro Paragraph 1', r.description1, (v) => r.description1 = v, maxLines: 4, translateKey: 'rk_d1', onTranslated: (hi, gu) { r.description1Hi = hi; r.description1Gu = gu; }),
                _buildField('Intro Paragraph 2', r.description2, (v) => r.description2 = v, maxLines: 4, translateKey: 'rk_d2', onTranslated: (hi, gu) { r.description2Hi = hi; r.description2Gu = gu; }),
                _buildImageField('Katha Section Image', r.photoUrl, (v) => setState(() => r.photoUrl = v)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),
        // SECTION 7: NEWS & EVENTS PREVIEW
        _sectionHeader('7. NEWS & EVENTS (DISPLAY ONLY)'),
        _buildInfoBox('The first 4 news blocks from the "News & Updates" page are displayed here. Use the sidebar menu to edit them.', Icons.newspaper_outlined),
        ...controller.homepageData.news.take(4).map((n) => ListTile(
          dense: true,
          leading: const Icon(Icons.article_outlined, color: Colors.blue, size: 16),
          title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        )),

        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () async {
            await controller.publish();
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Homepage Saved Successfully!')));
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white, padding: const EdgeInsets.all(20)),
          child: const Text('SAVE ALL HOMEPAGE DATA'),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade100)),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: Colors.blue.shade900, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _newsView(HomePageController controller) {
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('NEWS & UPDATES'),
        ...controller.homepageData.news.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _buildField('Title', e.value.title, (v) => e.value.title = v, translateKey: 'news_t_${e.key}', onTranslated: (hi, gu) { e.value.titleHi = hi; e.value.titleGu = gu; }),
              _buildField('Date', e.value.date, (v) => e.value.date = v),
              _buildImageField('News Image', e.value.image, (v) => setState(() => e.value.image = v)),
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

  Widget _kathaListView(HomePageController controller) {
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('FULL KATHA ARCHIVE'),
        ...controller.allKathas.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _buildField('Topic', e.value.topic, (v) => e.value.topic = v, translateKey: 'ka_t_${e.key}', onTranslated: (hi, gu) { e.value.topicHi = hi; e.value.topicGu = gu; }),
              _buildField('Location', e.value.location, (v) => e.value.location = v, translateKey: 'ka_l_${e.key}', onTranslated: (hi, gu) { e.value.locationHi = hi; e.value.locationGu = gu; }),
              _buildImageField('Archive Image', e.value.imageUrl, (v) => setState(() => e.value.imageUrl = v)),
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

  Widget _photoGalleryView(HomePageController controller) {
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('PHOTO GALLERY'),
        ...controller.photoGalleryData.sections.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _buildField('Heading', e.value.heading, (v) => e.value.heading = v, translateKey: 'pg_h_${e.key}', onTranslated: (hi, gu) { e.value.headingHi = hi; e.value.headingGu = gu; }),
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

  Widget _videoGalleryView(HomePageController controller) {
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('VIDEO GALLERY'),
        _buildImageField('Gallery Header Background', controller.videoGalleryData.headerImageUrl, (v) => setState(() => controller.videoGalleryData.headerImageUrl = v)),
        ...controller.videoGalleryData.categories.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _buildField('Category Title', e.value.categoryTitle, (v) => e.value.categoryTitle = v, translateKey: 'vg_t_${e.key}', onTranslated: (hi, gu) { e.value.categoryTitleHi = hi; e.value.categoryTitleGu = gu; }),
              const Divider(),
              ...e.value.videos.asMap().entries.map((vEntry) => Row(children: [
                Expanded(child: _buildField('Video Title', vEntry.value.title, (v) => vEntry.value.title = v, translateKey: 'v_t_${e.key}_${vEntry.key}', onTranslated: (hi, gu) { vEntry.value.titleHi = hi; vEntry.value.titleGu = gu; })),
                const SizedBox(width: 12),
                Expanded(child: _buildField('YouTube URL', vEntry.value.youtubeUrl, (v) => vEntry.value.youtubeUrl = v)),
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

  Widget _stotraView(HomePageController controller) {
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('STOTRA / BHAJAN'),
        _buildImageField('Page Top Header Image', controller.stotraSection.topHeaderImage, (v) => setState(() => controller.stotraSection.topHeaderImage = v)),
        _buildField('Page Title', controller.stotraSection.pageTitle, (v) => controller.stotraSection.pageTitle = v, translateKey: 'st_p_title', onTranslated: (hi, gu) { controller.stotraSection.pageTitleHi = hi; controller.stotraSection.pageTitleGu = gu; }),
        ...controller.stotraSection.items.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _buildField('Item Title', e.value.title, (v) => e.value.title = v, translateKey: 'st_t_${e.key}', onTranslated: (hi, gu) { e.value.titleHi = hi; e.value.titleGu = gu; }),
              _buildField('English PDF URL', e.value.englishPdfUrl, (v) => e.value.englishPdfUrl = v),
              _buildField('Hindi PDF URL', e.value.hindiPdfUrl, (v) => e.value.hindiPdfUrl = v),
              _buildField('Gujarati PDF URL', e.value.gujaratiPdfUrl, (v) => e.value.gujaratiPdfUrl = v),
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

  Widget _contactPageView(HomePageController controller) {
    final c = controller.contactPageData;
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('CONTACT SETTINGS'),
        _buildImageField('Header Banner Image', c.bannerImageUrl, (v) => setState(() => c.bannerImageUrl = v)),
        _buildField('Email Address', c.email, (v) => c.email = v),
        _buildField('Phone Number', c.phone, (v) => c.phone = v),
        _buildField('Address', c.address, (v) => c.address = v, translateKey: 'c_addr', onTranslated: (hi, gu) { c.addressHi = hi; c.addressGu = gu; }),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH CONTACT')),
        const SizedBox(height: 50),
        _sectionHeader('INQUIRIES'),
        ...controller.inquiries.map((i) => Card(child: ListTile(title: Text(i.name), subtitle: Text('${i.type}: ${i.message}')))),
      ],
    );
  }

  Widget _footerSettingsView(HomePageController controller) {
    final f = controller.footer;
    return ListView(
      padding: _responsivePadding(context).add(const EdgeInsets.only(bottom: 100)),
      children: [
        _sectionHeader('FOOTER SETTINGS'),
        _buildField('About Description', f.description, (v) => f.description = v, maxLines: 4, translateKey: 'f_desc', onTranslated: (hi, gu) { f.descriptionHi = hi; f.descriptionGu = gu; }),
        _buildField('Copyright Text', f.copyright, (v) => f.copyright = v),
        const SizedBox(height: 24),
        _sectionHeader('SOCIAL LINKS'),
        _buildField('YouTube', f.youtubeUrl, (v) => f.youtubeUrl = v),
        _buildField('Instagram', f.instagramUrl, (v) => f.instagramUrl = v),
        _buildField('Facebook', f.facebookUrl, (v) => f.facebookUrl = v),
        _buildField('WhatsApp', f.whatsappUrl, (v) => f.whatsappUrl = v),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: controller.publish, child: const Text('PUBLISH FOOTER')),
      ],
    );
  }
}
