import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/student_model.dart';
import '../../../data/repositories/student_repository.dart';

// Liste des élèves
final studentsProvider = FutureProvider<List<StudentModel>>((ref) {
  return ref.watch(studentRepositoryProvider).getAll();
});

// Recherche
final studentSearchQueryProvider = StateProvider<String>((ref) => '');

final studentSearchProvider = FutureProvider<List<StudentModel>>((ref) {
  final query = ref.watch(studentSearchQueryProvider);
  if (query.isEmpty) return ref.watch(studentRepositoryProvider).getAll();
  return ref.watch(studentRepositoryProvider).search(query);
});

// Détail élève
final studentDetailProvider = FutureProvider.family<StudentModel, int>((ref, id) {
  return ref.watch(studentRepositoryProvider).getById(id);
});
