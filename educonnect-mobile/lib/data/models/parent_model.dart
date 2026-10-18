import 'student_model.dart';

class ParentModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? telephone;
  final String? email;
  final String? adresse;
  final String? profession;
  final bool active;
  final int? userId;
  final List<StudentModel> children;

  const ParentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.telephone,
    this.email,
    this.adresse,
    this.profession,
    required this.active,
    this.userId,
    required this.children,
  });

  String get fullName => '$firstName $lastName';

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    final list = json['children'] as List?;
    final childrenList = list != null
        ? list.map((i) => StudentModel.fromJson(i as Map<String, dynamic>)).toList()
        : <StudentModel>[];

    return ParentModel(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      telephone: json['telephone'] as String?,
      email: json['email'] as String?,
      adresse: json['adresse'] as String?,
      profession: json['profession'] as String?,
      active: json['active'] as bool,
      userId: json['userId'] as int?,
      children: childrenList,
    );
  }
}
