import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:facultyfeed/features/admin/repository/students_repository.dart';

class BulkImportFormatScreen extends ConsumerWidget {
  const BulkImportFormatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Upload Students'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _handleImport(context, ref);
                },
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Select & Upload File'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Instructions section
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Format Instructions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Create an Excel (.xlsx, .xls) or CSV (.csv) file\n'
                      '• First row MUST contain column headers (case-insensitive):\n'
                      '   - Roll Number (or: roll, roll_no, roll number)\n'
                      '   - Name\n'
                      '   - Semester (must be an integer: 1, 2, 3, 4, etc.)\n'
                      '   - Branch (use short forms: CSE, IT, ME, EC, etc.)\n'
                      '• Each row below headers = one student\n'
                      '• All four columns are REQUIRED for each student\n'
                      '• No empty rows in the middle of data\n'
                      '• Semester must be a number, not text',
                      style: TextStyle(fontSize: 13, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Example table
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✓ Example Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Roll Number')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Semester')),
                          DataColumn(label: Text('Branch')),
                        ],
                        rows: const [
                          DataRow(
                            cells: [
                              DataCell(Text('20CS001')),
                              DataCell(Text('Rajesh Kumar')),
                              DataCell(Text('4')),
                              DataCell(Text('CSE')),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(Text('20CS002')),
                              DataCell(Text('Priya Singh')),
                              DataCell(Text('4')),
                              DataCell(Text('CSE')),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(Text('20ME001')),
                              DataCell(Text('Amit Patel')),
                              DataCell(Text('3')),
                              DataCell(Text('ME')),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(Text('20EC005')),
                              DataCell(Text('Neha Verma')),
                              DataCell(Text('2')),
                              DataCell(Text('EC')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // What happens section
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔐 What Happens During Import',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. File Validation: Headers checked, rows validated\n'
                      '2. Error Check: If any row has issues, import is stopped and errors shown\n'
                      '3. Confirmation: You review before import proceeds\n'
                      '4. Account Creation: Each student gets:\n'
                      '   - Firebase Auth account\n'
                      '   - Email: [roll_number]@mlvti.ac.in\n'
                      '   - Password: [roll_number]\n'
                      '5. Database Entry: Student details stored in Firestore\n'
                      '6. Summary Report: Shows created, skipped (already existed), and failed entries',
                      style: TextStyle(fontSize: 13, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Common mistakes
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '❌ Common Mistakes to Avoid',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Wrong header names (must be exactly: roll number, name, semester, branch)\n'
                      '• Semester as text like "Fourth" instead of "4"\n'
                      '• Empty cells in required columns\n'
                      '• Extra spaces or special characters in headers\n'
                      '• Empty rows between data\n'
                      '• Duplicate roll numbers in the same file\n'
                      '• Full branch names like "Computer Science" instead of short forms (CSE, IT, ME, EC, etc.)',
                      style: TextStyle(fontSize: 13, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

Future<void> _handleImport(BuildContext context, WidgetRef ref) async {
  try {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
      withData: true,
    );

    if (result == null) return; // user cancelled

    final picked = result.files.single;
    final name = picked.name;
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';

    Uint8List? bytes = picked.bytes;
    if (bytes == null && picked.path != null) {
      bytes = await io.File(picked.path!).readAsBytes();
    }

    if (bytes == null) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder:
            (c) => AlertDialog(
              title: const Text('File error'),
              content: const Text('Unable to read the selected file.'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    // Parse file
    final List<List<String>> table = [];

    if (ext == 'csv') {
      final content = String.fromCharCodes(bytes);
      final lines = content.split(RegExp(r'\r?\n'))
        ..removeWhere((s) => s.trim().isEmpty);
      for (final line in lines) {
        final cols = line.split(',').map((c) => c.trim()).toList();
        table.add(cols);
      }
    } else {
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder:
              (c) => AlertDialog(
                title: const Text('Invalid file'),
                content: const Text('Excel file contains no sheets.'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
        return;
      }
      final sheet = excel.tables.keys.first;
      final rows = excel.tables[sheet]!.rows;
      for (final row in rows) {
        table.add(row.map((c) => c?.value?.toString() ?? '').toList());
      }
    }

    if (table.isEmpty) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder:
            (c) => AlertDialog(
              title: const Text('Empty file'),
              content: const Text('The selected file is empty.'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    // Validate header
    final header = table.first.map((h) => h.trim().toLowerCase()).toList();
    String normalize(String s) =>
        s.replaceAll(' ', '').replaceAll('_', '').toLowerCase();

    final Map<String, int> indices = {};
    for (var i = 0; i < header.length; i++) {
      final norm = normalize(header[i]);
      if (['rollnumber', 'roll', 'rollno'].contains(norm))
        indices['rollNumber'] = i;
      if (['name'].contains(norm)) indices['name'] = i;
      if (['semester', 'sem'].contains(norm)) indices['semester'] = i;
      if (['branch'].contains(norm)) indices['branch'] = i;
    }

    final missing = <String>[];
    for (final k in ['rollNumber', 'name', 'semester', 'branch']) {
      if (!indices.containsKey(k)) missing.add(k);
    }

    if (missing.isNotEmpty) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder:
            (c) => AlertDialog(
              title: const Text('Invalid header'),
              content: Text(
                'Missing columns: ${missing.join(', ')}\nExpected: roll number, name, semester, branch',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    // Build rows map and validate each row
    final List<Map<String, dynamic>> rows = [];
    final List<String> rowErrors = [];
    for (var r = 1; r < table.length; r++) {
      final cols = table[r];
      String val(int idx) => idx < cols.length ? cols[idx].trim() : '';
      final roll = val(indices['rollNumber']!);
      final name = val(indices['name']!);
      final branch = val(indices['branch']!);
      final semRaw = val(indices['semester']!);

      if (roll.isEmpty || name.isEmpty || branch.isEmpty || semRaw.isEmpty) {
        rowErrors.add('Row ${r + 1}: missing required field(s)');
        continue;
      }

      // Robust semester parsing: remove common invisible characters and try parse
      String semClean =
          semRaw.replaceAll('\uFEFF', '').replaceAll('\u200B', '').trim();
      int? sem = int.tryParse(semClean);

      if (sem == null) {
        // Try parsing as double (handles values like "8.0")
        final normalized = semClean.replaceAll(',', '').trim();
        final d = double.tryParse(normalized);
        if (d != null) {
          if ((d - d.round()).abs() < 1e-9) {
            sem = d.toInt();
          }
        }
      }

      if (sem == null) {
        // Last resort: remove zero-width and control chars only (do not strip punctuation)
        final cleaned =
            semClean
                .replaceAll(RegExp(r'[\u2000-\u206F\u2E00-\u2E7F\uFEFF]'), '')
                .trim();
        sem = int.tryParse(cleaned);
      }

      if (sem == null) {
        // include raw code points to aid debugging of unexpected characters
        final codes = semRaw.runes
            .map((c) => c.toRadixString(16).padLeft(4, '0'))
            .join(' ');
        rowErrors.add(
          'Row ${r + 1}: semester is not an integer (got "$semRaw", codes: $codes)',
        );
        continue;
      }

      rows.add({
        'rollNumber': roll.toLowerCase(),
        'name': name,
        'branch': branch.toUpperCase(),
        'semester': sem,
      });
    }

    if (rowErrors.isNotEmpty) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder:
            (c) => AlertDialog(
              title: const Text('File validation errors'),
              content: SingleChildScrollView(child: Text(rowErrors.join('\n'))),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    // Confirm before import
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text('Confirm Import'),
            content: Text(
              'Import ${rows.length} students? This will create authentication accounts and Firestore entries.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Start Import'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    // Show progress
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (c) => WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Importing students...'),
                ],
              ),
            ),
          ),
    );

    final importResult = await ref
        .read(studentsRepositoryProvider)
        .bulkCreateStudents(rows);

    if (!context.mounted) return;
    Navigator.pop(context); // close progress

    importResult.fold(
      (failure) {
        showDialog(
          context: context,
          builder:
              (c) => AlertDialog(
                title: const Text('Import failed'),
                content: Text(failure.message),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      },
      (map) {
        final created = map['created'] ?? 0;
        final skipped = map['skipped'] ?? 0;
        final failed = map['failed'] ?? 0;
        final errors =
            (map['errors'] as List<dynamic>? ?? []).cast<Map<String, String>>();

        showDialog(
          context: context,
          builder:
              (c) => AlertDialog(
                title: const Text('Import summary'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✓ Created: $created',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '⊘ Skipped (already existed): $skipped',
                        style: const TextStyle(color: Colors.orange),
                      ),
                      Text(
                        '✗ Failed: $failed',
                        style: const TextStyle(color: Colors.red),
                      ),
                      if (errors.isNotEmpty) const SizedBox(height: 12),
                      if (errors.isNotEmpty)
                        const Text(
                          'Errors (first 10):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ...errors
                          .take(10)
                          .map((e) => Text('  Row ${e['row']}: ${e['error']}')),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('Close'),
                  ),
                ],
              ),
        );
      },
    );
  } catch (e) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
