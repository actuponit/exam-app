class ReferralUser {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String institutionType;
  final String institutionName;
  final String status;
  final String createdAt;
  final String lastLoginAt;
  final String? type;

  ReferralUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.institutionType,
    required this.institutionName,
    required this.status,
    required this.createdAt,
    required this.lastLoginAt,
    this.type,
  });

  factory ReferralUser.fromJson(Map<String, dynamic> json) {
    return ReferralUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      institutionType: json['institution_type'],
      institutionName: json['institution_name'],
      status: json['status'],
      createdAt: json['created_at'],
      lastLoginAt: json['last_login_at'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'institution_type': institutionType,
      'institution_name': institutionName,
      'status': status,
      'created_at': createdAt,
      'last_login_at': lastLoginAt,
      'type': type,
    };
  }
}
