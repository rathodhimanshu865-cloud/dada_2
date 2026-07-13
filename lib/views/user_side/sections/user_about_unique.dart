import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';

class UserAboutUnique extends StatelessWidget {
  final HomePageController controller;
  const UserAboutUnique({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    const accentBrown = Color(0xFFC19A6B);
    final about = controller.aboutSection;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 60),
      color: backgroundBeige,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 900;
            
            return Flex(
              direction: isDesktop ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Unique Floating Image Column
                Expanded(
                  flex: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Decorative Background Shape
                      Transform.translate(
                        offset: const Offset(-20, 20),
                        child: Container(
                          width: 350,
                          height: 450,
                          decoration: BoxDecoration(
                            border: Border.all(color: accentBrown.withOpacity(0.3), width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      // The Main Photo
                      Container(
                        width: 350,
                        height: 450,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            about.photoUrl.isNotEmpty 
                              ? about.photoUrl 
                              : 'https://via.placeholder.com/400x500',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.white,
                              child: const Icon(Icons.person, size: 100, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (isDesktop) const SizedBox(width: 80) else const SizedBox(height: 60),

                // Professional Content Column
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 40, height: 2, color: accentBrown),
                          const SizedBox(width: 15),
                          const Text(
                            'MEET JIGNESH DADA',
                            style: TextStyle(
                              color: accentBrown,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'The Divine Voice of Radhe Radhe',
                        textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: primaryTeal,
                          fontFamily: 'serif',
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 35),
                      Text(
                        about.description.isNotEmpty 
                          ? about.description 
                          : "Shri Jigneshdada, affectionately known as 'Radhe Radhe' among millions of devotees, is a globally renowned spiritual leader and Bhagwat Katha orator.",
                        textAlign: isDesktop ? TextAlign.start : TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.8,
                          color: Color(0xFF444444),
                          letterSpacing: 0.2,
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/about_dada'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 8,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'LEARN MORE ABOUT DADA',
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            SizedBox(width: 15),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
