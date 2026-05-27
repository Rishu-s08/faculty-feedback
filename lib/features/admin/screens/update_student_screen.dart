import 'package:facultyfeed/features/admin/repository/students_repository.dart';
import 'package:facultyfeed/core/models/user_model.dart';
import 'package:facultyfeed/core/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateStudentScreen extends ConsumerStatefulWidget {
  const UpdateStudentScreen({super.key});

  @override
  ConsumerState<UpdateStudentScreen> createState() =>
      _UpdateStudentScreenState();
}

class _UpdateStudentScreenState extends ConsumerState<UpdateStudentScreen> {
  final _rollController = TextEditingController();
  final _nameController = TextEditingController();
  String? _branch;
  int? _semester;
  bool _loading = false;
  UserModel? _found;

  final branches = ['CSE', 'ECE', 'ME', 'CE', 'EE', 'IT'];
  final semesters = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void dispose() {
    _rollController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final roll = _rollController.text.trim();
    if (roll.isEmpty) {
      showPrettySnackBar(context, 'Enter roll number to search', isError: true);
      return;
    }
    setState(() {
      _loading = true;
      _found = null;
    });
    final email = '$roll@mlvti.ac.in';
    try {
      final student = await ref
          .read(studentsRepositoryProvider)
          .getStudentByEmail(email);
      if (student == null) {
        showPrettySnackBar(context, 'Student not found', isError: true);
      } else {
        _found = student;
        _nameController.text = student.name;
        // Normalize branch to uppercase and ensure it matches one of the allowed branches
        final branchNorm = student.branch?.toString().trim().toUpperCase();
        _branch = branches.contains(branchNorm) ? branchNorm : null;
        _semester = student.semester;
      }
    } catch (e) {
      showPrettySnackBar(
        context,
        'Search error: ${e.toString()}',
        isError: true,
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_found == null) return;
    final updates = <String, dynamic>{};
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty && newName != _found!.name)
      updates['name'] = newName;
    if (_branch != null && _branch != _found!.branch)
      updates['branch'] = _branch;
    if (_semester != null && _semester != _found!.semester)
      updates['semester'] = _semester;

    if (updates.isEmpty) {
      showPrettySnackBar(context, 'No changes to save');
      return;
    }

    setState(() {
      _loading = true;
    });
    final result = await ref
        .read(studentsRepositoryProvider)
        .updateStudent(_found!.uid, updates);
    setState(() {
      _loading = false;
    });

    result.fold(
      (failure) {
        showPrettySnackBar(context, failure.message, isError: true);
      },
      (_) async {
        showPrettySnackBar(context, 'Student updated');
        // refresh found
        final updated = await ref
            .read(studentsRepositoryProvider)
            .getStudentByEmail(_found!.email);
        setState(() {
          _found = updated;
          if (updated != null) {
            _nameController.text = updated.name;
            final branchNorm = updated.branch?.toString().trim().toUpperCase();
            _branch = branches.contains(branchNorm) ? branchNorm : null;
            _semester = updated.semester;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update / Search Student')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _rollController,
              decoration: const InputDecoration(
                labelText: 'Roll Number',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loading ? null : _search,
              icon: const Icon(Icons.search),
              label: Text(_loading ? 'Searching...' : 'Search'),
            ),
            const SizedBox(height: 24),
            if (_found != null) ...[
              Text(
                'Editing: ${_found!.email}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _branch,
                decoration: const InputDecoration(labelText: 'Branch'),
                items:
                    branches
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                onChanged:
                    (v) => setState(() {
                      _branch = v;
                    }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _semester,
                decoration: const InputDecoration(labelText: 'Semester'),
                items:
                    semesters
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text('Semester $s'),
                          ),
                        )
                        .toList(),
                onChanged:
                    (v) => setState(() {
                      _semester = v;
                    }),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _loading ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(_loading ? 'Saving...' : 'Save Changes'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed:
                    _loading
                        ? null
                        : () async {
                          if (_found == null) return;
                          final ok = await showDialog<bool>(
                            context: context,
                            builder:
                                (c) => AlertDialog(
                                  title: const Text('Delete Student'),
                                  content: Text(
                                    'Delete ${_found!.name} and their auth account? This cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(c, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(c, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                          );
                          if (ok != true) return;

                          setState(() {
                            _loading = true;
                          });

                          // Delete only Firestore data (do not delete Auth account)
                          final result = await ref
                              .read(studentsRepositoryProvider)
                              .deleteStudent(_found!.uid, _found!.email);

                          setState(() {
                            _loading = false;
                          });

                          result.fold(
                            (failure) {
                              showPrettySnackBar(
                                context,
                                failure.message,
                                isError: true,
                              );
                            },
                            (_) {
                              showPrettySnackBar(
                                context,
                                'Student deleted from database.',
                              );
                              // Clear form
                              setState(() {
                                _found = null;
                                _nameController.clear();
                                _branch = null;
                                _semester = null;
                                _rollController.clear();
                              });
                            },
                          );
                        },
                icon: const Icon(Icons.delete_forever),
                label: Text(_loading ? 'Deleting...' : 'Delete Student'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
