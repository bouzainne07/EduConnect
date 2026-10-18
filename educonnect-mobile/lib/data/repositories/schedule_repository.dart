import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';
import '../services/schedule_api_service.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(ref.watch(scheduleApiServiceProvider));
});

class ScheduleRepository {
  final ScheduleApiService _api;
  ScheduleRepository(this._api);

  Future<ScheduleModel> getById(int id) => _api.getById(id);

  Future<List<ScheduleModel>> getByClasse(int classeId) => _api.getByClasse(classeId);

  Future<List<ScheduleModel>> getByTeacher(int teacherId) => _api.getByTeacher(teacherId);

  Future<List<ScheduleModel>> getByStudent(int studentId) => _api.getByStudent(studentId);

  Future<List<ScheduleModel>> getMySchedule() => _api.getMySchedule();

  Future<ScheduleModel> create({
    required int classeId,
    required int subjectId,
    required int teacherId,
    String? salle,
    required String jourSemaine,
    required String heureDebut,
    required String heureFin,
  }) =>
      _api.create({
        'classeId': classeId,
        'subjectId': subjectId,
        'teacherId': teacherId,
        if (salle != null) 'salle': salle,
        'jourSemaine': jourSemaine,
        'heureDebut': heureDebut,
        'heureFin': heureFin,
      });

  Future<ScheduleModel> update(int id, Map<String, dynamic> data) => _api.update(id, data);

  Future<void> delete(int id) => _api.delete(id);
}
