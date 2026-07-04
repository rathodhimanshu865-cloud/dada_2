import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import 'katha_calendar_view.dart';

class UserUpcomingKathas extends StatelessWidget {
  final HomePageController controller;
  const UserUpcomingKathas({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 100),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Upcoming Kathas',
                  style: TextStyle(
                    fontSize: 32, 
                    fontFamily: 'serif', 
                    color: primaryTeal,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu, size: 22, color: primaryTeal),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => KathaCalendarView(kathas: controller.upcomingKathas),
                          );
                        },
                        child: const Icon(Icons.grid_on_outlined, size: 22, color: primaryTeal),
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
                crossAxisCount: constraints.maxWidth > 800 ? 4 : 1,
                childAspectRatio: 1.5,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: controller.upcomingKathas.take(4).length,
              itemBuilder: (context, index) {
                final katha = controller.upcomingKathas[index];
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          katha.kathaNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: primaryTeal),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          katha.name, 
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          katha.dateString, 
                          style: const TextStyle(color: Colors.grey, fontSize: 11)
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/katha_list'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: const Text('VIEW ALL KATHAS'),
          ),
        ],
      ),
    );
  }
}
