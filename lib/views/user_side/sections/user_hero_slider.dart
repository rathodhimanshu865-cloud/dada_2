import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../models/homepage_model.dart';
import '../../../utils/app_typography.dart';
import '../../../utils/animation_utils.dart';

class UserHeroSlider extends StatefulWidget {
  final HomePageController controller;
  final ScrollController? scrollController;
  const UserHeroSlider({super.key, required this.controller, this.scrollController});

  @override
  State<UserHeroSlider> createState() => _UserHeroSliderState();
}

class _UserHeroSliderState extends State<UserHeroSlider> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  double _scrollOpacity = 1.0;

  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.linear),
    );

    if (widget.controller.heroSection.slides.length > 1) {
      _startTimer();
    }

    widget.scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.scrollController!.hasClients) {
      double offset = widget.scrollController!.offset;
      double newOpacity = (1.0 - (offset / 300)).clamp(0.0, 1.0);
      if (newOpacity != _scrollOpacity) {
        setState(() => _scrollOpacity = newOpacity);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_pageController.hasClients) {
        int next = (_currentPage + 1) % widget.controller.heroSection.slides.length;
        _pageController.animateToPage(
          next, 
          duration: AnimationUtils.getDuration(context, const Duration(milliseconds: 1500)), 
          curve: Curves.easeInOutExpo
        );
      }
    });
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _timer?.cancel();
    _pageController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.controller.heroSection.slides;
    if (slides.isEmpty) return const SizedBox.shrink();

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;
    final bool isReducedMotion = !AnimationUtils.shouldAnimate(context);
    
    final double sliderHeight = isMobile ? screenHeight * 0.75 : screenHeight;

    return SizedBox(
      height: sliderHeight,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: slides.length,
            itemBuilder: (context, index) => _buildSlide(slides[index], index == _currentPage, isReducedMotion),
          ),
          
          // Navigation Indicators
          if (slides.length > 1)
            Positioned(
              bottom: isMobile ? 30 : 60,
              left: 40,
              child: Opacity(
                opacity: _scrollOpacity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(slides.length, (index) => _buildIndicator(index == _currentPage)),
                ),
              ),
            ),
          
          // Scroll Down Indicator
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: _scrollOpacity,
              child: FadeInUp(
                duration: AnimationUtils.getDuration(context, const Duration(milliseconds: 800)),
                delay: AnimationUtils.getDuration(context, const Duration(milliseconds: 1500)),
                child: Column(
                  children: [
                    Text(
                      "Radhe Radhe",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isReducedMotion) _BouncingChevron() else const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(HeroSlide slide, bool isActive, bool isReducedMotion) {
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;

    return Stack(
      children: [
        // Background with Ken Burns Effect
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _zoomAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isReducedMotion ? 1.0 : _zoomAnimation.value,
                child: Image.network(
                  slide.image,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 50)),
                ),
              );
            },
          ),
        ),
        
        // Soft Dark Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
        
        // Content Overlay
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (slide.localizedBadge(lang).isNotEmpty)
                  FadeInDown(
                    animate: isActive,
                    duration: AnimationUtils.getDuration(context, const Duration(milliseconds: 600)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFC89A5B)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        slide.localizedBadge(lang).toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFC89A5B),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                
                // Headline with wipe animation
                if (slide.localizedHeading(lang).isNotEmpty)
                  FadeInUp(
                    animate: isActive,
                    duration: AnimationUtils.getDuration(context, const Duration(milliseconds: 800)),
                    delay: AnimationUtils.getDuration(context, const Duration(milliseconds: 200)),
                    child: Text(
                      slide.localizedHeading(lang),
                      style: AppTypography.headingStyle(
                        context,
                        fontSize: isMobile ? 40 : 80,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // Subheadline
                if (slide.localizedSubtitle(lang).isNotEmpty)
                  FadeInUp(
                    animate: isActive,
                    duration: AnimationUtils.getDuration(context, const Duration(milliseconds: 800)),
                    delay: AnimationUtils.getDuration(context, const Duration(milliseconds: 500)),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Text(
                        slide.localizedSubtitle(lang),
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 24,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w300,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 50),
                
                // CTA Buttons
                Row(
                  children: [
                    if (slide.localizedPrimaryCtaText(lang).isNotEmpty)
                      FadeInLeft(
                        animate: isActive,
                        duration: AnimationUtils.getDuration(context, const Duration(milliseconds: 600)),
                        delay: AnimationUtils.getDuration(context, const Duration(milliseconds: 800)),
                        child: _HeroCtaButton(
                          text: slide.localizedPrimaryCtaText(lang),
                          isPrimary: true,
                          onPressed: () {
                            if (slide.primaryCtaUrl.isNotEmpty) {
                              Navigator.pushNamed(context, slide.primaryCtaUrl);
                            }
                          },
                        ),
                      ),
                    const SizedBox(width: 20),
                    if (slide.localizedSecondaryCtaText(lang).isNotEmpty)
                      FadeInLeft(
                        animate: isActive,
                        duration: AnimationUtils.getDuration(context, const Duration(milliseconds: 600)),
                        delay: AnimationUtils.getDuration(context, const Duration(milliseconds: 1000)),
                        child: _HeroCtaButton(
                          text: slide.localizedSecondaryCtaText(lang),
                          isPrimary: false,
                          onPressed: () {
                            if (slide.secondaryCtaUrl.isNotEmpty) {
                              Navigator.pushNamed(context, slide.secondaryCtaUrl);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(bool active) {
    return AnimatedContainer(
      duration: AnimationUtils.getDuration(context, const Duration(milliseconds: 500)),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: active ? 40 : 10,
      height: 3,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFC89A5B) : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}


class _HeroCtaButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _HeroCtaButton({
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_HeroCtaButton> createState() => _HeroCtaButtonState();
}

class _HeroCtaButtonState extends State<_HeroCtaButton> {
  bool _isHovered = false;
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isTapped = true),
        onTapUp: (_) => setState(() => _isTapped = false),
        onTapCancel: () => setState(() => _isTapped = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isTapped ? 0.96 : (_isHovered ? 1.02 : 1.0))
            ..translate(0.0, _isHovered ? -3.0 : 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: widget.isPrimary 
              ? (_isHovered ? const Color(0xFFD4A76A) : const Color(0xFFC89A5B))
              : Colors.transparent,
            border: widget.isPrimary ? null : Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _isHovered && widget.isPrimary ? [
              BoxShadow(
                color: const Color(0xFFC89A5B).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ] : null,
          ),
          child: Text(
            widget.text.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _BouncingChevron extends StatefulWidget {
  @override
  State<_BouncingChevron> createState() => _BouncingChevronState();
}

class _BouncingChevronState extends State<_BouncingChevron> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 30),
        );
      },
    );
  }
}
