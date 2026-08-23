import 'package:cloud_firestore/cloud_firestore.dart';

class ContactInquiry {
  String id;
  String name;
  String email;
  String mobile;
  String country;
  String message;
  DateTime timestamp;
  String type; // Enquiries, Booklets/Photos, Audio/Video

  ContactInquiry({
    this.id = '',
    this.name = '',
    this.email = '',
    this.mobile = '',
    this.country = '',
    this.message = '',
    DateTime? timestamp,
    this.type = 'Enquiries',
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'mobile': mobile,
    'country': country,
    'message': message,
    'timestamp': FieldValue.serverTimestamp(),
    'type': type,
  };

  factory ContactInquiry.fromMap(String id, Map<String, dynamic> map) => ContactInquiry(
    id: id,
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    mobile: map['mobile'] ?? '',
    country: map['country'] ?? '',
    message: map['message'] ?? '',
    timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    type: map['type'] ?? 'Enquiries',
  );
}
