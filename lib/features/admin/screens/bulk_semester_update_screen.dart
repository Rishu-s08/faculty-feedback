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
  List<Map<String, dynamic>> _breakdown = [];
  List<int> _availableBatches = [];
  bool _loadingData = true;

  final semesters = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ref.read(studentsRepositoryProvider);
    final breakdown = await repo.getDetailedStudentBreakdown();
    final batches = await repo.getAvailableBatches();
    if (mounted) {
      setState(() {
        _breakdown = breakdown;
        _availableBatches = batches;
        _loadingData = false;
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
      _loadData();
      setState(() { _count = 0; _fromSemester = null; _toSemester = null; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Semester Update')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Action Section ---
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
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _loading ? null : _fetchCount,
              child: Text(_loading ? 'Checking...' : 'Check Affected Count'),
            ),
            if (_count > 0) ...[
              const SizedBox(height: 10),
              Text(
                'Affected: $_count students',
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: (_loading || _count == 0) ? null : _confirmAndRun,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                _loading ? 'Processing...' : 'Run Bulk Update',
                style: const TextStyle(color: Colors.white),
              ),
            ),

            // --- Detailed Breakdown ---
            const SizedBox(height: 28),
            _buildBreakdownSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownSection(ThemeData theme) {
    if (_loadingData) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ));
    }

    if (_breakdown.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text('No student data available', style: theme.textTheme.bodyMedium),
      );
    }

    // Group breakdown by semester
    final Map<int, List<Map<String, dynamic>>> bySemester = {};
    for (final item in _breakdown) {
      final sem = item['semester'] as int;
      bySemester.putIfAbsent(sem, () => []).add(item);
    }
    final sortedSemesters = bySemester.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_outlined, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Student Distribution',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sortedSemesters.map((sem) {
          final items = bySemester[sem]!;
          final totalInSem = items.fold<int>(0, (sum, e) => sum + (e['count'] as int));
          final semLabel = sem == 9 ? 'Pass Out' : 'Semester $sem';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Row(
                  children: [
                    Text(
                      semLabel,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha((0.10 * 255).toInt()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalInSem',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          children: [
                            _tableHeader('Branch'),
                            _tableHeader('Batch'),
                            _tableHeader('Count'),
                          ],
                        ),
                        ...items.map((item) {
                          final batch = item['batch'] as int;
                          return TableRow(
                            children: [
                              _tableCell(item['branch'] as String),
                              _tableCell(batch == 0 ? '—' : '$batch'),
                              _tableCell('${item['count']}', bold: true),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _tableCell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}
