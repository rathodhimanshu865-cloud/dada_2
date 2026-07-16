import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';
import 'package:easy_localization/easy_localization.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.locale.languageCode;
    if (locale == 'hi') {
      selectedLanguage = 'Hindi';
    } else if (locale == 'gu') {
      selectedLanguage = 'Gujarati';
    } else {
      selectedLanguage = 'English';
    }
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
    final double marginHorizontal = isSticky ? 40 : 0; // Edge-to-edge when transparent
    final double marginTop = isSticky ? 15 : 0;
    final double borderRadius = isSticky ? 24.0 : 0.0;
    final double logoSize = isSticky ? 75 : 100; // Increased logo size
    
    // Transparency Logic
    final double glassOpacity = isSticky ? 0.92 : 0.0; // Transparent at top
    final double blurAmount = isSticky ? 20.0 : 0.0; // No blur at top
    
    final Color bgColor = _parseColor(settings.headerBackgroundColor);
    
    // Text Color: Dynamic theme colors based on scroll position
    final bool isHomePage = currentRoute == '/';
    final Color navTextColor = (isSticky || !isHomePage) ? const Color(0xFF07404C) : const Color(0xFFFFF8F0);
    final Color activeNavColor = isSticky ? primaryTeal : const Color(0xFFC89A5B); // Temple Gold for active top

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutExpo,
      top: marginTop,
      left: marginHorizontal,
      right: marginHorizontal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Announcement Bar - Hidden when sticky
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
                boxShadow: isSticky ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ] : [],
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
                    ),
                    child: Row(
                      children: [
                        // LEFT SECTION: Logo
                        _buildLogo(logoSize, isSticky),
                        
                        const Spacer(),
                        
                        // CENTER SECTION: Navigation
                        _buildNavigation(currentRoute, isSticky, navTextColor, activeNavColor),
                        
                        const Spacer(),
                        
                        // RIGHT SECTION: Actions
                        _buildActionControls(isSticky, settings, navTextColor),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [templeGold, Color(0xFFD9A66B)],
        ),
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

  Widget _buildLogo(double size, bool isSticky) {
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
            boxShadow: isSticky ? [
              BoxShadow(
                color: templeGold.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ] : [],
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

  Widget _buildNavigation(String currentRoute, bool isSticky, Color textColor, Color activeColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _navItem('Home'.tr(), '/', currentRoute == '/', isSticky, textColor, activeColor),
        _navItem('About Dada'.tr(), '/about_dada', currentRoute == '/about_dada', isSticky, textColor, activeColor),
        _buildDropdownNavItem('Katha'.tr(), [
          _dropdownItem('Shrimad Bhagvat Katha'.tr(), '/about_katha'),
          _dropdownItem('Devi Bhagvat Katha'.tr(), '/about_devi_katha'),
          _dropdownItem('Shivmahapuran Katha'.tr(), '/about_shiv_katha'),
          const PopupMenuDivider(),
          _dropdownItem('Full Katha List'.tr(), '/katha_list'),
          _dropdownItem('Upcoming Kathas'.tr(), '/upcoming_ram_kathas'),
        ], currentRoute.contains('katha'), isSticky, textColor, activeColor),
        _navItem('Stotra / Bhajan'.tr(), '/stotra', currentRoute == '/stotra', isSticky, textColor, activeColor),
        _buildDropdownNavItem('Gallery'.tr(), [
          _dropdownItem('Photo Gallery'.tr(), '/photo_gallery'),
          _dropdownItem('Video Gallery'.tr(), '/video_gallery'),
          _dropdownItem('News Gallery'.tr(), '/news'),
        ], currentRoute.contains('gallery') || currentRoute == '/news', isSticky, textColor, activeColor),
        _navItem('Contact'.tr(), '/contact_us', currentRoute == '/contact_us', isSticky, textColor, activeColor),
      ],
    );
  }

  Widget _navItem(String title, String route, bool isActive, bool isSticky, Color textColor, Color activeColor) {
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
                fontFamily: 'serif',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isActive ? activeColor : textColor.withOpacity(0.8),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2.5,
              width: isActive ? 20 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownNavItem(String title, List<Widget> items, bool isActive, bool isSticky, Color textColor, Color activeColor) {
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
                    fontFamily: 'serif',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isActive ? activeColor : textColor.withOpacity(0.8),
                    letterSpacing: 1.5,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: 16, color: isActive ? activeColor : textColor.withOpacity(0.6)),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2.5,
              width: isActive ? 20 : 0,
              decoration: BoxDecoration(
                color: activeColor,
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
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B2B2B),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildActionControls(bool isSticky, HeaderSettings settings, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Language Button (exactly next to search)
        _buildLanguageSwitcher(settings, textColor, isSticky),
        
        if (settings.searchVisibility) ...[
          const SizedBox(width: 15),
          _buildSearchButton(isSticky, textColor),
        ],
        
        if (settings.donateButtonEnabled) ...[
          const SizedBox(width: 15),
          _buildDonateButton(settings),
        ],
      ],
    );
  }

  Widget _buildLanguageSwitcher(HeaderSettings settings, Color textColor, bool isSticky) {
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: warmWhite,
        onSelected: (v) {
          setState(() => selectedLanguage = v);
          if (v == 'Hindi') {
            context.setLocale(const Locale('hi'));
          } else if (v == 'Gujarati') {
            context.setLocale(const Locale('gu'));
          } else {
            context.setLocale(const Locale('en'));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSticky ? primaryTeal.withOpacity(0.05) : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSticky ? templeGold.withOpacity(0.3) : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: 16, color: isSticky ? templeGold : textColor),
              const SizedBox(width: 10),
              Text(
                selectedLanguage.tr(),
                style: TextStyle(
                  fontSize: 13, 
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: isSticky ? templeGold : textColor.withOpacity(0.6)),
            ],
          ),
        ),
        itemBuilder: (context) => [
          _buildLangOption('English', 'en'),
          _buildLangOption('Gujarati', 'gu'),
          _buildLangOption('Hindi', 'hi'),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildLangOption(String label, String code) {
    return PopupMenuItem<String>(
      value: label,
      child: Row(
        children: [
          Icon(
            Icons.check_circle, 
            size: 16, 
            color: context.locale.languageCode == code ? templeGold : Colors.transparent
          ),
          const SizedBox(width: 12),
          Text(
            label.tr(),
            style: TextStyle(
              fontWeight: context.locale.languageCode == code ? FontWeight.bold : FontWeight.normal,
              color: darkCharcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(bool isSticky, Color textColor) {
    bool isDarkText = textColor == const Color(0xFF07404C);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSticky ? primaryTeal : (isDarkText ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.2)),
        shape: BoxShape.circle,
        border: isSticky ? null : Border.all(color: isDarkText ? textColor.withOpacity(0.3) : Colors.white.withOpacity(0.3)),
      ),
      child: Icon(Icons.search, size: 18, color: isSticky ? Colors.white : (isDarkText ? textColor : Colors.white)),
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
