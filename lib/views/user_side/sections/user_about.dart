import 'package:flutter/material.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../../controllers/homepage_controller.dart';

class UserAbout extends StatelessWidget {
  final HomePageController controller;
  const UserAbout({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    final about = controller.aboutSection;
    final lang = Localizations.localeOf(context).languageCode;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: backgroundBeige,
      child: LayoutBuilder(builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;
        
        Widget imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            about.photoUrl.isNotEmpty 
              ? about.photoUrl 
              : 'https://via.placeholder.com/400x500',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.white,
              height: 400,
              width: double.infinity,
              child: const Icon(Icons.person, size: 100, color: Colors.grey),
            ),
          ),
        );

        return Flex(
          direction: isDesktop ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
              Expanded(
                flex: 1,
                child: imageWidget,
              ),
              const SizedBox(width: 60),
            ],
            if (!isDesktop) ...[
              imageWidget,
              const SizedBox(height: 40),
            ],
            if (isDesktop)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.aboutDada,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryTeal, fontFamily: 'serif'),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      about.localizedDescription(lang).isNotEmpty
                        ? about.localizedDescription(lang)
                        : 'Shri Jigneshdada, affectionately known as "Radhe Radhe", is one of the most respected and influential contemporary Bhagwatcharyas. He is widely admired as a torchbearer of Sanatan Dharma...',
                      style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/about_katha'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      ),
                      child: Text(AppLocalizations.of(context)!.readMore),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.aboutDada,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryTeal, fontFamily: 'serif'),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    about.localizedDescription(lang).isNotEmpty
                      ? about.localizedDescription(lang)
                      : 'Shri Jigneshdada, affectionately known as "Radhe Radhe", is one of the most respected and influential contemporary Bhagwatcharyas. He is widely admired as a torchbearer of Sanatan Dharma...',
                    style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/about_katha'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    ),
                    child: Text(AppLocalizations.of(context)!.readMore),
                  ),
                ],
              ),
          ],
        );
      }),
    );
  }
}

