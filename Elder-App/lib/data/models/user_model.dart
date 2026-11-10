enum UserRole {
  senior,
  family,
  caregiver,
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final UserRole role;
  final String? profilePhoto;
  final String? preferredLanguage;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profilePhoto,
    this.preferredLanguage = 'English / हिंदी',
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    UserRole? role,
    String? profilePhoto,
    String? preferredLanguage,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'profilePhoto': profilePhoto,
      'preferredLanguage': preferredLanguage,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.senior,
      ),
      profilePhoto: json['profilePhoto'] as String?,
      preferredLanguage: json['preferredLanguage'] as String?,
    );
  }
}

