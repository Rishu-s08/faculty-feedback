import 'package:facultyfeed/features/admin/repository/students_repository.dart';
import 'package:facultyfeed/core/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BulkSemesterUpdateScreen extends ConsumerStatefulWidget {
  const BulkSemesterUpdateScreen({super.key});

  @override
  ConsumerState<BulkSemesterUpdateScreen> createState() => _BulkSemesterUpdateScreenState();
}

class _BulkSemesterUpdateScreenState extends ConsumerState<BulkSemesterUpdateScreen> {
  int? _fromSemester;
  int? _toSemester;
  bool _loading = false;
  int _count = 0;

  final semesters = [1,2,3,4,5,6,7,8];

  String _semesterLabel(int? semester) {
    if (semester == null) return '';
    return semester == 9 ? 'Pass Out' : 'Semester $semester';
  }

  Future<void> _fetchCount() async {
    if (_fromSemester == null) {
      showPrettySnackBar(context, 'Select source semester', isError: true);
      return;
    }
    setState(() { _loading = true; _count = 0; });
    try {
      final cnt = await ref.read(studentsRepositoryProvider).countStudentsBySemester(_fromSemester!);
      setState(() { _count = cnt; });
    } catch (e) {
      showPrettySnackBar(context, 'Error fetching count: ${e.toString()}', isError: true);
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _confirmAndRun() async {
    if (_fromSemester == null || _toSemester == null) {
      showPrettySnackBar(context, 'Select both semesters', isError: true);
      return;
    }
    if (_fromSemester == _toSemester) {
      showPrettySnackBar(context, 'From and To semesters must differ', isError: true);
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm bulk update'),
          content: Text(
            'This will change $_count students from ${_semesterLabel(_fromSemester)} to ${_semesterLabel(_toSemester)}.\nThis operation cannot be easily undone.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Proceed')),
          ],
        );
      },
    );

    if (ok != true) return;

    setState(() { _loading = true; });
    final result = await ref.read(studentsRepositoryProvider).bulkUpdateSemester(
      fromSemester: _fromSemester!,
      toSemester: _toSemester!,
    );
    setState(() { _loading = false; });

    result.fold((failure) {
      showPrettySnackBar(context, failure.message, isError: true);
    }, (updatedCount) {
      showPrettySnackBar(context, 'Updated $updatedCount students');
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Semester Update')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _fromSemester,
              decoration: const InputDecoration(labelText: 'From Semester'),
              items: semesters.map((s) => DropdownMenuItem(value: s, child: Text('Semester $s'))).toList(),
              onChanged: (v) => setState(() { _fromSemester = v; }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _toSemester,
              decoration: const InputDecoration(labelText: 'To Semester'),
              items: [
                ...semesters.map((s) => DropdownMenuItem(value: s, child: Text('Semester $s'))),
                const DropdownMenuItem(value: 9, child: Text('Pass Out')),
              ],
              onChanged: (v) => setState(() { _toSemester = v; }),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loading ? null : _fetchCount, child: Text(_loading ? 'Checking...' : 'Check Affected Count')),
            const SizedBox(height: 12),
            Text('Affected students: $_count'),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: (_loading || _count == 0) ? null : _confirmAndRun,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(_loading ? 'Processing...' : 'Run Bulk Update'),
            ),
          ],
        ),
      ),
    );
  }
}
