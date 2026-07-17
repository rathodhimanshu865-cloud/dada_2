import 'package:flutter/material.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../models/homepage_model.dart';

class UserTeachings extends StatelessWidget {
  final HomePageController controller;
  const UserTeachings({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final teachings = controller.homepageData.teachings;
    if (teachings.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 40),
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Column(
            children: [
              const Text(
                "ETERNAL WISDOM",
                style: TextStyle(color: Color(0xFFC89A5B), letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 20),
              const Text(
                "Spiritual Teachings",
                style: TextStyle(fontSize: 42, fontFamily: 'serif', fontWeight: FontWeight.w900, color: Color(0xFF0F4C5C)),
              ),
              const SizedBox(height: 30),
              Container(height: 1, width: 80, color: const Color(0xFFC89A5B)),
            ],
          ),
          const SizedBox(height: 80),
          // Teaching Grid
          Container(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: LayoutBuilder(builder: (context, constraints) {
              int cols = constraints.maxWidth > 1100 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                  childAspectRatio: 0.8,
                ),
                itemCount: teachings.length,
                itemBuilder: (context, index) => _buildTeachingCard(context, teachings[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTeachingCard(BuildContext context, TeachingCard teaching) {
    final lang = Localizations.localeOf(context).languageCode;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F4),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 25, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF3EEE6),
              child: teaching.image.isNotEmpty
                ? Image.network(teaching.image, fit: BoxFit.cover)
                : const Icon(Icons.auto_awesome_rounded, size: 60, color: Color(0xFFC89A5B)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teaching.localizedSubtitle(lang).toUpperCase(),
                  style: const TextStyle(color: Color(0xFFC89A5B), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 15),
                Text(
                  teaching.localizedTitle(lang),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A), fontFamily: 'serif'),
                ),
                const SizedBox(height: 20),
                Text(
                  teaching.localizedDescription(lang),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF6D6D6D), fontSize: 15, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
