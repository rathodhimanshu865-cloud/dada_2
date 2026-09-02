import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String titleHi;
  final String titleGu;
  final String message;
  final String messageHi;
  final String messageGu;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    this.titleHi = '',
    this.titleGu = '',
    required this.message,
    this.messageHi = '',
    this.messageGu = '',
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleHi: data['titleHi'] ?? '',
      titleGu: data['titleGu'] ?? '',
      message: data['message'] ?? '',
      messageHi: data['messageHi'] ?? '',
      messageGu: data['messageGu'] ?? '',
      type: data['type'] ?? 'info',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'titleHi': titleHi,
      'titleGu': titleGu,
      'message': message,
      'messageHi': messageHi,
      'messageGu': messageGu,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }

  String localizedTitle(String langCode) {
    if (langCode == 'hi' && titleHi.isNotEmpty) return titleHi;
    if (langCode == 'gu' && titleGu.isNotEmpty) return titleGu;
    return title;
  }

  String localizedMessage(String langCode) {
    if (langCode == 'hi' && messageHi.isNotEmpty) return messageHi;
    if (langCode == 'gu' && messageGu.isNotEmpty) return messageGu;
    return message;
  }
}
