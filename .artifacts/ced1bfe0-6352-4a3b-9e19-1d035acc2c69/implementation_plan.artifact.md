# Advanced Header Animations for UserHeader

This plan implements a series of high-end animations for the main application header, including entrance effects, scroll-driven transformations, hover interactions, and mobile menu enhancements.

## User Review Required

> [!IMPORTANT]
> - The header will now use a `TickerProviderStateMixin` to manage multiple animation controllers (Entrance, Pulse, etc.).
> - Scroll-based reveal/hide logic will be added, which may affect how users interact with the page if they expect a constant sticky header.
> - Mobile menu will be upgraded from a simple `showModalBottomSheet` to a custom animated panel to meet the "translateX 100% to 0" requirement.

## Proposed Changes

### [User Interface]

#### [MODIFY] [user_header.dart](file:///D:/dada_2/lib/views/user_side/sections/user_header.dart)
- **Entrance Animations:**
    - Logo fade + scale (0.9 -> 1.0) on load.
    - Staggered navigation links (slide up -10px -> 0px, fade 0 -> 1).
- **Scroll-Driven Logic:**
    - Header height shrinks (95px -> 70px) when scroll > 80px.
    - Background transitions to blurred glass (sigma 12.0) with backdrop filter.
    - Reveal on scroll up, hide on scroll down (translateY transition).
- **Navigation Interaction:**
    - Hover effect: Underline draws left-to-right, text color shifts to saffron gold.
    - Active indicator: Smooth animation for the current page marker.
- **Mobile Enhancements:**
    - Hamburger icon animates into an "X".
    - Custom slide-in menu from the right with staggered item entrance.
- **CTA Pulse:**
    - "Donate" button (CTA) will have a subtle repeating pulse-glow loop.

## Verification Plan

### Automated Tests
- N/A (Visual animations are best verified manually in this context).

### Manual Verification
- **Load Page:** Observe logo and nav links entrance.
- **Scroll Down:** Verify header shrinks and background blurs.
- **Scroll Past 200px:** Scroll down to hide, scroll up to reveal.
- **Desktop Hover:** Hover over nav links to see underline and color shift.
- **Mobile Menu:** Tap hamburger, verify "X" animation and slide-in panel.
- **CTA Button:** Verify subtle pulse effect on the Donate button.
