import 'package:flutter/material.dart';
import 'dart:async';
import '../../../controllers/homepage_controller.dart';

class UserHero extends StatefulWidget {
  final HomePageController controller;
  const UserHero({super.key, required this.controller});

  @override
  State<UserHero> createState() => _UserHeroState();
}

class _UserHeroState extends State<UserHero> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < 7) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Filter out empty URLs
    final List<String> images = widget.controller.heroSection.bannerUrls
        .where((url) => url.isNotEmpty)
        .toList();

    // If no images are uploaded, show placeholders
    if (images.isEmpty) {
      images.addAll(List.filled(8, 'https://via.placeholder.com/1200x500?text=Upload+Image+in+Admin'));
    }

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 550, // Adjusted height to match the professional look of the photo
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                ),
              );
            },
          ),
        ),
        
        // Navigation Arrows (Optional, but visible in the photo)
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                },
                icon: const Icon(Icons.chevron_left, color: Colors.white54, size: 40),
              ),
              IconButton(
                onPressed: () {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                },
                icon: const Icon(Icons.chevron_right, color: Colors.white54, size: 40),
              ),
            ],
          ),
        ),
        
        // Gradient overlay at the bottom for smooth transition (Exactly like the photo)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120, // Height of the gradient fade
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.0),
                  const Color(0xFFFDF9F6).withOpacity(0.6), // Subtle warm transition
                  const Color(0xFFFDF9F6), // Matches the background color of the next sections
                ],
              ),
            ),
          ),
        ),

        // 8 Navigation Dots at the bottom
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              return Container(
                width: index == _currentPage ? 12 : 8,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index == _currentPage ? Colors.brown : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
