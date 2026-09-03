import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../controllers/language_controller.dart';
import '../../../controllers/homepage_controller.dart';
import 'package:dada_2/controllers/product_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/notification_controller.dart';
import 'notification_drawer.dart';
import '../../../models/homepage_model.dart';
import '../../../utils/app_typography.dart';
import '../../../utils/responsive_utils.dart';
import 'product_search_delegate.dart';

class UserHeader extends StatefulWidget {
  final HomePageController controller;
  final ScrollController? scrollController;
  final bool productPage;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const UserHeader({
    super.key,
    required this.controller,
    this.scrollController,
    this.productPage = false,
    this.scaffoldKey,
  });

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader>
    with TickerProviderStateMixin {
  String selectedLanguage = 'English';
  
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0.0);

  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color templeGold = const Color(0xFFC89A5B);
  final Color warmWhite = const Color(0xFFFAF8F4);
  final Color darkCharcoal = const Color(0xFF2B2B2B);

  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _logoAnimation;
  late Animation<double> _ctaPulseAnimation;

  int _logoTapCount = 0;
  Timer? _logoTapResetTimer;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_scrollListener);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _ctaPulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
  }

  @override
  void didUpdateWidget(UserHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      oldWidget.scrollController?.removeListener(_scrollListener);
      widget.scrollController?.addListener(_scrollListener);
    }
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
    _entranceController.dispose();
    _pulseController.dispose();
    _logoTapResetTimer?.cancel();
    _scrollOffset.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final double currentScroll = widget.scrollController?.offset ?? 0;
    _scrollOffset.value = currentScroll;
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
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    final l10n = AppLocalizations.of(context)!;
    final double screenWidth = context.screenWidth;
    final bool isMobile = !Responsive.isDesktop(context);
    final Color bgColor = _parseColor(settings.headerBackgroundColor);
    final bool isHomePage = currentRoute == '/';

    return ValueListenableBuilder<double>(
      valueListenable: _scrollOffset,
      builder: (context, offset, child) {
        final bool isSticky = !widget.productPage && offset > 80 && settings.stickyHeaderEnabled;
        final double headerHeight = isSticky ? 70 : (isMobile ? 70 : 95);
            final double marginHorizontal = isSticky ? (screenWidth > 1400 ? (screenWidth - 1300) / 2 : (isMobile ? 15 : 40)) : 0;
            final double marginTop = isSticky ? (isMobile ? 10 : 15) : 0;
            final double borderRadius = isSticky ? (isMobile ? 16.0 : 24.0) : 0.0;
            final double logoSize = isSticky ? (isMobile ? 40 : 50) : (isMobile ? 60 : 75);
            final double glassOpacity = (isSticky || !isHomePage) ? 0.96 : 0.0;
            final double blurAmount = (isSticky || !isHomePage) ? 12.0 : 0.0;

            final Color navTextColor = (isSticky || !isHomePage)
                ? const Color(0xFF07404C)
                : const Color(0xFFFFF8F0);
            final Color activeNavColor = isSticky ? primaryTeal : templeGold;

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: marginTop,
              left: marginHorizontal,
              right: marginHorizontal,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (settings.announcementBarText.isNotEmpty && !isSticky && !widget.productPage)
                    _buildAnnouncementBar(settings.localizedAnnouncementBarText(lang)),

                  Material(
                    color: Colors.transparent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: headerHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        boxShadow: isSticky
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ]
                            : [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: blurAmount,
                            sigmaY: blurAmount,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            decoration: BoxDecoration(
                              color: bgColor.withOpacity(glassOpacity),
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                            child: Row(
                              children: [
                                _buildBranding(logoSize, isSticky, navTextColor, lang),
                                if (!isMobile) ...[
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        child: _buildNavigation(
                                          l10n,
                                          currentRoute,
                                          isSticky,
                                          navTextColor,
                                          activeNavColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  _buildActionControls(
                                    l10n,
                                    isSticky,
                                    settings,
                                    navTextColor,
                                    lang,
                                  ),
                                ] else ...[
                                  const Spacer(),
                                  _buildSearchButton(isSticky, navTextColor),
                                  const SizedBox(width: 8),
                                  _buildMobileHamburger(true, navTextColor, () => _showMobileMenu(context, l10n, currentRoute, activeNavColor, lang)),
                                ],
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
    );
  }

  void _showMobileMenu(
    BuildContext context,
    AppLocalizations l10n,
    String currentRoute,
    Color activeColor,
    String lang,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'MobileMenu',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: _MobileMenuPanel(
            l10n: l10n,
            currentRoute: currentRoute,
            activeColor: activeColor,
            lang: lang,
            prodController: Provider.of<ProductController>(context, listen: false),
            authController: Provider.of<AuthController>(context, listen: false),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  Widget _buildBranding(double logoSize, bool isSticky, Color textColor, String lang) {
    return FadeTransition(
      opacity: _logoAnimation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(_logoAnimation),
        child: _buildLogo(logoSize, isSticky, lang),
      ),
    );
  }

  Widget _buildLogo(double size, bool isSticky, String lang) {
    return GestureDetector(
      onTap: _handleLogoTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: isSticky
              ? [
                  BoxShadow(
                    color: templeGold.withOpacity(0.3),
                    blurRadius: 15,
                  ),
                ]
              : [],
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: widget.controller.websiteSettings.logoUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(
                      widget.controller.websiteSettings.logoUrl,
                    ),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: widget.controller.websiteSettings.logoUrl.isEmpty
              ? Center(
                  child: Text(
                    widget.controller.websiteSettings.localizedName(lang).isNotEmpty 
                      ? widget.controller.websiteSettings.localizedName(lang)[0].toUpperCase()
                      : "D",
                    style: TextStyle(color: templeGold, fontWeight: FontWeight.bold, fontSize: size * 0.4),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildNavigation(
    AppLocalizations l10n,
    String currentRoute,
    bool isSticky,
    Color textColor,
    Color activeColor,
  ) {
    final navItems = [
      {'title': l10n.home, 'route': '/'},
      {'title': l10n.aboutDada, 'route': '/about_dada'},
      {'title': l10n.katha, 'type': 'dropdown', 'items': [
        _dropdownItem(l10n.shrimadBhagvatKatha, '/about_katha'),
        _dropdownItem(l10n.deviBhagvatKatha, '/about_devi_katha'),
        _dropdownItem(l10n.shivmahapuranKatha, '/about_shiv_katha'),
        const PopupMenuDivider(),
        _dropdownItem(l10n.fullKathaList, '/katha_list'),
        _dropdownItem(l10n.upcomingKathas, '/upcoming_ram_kathas'),
      ]},
      {'title': l10n.products, 'type': 'dropdown', 'items': [
        _dropdownItem(l10n.storeHomePortal, '/product'),
        _dropdownItem(l10n.allSacredProducts, '/catalogue'),
        const PopupMenuDivider(),
        _dropdownItem(l10n.pujyaDadaTeachings, '/teachings'),
        _dropdownItem(l10n.trackShipment, '/track'),
      ]},
      {'title': l10n.stotraBhajan, 'route': '/stotra'},
      {'title': l10n.gallery, 'type': 'dropdown', 'items': [
        _dropdownItem(l10n.photoGallery, '/photo_gallery'),
        _dropdownItem(l10n.videoGallery, '/video_gallery'),
        _dropdownItem(l10n.newsGallery, '/news'),
      ]},
      {'title': l10n.contact, 'route': '/contact_us'},
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: navItems.asMap().entries.map((entry) {
        final int index = entry.key;
        final item = entry.value;
        final bool isDropdown = item['type'] == 'dropdown';
        
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _entranceController,
            curve: Interval(0.2 + (index * 0.05), 0.6 + (index * 0.05), curve: Curves.easeIn),
          ),
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
              CurvedAnimation(
                parent: _entranceController,
                curve: Interval(0.2 + (index * 0.05), 0.6 + (index * 0.05), curve: Curves.easeOutCubic),
              ),
            ),
            child: isDropdown 
              ? _buildDropdownNavItem(
                  item['title'] as String,
                  item['items'] as List<Widget>,
                  currentRoute.contains(item['route'] as String? ?? 'NOT_FOUND'), 
                  isSticky,
                  textColor,
                  activeColor,
                )
              : _navItem(
                  item['title'] as String,
                  item['route'] as String,
                  currentRoute == item['route'],
                  isSticky,
                  textColor,
                  activeColor,
                ),
          ),
        );
      }).toList(),
    );
  }

  Widget _navItem(
    String title,
    String route,
    bool isActive,
    bool isSticky,
    Color textColor,
    Color activeColor,
  ) {
    return _AnimatedNavLink(
      title: title,
      isActive: isActive,
      textColor: textColor,
      activeColor: activeColor,
      onTap: () => Navigator.pushNamed(context, route),
    );
  }

  Widget _buildDropdownNavItem(
    String title,
    List<Widget> items,
    bool isActive,
    bool isSticky,
    Color textColor,
    Color activeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: warmWhite,
        child: _AnimatedNavLink(
          title: title,
          isActive: isActive,
          textColor: textColor,
          activeColor: activeColor,
          isDropdown: true,
        ),
        itemBuilder: (context) =>
            items.map((item) => item as PopupMenuEntry<String>).toList(),
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

  Widget _buildActionControls(
    AppLocalizations l10n,
    bool isSticky,
    HeaderSettings settings,
    Color textColor,
    String lang,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildAuthButton(textColor),
        const SizedBox(width: 10),
        _buildLanguageSwitcher(l10n, settings, textColor, isSticky),
        if (settings.searchVisibility) ...[
          const SizedBox(width: 10),
          _buildSearchButton(isSticky, textColor),
        ],
        if (settings.donateButtonEnabled) ...[
          const SizedBox(width: 10),
          _buildDonateButton(settings, lang),
        ],
      ],
    );
  }

  void _showNotificationDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const Align(
          alignment: Alignment.centerRight,
          child: NotificationDrawer(),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(anim1),
          child: child,
        );
      },
    );
  }

  Widget _buildAuthButton(Color textColor) {
    final auth = Provider.of<AuthController>(context);
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      icon: Icon(Icons.person_outline, color: textColor),
      onSelected: (v) async {
        if (v == 'login') {
          Provider.of<AuthController>(context, listen: false).toggleLoginPortal(true);
        }
        if (v == 'orders') Navigator.pushNamed(context, '/my_orders');
        if (v == 'logout') {
          await auth.logout();
        }
      },
      itemBuilder: (context) => auth.isAuthenticated
          ? [
              PopupMenuItem(
                value: 'orders',
                child: Text(l10n.myOrders),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text(l10n.close, style: const TextStyle(color: Colors.redAccent)),
              ),
            ]
          : [
              PopupMenuItem(
                value: 'login',
                child: Text(l10n.loginSignUp),
              ),
            ],
    );
  }

  Widget _buildLanguageSwitcher(
    AppLocalizations l10n,
    HeaderSettings settings,
    Color textColor,
    bool isSticky,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(hoverColor: Colors.transparent),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: warmWhite,
          onSelected: (v) {
            setState(() => selectedLanguage = v);
            final languageController = Provider.of<LanguageController>(
              context,
              listen: false,
            );
            if (v == 'Hindi') {
              languageController.changeLanguage(const Locale('hi'));
            } else if (v == 'Gujarati') {
              languageController.changeLanguage(const Locale('gu'));
            } else {
              languageController.changeLanguage(const Locale('en'));
            }
          },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSticky
                ? primaryTeal.withOpacity(0.05)
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSticky
                  ? templeGold.withOpacity(0.3)
                  : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                size: 16,
                color: isSticky ? templeGold : textColor,
              ),
              const SizedBox(width: 10),
              Text(
                _getTranslatedLanguageName(l10n, selectedLanguage),
                style: AppTypography.bodyStyle(
                  context,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: isSticky ? templeGold : textColor.withOpacity(0.6),
              ),
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

  PopupMenuItem<String> _buildLangOption(
    AppLocalizations l10n,
    String label,
    String code,
  ) {
    final currentLangCode = Localizations.localeOf(context).languageCode;
    return PopupMenuItem<String>(
      value: label,
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: currentLangCode == code ? templeGold : Colors.transparent,
          ),
          const SizedBox(width: 12),
          Text(
            _getTranslatedLanguageName(l10n, label),
            style: AppTypography.bodyStyle(
              context,
              fontWeight: currentLangCode == code
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: darkCharcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(bool isSticky, Color textColor) {
    return InkWell(
      onTap: () {
        showSearch(
          context: context,
          delegate: ProductSearchDelegate(),
        );
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSticky
              ? primaryTeal
              : (textColor == const Color(0xFF07404C)
                    ? Colors.black.withOpacity(0.05)
                    : Colors.white.withOpacity(0.2)),
          shape: BoxShape.circle,
          border: isSticky
              ? null
              : Border.all(
                  color: textColor == const Color(0xFF07404C)
                      ? textColor.withOpacity(0.3)
                      : Colors.white.withOpacity(0.3),
                ),
        ),
        child: Icon(
          Icons.search,
          size: 16,
          color: isSticky
              ? Colors.white
              : (textColor == const Color(0xFF07404C) ? textColor : Colors.white),
        ),
      ),
    );
  }

  Widget _buildDonateButton(HeaderSettings settings, String lang) {
    return FadeTransition(
      opacity: _ctaPulseAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: templeGold.withOpacity(0.3 * (1.0 - _ctaPulseAnimation.value)),
              blurRadius: 15 * _ctaPulseAnimation.value,
              spreadRadius: 2 * _ctaPulseAnimation.value,
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            if (settings.donateButtonUrl.isNotEmpty) {
              launchUrl(Uri.parse(settings.donateButtonUrl), mode: LaunchMode.externalApplication);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: templeGold,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            minimumSize: const Size(80, 36),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(
            settings.localizedDonateButtonText(lang).toUpperCase(),
            style: AppTypography.bodyStyle(
              context,
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHamburger(bool isVisible, Color color, VoidCallback onTap) {
    return _AnimatedHamburger(color: color, onTap: onTap);
  }

  Widget _buildAnnouncementBar(String text) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 35),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [templeGold, const Color(0xFFD9A66B)]),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.bodyStyle(
            context,
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  String _getTranslatedLanguageName(AppLocalizations l10n, String lang) {
    switch (lang) {
      case 'English':
        return l10n.english;
      case 'Gujarati':
        return l10n.gujarati;
      case 'Hindi':
        return l10n.hindi;
      default:
        return lang;
    }
  }
}

class _AnimatedHamburger extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;

  const _AnimatedHamburger({required this.color, required this.onTap});

  @override
  State<_AnimatedHamburger> createState() => _AnimatedHamburgerState();
}

class _AnimatedHamburgerState extends State<_AnimatedHamburger> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (_controller.isCompleted) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
        widget.onTap();
      },
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _controller,
            color: widget.color,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavLink extends StatefulWidget {
  final String title;
  final bool isActive;
  final Color textColor;
  final Color activeColor;
  final VoidCallback? onTap;
  final bool isDropdown;

  const _AnimatedNavLink({
    required this.title,
    required this.isActive,
    required this.textColor,
    required this.activeColor,
    this.onTap,
    this.isDropdown = false,
  });

  @override
  State<_AnimatedNavLink> createState() => _AnimatedNavLinkState();
}

class _AnimatedNavLinkState extends State<_AnimatedNavLink> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _underlineAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _underlineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color currentColor = widget.isActive 
      ? widget.activeColor 
      : (_isHovered ? const Color(0xFFC89A5B) : widget.textColor.withOpacity(0.85));

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: AppTypography.bodyStyle(
                      context,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: currentColor,
                      letterSpacing: 0.1,
                    ),
                    child: Text(widget.title.toUpperCase()),
                  ),
                  if (widget.isDropdown) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: currentColor.withOpacity(0.6)),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.isActive)
                    Container(
                      height: 2.5,
                      width: 20,
                      decoration: BoxDecoration(
                        color: widget.activeColor,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: widget.activeColor.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                    ),
                  if (!widget.isActive)
                    ScaleTransition(
                      scale: _underlineAnimation,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 2.5,
                        width: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC89A5B),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileMenuPanel extends StatefulWidget {
  final AppLocalizations l10n;
  final String currentRoute;
  final Color activeColor;
  final String lang;
  final ProductController prodController;
  final AuthController authController;

  const _MobileMenuPanel({
    required this.l10n,
    required this.currentRoute,
    required this.activeColor,
    required this.lang,
    required this.prodController,
    required this.authController,
  });

  @override
  State<_MobileMenuPanel> createState() => _MobileMenuPanelState();
}

class _MobileMenuPanelState extends State<_MobileMenuPanel> with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'title': widget.l10n.home, 'route': '/'},
      {'title': widget.l10n.aboutDada, 'route': '/about_dada'},
      {'title': widget.l10n.katha, 'type': 'expansion', 'children': [
        {'title': widget.l10n.shrimadBhagvatKatha, 'route': '/about_katha'},
        {'title': widget.l10n.deviBhagvatKatha, 'route': '/about_devi_katha'},
        {'title': widget.l10n.shivmahapuranKatha, 'route': '/about_shiv_katha'},
        {'title': widget.l10n.fullKathaList, 'route': '/katha_list'},
        {'title': widget.l10n.upcomingKathas, 'route': '/upcoming_ram_kathas'},
      ]},
      {'title': widget.l10n.products, 'type': 'expansion', 'children': [
        {'title': widget.l10n.storeHomePortal, 'route': '/product'},
        {'title': widget.l10n.allSacredProducts, 'route': '/catalogue'},
        {'title': widget.l10n.pujyaDadaTeachings, 'route': '/teachings'},
        {'title': widget.l10n.trackShipment, 'route': '/track'},
        {'title': widget.authController.isAuthenticated ? widget.l10n.myOrders : widget.l10n.loginSignUp, 'route': '/my_orders'},
      ]},
      {'title': widget.l10n.stotraBhajan, 'route': '/stotra'},
      {'title': widget.l10n.gallery, 'type': 'expansion', 'children': [
        {'title': widget.l10n.photoGallery, 'route': '/photo_gallery'},
        {'title': widget.l10n.videoGallery, 'route': '/video_gallery'},
        {'title': widget.l10n.newsGallery, 'route': '/news'},
      ]},
      {'title': widget.l10n.contact, 'route': '/contact_us'},
    ];

    return Material(
      color: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length + 2, // +2 for Divider and Language Buttons
                itemBuilder: (context, index) {
                  if (index < menuItems.length) {
                    final item = menuItems[index];
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _entranceController,
                        curve: Interval(index * 0.05, 0.6 + (index * 0.05), curve: Curves.easeIn),
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(
                          CurvedAnimation(
                            parent: _entranceController,
                            curve: Interval(index * 0.05, 0.6 + (index * 0.05), curve: Curves.easeOutCubic),
                          ),
                        ),
                        child: _buildMenuItem(item),
                      ),
                    );
                  } else if (index == menuItems.length) {
                    return const Divider(height: 40);
                  } else {
                    return _buildLanguageSection();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    final bool isExpansion = item['type'] == 'expansion';
    final String? route = item['route'] as String?;
    final bool isActive = route != null && widget.currentRoute == route;

    if (isExpansion) {
      return ExpansionTile(
        title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F4C5C))),
        children: (item['children'] as List<Map<String, dynamic>>).map((child) => ListTile(
          title: Text(child['title']!),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, child['route']!);
          },
        )).toList(),
      );
    }

    return ListTile(
      title: Text(
        item['title'] as String,
        style: TextStyle(
          color: isActive ? widget.activeColor : const Color(0xFF2B2B2B),
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route!);
      },
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.l10n.selectedLanguage,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _langButton('EN', 'English'),
            _langButton('HI', 'Hindi'),
            _langButton('GU', 'Gujarati'),
          ],
        ),
      ],
    );
  }

  Widget _langButton(String code, String label) {
    final bool isSelected = Provider.of<LanguageController>(context, listen: false).locale.languageCode == 
        (label == 'English' ? 'en' : label == 'Hindi' ? 'hi' : 'gu');
        
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFC89A5B) : Colors.grey[100],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        final langCode = label == 'English' ? 'en' : label == 'Hindi' ? 'hi' : 'gu';
        Provider.of<LanguageController>(context, listen: false).changeLanguage(Locale(langCode));
        Navigator.pop(context);
      },
      child: Text(code),
    );
  }
}
