import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grade_model.dart';
import '../services/grade_api_service.dart';

final gradeRepositoryProvider = Provider<GradeRepository>((ref) {
  return GradeRepository(ref.watch(gradeApiServiceProvider));
});

class GradeRepository {
  final GradeApiService _api;
  GradeRepository(this._api);

  Future<GradeModel> getById(int id) => _api.getById(id);

  Future<List<GradeModel>> getMyGrades() => _api.getMyGrades();

  Future<List<GradeModel>> getByStudent(int studentId) => _api.getByStudent(studentId);

  Future<StudentAverageModel> getStudentAverages(int studentId) => _api.getStudentAverages(studentId);

  Future<GradeModel> create({
    required int studentId,
    required int subjectId,
    required int teacherId,
    required String type,
    required double note,
    double? bareme,
    double? coefficient,
    String? appreciation,
    required String dateEvaluation,
  }) =>
      _api.create({
        'studentId': studentId,
        'subjectId': subjectId,
        'teacherId': teacherId,
        'type': type,
        'note': note,
        if (bareme != null) 'bareme': bareme,
        if (coefficient != null) 'coefficient': coefficient,
        if (appreciation != null) 'appreciation': appreciation,
        'dateEvaluation': dateEvaluation,
      });

  Future<GradeModel> update(int id, Map<String, dynamic> data) => _api.update(id, data);

  Future<void> delete(int id) => _api.delete(id);
}
