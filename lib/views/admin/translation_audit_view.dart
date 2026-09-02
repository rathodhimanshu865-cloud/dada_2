import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/audit_service.dart';

class TranslationAuditView extends StatefulWidget {
  const TranslationAuditView({super.key});

  @override
  State<TranslationAuditView> createState() => _TranslationAuditViewState();
}

class _TranslationAuditViewState extends State<TranslationAuditView> {
  bool _isLoading = true;
  Map<String, dynamic> _report = {};

  @override
  void initState() {
    super.initState();
    _runAudit();
  }

  Future<void> _runAudit() async {
    setState(() => _isLoading = true);
    final report = await AuditService.runFullAudit(FirebaseFirestore.instance);
    setState(() {
      _report = report;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation Audit Report'),
        actions: [
          IconButton(onPressed: _runAudit, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildSectionCard('Products', _report['products']),
              const SizedBox(height: 20),
              _buildSectionCard('Categories', _report['categories']),
              const SizedBox(height: 20),
              _buildSectionCard('Notifications', _report['notifications']),
              const SizedBox(height: 20),
              _buildSectionCard('Coupons', _report['coupons']),
            ],
          ),
    );
  }

  Widget _buildSectionCard(String title, Map<String, dynamic>? data) {
    if (data == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 10),
            _row('Total Records', '${data['total']}'),
            _row('Hindi Completeness', '${data['hindi_percentage'].toStringAsFixed(1)}%'),
            _row('Gujarati Completeness', '${data['gujarati_percentage'].toStringAsFixed(1)}%'),
            if (data['failed_ids'].isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Failed IDs: ${data['failed_ids'].join(', ')}', style: const TextStyle(fontSize: 10, color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
