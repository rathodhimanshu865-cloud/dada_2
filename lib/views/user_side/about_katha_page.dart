import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../l10n/app_localizations.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import '../../utils/app_typography.dart';
import '../../utils/animation_utils.dart';

class AboutKathaPage extends StatefulWidget {
  const AboutKathaPage({super.key});

  @override
  State<AboutKathaPage> createState() => _AboutKathaPageState();
}

class _AboutKathaPageState extends State<AboutKathaPage> with TickerProviderStateMixin {
  bool _isVisible = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    const accentBrown = Color(0xFFC19A6B);

    final controller = Provider.of<HomePageController>(context);
    final data = controller.bhagvatKathaPage;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;
    final horizontalPad = isMobile ? 20.0 : (screenWidth > 1400 ? (screenWidth - 1200) / 2 : 100.0);

    return UserPageLayout(
      controller: controller,
      child: VisibilityDetector(
        key: const Key('about-katha-visibility'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.1 && !_isVisible) {
            if (mounted) setState(() => _isVisible = true);
          }
        },
        child: Column(
          children: [
            const SizedBox(height: 120),
            
            // 1. HERO SECTION
            Container(
              width: double.infinity,
              color: backgroundBeige,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: isMobile ? 60 : 100),
                child: Builder(builder: (context) {
                  Widget heroText = Column(
                    crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      FadeInLeft(
                        animate: _isVisible,
                        duration: const Duration(milliseconds: 800),
                        child: Row(
                          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                          children: [
                            Container(width: 40, height: 1.5, color: accentBrown),
                            const SizedBox(width: 15),
                            Flexible(
                              child: Text(
                                data.localizedHeroBadge(lang).toUpperCase(),
                                style: const TextStyle(color: accentBrown, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 3),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeInUp(
                        animate: _isVisible,
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          data.localizedHeroTitle(lang),
                          textAlign: isMobile ? TextAlign.center : TextAlign.start,
                          style: AppTypography.headingStyle(
                            context,
                            fontSize: isMobile ? 36 : 64,
                            fontWeight: FontWeight.w900,
                            color: primaryTeal,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      FadeInUp(
                        animate: _isVisible,
                        delay: const Duration(milliseconds: 400),
                        child: Text(
                          data.localizedHeroDesc1(lang),
                          textAlign: isMobile ? TextAlign.center : TextAlign.start,
                          style: TextStyle(fontSize: isMobile ? 16 : 20, color: Colors.black87, height: 1.7, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300),
                        ),
                      ),
                      const SizedBox(height: 25),
                      FadeInUp(
                        animate: _isVisible,
                        delay: const Duration(milliseconds: 600),
                        child: Text(
                          data.localizedHeroDesc2(lang),
                          textAlign: isMobile ? TextAlign.center : TextAlign.start,
                          style: TextStyle(fontSize: isMobile ? 15 : 17, color: Colors.black54, height: 1.7, letterSpacing: 0.2),
                        ),
                      ),
                    ],
                  );

                  if (isMobile) {
                    return heroText;
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: heroText),
                    ],
                  );
                }),
              ),
            ),

            // 2. BIOGRAPHY SECTION
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 150, vertical: isMobile ? 60 : 120),
              child: Column(
                children: [
                  FadeInDown(
                    animate: _isVisible,
                    delay: const Duration(milliseconds: 800),
                    child: const Icon(Icons.wb_sunny_outlined, color: accentBrown, size: 40),
                  ),
                  const SizedBox(height: 50),
                  FadeInUp(
                    animate: _isVisible,
                    delay: const Duration(milliseconds: 1000),
                    child: Text(
                      data.localizedBioText(lang).isNotEmpty ? data.localizedBioText(lang) : AppLocalizations.of(context)!.biographyDetailsFallback,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: isMobile ? 15 : 18, color: const Color(0xFF333333), height: 1.9, letterSpacing: 0.3, fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),

            // 3. QUOTE SECTION
            _AnimatedQuote(
              isVisible: _isVisible,
              quote: data.localizedQuoteText(lang),
              author: data.localizedQuoteAuthor(lang),
              image: data.quoteImage,
              primaryTeal: primaryTeal,
              accentBrown: accentBrown,
              isMobile: isMobile,
            ),

            // 4. HIGHLIGHTS
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100, vertical: isMobile ? 60 : 120),
              child: isMobile 
                ? Column(
                    children: [
                      FadeInUp(animate: _isVisible, delay: const Duration(milliseconds: 1200), child: _buildHighlightCard(data.localizedHighlight1Title(lang), Icons.stars_rounded, data.localizedHighlight1Desc(lang), accentBrown)),
                      const SizedBox(height: 30),
                      FadeInUp(animate: _isVisible, delay: const Duration(milliseconds: 1400), child: _buildHighlightCard(data.localizedHighlight2Title(lang), Icons.auto_awesome, data.localizedHighlight2Desc(lang), accentBrown)),
                      const SizedBox(height: 30),
                      FadeInUp(animate: _isVisible, delay: const Duration(milliseconds: 1600), child: _buildHighlightCard(data.localizedHighlight3Title(lang), Icons.favorite_border_rounded, data.localizedHighlight3Desc(lang), accentBrown)),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: FadeInUp(animate: _isVisible, delay: const Duration(milliseconds: 1200), child: _buildHighlightCard(data.localizedHighlight1Title(lang), Icons.stars_rounded, data.localizedHighlight1Desc(lang), accentBrown))),
                      const SizedBox(width: 40),
                      Expanded(child: FadeInUp(animate: _isVisible, delay: const Duration(milliseconds: 1400), child: _buildHighlightCard(data.localizedHighlight2Title(lang), Icons.auto_awesome, data.localizedHighlight2Desc(lang), accentBrown))),
                      const SizedBox(width: 40),
                      Expanded(child: FadeInUp(animate: _isVisible, delay: const Duration(milliseconds: 1600), child: _buildHighlightCard(data.localizedHighlight3Title(lang), Icons.favorite_border_rounded, data.localizedHighlight3Desc(lang), accentBrown))),
                    ],
                  ),
            ),

            // 5. CTA BANNER
            FadeInUp(
              animate: _isVisible,
              delay: const Duration(milliseconds: 1800),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100),
                padding: EdgeInsets.symmetric(vertical: 60, horizontal: isMobile ? 24 : 80),
                decoration: BoxDecoration(
                  color: primaryTeal, 
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: primaryTeal.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 20))
                  ]
                ),
                child: Column(
                  children: [
                    const Icon(Icons.temple_hindu_outlined, color: Colors.white54, size: 60),
                    const SizedBox(height: 30),
                    Text(
                      data.localizedCtaTitle(lang),
                      textAlign: TextAlign.center,
                      style: AppTypography.headingStyle(
                        context,
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(data.localizedCtaSubtitle(lang), textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: isMobile ? 15 : 18, height: 1.5)),
                    const SizedBox(height: 40),
                    _PulsingCTAButton(
                      text: 'Explore Other Kathas',
                      onPressed: () => Navigator.pushNamed(context, '/katha_list'),
                      backgroundColor: backgroundBeige,
                      foregroundColor: primaryTeal,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 120),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard(String title, IconData icon, String desc, Color accent) {
    return StatefulBuilder(builder: (context, setState) {
      bool isHovered = false;
      return MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          transform: Matrix4.translationValues(0, isHovered ? -10 : 0, 0),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isHovered ? Colors.black.withOpacity(0.12) : Colors.black.withOpacity(0.06), 
                blurRadius: isHovered ? 40 : 25, 
                offset: Offset(0, isHovered ? 20 : 12)
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 400),
                scale: isHovered ? 1.2 : 1.0,
                child: Icon(icon, color: accent, size: 48),
              ),
              const SizedBox(height: 30),
              Text(
                title, 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1.2, color: Color(0xFF222222))
              ),
              const SizedBox(height: 20),
              Text(
                desc, 
                style: const TextStyle(color: Color(0xFF666666), fontSize: 16, height: 1.7, fontWeight: FontWeight.w400)
              ),
              const SizedBox(height: 30),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: isHovered ? 80 : 40, 
                height: 3, 
                color: accent.withOpacity(0.6)
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _AnimatedQuote extends StatefulWidget {
  final bool isVisible;
  final String quote;
  final String author;
  final String image;
  final Color primaryTeal;
  final Color accentBrown;
  final bool isMobile;

  const _AnimatedQuote({
    required this.isVisible,
    required this.quote,
    required this.author,
    required this.image,
    required this.primaryTeal,
    required this.accentBrown,
    required this.isMobile,
  });

  @override
  State<_AnimatedQuote> createState() => _AnimatedQuoteState();
}

class _AnimatedQuoteState extends State<_AnimatedQuote> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.isMobile ? 15 : 100),
      decoration: BoxDecoration(
        color: widget.primaryTeal, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: widget.primaryTeal.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20))
        ]
      ),
      clipBehavior: Clip.antiAlias,
      child: Builder(builder: (context) {
        Widget quoteText = Padding(
          padding: EdgeInsets.all(widget.isMobile ? 40 : 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return ZoomIn(
                    animate: widget.isVisible,
                    duration: const Duration(milliseconds: 1000),
                    child: Icon(
                      Icons.format_quote, 
                      color: widget.accentBrown.withOpacity(0.2 + (0.3 * _pulseController.value)), 
                      size: 100,
                      shadows: [
                        Shadow(color: widget.accentBrown.withOpacity(0.5 * _pulseController.value), blurRadius: 20)
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              FadeIn(
                animate: widget.isVisible,
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 1500),
                child: Text(
                  widget.quote,
                  style: AppTypography.headingStyle(
                    context,
                    fontSize: widget.isMobile ? 20 : 32,
                    color: Colors.white,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              FadeInLeft(
                animate: widget.isVisible,
                delay: const Duration(milliseconds: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '- ${widget.author.toUpperCase()}', 
                      style: TextStyle(color: widget.accentBrown, fontSize: widget.isMobile ? 14 : 18, fontWeight: FontWeight.w900, letterSpacing: 2)
                    ),
                    const SizedBox(height: 15),
                    Container(width: 60, height: 2, color: widget.accentBrown),
                  ],
                ),
              ),
            ],
          ),
        );

        Widget quoteImg = widget.image.isNotEmpty ? Image.network(
          widget.image, 
          height: widget.isMobile ? 350 : 600, 
          fit: BoxFit.cover, 
          errorBuilder: (c, e, s) => Container(color: Colors.black26)
        ) : Container(height: widget.isMobile ? 350 : 600, color: Colors.black26);

        if (widget.isMobile) {
          return Column(
            children: [
              quoteText,
              quoteImg,
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 6, child: quoteText),
            Expanded(flex: 5, child: quoteImg),
          ],
        );
      }),
    );
  }
}

class _PulsingCTAButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const _PulsingCTAButton({
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  State<_PulsingCTAButton> createState() => _PulsingCTAButtonState();
}

class _PulsingCTAButtonState extends State<_PulsingCTAButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withOpacity(0.2 * _controller.value),
                blurRadius: 15 * _controller.value,
                spreadRadius: 2 * _controller.value,
              )
            ]
          ),
          child: SiteElevatedButton(
            onPressed: widget.onPressed,
            enableHoverLift: false, // It pulses anyway
            backgroundColor: widget.backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.text, style: TextStyle(color: widget.foregroundColor, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
                const SizedBox(width: 15),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: widget.foregroundColor),
              ],
            ),
          ),
        );
      },
    );
  }
}
