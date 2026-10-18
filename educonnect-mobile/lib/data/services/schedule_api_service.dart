import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';
import 'dio_client.dart';

final scheduleApiServiceProvider = Provider<ScheduleApiService>((ref) {
  return ScheduleApiService(ref.watch(dioClientProvider).dio);
});

class ScheduleApiService {
  final Dio _dio;
  ScheduleApiService(this._dio);

  Future<ScheduleModel> getById(int id) async {
    final res = await _dio.get('/schedules/$id');
    return ScheduleModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<ScheduleModel>> getByClasse(int classeId) async {
    final res = await _dio.get('/schedules/classe/$classeId');
    final list = res.data as List;
    return list.map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ScheduleModel>> getByTeacher(int teacherId) async {
    final res = await _dio.get('/schedules/teacher/$teacherId');
    final list = res.data as List;
    return list.map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ScheduleModel>> getByStudent(int studentId) async {
    final res = await _dio.get('/schedules/student/$studentId');
    final list = res.data as List;
    return list.map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ScheduleModel>> getMySchedule() async {
    final res = await _dio.get('/schedules/me');
    final list = res.data as List;
    return list.map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ScheduleModel> create(Map<String, dynamic> data) async {
    final res = await _dio.post('/schedules', data: data);
    return ScheduleModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ScheduleModel> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/schedules/$id', data: data);
    return ScheduleModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/schedules/$id');
  }
}
