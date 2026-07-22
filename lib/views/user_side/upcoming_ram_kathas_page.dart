import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/language_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class UpcomingRamKathasPage extends StatefulWidget {
  const UpcomingRamKathasPage({super.key});

  @override
  State<UpcomingRamKathasPage> createState() => _UpcomingRamKathasPageState();
}

class _UpcomingRamKathasPageState extends State<UpcomingRamKathasPage> {
  int activeTab = 1; 
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

    return UserPageLayout(
      controller: controller,
      child: Column(
        children: [
          const SizedBox(height: 120),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 80),
            color: backgroundBeige.withOpacity(0.5),
            child: Column(
              children: [
                Text(AppLocalizations.of(context)!.upcomingKathas, style: TextStyle(fontSize: 52, fontFamily: 'serif', color: primaryTeal, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.homeKathasUpcoming, style: TextStyle(color: primaryTeal.withOpacity(0.6), fontSize: 16, letterSpacing: 0.5)),
              ],
            ),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tabButton(AppLocalizations.of(context)!.allKathas, activeTab == 0, () => Navigator.pushNamed(context, '/katha_list')),
              const SizedBox(width: 80),
              _tabButton(AppLocalizations.of(context)!.upcomingKathas2026, activeTab == 1, () {}),
            ],
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Column(
              children: [
                const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                ...controller.upcomingKathas.map((katha) => _buildUpcomingKathaRow(context, katha, lang)).toList(),
              ],
            ),
          ),
          const SizedBox(height: 100),
          UserFooter(controller: controller),
        ],
      ),
    );
  }

  Widget _tabButton(String title, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      child: Column(
        children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isActive ? primaryTeal : Colors.black45, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          AnimatedContainer(duration: const Duration(milliseconds: 300), height: 4, width: isActive ? 60 : 0, color: primaryTeal),
        ],
      ),
    );
  }

  Widget _buildUpcomingKathaRow(BuildContext context, UpcomingKatha katha, String lang) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.kathaPrefix, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(width: 10),
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: accentBrown, shape: BoxShape.circle, boxShadow: [BoxShadow(color: accentBrown.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]), child: Center(child: Text(katha.kathaNumber, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
                ],
              ),
              const SizedBox(width: 60),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(katha.localizedName(lang).toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF444444), letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text(katha.localizedDateString(lang).toUpperCase(), style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => _showMoreDetails(context, katha, lang),
                style: OutlinedButton.styleFrom(foregroundColor: accentBrown, side: BorderSide(color: accentBrown.withOpacity(0.5), width: 1.5), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                child: Text(AppLocalizations.of(context)!.moreDetails, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFEEEEEE)),
      ],
    );
  }

  void _showMoreDetails(BuildContext context, UpcomingKatha katha, String lang) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('${AppLocalizations.of(context)!.kathaPrefix} ${katha.kathaNumber} - ${katha.localizedName(lang)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryTeal, fontFamily: 'serif'))),
                  IconButton(icon: const Icon(Icons.close, size: 30), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              Container(width: 80, height: 3, color: accentBrown),
              const SizedBox(height: 40),
              _detailRow(AppLocalizations.of(context)!.kathaDate, katha.localizedDateString(lang)),
              _detailRow(AppLocalizations.of(context)!.kathaTiming, katha.timing),
              _detailRow(AppLocalizations.of(context)!.kathaLocation, katha.localizedLocation(lang)),
              _detailRow(AppLocalizations.of(context)!.kathaHosting, katha.hosting),
              const SizedBox(height: 40),
              Center(child: Container(width: 80, height: 1, color: Colors.grey[200])),
              const SizedBox(height: 30),
              Center(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20)), child: Text(AppLocalizations.of(context)!.close, style: const TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 180, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryTeal.withOpacity(0.8)))),
          Expanded(child: Text(value.isNotEmpty ? value : '-', style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4))),
        ],
      ),
    );
  }
}
