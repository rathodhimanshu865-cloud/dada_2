# Store Home Portal Animation Plan

This plan details the UI/UX improvements for the Product Store Home page (`ProductHomePage`) with cinematic entry animations, interactive category tiles, and dynamic product cards.

## Proposed Changes

### 1. Store Hero/Banner [MODIFY] [product_home_page.dart](file:///D:/dada_2/lib/views/user_side/product_home_page.dart)
- **Entrance**: Implement a fade-in and scale-up animation (`opacity 0 -> 1`, `scale 0.96 -> 1.0`) on page load.
- **Content Reveal**: Stagger the entrance of the heading, subtitle, and CTA buttons.

### 2. Interactive Category Collections [MODIFY] [product_home_page.dart](file:///D:/dada_2/lib/views/user_side/product_home_page.dart)
- **Staggered Entrance**: Use `VisibilityDetector` and `FadeInUp` to reveal collection tiles with a 60ms stagger.
- **Tactile Feedback**:
  - **Desktop**: Add hover scaling (`1.08x`) for category images and a subtle gold color shift for labels.
  - **Mobile**: Implement a quick scale-down (`0.97x`) on tap before navigating to the catalogue.

### 3. Featured Products Grid [MODIFY] [product_card.dart](file:///D:/dada_2/lib/views/user_side/sections/product_card.dart)
- **Entrance**: Staggered reveal for product cards in the grid.
- **Product Card Enhancements**:
  - **Hover Action**: "Add to Cart" button slides up from the bottom on desktop hover.
  - **Price Badge**: Pop-in animation for discount tags using spring easing.
  - **Action Feedback**: Crossfade transition to a "Added!" checkmark state upon clicking "Add to Cart".

### 4. Trust Badges & Process [MODIFY] [product_home_page.dart](file:///D:/dada_2/lib/views/user_side/product_home_page.dart)
- **Settle Animation**: Process icons (Ganga Jal, Vedic Mantra, etc.) will use a scale-down "settle" effect (`1.1 -> 1.0` with bounce) when they first enter the viewport.
- **Staggered Reveal**: Fade and rise entrance for process descriptions.

### 5. Wisdom & Testimonials [MODIFY] [product_home_page.dart](file:///D:/dada_2/lib/views/user_side/product_home_page.dart)
- **Scroll Reveal**: Sections will slide up smoothly as the user scrolls down.

## Verification Plan

### Manual Verification
- Navigate to the Store Home Portal.
- Observe the hero banner's scale-in entrance.
- Scroll through "Sacred Collections" to check the staggered tile reveals.
- Hover over category tiles on desktop to verify the image scale and label color shift.
- Test the "Add to Cart" interaction on product cards: verify the slide-up button (desktop) and the checkmark state change.
- Check the trust icons for the "settle" bounce effect on scroll.
