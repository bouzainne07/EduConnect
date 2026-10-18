import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/teacher_model.dart';
import '../../../data/services/dio_client.dart';

final teachersProvider = FutureProvider<List<TeacherModel>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final res = await dio.get('/teachers', queryParameters: {'page': 0, 'size': 100});
  final content = (res.data['content'] as List);
  return content.map((e) => TeacherModel.fromJson(e as Map<String, dynamic>)).toList();
});

class TeachersListScreen extends ConsumerWidget {
  const TeachersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teachersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enseignants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showForm(context, ref),
          ),
        ],
      ),
      body: teachersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (teachers) => teachers.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off_outlined, size: 64, color: AppTheme.textSecondary),
                    SizedBox(height: 12),
                    Text('Aucun enseignant', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(teachersProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: teachers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1),
                        child: Text(
                          teachers[i].firstName[0].toUpperCase(),
                          style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(teachers[i].fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(teachers[i].specialite ?? 'Spécialité non définie',
                          style: const TextStyle(color: AppTheme.textSecondary)),
                      trailing: teachers[i].anneesExperience != null
                          ? Text('${teachers[i].anneesExperience} ans',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))
                          : null,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref) {
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final specialiteCtrl = TextEditingController();
    final telephoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nouvel enseignant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: firstNameCtrl,
                decoration: const InputDecoration(labelText: 'Prénom *')),
            const SizedBox(height: 12),
            TextField(controller: lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Nom *')),
            const SizedBox(height: 12),
            TextField(controller: specialiteCtrl,
                decoration: const InputDecoration(labelText: 'Spécialité')),
            const SizedBox(height: 12),
            TextField(controller: telephoneCtrl,
                decoration: const InputDecoration(labelText: 'Téléphone')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (firstNameCtrl.text.isEmpty || lastNameCtrl.text.isEmpty) return;
                final dio = ref.read(dioClientProvider).dio;
                await dio.post('/teachers', data: {
                  'firstName': firstNameCtrl.text,
                  'lastName': lastNameCtrl.text,
                  'specialite': specialiteCtrl.text.isEmpty ? null : specialiteCtrl.text,
                  'telephone': telephoneCtrl.text.isEmpty ? null : telephoneCtrl.text,
                });
                ref.invalidate(teachersProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }
}
