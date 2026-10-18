import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grade_model.dart';
import 'dio_client.dart';

final gradeApiServiceProvider = Provider<GradeApiService>((ref) {
  return GradeApiService(ref.watch(dioClientProvider).dio);
});

class GradeApiService {
  final Dio _dio;
  GradeApiService(this._dio);

  Future<GradeModel> getById(int id) async {
    final res = await _dio.get('/grades/$id');
    return GradeModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<GradeModel>> getMyGrades() async {
    final res = await _dio.get('/grades/me');
    final list = res.data as List;
    return list.map((e) => GradeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<GradeModel>> getByStudent(int studentId) async {
    final res = await _dio.get('/grades/student/$studentId');
    final list = res.data as List;
    return list.map((e) => GradeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StudentAverageModel> getStudentAverages(int studentId) async {
    final res = await _dio.get('/grades/student/$studentId/averages');
    return StudentAverageModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<GradeModel> create(Map<String, dynamic> data) async {
    final res = await _dio.post('/grades', data: data);
    return GradeModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<GradeModel> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/grades/$id', data: data);
    return GradeModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/grades/$id');
  }
}
