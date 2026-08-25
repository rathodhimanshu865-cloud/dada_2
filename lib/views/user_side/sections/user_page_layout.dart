import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
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

  @override
  void initState() {
    super.initState();
    _internalController = ScrollController();
    _activeController = widget.scrollController ?? _internalController;
  }

  @override
  void dispose() {
    _internalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: const CartDrawer(),
      body: Stack(
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
        ],
      ),
    );
  }
}
