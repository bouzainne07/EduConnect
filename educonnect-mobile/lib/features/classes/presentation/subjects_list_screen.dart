import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/teacher_model.dart';
import '../../../data/repositories/subject_repository.dart';
import '../../teachers/presentation/teachers_list_screen.dart';
import '../application/subjects_provider.dart';

class SubjectsListScreen extends ConsumerWidget {
  const SubjectsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matières'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showForm(context, ref),
          ),
        ],
      ),
      body: subjectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (subjects) => subjects.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book_outlined, size: 64, color: AppTheme.textSecondary),
                    SizedBox(height: 12),
                    Text('Aucune matière enregistrée', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(subjectsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final s = subjects[i];
                    return Card(
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.book_rounded, color: Color(0xFF2563EB)),
                        ),
                        title: Text(
                          s.nom,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Code : ${s.code ?? 'N/A'} — Coeff : ${s.coefficient ?? 1.0}',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                            if (s.teacherNom != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'Ens : ${s.teacherNom}',
                                  style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                          ],
                        ),
                        isThreeLine: s.teacherNom != null,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref) {
    final nomCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final coeffCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    TeacherModel? selectedTeacher;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setState) {
          final teachersAsync = ref.watch(teachersProvider);

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouvelle matière',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nom de la matière *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Code (ex: MATH101)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: coeffCtrl,
                  decoration: const InputDecoration(labelText: 'Coefficient'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                teachersAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Erreur enseignants : $e'),
                  data: (teachers) => DropdownButtonFormField<TeacherModel>(
                    value: selectedTeacher,
                    decoration: const InputDecoration(labelText: 'Enseignant responsable'),
                    items: teachers
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.fullName),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedTeacher = val;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (nomCtrl.text.isEmpty) return;

                    final double? coeff = double.tryParse(coeffCtrl.text);

                    await ref.read(subjectRepositoryProvider).create(
                          nom: nomCtrl.text,
                          code: codeCtrl.text.isEmpty ? null : codeCtrl.text,
                          coefficient: coeff,
                          description: descCtrl.text.isEmpty ? null : descCtrl.text,
                          teacherId: selectedTeacher?.id,
                        );

                    ref.invalidate(subjectsProvider);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Créer'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
