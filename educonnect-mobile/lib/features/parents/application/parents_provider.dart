import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/parent_model.dart';
import '../../../data/repositories/parent_repository.dart';

// List of all parents
final parentsProvider = FutureProvider<List<ParentModel>>((ref) {
  return ref.watch(parentRepositoryProvider).getAll();
});

// Detail of a specific parent
final parentDetailProvider = FutureProvider.family<ParentModel, int>((ref, id) {
  return ref.watch(parentRepositoryProvider).getById(id);
});
