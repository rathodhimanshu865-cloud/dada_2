import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import 'user_header.dart';
import 'product_header.dart';
import 'user_footer.dart';
import 'cart_drawer.dart';

class ProductCartLayout extends StatefulWidget {
  final Widget child;
  final HomePageController controller;
  final ScrollController? scrollController;

  const ProductCartLayout({
    super.key,
    required this.child,
    required this.controller,
    this.scrollController,
  });

  @override
  State<ProductCartLayout> createState() => _ProductCartLayoutState();
}

class _ProductCartLayoutState extends State<ProductCartLayout> {
  late ScrollController _internalController;
  late ScrollController _activeController;
  double _scrollOffset = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _internalController = ScrollController();
    _activeController = widget.scrollController ?? _internalController;
    _activeController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (mounted) {
      setState(() {
        _scrollOffset = _activeController.offset;
      });
    }
  }

  @override
  void dispose() {
    _activeController.removeListener(_scrollListener);
    if (widget.scrollController == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Header 1 height is approx 95px based on UserHeader code
    double header1Height = 95.0;
    double header2Top = (header1Height - _scrollOffset).clamp(0.0, header1Height);
    bool isSticky = _scrollOffset >= header1Height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: const CartDrawer(),
      body: Stack(
        children: [
          // Content
          SingleChildScrollView(
            controller: _activeController,
            child: Column(
              children: [
                // Spacer for both headers so content starts below them
                const SizedBox(height: 95 + 64), 
                widget.child,
                UserFooter(controller: widget.controller),
              ],
            ),
          ),
          
          // Header 2 (Product Header)
          Positioned(
            top: header2Top,
            left: 0,
            right: 0,
            child: ProductHeader(isSticky: isSticky, scaffoldKey: _scaffoldKey),
          ),

          // Header 1 (Main Default Header)
          UserHeader(
            controller: widget.controller,
            scrollController: _activeController,
            productPage: true, // This enables the scroll-away behavior inside UserHeader
            scaffoldKey: _scaffoldKey,
          ),
        ],
      ),
    );
  }
}
