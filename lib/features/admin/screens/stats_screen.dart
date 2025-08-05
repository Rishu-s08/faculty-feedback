import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:facultyfeed/features/admin/screens/consise_stats_view_screen.dart';
import 'package:facultyfeed/features/admin/screens/detailed_stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsScreen extends ConsumerStatefulWidget {
  final FeedbackForm form;
  const StatsScreen({super.key, required this.form});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  late final _seletectForm;
  int selectedIndex = 0;

  void switchTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Statistics")),
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
                ConsiseStatsViewScreen(form: widget.form),
                DetailedStatsScreen(formId: widget.form.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
