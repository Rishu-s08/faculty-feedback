import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyfeed/core/failure.dart';
import 'package:facultyfeed/core/providers/firebase_providers.dart';
import 'package:facultyfeed/core/typedefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final editFeedbackFormRepositoryProvider = Provider((ref) {
  return EditFeedbackRepository(firestore: ref.read(firebaseFirestoreProvider));
});

class EditFeedbackRepository {
  final FirebaseFirestore _firestore;
  EditFeedbackRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get feedbackFormsCollection =>
      _firestore.collection('feedback_forms');

  FutureVoid updateFeedbackForm({
    required String formId,
    required String subject,
    required String facultyName,
    required int year,
    required String branch,
    required int semester,
  }) async {
    try {
      await feedbackFormsCollection.doc(formId).update({
        'subject': subject,
        'facultyName': facultyName,
        'year': year,
        'branch': branch,
        'semester': semester,
      });

      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
