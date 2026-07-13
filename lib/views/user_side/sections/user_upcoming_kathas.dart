import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';

class UserUpcomingKathas extends StatelessWidget {
  final HomePageController controller;
  const UserUpcomingKathas({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.upcomingKathas.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      color: const Color(0xFFF3EEE6),
      child: Column(
        children: [
          // Section Header
          Column(
            children: [
              const Text(
                "SPIRITUAL CALENDAR",
                style: TextStyle(color: Color(0xFFC89A5B), letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 20),
              const Text(
                "Upcoming Kathas",
                style: TextStyle(fontSize: 42, fontFamily: 'serif', fontWeight: FontWeight.w900, color: Color(0xFF0F4C5C)),
              ),
              const SizedBox(height: 30),
              Container(height: 1, width: 80, color: const Color(0xFFC89A5B)),
            ],
          ),
          
          const SizedBox(height: 80),

          // Well-arranged Grid of Cards
          Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: LayoutBuilder(builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1000 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 25,
                  childAspectRatio: 1.0, // Making boxes a bit smaller and more square
                ),
                itemCount: controller.upcomingKathas.take(3).length,
                itemBuilder: (context, index) => _buildEventCard(controller.upcomingKathas[index]),
              );
            }),
          ),
          
          const SizedBox(height: 60),
          
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/upcoming_ram_kathas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4C5C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('VIEW ALL UPCOMING KATHAS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(UpcomingKatha katha) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          // Calendar Icon in top-right corner
          const Positioned(
            top: 15, right: 15,
            child: Icon(Icons.calendar_month_outlined, color: Color(0xFFC89A5B), size: 24),
          ),

          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  katha.dateString.toUpperCase(),
                  style: const TextStyle(color: Color(0xFFC89A5B), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 20),
                Text(
                  katha.kathaNumber,
                  style: TextStyle(color: const Color(0xFF0F4C5C).withOpacity(0.3), fontSize: 40, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 15),
                Text(
                  katha.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), fontFamily: 'serif'),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFC89A5B)),
                    const SizedBox(width: 8),
                    Flexible(child: Text(katha.location, style: const TextStyle(color: Color(0xFF6D6D6D), fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "DETAILS >",
                  style: TextStyle(color: Color(0xFFC89A5B), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
