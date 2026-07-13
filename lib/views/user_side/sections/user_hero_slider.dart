import 'dart:async';
import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';

class UserHeroSlider extends StatefulWidget {
  final HomePageController controller;
  const UserHeroSlider({super.key, required this.controller});

  @override
  State<UserHeroSlider> createState() => _UserHeroSliderState();
}

class _UserHeroSliderState extends State<UserHeroSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.controller.heroSection.slides.length > 1) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_pageController.hasClients) {
        int next = (_currentPage + 1) % widget.controller.heroSection.slides.length;
        _pageController.animateToPage(next, duration: const Duration(milliseconds: 1500), curve: Curves.easeInOutExpo);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.controller.heroSection.slides;
    if (slides.isEmpty) return const SizedBox.shrink();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: slides.length,
            itemBuilder: (context, index) => _buildSlide(slides[index]),
          ),
          
          // Navigation Indicators
          if (slides.length > 1)
            Positioned(
              bottom: 40,
              left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (index) => _buildIndicator(index == _currentPage)),
              ),
            ),
            
          // Floating Gradient
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, const Color(0xFFFAF8F4).withOpacity(0.8), const Color(0xFFFAF8F4)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(HeroSlide slide) {
    return Container(
      color: const Color(0xFFFAF8F4), // Site background color
      child: Stack(
        children: [
          // Background Image - Set to contain to show full image
          Positioned.fill(
            child: Image.network(
              slide.image,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
          
          // Removed Dark Overlay as requested
          
          // Content with a soft background for readability since overlay is gone
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (slide.badge.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        border: Border.all(color: const Color(0xFFC89A5B), width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        slide.badge.toUpperCase(),
                        style: const TextStyle(color: Color(0xFFC89A5B), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 4),
                      ),
                    ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      slide.heading,
                      style: const TextStyle(
                        fontSize: 72,
                        fontFamily: 'serif',
                        color: Color(0xFF0F4C5C), // Dark color for readability on light BG
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      slide.subtitle,
                      style: const TextStyle(fontSize: 24, color: Color(0xFFC89A5B), fontWeight: FontWeight.w300, letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: 600,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      slide.description,
                      style: const TextStyle(fontSize: 18, color: Color(0xFF2B2B2B), height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Row(
                    children: [
                      if (slide.primaryCtaText.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4C5C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: Text(slide.primaryCtaText.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        ),
                      const SizedBox(width: 20),
                      if (slide.secondaryCtaText.isNotEmpty)
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0F4C5C), width: 1),
                            foregroundColor: const Color(0xFF0F4C5C),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: Text(slide.secondaryCtaText.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
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
