import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import 'katha_calendar_view.dart';

class UserUpcomingKathas extends StatelessWidget {
  final HomePageController controller;
  const UserUpcomingKathas({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 100),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Upcoming Kathas',
                  style: TextStyle(
                    fontSize: 32, 
                    fontFamily: 'serif', 
                    color: Color(0xFF444444),
                    letterSpacing: 0.5,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu, size: 22, color: Color(0xFF444444)),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => KathaCalendarView(kathas: controller.upcomingKathas),
                          );
                        },
                        child: const Icon(Icons.grid_on_outlined, size: 22, color: Color(0xFF444444)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth > 800 ? 2 : 1,
                childAspectRatio: 4.5,
                crossAxisSpacing: 80,
                mainAxisSpacing: 40,
              ),
              itemCount: controller.upcomingKathas.length,
              itemBuilder: (context, index) {
                final katha = controller.upcomingKathas[index];
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              katha.kathaNumber,
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                katha.name, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF333333))
                              ),
                              const SizedBox(height: 2),
                              Text(
                                katha.dateString, 
                                style: const TextStyle(color: Color(0xFFC19A6B), fontSize: 13, fontWeight: FontWeight.w500)
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
