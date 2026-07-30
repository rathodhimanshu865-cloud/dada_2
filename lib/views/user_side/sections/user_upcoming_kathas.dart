import 'package:flutter/material.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';
import '../../../utils/localization_helper.dart';
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
                  childAspectRatio: 1.0,
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
              onTap: () {
                Navigator.pushNamed(context, '/upcoming_ram_kathas');
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      katha.localizedDateString(lang).toUpperCase(),
                      style: AppTypography.bodyStyle(
                        context,
                        color: const Color(0xFFC89A5B),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isHovered ? 70 : 60,
                      height: isHovered ? 70 : 60,
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
                            fontSize: isHovered ? 24 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                          child: Text(katha.kathaNumber),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      katha.localizedName(lang),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyStyle(
                        context,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFC89A5B)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            katha.localizedLocation(lang),
                            style: AppTypography.bodyStyle(
                              context,
                              color: const Color(0xFF6D6D6D),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.detailsArrow.replaceAll(' >', ''),
                          style: AppTypography.bodyStyle(
                            context,
                            color: const Color(0xFFC89A5B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(left: isHovered ? 8 : 4),
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
