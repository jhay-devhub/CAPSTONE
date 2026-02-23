import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class AdminUserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  const AdminUserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    this.createdAt,
  });

  factory AdminUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String uid,
  ) {
    final data = doc.data() ?? {};
    return AdminUserModel(
      uid: uid,
      email: data[AppConstants.fieldEmail] as String? ?? '',
      name: data[AppConstants.fieldName] as String? ?? '',
      role: data[AppConstants.fieldRole] as String? ?? AppConstants.roleAdmin,
      isActive: data[AppConstants.fieldIsActive] as bool? ?? false,
      createdAt: (data[AppConstants.fieldCreatedAt] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppConstants.fieldEmail: email,
      AppConstants.fieldName: name,
      AppConstants.fieldRole: role,
      AppConstants.fieldIsActive: isActive,
      AppConstants.fieldCreatedAt:
          createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  bool get isSuperAdmin => role == AppConstants.roleSuperAdmin;

  AdminUserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AdminUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'AdminUserModel(uid: $uid, email: $email, role: $role, isActive: $isActive)';
}
