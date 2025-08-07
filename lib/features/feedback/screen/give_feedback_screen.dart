import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:facultyfeed/core/snackbar.dart';
import 'package:facultyfeed/features/auth/controller/auth_controller.dart';
import 'package:facultyfeed/features/dashboard/controller/dashboard_controller.dart';
import 'package:facultyfeed/features/feedback/controller/give_feedback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GiveFeedbackScreen extends ConsumerStatefulWidget {
  final FeedbackForm form;

  const GiveFeedbackScreen({super.key, required this.form});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GiveFeedbackScreenState();
}

class _GiveFeedbackScreenState extends ConsumerState<GiveFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();

  late Map<String, int?> _responses;

  final _ratingOptions = [1, 2, 3, 4, 5];

  late List<String> _questions;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _questions = widget.form.questions;
    _responses = {for (var q in widget.form.questions) q: null};
  }

  void _submit() async {
    final hasUnanswered = _responses.values.any((v) => v == null);

    if (hasUnanswered) {
      showPrettySnackBar(context, 'Please answer all questions', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final res = await ref
        .read(giveFeedbackControllerProvider)
        .giveFeedback(
          widget.form.id,
          widget.form.facultyName,
          widget.form.subject,
          widget.form.semester,
          _responses.cast<String, int>(),
          _commentController.text.trim(),
          context,
          widget.form.branch,
        );
    res.fold(
      (onLeft) => showPrettySnackBar(context, onLeft.message, isError: true),
      (onRight) =>
          showPrettySnackBar(context, "Feedback submitted successfully"),
    );
    if (mounted) {
      setState(() => _isSubmitting = false);
      // ignore: unused_result
      // ref.invalidate(userProvider);
      // ref.invalidate(feedbackFormsProvider);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;

    return Scaffold(
      appBar: AppBar(title: const Text('Give Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${form.facultyName} — ${form.subject}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),

                  ..._questions.map((question) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          children:
                              _ratingOptions.map((rating) {
                                return ChoiceChip(
                                  label:
                                      _responses[question] == rating
                                          ? Text(' ')
                                          : Text('$rating'),
                                  labelPadding:
                                      _responses[question] == rating
                                          ? EdgeInsets.all(0)
                                          : null,
                                  selected: _responses[question] == rating,
                                  onSelected: (_) {
                                    if (_responses[question] == rating) {
                                      setState(() {
                                        _responses[question] = null;
                                      });
                                    } else {
                                      setState(() {
                                        _responses[question] = rating;
                                      });
                                    }
                                  },
                                  selectedColor:
                                      Theme.of(context).colorScheme.primary,
                                  labelStyle: TextStyle(
                                    color:
                                        _responses[question] == rating
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),

                  TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Any additional comments (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child:
                          _isSubmitting
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              )
                              : const Text('Submit Feedback'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
