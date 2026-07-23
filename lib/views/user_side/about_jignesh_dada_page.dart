import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import '../../utils/app_typography.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';

class AboutJigneshDadaPage extends StatefulWidget {
  const AboutJigneshDadaPage({super.key});

  @override
  State<AboutJigneshDadaPage> createState() => _AboutJigneshDadaPageState();
}

class _AboutJigneshDadaPageState extends State<AboutJigneshDadaPage> {
  final List<GlobalKey> _chapterKeys = [];
  int _activeChapterIndex = 0;

  // Theme Constants
  final Color textSlate = const Color(0xFF1A1A1A);
  final Color accentGold = const Color(0xFFC19A6B);
  final Color softBeige = const Color(0xFFF9F3EA);
  final Color primaryTeal = const Color(0xFF0F4C5C);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    final data = controller.aboutDadaPage;
    final lang = Provider.of<LanguageController>(context).locale.languageCode;

    if (_chapterKeys.length != data.phases.length) {
      _chapterKeys.clear();
      for (int i = 0; i < data.phases.length; i++) {
        _chapterKeys.add(GlobalKey());
      }
    }

    final bool isDesktop = MediaQuery.of(context).size.width > 1100;

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          _buildAsymmetricalHero(data, isDesktop, lang),
          _buildGoldenDivider(),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 15, vertical: isDesktop ? 80 : 40),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDesktop)
                      SizedBox(
                        width: 250,
                        child: _buildStickyIndex(data.phases, lang),
                      ),
                    
                    Expanded(
                      child: Column(
                        children: data.phases.asMap().entries.map((entry) {
                          return _buildChapterSegment(
                            key: _chapterKeys[entry.key],
                            phase: entry.value,
                            isDesktop: isDesktop,
                            index: entry.key,
                            lang: lang,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _buildAsymmetricalHero(AboutDadaPageData data, bool isDesktop, String lang) {
    final title = data.localizedHeroTitle(lang);
    final subtitle = data.localizedHeroSubtitle(lang);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 24, vertical: 60),
      child: Flex(
        direction: isDesktop ? Axis.horizontal : Axis.vertical,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FadeIn(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    title.isEmpty ? "PUJYA JIGNESH DADA" : title,
                    style: AppTypography.headingStyle(
                      context,
                      fontSize: AppTypography.getResponsiveSize(context, desktop: 72, tablet: 40, mobile: 34),
                      fontWeight: FontWeight.w700,
                      color: textSlate,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    subtitle.isEmpty ? "Spiritual Leader & Scholar" : subtitle,
                    style: AppTypography.bodyStyle(
                      context,
                      fontSize: AppTypography.getResponsiveSize(context, desktop: 22, tablet: 20, mobile: 18),
                      fontWeight: FontWeight.w600,
                      color: accentGold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(height: 1, width: 80, color: accentGold),
              ],
            ),
          ),
          if (isDesktop) const SizedBox(width: 60),
          Expanded(
            flex: 5,
            child: Container(
              height: isDesktop ? 600 : 400,
              decoration: BoxDecoration(color: softBeige, borderRadius: BorderRadius.circular(4)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: data.heroImage.isNotEmpty
                    ? Image.network(data.heroImage, fit: BoxFit.contain)
                    : const Icon(Icons.person, size: 100, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldenDivider() {
    return Container(
      width: double.infinity,
      height: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, accentGold.withOpacity(0.5), accentGold, accentGold.withOpacity(0.5), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildStickyIndex(List<BiographyPhase> phases, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: phases.asMap().entries.map((entry) {
        bool isActive = entry.key == _activeChapterIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            "${(entry.key + 1).toString().padLeft(2, '0')} ${entry.value.localizedTitle(lang).toUpperCase()}",
            style: AppTypography.bodyStyle(
              context,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? accentGold : textSlate.withOpacity(0.5),
              letterSpacing: 1.5,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChapterSegment({required GlobalKey key, required BiographyPhase phase, required bool isDesktop, required int index, required String lang}) {
    return Container(
      key: key,
      padding: EdgeInsets.only(bottom: 120, left: isDesktop ? 60 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phase.localizedTitle(lang),
            style: AppTypography.headingStyle(
              context,
              fontSize: AppTypography.getResponsiveSize(context, desktop: 42, tablet: 34, mobile: 28),
              fontWeight: FontWeight.w700,
              color: textSlate,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            phase.localizedContent(lang),
            style: AppTypography.bodyStyle(
              context,
              fontSize: AppTypography.getResponsiveSize(context, desktop: 17, tablet: 16, mobile: 15),
              height: 1.8,
              color: textSlate.withOpacity(0.8),
            ),
          ),
          if (phase.images.isNotEmpty) ...[
            const SizedBox(height: 60),
            _buildStaggeredMedia(phase.images, isDesktop),
          ],
        ],
      ),
    );
  }


  Widget _buildStaggeredMedia(List<String> images, bool isDesktop) {
    return Wrap(
      spacing: 30,
      runSpacing: 30,
      children: images.map((url) => Container(
        width: isDesktop ? 400 : double.infinity,
        decoration: BoxDecoration(color: softBeige, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 15))]),
        child: Image.network(url, fit: BoxFit.contain),
      )).toList(),
    );
  }
}

class _FadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _FadeIn({required this.child, this.delay = Duration.zero});

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: SlideTransition(position: _slide, child: widget.child));
  }
}
