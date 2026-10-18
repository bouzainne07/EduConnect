import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/parent_model.dart';
import '../services/parent_api_service.dart';

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return ParentRepository(ref.watch(parentApiServiceProvider));
});

class ParentRepository {
  final ParentApiService _api;
  ParentRepository(this._api);

  Future<List<ParentModel>> getAll({int page = 0}) async {
    final data = await _api.getAll(page: page);
    final content = data['content'] as List<dynamic>;
    return content.map((e) => ParentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ParentModel> getById(int id) => _api.getById(id);

  Future<List<ParentModel>> getByStudentId(int studentId) => _api.getByStudentId(studentId);

  Future<ParentModel> create({
    required String firstName,
    required String lastName,
    String? telephone,
    String? email,
    String? adresse,
    String? profession,
    List<int>? childrenIds,
  }) =>
      _api.create({
        'firstName': firstName,
        'lastName': lastName,
        if (telephone != null) 'telephone': telephone,
        if (email != null) 'email': email,
        if (adresse != null) 'adresse': adresse,
        if (profession != null) 'profession': profession,
        if (childrenIds != null) 'childrenIds': childrenIds,
      });

  Future<ParentModel> update(int id, Map<String, dynamic> data) => _api.update(id, data);

  Future<void> delete(int id) => _api.delete(id);
}
