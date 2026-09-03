import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../utils/responsive_utils.dart';
import 'user_header.dart';
import 'cart_drawer.dart';

class UserPageLayout extends StatefulWidget {
  final Widget child;
  final HomePageController controller;
  final ScrollController? scrollController;
  final bool productPage;

  const UserPageLayout({
    super.key,
    required this.child,
    required this.controller,
    this.scrollController,
    this.productPage = false,
  });

  @override
  State<UserPageLayout> createState() => _UserPageLayoutState();
}

class _UserPageLayoutState extends State<UserPageLayout> {
  late ScrollController _internalController;
  late ScrollController _activeController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _internalController = ScrollController();
    _activeController = widget.scrollController ?? _internalController;
    _activeController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_activeController.hasClients) {
      if (_activeController.offset > 800 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_activeController.offset <= 800 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    }
  }

  @override
  void dispose() {
    _activeController.removeListener(_scrollListener);
    _internalController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _activeController.animateTo(
      0, 
      duration: const Duration(milliseconds: 1000), 
      curve: Curves.easeInOutQuart
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: const CartDrawer(),
      body: SelectionArea(
        child: Stack(
          children: [
            // MAIN SCROLLABLE CONTENT
            SingleChildScrollView(
              controller: _activeController,
              child: widget.child,
            ),
  
            // FLOATING PREMIUM HEADER
            UserHeader(
              controller: widget.controller,
              scrollController: _activeController,
              productPage: widget.productPage,
              scaffoldKey: _scaffoldKey,
            ),

            // BACK TO TOP BUTTON
            Positioned(
              bottom: 40,
              right: 40,
              child: _BackToTopButton(
                show: _showBackToTop,
                onPressed: _scrollToTop,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackToTopButton extends StatefulWidget {
  final bool show;
  final VoidCallback onPressed;
  const _BackToTopButton({required this.show, required this.onPressed});

  @override
  State<_BackToTopButton> createState() => _BackToTopButtonState();
}

class _BackToTopButtonState extends State<_BackToTopButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      animate: widget.show,
      duration: const Duration(milliseconds: 400),
      child: IgnorePointer(
        ignoring: !widget.show,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: () {
              _controller.forward(from: 0.0);
              widget.onPressed();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: _isHovered ? const Color(0xFFC89A5B) : const Color(0xFF0F4C5C),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isHovered ? const Color(0xFFC89A5B) : const Color(0xFF0F4C5C)).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: RotationTransition(
                turns: _controller,
                child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

