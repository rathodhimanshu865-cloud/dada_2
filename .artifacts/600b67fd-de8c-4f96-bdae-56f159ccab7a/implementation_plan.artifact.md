# Implementation Plan - User Invoice Access & UI Refinements

This plan addresses the user's request to enable invoice viewing/downloading for customers, fix navigation issues (moving Track Shipment, fixing missing pages), and organizing "messy" pages.

## User Review Required

> [!IMPORTANT]
> - **Invoice Location:** Buttons for "View Invoice" and "Download Invoice" will be added to each order card in the "My Orders" section.
> - **Navigation Change:** "Track Shipment" will be moved out of the "Katha" category to the main navigation for better visibility.
> - **Teachings Page:** "Pu. Dada's Teachings" will be added to the main header navigation as it was previously missing or hard to find.

## Proposed Changes

### [Invoice Functionality]

#### [MODIFY] [my_orders_page.dart](file:///D:/dada_2/lib/views/user_side/my_orders_page.dart)
- Integrate `InvoiceHelper` to provide "Print Invoice" and "Download/Share Invoice" actions within the `_showOrderDetails` bottom sheet and directly on the order card.

### [Navigation & Page Visibility]

#### [MODIFY] [user_header.dart](file:///D:/dada_2/lib/views/user_side/sections/user_header.dart)
- Move "Track Shipment" from the mobile "Katha" dropdown to a top-level item.
- Add "Track Order" icon/button to the desktop header actions.
- Add "Teachings" to the main desktop navigation.
- Ensure "Product Portal" is correctly linked and labeled.

#### [MODIFY] [user_footer.dart](file:///D:/dada_2/lib/views/user_side/sections/user_footer.dart)
- Standardize link labels and routes to ensure consistency with the header.

### [Page Organization & UI Cleanup]

#### [MODIFY] [product_home_page.dart](file:///D:/dada_2/lib/views/user_side/product_home_page.dart)
- Audit and fix the layout to ensure it renders correctly even if dynamic data is partially missing.
- Improve spacing and visual hierarchy to remove the "messy" feel.

#### [MODIFY] [pu_dada_teachings_page.dart](file:///D:/dada_2/lib/views/user_side/pu_dada_teachings_page.dart)
- Enhance the UI layout, fixing any alignment issues or overlapping components.

#### [MODIFY] [track_shipment_page.dart](file:///D:/dada_2/lib/views/user_side/track_shipment_page.dart)
- Improve the visual design of the tracking results to be more intuitive and professional.

## Verification Plan

### Automated Tests
- N/A (Focus on UI/UX and functional manual verification)

### Manual Verification
- **Invoice Check:** Log in as a user, go to "My Orders", and verify that clicking "View Invoice" opens the print dialog and "Download" triggers the share/save dialog.
- **Navigation Check:** Verify "Track Shipment" is now a top-level item in both mobile and desktop menus.
- **Page Audit:** Navigate through "Product Home", "Teachings", and "Track Shipment" to ensure they load correctly and look organized.
- **Responsive Test:** Check all changes on both mobile and desktop screen sizes.
