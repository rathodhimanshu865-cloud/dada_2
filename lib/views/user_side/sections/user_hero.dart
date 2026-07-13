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
      final images = widget.controller.heroSection.bannerUrls
          .where((url) => url.isNotEmpty)
          .toList();
      int total = images.isEmpty ? 8 : images.length;
      
      if (_currentPage < total - 1) {
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
    const accentBrown = Color(0xFFC19A6B);
    const backgroundBeige = Color(0xFFF9F3EA);

    final List<String> images = widget.controller.heroSection.bannerUrls
        .where((url) => url.isNotEmpty)
        .toList();

    if (images.isEmpty) {
      images.addAll(
        List.filled(
          8,
          'https://via.placeholder.com/1920x800?text=Jignesh+Dada+Official',
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // High-end edge-to-edge height
        double sliderHeight = 650; 

        return Stack(
          children: [
            // Main Image Slider (FULL EDGE-TO-EDGE)
            SizedBox(
              width: double.infinity,
              height: sliderHeight,
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
                    alignment: const Alignment(0, -0.4), 
                    width: double.infinity,
                    height: double.infinity,
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

            // Proper Bottom Gradient Fade
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 150, // Height of the gradient fade
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      backgroundBeige.withOpacity(0.5),
                      backgroundBeige,
                    ],
                  ),
                ),
              ),
            ),

            // Navigation Indicators
            Positioned(
              bottom: 25,
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
      },
    );
  }

  Widget _navArrow(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2), 
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
