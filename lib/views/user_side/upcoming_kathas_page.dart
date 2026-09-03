import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import 'sections/katha_calendar_view.dart';
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
  bool isListView = true;
  final int pageSize = 10;
  final primaryTeal = const Color(0xFF0F4C5C);
  final backgroundBeige = const Color(0xFFF9F3EA);
  final accentBrown = const Color(0xFFC19A6B);

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
          const SizedBox(height: 120),

          // ── Page hero banner ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100),
            decoration: BoxDecoration(
              color: backgroundBeige.withOpacity(0.4),
              image: const DecorationImage(
                image: NetworkImage('https://www.transparenttextures.com/patterns/natural-paper.png'),
                opacity: 0.05,
              ),
            ),
            child: Column(
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    AppLocalizations.of(context)!.upcomingKathas,
                    textAlign: TextAlign.center,
                    style: AppTypography.headingStyle(
                      context,
                      fontSize: isMobile ? 32 : 56,
                      fontWeight: FontWeight.w900,
                      color: primaryTeal,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 200),
                  child: Container(height: 1.5, width: 60, color: accentBrown),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    AppLocalizations.of(context)!.homeKathasUpcoming,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyStyle(
                      context,
                      color: primaryTeal.withOpacity(0.6),
                      fontSize: isMobile ? 14 : 16,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 40 : 80),

          // ── Tab row ───────────────────────────────────────────────────────
          Wrap(
            alignment: WrapAlignment.center,
            spacing: isMobile ? 20 : 60,
            runSpacing: 15,
            children: [
              _tabButton(
                AppLocalizations.of(context)!.allKathas,
                activeTab == 0,
                () => Navigator.pushNamed(context, '/katha_list'),
              ),
              _tabButton(
                AppLocalizations.of(context)!.upcomingKathas2026,
                activeTab == 1,
                () {},
              ),
            ],
          ),

          const SizedBox(height: 50),

          // ── View Toggle (List vs Calendar) ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _viewToggleItem(Icons.list_alt_rounded, "LIST", isListView, () => setState(() => isListView = true)),
              const SizedBox(width: 20),
              _viewToggleItem(Icons.calendar_month_outlined, "CALENDAR", !isListView, () => setState(() => isListView = false)),
            ],
          ),

          const SizedBox(height: 60),

          // ── Content Switcher ──────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: isListView 
              ? _buildListView(context, controller, lang, isMobile)
              : _buildCalendarView(context, controller),
          ),

          const SizedBox(height: 100),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _viewToggleItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? primaryTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isActive ? primaryTeal : Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isActive ? Colors.white : Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, HomePageController controller) {
    return FadeIn(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            const Icon(Icons.calendar_month_rounded, size: 40, color: Color(0xFFC19A6B)),
            const SizedBox(height: 20),
            Text(
              "Spiritual Calendar".toUpperCase(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 3, color: Color(0xFFC19A6B)),
            ),
            const SizedBox(height: 40),
            KathaCalendarView(kathas: controller.upcomingKathas),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context, HomePageController controller, String lang, bool isMobile) {
    final allKathas = controller.upcomingKathas.toList();
    allKathas.sort((a, b) {
      int aNum = int.tryParse(a.kathaNumber) ?? 0;
      int bNum = int.tryParse(b.kathaNumber) ?? 0;
      return aNum.compareTo(bNum);
    });

    final totalKathas = allKathas.length;
    final totalPages = (totalKathas / pageSize).ceil();
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

    final startIndex = (currentPage - 1) * pageSize;
    final paginatedKathas = allKathas.skip(startIndex).take(pageSize).toList();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40),
        child: Column(
          children: [
            const Divider(color: Color(0xFFEEEEEE), thickness: 1),
            if (paginatedKathas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text("No upcoming kathas found.", style: AppTypography.bodyStyle(context, color: Colors.grey)),
              )
            else
              ...paginatedKathas.asMap().entries.map((e) {
                return _buildUpcomingKathaRow(context, e.value, lang, isMobile, e.key);
              }),
            
            _buildPaginationControls(totalPages),
          ],
        ),
      ),
    );
  }

  // ── Shared tab button (matches katha_list_page.dart exactly) ──────────────
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

  // ── Individual katha row ─────────────────────────────────────────────────
  Widget _buildUpcomingKathaRow(
    BuildContext context,
    UpcomingKatha katha,
    String lang,
    bool isMobile,
    int index,
  ) {
    bool isLive = _checkIfLive(katha);

    return VisibilityDetector(
      key: Key('katha-row-${katha.kathaNumber}-$index'),
      onVisibilityChanged: (info) {
        // Handled by animate_do internal logic via parent visibility usually, 
        // but since we are in a scroll list, we just wrap it in FadeInUp.
      },
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        delay: Duration(milliseconds: (index % 5) * 100),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24 : 40,
                horizontal: 20,
              ),
              child: isMobile
                  ? _buildMobileKathaRow(context, katha, lang, isLive)
                  : _buildDesktopKathaRow(context, katha, lang, isLive),
            ),
            const Divider(color: Color(0xFFEEEEEE)),
          ],
        ),
      ),
    );
  }

  bool _checkIfLive(UpcomingKatha katha) {
    if (katha.startDate == null || katha.endDate == null) return false;
    final now = DateTime.now();
    // Normalize to dates only for comparison if needed, or use full timestamps
    return now.isAfter(katha.startDate!) && now.isBefore(katha.endDate!.add(const Duration(days: 1)));
  }

  Widget _buildDesktopKathaRow(
    BuildContext context,
    UpcomingKatha katha,
    String lang,
    bool isLive,
  ) {
    return Row(
      children: [
        // Katha number badge
        SizedBox(
          width: 140,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.kathaPrefix,
                style: AppTypography.bodyStyle(context, color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(width: 12),
              _kathaNumberBadge(katha.kathaNumber),
            ],
          ),
        ),
        const SizedBox(width: 40),

        // Name + date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      katha.localizedName(lang).toUpperCase(),
                      style: AppTypography.bodyStyle(
                        context,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF333333),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  if (isLive) ...[
                    const SizedBox(width: 15),
                    const _LivePulse(),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                KathaHelper.formatDateRange(katha, lang).toUpperCase(),
                style: AppTypography.bodyStyle(
                  context,
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        // Location Info with Bounce Animation
        _LocationItem(location: katha.localizedLocation(lang), accentBrown: accentBrown),

        const SizedBox(width: 40),

        // More Details button
        OutlinedButton(
          onPressed: () => KathaHelper.showMoreDetails(context, katha, lang),
          style: OutlinedButton.styleFrom(
            foregroundColor: accentBrown,
            side: BorderSide(color: accentBrown.withOpacity(0.4), width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Text(
            AppLocalizations.of(context)!.moreDetails,
            style: AppTypography.bodyStyle(
              context,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileKathaRow(
    BuildContext context,
    UpcomingKatha katha,
    String lang,
    bool isLive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.kathaPrefix,
                  style: AppTypography.bodyStyle(context, color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(width: 10),
                _kathaNumberBadge(katha.kathaNumber),
              ],
            ),
            if (isLive) const _LivePulse(),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          katha.localizedName(lang).toUpperCase(),
          style: AppTypography.bodyStyle(
            context,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF333333),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          KathaHelper.formatDateRange(katha, lang).toUpperCase(),
          style: AppTypography.bodyStyle(
            context,
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.location_on, size: 14, color: accentBrown),
            const SizedBox(width: 6),
            Expanded(child: Text(katha.localizedLocation(lang), style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600))),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => KathaHelper.showMoreDetails(context, katha, lang),
            style: OutlinedButton.styleFrom(
              foregroundColor: accentBrown,
              side: BorderSide(color: accentBrown.withOpacity(0.5), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(
              AppLocalizations.of(context)!.moreDetails,
              style: AppTypography.bodyStyle(
                context,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _kathaNumberBadge(String number) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: accentBrown,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: accentBrown.withValues(alpha: 0.2),
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

  // ── Pagination Controls ───────────────────────────────────────────────────
  Widget _buildPaginationControls(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          _pageNavButton(
            AppLocalizations.of(context)!.previous,
            currentPage > 1 ? () => setState(() => currentPage--) : null,
            isIcon: true,
            icon: Icons.chevron_left,
          ),
          const SizedBox(width: 20),
          
          // Page Numbers
          ...List.generate(totalPages, (index) {
            int pageNum = index + 1;
            bool isActive = pageNum == currentPage;
            
            // For many pages, we might want to truncate, but for now 
            // we show all as typical for this site's scale
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
          // Next Button
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

class _LivePulse extends StatefulWidget {
  const _LivePulse();

  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    _scale = Tween<double>(begin: 1.0, end: 2.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.8, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
            Container(
              width: 10, height: 10,
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
            ),
          ],
        ),
        const SizedBox(width: 8),
        const Text(
          "LIVE NOW", 
          style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)
        ),
      ],
    );
  }
}

class _LocationItem extends StatelessWidget {
  final String location;
  final Color accentBrown;
  const _LocationItem({required this.location, required this.accentBrown});

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('loc-${location.hashCode}'),
      onVisibilityChanged: (info) {},
      child: FadeInUp(
        duration: const Duration(milliseconds: 800),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F3EA),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElasticIn(
                duration: const Duration(milliseconds: 1200),
                manualTrigger: false,
                child: Icon(Icons.location_on, size: 14, color: accentBrown),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  location,
                  style: const TextStyle(
                    color: Color(0xFF6D6D6D),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

