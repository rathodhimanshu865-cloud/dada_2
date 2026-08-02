# Implementation Plan - Product Page & Catalog System

Implement a full product management system including an admin interface for CRUD operations and a public-facing catalog with dynamic, slug-based routing.

## User Review Required

> [!IMPORTANT]
> 1. **Price Visibility**: Should products display a price, or is this a purely informational showcase? (Default: Price included but optional).
> 2. **Deletion Policy**: Unlike the photo gallery, should products be fully deletable? (Default: Yes, for inventory management).
> 3. **Navigation Link**: I will add a "PRODUCTS" link to the main header and mobile menu. Please confirm if it should be placed elsewhere.

## Proposed Changes

### Core Logic & Data

#### [NEW] [product_model.dart](file:///D:/dada_2/lib/models/product_model.dart)
- Define `Product` class with fields: `id`, `title`, `slug`, `description`, `price`, `images` (List), `category`, `featured` (bool), `visible` (bool), `createdAt`, `updatedAt`.
- Include `toMap` and `fromMap`.

#### [NEW] [product_controller.dart](file:///D:/dada_2/lib/controllers/product_controller.dart)
- Handle Firestore stream of visible products.
- CRUD operations for Admin.
- Multi-image upload logic using `FirebaseStorage`.
- Slug generation helper (e.g., lowercase + hyphens).

---

### Admin Interface

#### [admin_dashboard.dart](file:///D:/dada_2/lib/views/admin/admin_dashboard.dart)
- Add "Products" to the sidebar menu.
- Integrate the new `ProductManagementView`.

#### [NEW] [product_management_view.dart](file:///D:/dada_2/lib/views/admin/product_management_view.dart)
- List all products with toggle for visibility.
- Form to Add/Edit products:
    - Auto-generate slug from title.
    - Multi-file picker for images.
    - Fields for category, price, and description.

---

### User Side

#### [NEW] [product_list_page.dart](file:///D:/dada_2/lib/views/user_side/product_list_page.dart)
- Professional grid layout for products.
- Category filtering (if applicable).
- Responsive design (mobile/tablet/desktop).

#### [NEW] [product_detail_page.dart](file:///D:/dada_2/lib/views/user_side/product_detail_page.dart)
- Hero section for product title.
- Image gallery/carousel for multiple images.
- Detailed description and price.
- "Product not found" handling.

---

### Routing & Navigation

#### [main.dart](file:///D:/dada_2/lib/main.dart)
- Register `ProductController` in `MultiProvider`.
- Implement `onGenerateRoute` to support `/products/:slug` pattern.

#### [user_header.dart](file:///D:/dada_2/lib/views/user_side/sections/user_header.dart)
- Add "PRODUCTS" to the navigation menu and mobile bottom sheet.

---

## Verification Plan

### Manual Verification
1.  **Admin CRUD**:
    - Add a new product with multiple images.
    - Edit the product (change title/price).
    - Verify slug auto-generation and manual override.
    - Toggle visibility and verify removal from user side.
    - Delete the product and verify cleanup.
2.  **Routing**:
    - Manually enter `/products/your-product-slug` in the browser and verify it loads correctly.
    - Verify that a non-existent slug shows a "Product Not Found" screen.
3.  **Real-time Sync**:
    - Verify that changes in Admin appear on the user side instantly without refresh.
4.  **Regression**:
    - Navigate to "About Dada," "Gallery," and "Contact" to ensure no visual or functional changes occurred.
