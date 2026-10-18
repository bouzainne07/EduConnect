import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/classe_model.dart';
import '../../../data/services/dio_client.dart';

final classesProvider = FutureProvider<List<ClasseModel>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final res = await dio.get('/classes');
  return (res.data as List)
      .map((e) => ClasseModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

final _niveaux = ['SIXIEME','CINQUIEME','QUATRIEME','TROISIEME','SECONDE','PREMIERE','TERMINALE'];

class ClassesListScreen extends ConsumerWidget {
  const ClassesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showForm(context, ref),
          ),
        ],
      ),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (classes) => classes.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.class_outlined, size: 64, color: AppTheme.textSecondary),
                    SizedBox(height: 12),
                    Text('Aucune classe', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(classesProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: classes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final c = classes[i];
                    return Card(
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.class_rounded,
                              color: Color(0xFFD97706)),
                        ),
                        title: Text(c.nom,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${c.niveau.replaceAll("_", " ")} — ${c.nombreEleves} élèves'
                          '${c.salle != null ? ' — Salle ${c.salle}' : ''}',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        trailing: c.responsableNom != null
                            ? Text(c.responsableNom!,
                                style: const TextStyle(
                                    fontSize: 11, color: AppTheme.textSecondary))
                            : null,
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
    final salleCtrl = TextEditingController();
    String selectedNiveau = _niveaux.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (_, setState) => Padding(
          padding: EdgeInsets.only(
              left: 16, right: 16, top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nouvelle classe',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nom * (ex: 3ème A)')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedNiveau,
                decoration: const InputDecoration(labelText: 'Niveau *'),
                items: _niveaux.map((n) => DropdownMenuItem(
                  value: n, child: Text(n.replaceAll('_', ' ')),
                )).toList(),
                onChanged: (v) => setState(() => selectedNiveau = v!),
              ),
              const SizedBox(height: 12),
              TextField(controller: salleCtrl,
                  decoration: const InputDecoration(labelText: 'Salle')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (nomCtrl.text.isEmpty) return;
                  final dio = ref.read(dioClientProvider).dio;
                  await dio.post('/classes', data: {
                    'nom': nomCtrl.text,
                    'niveau': selectedNiveau,
                    'salle': salleCtrl.text.isEmpty ? null : salleCtrl.text,
                  });
                  ref.invalidate(classesProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Créer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
