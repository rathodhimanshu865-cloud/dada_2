import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import 'katha_calendar_view.dart';

class UserUpcomingKathas extends StatelessWidget {
  final HomePageController controller;
  const UserUpcomingKathas({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const accentBrown = Color(0xFFC19A6B);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 60),
      child: Column(
        children: [
          // Section Header with View Switchers
          Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 100), // Spacer for balance
                Column(
                  children: [
                    const Text(
                      'Upcoming Kathas',
                      style: TextStyle(
                        fontSize: 36, 
                        fontFamily: 'serif', 
                        color: primaryTeal,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(width: 60, height: 3, color: accentBrown),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.list_alt_rounded, size: 28),
                      color: primaryTeal.withOpacity(0.5),
                      onPressed: () => Navigator.pushNamed(context, '/upcoming_ram_kathas'),
                      tooltip: 'List View',
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.grid_view_rounded, size: 28),
                      color: primaryTeal,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => KathaCalendarView(kathas: controller.upcomingKathas),
                        );
                      },
                      tooltip: 'Calendar View',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 80),
          
          // Responsive Grid of Katha Cards
          Container(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: LayoutBuilder(builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1100 ? 4 : (constraints.maxWidth > 700 ? 2 : 1);
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 25,
                  childAspectRatio: 0.85,
                ),
                itemCount: controller.upcomingKathas.take(4).length,
                itemBuilder: (context, index) {
                  final katha = controller.upcomingKathas[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06), 
                          blurRadius: 20, 
                          offset: const Offset(0, 10)
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Brown Circular ID
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accentBrown,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: accentBrown.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                            ]
                          ),
                          child: Center(
                            child: Text(
                              katha.kathaNumber,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Location/Name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            katha.name.toUpperCase(), 
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 18, 
                              color: Color(0xFF333333),
                              letterSpacing: 1,
                            )
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // Date
                        Text(
                          katha.dateString.toUpperCase(), 
                          style: TextStyle(
                            color: primaryTeal.withOpacity(0.6), 
                            fontSize: 13, 
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          )
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Details Link
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, '/upcoming_ram_kathas'),
                          child: Text(
                            'MORE DETAILS >',
                            style: TextStyle(
                              color: accentBrown,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          
          const SizedBox(height: 80),
          
          // Main Action Button
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/katha_list'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 5,
            ),
            child: const Text(
              'VIEW ALL KATHAS', 
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)
            ),
          ),
        ],
      ),
    );
  }
}
