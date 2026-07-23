import 'package:facultyfeed/core/constants.dart';
import 'package:facultyfeed/core/dialogs/delete_confirmation_dialog.dart';
import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:facultyfeed/core/snackbar.dart';
import 'package:facultyfeed/features/dashboard/controller/dashboard_controller.dart';
import 'package:facultyfeed/features/feedback/controller/edit_feedback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EditFeedbackScreen extends ConsumerStatefulWidget {
  final FeedbackForm form;
  const EditFeedbackScreen({super.key, required this.form});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditFeedbackScreenState();
}

class _EditFeedbackScreenState extends ConsumerState<EditFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  String selectedYear = '1st Year';
  String selectedSem = 'even';
  String selectedBranch = 'CSE';
  List<String> suffixForYear = ['st', 'nd', 'rd', 'th'];

  @override
  void initState() {
    super.initState();
    _facultyController.text = widget.form.facultyName;
    _subjectController.text = widget.form.subject;
    selectedYear =
        '${widget.form.year}${suffixForYear[widget.form.year - 1]} Year';
    selectedSem = widget.form.semester % 2 == 0 ? 'even' : 'odd';
    selectedBranch = widget.form.branch;
  }

  final _facultyController = TextEditingController();
  final _subjectController = TextEditingController();

  final List<String> staticQuestions = [
    'Subject Knowledge and Expertise',
    'Teaching Methodology and Delivery',
    'Communication and Clarity',
    'Punctuality and Professionalism',
    'Mentorship, Guidance, and Support',
  ];

  // void _submitForm() async {
  //   if (_formKey.currentState!.validate()) {
  //     final controller = ref.read(addFeedbackControllerProvider);
  //     final year = int.parse(selectedYear[0]);
  //     final sem = selectedSem == 'even' ? 2 * year : 2 * year - 1;

  //     final res = await controller.addFeedback(
  //       _subjectController.text.trim(),
  //       _facultyController.text.trim(),
  //       year,
  //       sem,
  //       staticQuestions,
  //       selectedBranch,
  //     );

  //     res.fold(
  //       (l) {
  //         if (context.mounted) {
  //           showPrettySnackBar(context, l.message, isError: true);
  //         }
  //       },
  //       (_) {
  //         if (context.mounted) {
  //           showPrettySnackBar(context, "Feedback form created successfully");
  //           Navigator.of(context).pop();
  //         }
  //       },
  //     );
  //   }
  // }

  void _updateForm() async {
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(editFeedbackControllerProvider);
      final year = int.parse(selectedYear[0]);
      final sem = selectedSem == 'even' ? 2 * year : 2 * year - 1;
      final res = await controller.updateFeedback(
        widget.form.id,
        _subjectController.text.trim(),
        _facultyController.text.trim(),
        year,
        sem,
        selectedBranch,
      );

      res.fold(
        (l) {
          if (context.mounted) {
            showPrettySnackBar(context, l.message, isError: true);
          }
        },
        (_) {
          if (context.mounted) {
            showPrettySnackBar(context, "Feedback form updated successfully");
            Navigator.of(context).pop();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _facultyController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Feedback Form'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Form',
            onPressed: () async {
              final confirm = await showDeleteConfirmationDialog(
                context: context,
                formTitle:
                    '${widget.form.subject} - ${widget.form.facultyName}',
              );

              if (confirm == true && context.mounted) {
                await ref
                    .read(feedbackControllerProvider)
                    .deleteFeedbackForm(widget.form.id, context);

                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Select Year',
                  border: OutlineInputBorder(),
                ),
                items:
                    ['1st Year', '2nd Year', '3rd Year', '4th Year']
                        .map(
                          (year) =>
                              DropdownMenuItem(value: year, child: Text(year)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedYear = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedSem,
                decoration: const InputDecoration(
                  labelText: 'Select Semester',
                  border: OutlineInputBorder(),
                ),
                items:
                    ['even', 'odd']
                        .map(
                          (sem) =>
                              DropdownMenuItem(value: sem, child: Text(sem)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedSem = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedBranch,
                decoration: const InputDecoration(
                  labelText: 'Select Branch',
                  border: OutlineInputBorder(),
                ),
                items:
                    Constants.branches
                        .map(
                          (branch) => DropdownMenuItem(
                            value: branch,
                            child: Text(branch),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedBranch = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _facultyController,
                decoration: const InputDecoration(
                  labelText: 'Faculty Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter faculty name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter subject name' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Static Feedback Questions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...staticQuestions.map(
                (q) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text('• $q', style: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Update Feedback Form'),
                onPressed: _updateForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
