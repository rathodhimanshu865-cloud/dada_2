import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/notification_controller.dart';
import 'notification_drawer.dart';
import '../../../models/product_model.dart';
import '../../../utils/app_typography.dart';

class ProductHeader extends StatefulWidget {
  final bool isSticky;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const ProductHeader({
    super.key,
    this.isSticky = true,
    this.scaffoldKey,
  });

  @override
  State<ProductHeader> createState() => _ProductHeaderState();
}

class _ProductHeaderState extends State<ProductHeader> {
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  Timer? _searchDebounce;
  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final productController = Provider.of<ProductController>(context, listen: false);
      productController.performSearch(query);

      if (query.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 450,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 45),
          child: Material(
            elevation: 20,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: Consumer<ProductController>(
              builder: (context, prod, child) {
                return Container(
                  constraints: const BoxConstraints(maxHeight: 500),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _buildSearchResults(prod),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(ProductController prod) {
    if (prod.isSearching) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF0F4C5C)),
            SizedBox(height: 16),
            Text('Searching sacred items...', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    if (prod.searchError != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 16),
            Text(prod.searchError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    if (prod.searchResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: Colors.grey, size: 40),
            const SizedBox(height: 16),
            Text('No matching products found.', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Try searching with a different term.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text('${prod.searchResults.length} PRODUCTS FOUND', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
        ),
        Flexible(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 12),
            shrinkWrap: true,
            itemCount: prod.searchResults.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 20, endIndent: 20),
            itemBuilder: (context, index) {
              final product = prod.searchResults[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade100)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.imageUrls.isNotEmpty 
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrls[0],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (c, e, s) => const Icon(Icons.image_outlined, color: Colors.grey),
                        )
                      : const Icon(Icons.image_outlined, color: Colors.grey),
                  ),
                ),
                title: Text(product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                subtitle: Text(product.categoryId, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${product.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F4C5C), fontSize: 14)),
                    if (!product.isActive || product.stock <= 0)
                      const Text('OUT OF STOCK', style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.bold)),
                  ],
                ),
                onTap: () {
                  _searchController.clear();
                  _removeOverlay();
                  Navigator.pushNamed(context, '/product_details', arguments: product.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _removeOverlay();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkCharcoal = Color(0xFF2B2B2B);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 2.0)),
        boxShadow: widget.isSticky ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))] : [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _navLink(context, 'Home Portal', '/product', darkCharcoal),
                  const SizedBox(width: 20),
                  _buildCatalogueDropdown(context, darkCharcoal, const Color(0xFF0F4C5C)),
                  const SizedBox(width: 20),
                  _navLink(context, 'Pu. Dada Teachings', '/teachings', darkCharcoal),
                  const SizedBox(width: 20),
                  _navLink(context, 'Track Shipment', '/track', darkCharcoal),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: CompositedTransformTarget(
                    link: _layerLink,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8), color: Colors.grey.shade50),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.search, color: Colors.grey, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Search for Malas, Keychains, Books...',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _wishlistButton(context, darkCharcoal),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationButton(BuildContext context, Color color) {
    return Consumer<NotificationController>(
      builder: (context, controller, child) {
        return InkWell(
          onTap: () => _showNotificationDrawer(context),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none_outlined, color: color, size: 22),
              if (controller.unreadCount > 0)
                Positioned(
                  right: -4, top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text('${controller.unreadCount}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const Align(
          alignment: Alignment.centerRight,
          child: NotificationDrawer(),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(anim1),
          child: child,
        );
      },
    );
  }

  Widget _wishlistButton(BuildContext context, Color color) {
    return Consumer<ProductController>(
      builder: (context, prod, child) {
        return InkWell(
          onTap: () => Navigator.pushNamed(context, '/wishlist'),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.favorite_border, color: color, size: 20),
                  if (prod.wishlistIds.isNotEmpty)
                    Positioned(
                      right: -6, top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFFC89A5B), shape: BoxShape.circle),
                        child: Text('${prod.wishlistIds.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Text('Favorites', style: AppTypography.bodyStyle(context, fontSize: 14, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCatalogueDropdown(BuildContext context, Color textColor, Color primaryColor) {
    // Icons mapping for visual consistency
    final Map<String, IconData> iconMap = {
      'keychain': Icons.vpn_key_outlined,
      'acrylic_photo_frame': Icons.crop_original,
      'temple': Icons.temple_hindu_outlined,
      'footprints_paduka': Icons.pets_outlined,
      'sticker': Icons.sticky_note_2_outlined,
      'pouch_pocket_pin': Icons.wallet_outlined,
      'rakshasutra_sacred_thread': Icons.gesture,
      'other': Icons.more_horiz_outlined,
    };

    return Consumer<ProductController>(
      builder: (context, prod, child) {
        return Theme(
          data: Theme.of(context).copyWith(hoverColor: Colors.transparent),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 45),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            color: Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Product Catalogue', style: AppTypography.bodyStyle(context, fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                padding: EdgeInsets.zero,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sacred Categories', style: AppTypography.headingStyle(context, fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                      const SizedBox(height: 20),
                      ...prod.categoryObjects.map((cat) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/catalogue', arguments: cat.id);
                          },
                          child: Row(
                            children: [
                              Icon(
                                iconMap[cat.id.toLowerCase()] ?? iconMap[cat.name.toLowerCase().replaceAll(' ', '_')] ?? Icons.category_outlined,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  cat.name,
                                  style: AppTypography.bodyStyle(context, fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2B2B2B)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/catalogue', arguments: 'all');
                          },
                          child: Text('Explore All Products >', style: AppTypography.bodyStyle(context, fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _navLink(BuildContext context, String title, String route, Color color) => InkWell(
    onTap: () { 
      // If we are already on the page, don't do anything or just popUntil home
      if (ModalRoute.of(context)?.settings.name == route) return;
      
      if (route == '/product') {
        // Going to home portal: pop everything related to products and go to /product
        Navigator.pushNamedAndRemoveUntil(context, '/product', (route) => route.settings.name == '/');
      } else {
        Navigator.pushNamed(context, route); 
      }
    }, 
    child: Text(title, style: AppTypography.bodyStyle(context, fontSize: 14, fontWeight: FontWeight.w600, color: color))
  );

  Widget _cartButton(BuildContext context, Color color) {
    return Consumer<CartController>(
      builder: (context, cart, child) => InkWell(
        onTap: () {
          if (widget.scaffoldKey?.currentState != null) {
            widget.scaffoldKey!.currentState!.openEndDrawer();
          } else {
            Scaffold.of(context).openEndDrawer();
          }
        },
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.shopping_cart_outlined, color: color, size: 22),
                if (cart.totalItems > 0)
                  Positioned(
                    right: -6, top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF111111), shape: BoxShape.circle),
                      child: Text('${cart.totalItems}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Text('Cart', style: AppTypography.bodyStyle(context, fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
