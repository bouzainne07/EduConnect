import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/student_repository.dart';
import '../application/students_provider.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  final int? studentId; // null = création, non-null = modification
  const StudentFormScreen({super.key, this.studentId});

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _matriculeCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _telephoneCtrl = TextEditingController();

  String _selectedNiveau = 'SIXIEME';
  bool _isLoading = false;
  String? _error;

  final List<String> _niveaux = [
    'SIXIEME', 'CINQUIEME', 'QUATRIEME', 'TROISIEME',
    'SECONDE', 'PREMIERE', 'TERMINALE'
  ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _dobCtrl.dispose();
    _matriculeCtrl.dispose();
    _adresseCtrl.dispose();
    _telephoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _error = null; });

    try {
      final repo = ref.read(studentRepositoryProvider);

      if (widget.studentId == null) {
        await repo.create(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          dateOfBirth: _dobCtrl.text.trim(),
          niveau: _selectedNiveau,
          matricule: _matriculeCtrl.text.trim().isEmpty
              ? null : _matriculeCtrl.text.trim(),
          adresse: _adresseCtrl.text.trim().isEmpty
              ? null : _adresseCtrl.text.trim(),
          telephone: _telephoneCtrl.text.trim().isEmpty
              ? null : _telephoneCtrl.text.trim(),
        );
      } else {
        await repo.update(widget.studentId!, {
          'firstName': _firstNameCtrl.text.trim(),
          'lastName': _lastNameCtrl.text.trim(),
          'dateOfBirth': _dobCtrl.text.trim(),
          'niveau': _selectedNiveau,
          'matricule': _matriculeCtrl.text.trim(),
          'adresse': _adresseCtrl.text.trim(),
          'telephone': _telephoneCtrl.text.trim(),
        });
      }

      ref.invalidate(studentsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _dobCtrl.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentId == null ? 'Nouvel élève' : 'Modifier élève'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: AppTheme.error)),
                ),

              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'Prénom *'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Prénom requis' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Nom *'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _dobCtrl,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Date de naissance *',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Date requise' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedNiveau,
                decoration: const InputDecoration(labelText: 'Niveau *'),
                items: _niveaux
                    .map((n) => DropdownMenuItem(
                          value: n,
                          child: Text(n.replaceAll('_', ' ')),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedNiveau = v!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _matriculeCtrl,
                decoration:
                    const InputDecoration(labelText: 'Matricule (optionnel)'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _telephoneCtrl,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Téléphone (optionnel)'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _adresseCtrl,
                decoration:
                    const InputDecoration(labelText: 'Adresse (optionnel)'),
                maxLines: 2,
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(widget.studentId == null
                        ? 'Créer l\'élève'
                        : 'Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
