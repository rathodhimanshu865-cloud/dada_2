import 'package:flutter/material.dart';

// Re-export canonical design-system tokens so callers only need one import.
export 'site_interactions.dart'
    show
        SiteTokens,
        SiteFilterTabBar,
        SiteCardEntrance,
        SitePressable,
        SiteElevatedButton,
        SiteIconButton,
        SiteGridSwitcher,
        SiteLightboxRoute;

class AnimationUtils {
  /// Returns a duration that is 0 if the user has requested reduced motion.
  static Duration getDuration(BuildContext context, Duration original) {
    if (MediaQuery.of(context).disableAnimations) {
      return Duration.zero;
    }
    return original;
  }

  /// Returns an offset of zero if the user has requested reduced motion.
  static double getOffset(BuildContext context, double original) {
    if (MediaQuery.of(context).disableAnimations) {
      return 0.0;
    }
    return original;
  }

  /// Helper to decide if complex animations (transforms, zooms) should be shown.
  static bool shouldAnimate(BuildContext context) {
    return !MediaQuery.of(context).disableAnimations;
  }
}
