import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';
import '../../../utils/app_typography.dart';

class UserTestimonials extends StatefulWidget {
  final HomePageController controller;
  const UserTestimonials({super.key, required this.controller});

  @override
  State<UserTestimonials> createState() => _UserTestimonialsState();
}

class _UserTestimonialsState extends State<UserTestimonials> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentIndex = 0;
  Timer? _timer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller.homepageData.testimonials.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
        if (_pageController.hasClients) {
          int next = (_currentIndex + 1) % widget.controller.homepageData.testimonials.length;
          _pageController.animateToPage(
            next, 
            duration: const Duration(milliseconds: 1000), 
            curve: Curves.easeInOutQuart
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testimonials = widget.controller.homepageData.testimonials;
    if (testimonials.isEmpty) return const SizedBox.shrink();

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;

    return VisibilityDetector(
      key: const Key('user-testimonials'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          setState(() => _isVisible = true);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isMobile ? 80 : 160),
        color: Colors.white,
        child: Column(
          children: [
            Column(
              children: [
                FadeInDown(
                  animate: _isVisible,
                  child: const Text(
                    "DEVOTEE REFLECTIONS",
                    style: TextStyle(color: Color(0xFFC89A5B), letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  animate: _isVisible,
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    "Words of Grace",
                    style: AppTypography.headingStyle(
                      context,
                      fontSize: isMobile ? 32 : 52,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F4C5C),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeIn(
                  animate: _isVisible,
                  delay: const Duration(milliseconds: 400),
                  child: Container(height: 1, width: 80, color: const Color(0xFFC89A5B)),
                ),
              ],
            ),
            const SizedBox(height: 60),
            
            FadeIn(
              animate: _isVisible,
              delay: const Duration(milliseconds: 600),
              child: SizedBox(
                height: isMobile ? 400 : 500,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemCount: testimonials.length,
                  itemBuilder: (context, index) {
                    return _buildTestimonialCard(context, testimonials[index], index == _currentIndex);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Animated Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(testimonials.length, (index) => _buildIndicator(index == _currentIndex)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: active ? 24 : 8,
      height: 4,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFC89A5B) : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTestimonialCard(BuildContext context, Testimonial testimonial, bool active) {
    final lang = Localizations.localeOf(context).languageCode;
    return AnimatedScale(
      duration: const Duration(milliseconds: 800),
      scale: active ? 1.0 : 0.9,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 800),
        opacity: active ? 1.0 : 0.3,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F4),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(active ? 0.06 : 0),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.format_quote_rounded, color: Color(0xFFC89A5B), size: 60),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    testimonial.localizedFeedback(lang),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18, 
                      height: 1.8, 
                      color: const Color(0xFF2B2B2B), 
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFF3EEE6),
                    backgroundImage: testimonial.photo.isNotEmpty ? NetworkImage(testimonial.photo) : null,
                    child: testimonial.photo.isEmpty ? const Icon(Icons.person, color: Color(0xFFC89A5B), size: 30) : null,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial.localizedName(lang).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, color: Color(0xFF0F4C5C)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        testimonial.location,
                        style: const TextStyle(fontSize: 12, color: Color(0xFFC89A5B), fontWeight: FontWeight.bold),
                      ),
                    ],
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
