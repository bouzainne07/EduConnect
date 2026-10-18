import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subject_model.dart';
import 'dio_client.dart';

final subjectApiServiceProvider = Provider<SubjectApiService>((ref) {
  return SubjectApiService(ref.watch(dioClientProvider).dio);
});

class SubjectApiService {
  final Dio _dio;
  SubjectApiService(this._dio);

  Future<List<SubjectModel>> getAll() async {
    final res = await _dio.get('/subjects');
    final list = res.data as List;
    return list.map((e) => SubjectModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SubjectModel> getById(int id) async {
    final res = await _dio.get('/subjects/$id');
    return SubjectModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<SubjectModel>> getByTeacher(int teacherId) async {
    final res = await _dio.get('/subjects/teacher/$teacherId');
    final list = res.data as List;
    return list.map((e) => SubjectModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SubjectModel> create(Map<String, dynamic> data) async {
    final res = await _dio.post('/subjects', data: data);
    return SubjectModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<SubjectModel> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/subjects/$id', data: data);
    return SubjectModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/subjects/$id');
  }
}
