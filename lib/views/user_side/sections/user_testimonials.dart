import 'dart:async';
import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';

class UserTestimonials extends StatefulWidget {
  final HomePageController controller;
  const UserTestimonials({super.key, required this.controller});

  @override
  State<UserTestimonials> createState() => _UserTestimonialsState();
}

class _UserTestimonialsState extends State<UserTestimonials> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.controller.homepageData.testimonials.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
        if (_pageController.hasClients) {
          int next = (_currentIndex + 1) % widget.controller.homepageData.testimonials.length;
          _pageController.animateToPage(next, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut);
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120),
      color: Colors.white,
      child: Column(
        children: [
          Column(
            children: [
              const Text(
                "DEVOTEE REFLECTIONS",
                style: TextStyle(color: Color(0xFFC89A5B), letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 20),
              const Text(
                "Words of Grace",
                style: TextStyle(fontSize: 42, fontFamily: 'serif', fontWeight: FontWeight.w900, color: Color(0xFF0F4C5C)),
              ),
              const SizedBox(height: 30),
              Container(height: 1, width: 80, color: const Color(0xFFC89A5B)),
            ],
          ),
          const SizedBox(height: 80),
          SizedBox(
            height: 450,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemCount: testimonials.length,
              itemBuilder: (context, index) {
                return _buildTestimonialCard(context, testimonials[index], index == _currentIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(BuildContext context, Testimonial testimonial, bool active) {
    final lang = Localizations.localeOf(context).languageCode;
    return AnimatedScale(
      duration: const Duration(milliseconds: 500),
      scale: active ? 1.0 : 0.9,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: active ? 1.0 : 0.5,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          padding: const EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F4),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 40, offset: const Offset(0, 20)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.format_quote_rounded, color: Color(0xFFC89A5B), size: 50),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    testimonial.localizedFeedback(lang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, height: 1.8, color: Color(0xFF2B2B2B), fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFFF3EEE6),
                    backgroundImage: testimonial.photo.isNotEmpty ? NetworkImage(testimonial.photo) : null,
                    child: testimonial.photo.isEmpty ? const Icon(Icons.person, color: Color(0xFFC89A5B)) : null,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial.localizedName(lang).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                      ),
                      Text(
                        testimonial.location,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6D6D6D)),
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
