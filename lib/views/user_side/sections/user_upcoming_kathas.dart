import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';

import '../../../utils/app_typography.dart';
import 'katha_calendar_view.dart';

class UserUpcomingKathas extends StatelessWidget {
  final HomePageController controller;
  const UserUpcomingKathas({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.upcomingKathas.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      color: const Color(0xFFF3EEE6),
      child: Column(
        children: [
          // Section Header
          Column(
            children: [
              Text(
                AppLocalizations.of(context)!.spiritualCalendar,
                style: AppTypography.bodyStyle(
                  context,
                  color: const Color(0xFFC89A5B),
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.upcomingKathas,
                style: AppTypography.headingStyle(
                  context,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F4C5C),
                ),
              ),
              const SizedBox(height: 30),
              Container(height: 1, width: 80, color: const Color(0xFFC89A5B)),
            ],
          ),

          const SizedBox(height: 50),

          // View Toggles: List View & Calendar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _viewButton(context, AppLocalizations.of(context)!.listView, Icons.list_alt_rounded, () {
                Navigator.pushNamed(context, '/upcoming_ram_kathas');
              }),
              const SizedBox(width: 20),
              _viewButton(context, AppLocalizations.of(context)!.calendar, Icons.calendar_month_outlined, () {
                showDialog(
                  context: context,
                  builder: (context) => KathaCalendarView(kathas: controller.upcomingKathas),
                );
              }),
            ],
          ),

          const SizedBox(height: 60),

          // Well-arranged Grid of Cards
          Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: LayoutBuilder(builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 25,
                  childAspectRatio: 1.15,
                ),
                itemCount: controller.upcomingKathas.take(3).length,
                itemBuilder: (context, index) => _buildEventCard(context, controller.upcomingKathas[index]),
              );
            }),
          ),

          const SizedBox(height: 60),

          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/upcoming_ram_kathas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4C5C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(
              AppLocalizations.of(context)!.viewAllUpcomingKathas,
              style: AppTypography.bodyStyle(
                context,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: AppTypography.bodyStyle(
          context,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          fontSize: 12,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F4C5C),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        side: BorderSide(color: const Color(0xFF0F4C5C).withValues(alpha: 0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, UpcomingKatha katha) {
    final lang = Localizations.localeOf(context).languageCode;
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(0, isHovered ? -10 : 0, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: const Border(top: BorderSide(color: Color(0xFFC89A5B), width: 4)),
              boxShadow: [
                BoxShadow(
                  color: isHovered ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.04),
                  blurRadius: isHovered ? 30 : 20,
                  offset: Offset(0, isHovered ? 15 : 10),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => _showMoreDetails(context, katha, lang),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      _formatDateRange(katha, lang).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyStyle(
                        context,
                        color: const Color(0xFFC89A5B),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 15),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isHovered ? 65 : 55,
                      height: isHovered ? 65 : 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F4C5C), Color(0xFF07404C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (isHovered) BoxShadow(color: const Color(0xFF0F4C5C).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: AppTypography.bodyStyle(
                            context,
                            color: Colors.white,
                            fontSize: isHovered ? 22 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                          child: Text(katha.kathaNumber),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      katha.localizedName(lang),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headingStyle(
                        context,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F4C5C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F3EA),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFC89A5B).withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Color(0xFFC89A5B)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              katha.localizedLocation(lang),
                              style: AppTypography.bodyStyle(
                                context,
                                color: const Color(0xFF6D6D6D),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.detailsArrow.replaceAll(' >', ''),
                          style: AppTypography.bodyStyle(
                            context,
                            color: const Color(0xFFC89A5B),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(left: isHovered ? 8 : 4),
                          child: const Icon(Icons.arrow_forward_ios, size: 8, color: Color(0xFFC89A5B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateRange(UpcomingKatha katha, String lang) {
    if (katha.startDate != null && katha.endDate != null) {
      final start = DateFormat('dd MMM yyyy').format(katha.startDate!);
      final end = DateFormat('dd MMM yyyy').format(katha.endDate!);
      if (start == end) return start;
      return '$start - $end';
    }
    return katha.localizedDateString(lang);
  }

  void _showMoreDetails(BuildContext context, UpcomingKatha katha, String lang) {
    showDialog(
      context: context,
      builder: (context) {
        final isMobile = MediaQuery.of(context).size.width < 900;
        const primaryTeal = Color(0xFF0F4C5C);
        const accentBrown = Color(0xFFC19A6B);

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
          child: Container(
            width: isMobile ? double.infinity : 600,
            padding: EdgeInsets.all(isMobile ? 24 : 50),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${AppLocalizations.of(context)!.kathaPrefix} ${katha.kathaNumber} — ${katha.localizedName(lang)}',
                          style: AppTypography.headingStyle(
                            context,
                            fontSize: isMobile ? 20 : 26,
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close, size: 26),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(width: 80, height: 3, color: accentBrown),
                  const SizedBox(height: 30),
                  _detailRow(context, AppLocalizations.of(context)!.kathaDate, _formatDateRange(katha, lang), isMobile),
                  _detailRow(context, AppLocalizations.of(context)!.kathaTiming, katha.timing, isMobile),
                  _detailRow(context, AppLocalizations.of(context)!.kathaLocation, katha.localizedLocation(lang), isMobile),
                  _detailRow(context, AppLocalizations.of(context)!.kathaHosting, katha.hosting, isMobile),
                  if (katha.localizedDescription(lang).isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.moreDetails,
                      style: AppTypography.bodyStyle(
                        context,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                        color: primaryTeal.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      katha.localizedDescription(lang),
                      style: AppTypography.bodyStyle(
                        context,
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  Center(child: Container(width: 80, height: 1, color: Colors.grey[200])),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 30 : 50, vertical: isMobile ? 15 : 20),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.close,
                        style: AppTypography.bodyStyle(
                          context,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

  Widget _detailRow(BuildContext context, String label, String value, bool isMobile) {
    const primaryTeal = Color(0xFF0F4C5C);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 120 : 180,
            child: Text(
              label,
              style: AppTypography.bodyStyle(
                context,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 14 : 16,
                color: primaryTeal.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: AppTypography.bodyStyle(
                context,
                fontSize: isMobile ? 14 : 16,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
