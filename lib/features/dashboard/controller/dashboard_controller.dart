import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:facultyfeed/core/snackbar.dart';
import 'package:facultyfeed/core/typedefs.dart';
import 'package:facultyfeed/features/dashboard/repository/dashboard_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedbackControllerProvider = Provider<FeedbackController>(
  (ref) => FeedbackController(
    dashboardRepository: ref.read(dashboardRepositoryProvider),
  ),
);

final feedbackFormsProvider = StreamProvider((ref) {
  return ref.read(feedbackControllerProvider).getFeedbackForms();
});

class FeedbackController {
  final DashboardRepository _dashboardRepository;
  FeedbackController({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository;

  Stream<List<FeedbackForm>> getFeedbackForms() {
    return _dashboardRepository.getFeedbackForms();
  }

  Future<FeedbackForm> getFeedbackFormByFormId(
    String formId,
    BuildContext context,
  ) async {
    final form = await _dashboardRepository.getFeedbackFormByFormId(formId);
    return form.fold((l) {
      showPrettySnackBar(context, l.message, isError: true);
      return [] as FeedbackForm;
    }, (r) => r);
  }

  Future<void> deleteFeedbackForm(String formId, BuildContext context) async {
    final result = await _dashboardRepository.deleteFeedbackForm(formId);
    result.fold(
      (l) => showPrettySnackBar(context, l.message, isError: true),
      (r) => showPrettySnackBar(context, 'Form deleted successfully'),
    );
  }
}
