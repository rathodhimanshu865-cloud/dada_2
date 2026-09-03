import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../utils/app_typography.dart';

class UserLatestVideos extends StatefulWidget {
  final HomePageController controller;
  const UserLatestVideos({super.key, required this.controller});

  @override
  State<UserLatestVideos> createState() => _UserLatestVideosState();
}

class _UserLatestVideosState extends State<UserLatestVideos> {
  bool _isVisible = false;

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.videos.isEmpty) return const SizedBox.shrink();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;
    final displayVideos = widget.controller.videos.take(isMobile ? 3 : 6).toList();

    return VisibilityDetector(
      key: const Key('user-latest-videos'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          setState(() => _isVisible = true);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 60 : 120,
          horizontal: isMobile ? 20 : 40,
        ),
        color: Colors.white,
        child: Column(
          children: [
            // Header
            Column(
              children: [
                FadeInDown(
                  animate: _isVisible,
                  child: Text(
                    AppLocalizations.of(context)!.watchAndReflect,
                    style: AppTypography.bodyStyle(
                      context,
                      color: const Color(0xFFC89A5B),
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  animate: _isVisible,
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    AppLocalizations.of(context)!.latestVideos,
                    textAlign: TextAlign.center,
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

            SizedBox(height: isMobile ? 50 : 80),

            // Responsive Video Grid
            Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: LayoutBuilder(builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 1000
                    ? 3
                    : (constraints.maxWidth > 700 ? 2 : 1);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: isMobile ? 15 : 30,
                    mainAxisSpacing: isMobile ? 30 : 50,
                    childAspectRatio: isMobile ? 1.4 : 1.1,
                  ),
                  itemCount: displayVideos.length,
                  itemBuilder: (context, index) => FadeInUp(
                    animate: _isVisible,
                    delay: Duration(milliseconds: 150 * index),
                    child: _buildVideoCard(context, displayVideos[index]),
                  ),
                );
              }),
            ),

            SizedBox(height: isMobile ? 60 : 100),

            FadeInUp(
              animate: _isVisible,
              delay: const Duration(milliseconds: 800),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/video_gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C5C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 30 : 50,
                    vertical: isMobile ? 18 : 25,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  AppLocalizations.of(context)!.viewAllVideos,
                  style: AppTypography.bodyStyle(
                    context,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, dynamic video) {
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    bool isHovered = false;
    return StatefulBuilder(builder: (context, setState) {
      return MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: () => _launchUrl(video.youtubeUrl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isHovered ? 0.2 : 0.1),
                        blurRadius: isHovered ? 30 : 20,
                        offset: Offset(0, isHovered ? 15 : 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedScale(
                          duration: const Duration(milliseconds: 600),
                          scale: isHovered ? 1.05 : 1.0,
                          child: Image.network(
                            video.thumbnail,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        
                        // Dark Overlay on Hover
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: isHovered ? 0.4 : 0.2,
                          child: Container(color: Colors.black),
                        ),
                        
                        _PulsingPlayButton(isHovered: isHovered),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                video.localizedTitle(lang).toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 0.5,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.play_circle_fill, size: 14, color: Color(0xFFC89A5B)),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.youtubeDiscourse,
                    style: const TextStyle(
                      color: Color(0xFFC89A5B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _PulsingPlayButton extends StatefulWidget {
  final bool isHovered;
  const _PulsingPlayButton({required this.isHovered});

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
        // Pulsing Rings
        ...List.generate(2, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double progress = (_controller.value + index / 2) % 1.0;
              return Container(
                width: 50 + (progress * 50),
                height: 50 + (progress * 50),
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
        
        // Main Button
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: widget.isHovered ? 60 : 50,
          height: widget.isHovered ? 60 : 50,
          decoration: BoxDecoration(
            color: widget.isHovered ? const Color(0xFFC89A5B) : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(
            Icons.play_arrow_rounded, 
            size: widget.isHovered ? 36 : 30, 
            color: Colors.white
          ),
        ),
      ],
    );
  }
}
