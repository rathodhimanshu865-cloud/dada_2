import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';
import '../../../utils/app_typography.dart';
import '../../../utils/katha_helper.dart';
import '../../../utils/responsive_utils.dart';
import 'katha_calendar_view.dart';

class UserUpcomingKathas extends StatefulWidget {
  final HomePageController controller;
  const UserUpcomingKathas({super.key, required this.controller});

  @override
  State<UserUpcomingKathas> createState() => _UserUpcomingKathasState();
}

class _UserUpcomingKathasState extends State<UserUpcomingKathas> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    if (widget.controller.upcomingKathas.isEmpty) return const SizedBox.shrink();
    final bool isMobile = !Responsive.isDesktop(context);
    final displayKathas = widget.controller.upcomingKathas.take(isMobile ? 2 : 3).toList();

    return VisibilityDetector(
      key: const Key('user-upcoming-kathas'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          setState(() => _isVisible = true);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 120, horizontal: isMobile ? 20 : 40),
        color: const Color(0xFFF3EEE6),
        child: Column(
          children: [
            // Section Header
            Column(
              children: [
                FadeInDown(
                  animate: _isVisible,
                  child: Text(
                    AppLocalizations.of(context)!.spiritualCalendar,
                    style: AppTypography.bodyStyle(
                      context,
                      color: const Color(0xFFC89A5B),
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  animate: _isVisible,
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    AppLocalizations.of(context)!.upcomingKathas,
                    textAlign: TextAlign.center,
                    style: AppTypography.headingStyle(
                      context,
                      fontSize: isMobile ? 32 : 52,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F4C5C),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeIn(
                  animate: _isVisible,
                  delay: const Duration(milliseconds: 400),
                  child: Container(height: 1, width: 80, color: const Color(0xFFC89A5B)),
                ),
              ],
            ),

            const SizedBox(height: 50),

            // View Toggles
            FadeIn(
              animate: _isVisible,
              delay: const Duration(milliseconds: 600),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: [
                  _viewButton(context, AppLocalizations.of(context)!.listView, Icons.list_alt_rounded, () {
                    Navigator.pushNamed(context, '/upcoming_ram_kathas');
                  }),
                  _viewButton(context, AppLocalizations.of(context)!.calendar, Icons.calendar_month_outlined, () {
                    showDialog(
                      context: context,
                      builder: (context) => KathaCalendarView(kathas: widget.controller.upcomingKathas),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // alternating side slide-in
            Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                  mainAxisExtent: isMobile ? 360 : 400,
                ),
                itemCount: displayKathas.length,
                itemBuilder: (context, index) {
                  final katha = displayKathas[index];
                  if (index % 2 == 0) {
                    return FadeInLeft(
                      animate: _isVisible,
                      delay: Duration(milliseconds: 200 * index),
                      child: _buildEventCard(context, katha),
                    );
                  } else {
                    return FadeInRight(
                      animate: _isVisible,
                      delay: Duration(milliseconds: 200 * index),
                      child: _buildEventCard(context, katha),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 80),

            FadeInUp(
              animate: _isVisible,
              delay: const Duration(milliseconds: 800),
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F4C5C),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        side: BorderSide(color: const Color(0xFF0F4C5C).withOpacity(0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, UpcomingKatha katha) {
    final lang = Localizations.localeOf(context).languageCode;
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            transform: Matrix4.translationValues(0, isHovered ? -12 : 0, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border(top: BorderSide(color: const Color(0xFFC89A5B), width: isHovered ? 6 : 4)),
              boxShadow: [
                BoxShadow(
                  color: isHovered ? Colors.black.withOpacity(0.12) : Colors.black.withOpacity(0.04),
                  blurRadius: isHovered ? 40 : 20,
                  offset: Offset(0, isHovered ? 20 : 10),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => KathaHelper.showMoreDetails(context, katha, lang),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      KathaHelper.formatDateRange(katha, lang).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFC89A5B), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    const SizedBox(height: 20),
                    
                    // Animated Date Circle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: isHovered ? 70 : 60,
                      height: isHovered ? 70 : 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F4C5C),
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (isHovered) BoxShadow(color: const Color(0xFF0F4C5C).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Center(
                        child: Text(
                          katha.kathaNumber,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    Text(
                      katha.localizedName(lang),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F4C5C), height: 1.2),
                    ),
                    const SizedBox(height: 15),
                    
                    // Location Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F3EA),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Color(0xFFC89A5B)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              katha.localizedLocation(lang),
                              style: const TextStyle(color: Color(0xFF6D6D6D), fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Animated Detail Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.detailsArrow.replaceAll(' >', ''),
                          style: const TextStyle(color: Color(0xFFC89A5B), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 2),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(left: isHovered ? 12 : 6),
                          child: const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFFC89A5B)),
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
}
