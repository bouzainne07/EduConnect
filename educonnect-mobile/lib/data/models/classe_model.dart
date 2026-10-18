class ClasseModel {
  final int id;
  final String nom;
  final String niveau;
  final String? salle;
  final int? capaciteMax;
  final int? responsableId;
  final String? responsableNom;
  final int nombreEleves;

  const ClasseModel({
    required this.id,
    required this.nom,
    required this.niveau,
    this.salle,
    this.capaciteMax,
    this.responsableId,
    this.responsableNom,
    required this.nombreEleves,
  });

  factory ClasseModel.fromJson(Map<String, dynamic> json) => ClasseModel(
        id: json['id'] as int,
        nom: json['nom'] as String,
        niveau: json['niveau'] as String,
        salle: json['salle'] as String?,
        capaciteMax: json['capaciteMax'] as int?,
        responsableId: json['responsableId'] as int?,
        responsableNom: json['responsableNom'] as String?,
        nombreEleves: json['nombreEleves'] as int? ?? 0,
      );
}
