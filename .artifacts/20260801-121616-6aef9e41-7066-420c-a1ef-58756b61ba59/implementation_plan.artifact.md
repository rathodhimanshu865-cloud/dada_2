# Implementation Plan - Full E-Commerce Purchase System

Implement a robust, Amazon-style e-commerce flow for the website, including cart management, secure user accounts, Razorpay payment integration, and order tracking.

## User Review Required

> [!IMPORTANT]
> 1. **Payment Gateway**: I will proceed with **Razorpay** integration as requested. You will need to provide the `KEY_ID` and `KEY_SECRET` from your Razorpay Dashboard later.
> 2. **Guest Checkout**: Should we allow users to purchase without an account? (Recommended: **No**, require login for better order tracking).
> 3. **Stock Tracking**: Should we track inventory and prevent overselling? (Default: No, unlimited stock).
> 4. **Cloud Functions**: This requires a Firebase **Blaze plan** (pay-as-you-go). Please confirm if your project is on the Blaze plan.

## Proposed Changes

### 1. Authentication & Accounts
- Implement `AuthController` for Firebase Auth (Email/Password & Google).
- Create `lib/views/user_side/auth/login_page.dart` and `signup_page.dart`.
- Create `lib/views/user_side/profile/my_orders_page.dart`.

### 2. Shopping Cart
- Create `CartController` using `Provider` for state management.
- Persist cart items in Firestore for logged-in users and `SharedPreferences` for guest sessions.
- Add "Add to Cart" buttons to `ProductListPage` and `ProductDetailPage`.
- Create `lib/views/user_side/cart_page.dart`.

### 3. Checkout & Payment (Razorpay)
- Create `lib/views/user_side/checkout_page.dart` (Address form & Summary).
- **Backend**: Implement Firebase Cloud Functions:
  - `createRazorpayOrder`: Securely calls Razorpay API to create an order.
  - `verifyRazorpayPayment`: Securely verifies the payment signature before updating Firestore.
- **Frontend**: Integrate `razorpay_flutter` package.

### 4. Order Management
- Define `Order` model in `lib/models/order_model.dart`.
- Update `AdminDashboard` to include an "Orders" section for status updates (Processing, Shipped, Delivered).

### 5. UI/UX Refinements
- Update `UserHeader` to include a Cart icon with a badge (item count) and a Profile/Account icon.

## Verification Plan

### Manual Verification
1.  **Auth Flow**: Sign up, login, and verify order history accessibility.
2.  **Cart Flow**: Add multiple items, adjust quantities, verify persistence after page refresh.
3.  **Payment (Test Mode)**:
    - Proceed to checkout with valid details.
    - Complete a test transaction using Razorpay's test card/UPI.
    - Verify the order is marked as "Paid" in Firestore only after backend verification.
4.  **Admin Flow**: View the new order in the Admin Dashboard and update its status.
5.  **Customer Flow**: View the updated status in "My Orders".
