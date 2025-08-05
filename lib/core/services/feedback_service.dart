import '../models/feedback_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackService {
  final _feedbacks = FirebaseFirestore.instance.collection('feedbacks');

  Future<void> submitFeedback(FeedbackForm feedback) async {
    await _feedbacks.doc(feedback.id).set(feedback.toMap());
  }

  Stream<List<FeedbackForm>> getAllFeedbacks() {
    return _feedbacks.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => FeedbackForm.fromMap(doc.data())).toList(),
    );
  }
}
