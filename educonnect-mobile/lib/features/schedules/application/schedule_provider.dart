import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/repositories/schedule_repository.dart';

final scheduleByClasseProvider = FutureProvider.family<List<ScheduleModel>, int>((ref, classeId) {
  return ref.watch(scheduleRepositoryProvider).getByClasse(classeId);
});

final scheduleByTeacherProvider = FutureProvider.family<List<ScheduleModel>, int>((ref, teacherId) {
  return ref.watch(scheduleRepositoryProvider).getByTeacher(teacherId);
});

final scheduleByStudentProvider = FutureProvider.family<List<ScheduleModel>, int>((ref, studentId) {
  return ref.watch(scheduleRepositoryProvider).getByStudent(studentId);
});

final myScheduleProvider = FutureProvider<List<ScheduleModel>>((ref) {
  return ref.watch(scheduleRepositoryProvider).getMySchedule();
});
