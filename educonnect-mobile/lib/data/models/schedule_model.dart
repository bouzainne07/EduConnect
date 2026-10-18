class ScheduleModel {
  final int id;
  final int classeId;
  final String classeNom;
  final int subjectId;
  final String subjectNom;
  final String? subjectCode;
  final int teacherId;
  final String teacherNom;
  final String? salle;
  final String jourSemaine;
  final String heureDebut;
  final String heureFin;
  final bool active;

  const ScheduleModel({
    required this.id,
    required this.classeId,
    required this.classeNom,
    required this.subjectId,
    required this.subjectNom,
    this.subjectCode,
    required this.teacherId,
    required this.teacherNom,
    this.salle,
    required this.jourSemaine,
    required this.heureDebut,
    required this.heureFin,
    required this.active,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
        id: json['id'] as int,
        classeId: json['classeId'] as int,
        classeNom: json['classeNom'] as String,
        subjectId: json['subjectId'] as int,
        subjectNom: json['subjectNom'] as String,
        subjectCode: json['subjectCode'] as String?,
        teacherId: json['teacherId'] as int,
        teacherNom: json['teacherNom'] as String,
        salle: json['salle'] as String?,
        jourSemaine: json['jourSemaine'] as String,
        heureDebut: json['heureDebut'] as String,
        heureFin: json['heureFin'] as String,
        active: json['active'] as bool,
      );
}
