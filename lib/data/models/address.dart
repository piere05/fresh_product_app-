import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  const Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.line1,
    required this.city,
    required this.state,
    required this.postalCode,
    this.line2,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String phone;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String postalCode;
  final bool isDefault;

  factory Address.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Address(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      line1: (data['line1'] as String?) ?? '',
      line2: data['line2'] as String?,
      city: (data['city'] as String?) ?? '',
      state: (data['state'] as String?) ?? '',
      postalCode: (data['postalCode'] as String?) ?? '',
      isDefault: (data['isDefault'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'isDefault': isDefault,
    };
  }

  String get formatted {
    final buffer = StringBuffer();
    buffer.write(line1);
    if (line2 != null && line2!.isNotEmpty) {
      buffer.write(', ${line2!}');
    }
    buffer.write(', $city, $state - $postalCode');
    return buffer.toString();
  }
}
