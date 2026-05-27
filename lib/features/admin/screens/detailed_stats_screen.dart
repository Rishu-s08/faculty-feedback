import 'package:facultyfeed/core/models/response_form.dart';
import 'package:facultyfeed/core/services/export_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailedStatsScreen extends ConsumerWidget {
  final String formId;
  final List<ResponseForm> responses;
  final int? batchYear;

  const DetailedStatsScreen({
    super.key,
    required this.formId,
    required this.responses,
    this.batchYear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = responses.isNotEmpty ? responses.first.responses.keys.toList() : <String>[];

    return Scaffold(
      body:
          responses.isEmpty
              ? const Center(child: Text('No responses available'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ExportService.exportDetailedStatsToExcel(
                          ref: ref,
                          context: context,
                          responses: responses,
                          formId: formId,
                        );
                      },
                      icon: const Icon(Icons.table_chart),
                      label: const Text('Export to Excel'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                  if (batchYear != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(label: Text('Batch $batchYear')),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columnSpacing: 20,
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 80,
                            columns: [
                              const DataColumn(
                                label: Text(
                                  'Student',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const DataColumn(
                                label: Text(
                                  'Batch',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...questions.map(
                                (q) => DataColumn(
                                  label: Text(
                                    q,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const DataColumn(
                                label: Text(
                                  'Comment',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows:
                                responses.map((response) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(response.studentName)),
                                      DataCell(
                                        Text(
                                          response.batchYear?.toString() ?? '-',
                                        ),
                                      ),
                                      ...questions.map((q) {
                                        final rating = response.responses[q];
                                        return DataCell(
                                          Text(
                                            rating?.toStringAsFixed(1) ?? '-',
                                          ),
                                        );
                                      }),
                                      DataCell(
                                        Text(
                                          response.comment?.trim().isEmpty ??
                                                  true
                                              ? '-'
                                              : response.comment!,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
