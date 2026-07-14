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
      height: MediaQuery.of(context).size.height, // Full screen height
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
        ],
      ),
    );
  }

  Widget _buildSlide(HeroSlide slide) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.network(
        slide.image,
        fit: BoxFit.cover, // Fills full screen, no color on sides
        alignment: Alignment.center,
        errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 50)),
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
