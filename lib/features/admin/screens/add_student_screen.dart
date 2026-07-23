import 'package:facultyfeed/core/constants.dart';
import 'package:facultyfeed/core/snackbar.dart';
import 'package:facultyfeed/features/admin/repository/students_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddStudentScreen extends ConsumerStatefulWidget {
  const AddStudentScreen({super.key});

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  int? _selectedSemester;
  String? _selectedBranch;

  bool _isLoading = false;

  final branches = Constants.branches;
  final semesters = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void dispose() {
    _studentNameController.dispose();
    _rollNumberController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBranch == null) {
      showPrettySnackBar(context, 'Please select a branch', isError: true);
      return;
    }

    if (_selectedSemester == null) {
      showPrettySnackBar(context, 'Please select a semester', isError: true);
      return;
    }

    // year removed; can be inferred from semester if needed

    setState(() {
      _isLoading = true;
    });

    final result = await ref.read(studentsRepositoryProvider).createStudent(
      studentName: _studentNameController.text.trim(),
      rollNumber: _rollNumberController.text.trim(),
      semester: _selectedSemester!,
      branch: _selectedBranch!,
    );

    setState(() {
      _isLoading = false;
    });

    result.fold(
      (failure) {
        showPrettySnackBar(context, failure.message, isError: true);
      },
      (student) {
        showPrettySnackBar(context, 'Student created successfully!');
        Future.delayed(const Duration(milliseconds: 500), () {
          context.pop();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Student Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Student Name
              TextFormField(
                controller: _studentNameController,
                decoration: InputDecoration(
                  labelText: 'Student Name',
                  hintText: 'Enter student name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Roll Number
              TextFormField(
                controller: _rollNumberController,
                decoration: InputDecoration(
                  labelText: 'Roll Number',
                  hintText: 'Enter roll number (email will be rollno@mlvti.ac.in)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.card_giftcard),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter roll number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Branch Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBranch,
                decoration: InputDecoration(
                  labelText: 'Branch',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.school),
                ),
                items: branches.map((branch) {
                  return DropdownMenuItem(
                    value: branch,
                    child: Text(branch),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBranch = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a branch';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Semester Dropdown
              DropdownButtonFormField<int>(
                value: _selectedSemester,
                decoration: InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.calendar_month),
                ),
                items: semesters.map((semester) {
                  return DropdownMenuItem(
                    value: semester,
                    child: Text('Semester $semester'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSemester = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a semester';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 32),
              // Submit Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(_isLoading ? 'Creating...' : 'Create Student'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auto-Generated Credentials:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Email: rollno@mlvti.ac.in'),
                    const SizedBox(height: 4),
                    const Text('Password: Roll Number'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Student can use these credentials to login to the app.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
