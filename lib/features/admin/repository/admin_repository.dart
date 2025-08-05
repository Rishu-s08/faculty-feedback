import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyfeed/core/typedefs.dart';

class AdminRepository {
  final FirebaseFirestore _firebaseFirestore;
  AdminRepository(final FirebaseFirestore firebaseFirestore)
    : _firebaseFirestore = firebaseFirestore;
}
