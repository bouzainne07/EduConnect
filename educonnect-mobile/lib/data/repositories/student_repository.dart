import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_model.dart';
import '../services/student_api_service.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(ref.watch(studentApiServiceProvider));
});

class StudentRepository {
  final StudentApiService _api;
  StudentRepository(this._api);

  Future<List<StudentModel>> getAll({int page = 0}) async {
    final data = await _api.getAll(page: page);
    final content = data['content'] as List<dynamic>;
    return content.map((e) => StudentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<StudentModel>> search(String query) async {
    final data = await _api.search(query);
    final content = data['content'] as List<dynamic>;
    return content.map((e) => StudentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StudentModel> getById(int id) => _api.getById(id);

  Future<StudentModel> create({
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String niveau,
    String? matricule,
    String? adresse,
    String? telephone,
  }) =>
      _api.create({
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'niveau': niveau,
        if (matricule != null) 'matricule': matricule,
        if (adresse != null) 'adresse': adresse,
        if (telephone != null) 'telephone': telephone,
      });

  Future<StudentModel> update(int id, Map<String, dynamic> data) => _api.update(id, data);

  Future<void> delete(int id) => _api.delete(id);
}
