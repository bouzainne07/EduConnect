import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/parent_model.dart';
import 'dio_client.dart';

final parentApiServiceProvider = Provider<ParentApiService>((ref) {
  return ParentApiService(ref.watch(dioClientProvider).dio);
});

class ParentApiService {
  final Dio _dio;
  ParentApiService(this._dio);

  Future<Map<String, dynamic>> getAll({int page = 0, int size = 20}) async {
    final res = await _dio.get('/parents', queryParameters: {'page': page, 'size': size});
    return res.data as Map<String, dynamic>;
  }

  Future<ParentModel> getById(int id) async {
    final res = await _dio.get('/parents/$id');
    return ParentModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<ParentModel>> getByStudentId(int studentId) async {
    final res = await _dio.get('/parents/student/$studentId');
    final list = res.data as List;
    return list.map((e) => ParentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ParentModel> create(Map<String, dynamic> data) async {
    final res = await _dio.post('/parents', data: data);
    return ParentModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ParentModel> update(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('/parents/$id', data: data);
    return ParentModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/parents/$id');
  }
}
