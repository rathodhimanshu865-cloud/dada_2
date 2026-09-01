import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';

class UserFeaturedQuote extends StatelessWidget {
  final HomePageController controller;
  const UserFeaturedQuote({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final quoteData = controller.homepageData.featuredQuote;
    final lang = Localizations.localeOf(context).languageCode;
    if (quoteData.quote.isEmpty) return const SizedBox.shrink();

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 120, horizontal: isMobile ? 20 : 40),
      color: const Color(0xFFFAF8F4),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Icon(Icons.format_quote_rounded, size: isMobile ? 40 : 80, color: const Color(0xFFC89A5B)),
              SizedBox(height: isMobile ? 20 : 40),
              Text(
                quoteData.localizedQuote(lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? (screenWidth < 600 ? 18 : 24) : 36,
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF2B2B2B),
                  height: 1.5,
                ),
              ),
              SizedBox(height: isMobile ? 25 : 40),
              Container(height: 1, width: 60, color: const Color(0xFFC89A5B)),
              const SizedBox(height: 30),
              Text(
                quoteData.localizedAuthor(lang).toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold, letterSpacing: 4, color: const Color(0xFFC89A5B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
