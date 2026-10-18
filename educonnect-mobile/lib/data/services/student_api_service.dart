import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_model.dart';
import 'dio_client.dart';

final studentApiServiceProvider = Provider<StudentApiService>((ref) {
  return StudentApiService(ref.watch(dioClientProvider).dio);
});

class StudentApiService {
  final Dio _dio;
  StudentApiService(this._dio);

  Future<Map<String, dynamic>> getAll({int page = 0, int size = 20}) async {
    final res = await _dio.get('/students', queryParameters: {'page': page, 'size': size});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> search(String query, {int page = 0}) async {
    final res = await _dio.get('/students/search', queryParameters: {'q': query, 'page': page});
    return res.data as Map<String, dynamic>;
  }

  Future<StudentModel> getById(int id) async {
    final res = await _dio.get('/students/$id');
    return StudentModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<StudentModel> create(Map<String, dynamic> data) async {
    final res = await _dio.post('/students', data: data);
    return StudentModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<StudentModel> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/students/$id', data: data);
    return StudentModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/students/$id');
  }
}
