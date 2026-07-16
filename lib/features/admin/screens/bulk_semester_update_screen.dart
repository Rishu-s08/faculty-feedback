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
  int? _selectedBatch;
  bool _loading = false;
  int _count = 0;
  Map<int, int> _activeSemesters = {};
  List<int> _availableBatches = [];
  bool _loadingActive = true;

  final semesters = [1,2,3,4,5,6,7,8];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ref.read(studentsRepositoryProvider);
    final counts = await repo.getActiveSemesterCounts();
    final batches = await repo.getAvailableBatches();
    if (mounted) {
      setState(() {
        _activeSemesters = counts;
        _availableBatches = batches;
        _loadingActive = false;
      });
    }
  }

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
      final cnt = await ref.read(studentsRepositoryProvider).countStudentsBySemester(
        _fromSemester!,
        batchYear: _selectedBatch,
      );
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

    final batchLabel = _selectedBatch != null ? ' (Batch $_selectedBatch)' : ' (All batches)';
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm bulk update'),
          content: Text(
            'This will change $_count students$batchLabel from ${_semesterLabel(_fromSemester)} to ${_semesterLabel(_toSemester)}.\nThis operation cannot be easily undone.',
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
      batchYear: _selectedBatch,
    );
    setState(() { _loading = false; });

    result.fold((failure) {
      showPrettySnackBar(context, failure.message, isError: true);
    }, (updatedCount) {
      showPrettySnackBar(context, 'Updated $updatedCount students');
      _loadData(); // Refresh the overview
      setState(() { _count = 0; _fromSemester = null; _toSemester = null; });
    });
  }

  Widget _buildActiveSemestersCard(BuildContext context) {
    final theme = Theme.of(context);

    if (_loadingActive) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_activeSemesters.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('No students found', style: theme.textTheme.bodyMedium),
        ),
      );
    }

    final sortedEntries = _activeSemesters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Students Currently In',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: sortedEntries.map((entry) {
                final sem = entry.key;
                final count = entry.value;
                final label = sem == 9 ? 'Pass Out' : 'Sem $sem';
                final isEven = sem != 9 && sem.isEven;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isEven
                        ? theme.colorScheme.primary.withAlpha((0.10 * 255).toInt())
                        : theme.colorScheme.secondary.withAlpha((0.10 * 255).toInt()),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEven
                          ? theme.colorScheme.primary.withAlpha((0.3 * 255).toInt())
                          : theme.colorScheme.secondary.withAlpha((0.3 * 255).toInt()),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isEven
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isEven
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Semester Update')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActiveSemestersCard(context),
            const SizedBox(height: 20),
            DropdownButtonFormField<int?>(
              value: _selectedBatch,
              decoration: const InputDecoration(labelText: 'Filter by Batch (optional)'),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('All Batches')),
                ..._availableBatches.map((b) => DropdownMenuItem<int?>(value: b, child: Text('$b Batch'))),
              ],
              onChanged: (v) => setState(() { _selectedBatch = v; _count = 0; }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _fromSemester,
              decoration: const InputDecoration(labelText: 'From Semester'),
              items: semesters.map((s) => DropdownMenuItem(value: s, child: Text('Semester $s'))).toList(),
              onChanged: (v) => setState(() { _fromSemester = v; _count = 0; }),
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
