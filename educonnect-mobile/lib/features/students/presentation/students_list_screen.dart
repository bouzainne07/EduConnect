import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../application/students_provider.dart';
import '../../../data/models/student_model.dart';
import 'student_form_screen.dart';
import 'student_detail_screen.dart';

class StudentsListScreen extends ConsumerStatefulWidget {
  const StudentsListScreen({super.key});

  @override
  ConsumerState<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends ConsumerState<StudentsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Élèves'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentFormScreen()),
            ).then((_) => ref.invalidate(studentsProvider)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, prénom, matricule...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(studentSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(studentSearchQueryProvider.notifier).state = v,
            ),
          ),

          // Liste
          Expanded(
            child: studentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                    const SizedBox(height: 8),
                    Text('Erreur : $e',
                        style: const TextStyle(color: AppTheme.error)),
                    TextButton(
                      onPressed: () => ref.invalidate(studentSearchProvider),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
              data: (students) => students.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined,
                              size: 64, color: AppTheme.textSecondary),
                          SizedBox(height: 12),
                          Text('Aucun élève trouvé',
                              style: TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(studentSearchProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _StudentCard(
                          student: students[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StudentDetailScreen(studentId: students[i].id),
                            ),
                          ).then((_) => ref.invalidate(studentsProvider)),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;

  const _StudentCard({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          backgroundImage: student.photoUrl != null
              ? NetworkImage(student.photoUrl!)
              : null,
          child: student.photoUrl == null
              ? Text(
                  student.firstName[0].toUpperCase(),
                  style: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(
          student.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          student.niveau.replaceAll('_', ' '),
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        trailing: student.matricule != null
            ? Text(
                student.matricule!,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              )
            : const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      ),
    );
  }
}
