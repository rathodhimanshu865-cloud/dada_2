import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import '../../utils/app_typography.dart';
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
  final backgroundBeige = const Color(0xFFF9F3EA);
  final accentBrown = const Color(0xFFC19A6B);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);

    if (controller.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),

          // ── Page hero banner ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80),
            color: backgroundBeige.withValues(alpha: 0.5),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.upcomingKathas,
                  style: AppTypography.headingStyle(
                    context,
                    fontSize: AppTypography.getResponsiveSize(
                      context,
                      desktop: 52,
                      tablet: 44,
                      mobile: 34,
                    ),
                    fontWeight: FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.homeKathasUpcoming,
                  style: AppTypography.bodyStyle(
                    context,
                    color: primaryTeal.withValues(alpha: 0.6),
                    fontSize: isMobile ? 14 : 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 30 : 60),

          // ── Tab row ───────────────────────────────────────────────────────
          Wrap(
            alignment: WrapAlignment.center,
            spacing: isMobile ? 20 : 80,
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

          SizedBox(height: isMobile ? 30 : 60),

          // ── Katha list ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100),
            child: Builder(
              builder: (context) {
                final allKathas = controller.upcomingKathas.toList();
                // Ensure list starts from number 1 visually/ordering-wise if possible
                allKathas.sort((a, b) {
                  int aNum = int.tryParse(a.kathaNumber) ?? 0;
                  int bNum = int.tryParse(b.kathaNumber) ?? 0;
                  return aNum.compareTo(bNum);
                });

                final totalKathas = allKathas.length;
                final totalPages = (totalKathas / pageSize).ceil();
                
                // Adjust currentPage if out of bounds
                if (currentPage > totalPages && totalPages > 0) {
                  currentPage = totalPages;
                }

                final startIndex = (currentPage - 1) * pageSize;
                final paginatedKathas = allKathas.skip(startIndex).take(pageSize).toList();

                return Column(
                  children: [
                    const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    if (paginatedKathas.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text("No upcoming kathas found.", style: AppTypography.bodyStyle(context, color: Colors.grey)),
                      )
                    else
                      ...paginatedKathas.map((katha) => _buildUpcomingKathaRow(context, katha, lang, isMobile)),
                    
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
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 24 : 40,
            horizontal: 20,
          ),
          child: isMobile
              ? _buildMobileKathaRow(context, katha, lang)
              : _buildDesktopKathaRow(context, katha, lang),
        ),
        const Divider(color: Color(0xFFEEEEEE)),
      ],
    );
  }

  Widget _buildDesktopKathaRow(
    BuildContext context,
    UpcomingKatha katha,
    String lang,
  ) {
    return Row(
      children: [
        // Katha number badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.kathaPrefix,
              style: AppTypography.bodyStyle(
                context,
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 10),
            _kathaNumberBadge(katha.kathaNumber),
          ],
        ),
        const SizedBox(width: 60),

        // Name + date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                katha.localizedName(lang).toUpperCase(),
                style: AppTypography.bodyStyle(
                  context,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF333333),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDateRange(katha, lang).toUpperCase(),
                style: AppTypography.bodyStyle(
                  context,
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // More Details button
        OutlinedButton(
          onPressed: () => _showMoreDetails(context, katha, lang),
          style: OutlinedButton.styleFrom(
            foregroundColor: accentBrown,
            side: BorderSide(color: accentBrown.withValues(alpha: 0.5), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Text(
            AppLocalizations.of(context)!.moreDetails,
            style: AppTypography.bodyStyle(
              context,
              fontSize: 14,
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          _formatDateRange(katha, lang).toUpperCase(),
          style: AppTypography.bodyStyle(
            context,
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => _showMoreDetails(context, katha, lang),
          style: OutlinedButton.styleFrom(
            foregroundColor: accentBrown,
            side: BorderSide(color: accentBrown.withValues(alpha: 0.5), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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

  Widget _kathaNumberBadge(String number) {
    return Container(
      width: 44,
      height: 44,
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
    );
  }

  // ── Details dialog ────────────────────────────────────────────────────────
  void _showMoreDetails(BuildContext context, UpcomingKatha katha, String lang) {
    showDialog(
      context: context,
      builder: (context) {
        final isMobile = MediaQuery.of(context).size.width < 900;
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
                  _detailRow(AppLocalizations.of(context)!.kathaDate, _formatDateRange(katha, lang), isMobile),
                  _detailRow(AppLocalizations.of(context)!.kathaTiming, katha.timing, isMobile),
                  _detailRow(AppLocalizations.of(context)!.kathaLocation, katha.localizedLocation(lang), isMobile),
                  _detailRow(AppLocalizations.of(context)!.kathaHosting, katha.hosting, isMobile),
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

  Widget _detailRow(String label, String value, bool isMobile) {
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

  String _formatDateRange(UpcomingKatha katha, String lang) {
    if (katha.startDate != null && katha.endDate != null) {
      final start = DateFormat('dd MMM yyyy').format(katha.startDate!);
      final end = DateFormat('dd MMM yyyy').format(katha.endDate!);
      if (start == end) return start;
      return '$start - $end';
    }
    return katha.localizedDateString(lang);
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
            AppLocalizations.of(context)!.previous ?? "PREVIOUS", 
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
            AppLocalizations.of(context)!.next ?? "NEXT", 
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
