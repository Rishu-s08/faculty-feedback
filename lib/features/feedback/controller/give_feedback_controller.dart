import 'package:facultyfeed/core/models/response_form.dart';
import 'package:facultyfeed/core/snackbar.dart';
import 'package:facultyfeed/core/typedefs.dart';
import 'package:facultyfeed/features/auth/controller/auth_controller.dart';
import 'package:facultyfeed/features/feedback/repository/give_feedback_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final giveFeedbackControllerProvider = Provider((ref) {
  return GiveFeedbackController(
    giveFeedbackRepository: ref.read(giveFeedbackRepositoryProvider),
    ref: ref,
  );
});

final isFormRemainingProvider = StateProvider<bool>((ref) {
  return false;
});

class GiveFeedbackController {
  final GiveFeedbackRepository _giveFeedbackRepository;
  final Ref _ref;
  GiveFeedbackController({
    required GiveFeedbackRepository giveFeedbackRepository,
    required Ref ref,
  }) : _giveFeedbackRepository = giveFeedbackRepository,
       _ref = ref;

  FutureVoid giveFeedback(
    String formID,
    String faculty,
    String subject,
    int sem,
    Map<String, int> responses,
    String? comment,
    BuildContext context,
    String branch,
  ) async {
    return await _giveFeedbackRepository.giveFeedback(
      formID: formID,
      faculty: faculty,
      subject: subject,
      branch: branch,
      userId: _ref.read(userProvider)!.uid,
      studentName: _ref.read(userProvider)!.name,
      studentEmail: _ref.read(userProvider)!.email,
      sem: sem,
      responses: responses,
      comment: comment,
    );
  }

  Future<List<ResponseForm>> getResponsesFormFromID(
    String formID,
    BuildContext context,
  ) async {
    final res = await _giveFeedbackRepository.getResponsesFormFromID(formID);
    return res.fold((l) {
      showPrettySnackBar(context, l.message, isError: true);
      return [];
    }, (r) => r);
  }
}
