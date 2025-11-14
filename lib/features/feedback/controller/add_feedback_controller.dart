import 'package:facultyfeed/core/typedefs.dart';
import 'package:facultyfeed/features/feedback/repository/add_feedback_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addFeedbackControllerProvider = Provider((ref) {
  return AddFeedbackController(
    addFeedbackRepository: ref.read(addFeedbackRepositoryProvider),
    ref: ref,
  );
});

class AddFeedbackController {
  final AddFeedbackRepository _addFeedbackRepository;
  final Ref _ref;
  AddFeedbackController({
    required AddFeedbackRepository addFeedbackRepository,
    required Ref ref,
  }) : _addFeedbackRepository = addFeedbackRepository,
       _ref = ref;

  FutureVoid addFeedback(
    String subject,
    String facultyName,
    int year,
    int semester,
    List<String> questions,
    String branch,
  ) async {
    return await _addFeedbackRepository.createFeedbackForm(
      subject: subject,
      facultyName: facultyName,
      year: year,
      branch: branch,
      semester: semester,
      questions: questions,
    );
  }
}
