import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../controllers/homepage_controller.dart';

class UserFeaturedQuote extends StatefulWidget {
  final HomePageController controller;
  const UserFeaturedQuote({super.key, required this.controller});

  @override
  State<UserFeaturedQuote> createState() => _UserFeaturedQuoteState();
}

class _UserFeaturedQuoteState extends State<UserFeaturedQuote> with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quoteData = widget.controller.homepageData.featuredQuote;
    final lang = Localizations.localeOf(context).languageCode;
    if (quoteData.quote.isEmpty) return const SizedBox.shrink();

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;
    
    return VisibilityDetector(
      key: const Key('user-featured-quote'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3 && !_isVisible) {
          setState(() => _isVisible = true);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isMobile ? 80 : 160, horizontal: isMobile ? 20 : 40),
        color: const Color(0xFFFAF8F4),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Gold Glow Pulse Behind
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: isMobile ? 300 : 600,
                    height: isMobile ? 200 : 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFC89A5B).withOpacity(0.08 * _pulseController.value),
                          const Color(0xFFC89A5B).withOpacity(0),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              Container(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    FadeInDown(
                      animate: _isVisible,
                      duration: const Duration(milliseconds: 600),
                      child: Icon(Icons.format_quote_rounded, size: isMobile ? 40 : 80, color: const Color(0xFFC89A5B)),
                    ),
                    SizedBox(height: isMobile ? 20 : 40),
                    FadeIn(
                      animate: _isVisible,
                      duration: const Duration(milliseconds: 1000),
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        quoteData.localizedQuote(lang),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? (screenWidth < 600 ? 20 : 28) : 42,
                          fontFamily: 'serif',
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF2B2B2B),
                          height: 1.4,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 25 : 40),
                    FadeIn(
                      animate: _isVisible,
                      delay: const Duration(milliseconds: 800),
                      child: Container(height: 1, width: 80, color: const Color(0xFFC89A5B)),
                    ),
                    const SizedBox(height: 30),
                    FadeInUp(
                      animate: _isVisible,
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 1000),
                      child: Text(
                        quoteData.localizedAuthor(lang).toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 6, 
                          color: const Color(0xFFC89A5B)
                        ),
                      ),
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
