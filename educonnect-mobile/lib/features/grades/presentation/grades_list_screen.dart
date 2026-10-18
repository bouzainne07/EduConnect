import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/grade_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/models/teacher_model.dart';
import '../../../data/repositories/grade_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../classes/application/subjects_provider.dart';
import '../../students/application/students_provider.dart';
import '../../teachers/presentation/teachers_list_screen.dart';
import '../application/grades_provider.dart';

class GradesListScreen extends ConsumerStatefulWidget {
  const GradesListScreen({super.key});

  @override
  ConsumerState<GradesListScreen> createState() => _GradesListScreenState();
}

class _GradesListScreenState extends ConsumerState<GradesListScreen> {
  StudentModel? _selectedStudent;

  final List<String> _gradeTypes = ['CONTROLE', 'DEVOIR', 'TP', 'EXAMEN'];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider).valueOrNull;
    final role = authState?.role ?? 'ELEVE';
    final canManage = role == 'ADMIN' || role == 'DIRECTEUR' || role == 'ENSEIGNANT';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes & Bulletin'),
      ),
      body: Column(
        children: [
          if (canManage) _buildStudentSelector(),
          Expanded(
            child: canManage
                ? (_selectedStudent == null
                    ? const Center(child: Text('Veuillez sélectionner un élève pour afficher ses notes'))
                    : _buildStudentGradesAndAverages(_selectedStudent!.id))
                : _buildMyGradesAndAverages(),
          ),
        ],
      ),
      floatingActionButton: canManage && _selectedStudent != null
          ? FloatingActionButton(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              onPressed: () => _showAddGradeForm(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildStudentSelector() {
    final studentsAsync = ref.watch(studentsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Erreur élèves : $e'),
        data: (students) {
          if (students.isEmpty) {
            return const Text('Aucun élève trouvé.');
          }
          if (_selectedStudent == null && students.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedStudent = students.first;
              });
            });
          }
          return DropdownButtonFormField<StudentModel>(
            value: _selectedStudent,
            decoration: const InputDecoration(
              labelText: 'Sélectionner un élève',
              border: OutlineInputBorder(),
            ),
            items: students
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text('${s.fullName} (${s.niveau.replaceAll('_', ' ')})'),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedStudent = val;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildMyGradesAndAverages() {
    final gradesAsync = ref.watch(myGradesProvider);

    return gradesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur : $e')),
      data: (grades) => _buildGradesView(grades, null),
    );
  }

  Widget _buildStudentGradesAndAverages(int studentId) {
    final gradesAsync = ref.watch(gradesByStudentProvider(studentId));
    final averagesAsync = ref.watch(studentAveragesProvider(studentId));

    return gradesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur : $e')),
      data: (grades) => averagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildGradesView(grades, null),
        data: (averages) => _buildGradesView(grades, averages),
      ),
    );
  }

  Widget _buildGradesView(List<GradeModel> grades, StudentAverageModel? averages) {
    if (grades.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grade_outlined, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 12),
            Text('Aucune note enregistrée', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    // Regrouper par matière
    final Map<String, List<GradeModel>> groupedBySubject = {};
    for (var g in grades) {
      groupedBySubject.putIfAbsent(g.subjectNom, () => []).add(g);
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedStudent != null) {
          ref.invalidate(gradesByStudentProvider(_selectedStudent!.id));
          ref.invalidate(studentAveragesProvider(_selectedStudent!.id));
        } else {
          ref.invalidate(myGradesProvider);
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte Moyenne Générale
            if (averages != null && averages.moyenneGenerale != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'MOYENNE GÉNÉRALE',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${averages.moyenneGenerale!.toStringAsFixed(2)} / 20',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getMention(averages.moyenneGenerale!),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            const Text(
              'Détail des matières',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Liste par matière
            ...groupedBySubject.entries.map((entry) {
              final subjectName = entry.key;
              final subjectGrades = entry.value;

              // Trouver moyenne de cette matière si dispo
              final subjAvg = averages?.moyennesParMatiere.firstWhere(
                (m) => m.subjectNom == subjectName,
                orElse: () => SubjectAverageModel(subjectId: 0, subjectNom: '', moyenneMatiere: 0, coefficientMatiere: 1, nombreNotes: 0),
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: subjAvg != null && subjAvg.nombreNotes > 0
                      ? Text('Moyenne : ${subjAvg.moyenneMatiere.toStringAsFixed(2)} / 20 (Coeff: ${subjAvg.coefficientMatiere})',
                          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13))
                      : null,
                  children: subjectGrades.map((g) {
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppTheme.borderColor, width: 0.5)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTypeColor(g.type).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              g.type,
                              style: TextStyle(color: _getTypeColor(g.type), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Note : ${g.note} / ${g.bareme}  (Sur 20 : ${g.noteSur20.toStringAsFixed(2)})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  'Coeff: ${g.coefficient} — ${g.dateEvaluation} — Par : ${g.teacherNom}',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                                if (g.appreciation != null && g.appreciation!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '"${g.appreciation}"',
                                      style: const TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textPrimary, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getMention(double note) {
    if (note >= 16) return 'Très Bien';
    if (note >= 14) return 'Bien';
    if (note >= 12) return 'Assez Bien';
    if (note >= 10) return 'Passable';
    return 'Insuffisant';
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'EXAMEN':
        return const Color(0xFFDC2626);
      case 'CONTROLE':
        return const Color(0xFFD97706);
      case 'TP':
        return const Color(0xFF059669);
      case 'DEVOIR':
      default:
        return const Color(0xFF2563EB);
    }
  }

  void _showAddGradeForm(BuildContext context) {
    final noteCtrl = TextEditingController();
    final baremeCtrl = TextEditingController(text: '20');
    final coeffCtrl = TextEditingController(text: '1.0');
    final appreciationCtrl = TextEditingController();
    SubjectModel? selectedSubject;
    TeacherModel? selectedTeacher;
    String selectedType = _gradeTypes.first;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final subjectsAsync = ref.watch(subjectsProvider);
          final teachersAsync = ref.watch(teachersProvider);

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
                  Text(
                    'Saisir une note — ${_selectedStudent?.fullName ?? ''}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Matières
                  subjectsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Erreur matières : $e'),
                    data: (subjects) => DropdownButtonFormField<SubjectModel>(
                      value: selectedSubject,
                      decoration: const InputDecoration(labelText: 'Matière *'),
                      items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.nom))).toList(),
                      onChanged: (val) => setModalState(() => selectedSubject = val),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Enseignant
                  teachersAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Erreur enseignants : $e'),
                    data: (teachers) => DropdownButtonFormField<TeacherModel>(
                      value: selectedTeacher,
                      decoration: const InputDecoration(labelText: 'Enseignant *'),
                      items: teachers.map((t) => DropdownMenuItem(value: t, child: Text(t.fullName))).toList(),
                      onChanged: (val) => setModalState(() => selectedTeacher = val),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Type
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Type d\'évaluation *'),
                    items: _gradeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setModalState(() => selectedType = val!),
                  ),
                  const SizedBox(height: 12),

                  // Note + Barème
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: noteCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Note obtenues * (ex: 15.5)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: baremeCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Barème (ex: 20)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Coefficient
                  TextField(
                    controller: coeffCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Coefficient (ex: 1.0)'),
                  ),
                  const SizedBox(height: 12),

                  // Appréciation
                  TextField(
                    controller: appreciationCtrl,
                    decoration: const InputDecoration(labelText: 'Appréciation / Remarque'),
                  ),
                  const SizedBox(height: 16),

                  // Date
                  Row(
                    children: [
                      Text('Date : ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: const Text('Changer date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      if (selectedSubject == null ||
                          selectedTeacher == null ||
                          noteCtrl.text.isEmpty ||
                          _selectedStudent == null) return;

                      final double noteVal = double.parse(noteCtrl.text);
                      final double baremeVal = baremeCtrl.text.isNotEmpty ? double.parse(baremeCtrl.text) : 20.0;
                      final double coefVal = coeffCtrl.text.isNotEmpty ? double.parse(coeffCtrl.text) : 1.0;
                      final String dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

                      await ref.read(gradeRepositoryProvider).create(
                            studentId: _selectedStudent!.id,
                            subjectId: selectedSubject!.id,
                            teacherId: selectedTeacher!.id,
                            type: selectedType,
                            note: noteVal,
                            bareme: baremeVal,
                            coefficient: coefVal,
                            appreciation: appreciationCtrl.text.isEmpty ? null : appreciationCtrl.text,
                            dateEvaluation: dateStr,
                          );

                      ref.invalidate(gradesByStudentProvider(_selectedStudent!.id));
                      ref.invalidate(studentAveragesProvider(_selectedStudent!.id));
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Enregistrer la note'),
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
