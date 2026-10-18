class SubjectModel {
  final int id;
  final String nom;
  final String? code;
  final double? coefficient;
  final String? description;
  final int? teacherId;
  final String? teacherNom;
  final bool active;

  const SubjectModel({
    required this.id,
    required this.nom,
    this.code,
    this.coefficient,
    this.description,
    this.teacherId,
    this.teacherNom,
    required this.active,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        id: json['id'] as int,
        nom: json['nom'] as String,
        code: json['code'] as String?,
        coefficient: (json['coefficient'] as num?)?.toDouble(),
        description: json['description'] as String?,
        teacherId: json['teacherId'] as int?,
        teacherNom: json['teacherNom'] as String?,
        active: json['active'] as bool,
      );
}
