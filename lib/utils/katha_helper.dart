import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/homepage_model.dart';
import '../utils/app_typography.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class KathaHelper {
  static String formatDateRange(UpcomingKatha katha, String lang) {
    if (katha.startDate != null && katha.endDate != null) {
      final start = DateFormat('dd MMM yyyy').format(katha.startDate!);
      final end = DateFormat('dd MMM yyyy').format(katha.endDate!);
      if (start == end) return start;
      return '$start - $end';
    }
    return katha.localizedDateString(lang);
  }

  static void showMoreDetails(BuildContext context, UpcomingKatha katha, String lang) {
    showDialog(
      context: context,
      builder: (context) {
        final isMobile = MediaQuery.of(context).size.width < 900;
        const primaryTeal = Color(0xFF0F4C5C);
        const backgroundBeige = Color(0xFFF9F3EA);
        const accentBrown = Color(0xFFC19A6B);

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 24,
          insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
          child: Container(
            width: isMobile ? double.infinity : 700,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, backgroundBeige.withValues(alpha: 0.2)],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.fromLTRB(30, 30, 20, 20),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: accentBrown.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${AppLocalizations.of(context)!.kathaPrefix} ${katha.kathaNumber}'.toUpperCase(),
                                  style: const TextStyle(color: accentBrown, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                katha.localizedName(lang).toUpperCase(),
                                style: AppTypography.headingStyle(
                                  context,
                                  fontSize: isMobile ? 22 : 30,
                                  fontWeight: FontWeight.w800,
                                  color: primaryTeal,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content section
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRowWithIcon(context, Icons.calendar_today_outlined, AppLocalizations.of(context)!.kathaDate, formatDateRange(katha, lang), primaryTeal),
                        _detailRowWithIcon(context, Icons.access_time_rounded, AppLocalizations.of(context)!.kathaTiming, katha.localizedTiming(lang), primaryTeal),
                        _detailRowWithIcon(context, Icons.location_on_outlined, AppLocalizations.of(context)!.kathaLocation, katha.localizedLocation(lang), primaryTeal),
                        _detailRowWithIcon(context, Icons.people_outline_rounded, AppLocalizations.of(context)!.kathaHosting, katha.localizedHosting(lang), primaryTeal),
                        
                        if (katha.localizedDescription(lang).isNotEmpty) ...[
                          const SizedBox(height: 30),
                          const Divider(height: 1),
                          const SizedBox(height: 30),
                          const Text(
                            "EVENT OVERVIEW",
                            style: TextStyle(
                              color: accentBrown,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            katha.localizedDescription(lang),
                            style: AppTypography.bodyStyle(
                              context,
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.7,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Footer button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.close.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _detailRowWithIcon(BuildContext context, IconData icon, String label, String value, Color primaryTeal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.05), shape: BoxShape.circle),
            child: Icon(icon, color: primaryTeal, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
