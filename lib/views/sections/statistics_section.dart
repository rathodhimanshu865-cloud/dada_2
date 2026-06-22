import 'package:flutter/material.dart';
import '../../controllers/homepage_controller.dart';

class StatisticsSection extends StatelessWidget {
  final HomePageController controller;
  const StatisticsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        title: const Text('Impact Statistics', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: const Text('Numerical counters for global reach', style: TextStyle(fontSize: 12)),
        leading: const Icon(Icons.analytics_outlined, color: Colors.black),
        childrenPadding: const EdgeInsets.all(20),
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Total Kathas', hintText: '0'),
                keyboardType: TextInputType.number,
                onChanged: (v) => controller.statistics.totalKathas = int.tryParse(v) ?? 0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Total Countries', hintText: '0'),
                keyboardType: TextInputType.number,
                onChanged: (v) => controller.statistics.totalCountries = int.tryParse(v) ?? 0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Total Cities', hintText: '0'),
                keyboardType: TextInputType.number,
                onChanged: (v) => controller.statistics.totalCities = int.tryParse(v) ?? 0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Total Devotees', hintText: '0'),
                keyboardType: TextInputType.number,
                onChanged: (v) => controller.statistics.totalDevotees = int.tryParse(v) ?? 0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
