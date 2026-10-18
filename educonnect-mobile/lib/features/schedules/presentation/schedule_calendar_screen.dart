import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/classe_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/teacher_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../classes/application/subjects_provider.dart';
import '../../classes/presentation/classes_list_screen.dart';
import '../../teachers/presentation/teachers_list_screen.dart';
import '../application/schedule_provider.dart';

class ScheduleCalendarScreen extends ConsumerStatefulWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  ConsumerState<ScheduleCalendarScreen> createState() => _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState extends ConsumerState<ScheduleCalendarScreen> {
  ClasseModel? _selectedClasse;
  final List<String> _days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
  
  final Map<String, String> _dayNamesFr = {
    'MONDAY': 'Lundi',
    'TUESDAY': 'Mardi',
    'WEDNESDAY': 'Mercredi',
    'THURSDAY': 'Jeudi',
    'FRIDAY': 'Vendredi',
    'SATURDAY': 'Samedi',
  };

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider).valueOrNull;
    final role = authState?.role ?? 'ELEVE';
    final isAdmin = role == 'ADMIN' || role == 'DIRECTEUR' || role == 'SURVEILLANT';

    return DefaultTabController(
      length: _days.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Emploi du temps'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _days.map((day) => Tab(text: _dayNamesFr[day])).toList(),
          ),
        ),
        body: Column(
          children: [
            if (isAdmin) _buildClassSelector(),
            Expanded(
              child: TabBarView(
                children: _days.map((day) => _buildDaySchedule(day, isAdmin, role)).toList(),
              ),
            ),
          ],
        ),
        floatingActionButton: isAdmin && _selectedClasse != null
            ? FloatingActionButton(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                onPressed: () => _showAddSlotForm(context),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildClassSelector() {
    final classesAsync = ref.watch(classesProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Erreur chargement classes : $e'),
        data: (classes) {
          if (classes.isEmpty) {
            return const Text('Veuillez créer une classe d\'abord.');
          }
          if (_selectedClasse == null && classes.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedClasse = classes.first;
              });
            });
          }
          return DropdownButtonFormField<ClasseModel>(
            value: _selectedClasse,
            decoration: const InputDecoration(
              labelText: 'Sélectionner la classe',
              border: OutlineInputBorder(),
            ),
            items: classes
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.nom),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedClasse = val;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildDaySchedule(String day, bool isAdmin, String role) {
    if (isAdmin && _selectedClasse == null) {
      return const Center(child: Text('Sélectionnez une classe pour afficher l\'emploi du temps'));
    }

    final scheduleAsync = isAdmin
        ? ref.watch(scheduleByClasseProvider(_selectedClasse!.id))
        : ref.watch(myScheduleProvider);

    return scheduleAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur : $e')),
      data: (schedules) {
        final daySlots = schedules
            .where((s) => s.jourSemaine.toUpperCase() == day)
            .toList();

        // Trier par heure de début
        daySlots.sort((a, b) => a.heureDebut.compareTo(b.heureFin));

        if (daySlots.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, size: 48, color: AppTheme.textSecondary),
                SizedBox(height: 12),
                Text('Aucun cours ce jour', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: daySlots.length,
          itemBuilder: (context, i) {
            final s = daySlots[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Horaires
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.heureDebut.substring(0, 5),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                        ),
                        const Icon(Icons.arrow_downward_rounded, size: 16, color: AppTheme.textSecondary),
                        Text(
                          s.heureFin.substring(0, 5),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Détails du cours
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.subjectNom,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: AppTheme.textSecondary),
                              const SizedBox(width: 4),
                              Text(s.teacherNom, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                          if (s.salle != null && s.salle!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.meeting_room_outlined, size: 14, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text('Salle : ${s.salle}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ],
                          if (role == 'ENSEIGNANT' || role == 'PARENT') ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.class_outlined, size: 14, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text('Classe : ${s.classeNom}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                    // Actions (admin)
                    if (isAdmin)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                        onPressed: () => _confirmDelete(s.id),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce créneau ?'),
        content: const Text('Voulez-vous vraiment retirer ce cours de l\'emploi du temps ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(scheduleRepositoryProvider).delete(id);
              if (mounted) {
                ref.invalidate(scheduleByClasseProvider(_selectedClasse!.id));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  void _showAddSlotForm(BuildContext context) {
    final salleCtrl = TextEditingController();
    SubjectModel? selectedSubject;
    TeacherModel? selectedTeacher;
    String selectedDay = _days.first;
    TimeOfDay? startTime;
    TimeOfDay? endTime;

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
                  const Text('Ajouter un cours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Matière
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

                  // Jour de la semaine
                  DropdownButtonFormField<String>(
                    value: selectedDay,
                    decoration: const InputDecoration(labelText: 'Jour de la semaine *'),
                    items: _days.map((day) => DropdownMenuItem(value: day, child: Text(_dayNamesFr[day]!))).toList(),
                    onChanged: (val) => setModalState(() => selectedDay = val!),
                  ),
                  const SizedBox(height: 12),

                  // Salle
                  TextField(
                    controller: salleCtrl,
                    decoration: const InputDecoration(labelText: 'Salle de classe'),
                  ),
                  const SizedBox(height: 16),

                  // Sélection Heures
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: startTime ?? const TimeOfDay(hour: 8, minute: 30),
                            );
                            if (picked != null) {
                              setModalState(() => startTime = picked);
                            }
                          },
                          child: Text(startTime == null
                              ? 'Heure début *'
                              : 'Début : ${startTime!.format(context)}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: endTime ?? const TimeOfDay(hour: 10, minute: 0),
                            );
                            if (picked != null) {
                              setModalState(() => endTime = picked);
                            }
                          },
                          child: Text(endTime == null
                              ? 'Heure fin *'
                              : 'Fin : ${endTime!.format(context)}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      if (selectedSubject == null ||
                          selectedTeacher == null ||
                          startTime == null ||
                          endTime == null ||
                          _selectedClasse == null) return;

                      final String startStr = '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00';
                      final String endStr = '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00';

                      await ref.read(scheduleRepositoryProvider).create(
                            classeId: _selectedClasse!.id,
                            subjectId: selectedSubject!.id,
                            teacherId: selectedTeacher!.id,
                            salle: salleCtrl.text.isEmpty ? null : salleCtrl.text,
                            jourSemaine: selectedDay,
                            heureDebut: startStr,
                            heureFin: endStr,
                          );

                      ref.invalidate(scheduleByClasseProvider(_selectedClasse!.id));
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Ajouter'),
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
