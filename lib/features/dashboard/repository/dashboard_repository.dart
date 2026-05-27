import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyfeed/core/failure.dart';
import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:facultyfeed/core/providers/firebase_providers.dart';
import 'package:facultyfeed/core/typedefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final dashboardRepositoryProvider = Provider((ref) {
  return DashboardRepository(
    firebaseFirestore: ref.read(firebaseFirestoreProvider),
  );
});

class DashboardRepository {
  final FirebaseFirestore _firebaseFirestore;
  DashboardRepository({required FirebaseFirestore firebaseFirestore})
    : _firebaseFirestore = firebaseFirestore;

  CollectionReference get feedbackFormsCollection =>
      _firebaseFirestore.collection('feedback_forms');

  Stream<List<FeedbackForm>> getFeedbackForms() {
    return feedbackFormsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => FeedbackForm.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  FutureEither<FeedbackForm> getFeedbackFormByFormId(String formId) async {
    try {
      final doc = await feedbackFormsCollection.doc(formId).get();
      if (doc.exists) {
        final feedbackForm = FeedbackForm.fromMap(
          doc.data() as Map<String, dynamic>,
        );
        return right(feedbackForm);
      } else {
        return left(Failure('Feedback form not found'));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Delete feedback form and all associated student responses
  FutureVoid deleteFeedbackForm(String formId) async {
    try {
      // 1️⃣ Delete all student responses associated with this form
      final responsesSnapshot =
          await _firebaseFirestore
              .collection('response_feedbacks')
              .where('formID', isEqualTo: formId)
              .get();

      // Delete each response document
      final batch = _firebaseFirestore.batch();
      for (var doc in responsesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 2️⃣ Delete the feedback form itself
      batch.delete(feedbackFormsCollection.doc(formId));

      // Execute all deletions
      await batch.commit();

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
