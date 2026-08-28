import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/profile_controller.dart';
import 'order_management_view.dart';
import 'biography_editor.dart';
import 'product_management_view.dart';
import 'admin_settings_view.dart';
import 'admin_users_view.dart';
import 'admin_notifications_view.dart';
import 'cms_views_helper.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentMenuIndex = 13; // Reverted default to Product Management
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
    // ── ORIGINAL SIDEBAR MENU RESTORED ──────────────────────────────────────
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
          // ── LOGOUT ──
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
            onTap: () async {
              if (isMobile) Navigator.pop(context);
              final auth = Provider.of<AuthController>(context, listen: false);
              await auth.adminLogout();
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
    // Reverted to individual view routing
    switch (currentMenuIndex) {
      case 13: return const ProductManagementView();
      // Delegate CMS indices (0-12) to the helper
      default:
        if (currentMenuIndex >= 0 && currentMenuIndex <= 12) {
          return CMSViewsHelper.buildCMSView(currentMenuIndex, controller, context, _fieldLoading, setState);
        }
        return const Center(child: Text('Select a menu'));
    }
  }
}
