# Admin Panel Comprehensive Upgrade Plan

This plan outlines the complete overhaul of the Admin Panel to provide full control over the user-side application, analytics, inventory, orders, and content management.

## User Review Required

> [!IMPORTANT]
> - **Profit Calculation:** This will be based on `Selling Price - Cost Price`. I will add a `costPrice` field to products.
> - **Out of Stock:** Products with 0 stock will be automatically hidden or shown as "Out of Stock" on the user side.
> - **Review Replies:** Admin replies to reviews will trigger a direct WhatsApp/SMS message.
> - **Store Settings:** The new settings section will allow editing the Home Portal, Product Catalogue, and Teachings section dynamically from Firestore.

## Proposed Changes

### 1. Data Models & Controllers

#### [MODIFY] [ProductModel](file:///D:/dada_2/lib/models/product_model.dart)
- Add `costPrice` field.
- Add `minStockAlert` field (default 5).

#### [NEW] [CouponModel](file:///D:/dada_2/lib/models/coupon_model.dart)
- Fields: `code`, `discountType` (percentage/flat), `discountValue`, `minOrderValue`, `isActive`.

#### [MODIFY] [DashboardController](file:///D:/dada_2/lib/controllers/dashboard_controller.dart)
- Implement `statsByPeriod(int days)` to filter data for 1, 30, 90, 180, 365 days.
- Calculate total profit using `items` in orders and `costPrice` from products.
- Identify low stock products.

#### [NEW] [CouponController](file:///D:/dada_2/lib/controllers/coupon_controller.dart)
- CRUD operations for coupons.

### 2. Admin UI - Redesign

#### [MODIFY] [AdminDashboard](file:///D:/dada_2/lib/views/admin/admin_dashboard.dart)
- New Sidebar Structure:
  1. Dashboard
  2. Products
  3. Categories
  4. Inventory & Stock
  5. Orders & Dispatch
  6. Payments
  7. Devotees
  8. Coupons
  9. Reviews
  10. Store & Seva Settings (Home Portal, Teachings, etc.)

#### [NEW] [DashboardView](file:///D:/dada_2/lib/views/admin/dashboard_view.dart)
- Analytics boxes (Revenue, Profit, Orders, Products, Stock Attention).
- Action buttons: Add Product, Restock, Create Coupon, Dispatch.
- Recent Orders list with Invoice view.
- Low Stock Watch list.

#### [NEW] [CategoryManagementView](file:///D:/dada_2/lib/views/admin/category_management_view.dart)
- Add/Edit/Delete categories with icons and product counts.

#### [MODIFY] [ProductManagementView](file:///D:/dada_2/lib/views/admin/product_management_view.dart)
- Enhance with category-wise filtering and detailed list view matching the screenshot.

#### [NEW] [InventoryStockView](file:///D:/dada_2/lib/views/admin/inventory_stock_view.dart)
- List products with current stock, safety limit, and quick replenish buttons (+5, +25).

#### [NEW] [OrderDispatchView](file:///D:/dada_2/lib/views/admin/order_dispatch_view.dart)
- Manage order statuses (Pending -> Delivered).
- Update tracking carrier/ID.
- Print/View Invoices.

#### [NEW] [DevoteeManagementView](file:///D:/dada_2/lib/views/admin/devotee_management_view.dart)
- List users with order history.
- "WhatsApp Seva" button for direct contact.

#### [NEW] [StoreSettingsView](file:///D:/dada_2/lib/views/admin/store_settings_view.dart)
- Replace legacy settings with dynamic editors for:
  - Home Portal (Slider, Sections)
  - Product Catalogue info
  - Teachings (Content & Images)

### 3. User-Side Synchronization

#### [MODIFY] [UserHomePage](file:///D:/dada_2/lib/views/user_side/user_homepage.dart)
- Sync content with Firestore settings updated by admin.

#### [MODIFY] [CataloguePage](file:///D:/dada_2/lib/views/user_side/catalogue_page.dart)
- Implement category-wise display.
- Hide/Show "Out of Stock" labels based on inventory.

#### [MODIFY] [TrackShipmentPage](file:///D:/dada_2/lib/views/user_side/track_shipment_page.dart)
- Display real-time status and tracking info from Admin updates.

### 4. Localization

- Add translations for all new Admin UI components and User-side status labels in [app_en.arb](file:///D:/dada_2/lib/l10n/app_en.arb), `app_gu.arb`, and `app_hi.arb`.

## Verification Plan

### Automated Tests
- Unit tests for `DashboardController` period filtering logic.
- Integration tests for Order status updates reflecting on User-side.

### Manual Verification
1. Log in as Admin.
2. Verify Dashboard stats change with period selection.
3. Add a product and verify it appears in the User Catalogue under the correct category.
4. Set stock to 0 and verify "Out of Stock" or hidden status on User-side.
5. Update an order status and check `Track Shipment` on the User-side.
6. Create a coupon and test it in the Checkout flow.
7. Reply to a review and verify WhatsApp intent is launched.
