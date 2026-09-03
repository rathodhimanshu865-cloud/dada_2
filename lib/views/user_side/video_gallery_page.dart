import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import '../../utils/app_typography.dart';
import '../../utils/responsive_utils.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class VideoGalleryPage extends StatefulWidget {
  const VideoGalleryPage({super.key});

  @override
  State<VideoGalleryPage> createState() => _VideoGalleryPageState();
}

class _VideoGalleryPageState extends State<VideoGalleryPage> {
  int activeCategoryIndex = 0;
  bool _isFiltering = false;

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    const accentBrown = Color(0xFFC19A6B);

    final controller = Provider.of<HomePageController>(context);
    final data = controller.videoGalleryData;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    final bool isMobile = Responsive.isMobile(context);

    // Prepare Categories (Sections + All Videos as first option)
    List<VideoCategory> categories = [
      VideoCategory(
        categoryTitle: lang == 'hi' ? 'सभी वीडियो' : lang == 'gu' ? 'બધા વિડિયો' : 'All Videos',
        videos: controller.videos.map((v) => VideoGalleryEntry(title: v.title, youtubeUrl: v.youtubeUrl)).toList(),
      ),
      ...data.categories,
    ];

    List<VideoGalleryEntry> currentVideos = categories[activeCategoryIndex].videos;

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          
          // Hero Title Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100),
            decoration: BoxDecoration(
              color: backgroundBeige.withOpacity(0.4),
              image: const DecorationImage(
                image: NetworkImage('https://www.transparenttextures.com/patterns/natural-paper.png'),
                opacity: 0.05,
              ),
            ),
            child: Column(
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    AppLocalizations.of(context)!.videoGallery, 
                    style: AppTypography.headingStyle(
                      context, 
                      fontSize: AppTypography.getResponsiveSize(context, desktop: 56, tablet: 48, mobile: 38),
                      fontWeight: FontWeight.w900,
                      color: primaryTeal,
                      height: 1.1,
                    )
                  ),
                ),
                const SizedBox(height: 15),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    height: 1.5, width: 60, color: accentBrown,
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    AppLocalizations.of(context)!.homeGalleryVideos, 
                    style: TextStyle(
                      color: primaryTeal.withOpacity(0.6), 
                      fontSize: isMobile ? 14 : 16, 
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600
                    )
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Category Filter Tabs
          if (categories.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(categories.length, (index) {
                    final category = categories[index];
                    bool isActive = activeCategoryIndex == index;
                    return GestureDetector(
                      onTap: () {
                        if (activeCategoryIndex != index) {
                          setState(() {
                            _isFiltering = true;
                            activeCategoryIndex = index;
                          });
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) setState(() => _isFiltering = false);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        decoration: const BoxDecoration(color: Colors.transparent),
                        child: Column(
                          children: [
                            Text(
                              category.localizedCategoryTitle(lang).toUpperCase(),
                              style: TextStyle(
                                color: isActive ? primaryTeal : Colors.grey,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                letterSpacing: 1.5,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              height: 2,
                              width: isActive ? 30 : 0,
                              color: accentBrown,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

          const SizedBox(height: 40),

          // Video Grid with Exit/Entrance Animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _isFiltering 
              ? const SizedBox(height: 600, width: double.infinity)
              : _buildVideoGrid(context, currentVideos, primaryTeal, accentBrown, lang),
          ),

          const SizedBox(height: 100),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _buildVideoGrid(BuildContext context, List<VideoGalleryEntry> videos, Color primaryTeal, Color accentBrown, String lang) {
    if (videos.isEmpty) {
      return FadeIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100), 
          child: Text("No videos added to this section yet.", style: const TextStyle(color: Colors.grey, fontSize: 18))
        ),
      );
    }
    final bool isMobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100),
      child: LayoutBuilder(builder: (context, constraints) {
        int cols = Responsive.isDesktop(context) ? 3 : (Responsive.isTablet(context) ? 2 : 1);
        if (constraints.maxWidth < 600) cols = 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(cols * 2 - 1, (index) {
            if (index.isOdd) return SizedBox(width: isMobile ? 15 : 30);
            int colIdx = index ~/ 2;
            return Expanded(
              child: Column(
                children: videos.asMap().entries
                    .where((e) => e.key % cols == colIdx)
                    .map<Widget>((e) {
                      int overallIndex = e.key;
                      return FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: Duration(milliseconds: (overallIndex % 6) * 100),
                        child: _VideoCard(video: e.value, lang: lang, isMobile: isMobile, accentBrown: accentBrown),
                      );
                    })
                    .toList(),
              ),
            );
          }),
        );
      }),
    );
  }
}

class _VideoCard extends StatefulWidget {
  final VideoGalleryEntry video;
  final String lang;
  final bool isMobile;
  final Color accentBrown;

  const _VideoCard({
    required this.video, 
    required this.lang, 
    required this.isMobile, 
    required this.accentBrown
  });

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: widget.isMobile ? 30 : 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: () => _openVideoModal(context, widget.video.youtubeUrl),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.1),
                      blurRadius: _isHovered ? 30 : 20,
                      offset: Offset(0, _isHovered ? 15 : 10),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 16/9,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 600),
                          scale: _isHovered ? 1.05 : 1.0,
                          child: Image.network(
                            widget.video.thumbnail, 
                            width: double.infinity, 
                            fit: BoxFit.cover, 
                            errorBuilder: (c, e, s) => Container(color: Colors.grey[200])
                          ),
                        ),
                      ),
                      
                      // Dark Overlay
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: _isHovered ? 0.4 : 0.2,
                        child: Container(color: Colors.black),
                      ),
                      
                      _PulsingPlayButton(isHovered: _isHovered, accentColor: widget.accentBrown),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            widget.video.localizedTitle(widget.lang).toUpperCase(), 
            maxLines: 2, 
            overflow: TextOverflow.ellipsis, 
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w900, 
              color: Color(0xFF1A1A1A), 
              height: 1.4, 
              letterSpacing: 0.5
            )
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.play_circle_fill, size: 14, color: widget.accentBrown),
              const SizedBox(width: 6),
              Text(
                "YOUTUBE DISCOURSE",
                style: TextStyle(
                  color: widget.accentBrown,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openVideoModal(BuildContext context, String url) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Video Player',
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return _VideoPlayerModal(url: url);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }
}

class _VideoPlayerModal extends StatelessWidget {
  final String url;
  const _VideoPlayerModal({required this.url});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismiss area
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),
          
          Center(
            child: Container(
              width: isMobile ? MediaQuery.of(context).size.width * 0.95 : MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 20))
                ],
              ),
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Since we are not integrating a full YouTube player library here 
                    // for complexity reasons (requiring specific plugins setup), 
                    // we provide a high-fidelity "Play on YouTube" interface
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.video_library_rounded, color: Colors.white, size: 60),
                        const SizedBox(height: 20),
                        const Text(
                          "Watch Discourse on YouTube",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () {
                            _launchUrl(url);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text("OPEN IN YOUTUBE"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC19A6B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          ),
                        ),
                      ],
                    ),
                    
                    Positioned(
                      top: 20,
                      right: 20,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingPlayButton extends StatefulWidget {
  final bool isHovered;
  final Color accentColor;
  const _PulsingPlayButton({required this.isHovered, required this.accentColor});

  @override
  State<_PulsingPlayButton> createState() => _PulsingPlayButtonState();
}

class _PulsingPlayButtonState extends State<_PulsingPlayButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(2, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double progress = (_controller.value + index / 2) % 1.0;
              return Container(
                width: 60 + (progress * 60),
                height: 60 + (progress * 60),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(1.0 - progress),
                    width: 2,
                  ),
                ),
              );
            },
          );
        }),
        
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: widget.isHovered ? 70 : 60,
          height: widget.isHovered ? 70 : 60,
          decoration: BoxDecoration(
            color: widget.isHovered ? widget.accentColor : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(
            Icons.play_arrow_rounded, 
            size: widget.isHovered ? 40 : 35, 
            color: Colors.white
          ),
        ),
      ],
    );
  }
}
