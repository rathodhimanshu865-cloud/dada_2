import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/homepage_model.dart';
import 'sections/user_header.dart';
import 'sections/user_footer.dart';

class UpcomingRamKathasPage extends StatelessWidget {
  const UpcomingRamKathasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context);

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.black)));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Upcoming Ram Kathas',
                        style: TextStyle(
                          fontSize: 36,
                          fontFamily: 'serif',
                          color: Color(0xFF444444),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Home > Ram Katha > Upcoming Ram Kathas', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/katha_list'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF444444)),
                    child: const Text('View All Kathas'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Column(
                children: controller.upcomingKathas.map((katha) => _UpcomingKathaCard(katha: katha)).toList(),
              ),
            ),
            const SizedBox(height: 80),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _UpcomingKathaCard extends StatelessWidget {
  final UpcomingKatha katha;
  const _UpcomingKathaCard({required this.katha});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: Color(0xFF9C755F), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    katha.kathaNumber,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      katha.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      katha.dateString,
                      style: const TextStyle(color: Color(0xFF9C755F), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _showDetails(context, katha),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF9C755F),
                  side: const BorderSide(color: Color(0xFF9C755F)),
                  elevation: 0,
                ),
                child: const Text('More Details'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, UpcomingKatha katha) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Katha ${katha.kathaNumber} - ${katha.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Katha Date', katha.dateString),
            _detailRow('Katha Timing', katha.timing),
            _detailRow('Katha Location', katha.location),
            _detailRow('Katha Hosting', katha.hosting),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(child: Text(value.isNotEmpty ? value : '-', style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
