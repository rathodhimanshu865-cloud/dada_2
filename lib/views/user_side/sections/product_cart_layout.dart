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
  final List<Widget>? slivers; 

  const ProductCartLayout({
    super.key,
    required this.child,
    required this.controller,
    this.scrollController,
    this.slivers,
  });

  @override
  State<ProductCartLayout> createState() => _ProductCartLayoutState();
}

class _ProductCartLayoutState extends State<ProductCartLayout> {
  late ScrollController _internalController;
  late ScrollController _activeController;
  
  // Use ValueNotifier for performance (rebuilds only what's needed)
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0.0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _internalController = ScrollController();
    _activeController = widget.scrollController ?? _internalController;
    _activeController.addListener(_scrollListener);
  }

  void _scrollListener() {
    _scrollOffset.value = _activeController.offset;
  }

  @override
  void dispose() {
    _activeController.removeListener(_scrollListener);
    _scrollOffset.dispose();
    if (widget.scrollController == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double header1Height = 95.0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: const CartDrawer(),
      body: Stack(
        children: [
          // Content
          CustomScrollView(
            controller: _activeController,
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 95 + 64)),
              if (widget.slivers != null) 
                ...widget.slivers!
              else 
                SliverToBoxAdapter(child: widget.child),
              SliverToBoxAdapter(child: UserFooter(controller: widget.controller)),
            ],
          ),
          
          // Header 2 (Product Header) - Optimized with ValueListenableBuilder
          ValueListenableBuilder<double>(
            valueListenable: _scrollOffset,
            builder: (context, offset, child) {
              double top = (header1Height - offset).clamp(0.0, header1Height);
              bool isSticky = offset >= header1Height;
              return Positioned(
                top: top,
                left: 0,
                right: 0,
                child: ProductHeader(isSticky: isSticky, scaffoldKey: _scaffoldKey),
              );
            },
          ),

          // Header 1 (Main Default Header)
          UserHeader(
            controller: widget.controller,
            scrollController: _activeController,
            productPage: true, 
            scaffoldKey: _scaffoldKey,
          ),
        ],
      ),
    );
  }
}
