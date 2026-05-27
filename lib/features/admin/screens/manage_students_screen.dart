import 'package:facultyfeed/core/models/user_model.dart';
import 'package:facultyfeed/features/admin/repository/students_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ManageStudentsScreen extends ConsumerWidget {
  const ManageStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show minimal management view: Add Student and Update Student actions only
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Students'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/bulk-import-format'),
              icon: const Icon(Icons.upload_file),
              label: const Text('Bulk Upload Students'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.push('/add-student'),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Student'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to an update/search UI (not implemented yet)
                // For now, reuse manage-students route but we could add a dedicated screen.
                context.push('/update-student');
              },
              icon: const Icon(Icons.edit),
              label: const Text('Update / Search Student'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.push('/bulk-semester-update'),
              icon: const Icon(Icons.swap_vert),
              label: const Text('Bulk Semester Update'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Note: Listing all students is disabled to avoid heavy reads. Use Update/Search to find specific students.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentCard extends ConsumerWidget {
  final UserModel student;
  final WidgetRef ref;

  const StudentCard({required this.student, required this.ref});

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Student'),
          content: Text(
            'Are you sure you want to delete ${student.name}?\nThis will remove them from the database.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteStudent(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteStudent(BuildContext context) async {
    final result = await ref
        .read(studentsRepositoryProvider)
        .deleteStudent(student.uid, student.email);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted successfully')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Email: ${student.email}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Branch: ${student.branch} | Semester: ${student.semester}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<int>(
          itemBuilder:
              (context) => [
                const PopupMenuItem<int>(
                  enabled: false,
                  child: Text('Roll Number Details'),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<int>(
                  onTap: () => _showDeleteConfirmation(context),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
        ),
      ),
    );
  }
}

final allStudentsProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(studentsRepositoryProvider).getAllStudents();
});
