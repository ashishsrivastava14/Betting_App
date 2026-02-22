class UserModel {
  final String id;
  final String name;
  final String phone;
  final String dob;
  final String location;
  final String? imageUrl;
  double walletBalance;
  bool kycVerified;
  bool isBlocked;
  final String role; // 'user' | 'admin'
  final String createdAt; // ISO date string YYYY-MM-DD

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.dob,
    required this.location,
    this.imageUrl,
    this.walletBalance = 0.0,
    this.kycVerified = false,
    this.isBlocked = false,
    this.role = 'user',
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String().substring(0, 10);

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? dob,
    String? location,
    String? imageUrl,
    double? walletBalance,
    bool? kycVerified,
    bool? isBlocked,
    String? role,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      walletBalance: walletBalance ?? this.walletBalance,
      kycVerified: kycVerified ?? this.kycVerified,
      isBlocked: isBlocked ?? this.isBlocked,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
