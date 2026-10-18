class StudentModel {
  final int id;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String? photoUrl;
  final String niveau;
  final String? matricule;
  final String? adresse;
  final String? telephone;
  final String? notesDossier;
  final bool active;
  final int? userId;

  const StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.photoUrl,
    required this.niveau,
    this.matricule,
    this.adresse,
    this.telephone,
    this.notesDossier,
    required this.active,
    this.userId,
  });

  String get fullName => '$firstName $lastName';

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json['id'] as int,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        dateOfBirth: json['dateOfBirth'] as String,
        photoUrl: json['photoUrl'] as String?,
        niveau: json['niveau'] as String,
        matricule: json['matricule'] as String?,
        adresse: json['adresse'] as String?,
        telephone: json['telephone'] as String?,
        notesDossier: json['notesDossier'] as String?,
        active: json['active'] as bool,
        userId: json['userId'] as int?,
      );
}
