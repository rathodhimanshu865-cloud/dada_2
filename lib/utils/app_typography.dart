import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static String getHeadingFont(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'gu') return GoogleFonts.notoSansGujarati().fontFamily!;
    if (locale == 'hi') return GoogleFonts.notoSansDevanagari().fontFamily!;
    return GoogleFonts.cormorantGaramond().fontFamily!;
  }

  static String getBodyFont(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'gu') return GoogleFonts.notoSansGujarati().fontFamily!;
    if (locale == 'hi') return GoogleFonts.notoSansDevanagari().fontFamily!;
    return GoogleFonts.nunito().fontFamily!;
  }

  static TextStyle headingStyle(BuildContext context, {double? fontSize, FontWeight? fontWeight, Color? color, double? letterSpacing, double? height, FontStyle? fontStyle}) {
    return TextStyle(
      fontFamily: getHeadingFont(context),
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
    );
  }

  static TextStyle bodyStyle(BuildContext context, {double? fontSize, FontWeight? fontWeight, Color? color, double? letterSpacing, double? height, FontStyle? fontStyle}) {
    return TextStyle(
      fontFamily: getBodyFont(context),
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
    );
  }

  // Responsive scaling helpers
  static double getResponsiveSize(BuildContext context, {required double desktop, required double tablet, required double mobile}) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1024) return desktop;
    if (width >= 600) return tablet;
    return mobile;
  }

  static double dynamicFontSize(BuildContext context, double baseSize) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1400) return baseSize;
    if (width >= 1024) return baseSize * 0.9;
    if (width >= 600) return baseSize * 0.8;
    return baseSize * 0.75;
  }
}
