import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dada_2/l10n/app_localizations.dart';

class ReviewsView extends StatelessWidget {
  const ReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reviews').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reviews = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.devoteeReviewsBlessings, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(AppLocalizations.of(context)!.moderateTestimonials, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 32),
              
              if (reviews.isEmpty)
                _buildMockReview(context)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final data = reviews[i].data() as Map<String, dynamic>;
                    return _buildReviewCard(context, data);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMockReview(BuildContext context) {
    return _buildReviewCard(context, {
      'userName': 'Ramesh Patel',
      'productName': "Dada's Photo Keychain",
      'rating': 5,
      'comment': "The quality is divine. Truly brings peace.",
      'userPhone': '919876543210',
    });
  }

  Widget _buildReviewCard(BuildContext context, Map<String, dynamic> review) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(review['userName'] ?? AppLocalizations.of(context)!.anonymousUser, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.onProduct(review['productName'] ?? ''), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < (review['rating'] ?? 5) ? Icons.star : Icons.star_border, 
                  size: 14, 
                  color: Colors.amber
                )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            review['comment'] ?? '',
            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showReplyDialog(context, review['userPhone'] ?? ''), 
              child: Text(AppLocalizations.of(context)!.replyToDevoteeArrow, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown))
            ),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(BuildContext context, String phone) {
    final TextEditingController replyCtrl = TextEditingController(
      text: AppLocalizations.of(context)!.suggestedReplyText
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.replyToDevotee),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.suggestedReply, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: replyCtrl,
              maxLines: 5,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton.icon(
            onPressed: () {
              _sendWhatsApp(phone, replyCtrl.text);
              Navigator.pop(context);
            }, 
            icon: const Icon(Icons.chat),
            label: Text(AppLocalizations.of(context)!.sendViaWhatsApp),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _sendWhatsApp(String phone, String message) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
