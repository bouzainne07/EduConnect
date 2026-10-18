import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/grade_model.dart';
import '../../../data/repositories/grade_repository.dart';

final myGradesProvider = FutureProvider<List<GradeModel>>((ref) {
  return ref.watch(gradeRepositoryProvider).getMyGrades();
});

final gradesByStudentProvider = FutureProvider.family<List<GradeModel>, int>((ref, studentId) {
  return ref.watch(gradeRepositoryProvider).getByStudent(studentId);
});

final studentAveragesProvider = FutureProvider.family<StudentAverageModel, int>((ref, studentId) {
  return ref.watch(gradeRepositoryProvider).getStudentAverages(studentId);
});
