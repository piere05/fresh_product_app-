import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.isApproved = true,
    this.isBlocked = false,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final bool isApproved;
  final bool isBlocked;
  final DateTime? createdAt;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      id: doc.id,
      name: (data['name'] as String?) ?? 'User',
      email: (data['email'] as String?) ?? '',
      phone: data['phone'] as String?,
      role: userRoleFromString((data['role'] as String?) ?? 'customer'),
      isApproved: (data['isApproved'] as bool?) ?? true,
      isBlocked: (data['isBlocked'] as bool?) ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': userRoleToString(role),
      'isApproved': isApproved,
      'isBlocked': isBlocked,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
