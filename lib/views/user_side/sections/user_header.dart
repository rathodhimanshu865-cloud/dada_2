import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';

class UserHeader extends StatefulWidget {
  final HomePageController controller;
  final ScrollController? scrollController;
  
  const UserHeader({
    super.key, 
    required this.controller,
    this.scrollController,
  });

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> with SingleTickerProviderStateMixin {
  String selectedLanguage = 'English';
  double _scrollOffset = 0;
  
  // Luxury Color Palette
  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color templeGold = const Color(0xFFC89A5B);
  final Color warmWhite = const Color(0xFFFAF8F4);
  final Color darkCharcoal = const Color(0xFF2B2B2B);

  // Logo tap for admin access
  int _logoTapCount = 0;
  Timer? _logoTapResetTimer;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_scrollListener);
    _logoTapResetTimer?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (mounted) {
      setState(() {
        _scrollOffset = widget.scrollController?.offset ?? 0;
      });
    }
  }

  void _handleLogoTap() {
    _logoTapResetTimer?.cancel();
    _logoTapResetTimer = Timer(const Duration(seconds: 2), () {
      setState(() => _logoTapCount = 0);
    });

    setState(() => _logoTapCount++);

    if (_logoTapCount >= 5) {
      _logoTapResetTimer?.cancel();
      setState(() => _logoTapCount = 0);
      Navigator.pushNamed(context, '/admin_login');
    }
  }

  Color _parseColor(String hexColor) {
    try {
      if (hexColor.isEmpty) return warmWhite;
      hexColor = hexColor.replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor";
      }
      return Color(int.parse("0x$hexColor"));
    } catch (e) {
      return warmWhite;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.controller.websiteSettings.headerSettings;
    final bool isSticky = _scrollOffset > 50 && settings.stickyHeaderEnabled;
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    
    // Dynamic dimensions
    final double headerHeight = isSticky ? 75 : 95;
    final double marginHorizontal = isSticky ? 40 : 20;
    final double marginTop = isSticky ? 15 : 20;
    final double borderRadius = 24.0;
    final double logoSize = isSticky ? 55 : 70;
    final double glassOpacity = isSticky ? 0.92 : 0.75;
    final double blurAmount = isSticky ? 20.0 : 12.0;

    final Color bgColor = _parseColor(settings.headerBackgroundColor);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutExpo,
      top: marginTop,
      left: marginHorizontal,
      right: marginHorizontal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Announcement Bar
          if (settings.announcementBarText.isNotEmpty && !isSticky)
            _buildAnnouncementBar(settings.announcementBarText),
          
          Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutExpo,
              height: headerHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isSticky ? 0.15 : 0.08),
                    blurRadius: isSticky ? 40 : 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      color: bgColor.withOpacity(glassOpacity),
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // LEFT SECTION: Logo
                        _buildLogo(logoSize),
                        
                        const Spacer(),
                        
                        // CENTER SECTION: Navigation
                        _buildNavigation(currentRoute, isSticky),
                        
                        const Spacer(),
                        
                        // RIGHT SECTION: Actions
                        _buildActionControls(isSticky, settings),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementBar(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.only(bottom: 12, left: 40, right: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [templeGold, Color(0xFFD9A66B)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(double size) {
    return GestureDetector(
      onTap: _handleLogoTap,
      child: Hero(
        tag: 'website_logo',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: templeGold.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: widget.controller.websiteSettings.logoUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(widget.controller.websiteSettings.logoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.controller.websiteSettings.logoUrl.isEmpty
                ? Icon(Icons.person, color: templeGold, size: size * 0.6)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigation(String currentRoute, bool isSticky) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _navItem('Home', '/', currentRoute == '/', isSticky),
        _navItem('About Dada', '/about_dada', currentRoute == '/about_dada', isSticky),
        _buildDropdownNavItem('Katha', [
          _dropdownItem('Shrimad Bhagvat Katha', '/about_katha'),
          _dropdownItem('Devi Bhagvat Katha', '/about_devi_katha'),
          _dropdownItem('Shivmahapuran Katha', '/about_shiv_katha'),
          const PopupMenuDivider(),
          _dropdownItem('Full Katha List', '/katha_list'),
          _dropdownItem('Upcoming Kathas', '/upcoming_ram_kathas'),
        ], currentRoute.contains('katha'), isSticky),
        _navItem('Stotra / Bhajan', '/stotra', currentRoute == '/stotra', isSticky),
        _buildDropdownNavItem('Gallery', [
          _dropdownItem('Photo Gallery', '/photo_gallery'),
          _dropdownItem('Video Gallery', '/video_gallery'),
        ], currentRoute.contains('gallery'), isSticky),
        _navItem('Contact', '/contact_us', currentRoute == '/contact_us', isSticky),
      ],
    );
  }

  Widget _navItem(String title, String route, bool isActive, bool isSticky) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        hoverColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isActive ? primaryTeal : darkCharcoal.withOpacity(0.7),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2.5,
              width: isActive ? 20 : 0,
              decoration: BoxDecoration(
                color: templeGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownNavItem(String title, List<Widget> items, bool isActive, bool isSticky) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: warmWhite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isActive ? primaryTeal : darkCharcoal.withOpacity(0.7),
                    letterSpacing: 1.5,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: 16, color: templeGold),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2.5,
              width: isActive ? 20 : 0,
              decoration: BoxDecoration(
                color: templeGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        itemBuilder: (context) => items.map((item) => item as PopupMenuEntry<String>).toList(),
      ),
    );
  }

  PopupMenuItem<String> _dropdownItem(String title, String route) {
    return PopupMenuItem<String>(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: darkCharcoal,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildActionControls(bool isSticky, HeaderSettings settings) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Language Pill
        _buildLanguageSwitcher(settings),
        
        if (settings.searchVisibility) ...[
          const SizedBox(width: 15),
          _buildSearchButton(),
        ],
        
        if (settings.donateButtonEnabled) ...[
          const SizedBox(width: 15),
          _buildDonateButton(settings),
        ],
      ],
    );
  }

  Widget _buildLanguageSwitcher(HeaderSettings settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: templeGold.withOpacity(0.3)),
      ),
      child: PopupMenuButton<String>(
        onSelected: (v) => setState(() => selectedLanguage = v),
        child: Row(
          children: [
            Icon(Icons.language, size: 16, color: templeGold),
            const SizedBox(width: 8),
            Text(
              selectedLanguage,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            Icon(Icons.keyboard_arrow_down, size: 14, color: darkCharcoal.withOpacity(0.5)),
          ],
        ),
        itemBuilder: (context) => settings.languageOptions.map((lang) => PopupMenuItem(
          value: lang,
          child: Text(lang, style: const TextStyle(fontWeight: FontWeight.bold)),
        )).toList(),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: primaryTeal,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(Icons.search, size: 18, color: Colors.white),
    );
  }

  Widget _buildDonateButton(HeaderSettings settings) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: templeGold,
        foregroundColor: Colors.white,
        elevation: 5,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        settings.donateButtonText.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
