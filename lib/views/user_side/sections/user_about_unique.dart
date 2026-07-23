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
