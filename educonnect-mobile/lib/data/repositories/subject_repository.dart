import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subject_model.dart';
import '../services/subject_api_service.dart';

final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepository(ref.watch(subjectApiServiceProvider));
});

class SubjectRepository {
  final SubjectApiService _api;
  SubjectRepository(this._api);

  Future<List<SubjectModel>> getAll() => _api.getAll();

  Future<SubjectModel> getById(int id) => _api.getById(id);

  Future<List<SubjectModel>> getByTeacher(int teacherId) => _api.getByTeacher(teacherId);

  Future<SubjectModel> create({
    required String nom,
    String? code,
    double? coefficient,
    String? description,
    int? teacherId,
  }) =>
      _api.create({
        'nom': nom,
        if (code != null) 'code': code,
        if (coefficient != null) 'coefficient': coefficient,
        if (description != null) 'description': description,
        if (teacherId != null) 'teacherId': teacherId,
      });

  Future<SubjectModel> update(int id, Map<String, dynamic> data) => _api.update(id, data);

  Future<void> delete(int id) => _api.delete(id);
}
