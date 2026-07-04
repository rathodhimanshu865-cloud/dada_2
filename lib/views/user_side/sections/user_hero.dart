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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundBeige = Color(0xFFF9F3EA);
    const accentBrown = Color(0xFFC19A6B);

    // Filter out empty URLs
    final List<String> images = widget.controller.heroSection.bannerUrls
        .where((url) => url.isNotEmpty)
        .toList();

    // If no images are uploaded, show placeholders
    if (images.isEmpty) {
      images.addAll(
        List.filled(
          8,
          'https://via.placeholder.com/1600x700?text=Jignesh+Dada+Official',
        ),
      );
    }

    return Stack(
      children: [
        // Main Image Slider with Fixed Aspect Ratio Logic
        SizedBox(
          width: double.infinity,
          height: 650, // Increased height to prevent vertical cutting
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
                alignment: Alignment.topCenter, // CRITICAL: Prioritize the top of the photo (Head/Face)
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),

        // Navigation Arrows
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navArrow(Icons.chevron_left, () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                )),
                _navArrow(Icons.chevron_right, () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                )),
              ],
            ),
          ),
        ),

        // Professional Bottom Gradient Fade
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200, // Taller fade for a more professional transition
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.0),
                  backgroundBeige.withOpacity(0.4),
                  backgroundBeige.withOpacity(0.8),
                  backgroundBeige, // Perfectly matches the background color of next section
                ],
              ),
            ),
          ),
        ),

        // Navigation Indicators (Sleek gold bars)
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              bool isSelected = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 30 : 15,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? accentBrown : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _navArrow(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white70, size: 30),
      ),
    );
  }
}
