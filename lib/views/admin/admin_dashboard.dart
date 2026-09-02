import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/product_controller.dart';
import '../../services/translation_service.dart';
import 'product_management_view.dart';
import 'devotee_management_view.dart';
import 'cms_views_helper.dart';
import 'translation_audit_view.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentMenuIndex = 0; // Default to General Settings
  bool _isSidebarVisible = true;
  final Map<String, bool> _fieldLoading = {};

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    
    if (!auth.isAdminAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final controller = Provider.of<HomePageController>(context);
    final prof = Provider.of<ProfileController>(context);
    final bool globalLoading = controller.isLoading || prof.isLoading;

    bool isMobile = MediaQuery.of(context).size.width <= 1100;

    return Scaffold(
      appBar: AppBar(
        bottom: globalLoading ? const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: LinearProgressIndicator(backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation<Color>(Colors.amber)),
        ) : null,
        title: Text(AppLocalizations.of(context)!.adminPortal, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
          TextButton.icon(
            onPressed: () async {
              _showKathaTranslationDialog(context);
            },
            icon: const Icon(Icons.translate, size: 16, color: Colors.orangeAccent),
            label: const Text('TRANSLATE KATHAS', style: TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () async {
              _showPublishProgressDialog(context);
            },
            icon: const Icon(Icons.publish, size: 16, color: Colors.blueAccent),
            label: Text(AppLocalizations.of(context)!.publish, style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          IconButton(
            tooltip: AppLocalizations.of(context)!.refreshData,
            onPressed: () {
              controller.loadData();
              Provider.of<ProductController>(context, listen: false).fetchBrowsingProducts(refresh: true);
            }, 
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
    final contentMenus = [
      {'title': AppLocalizations.of(context)!.headerFooterSettings, 'icon': Icons.settings},
      {'title': AppLocalizations.of(context)!.homePage, 'icon': Icons.home},
      {'title': AppLocalizations.of(context)!.aboutDadaPage, 'icon': Icons.person},
      {'title': AppLocalizations.of(context)!.kathaPages, 'icon': Icons.menu_book},
      {'title': AppLocalizations.of(context)!.fullKathaList, 'icon': Icons.list_alt},
      {'title': AppLocalizations.of(context)!.upcomingKathas, 'icon': Icons.event},
      {'title': AppLocalizations.of(context)!.stotraBhajan, 'icon': Icons.music_note},
      {'title': AppLocalizations.of(context)!.photoGallery, 'icon': Icons.photo_library},
      {'title': AppLocalizations.of(context)!.videoGallery, 'icon': Icons.video_library},
      {'title': AppLocalizations.of(context)!.newsGallery, 'icon': Icons.newspaper},
      {'title': AppLocalizations.of(context)!.contactEnquiries, 'icon': Icons.contact_mail},
      {'title': AppLocalizations.of(context)!.productManagement, 'icon': Icons.shopping_bag},
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
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(AppLocalizations.of(context)!.logout, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
            onTap: () async {
              if (isMobile) Navigator.pop(context);
              final auth = Provider.of<AuthController>(context, listen: false);
              await auth.adminLogout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.public, color: Colors.blueAccent),
            title: Text(AppLocalizations.of(context)!.backToWebsite,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMainContent(HomePageController controller) {
    switch (currentMenuIndex) {
      case 0: return CMSViewsHelper.buildCMSView('settings', controller, context, _fieldLoading, setState);
      case 1: return CMSViewsHelper.buildCMSView('home', controller, context, _fieldLoading, setState);
      case 2: return CMSViewsHelper.buildCMSView('about_page', controller, context, _fieldLoading, setState);
      case 3: return CMSViewsHelper.buildCMSView('katha_pages', controller, context, _fieldLoading, setState);
      case 4: return CMSViewsHelper.buildCMSView('katha_list', controller, context, _fieldLoading, setState);
      case 5: return CMSViewsHelper.buildCMSView('upcoming', controller, context, _fieldLoading, setState);
      case 6: return CMSViewsHelper.buildCMSView('stotra', controller, context, _fieldLoading, setState);
      case 7: return CMSViewsHelper.buildCMSView('photo', controller, context, _fieldLoading, setState);
      case 8: return CMSViewsHelper.buildCMSView('video', controller, context, _fieldLoading, setState);
      case 9: return CMSViewsHelper.buildCMSView('news', controller, context, _fieldLoading, setState);
      case 10: return CMSViewsHelper.buildCMSView('contact', controller, context, _fieldLoading, setState);
      case 11: return const ProductManagementView(initialSubMenu: 0);
      default: return Center(child: Text(AppLocalizations.of(context)!.selectMenu));
    }
  }

  void _showPublishProgressDialog(BuildContext context) {
    final home = Provider.of<HomePageController>(context, listen: false);
    final prof = Provider.of<ProfileController>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.publish, color: Colors.blueAccent),
            const SizedBox(width: 12),
            const Text('Publishing Content'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Updating live website data...'),
          ],
        ),
      ),
    );

    Future.wait([
      home.publish(),
      if (prof.profileData != null) prof.saveProfileData(prof.profileData!),
    ]).then((_) {
      if (mounted) {
        Navigator.pop(context); // Close progress
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All content published successfully!'), backgroundColor: Colors.green));
      }
    }).catchError((e) {
      if (mounted) {
        Navigator.pop(context); // Close progress
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error publishing: $e'), backgroundColor: Colors.red));
      }
    });
  }

  void _showKathaTranslationDialog(BuildContext context) {
    final home = Provider.of<HomePageController>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Row(
          children: [
            Icon(Icons.translate, color: Colors.orangeAccent),
            const SizedBox(width: 12),
            const Text('Translating Kathas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.orangeAccent),
            SizedBox(height: 20),
            Text('Using Google Translation for all lists...'),
            Text('Updating Firebase & sync in progress...', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );

    home.translateKathas().then((_) {
      if (mounted) {
        Navigator.pop(context); // Close progress
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All Katha lists translated and published!'), backgroundColor: Colors.green));
      }
    }).catchError((e) {
      if (mounted) {
        Navigator.pop(context); // Close progress
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error during translation: $e'), backgroundColor: Colors.red));
      }
    });
  }
}
