class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.photoUrl,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromAuthResponse(Map<String, dynamic> json) => UserModel(
        id: json['userId'] as int,
        email: json['email'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        role: json['role'] as String,
        photoUrl: json['photoUrl'] as String?,
      );
}
