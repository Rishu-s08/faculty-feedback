import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyfeed/core/failure.dart';
import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:facultyfeed/core/models/response_form.dart';
import 'package:facultyfeed/core/providers/firebase_providers.dart';
import 'package:facultyfeed/core/typedefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

final giveFeedbackRepositoryProvider = Provider((ref) {
  return GiveFeedbackRepository(firestore: ref.read(firebaseFirestoreProvider));
});

class GiveFeedbackRepository {
  final FirebaseFirestore _firestore;
  GiveFeedbackRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get feedbackFormsCollection =>
      _firestore.collection('feedback_forms');

  CollectionReference get _responseFeedbacksCollection =>
      _firestore.collection('response_feedbacks');

  FutureVoid giveFeedback({
    required String formID,
    required String faculty,
    required String subject,
    required int sem,
    required String studentName,
    required String studentEmail,
    required Map<String, int> responses,
    required String? comment,
  }) async {
    try {
      final id = Uuid().v4();
      final response = ResponseForm(
        id: id,
        formID: formID,
        faculty: faculty,
        subject: subject,
        studentName: studentName,
        studentEmail: studentEmail,
        sem: sem,
        responses: responses,
      );

      final docSnapshot = await feedbackFormsCollection.doc(formID).get();
      if (!docSnapshot.exists) throw Exception("Feedback form not found");

      final data = docSnapshot.data()! as Map<String, dynamic>;
      final FeedbackForm form = FeedbackForm.fromMap(data);

      final prevRatings = form.ratings;
      final totalResponses = form.totalResponses;

      // ✅ New averaged ratings
      Map<String, double> updatedRatings = {};
      responses.forEach((question, newRating) {
        final oldRating = prevRatings[question] ?? 0.0;
        final newAverage =
            ((oldRating * totalResponses) + newRating) / (totalResponses + 1);
        updatedRatings[question] = double.parse(
          newAverage.toStringAsFixed(2),
        ); // rounding
      });

      // ✅ Update the FeedbackForm doc
      await feedbackFormsCollection.doc(formID).update({
        'ratings': updatedRatings,
        'totalResponses': totalResponses + 1,
      });

      // ✅ Save student response in 'responses' subcollection or another collection
      await _responseFeedbacksCollection.doc(id).set(response.toMap());
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<List<ResponseForm>> getResponsesFormFromID(String formID) async {
    try {
      final form = await _responseFeedbacksCollection
          .where('formID', isEqualTo: formID)
          .get()
          .then(
            (value) =>
                value.docs
                    .map(
                      (e) => ResponseForm.fromMap(
                        e.data() as Map<String, dynamic>,
                      ),
                    )
                    .toList(),
          );
      return right(form);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
