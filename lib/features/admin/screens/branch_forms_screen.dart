import 'package:facultyfeed/core/loader.dart';
import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:facultyfeed/core/no_internet_widget.dart';
import 'package:facultyfeed/features/dashboard/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen that shows all feedback forms belonging to a specific branch,
/// grouped by semester with toggle pills to filter.
class BranchFormsScreen extends ConsumerStatefulWidget {
  final String branch;

  const BranchFormsScreen({super.key, required this.branch});

  @override
  ConsumerState<BranchFormsScreen> createState() => _BranchFormsScreenState();
}

class _BranchFormsScreenState extends ConsumerState<BranchFormsScreen> {
  /// Set of semesters currently enabled (visible).
  final Set<int> _enabledSemesters = {};
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.branch} Forms')),
      body: ref.watch(feedbackFormsProvider).when(
        data: (allForms) {
          final branchForms = allForms
              .where((form) => form.branch == widget.branch)
              .toList()
            ..sort((a, b) => a.semester.compareTo(b.semester));

          if (branchForms.isEmpty) {
            return _buildEmptyState(context);
          }

          // Get all available semesters
          final availableSemesters = branchForms
              .map((f) => f.semester)
              .toSet()
              .toList()
            ..sort();

          // Initialize all semesters as enabled on first load
          if (!_initialized) {
            _enabledSemesters.addAll(availableSemesters);
            _initialized = true;
          }

          // Filter forms by enabled semesters
          final visibleForms = branchForms
              .where((form) => _enabledSemesters.contains(form.semester))
              .toList();

          // Group visible forms by semester
          final grouped = _groupBySemester(visibleForms);
          final semesters = grouped.keys.toList()..sort();

          return Column(
            children: [
              // Semester pills
              _SemesterPills(
                availableSemesters: availableSemesters,
                enabledSemesters: _enabledSemesters,
                onToggle: (sem) {
                  setState(() {
                    if (_enabledSemesters.contains(sem)) {
                      _enabledSemesters.remove(sem);
                    } else {
                      _enabledSemesters.add(sem);
                    }
                  });
                },
              ),
              const Divider(height: 1),
              // Forms list
              Expanded(
                child: visibleForms.isEmpty
                    ? Center(
                        child: Text(
                          'No semesters selected',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: semesters.length,
                        itemBuilder: (context, index) {
                          final sem = semesters[index];
                          final forms = grouped[sem]!;
                          return _SemesterSection(
                            semester: sem,
                            forms: forms,
                          );
                        },
                      ),
              ),
            ],
          );
        },
        error: (e, _) => NoInternetWidget(
          message: 'Unable to load forms.\nPlease check your connection.',
          onRetry: () => ref.invalidate(feedbackFormsProvider),
        ),
        loading: () => const Loader(),
      ),
    );
  }

  Map<int, List<FeedbackForm>> _groupBySemester(List<FeedbackForm> forms) {
    final Map<int, List<FeedbackForm>> grouped = {};
    for (final form in forms) {
      grouped.putIfAbsent(form.semester, () => []).add(form);
    }
    return grouped;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No forms found for ${widget.branch}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal scrollable semester toggle pills.
class _SemesterPills extends StatelessWidget {
  final List<int> availableSemesters;
  final Set<int> enabledSemesters;
  final ValueChanged<int> onToggle;

  const _SemesterPills({
    required this.availableSemesters,
    required this.enabledSemesters,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: availableSemesters.map((sem) {
          final isEnabled = enabledSemesters.contains(sem);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('Sem $sem'),
              selected: isEnabled,
              onSelected: (_) => onToggle(sem),
              selectedColor: theme.colorScheme.primary.withAlpha((0.15 * 255).toInt()),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                fontWeight: isEnabled ? FontWeight.w600 : FontWeight.w400,
                color: isEnabled ? theme.colorScheme.primary : Colors.grey.shade700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isEnabled
                      ? theme.colorScheme.primary.withAlpha((0.4 * 255).toInt())
                      : Colors.grey.shade300,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Displays a section for a single semester with its forms.
class _SemesterSection extends StatelessWidget {
  final int semester;
  final List<FeedbackForm> forms;

  const _SemesterSection({
    required this.semester,
    required this.forms,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha((0.12 * 255).toInt()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Semester $semester',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${forms.length} form${forms.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        ...forms.map((form) => _FormTile(form: form)),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// A single form card within a semester section.
class _FormTile extends StatelessWidget {
  final FeedbackForm form;

  const _FormTile({required this.form});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withAlpha((0.10 * 255).toInt()),
          child: Icon(Icons.assignment, color: theme.colorScheme.primary, size: 22),
        ),
        title: Text(
          form.subject,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          form.facultyName,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
        onTap: () {
          context.push('/edit-feedback-form', extra: form);
        },
      ),
    );
  }
}
