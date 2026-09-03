import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:animate_do/animate_do.dart';
import '../../../utils/app_typography.dart';

class UserStatsSection extends StatefulWidget {
  const UserStatsSection({super.key});

  @override
  State<UserStatsSection> createState() => _UserStatsSectionState();
}

class _UserStatsSectionState extends State<UserStatsSection> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;

    return VisibilityDetector(
      key: const Key('user-stats-section'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3 && !_isVisible) {
          setState(() => _isVisible = true);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isMobile ? 80 : 120, horizontal: isMobile ? 20 : 40),
        decoration: const BoxDecoration(
          color: Color(0xFF0F4C5C),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: isMobile ? 40 : 80,
              runSpacing: 40,
              children: [
                _buildStatItem(context, "200+", "Kathas Delivered", 200, _isVisible, 0),
                _buildStatItem(context, "10k+", "Devoted Followers", 10, _isVisible, 1, suffix: "k+"),
                _buildStatItem(context, "50+", "Sacred Locations", 50, _isVisible, 2),
                _buildStatItem(context, "25+", "Years of Service", 25, _isVisible, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String subtitle, int targetValue, bool animate, int index, {String suffix = "+"}) {
    return FadeInUp(
      animate: animate,
      delay: Duration(milliseconds: 200 * index),
      child: Column(
        children: [
          _CountUpText(
            targetValue: targetValue,
            animate: animate,
            suffix: suffix,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Color(0xFFC89A5B),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 2, width: 30, color: const Color(0xFFC89A5B).withOpacity(0.3)),
        ],
      ),
    );
  }
}

class _CountUpText extends StatefulWidget {
  final int targetValue;
  final bool animate;
  final String suffix;
  final TextStyle style;

  const _CountUpText({
    required this.targetValue,
    required this.animate,
    required this.suffix,
    required this.style,
  });

  @override
  State<_CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<_CountUpText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = IntTween(begin: 0, end: widget.targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
  }

  @override
  void didUpdateWidget(_CountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          "${_animation.value}${widget.suffix}",
          style: widget.style,
        );
      },
    );
  }
}
