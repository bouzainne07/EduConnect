class GradeModel {
  final int id;
  final int studentId;
  final String studentNom;
  final int subjectId;
  final String subjectNom;
  final String? subjectCode;
  final int teacherId;
  final String teacherNom;
  final String type;
  final double note;
  final double bareme;
  final double coefficient;
  final double noteSur20;
  final String? appreciation;
  final String dateEvaluation;
  final bool active;

  const GradeModel({
    required this.id,
    required this.studentId,
    required this.studentNom,
    required this.subjectId,
    required this.subjectNom,
    this.subjectCode,
    required this.teacherId,
    required this.teacherNom,
    required this.type,
    required this.note,
    required this.bareme,
    required this.coefficient,
    required this.noteSur20,
    this.appreciation,
    required this.dateEvaluation,
    required this.active,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) => GradeModel(
        id: json['id'] as int,
        studentId: json['studentId'] as int,
        studentNom: json['studentNom'] as String,
        subjectId: json['subjectId'] as int,
        subjectNom: json['subjectNom'] as String,
        subjectCode: json['subjectCode'] as String?,
        teacherId: json['teacherId'] as int,
        teacherNom: json['teacherNom'] as String,
        type: json['type'] as String,
        note: (json['note'] as num).toDouble(),
        bareme: (json['bareme'] as num).toDouble(),
        coefficient: (json['coefficient'] as num).toDouble(),
        noteSur20: (json['noteSur20'] as num).toDouble(),
        appreciation: json['appreciation'] as String?,
        dateEvaluation: json['dateEvaluation'] as String,
        active: json['active'] as bool,
      );
}

class SubjectAverageModel {
  final int subjectId;
  final String subjectNom;
  final String? subjectCode;
  final double moyenneMatiere;
  final double coefficientMatiere;
  final int nombreNotes;

  const SubjectAverageModel({
    required this.subjectId,
    required this.subjectNom,
    this.subjectCode,
    required this.moyenneMatiere,
    required this.coefficientMatiere,
    required this.nombreNotes,
  });

  factory SubjectAverageModel.fromJson(Map<String, dynamic> json) => SubjectAverageModel(
        subjectId: json['subjectId'] as int,
        subjectNom: json['subjectNom'] as String,
        subjectCode: json['subjectCode'] as String?,
        moyenneMatiere: (json['moyenneMatiere'] as num).toDouble(),
        coefficientMatiere: (json['coefficientMatiere'] as num).toDouble(),
        nombreNotes: json['nombreNotes'] as int,
      );
}

class StudentAverageModel {
  final int studentId;
  final String studentNom;
  final double? moyenneGenerale;
  final List<SubjectAverageModel> moyennesParMatiere;

  const StudentAverageModel({
    required this.studentId,
    required this.studentNom,
    this.moyenneGenerale,
    required this.moyennesParMatiere,
  });

  factory StudentAverageModel.fromJson(Map<String, dynamic> json) {
    final list = json['moyennesParMatiere'] as List?;
    final moyennes = list != null
        ? list.map((i) => SubjectAverageModel.fromJson(i as Map<String, dynamic>)).toList()
        : <SubjectAverageModel>[];

    return StudentAverageModel(
      studentId: json['studentId'] as int,
      studentNom: json['studentNom'] as String,
      moyenneGenerale: json['moyenneGenerale'] != null ? (json['moyenneGenerale'] as num).toDouble() : null,
      moyennesParMatiere: moyennes,
    );
  }
}
