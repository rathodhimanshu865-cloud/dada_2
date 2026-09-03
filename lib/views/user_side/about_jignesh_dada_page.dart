import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/homepage_model.dart';
import '../../models/profile_model.dart';
import '../../utils/app_typography.dart';
import '../../utils/responsive_utils.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TOKENS
// ─────────────────────────────────────────────────────────────────────────────
const _teal    = Color(0xFF0F4C5C);
const _deep    = Color(0xFF07303D);
const _darker  = Color(0xFF051E27);
const _gold    = Color(0xFFC19A6B);
const _goldL   = Color(0xFFE3C18A);
const _beige   = Color(0xFFF9F3EA);
const _cream   = Color(0xFFFCF8F3);
const _ink     = Color(0xFF1C1C1C);
const _slate   = Color(0xFF4A5568);

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────
class AboutJigneshDadaPage extends StatefulWidget {
  const AboutJigneshDadaPage({super.key});

  @override
  State<AboutJigneshDadaPage> createState() => _AboutJigneshDadaPageState();
}

class _AboutJigneshDadaPageState extends State<AboutJigneshDadaPage> {
  // keepScrollOffset: false ensures Flutter never restores the previous scroll
  // position, so the Hero is always visible at the top on every navigation.
  final ScrollController _scrollController = ScrollController(keepScrollOffset: false);
  bool _hasForceScrolled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Aggressive scroll reset: Ensures that even on a hot-reload, 
    // the page jumps to the very top to reveal the Hero section.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients && !_hasForceScrolled) {
        _scrollController.jumpTo(0);
        _hasForceScrolled = true;
      }
    });

    final home    = Provider.of<HomePageController>(context);
    final prof    = Provider.of<ProfileController>(context);
    final lang    = Provider.of<LanguageController>(context).locale.languageCode;
    final bool isMob = Responsive.isMobile(context);
    final bool isDsk = Responsive.isDesktop(context);
    final p       = prof.profileData;

    return UserPageLayout(
      controller: home,
      scrollController: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. HERO ──────────────────────────────────────────────────────
          _Hero(data: home.aboutDadaPage, lang: lang, isMob: isMob, isDsk: isDsk, l10n: l10n),

          if (prof.isLoading)
            const Padding(padding: EdgeInsets.all(100), child: Center(child: CircularProgressIndicator(color: _teal)))
          else if (p != null) ...[

            // ── 2. INTRODUCTION ──────────────────────────────────────────
            if (p.localizedContentHTML(lang).isNotEmpty)
              _IntroBlock(html: p.localizedContentHTML(lang), portrait: home.aboutDadaPage.heroImage, isMob: isMob, isDsk: isDsk, lang: lang, l10n: l10n),

            // ── 3. CORE COMPETENCIES ─────────────────────────────────────
            if (p.localizedCoreCompetencies(lang).isNotEmpty)
              _CompetenciesBlock(items: p.localizedCoreCompetencies(lang), isMob: isMob, isDsk: isDsk, lang: lang, l10n: l10n),

            // ── 4. PROFESSIONAL HIGHLIGHTS ───────────────────────────────
            if (p.localizedProfessionalHighlights(lang).isNotEmpty)
              _HighlightsBlock(items: p.localizedProfessionalHighlights(lang), isMob: isMob, isDsk: isDsk, lang: lang, l10n: l10n),

            // ── 5. SOCIAL INITIATIVE ─────────────────────────────────────
            if (p.localizedSocialTitle(lang).isNotEmpty || p.localizedSocialVision(lang).isNotEmpty)
              _SocialBlock(p: p, isMob: isMob, isDsk: isDsk, lang: lang, l10n: l10n),

            // ── 6. PHILOSOPHY OF LIFE ────────────────────────────────────
            if (p.localizedPhilosophy(lang).isNotEmpty)
              _PhilosophyBlock(quote: p.localizedPhilosophy(lang), isMob: isMob, lang: lang, l10n: l10n),

            // ── 7. PERSONAL ATTRIBUTES ───────────────────────────────────
            if (p.localizedPersonalAttributes(lang).isNotEmpty)
              _AttributesBlock(items: p.localizedPersonalAttributes(lang), isMob: isMob, isDsk: isDsk, lang: lang, l10n: l10n),

            // ── 8. SIGNATURE IDENTITY ────────────────────────────────────
            if (p.localizedSignatureTitle(lang).isNotEmpty || p.localizedSignatureSubtitle(lang).isNotEmpty)
              _SignatureBlock(title: p.localizedSignatureTitle(lang), subtitle: p.localizedSignatureSubtitle(lang), isMob: isMob, isDsk: isDsk, lang: lang, l10n: l10n),
          ],

          // ── 9. FOOTER ────────────────────────────────────────────────────
          UserFooter(controller: home),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. HERO — cinematic full-bleed banner
// ─────────────────────────────────────────────────────────────────────────────
class _Hero extends StatefulWidget {
  final AboutDadaPageData data;
  final String lang;
  final bool isMob, isDsk;
  final AppLocalizations l10n;
  const _Hero({required this.data, required this.lang, required this.isMob, required this.isDsk, required this.l10n});

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> with TickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideText;
  late final Animation<Offset> _slideImg;

  late final AnimationController _zoomController;
  late final Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fade = CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _slideText = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic)));
    _slideImg = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)));

    _zoomController = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat(reverse: true);
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(CurvedAnimation(parent: _zoomController, curve: Curves.linear));

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _c.forward();
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String defaultTitle = widget.lang == 'hi' ? 'पूज्य श्री जिग्नेशदादा' : widget.lang == 'gu' ? 'પૂજ્ય શ્રી જીગ્નેશદાદા' : 'Pujya Shri Jigneshdada';
    String defaultSubtitle = widget.lang == 'hi' ? 'प्रसिद्ध भागवताचार्य • आध्यात्मिक मार्गदर्शक • समाज सेवक' : widget.lang == 'gu' ? 'પ્રસિદ્ધ ભાગવતાચાર્ય • આધ્યાત્મિક માર્ગદર્શક • સમાજ સેવક' : 'Renowned Bhagavatacharya • Spiritual Guide • Social Philanthropist';

    final title = widget.data.localizedHeroTitle(widget.lang).isEmpty ? defaultTitle : widget.data.localizedHeroTitle(widget.lang);
    final subtitle = widget.data.localizedHeroSubtitle(widget.lang).isEmpty ? defaultSubtitle : widget.data.localizedHeroSubtitle(widget.lang);
    final hasImg = widget.data.heroImage.isNotEmpty;

    return Container(
      width: double.infinity,
      color: const Color(0xFFFAF8F4), // Ultra clean warm white
      child: Stack(
        children: [
          // Background Ken Burns Zoom
          if (hasImg) Positioned.fill(
            child: AnimatedBuilder(
              animation: _zoomAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _zoomAnimation.value,
                  child: Opacity(
                    opacity: 0.04,
                    child: Image.network(widget.data.heroImage, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          
          Positioned(
            top: -100, right: -50,
            child: Icon(Icons.wb_sunny_rounded, size: 400, color: _gold.withOpacity(0.02)),
          ),
          
          Padding(
            padding: EdgeInsets.fromLTRB(
              widget.isMob ? 24 : (widget.isDsk ? 100 : 60), 
              widget.isMob ? 140 : 180, // Extra space for header
              widget.isMob ? 24 : (widget.isDsk ? 100 : 60), 
              widget.isMob ? 60 : 100
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: widget.isMob
                    ? _mobileLayout(title, subtitle, hasImg)
                    : _desktopLayout(title, subtitle, hasImg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktopLayout(String title, String subtitle, bool hasImg) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Text column
        Expanded(
          flex: 55,
          child: FadeTransition(opacity: _fade, child: SlideTransition(position: _slideText, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _teal.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _teal.withOpacity(0.1)),
                  ),
                  child: Text(widget.l10n.aboutUs, style: const TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
                ),
                const SizedBox(width: 16),
                Container(width: 40, height: 1, color: _gold),
              ]),
              const SizedBox(height: 32),
              
              // Name
              Text(title,
                style: AppTypography.headingStyle(context, fontSize: 56, fontWeight: FontWeight.w800, color: _teal, height: 1.1, letterSpacing: -1)),
              const SizedBox(height: 24),
              
              // Subtitle
              Container(
                padding: const EdgeInsets.only(left: 20),
                decoration: const BoxDecoration(border: Border(left: BorderSide(color: _gold, width: 3))),
                child: Text(subtitle, style: AppTypography.bodyStyle(context, fontSize: 17, color: _slate, height: 1.6, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 48),
              
              // Signature / Mantra
              Row(children: [
                Icon(Icons.spa_rounded, color: _gold.withOpacity(0.8), size: 24),
                const SizedBox(width: 12),
                Text(widget.lang == 'hi' ? '"राधे राधे"' : widget.lang == 'gu' ? '"રાધે રાધે"' : '"Radhe Radhe"',
                  style: const TextStyle(color: _gold, fontSize: 22, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, fontFamily: 'Georgia')),
              ]),
            ],
          ))),
        ),
        
        // Portrait column
        if (hasImg) ...[
          const SizedBox(width: 60),
          Expanded(
            flex: 45,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slideImg,
                child: _PortraitFrame(url: widget.data.heroImage, height: 550),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _mobileLayout(String title, String subtitle, bool hasImg) {
    return FadeTransition(
      opacity: _fade,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        if (hasImg) ...[_PortraitFrame(url: widget.data.heroImage, height: 380), const SizedBox(height: 40)],
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: _teal.withOpacity(0.06), borderRadius: BorderRadius.circular(4)),
          child: Text(widget.l10n.aboutUs, style: const TextStyle(color: _teal, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
        ),
        const SizedBox(height: 20),
        
        Text(title, textAlign: TextAlign.center,
          style: AppTypography.headingStyle(context, fontSize: 40, fontWeight: FontWeight.w800, color: _teal, height: 1.15)),
        const SizedBox(height: 20),
        
        Text(subtitle, textAlign: TextAlign.center, style: AppTypography.bodyStyle(context, fontSize: 15, color: _slate, height: 1.6)),
        const SizedBox(height: 32),
        
        Text(widget.lang == 'hi' ? '"राधे राधे"' : widget.lang == 'gu' ? '"રાધે રાધે"' : '"Radhe Radhe"', 
          style: const TextStyle(color: _gold, fontSize: 20, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, fontFamily: 'Georgia')),
      ]),
    );
  }
}

class _PortraitFrame extends StatelessWidget {
  final String url;
  final double height;
  const _PortraitFrame({required this.url, required this.height});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Premium backdrop shadow/offset
        Positioned(
          top: 20, bottom: -20, left: 20, right: -20,
          child: Container(
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Gold outline
        Positioned(
          top: -10, bottom: 10, left: -10, right: 10,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: _gold.withOpacity(0.5), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Main Image
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: _teal.withOpacity(0.12), blurRadius: 40, offset: const Offset(0, 20)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url, 
              fit: BoxFit.cover, 
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: _beige,
                child: const Icon(Icons.person_outline_rounded, color: _teal, size: 80),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. INTRODUCTION — editorial two-column with drop cap
// ─────────────────────────────────────────────────────────────────────────────
class _IntroBlock extends StatefulWidget {
  final String html, portrait, lang;
  final bool isMob, isDsk;
  final AppLocalizations l10n;
  const _IntroBlock({required this.html, required this.portrait, required this.isMob, required this.isDsk, required this.lang, required this.l10n});

  @override
  State<_IntroBlock> createState() => _IntroBlockState();
}

class _IntroBlockState extends State<_IntroBlock> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final hPad = widget.isMob ? 24.0 : (widget.isDsk ? 120.0 : 60.0);
    
    return VisibilityDetector(
      key: const Key('about-intro-block'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          setState(() => _isVisible = true);
        }
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: widget.isMob ? 60 : 100),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: widget.isMob ? _buildMobileIntro() : _buildDesktopIntro(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopIntro() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                animate: _isVisible,
                child: _Label(widget.l10n.anIntroduction, widget.isMob),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                animate: _isVisible,
                delay: const Duration(milliseconds: 200),
                child: Text(widget.lang == 'hi' ? 'प्रेरक जीवन और यात्रा' : widget.lang == 'gu' ? 'પ્રેરણાદાયક જીવન અને યાત્રા' : 'The Inspiring Life & Journey',
                  style: AppTypography.headingStyle(context, fontSize: 38, color: _teal, fontWeight: FontWeight.w700, height: 1.2)),
              ),
              const SizedBox(height: 48),

              FadeInUp(
                animate: _isVisible,
                delay: const Duration(milliseconds: 400),
                child: _HtmlContent(html: widget.html, isMob: widget.isMob),
              ),
            ],
          ),
        ),
        const SizedBox(width: 80),
        Expanded(
          flex: 4,
          child: FadeInRight(
            animate: _isVisible,
            delay: const Duration(milliseconds: 600),
            child: _PortraitFrame(url: widget.portrait, height: 500),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInDown(
          animate: _isVisible,
          child: _Label(widget.l10n.anIntroduction, widget.isMob),
        ),
        const SizedBox(height: 8),
        FadeInUp(
          animate: _isVisible,
          delay: const Duration(milliseconds: 200),
          child: Text(widget.lang == 'hi' ? 'प्रेरक जीवन और यात्रा' : widget.lang == 'gu' ? 'પ્રેરણાદાયક જીવન અને યાત્રા' : 'The Inspiring Life & Journey',
            style: AppTypography.headingStyle(context, fontSize: 26, color: _teal, fontWeight: FontWeight.w700, height: 1.2)),
        ),
        const SizedBox(height: 32),
        FadeInRight(
          animate: _isVisible,
          delay: const Duration(milliseconds: 400),
          child: _PortraitFrame(url: widget.portrait, height: 400),
        ),
        const SizedBox(height: 40),
        FadeInUp(
          animate: _isVisible,
          delay: const Duration(milliseconds: 600),
          child: _HtmlContent(html: widget.html, isMob: widget.isMob),
        ),
      ],
    );
  }
}

class _HtmlContent extends StatelessWidget {
  final String html;
  final bool isMob;
  const _HtmlContent({required this.html, required this.isMob});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      html,
      textStyle: AppTypography.bodyStyle(context, fontSize: isMob ? 15 : 17, height: 1.95, color: _slate),
      customStylesBuilder: (el) {
        if (el.localName == 'h1') {
          return {
          'color': '#0F4C5C', 'font-size': isMob ? '22px' : '30px', 'font-weight': '700',
          'margin-top': '56px', 'margin-bottom': '24px', 'padding-bottom': '14px',
          'border-bottom': '2px solid #C19A6B', 'letter-spacing': '0.5px'};
        }
        if (el.localName == 'h2') {
          return {
          'color': '#0F4C5C', 'font-size': isMob ? '19px' : '24px', 'font-weight': '700',
          'margin-top': '44px', 'margin-bottom': '18px',
          'padding-left': '18px', 'border-left': '4px solid #C19A6B'};
        }
        if (el.localName == 'p') {
          return {'margin-bottom': '24px', 'line-height': '1.95', 'text-align': 'justify'};
        }
        if (el.localName == 'li') {
          return {'margin-bottom': '10px', 'line-height': '1.75', 'color': '#4A5568'};
        }
        if (el.localName == 'strong' || el.localName == 'b') {
          return {'color': '#0F4C5C', 'font-weight': '700'};
        }
        if (el.localName == 'em' || el.localName == 'i') {
          return {'color': '#C19A6B', 'font-style': 'italic'};
        }
        if (el.localName == 'blockquote') {
          return {
          'background': '#F9F3EA', 'border-left': '5px solid #C19A6B',
          'padding': '20px 24px', 'margin': '32px 0', 'font-style': 'italic', 'color': '#374151'};
        }
        return null;
      },
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// 3. CORE COMPETENCIES — icon-card grid on rich dark background
// ─────────────────────────────────────────────────────────────────────────────
class _CompetenciesBlock extends StatelessWidget {
  final List<String> items;
  final bool isMob, isDsk;
  final String lang;
  final AppLocalizations l10n;
  const _CompetenciesBlock({required this.items, required this.isMob, required this.isDsk, required this.lang, required this.l10n});

  static const _icons = [
    Icons.menu_book_rounded, Icons.self_improvement_rounded, Icons.star_half_rounded,
    Icons.volunteer_activism_rounded, Icons.record_voice_over_rounded, Icons.music_note_rounded,
    Icons.library_music_rounded, Icons.school_rounded, Icons.flag_rounded,
    Icons.people_rounded, Icons.public_rounded, Icons.favorite_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final cols = isMob ? 1 : (isDsk ? 3 : 2);
    String titleText = lang == 'hi' ? 'आध्यात्मिक विशेषज्ञता और सेवा' : lang == 'gu' ? 'આધ્યાત્મિક કુશળતા અને સેવા' : 'Spiritual Expertise & Service';
    
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_darker, _deep, Color(0xFF0F4C5C)]),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMob ? 24 : (isDsk ? 120 : 60), vertical: isMob ? 60 : 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label(l10n.coreCompetencies, isMob, onDark: true),
              const SizedBox(height: 8),
              Text(titleText,
                style: AppTypography.headingStyle(context, fontSize: isMob ? 26 : 38, color: Colors.white, fontWeight: FontWeight.w700, height: 1.2)),
              const SizedBox(height: 52),

              // Grid
              LayoutBuilder(builder: (ctx, box) {
                final itemW = (box.maxWidth - (cols - 1) * 20) / cols;
                return Wrap(spacing: 20, runSpacing: 20,
                  children: items.asMap().entries.map((e) =>
                    SizedBox(width: itemW,
                      child: _CompCard(
                        icon: e.key < _icons.length ? _icons[e.key] : Icons.auto_awesome_rounded,
                        label: e.value,
                        index: e.key,
                        isMob: isMob,
                      ))).toList());
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isMob;
  const _CompCard({required this.icon, required this.label, required this.index, required this.isMob});

  @override
  State<_CompCard> createState() => _CompCardState();
}

class _CompCardState extends State<_CompCard> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hov ? _gold.withOpacity(0.14) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _hov ? _gold.withOpacity(0.7) : _gold.withOpacity(0.18), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _hov ? _gold : _gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(widget.icon, color: _hov ? Colors.white : _gold, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(widget.label,
                style: TextStyle(
                  color: _hov ? Colors.white : Colors.white.withOpacity(0.82),
                  fontSize: widget.isMob ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. PROFESSIONAL HIGHLIGHTS — vertical timeline
// ─────────────────────────────────────────────────────────────────────────────
class _HighlightsBlock extends StatefulWidget {
  final List<String> items;
  final bool isMob, isDsk;
  final String lang;
  final AppLocalizations l10n;
  const _HighlightsBlock({required this.items, required this.isMob, required this.isDsk, required this.lang, required this.l10n});

  @override
  State<_HighlightsBlock> createState() => _HighlightsBlockState();
}

class _HighlightsBlockState extends State<_HighlightsBlock> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final hPad = widget.isMob ? 24.0 : (widget.isDsk ? 120.0 : 60.0);
    String titleText = widget.lang == 'hi' ? 'प्रमुख उपलब्धियां और उल्लेखनीय कार्य' : widget.lang == 'gu' ? 'મુખ્ય સિદ્ધિઓ અને નોંધપાત્ર કાર્ય' : 'Key Achievements & Notable Work';

    return VisibilityDetector(
      key: const Key('about-highlights-block'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          setState(() => _isVisible = true);
        }
      },
      child: Container(
        color: _beige,
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: widget.isMob ? 80 : 140),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  animate: _isVisible,
                  child: _Label(widget.l10n.professionalHighlights, widget.isMob),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  animate: _isVisible,
                  delay: const Duration(milliseconds: 200),
                  child: Text(titleText,
                    style: AppTypography.headingStyle(context, fontSize: widget.isMob ? 26 : 42, color: _teal, fontWeight: FontWeight.w700, height: 1.2)),
                ),
                const SizedBox(height: 70),

                // Animated Timeline
                Stack(
                  children: [
                    // The Progressive Line
                    Positioned(
                      left: 20,
                      top: 40,
                      bottom: 40,
                      child: _ProgressiveLine(animate: _isVisible),
                    ),
                    
                    Column(
                      children: widget.items.asMap().entries.map((e) =>
                        _TimelineItem(
                          index: e.key, 
                          text: e.value, 
                          isMob: widget.isMob, 
                          total: widget.items.length,
                          parentVisible: _isVisible,
                        )
                      ).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressiveLine extends StatefulWidget {
  final bool animate;
  const _ProgressiveLine({required this.animate});

  @override
  State<_ProgressiveLine> createState() => _ProgressiveLineState();
}

class _ProgressiveLineState extends State<_ProgressiveLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart));
  }

  @override
  void didUpdateWidget(_ProgressiveLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 2,
          color: _gold.withOpacity(0.1),
          alignment: Alignment.topCenter,
          child: Container(
            width: 2,
            height: MediaQuery.of(context).size.height * 2, // Large enough to cover
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_gold, _gold, Colors.transparent],
                stops: [_animation.value, _animation.value, _animation.value],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimelineItem extends StatefulWidget {
  final int index, total;
  final String text;
  final bool isMob;
  final bool parentVisible;
  const _TimelineItem({required this.index, required this.text, required this.isMob, required this.total, required this.parentVisible});

  @override
  State<_TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<_TimelineItem> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hov = true),
        onExit:  (_) => setState(() => _hov = false),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Node
            ZoomIn(
              animate: widget.parentVisible,
              delay: Duration(milliseconds: 400 + (widget.index * 200)),
              duration: const Duration(milliseconds: 600),
              manualTrigger: false,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: _hov ? _gold : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _gold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withOpacity(_hov ? 0.4 : 0.1),
                      blurRadius: _hov ? 15 : 5,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: Text('${widget.index + 1}',
                  style: TextStyle(color: _hov ? Colors.white : _gold, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(width: 24),
            
            // Card
            Expanded(
              child: FadeInRight(
                animate: widget.parentVisible,
                delay: Duration(milliseconds: 500 + (widget.index * 200)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(widget.isMob ? 20 : 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _hov ? _gold.withOpacity(0.5) : Colors.transparent),
                    boxShadow: [
                      BoxShadow(
                        color: _hov ? _gold.withOpacity(0.08) : Colors.black.withOpacity(0.03),
                        blurRadius: _hov ? 30 : 10, 
                        offset: const Offset(0, 5)
                      )
                    ],
                  ),
                  child: Text(widget.text,
                    style: AppTypography.bodyStyle(context, fontSize: widget.isMob ? 14 : 16, color: _slate, height: 1.75, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// 5. SOCIAL INITIATIVE — full dark premium layout
// ─────────────────────────────────────────────────────────────────────────────
class _SocialBlock extends StatelessWidget {
  final ProfileData p;
  final bool isMob, isDsk;
  final String lang;
  final AppLocalizations l10n;
  const _SocialBlock({required this.p, required this.isMob, required this.isDsk, required this.lang, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF051E27), Color(0xFF07303D), Color(0xFF0F4C5C)]),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? 24 : (isDsk ? 120 : 60),
        vertical: isMob ? 60 : 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label(l10n.socialInitiative, isMob, onDark: true),
              const SizedBox(height: 8),
              if (p.localizedSocialTitle(lang).isNotEmpty) ...[
                Text(p.localizedSocialTitle(lang),
                  style: AppTypography.headingStyle(context, fontSize: isMob ? 22 : 34, color: Colors.white, fontWeight: FontWeight.w700, height: 1.25)),
                const SizedBox(height: 18),
                Row(children: [
                  Container(width: 50, height: 2, color: _gold),
                  const SizedBox(width: 10),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle)),
                ]),
                const SizedBox(height: 52),
              ],

              // Three pillar cards
              isMob
                  ? Column(children: _pillars(context))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _pillars(context).expand((w) sync* {
                        yield Expanded(child: w);
                        if (w != _pillars(context).last) yield const SizedBox(width: 24);
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _pillars(BuildContext ctx) {
    final data = [
      if (p.localizedSocialVision(lang).isNotEmpty)    (Icons.visibility_outlined, l10n.vision,    p.localizedSocialVision(lang)),
      if (p.localizedSocialMission(lang).isNotEmpty)   (Icons.flag_outlined,        l10n.mission,   p.localizedSocialMission(lang)),
      if (p.localizedSocialObjective(lang).isNotEmpty) (Icons.track_changes_rounded, l10n.objective, p.localizedSocialObjective(lang)),
    ];
    return data.map((d) => _PillarCard(icon: d.$1, label: d.$2, text: d.$3, isMob: isMob)).toList();
  }
}

class _PillarCard extends StatefulWidget {
  final IconData icon;
  final String label, text;
  final bool isMob;
  const _PillarCard({required this.icon, required this.label, required this.text, required this.isMob});

  @override
  State<_PillarCard> createState() => _PillarCardState();
}

class _PillarCardState extends State<_PillarCard> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: widget.isMob ? const EdgeInsets.only(bottom: 20) : EdgeInsets.zero,
        padding: EdgeInsets.all(widget.isMob ? 24 : 30),
        decoration: BoxDecoration(
          color: _hov ? _gold.withOpacity(0.1) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _hov ? _gold.withOpacity(0.6) : _gold.withOpacity(0.2), width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _gold.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Icon(widget.icon, color: _gold, size: 22),
          ),
          const SizedBox(height: 20),
          Text(widget.label,
            style: const TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2.5)),
          const SizedBox(height: 10),
          Container(width: 24, height: 1.5, color: _gold.withOpacity(0.4)),
          const SizedBox(height: 14),
          Text(widget.text,
            style: AppTypography.bodyStyle(context, fontSize: widget.isMob ? 13.5 : 15, color: Colors.white.withOpacity(0.72), height: 1.8)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. PHILOSOPHY OF LIFE — giant typographic statement
// ─────────────────────────────────────────────────────────────────────────────
class _PhilosophyBlock extends StatefulWidget {
  final String quote;
  final bool isMob;
  final String lang;
  final AppLocalizations l10n;
  const _PhilosophyBlock({required this.quote, required this.isMob, required this.lang, required this.l10n});

  @override
  State<_PhilosophyBlock> createState() => _PhilosophyBlockState();
}

class _PhilosophyBlockState extends State<_PhilosophyBlock> with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('about-philosophy-block'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.4 && !_isVisible) {
          setState(() => _isVisible = true);
        }
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: widget.isMob ? 24 : 60, vertical: widget.isMob ? 100 : 160),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                FadeInDown(
                  animate: _isVisible,
                  child: _Label(widget.l10n.philosophyOfLife, widget.isMob),
                ),
                const SizedBox(height: 60),
                
                // Glowing Quotes
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return FadeIn(
                      animate: _isVisible,
                      duration: const Duration(milliseconds: 1000),
                      child: Icon(
                        Icons.format_quote_rounded, 
                        color: _gold.withOpacity(0.1 + (0.3 * _glowController.value)), 
                        size: 100,
                        shadows: [
                          Shadow(color: _gold.withOpacity(0.5 * _glowController.value), blurRadius: 20),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Animated Quote Text
                FadeIn(
                  animate: _isVisible,
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 1500),
                  child: Text(
                    widget.quote,
                    textAlign: TextAlign.center,
                    style: AppTypography.headingStyle(context,
                      fontSize: widget.isMob ? 24 : 36,
                      color: _teal,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                FadeIn(
                  animate: _isVisible,
                  delay: const Duration(milliseconds: 1000),
                  child: Container(width: 80, height: 3, color: _gold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// 7. PERSONAL ATTRIBUTES — tags/badges
// ─────────────────────────────────────────────────────────────────────────────
class _AttributesBlock extends StatelessWidget {
  final List<String> items;
  final bool isMob, isDsk;
  final String lang;
  final AppLocalizations l10n;
  const _AttributesBlock({required this.items, required this.isMob, required this.isDsk, required this.lang, required this.l10n});

  static const _icons = [
    Icons.favorite_rounded, Icons.handshake_rounded, Icons.self_improvement_rounded,
    Icons.volunteer_activism_rounded, Icons.lightbulb_rounded, Icons.temple_hindu_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final cols = isMob ? 1 : (isDsk ? 2 : 2);
    String titleText = lang == 'hi' ? 'चरित्र, मूल्य और जीवन सिद्धांत' : lang == 'gu' ? 'ચારિત્ર્ય, મૂલ્યો અને જીવન સિદ્ધાંતો' : 'Character, Values & Life Principles';

    return Container(
      color: _beige,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMob ? 24 : (isDsk ? 120 : 60), vertical: isMob ? 60 : 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label(l10n.personalAttributes, isMob),
              const SizedBox(height: 8),
              Text(titleText,
                style: AppTypography.headingStyle(context, fontSize: isMob ? 26 : 38, color: _teal, fontWeight: FontWeight.w700, height: 1.2)),
              const SizedBox(height: 52),
              LayoutBuilder(builder: (ctx, box) {
                final itemW = cols == 1 ? box.maxWidth : (box.maxWidth - 24) / 2;
                return Wrap(spacing: 24, runSpacing: 20,
                  children: items.asMap().entries.map((e) =>
                    SizedBox(width: itemW,
                      child: _AttrCard(
                        icon: e.key < _icons.length ? _icons[e.key] : Icons.star_rounded,
                        label: e.value, isMob: isMob,
                      ))).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttrCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isMob;
  const _AttrCard({required this.icon, required this.label, required this.isMob});

  @override
  State<_AttrCard> createState() => _AttrCardState();
}

class _AttrCardState extends State<_AttrCard> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: _hov ? _teal : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _hov ? _teal : _gold.withOpacity(0.25)),
          boxShadow: [BoxShadow(color: _hov ? _teal.withOpacity(0.15) : Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _hov ? _gold.withOpacity(0.2) : _beige,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(widget.icon, color: _gold, size: 19),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(widget.label,
            style: TextStyle(
              color: _hov ? Colors.white : _ink,
              fontSize: widget.isMob ? 13 : 14.5,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ))),
          Icon(Icons.arrow_forward_rounded, color: _hov ? _gold.withOpacity(0.6) : Colors.transparent, size: 16),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. SIGNATURE IDENTITY
// ─────────────────────────────────────────────────────────────────────────────
class _SignatureBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isMob, isDsk;
  final String lang;
  final AppLocalizations l10n;
  const _SignatureBlock({required this.title, required this.subtitle, required this.isMob, required this.isDsk, required this.lang, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? 24 : (isDsk ? 120 : 60),
        vertical: isMob ? 60 : 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                l10n.signatureIdentity,
                style: AppTypography.headingStyle(
                  context,
                  fontSize: isMob ? 26 : 32,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5A2D82), // Deep purple as requested
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '"$title" ',
                      style: AppTypography.bodyStyle(context,
                        fontSize: isMob ? 18 : 22,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF03A3A), // Red as requested
                      ),
                    ),
                    TextSpan(
                      text: subtitle,
                      style: AppTypography.bodyStyle(context,
                        fontSize: isMob ? 18 : 22,
                        fontWeight: FontWeight.w400,
                        color: _slate,
                        height: 1.6,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED — Section label
// ─────────────────────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  final bool isMob;
  final bool onDark;
  const _Label(this.text, this.isMob, {this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(width: 24, height: 1.5, color: _gold),
        const SizedBox(width: 10),
        Text(text,
          style: AppTypography.bodyStyle(context,
            fontSize: isMob ? 10 : 11,
            fontWeight: FontWeight.w800,
            color: _gold,
            letterSpacing: 3.5)),
        const SizedBox(width: 10),
        Container(width: 24, height: 1.5, color: _gold.withOpacity(0.0)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DOT GRID PAINTER — subtle hero texture
// ─────────────────────────────────────────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.025)..strokeWidth = 1;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
