import 'package:facultyfeed/core/models/response_form.dart';
import 'package:facultyfeed/features/feedback/controller/give_feedback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailedStatsScreen extends ConsumerStatefulWidget {
  final String formId;
  const DetailedStatsScreen({super.key, required this.formId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DetailedStatsScreenState();
}

class _DetailedStatsScreenState extends ConsumerState<DetailedStatsScreen> {
  bool isLoading = true;
  late List<ResponseForm> responses;
  List<String> questions = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    responses = await ref
        .read(giveFeedbackControllerProvider)
        .getResponsesFormFromID(widget.formId, context);

    if (responses.isNotEmpty) {
      questions = responses.first.responses.keys.toList();
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : responses.isEmpty
              ? const Center(child: Text("No responses available"))
              : Padding(
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
                            "Student",
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
                            "Comment",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows:
                          responses.map((response) {
                            return DataRow(
                              cells: [
                                DataCell(Text(response.studentName)),
                                ...questions.map((q) {
                                  final rating = response.responses[q];
                                  return DataCell(
                                    Text(rating?.toStringAsFixed(1) ?? '-'),
                                  );
                                }),
                                DataCell(
                                  Text(
                                    response.comment?.trim().isEmpty ?? true
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
    );
  }
}
