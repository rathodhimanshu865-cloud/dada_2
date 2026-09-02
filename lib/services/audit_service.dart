import 'package:cloud_firestore/cloud_firestore.dart';

class AuditService {
  static Future<Map<String, dynamic>> runFullAudit(FirebaseFirestore firestore) async {
    final Map<String, dynamic> report = {};
    
    // 1. Audit Products
    report['products'] = await _auditCollection(firestore, 'products', ['name', 'description', 'shortSummary', 'consecrationBadge']);
    
    // 2. Audit Categories
    report['categories'] = await _auditCollection(firestore, 'categories', ['name', 'description']);
    
    // 3. Audit Notifications
    report['notifications'] = await _auditCollection(firestore, 'notifications', ['title', 'message']);

    // 4. Audit Coupons
    report['coupons'] = await _auditCollection(firestore, 'coupons', ['terms']);

    return report;
  }

  static Future<Map<String, dynamic>> _auditCollection(
    FirebaseFirestore firestore, 
    String collection, 
    List<String> fields
  ) async {
    final snapshot = await firestore.collection(collection).get();
    int total = snapshot.docs.length;
    int hiComplete = 0;
    int guComplete = 0;
    List<String> failedIds = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      bool hiOk = true;
      bool guOk = true;

      for (var f in fields) {
        final val = data[f] ?? '';
        final valHi = data['${f}Hi'] ?? data['${f}_hi'] ?? '';
        final valGu = data['${f}Gu'] ?? data['${f}_gu'] ?? '';

        if (val.toString().isNotEmpty) {
          if (valHi.toString().isEmpty) hiOk = false;
          if (valGu.toString().isEmpty) guOk = false;
        }
      }

      if (hiOk) hiComplete++;
      if (guOk) guComplete++;
      if (!hiOk || !guOk) failedIds.add(doc.id);
    }

    return {
      'total': total,
      'hindi_percentage': total == 0 ? 100 : (hiComplete / total * 100),
      'gujarati_percentage': total == 0 ? 100 : (guComplete / total * 100),
      'failed_ids': failedIds,
    };
  }

  static Future<Map<String, dynamic>> _auditHomepage(FirebaseFirestore firestore) async {
     final doc = await firestore.collection('cms').doc('homepage').get();
     if (!doc.exists) return {'status': 'missing'};
     
     // For simplicity, we just check a few key fields here
     // In a real app, we'd recursively check the whole model
     final data = doc.data()!;
     return {
       'status': 'checked',
       // Add more detailed checks here
     };
  }
}
