import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';

class UserDonationCTA extends StatelessWidget {
  final HomePageController controller;
  const UserDonationCTA({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(40),
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 60),
      decoration: BoxDecoration(
        color: const Color(0xFF0F4C5C),
        borderRadius: BorderRadius.circular(4),
        image: const DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
          opacity: 0.05,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        children: [
          const Text(
            "SUPPORT THE MISSION",
            style: TextStyle(color: Color(0xFFC89A5B), letterSpacing: 6, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 30),
          const Text(
            "Join us in spreading the eternal \nwisdom of Sanatan Dharma.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 42,
              fontFamily: 'serif',
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC89A5B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              elevation: 20,
              shadowColor: Colors.black.withOpacity(0.5),
            ),
            child: const Text('CONTRIBUTE NOW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }
}
