import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../controllers/homepage_controller.dart';

class UserDailySuvichar extends StatefulWidget {
  final HomePageController controller;
  const UserDailySuvichar({super.key, required this.controller});

  @override
  State<UserDailySuvichar> createState() => _UserDailySuvicharState();
}

class _UserDailySuvicharState extends State<UserDailySuvichar> {
  bool _isLiked = false;

  Future<void> _shareContent(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.imageLinkCopied)),
      );
    }
  }

  Future<void> _downloadImage(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suvichar = widget.controller.dailySuvichar;
    final lang = Localizations.localeOf(context).languageCode;
    if (suvichar.imageUrl.isEmpty) return const SizedBox.shrink();

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 120, horizontal: isMobile ? 15 : 40),
      color: const Color(0xFFF3EEE6),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20)),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF2ECE3))),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dadasDailySuvichar,
                        style: TextStyle(color: const Color(0xFFC89A5B), letterSpacing: isMobile ? 2 : 4, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        suvichar.localizedDate(lang),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: isMobile ? 14 : 16, color: const Color(0xFF6D6D6D), fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Image
              Padding(
                padding: EdgeInsets.all(isMobile ? 15 : 40),
                child: ClipRRect(
                  child: Image.network(
                    suvichar.imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
              
              // Footer Action
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.share_outlined,
                      onTap: () => _shareContent(suvichar.imageUrl),
                      tooltip: AppLocalizations.of(context)!.shareLink,
                      isMobile: isMobile,
                    ),
                    SizedBox(width: isMobile ? 20 : 40),
                    _buildActionButton(
                      icon: Icons.download_outlined,
                      onTap: () => _downloadImage(suvichar.imageUrl),
                      tooltip: AppLocalizations.of(context)!.openToDownload,
                      isMobile: isMobile,
                    ),
                    SizedBox(width: isMobile ? 20 : 40),
                    _buildActionButton(
                      icon: _isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                      color: _isLiked ? Colors.red : const Color(0xFFC89A5B),
                      onTap: () {
                        setState(() {
                          _isLiked = !_isLiked;
                        });
                      },
                      tooltip: AppLocalizations.of(context)!.like,
                      isMobile: isMobile,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon, 
    required VoidCallback onTap, 
    String? tooltip,
    Color? color,
    required bool isMobile,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: isMobile ? 50 : 60, 
          height: isMobile ? 50 : 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFC89A5B).withOpacity(0.2)),
          ),
          child: Icon(icon, size: isMobile ? 22 : 26, color: color ?? const Color(0xFFC89A5B)),
        ),
      ),
    );
  }
}

