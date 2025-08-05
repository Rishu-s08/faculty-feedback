import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyfeed/core/failure.dart';
import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:facultyfeed/core/providers/firebase_providers.dart';
import 'package:facultyfeed/core/typedefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

final addFeedbackRepositoryProvider = Provider((ref) {
  return AddFeedbackRepository(firestore: ref.read(firebaseFirestoreProvider));
});

class AddFeedbackRepository {
  final FirebaseFirestore _firestore;
  AddFeedbackRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get feedbackFormsCollection =>
      _firestore.collection('feedback_forms');

  FutureVoid createFeedbackForm({
    required String subject,
    required String facultyName,
    required int year,
    required int semester,
    required List<String> questions,
  }) async {
    final formId = _uuid.v4();
    Map<String, double> questionMap = {
      for (var question in questions) question: 0.0,
    };

    final data = FeedbackForm(
      id: formId,
      subject: subject,
      facultyName: facultyName,
      year: year,
      semester: semester,
      totalResponses: 0,
      ratings: questionMap,
      questions: questions,
      createdAt: DateTime.now(),
    );
    try {
      await feedbackFormsCollection.doc(formId).set(data.toMap());
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
