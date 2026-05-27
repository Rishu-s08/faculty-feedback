import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:facultyfeed/core/models/response_form.dart';
import 'package:facultyfeed/features/admin/screens/consise_stats_view_screen.dart';
import 'package:facultyfeed/features/admin/screens/detailed_stats_screen.dart';
import 'package:facultyfeed/features/feedback/controller/give_feedback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsScreen extends ConsumerStatefulWidget {
  final FeedbackForm form;
  const StatsScreen({super.key, required this.form});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int selectedIndex = 0;
  bool _loading = true;
  List<ResponseForm> _allResponses = [];
  List<int> _availableBatches = [];
  int? _selectedBatchYear;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    final responses = await ref
        .read(giveFeedbackControllerProvider)
        .getResponsesFormFromID(widget.form.id, context);

    if (!mounted) return;

    final batches = responses
        .map((response) => response.batchYear)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    setState(() {
      _allResponses = responses;
      _availableBatches = batches;
      _selectedBatchYear = batches.isNotEmpty ? batches.first : null;
      _loading = false;
    });
  }

  void switchTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  List<ResponseForm> get _filteredResponses {
    if (_selectedBatchYear == null) {
      return _allResponses;
    }

    return _allResponses
        .where((response) => response.batchYear == _selectedBatchYear)
        .toList();
  }

  FeedbackForm get _filteredForm {
    final responses = _filteredResponses;
    if (responses.isEmpty) {
      return widget.form.copyWith(ratings: {
        for (final question in widget.form.questions) question: 0.0,
      }, totalResponses: 0);
    }

    final ratings = <String, double>{};
    for (final question in widget.form.questions) {
      final total = responses.fold<double>(
        0,
        (sum, response) => sum + (response.responses[question] ?? 0),
      );
      ratings[question] = double.parse(
        (total / responses.length).toStringAsFixed(2),
      );
    }

    return widget.form.copyWith(
      ratings: ratings,
      totalResponses: responses.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Statistics")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredForm = _filteredForm;
    return Scaffold(
      appBar: AppBar(title: const Text("Statistics")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Icon(Icons.auto_graph, size: 70),
              Text(
                widget.form.subject,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                widget.form.facultyName,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<int?>(
                  value: _selectedBatchYear,
                  decoration: const InputDecoration(
                    labelText: 'Batch Year',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      _availableBatches
                          .map(
                            (batchYear) => DropdownMenuItem<int?>(
                              value: batchYear,
                              child: Text('$batchYear Batch'),
                            ),
                          )
                          .toList(),
                  onChanged: _availableBatches.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            _selectedBatchYear = value;
                          });
                        },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => switchTab(0),
                  icon: Icon(
                    Icons.show_chart,
                    color:
                        selectedIndex == 0
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    backgroundColor:
                        selectedIndex == 0
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                  ),
                  label: Text(
                    'Concise View',
                    style: TextStyle(
                      color: selectedIndex == 0 ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => switchTab(1),
                  icon: Icon(
                    Icons.details,
                    color:
                        selectedIndex == 1
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    backgroundColor:
                        selectedIndex == 1
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                  ),
                  label: Text(
                    'Detailed View',
                    style: TextStyle(
                      color:
                          selectedIndex == 1
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: [
                ConsiseStatsViewScreen(
                  form: filteredForm,
                  batchYear: _selectedBatchYear,
                ),
                DetailedStatsScreen(
                  formId: widget.form.id,
                  responses: _filteredResponses,
                  batchYear: _selectedBatchYear,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
