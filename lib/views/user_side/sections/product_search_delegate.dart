import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../models/product_model.dart';
import '../../../l10n/app_localizations.dart';

class ProductSearchDelegate extends SearchDelegate<String?> {
  @override
  String get searchFieldLabel => 'Search Sacred Products...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return Container(
        color: const Color(0xFFFAF8F4),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 80, color: const Color(0xFF07404C).withOpacity(0.1)),
              const SizedBox(height: 24),
              Text(
                'WHAT ARE YOU SEEKING TODAY?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: const Color(0xFF07404C).withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Search for blessings, malas, or sacred artifacts.',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final productController = Provider.of<ProductController>(context, listen: false);
    final lang = Provider.of<LanguageController>(context, listen: false).locale.languageCode;
    
    final lowercaseQuery = query.toLowerCase();
    final results = productController.allProducts.where((p) {
      return p.name.toLowerCase().contains(lowercaseQuery) ||
             p.nameHi.toLowerCase().contains(lowercaseQuery) ||
             p.nameGu.toLowerCase().contains(lowercaseQuery) ||
             p.categoryId.toLowerCase().contains(lowercaseQuery) ||
             p.shortSummary.toLowerCase().contains(lowercaseQuery) ||
             p.shortSummaryHi.toLowerCase().contains(lowercaseQuery) ||
             p.shortSummaryGu.toLowerCase().contains(lowercaseQuery);
    }).toList();

    if (results.isEmpty) {
      return Container(
        color: const Color(0xFFFAF8F4),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 24),
              Text(
                'NO RESULTS FOUND',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We couldn\'t find any sacred items matching "$query"',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => query = '',
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07404C),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('CLEAR SEARCH'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFFAF8F4),
      child: ListView.separated(
        itemCount: results.length,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = results[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: p.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    errorWidget: (context, url, error) => const Icon(Icons.image_outlined, color: Colors.grey),
                  ),
                ),
              ),
              title: Text(
                p.localizedName(lang),
                style: GoogleFonts.cormorantGaramond(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF07404C),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  p.localizedShortSummary(lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${p.price.toInt()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Color(0xFF07404C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
                ],
              ),
              onTap: () {
                close(context, p.id);
                Navigator.pushNamed(context, '/product_details', arguments: p.id);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF07404C)),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF07404C),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 16),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }
}
