import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import '../../utils/app_typography.dart';
import '../../utils/animation_utils.dart';
import 'package:flutter/services.dart';

class PuDadaTeachingsPage extends StatefulWidget {
  const PuDadaTeachingsPage({super.key});

  @override
  State<PuDadaTeachingsPage> createState() => _PuDadaTeachingsPageState();
}

class _PuDadaTeachingsPageState extends State<PuDadaTeachingsPage> with TickerProviderStateMixin {
  late final AnimationController _zoomController;
  late final Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
    
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF0F4C5C))));
    }

    final t = controller.homepageData.teachingsPage;
    final primaryTeal = const Color(0xFF0F4C5C);
    final goldAccent = const Color(0xFFC89A5B);
    final softBeige = const Color(0xFFFBF9F6);

    final bool isMobile = MediaQuery.of(context).size.width < 1100;
    final bool isReducedMotion = !AnimationUtils.shouldAnimate(context);

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          _buildKenBurnsBanner(context, t, primaryTeal, goldAccent, softBeige, lang, isMobile, isReducedMotion),
          
          const SizedBox(height: 80),
          _TeachingsGridSection(isMobile: isMobile, goldAccent: goldAccent, primaryTeal: primaryTeal),
          
          const SizedBox(height: 100),
          _ThoughtOfTheDaySection(isMobile: isMobile, isReducedMotion: isReducedMotion),
          
          const SizedBox(height: 100),
          _VideoTeachingsSection(isMobile: isMobile, primaryTeal: primaryTeal, goldAccent: goldAccent),

          const SizedBox(height: 120),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _buildKenBurnsBanner(BuildContext context, TeachingsPageData t, Color primaryColor, Color goldColor, Color softBeige, String lang, bool isMobile, bool isReducedMotion) {
    return Container(
      width: double.infinity,
      color: softBeige,
      child: Stack(
        children: [
          if (t.heroImage.isNotEmpty)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _zoomAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isReducedMotion ? 1.0 : _zoomAnimation.value,
                    child: Opacity(
                      opacity: 0.15,
                      child: Image.network(t.heroImage, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100, vertical: isMobile ? 80 : 120),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.spa, color: goldColor, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context)!.divineDiscourses.toUpperCase(),
                            style: TextStyle(color: goldColor, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 3),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.spa, color: goldColor, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        t.localizedHeroTitle(lang).isNotEmpty ? t.localizedHeroTitle(lang) : 'Divine Teachings of Pu. Dada',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingStyle(
                          context, 
                          fontSize: isMobile ? 36 : 64, 
                          fontWeight: FontWeight.w900, 
                          color: primaryColor,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        t.localizedHeroSubtitle(lang).isNotEmpty ? t.localizedHeroSubtitle(lang) : 'Illuminating the path of devotion, humanity, and inner peace.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: isMobile ? 16 : 22, color: Colors.black87, height: 1.6, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// TEACHINGS GRID WITH FILTER TABS
// ---------------------------------------------------------

class _TeachingsGridSection extends StatefulWidget {
  final bool isMobile;
  final Color goldAccent;
  final Color primaryTeal;

  const _TeachingsGridSection({required this.isMobile, required this.goldAccent, required this.primaryTeal});

  @override
  State<_TeachingsGridSection> createState() => _TeachingsGridSectionState();
}

class _TeachingsGridSectionState extends State<_TeachingsGridSection> {
  final List<String> _categories = ["All", "Life Lessons", "Devotion", "Karma", "Humanity"];
  int _selectedCategoryIndex = 0;
  bool _isVisible = false;
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    final teachingsData = controller.homepageData.teachingsPage.pillars.map((e) => {
      "category": e.subtitle,
      "title": e.title,
      "quote": e.icon,
      "detail": e.description,
    }).toList();

    List<Map<String, String>> filtered = _selectedCategoryIndex == 0 
      ? teachingsData 
      : teachingsData.where((e) => e["category"] == _categories[_selectedCategoryIndex]).toList();

    return VisibilityDetector(
      key: const Key('teachings-grid'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          if (mounted) setState(() => _isVisible = true);
        }
      },
      child: Column(
        children: [
          // Filter Tabs — Canonical SiteFilterTabBar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SiteFilterTabBar(
              tabs: _categories,
              activeIndex: _selectedCategoryIndex,
              onTabSelected: (index) => setState(() => _selectedCategoryIndex = index),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 20 : 100),
            child: Wrap(
              spacing: 30,
              runSpacing: 40,
              alignment: WrapAlignment.center,
              children: List.generate(filtered.length, (index) {
                final item = filtered[index];
                return SiteCardEntrance(
                  animate: _isVisible,
                  index: index,
                  child: SizedBox(
                    width: widget.isMobile ? double.infinity : 350,
                    child: _FlipTeachingCard(
                      title: item["title"]!,
                      quote: item["quote"]!,
                      detail: item["detail"]!,
                      goldAccent: widget.goldAccent,
                      primaryTeal: widget.primaryTeal,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlipTeachingCard extends StatefulWidget {
  final String title;
  final String quote;
  final String detail;
  final Color goldAccent;
  final Color primaryTeal;

  const _FlipTeachingCard({
    required this.title,
    required this.quote,
    required this.detail,
    required this.goldAccent,
    required this.primaryTeal,
  });

  @override
  State<_FlipTeachingCard> createState() => _FlipTeachingCardState();
}

class _FlipTeachingCardState extends State<_FlipTeachingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnim;
  bool _isFront = true;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _flipAnim = Tween<double>(begin: 0, end: pi).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: _toggleFlip,
            child: AnimatedBuilder(
              animation: _flipAnim,
              builder: (context, child) {
                final isUnder = _flipAnim.value > pi / 2;
                final angle = isUnder ? _flipAnim.value - pi : _flipAnim.value;
                
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.05),
                          blurRadius: _isHovered ? 30 : 15,
                          offset: Offset(0, _isHovered ? 15 : 5),
                        )
                      ],
                    ),
                    child: isUnder ? _buildBack() : _buildFront(),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Fallback for accessibility
        TextButton(
          onPressed: _toggleFlip,
          style: TextButton.styleFrom(
            foregroundColor: widget.primaryTeal,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_isFront ? "Read Explanation" : "Back to Quote", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 5),
              Icon(_isFront ? Icons.rotate_right : Icons.rotate_left, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFront() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.format_quote_rounded, color: widget.goldAccent.withOpacity(0.5), size: 40),
        const SizedBox(height: 15),
        Text(
          widget.quote,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey.shade800, fontStyle: FontStyle.italic),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 20),
        Container(width: 30, height: 2, color: widget.goldAccent),
      ],
    );
  }

  Widget _buildBack() {
    return Transform(
      transform: Matrix4.identity()..rotateY(pi),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: widget.primaryTeal)),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                widget.detail,
                style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey.shade700),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _ShareButtons(textToShare: "${widget.quote} - ${widget.title}", goldAccent: widget.goldAccent),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// SHARE BUTTONS & TOAST NOTIFICATION
// ---------------------------------------------------------

class _ShareButtons extends StatelessWidget {
  final String textToShare;
  final Color goldAccent;

  const _ShareButtons({required this.textToShare, required this.goldAccent});

  void _showShareToast(BuildContext context) {
    Clipboard.setData(ClipboardData(text: textToShare));
    
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: FadeInUp(
          duration: const Duration(milliseconds: 300),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: goldAccent, size: 20),
                    const SizedBox(width: 10),
                    const Text('Copied to clipboard!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _AnimatedShareIcon(
          icon: Icons.copy_rounded, 
          onTap: () => _showShareToast(context),
          goldAccent: goldAccent,
        ),
      ],
    );
  }
}

class _AnimatedShareIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color goldAccent;

  const _AnimatedShareIcon({required this.icon, required this.onTap, required this.goldAccent});

  @override
  State<_AnimatedShareIcon> createState() => _AnimatedShareIconState();
}

class _AnimatedShareIconState extends State<_AnimatedShareIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.15 : 1.0)
            ..rotateZ(_isHovered ? 0.05 : 0.0),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered ? widget.goldAccent.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, size: 20, color: _isHovered ? widget.goldAccent : Colors.grey.shade400),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// THOUGHT OF THE DAY
// ---------------------------------------------------------

class _ThoughtOfTheDaySection extends StatefulWidget {
  final bool isMobile;
  final bool isReducedMotion;

  const _ThoughtOfTheDaySection({required this.isMobile, required this.isReducedMotion});

  @override
  State<_ThoughtOfTheDaySection> createState() => _ThoughtOfTheDaySectionState();
}

class _ThoughtOfTheDaySectionState extends State<_ThoughtOfTheDaySection> with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late final AnimationController _driftController;
  final String _quote = "True spiritual awakening is realizing that you are not a drop in the ocean, but the entire ocean in a drop.";

  @override
  void initState() {
    super.initState();
    _driftController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _driftController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    List<String> words = _quote.split(' ');

    return VisibilityDetector(
      key: const Key('thought-of-the-day'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3 && !_isVisible) {
          if (mounted) setState(() => _isVisible = true);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 20 : 100, vertical: 80),
        decoration: const BoxDecoration(
          color: Color(0xFF0F4C5C),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  AnimatedScale(
                    scale: _isVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    child: const Icon(Icons.format_quote_rounded, color: Color(0xFFC89A5B), size: 80),
                  ),
                  const SizedBox(height: 30),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 10,
                    children: List.generate(words.length, (index) {
                      return FadeInUp(
                        animate: _isVisible,
                        delay: Duration(milliseconds: 300 + (index * 100)),
                        from: 15, // Custom upward drift amount
                        child: Text(
                          words[index],
                          style: AppTypography.headingStyle(
                            context,
                            fontSize: widget.isMobile ? 24 : 36,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  FadeIn(
                    animate: _isVisible,
                    delay: Duration(milliseconds: 500 + (words.length * 100)),
                    child: Column(
                      children: [
                        Container(width: 50, height: 2, color: const Color(0xFFC89A5B)),
                        const SizedBox(height: 15),
                        const Text(
                          "- PUJYA DADA", 
                          style: TextStyle(color: Color(0xFFC89A5B), fontWeight: FontWeight.bold, letterSpacing: 3)
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// VIDEO TEACHINGS
// ---------------------------------------------------------

class _VideoTeachingsSection extends StatelessWidget {
  final bool isMobile;
  final Color primaryTeal;
  final Color goldAccent;

  const _VideoTeachingsSection({required this.isMobile, required this.primaryTeal, required this.goldAccent});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    final List videos = controller.videos.take(3).toList();

    return Column(
      children: [
        Text(
          "VIDEO TEACHINGS",
          style: TextStyle(color: primaryTeal, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        Container(margin: const EdgeInsets.only(top: 15, bottom: 40), width: 60, height: 3, color: goldAccent),
        
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100),
          child: Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: videos.map((v) => SizedBox(
              width: isMobile ? double.infinity : 350,
              child: _VideoThumbnail(thumb: v.thumbnail, title: v.title, primaryTeal: primaryTeal, goldAccent: goldAccent),
            )).toList(),
          ),
        ),
        
        const SizedBox(height: 50),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/video_gallery'),
          style: TextButton.styleFrom(foregroundColor: primaryTeal, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("View All Videos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _VideoThumbnail extends StatefulWidget {
  final String thumb;
  final String title;
  final Color primaryTeal;
  final Color goldAccent;

  const _VideoThumbnail({required this.thumb, required this.title, required this.primaryTeal, required this.goldAccent});

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // Typically route to a video player page or open modal
          Navigator.pushNamed(context, '/video_gallery');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    AnimatedScale(
                      scale: _isHovered ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: Image.network(widget.thumb, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    ),
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.5),
                        child: Center(
                          child: AnimatedScale(
                            scale: _isHovered ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: widget.goldAccent.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              widget.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: widget.primaryTeal),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
