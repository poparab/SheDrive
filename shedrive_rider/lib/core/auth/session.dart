class Session {
  final String userId;
  final String phone;
  final String role;
  final bool kycVerified;
  final DateTime loggedInAt;

  Session({
    required this.userId,
    required this.phone,
    required this.role,
    required this.kycVerified,
    required this.loggedInAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'phone': phone,
        'role': role,
        'kycVerified': kycVerified,
        'loggedInAt': loggedInAt.toIso8601String(),
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        userId: json['userId'] as String,
        phone: json['phone'] as String,
        role: json['role'] as String,
        kycVerified: json['kycVerified'] as bool,
        loggedInAt: DateTime.parse(json['loggedInAt'] as String),
      );
}
