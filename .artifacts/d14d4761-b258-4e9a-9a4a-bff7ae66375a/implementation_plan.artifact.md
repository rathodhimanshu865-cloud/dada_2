# Product Catalog & Cart Drawer Animation Plan

This plan details the premium UI/UX enhancements for the Product Catalog (`CataloguePage`) and the Cart Drawer (`CartDrawer`), focusing on smooth filtering, staggered grids, and tactile feedback.

## Proposed Changes

### 1. Full Catalog Page [MODIFY] [catalogue_page.dart](file:///D:/dada_2/lib/views/user_side/catalogue_page.dart)
- **Sticky Filter Bar**:
    - Implement a `SliverPersistentHeader` to make the category/filter bar sticky.
    - Add a background blur and subtle shadow that fades in as it sticks.
- **Product Grid Reveal**:
    - Staggered entrance for product cards (`FadeInUp` with incremental delays).
    - On filter/sort change: Current items fade/scale out (150ms) before the new set enters.

### 2. Enhanced Product Card [MODIFY] [product_card.dart](file:///D:/dada_2/lib/views/user_side/sections/product_card.dart)
- **Image Hover Swap**: Crossfade to the second image in `product.imageUrls` on hover (if available).
- **Interactive UI**:
    - "Quick View" button slides up from the bottom edge on hover.
    - Card lifts by 4px with an expanded shadow bloom.
    - Mobile: Tap feedback via `AnimatedScale`.

### 3. Quick View Modal [MODIFY] [product_quick_view.dart](file:///D:/dada_2/lib/views/user_side/sections/product_quick_view.dart)
- **Positioned Entrance**: Animate scale+fade-in from the card's general position.
- **Micro-Interactions**: Thumbnails crossfade the main image on selection.

### 4. Cart Drawer [MODIFY] [cart_drawer.dart](file:///D:/dada_2/lib/views/user_side/sections/cart_drawer.dart)
- **Entrance**: Slide-in from right (100% -> 0) with backdrop fade.
- **Staggered Items**: Cart items slide in one by one.
- **Tactile Feedback**: Quantity +/- buttons scale down (0.9x) on tap.
- **Removal Animation**: Items slide out to the right and collapse their height smoothly.

## Verification Plan

### Manual Verification
- Navigate to the Full Catalog.
- Scroll down to verify the sticky filter bar behavior.
- Change a category and observe the smooth exit/entrance of product cards.
- Hover over products to test image swapping and the "Quick View" button.
- Open the Cart Drawer: check for staggered item entrance.
- Test removing a cart item and verify the smooth height collapse.
