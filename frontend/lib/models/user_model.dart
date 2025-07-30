class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool emailVerified;
  final bool isGoogleUser;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.emailVerified,
    required this.isGoogleUser,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      isGoogleUser: json['is_google_user'] ?? false,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}