import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:facultyfeed/core/providers/firebase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}
