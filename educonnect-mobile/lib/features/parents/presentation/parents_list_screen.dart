import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/parent_repository.dart';
import '../../students/application/students_provider.dart';
import '../application/parents_provider.dart';

class ParentsListScreen extends ConsumerWidget {
  const ParentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentsAsync = ref.watch(parentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showForm(context, ref),
          ),
        ],
      ),
      body: parentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (parents) => parents.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.family_restroom_outlined, size: 64, color: AppTheme.textSecondary),
                    SizedBox(height: 12),
                    Text('Aucun parent enregistré', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(parentsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: parents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final p = parents[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFF059669).withOpacity(0.1),
                                  child: Text(
                                    p.firstName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF059669),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (p.profession != null)
                                        Text(
                                          p.profession!,
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            if (p.telephone != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 16, color: AppTheme.textSecondary),
                                    const SizedBox(width: 8),
                                    Text(p.telephone!, style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                            if (p.email != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.email_outlined, size: 16, color: AppTheme.textSecondary),
                                    const SizedBox(width: 8),
                                    Text(p.email!, style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                            if (p.adresse != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary),
                                    const SizedBox(width: 8),
                                    Text(p.adresse!, style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                            if (p.children.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Enfants :',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: p.children.map((child) {
                                  return ActionChip(
                                    avatar: const Icon(Icons.school_outlined, size: 14),
                                    label: Text(child.fullName),
                                    onPressed: () => context.push('/students/${child.id}'),
                                    labelStyle: const TextStyle(fontSize: 12),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref) {
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final professionCtrl = TextEditingController();
    final selectedStudents = <int>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setState) {
          final studentsAsync = ref.watch(studentsProvider);

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nouveau parent',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: firstNameCtrl,
                    decoration: const InputDecoration(labelText: 'Prénom *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: lastNameCtrl,
                    decoration: const InputDecoration(labelText: 'Nom *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: professionCtrl,
                    decoration: const InputDecoration(labelText: 'Profession'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Associer des enfants',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  studentsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Erreur élèves : $e'),
                    data: (students) => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: students.length,
                      itemBuilder: (context, i) {
                        final s = students[i];
                        final isSelected = selectedStudents.contains(s.id);
                        return CheckboxListTile(
                          title: Text(s.fullName),
                          subtitle: Text(s.niveau.replaceAll('_', ' ')),
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selectedStudents.add(s.id);
                              } else {
                                selectedStudents.remove(s.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (firstNameCtrl.text.isEmpty || lastNameCtrl.text.isEmpty) return;

                      await ref.read(parentRepositoryProvider).create(
                            firstName: firstNameCtrl.text,
                            lastName: lastNameCtrl.text,
                            telephone: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
                            email: emailCtrl.text.isEmpty ? null : emailCtrl.text,
                            adresse: addressCtrl.text.isEmpty ? null : addressCtrl.text,
                            profession: professionCtrl.text.isEmpty ? null : professionCtrl.text,
                            childrenIds: selectedStudents.toList(),
                          );

                      ref.invalidate(parentsProvider);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Créer'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
