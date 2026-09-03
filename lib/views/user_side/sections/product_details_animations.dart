import 'dart:math';
import 'package:flutter/material.dart';

// --- BREADCRUMB ---
class HoverUnderlineText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final VoidCallback? onTap;

  const HoverUnderlineText({super.key, required this.text, required this.style, this.onTap});

  @override
  State<HoverUnderlineText> createState() => _HoverUnderlineTextState();
}

class _HoverUnderlineTextState extends State<HoverUnderlineText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Text(widget.text, style: widget.style),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 1,
                width: _isHovered ? null : 0,
                color: widget.style.color ?? Colors.black,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _isHovered ? 1.0 : 0.0,
                  alignment: Alignment.centerLeft,
                  child: Container(color: widget.style.color ?? Colors.black, height: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- DESKTOP ZOOM LENS ---
class ZoomableImageDesktop extends StatefulWidget {
  final String imageUrl;
  final Widget childWidget;

  const ZoomableImageDesktop({
    super.key,
    required this.imageUrl,
    required this.childWidget,
  });

  @override
  State<ZoomableImageDesktop> createState() => _ZoomableImageDesktopState();
}

class _ZoomableImageDesktopState extends State<ZoomableImageDesktop> {
  double _x = 0.5;
  double _y = 0.5;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      onHover: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final size = box.size;
        final localPos = details.localPosition;
        setState(() {
          _x = (localPos.dx / size.width).clamp(0.0, 1.0);
          _y = (localPos.dy / size.height).clamp(0.0, 1.0);
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AnimatedScale(
          scale: _isHovering ? 2.5 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          alignment: Alignment(_x * 2 - 1, _y * 2 - 1),
          child: widget.childWidget,
        ),
      ),
    );
  }
}

// --- SEQUENTIAL STARS ---
class AnimatedSequentialStars extends StatefulWidget {
  final double rating;
  final double size;
  final MainAxisAlignment alignment;

  const AnimatedSequentialStars({super.key, required this.rating, this.size = 18, this.alignment = MainAxisAlignment.start});

  @override
  State<AnimatedSequentialStars> createState() => _AnimatedSequentialStarsState();
}

class _AnimatedSequentialStarsState extends State<AnimatedSequentialStars> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.alignment,
      children: List.generate(5, (index) {
        final start = (index * 0.1).clamp(0.0, 1.0);
        final end = (start + 0.2).clamp(0.0, 1.0);
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        );

        return ScaleTransition(
          scale: animation,
          child: Icon(
            index < widget.rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: widget.size,
          ),
        );
      }),
    );
  }
}

// --- PRICE STRIKE THROUGH ---
class StrikeThroughPrice extends StatefulWidget {
  final double price;
  final TextStyle style;

  const StrikeThroughPrice({super.key, required this.price, required this.style});

  @override
  State<StrikeThroughPrice> createState() => _StrikeThroughPriceState();
}

class _StrikeThroughPriceState extends State<StrikeThroughPrice> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    Future.delayed(const Duration(milliseconds: 400), () {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _StrikePainter(progress: _controller.value, color: widget.style.color ?? Colors.grey),
          child: Text('₹${widget.price.toInt()}', style: widget.style.copyWith(decoration: TextDecoration.none)),
        );
      },
    );
  }
}

class _StrikePainter extends CustomPainter {
  final double progress;
  final Color color;

  _StrikePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width * progress, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _StrikePainter oldDelegate) => oldDelegate.progress != progress;
}

// --- QUANTITY STEPPER ---
class AnimatedQuantityNumber extends StatelessWidget {
  final int quantity;

  const AnimatedQuantityNumber({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.5),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text(
        '$quantity',
        key: ValueKey<int>(quantity),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

// --- ADD TO CART BUTTON WITH LOADING/SUCCESS ---
class AddToCartButton extends StatefulWidget {
  final Future<void> Function() onAddToCart;
  final String label;
  final String successLabel;
  final double price;
  final Color backgroundColor;
  final bool disabled;

  const AddToCartButton({
    super.key,
    required this.onAddToCart,
    required this.label,
    required this.successLabel,
    required this.price,
    required this.backgroundColor,
    this.disabled = false,
  });

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  int _state = 0; // 0 = idle, 1 = loading, 2 = success

  void _handlePress() async {
    if (_state != 0 || widget.disabled) return;
    setState(() => _state = 1);
    await widget.onAddToCart();
    if (mounted) {
      setState(() => _state = 2);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _state = 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handlePress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: widget.disabled ? Colors.grey.shade400 : (_state == 2 ? Colors.green : widget.backgroundColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _state == 0
                ? Text(
                    widget.disabled ? widget.label : '${widget.label.toUpperCase()} • ₹${widget.price.toInt()}',
                    key: const ValueKey('idle'),
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13, letterSpacing: 1),
                  )
                : _state == 1
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        key: const ValueKey('success'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(widget.successLabel, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13)),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

// --- PULSING BUY NOW BUTTON ---
class PulsingBuyNowButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final Color backgroundColor;

  const PulsingBuyNowButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.backgroundColor,
  });

  @override
  State<PulsingBuyNowButton> createState() => _PulsingBuyNowButtonState();
}

class _PulsingBuyNowButtonState extends State<PulsingBuyNowButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    if (widget.onPressed != null) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PulsingBuyNowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed == null) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
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
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: widget.backgroundColor.withOpacity(_controller.value * 0.4),
                      blurRadius: 15 * _controller.value,
                      spreadRadius: 2 * _controller.value,
                    )
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.backgroundColor,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Center(
              child: Text(
                widget.label.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13, letterSpacing: 1.5),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- HELPFUL THUMBS UP ---
class HelpfulThumbsUp extends StatefulWidget {
  const HelpfulThumbsUp({super.key});

  @override
  State<HelpfulThumbsUp> createState() => _HelpfulThumbsUpState();
}

class _HelpfulThumbsUpState extends State<HelpfulThumbsUp> with SingleTickerProviderStateMixin {
  int _count = 12;
  bool _isHelpful = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isHelpful = !_isHelpful;
      if (_isHelpful) {
        _count++;
        _controller.forward(from: 0);
      } else {
        _count--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.elasticOut)).animate(_controller),
            child: Icon(
              _isHelpful ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
              size: 16,
              color: _isHelpful ? Colors.blue : Colors.grey,
            ),
          ),
          const SizedBox(width: 4),
          Text('$_count', style: TextStyle(fontSize: 12, color: _isHelpful ? Colors.blue : Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --- SACRED DIVIDER ---
class SacredDivider extends StatefulWidget {
  final Color? color;
  const SacredDivider({super.key, this.color});

  @override
  State<SacredDivider> createState() => _SacredDividerState();
}

class _SacredDividerState extends State<SacredDivider> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = widget.color ?? const Color(0xFFC89A5B);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: gold.withOpacity(0.15))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Icon(
                Icons.auto_awesome, 
                size: 24, 
                color: gold.withOpacity(0.3 + (0.4 * _pulse.value)),
                shadows: [Shadow(color: gold.withOpacity(0.5 * _pulse.value), blurRadius: 10 * _pulse.value)],
              );
            }
          ),
        ),
        Expanded(child: Container(height: 1, color: gold.withOpacity(0.15))),
      ],
    );
  }
}

