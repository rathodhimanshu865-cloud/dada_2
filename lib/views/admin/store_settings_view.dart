import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import 'cms_views_helper.dart';

class StoreSettingsView extends StatefulWidget {
  const StoreSettingsView({super.key});

  @override
  State<StoreSettingsView> createState() => _StoreSettingsViewState();
}

class _StoreSettingsViewState extends State<StoreSettingsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _fieldLoading = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);

    return Column(
      children: [
        Container(
          color: Colors.white,
          width: double.infinity,
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: const Color(0xFF8B4513),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF8B4513),
            tabs: const [
              Tab(text: 'Home Portal'),
              Tab(text: 'Product Catalogue'),
              Tab(text: 'Pujya Dada Teachings'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildScrollableCMS(100, controller), // Home Portal
              _buildScrollableCMS(101, controller), // Product Catalogue
              _buildScrollableCMS(102, controller), // Pujya Dada Teachings
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableCMS(int index, HomePageController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: CMSViewsHelper.buildCMSView(index, controller, context, _fieldLoading, setState),
    );
  }
}
