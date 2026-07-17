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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
      color: const Color(0xFFFAF8F4),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const Icon(Icons.format_quote_rounded, size: 80, color: Color(0xFFC89A5B)),
              const SizedBox(height: 40),
              Text(
                quoteData.localizedQuote(lang),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 36,
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF2B2B2B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Container(height: 1, width: 60, color: const Color(0xFFC89A5B)),
              const SizedBox(height: 30),
              Text(
                quoteData.localizedAuthor(lang).toUpperCase(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 4, color: Color(0xFFC89A5B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
