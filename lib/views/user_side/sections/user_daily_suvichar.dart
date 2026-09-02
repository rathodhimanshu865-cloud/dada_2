import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../utils/responsive_utils.dart';

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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.imageLinkCopied),
          behavior: SnackBarBehavior.floating,
        ),
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
    if (suvichar.imageUrl.isEmpty) return const SizedBox.shrink();

    final bool isMobile = Responsive.isMobile(context);
    final String lang = Localizations.localeOf(context).languageCode;
    final String dynamicDate = DateFormat('dd MMMM yyyy', lang).format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100, 
        horizontal: isMobile ? 20 : 40
      ),
      color: const Color(0xFFF6F3ED), // Soft cream background
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), 
                blurRadius: 30, 
                offset: const Offset(0, 10)
              ),
            ],
          ),
          child: Column(
            children: [
              // HEADER SECTION
              Container(
                padding: const EdgeInsets.symmetric(vertical: 35),
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF5F0E8), width: 1.5)
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.dadasDailySuvichar.toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFFC19A6B), 
                        letterSpacing: 2.5, 
                        fontWeight: FontWeight.w800, 
                        fontSize: isMobile ? 10 : 12
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      dynamicDate,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18, 
                        color: const Color(0xFF4A4A4A), 
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5
                      ),
                    ),
                  ],
                ),
              ),
              
              // IMAGE/CONTENT SECTION
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 30 : 50, 
                  horizontal: isMobile ? 20 : 60
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF5F0E8), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      suvichar.imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            color: const Color(0xFFC19A6B),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // ACTION FOOTER
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconBtn(
                      icon: Icons.share_outlined,
                      onTap: () => _shareContent(suvichar.imageUrl),
                      tooltip: AppLocalizations.of(context)!.shareLink,
                      isMobile: isMobile,
                    ),
                    const SizedBox(width: 30),
                    _buildIconBtn(
                      icon: Icons.download_rounded,
                      onTap: () => _downloadImage(suvichar.imageUrl),
                      tooltip: AppLocalizations.of(context)!.openToDownload,
                      isMobile: isMobile,
                    ),
                    const SizedBox(width: 30),
                    _buildIconBtn(
                      icon: _isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                      color: _isLiked ? Colors.redAccent : const Color(0xFFC19A6B),
                      onTap: () {
                        setState(() => _isLiked = !_isLiked);
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

  Widget _buildIconBtn({
    required IconData icon, 
    required VoidCallback onTap, 
    String? tooltip,
    Color? color,
    required bool isMobile,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: isMobile ? 50 : 56, 
        height: isMobile ? 50 : 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFC19A6B).withOpacity(0.15), width: 1),
          color: Colors.white,
        ),
        child: Icon(
          icon, 
          size: isMobile ? 20 : 22, 
          color: color ?? const Color(0xFFC19A6B)
        ),
      ),
    );
  }
}

