# Implementation Plan - Product Details Page Overhaul

Update the product details page to exactly match the provided image, ensuring a high-quality, devotional user experience while maintaining consistency with the admin panel.

## User Review Required

> [!IMPORTANT]
> The UI changes are extensive to match the high-fidelity design in the image. This includes custom components for quantity selectors, variant pickers, and delivery availability checkers.

> [!WARNING]
> I will be adding new fields to the `ProductModel` to support dynamic variants (finishes and sizes) to ensure "original details for every single product" are displayed.

## Proposed Changes

### Data Model & Backend

#### [MODIFY] [product_model.dart](file:///D:/dada_2/lib/models/product_model.dart)
- Add `List<String> finishes` and `List<String> sizes` to support dynamic product variants.
- Update `fromFirestore` and `toFirestore` to handle these new fields.

### Admin Panel

#### [MODIFY] [product_management_view.dart](file:///D:/dada_2/lib/views/admin/product_management_view.dart)
- Add input fields for `finishes` and `sizes` in the "Add/Edit Product" dialog.
- Ensure all new fields are correctly saved to Firestore.

### User Side UI

#### [MODIFY] [product_details_page.dart](file:///D:/dada_2/lib/views/user_side/product_details_page.dart)
- Refine the top header/breadcrumbs styling.
- Implement the exact layout for the product gallery with thumbnails and badges.
- Update the product info section:
    - Add the "Sanctified & Consecrated" alert box with the correct styling.
    - Implement the large price display with discount badges.
    - Add the detailed description box below the stock status.
    - Implement the variant picker (Finish and Size) using dynamic data from the model.
    - Style the complimentary item checkboxes.
    - Implement the large "ADD TO BAG" and "INSTANT SACRED CHECKOUT" buttons.
    - Add the WhatsApp inquiry button.
    - Implement the "Delivery & Payment Availability" section with a pincode checker.
    - Refine the "Frequently Blessed Together" bundle offer section.
    - Update the tabs section to match the design.
    - Implement the feature grid under the "Vedic Significance" tab.
- Ensure the header and footer remain untouched as they are provided by the layout wrapper.

## Verification Plan

### Automated Tests
- N/A (UI focused task, will verify via manual inspection of layout).

### Manual Verification
- Open the admin panel, add a new product with custom finishes and sizes.
- Verify the product appears in the user-side products list.
- Open the product details page and verify it matches the image "exactly".
- Check that all buttons and interactable elements (quantity, checkboxes, variants) function correctly.
- Ensure no excessive errors or logs appear in the terminal during navigation.
