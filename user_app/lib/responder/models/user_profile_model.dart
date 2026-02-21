import 'package:flutter/foundation.dart';

/// Stores basic user profile information.
@immutable
class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.profileImageUrl,
  });

  final String id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? profileImageUrl;

  /// Placeholder/empty profile used before data is loaded.
  static const UserProfileModel empty = UserProfileModel(
    id: '',
    fullName: '',
    phoneNumber: '',
  );

  bool get isEmpty => id.isEmpty;

  UserProfileModel copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? profileImageUrl,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  String toString() =>
      'UserProfileModel(id: $id, fullName: $fullName, phone: $phoneNumber)';
}
