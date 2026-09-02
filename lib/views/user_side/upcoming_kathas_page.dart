import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import '../../utils/app_typography.dart';
import '../../utils/katha_helper.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class UpcomingRamKathasPage extends StatefulWidget {
  const UpcomingRamKathasPage({super.key});

  @override
  State<UpcomingRamKathasPage> createState() => _UpcomingRamKathasPageState();
}

class _UpcomingRamKathasPageState extends State<UpcomingRamKathasPage> {
  int activeTab = 1;
  int currentPage = 1;
  final int pageSize = 10;
  final primaryTeal = const Color(0xFF0F4C5C);
  final backgroundBeige = const Color(0xFFFDFBF7);
  final templeGold = const Color(0xFFC89A5B);
  final accentBrown = const Color(0xFF8B4513);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);

    if (controller.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 100),

          // ── Page hero banner ──────────────────────────────────────────────
          _buildHeroBanner(context, isMobile),

          const SizedBox(height: 60),

          // ── Tab row ───────────────────────────────────────────────────────
          Wrap(
            alignment: WrapAlignment.center,
            spacing: isMobile ? 20 : 80,
            runSpacing: 15,
            children: [
              _tabButton(
                AppLocalizations.of(context)!.listView,
                activeTab == 0,
                () => Navigator.pushNamed(context, '/katha_list'),
              ),
              _tabButton(
                AppLocalizations.of(context)!.calendar,
                activeTab == 1,
                () {},
              ),
            ],
          ),

          const SizedBox(height: 60),

          // ── Katha list ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
            child: Builder(
              builder: (context) {
                final allKathas = controller.upcomingKathas.toList();
                allKathas.sort((a, b) {
                  int aNum = int.tryParse(a.kathaNumber) ?? 0;
                  int bNum = int.tryParse(b.kathaNumber) ?? 0;
                  return aNum.compareTo(bNum);
                });

                final totalKathas = allKathas.length;
                final totalPages = (totalKathas / pageSize).ceil();
                
                if (currentPage > totalPages && totalPages > 0) {
                  currentPage = totalPages;
                }

                final startIndex = (currentPage - 1) * pageSize;
                final paginatedKathas = allKathas.skip(startIndex).take(pageSize).toList();

                if (paginatedKathas.isEmpty) {
                  return _buildEmptyState(context);
                }

                return Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 700,
                        mainAxisExtent: isMobile ? 320 : 340,
                        crossAxisSpacing: 30,
                        mainAxisSpacing: 30,
                      ),
                      itemCount: paginatedKathas.length,
                      itemBuilder: (context, index) => _buildKathaCard(context, paginatedKathas[index], lang, isMobile),
                    ),
                    _buildPaginationControls(totalPages),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 100),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isMobile) {
    return Stack(
      children: [
        Container(
          height: isMobile ? 300 : 450,
          width: double.infinity,
          decoration: BoxDecoration(
            color: primaryTeal,
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1542332213-9b5a5a3fab35?auto=format&fit=crop&q=80&w=2000'),
              fit: BoxFit.cover,
              opacity: 0.2,
            ),
          ),
        ),
        Container(
          height: isMobile ? 300 : 450,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryTeal.withOpacity(0.8), primaryTeal],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: templeGold.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  AppLocalizations.of(context)!.spiritualCalendar.toUpperCase(),
                  style: TextStyle(color: templeGold, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.upcomingKathas,
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: isMobile ? 42 : 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Join us in these divine assemblies of spiritual enlightenment and grace.",
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyStyle(
                    context,
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isMobile ? 14 : 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            "No upcoming kathas found.", 
            style: AppTypography.bodyStyle(context, color: Colors.grey.shade500, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildKathaCard(BuildContext context, UpcomingKatha katha, String lang, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kathaNumberBadge(katha.kathaNumber),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            katha.localizedName(lang).toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyStyle(
                              context,
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.w800,
                              color: primaryTeal,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _infoItem(Icons.calendar_today_outlined, KathaHelper.formatDateRange(katha, lang)),
                          const SizedBox(height: 8),
                          _infoItem(Icons.location_on_outlined, katha.localizedLocation(lang)),
                          const SizedBox(height: 8),
                          _infoItem(Icons.person_outline, katha.localizedHosting(lang)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF9F9F9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      katha.localizedTiming(lang),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => KathaHelper.showMoreDetails(context, katha, lang),
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.detailsArrow.toUpperCase(),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: templeGold, letterSpacing: 1),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 10, color: templeGold),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: templeGold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _tabButton(String title, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.bodyStyle(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isActive ? primaryTeal : Colors.black45,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            width: isActive ? 60 : 0,
            color: primaryTeal,
          ),
        ],
      ),
    );
  }

  Widget _kathaNumberBadge(String number) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: templeGold,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: templeGold.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            number,
            style: AppTypography.bodyStyle(
              context,
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageNavButton(
            AppLocalizations.of(context)!.previous,
            currentPage > 1 ? () => setState(() => currentPage--) : null,
            isIcon: true,
            icon: Icons.chevron_left,
          ),
          const SizedBox(width: 20),
          
          ...List.generate(totalPages, (index) {
            int pageNum = index + 1;
            bool isActive = pageNum == currentPage;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: InkWell(
                onTap: () => setState(() => currentPage = pageNum),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: isActive ? primaryTeal : Colors.transparent,
                    border: Border.all(color: isActive ? primaryTeal : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      "$pageNum",
                      style: AppTypography.bodyStyle(
                        context,
                        color: isActive ? Colors.white : primaryTeal,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          
          const SizedBox(width: 20),
          _pageNavButton(
            AppLocalizations.of(context)!.next,
            currentPage < totalPages ? () => setState(() => currentPage++) : null,
            isIcon: true,
            icon: Icons.chevron_right,
            isNext: true,
          ),
        ],
      ),
    );
  }

  Widget _pageNavButton(String label, VoidCallback? onTap, {bool isIcon = false, IconData? icon, bool isNext = false}) {
    bool isDisabled = onTap == null;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: isDisabled ? Colors.grey[200]! : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            if (isIcon && icon != null && !isNext) Icon(icon, size: 18, color: isDisabled ? Colors.grey[300] : primaryTeal),
            if (isIcon && icon != null && !isNext) const SizedBox(width: 5),
            Text(
              label.toUpperCase(),
              style: AppTypography.bodyStyle(
                context,
                color: isDisabled ? Colors.grey[300] : primaryTeal,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            if (isIcon && icon != null && isNext) const SizedBox(width: 5),
            if (isIcon && icon != null && isNext) Icon(icon, size: 18, color: isDisabled ? Colors.grey[300] : primaryTeal),
          ],
        ),
      ),
    );
  }
}
