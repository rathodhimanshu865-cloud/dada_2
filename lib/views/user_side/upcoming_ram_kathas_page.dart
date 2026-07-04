import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_header.dart';
import 'sections/user_footer.dart';

class UpcomingRamKathasPage extends StatefulWidget {
  const UpcomingRamKathasPage({super.key});

  @override
  State<UpcomingRamKathasPage> createState() => _UpcomingRamKathasPageState();
}

class _UpcomingRamKathasPageState extends State<UpcomingRamKathasPage> {
  int activeTab = 1; // 0 for All Kathas, 1 for Upcoming Kathas
  
  final primaryTeal = const Color(0xFF0F4C5C);
  final backgroundBeige = const Color(0xFFF9F3EA);
  final accentBrown = const Color(0xFFC19A6B);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);
    
    if (controller.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: primaryTeal)));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),
            
            // Hero Title Section (Exactly like All Kathas page)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 80),
              color: backgroundBeige.withOpacity(0.5),
              child: Column(
                children: [
                  Text(
                    'Upcoming Kathas',
                    style: TextStyle(fontSize: 52, fontFamily: 'serif', color: primaryTeal, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Home > Ram Katha > Upcoming Kathas', style: TextStyle(color: primaryTeal.withOpacity(0.6), fontSize: 16, letterSpacing: 0.5)),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Tab Switcher (Exactly like All Kathas page)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tabButton('All Kathas', activeTab == 0, () => Navigator.pushNamed(context, '/katha_list')),
                const SizedBox(width: 80),
                _tabButton('Upcoming Kathas 2026', activeTab == 1, () {}),
              ],
            ),
            
            const SizedBox(height: 60),
            
            // List of Upcoming Kathas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Column(
                children: [
                   // Decorative line matching the style
                  const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                  ...controller.upcomingKathas.map((katha) => _buildUpcomingKathaRow(context, katha)).toList(),
                ],
              ),
            ),

            const SizedBox(height: 100),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String title, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 18, 
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? primaryTeal : Colors.black45,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4, 
            width: isActive ? 60 : 0, 
            color: primaryTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingKathaRow(BuildContext context, UpcomingKatha katha) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Row(
            children: [
              // Circular ID with Label (Bigger fonts)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Katha ', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentBrown, 
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: accentBrown.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                      ]
                    ),
                    child: Center(
                      child: Text(
                        katha.kathaNumber,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 60),
              
              // Details (Bigger fonts)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      katha.name.toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF444444), letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      katha.dateString.toUpperCase(),
                      style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),

              // Action Button (Styled like All Kathas page buttons)
              OutlinedButton(
                onPressed: () => _showMoreDetails(context, katha),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentBrown,
                  side: BorderSide(color: accentBrown.withOpacity(0.5), width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('More Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFEEEEEE)),
      ],
    );
  }

  void _showMoreDetails(BuildContext context, UpcomingKatha katha) {
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
                  Expanded(
                    child: Text(
                      'Katha ${katha.kathaNumber} - ${katha.name}',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryTeal, fontFamily: 'serif'),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close, size: 30), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              Container(width: 80, height: 3, color: accentBrown),
              const SizedBox(height: 40),
              
              _detailRow('Katha Date', katha.dateString),
              _detailRow('Katha Timing', katha.timing),
              _detailRow('Katha Location', katha.location),
              _detailRow('Katha Hosting', katha.hosting),
              
              const SizedBox(height: 40),
              Center(child: Container(width: 80, height: 1, color: Colors.grey[200])),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                  child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
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
          SizedBox(
            width: 180, 
            child: Text(
              label, 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryTeal.withOpacity(0.8))
            )
          ),
          Expanded(child: Text(value.isNotEmpty ? value : '-', style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4))),
        ],
      ),
    );
  }
}
