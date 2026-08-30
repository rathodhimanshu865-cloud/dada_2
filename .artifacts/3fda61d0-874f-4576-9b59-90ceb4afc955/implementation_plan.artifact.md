# Implementation Plan - Admin & User Panel Updates

This plan outlines the updates and bug fixes for the Jignesh Dada Official app, focusing on the Admin Dashboard, Product Management, Category functionality, and CMS restoration.

## User Review Required

> [!IMPORTANT]
> **Google Translate API**: The current `TranslationService` uses a free MyMemory API. For a more robust "Google Translate API integration," a Google Cloud project with an API key is required. I will add placeholders for the API key in the `TranslationService`.
>
> **CMS Cleanup**: The requested cleanup will hide several existing CMS modules (Hero Slider, Biography, News, etc.) from the sidebar to strictly follow the new requirements.

## Proposed Changes

### 1. Dashboard Page Updates
#### [MODIFY] [admin_dashboard.dart](file:///D:/dada_2/lib/views/admin/admin_dashboard.dart)
- Add "Dashboard" and "Order & Dispatch" to the sidebar menus.
- Set default `currentMenuIndex` to 14 (Dashboard).

#### [MODIFY] [dashboard_view.dart](file:///D:/dada_2/lib/views/admin/dashboard_view.dart)
- Fix broken RESTOCK and COUPONS buttons.
- Add "Order & Dispatch" button to the header actions.
- Implement a real-time clock in the top-right corner that updates every second and resets at midnight.
- Add Quick Access Actions (Add product, Check stock, Create coupons, View orders).

### 2. Products Section (Performance & Fields)
#### [MODIFY] [product_controller.dart](file:///D:/dada_2/lib/controllers/product_controller.dart)
- Optimize `addProduct` and `updateProduct` by reducing redundant state updates.
- Ensure `comparePrice` is correctly handled in Firestore operations.

#### [MODIFY] [product_dialog_helper.dart](file:///D:/dada_2/lib/views/admin/product_dialog_helper.dart)
- Replace "Cost Price" field with "Compare Price" in the Add/Edit Product dialog.
- Ensure the value is mapped to `product.comparePrice`.

#### [MODIFY] [product_details_page.dart](file:///D:/dada_2/lib/views/user_side/product_details_page.dart)
- Display the "Compare Price" (Original Price) with a strike-through next to the selling price.

### 3. Category Page Fixes
#### [MODIFY] [category_management_view.dart](file:///D:/dada_2/lib/views/admin/category_management_view.dart)
- Implement "View Products" to filter the Product List by category.
- Implement Add, Edit, and Delete functionality for categories.
- Ensure real-time sync with the User Panel (already handled by StreamBuilder/Provider).

### 4. Inventory & Low Stock Alerts
#### [MODIFY] [dashboard_view.dart](file:///D:/dada_2/lib/views/admin/dashboard_view.dart)
- Add a dynamic notification badge to the "LOW STOCK" stat box showing the count of products below the threshold.

### 5. Order Management & Invoices
#### [MODIFY] [order_dispatch_view.dart](file:///D:/dada_2/lib/views/admin/order_dispatch_view.dart)
- Implement a professional invoice layout using a new `InvoicePreviewDialog`.
- Integrate `printing` and `pdf` packages to enable View, Download (PDF), and WhatsApp sharing of invoices.

### 6. User Section Fix
#### [MODIFY] [devotee_management_view.dart](file:///D:/dada_2/lib/views/admin/devotee_management_view.dart)
- Fix the potential crash when a user's name is empty.
- Ensure it is correctly reachable from the sidebar/dashboard.

### 7. Restore CMS Section
#### [MODIFY] [cms_views_helper.dart](file:///D:/dada_2/lib/views/admin/cms_views_helper.dart)
- Simplify the CMS views to strictly include:
  - Home portal text/images.
  - Product catalogue headings.
  - Promotional images.
  - "Pujya Dada Teachings" content editor.

### 8. Automated Translation & Publishing
#### [MODIFY] [admin_dashboard.dart](file:///D:/dada_2/lib/views/admin/admin_dashboard.dart)
- Add "Translate All" and "Publish All" buttons to the AppBar.
- Implement logic to iterate through un-translated database entries and apply translations.

## Verification Plan

### Automated Tests
- Run `flutter test` to ensure no regressions in models.

### Manual Verification
- **Dashboard**: Verify the clock updates and resets at midnight. Test all quick action buttons.
- **Products**: Add a product with "Compare Price" and verify it appears with a strike-through on the user side.
- **Categories**: Add a new category and verify it appears instantly on the user home page.
- **Invoices**: Generate an invoice, download as PDF, and verify layout quality.
- **CMS**: Update a teaching section and verify it reflects on the user teachings page.
- **Translation**: Click "Translate" and verify Hindi/Gujarati fields are populated in Firestore.
