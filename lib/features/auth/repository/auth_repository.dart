// IMPORTANT: Ensure Firebase is initialized in main.dart before using AuthRepository.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyfeed/core/failure.dart';
import 'package:facultyfeed/core/models/user_model.dart';
import 'package:facultyfeed/core/providers/firebase_providers.dart';
import 'package:facultyfeed/core/typedefs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    auth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firebaseFirestoreProvider),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  CollectionReference get _user => _firestore.collection('users');

  FutureEither<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      // final userModel = UserModel(
      //   email: user.email!,
      //   name: "Nitesh Chauhan",
      //   role: "admin",
      //   branch: "CSE",
      //   uid: user.uid,
      // );
      // await _user.doc(user.uid).set(userModel.toMap());
      final userModel = await getUserData(user.uid).first;
      print(userModel);
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'invalid-user' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-email') {
        return left(Failure('Invalid email or password'));
      } else {
        return left(Failure(e.message ?? 'Authentication error'));
      }
    } catch (e) {
      return left(Failure('Sign-in error: ${e.toString()}'));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _user.doc(uid).snapshots().map((event) {
      final data = event.data();
      if (data == null) {
        throw Exception('user data not found');
      } else {
        return UserModel.fromMap(data as Map<String, dynamic>);
      }
    });
  }

  FutureVoid signOut() async {
    try {
      await _auth.signOut();
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
