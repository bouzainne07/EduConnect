class TeacherModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? specialite;
  final String? telephone;
  final String? photoUrl;
  final String? diplome;
  final int? anneesExperience;
  final bool active;

  const TeacherModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.specialite,
    this.telephone,
    this.photoUrl,
    this.diplome,
    this.anneesExperience,
    required this.active,
  });

  String get fullName => '$firstName $lastName';

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
        id: json['id'] as int,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        specialite: json['specialite'] as String?,
        telephone: json['telephone'] as String?,
        photoUrl: json['photoUrl'] as String?,
        diplome: json['diplome'] as String?,
        anneesExperience: json['anneesExperience'] as int?,
        active: json['active'] as bool,
      );
}
