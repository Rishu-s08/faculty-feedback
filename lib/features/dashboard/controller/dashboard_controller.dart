import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:facultyfeed/features/dashboard/repository/dashboard_repository.dart';
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
}
