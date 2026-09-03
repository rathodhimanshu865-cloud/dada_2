// SITE-WIDE DESIGN SYSTEM — Shared Interaction Primitives
//
// ALL pages must import this file and use these canonical widgets
// rather than implementing their own versions.  This guarantees that
// filter tabs, card entrances, button feedback, and lightbox transitions
// feel identical everywhere on the site.
//
// Rules:
//   • Devotional / content pages  → full motion budget
//   • Utility / functional pages  → use [SiteCardEntrance] with
//     reducedMotion:true  and NO hover-lift on form elements.
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS — single source of truth for all motion timings & colours
// ─────────────────────────────────────────────────────────────────────────────
class SiteTokens {
  SiteTokens._();

  // Colours
  static const Color primaryTeal = Color(0xFF0F4C5C);
  static const Color goldAccent  = Color(0xFFC89A5B);
  static const Color bgBeige     = Color(0xFFF9F3EA);

  // Card entrance
  static const Duration cardEntranceDuration = Duration(milliseconds: 600);
  static const int     cardStaggerMs         = 70; // 60–80ms per spec

  // Filter tab underline
  static const Duration tabUnderlineDuration = Duration(milliseconds: 280);
  static const double  tabUnderlineWidth     = 36;

  // Button press scale
  static const double btnPressScale   = 0.965;
  static const Duration btnPressDur   = Duration(milliseconds: 80);
  static const Duration btnReleaseDur = Duration(milliseconds: 180);

  // Button / card hover lift
  static const double hoverTranslateY = -4.0; // -3px to -6px per spec, mid point
  static const Duration hoverDuration = Duration(milliseconds: 220);

  // Lightbox / modal open
  static const Duration lightboxOpenDur  = Duration(milliseconds: 320);
  static const Duration lightboxCloseDur = Duration(milliseconds: 220);
  static const double   lightboxScaleIn  = 0.94; // starts at 94%, scales to 100%
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. SITE FILTER TAB BAR
//    Identical sliding-underline system used on every filter / category tab.
// ─────────────────────────────────────────────────────────────────────────────
class SiteFilterTabBar extends StatelessWidget {
  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  /// Set to true on utility pages for slightly smaller text / no letter-spacing
  final bool compact;

  const SiteFilterTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (i) {
          final bool isActive = activeIndex == i;
          return GestureDetector(
            onTap: () => onTabSelected(i),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 14 : 18,
                vertical: 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tabs[i].toUpperCase(),
                    style: TextStyle(
                      color: isActive
                          ? SiteTokens.primaryTeal
                          : Colors.grey.shade500,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.w500,
                      fontSize: compact ? 12 : 13,
                      letterSpacing: compact ? 1.0 : 1.5,
                    ),
                  ),
                  const SizedBox(height: 7),
                  AnimatedContainer(
                    duration: SiteTokens.tabUnderlineDuration,
                    curve: Curves.easeInOut,
                    height: 2,
                    width: isActive ? SiteTokens.tabUnderlineWidth : 0,
                    decoration: BoxDecoration(
                      color: SiteTokens.goldAccent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. SITE CARD ENTRANCE
//    Wraps any card widget with the canonical staggered fade+translateY entrance.
//    Pass [reducedMotion:true] on utility pages (Track Shipment, Orders etc.)
//    to keep motion minimal and trust-building.
// ─────────────────────────────────────────────────────────────────────────────
class SiteCardEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final bool animate;
  final bool reducedMotion;

  const SiteCardEntrance({
    super.key,
    required this.child,
    required this.index,
    this.animate = true,
    this.reducedMotion = false,
  });

  @override
  State<SiteCardEntrance> createState() => _SiteCardEntranceState();
}

class _SiteCardEntranceState extends State<SiteCardEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.reducedMotion
          ? const Duration(milliseconds: 200)
          : SiteTokens.cardEntranceDuration,
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.7, curve: Curves.easeOut)),
    );
    _slide = Tween<double>(begin: widget.reducedMotion ? 4 : 18, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.8, curve: Curves.easeOutCubic)),
    );

    if (widget.animate) {
      Future.delayed(Duration(milliseconds: widget.index * SiteTokens.cardStaggerMs), () {
        if (mounted) _ctrl.forward();
      });
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. SITE PRESSABLE BUTTON / HOVER LIFT
//    Canonical tap-feedback (scale 0.965 on press) + hover-lift (-4px + shadow).
//    Wrap any tappable surface — cards, buttons, icons — with this widget.
// ─────────────────────────────────────────────────────────────────────────────
class SitePressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  /// Disable hover-lift on functional/utility page elements
  final bool enableHoverLift;
  final bool enableShadowBloom;

  const SitePressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.enableHoverLift = true,
    this.enableShadowBloom = true,
  });

  @override
  State<SitePressable> createState() => _SitePressableState();
}

class _SitePressableState extends State<SitePressable>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _isPressed ? SiteTokens.btnPressScale : 1.0;
    final double ty = widget.enableHoverLift && _isHovered && !_isPressed
        ? SiteTokens.hoverTranslateY
        : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: _isPressed ? SiteTokens.btnPressDur : SiteTokens.btnReleaseDur,
          curve: _isPressed ? Curves.easeIn : Curves.easeOut,
          transform: Matrix4.identity()
            ..scale(scale)
            ..translate(0.0, ty),
          transformAlignment: Alignment.center,
          decoration: widget.enableShadowBloom && _isHovered && !_isPressed
              ? BoxDecoration(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: SiteTokens.primaryTeal.withOpacity(0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                )
              : const BoxDecoration(),
          child: widget.child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. SITE LIGHTBOX ROUTE
//    Shared open/close transition: scale 0.94→1.0 + fade, applies to all
//    fullscreen modals (Photo Gallery, Quick View, Video player, Katha).
// ─────────────────────────────────────────────────────────────────────────────
class SiteLightboxRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  SiteLightboxRoute({required this.builder})
      : super(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.92),
          transitionDuration: SiteTokens.lightboxOpenDur,
          reverseTransitionDuration: SiteTokens.lightboxCloseDur,
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: SiteTokens.lightboxScaleIn,
                  end: 1.0,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. SITE ELEVATED BUTTON
//    A drop-in replacement for ElevatedButton that bakes in the canonical
//    press-scale + hover-lift across all CTAs on every page.
// ─────────────────────────────────────────────────────────────────────────────
class SiteElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  /// Set false on utility pages (Track Shipment, Auth forms) for calmer feel.
  final bool enableHoverLift;

  const SiteElevatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.enableHoverLift = true,
  });

  @override
  Widget build(BuildContext context) {
    return SitePressable(
      onTap: onPressed,
      borderRadius: borderRadius,
      enableHoverLift: enableHoverLift,
      enableShadowBloom: enableHoverLift,
      child: Material(
        color: backgroundColor ?? SiteTokens.primaryTeal,
        borderRadius: borderRadius,
        elevation: 0,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          splashColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: padding,
            child: DefaultTextStyle(
              style: TextStyle(
                color: foregroundColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. SITE ICON BUTTON
//    Canonical share / action icon with scale+rotate hover used on
//    Teachings, Stotra, News and any other page with icon interactions.
// ─────────────────────────────────────────────────────────────────────────────
class SiteIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final double size;
  final String? tooltip;

  const SiteIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.size = 22,
    this.tooltip,
  });

  @override
  State<SiteIconButton> createState() => _SiteIconButtonState();
}

class _SiteIconButtonState extends State<SiteIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget btn = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.15 : 1.0)
            ..rotateZ(_isHovered ? 0.05 : 0.0),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered
                ? (widget.color ?? SiteTokens.goldAccent).withOpacity(0.12)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: _isHovered
                ? (widget.color ?? SiteTokens.goldAccent)
                : Colors.grey.shade500,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: btn);
    }
    return btn;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. SITE GRID SWITCHER
//    Wraps a filter-gated grid with the correct AnimatedSwitcher transition.
//    Use this any time the content changes on tab switch.
// ─────────────────────────────────────────────────────────────────────────────
class SiteGridSwitcher extends StatelessWidget {
  final Widget child;

  const SiteGridSwitcher({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. SITE ORDER TIMELINE
//    Animated order-progress tracker shared by Track Shipment and My Orders.
//    Pass [status] matching the order model's orderStatus string.
//    Steps are: Placed → Processing → Shipped → Delivered (Cancelled = greyed).
//    Adapts automatically between horizontal (desktop) and vertical (mobile).
// ─────────────────────────────────────────────────────────────────────────────
class SiteOrderTimeline extends StatelessWidget {
  final String status;
  final bool isMobile;

  const SiteOrderTimeline({
    super.key,
    required this.status,
    required this.isMobile,
  });

  static int _statusIndex(String status) {
    switch (status) {
      case 'Placed':      return 0;
      case 'Processing':  return 1;
      case 'Shipped':     return 2;
      case 'Delivered':   return 3;
      case 'Cancelled':   return -1;
      default:            return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mappedIndex = _statusIndex(status);
    final List<String> steps = ['Placed', 'Processing', 'Shipped', 'Delivered'];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (i) {
          final isCompleted = mappedIndex >= 0 && i <= mappedIndex;
          final isActive    = i == mappedIndex;
          final isLast      = i == steps.length - 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SiteOrderNodeMobile(
                index: i + 1,
                title: steps[i],
                isCompleted: isCompleted,
                isActive: isActive,
                delayMs: i * 200,
              ),
              if (!isLast)
                _SiteOrderConnectorMobile(
                  isCompleted: mappedIndex >= 0 && i < mappedIndex,
                  delayMs: (i * 200) + 100,
                ),
            ],
          );
        }),
      );
    }

    return Row(
      children: List.generate(steps.length, (i) {
        final isCompleted = mappedIndex >= 0 && i <= mappedIndex;
        final isActive    = i == mappedIndex;
        final isLast      = i == steps.length - 1;

        final node = _SiteOrderNode(
          index: i + 1,
          title: steps[i],
          isCompleted: isCompleted,
          isActive: isActive,
          delayMs: i * 200,
        );

        if (isLast) return Expanded(child: node);

        return Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(child: node),
              Expanded(
                child: _SiteOrderConnector(
                  isCompleted: mappedIndex >= 0 && i < mappedIndex,
                  delayMs: (i * 200) + 100,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Desktop node ──────────────────────────────────────────────────────────────
class _SiteOrderNode extends StatefulWidget {
  final int index;
  final String title;
  final bool isCompleted;
  final bool isActive;
  final int delayMs;

  const _SiteOrderNode({
    required this.index,
    required this.title,
    required this.isCompleted,
    required this.isActive,
    required this.delayMs,
  });

  @override
  State<_SiteOrderNode> createState() => _SiteOrderNodeState();
}

class _SiteOrderNodeState extends State<_SiteOrderNode>
    with SingleTickerProviderStateMixin {
  bool _showFill = false;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2));
    if (widget.isCompleted) {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) setState(() => _showFill = true);
        if (widget.isActive && mounted) _pulseCtrl.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (context, _) {
            final glow = widget.isActive ? _pulseCtrl.value : 0.0;
            return Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  if (widget.isActive)
                    BoxShadow(
                      color: SiteTokens.primaryTeal.withOpacity(glow * 0.4),
                      blurRadius: 10 * glow,
                      spreadRadius: 4 * glow,
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100),
                    child: Center(
                      child: Text('${widget.index}',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: _showFill ? 32 : 0,
                    height: _showFill ? 32 : 0,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: SiteTokens.primaryTeal),
                  ),
                  if (_showFill)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 300),
                      builder: (_, v, _) => CustomPaint(
                        size: const Size(16, 16),
                        painter: SiteCheckmarkPainter(
                            progress: v, color: Colors.white),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                widget.isCompleted ? FontWeight.bold : FontWeight.normal,
            color:
                widget.isCompleted ? Colors.black87 : Colors.grey.shade400,
          ),
          child: Text(widget.title, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

// ── Desktop connector ────────────────────────────────────────────────────────
class _SiteOrderConnector extends StatefulWidget {
  final bool isCompleted;
  final int delayMs;

  const _SiteOrderConnector(
      {required this.isCompleted, required this.delayMs});

  @override
  State<_SiteOrderConnector> createState() => _SiteOrderConnectorState();
}

class _SiteOrderConnectorState extends State<_SiteOrderConnector> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.isCompleted) {
      Future.delayed(Duration(milliseconds: widget.delayMs),
          () { if (mounted) setState(() => _progress = 1.0); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(2)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          height: 4,
          width: _progress > 0 ? double.infinity : 0,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progress,
            child: Container(
              decoration: BoxDecoration(
                  color: SiteTokens.primaryTeal,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mobile node ───────────────────────────────────────────────────────────────
class _SiteOrderNodeMobile extends StatefulWidget {
  final int index;
  final String title;
  final bool isCompleted;
  final bool isActive;
  final int delayMs;

  const _SiteOrderNodeMobile({
    required this.index,
    required this.title,
    required this.isCompleted,
    required this.isActive,
    required this.delayMs,
  });

  @override
  State<_SiteOrderNodeMobile> createState() => _SiteOrderNodeMobileState();
}

class _SiteOrderNodeMobileState extends State<_SiteOrderNodeMobile>
    with SingleTickerProviderStateMixin {
  bool _showFill = false;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2));
    if (widget.isCompleted) {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) setState(() => _showFill = true);
        if (widget.isActive && mounted) _pulseCtrl.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (context, _) {
            final glow = widget.isActive ? _pulseCtrl.value : 0.0;
            return Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  if (widget.isActive)
                    BoxShadow(
                      color: SiteTokens.primaryTeal.withOpacity(glow * 0.4),
                      blurRadius: 10 * glow,
                      spreadRadius: 4 * glow,
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100),
                    child: Center(
                      child: Text('${widget.index}',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: _showFill ? 24 : 0,
                    height: _showFill ? 24 : 0,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: SiteTokens.primaryTeal),
                  ),
                  if (_showFill)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 300),
                      builder: (_, v, _) => CustomPaint(
                        size: const Size(12, 12),
                        painter: SiteCheckmarkPainter(
                            progress: v,
                            color: Colors.white,
                            strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 14,
            fontWeight:
                widget.isCompleted ? FontWeight.bold : FontWeight.normal,
            color:
                widget.isCompleted ? Colors.black87 : Colors.grey.shade400,
          ),
          child: Text(widget.title),
        ),
      ],
    );
  }
}

// ── Mobile connector ──────────────────────────────────────────────────────────
class _SiteOrderConnectorMobile extends StatefulWidget {
  final bool isCompleted;
  final int delayMs;

  const _SiteOrderConnectorMobile(
      {required this.isCompleted, required this.delayMs});

  @override
  State<_SiteOrderConnectorMobile> createState() =>
      _SiteOrderConnectorMobileState();
}

class _SiteOrderConnectorMobileState
    extends State<_SiteOrderConnectorMobile> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.isCompleted) {
      Future.delayed(Duration(milliseconds: widget.delayMs),
          () { if (mounted) setState(() => _progress = 1.0); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 30,
      margin: const EdgeInsets.only(left: 13, top: 4, bottom: 4),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(2)),
      child: Align(
        alignment: Alignment.topCenter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: 4,
          child: FractionallySizedBox(
            alignment: Alignment.topCenter,
            heightFactor: _progress,
            child: Container(
              decoration: BoxDecoration(
                  color: SiteTokens.primaryTeal,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Checkmark painter (now public — shared by all order nodes) ────────────────
class SiteCheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  const SiteCheckmarkPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 2.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.45, size.height * 0.75)
      ..lineTo(size.width * 0.85, size.height * 0.25);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    canvas.drawPath(
        metrics.first.extractPath(0, metrics.first.length * progress), paint);
  }

  @override
  bool shouldRepaint(SiteCheckmarkPainter old) => old.progress != progress;
}
