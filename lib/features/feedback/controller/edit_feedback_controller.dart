import 'package:facultyfeed/core/typedefs.dart';
import 'package:facultyfeed/features/feedback/repository/edit_feedback_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final editFeedbackControllerProvider = Provider((ref) {
  return EditFeedbackController(
    editFeedbackRepository: ref.read(editFeedbackFormRepositoryProvider),
    ref: ref,
  );
});

class EditFeedbackController {
  final EditFeedbackRepository _editFeedbackRepository;
  final Ref _ref;
  EditFeedbackController({
    required EditFeedbackRepository editFeedbackRepository,
    required Ref ref,
  }) : _editFeedbackRepository = editFeedbackRepository,
       _ref = ref;

  FutureVoid updateFeedback(
    String formId,
    String subject,
    String facultyName,
    int year,
    int semester,
    String branch,
  ) async {
    return await _editFeedbackRepository.updateFeedbackForm(
      formId: formId,
      subject: subject,
      facultyName: facultyName,
      year: year,
      branch: branch,
      semester: semester,
    );
  }
}
