import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../controllers/language_controller.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';
import '../../../utils/app_typography.dart';

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
  
  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color templeGold = const Color(0xFFC89A5B);
  final Color warmWhite = const Color(0xFFFAF8F4);
  final Color darkCharcoal = const Color(0xFF2B2B2B);

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
    final locale = Localizations.localeOf(context).languageCode;
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
      if (hexColor.length == 6) hexColor = "FF$hexColor";
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
    final l10n = AppLocalizations.of(context)!;
    
    final double headerHeight = isSticky ? 75 : 95;
    final double marginHorizontal = isSticky ? 40 : 0;
    final double marginTop = isSticky ? 15 : 0;
    final double borderRadius = isSticky ? 24.0 : 0.0;
    final double logoSize = isSticky ? 55 : 75;
    
    final double glassOpacity = isSticky ? 0.92 : 0.0;
    final double blurAmount = isSticky ? 20.0 : 0.0;
    
    final Color bgColor = _parseColor(settings.headerBackgroundColor);
    final bool isHomePage = currentRoute == '/';
    final Color navTextColor = (isSticky || !isHomePage) ? const Color(0xFF07404C) : const Color(0xFFFFF8F0);
    final Color activeNavColor = isSticky ? primaryTeal : templeGold;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutExpo,
      top: marginTop,
      left: marginHorizontal,
      right: marginHorizontal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 10)),
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
                        _buildBranding(logoSize, isSticky, navTextColor),
                        const Spacer(),
                        _buildNavigation(l10n, currentRoute, isSticky, navTextColor, activeNavColor),
                        const Spacer(),
                        _buildActionControls(l10n, isSticky, settings, navTextColor),
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

  Widget _buildBranding(double logoSize, bool isSticky, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogo(logoSize, isSticky),
        const SizedBox(width: 15),
        Text(
          widget.controller.websiteSettings.name,
          style: AppTypography.headingStyle(
            context,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.5,
            fontSize: AppTypography.getResponsiveSize(context, desktop: 32, tablet: 28, mobile: 24),
          ),
        ),
      ],
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
              BoxShadow(color: templeGold.withOpacity(0.4), blurRadius: 20, spreadRadius: 1),
            ] : [],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: widget.controller.websiteSettings.logoUrl.isNotEmpty
                  ? DecorationImage(image: NetworkImage(widget.controller.websiteSettings.logoUrl), fit: BoxFit.cover)
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

  Widget _buildNavigation(AppLocalizations l10n, String currentRoute, bool isSticky, Color textColor, Color activeColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _navItem(l10n.home, '/', currentRoute == '/', isSticky, textColor, activeColor),
        _navItem(l10n.aboutDada, '/about_dada', currentRoute == '/about_dada', isSticky, textColor, activeColor),
        _buildDropdownNavItem(l10n.katha, [
          _dropdownItem(l10n.shrimadBhagvatKatha, '/about_katha'),
          _dropdownItem(l10n.deviBhagvatKatha, '/about_devi_katha'),
          _dropdownItem(l10n.shivmahapuranKatha, '/about_shiv_katha'),
          const PopupMenuDivider(),
          _dropdownItem(l10n.fullKathaList, '/katha_list'),
          _dropdownItem(l10n.upcomingKathas, '/upcoming_ram_kathas'),
        ], currentRoute.contains('katha'), isSticky, textColor, activeColor),
        _navItem(l10n.stotraBhajan, '/stotra', currentRoute == '/stotra', isSticky, textColor, activeColor),
        _buildDropdownNavItem(l10n.gallery, [
          _dropdownItem(l10n.photoGallery, '/photo_gallery'),
          _dropdownItem(l10n.videoGallery, '/video_gallery'),
          _dropdownItem(l10n.newsGallery, '/news'),
        ], currentRoute.contains('gallery') || currentRoute == '/news', isSticky, textColor, activeColor),
        _navItem(l10n.contact, '/contact_us', currentRoute == '/contact_us', isSticky, textColor, activeColor),
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
              style: AppTypography.bodyStyle(
                context,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isActive ? activeColor : textColor.withOpacity(0.8),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2.5,
              width: isActive ? 20 : 0,
              decoration: BoxDecoration(color: activeColor, borderRadius: BorderRadius.circular(2)),
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
                  style: AppTypography.bodyStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isActive ? activeColor : textColor.withOpacity(0.8),
                    letterSpacing: 0.2,
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
              decoration: BoxDecoration(color: activeColor, borderRadius: BorderRadius.circular(2)),
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
          style: AppTypography.bodyStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkCharcoal,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildActionControls(AppLocalizations l10n, bool isSticky, HeaderSettings settings, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLanguageSwitcher(l10n, settings, textColor, isSticky),
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

  String _getTranslatedLanguageName(AppLocalizations l10n, String lang) {
    switch (lang) {
      case 'English': return l10n.english;
      case 'Gujarati': return l10n.gujarati;
      case 'Hindi': return l10n.hindi;
      default: return lang;
    }
  }

  Widget _buildLanguageSwitcher(AppLocalizations l10n, HeaderSettings settings, Color textColor, bool isSticky) {
    return Theme(
      data: Theme.of(context).copyWith(hoverColor: Colors.transparent),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: warmWhite,
        onSelected: (v) {
          setState(() => selectedLanguage = v);
          final languageController = Provider.of<LanguageController>(context, listen: false);
          if (v == 'Hindi') languageController.changeLanguage(const Locale('hi'));
          else if (v == 'Gujarati') languageController.changeLanguage(const Locale('gu'));
          else languageController.changeLanguage(const Locale('en'));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSticky ? primaryTeal.withOpacity(0.05) : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isSticky ? templeGold.withOpacity(0.3) : Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: 16, color: isSticky ? templeGold : textColor),
              const SizedBox(width: 10),
              Text(
                _getTranslatedLanguageName(l10n, selectedLanguage),
                style: AppTypography.bodyStyle(context, fontSize: 13, fontWeight: FontWeight.w800, color: textColor, letterSpacing: 0.5),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: isSticky ? templeGold : textColor.withOpacity(0.6)),
            ],
          ),
        ),
        itemBuilder: (context) => [
          _buildLangOption(l10n, 'English', 'en'),
          _buildLangOption(l10n, 'Gujarati', 'gu'),
          _buildLangOption(l10n, 'Hindi', 'hi'),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildLangOption(AppLocalizations l10n, String label, String code) {
    final currentLangCode = Localizations.localeOf(context).languageCode;
    return PopupMenuItem<String>(
      value: label,
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: currentLangCode == code ? templeGold : Colors.transparent),
          const SizedBox(width: 12),
          Text(_getTranslatedLanguageName(l10n, label), style: AppTypography.bodyStyle(context, fontWeight: currentLangCode == code ? FontWeight.bold : FontWeight.normal, color: darkCharcoal)),
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
      child: Text(settings.donateButtonText.toUpperCase(), style: AppTypography.bodyStyle(context, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: Colors.white)),
    );
  }

  Widget _buildAnnouncementBar(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [templeGold, const Color(0xFFD9A66B)])),
      child: Center(child: Text(text, style: AppTypography.bodyStyle(context, color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5))),
    );
  }
}
