import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/subject_repository.dart';

// List of all subjects
final subjectsProvider = FutureProvider<List<SubjectModel>>((ref) {
  return ref.watch(subjectRepositoryProvider).getAll();
});
