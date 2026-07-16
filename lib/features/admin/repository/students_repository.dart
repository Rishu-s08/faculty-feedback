import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyfeed/core/failure.dart';
import 'package:facultyfeed/core/models/user_model.dart';
import 'package:facultyfeed/core/providers/firebase_providers.dart';
import 'package:facultyfeed/core/typedefs.dart';
import 'package:facultyfeed/firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final studentsRepositoryProvider = Provider((ref) {
  return StudentsRepository(firestore: ref.read(firebaseFirestoreProvider));
});

class StudentsRepository {
  final FirebaseFirestore _firestore;

  StudentsRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get _users => _firestore.collection('users');

  /// Create a student account with auto-generated credentials
  /// Email: <rollno>@mlvti.ac.in
  /// Password: rollno
  FutureEither<UserModel> createStudent({
    required String studentName,
    required String rollNumber,
    required int semester,
    required String branch,
  }) async {
    try {
      final email = '$rollNumber@mlvti.ac.in';
      final password = rollNumber;

      // Create user via Identity Toolkit REST API so the SDK doesn't switch currentUser
      final apiKey = DefaultFirebaseOptions.android.apiKey;
      final uri = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
      );

      final payload = jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      });

      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      if (resp.statusCode != 200) {
        final body = jsonDecode(resp.body);
        final message =
            body['error'] != null && body['error']['message'] != null
                ? body['error']['message']
                : 'Failed to create user';
        if (message.contains('EMAIL_EXISTS')) {
          return left(Failure('Student with this roll number already exists'));
        }
        return left(Failure(message));
      }

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final uid = body['localId'] as String;

      // Create UserModel
      final batch = _batchFromRollNumber(rollNumber);
      final userModel = UserModel(
        uid: uid,
        email: email,
        name: studentName,
        branch: branch,
        semester: semester,
        batch: batch,
        passOut: false,
        role: 'student',
        submittedFormIds: const [],
      );

      // Save to Firestore
      await _users.doc(uid).set(userModel.toMap());

      return right(userModel);
    } catch (e) {
      return left(Failure('Error creating student: ${e.toString()}'));
    }
  }

  /// Get all students
  Stream<List<UserModel>> getAllStudents() {
    return _users.where('role', isEqualTo: 'student').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get students by branch and semester
  Stream<List<UserModel>> getStudentsByBranchAndSemester({
    required String branch,
    required int semester,
  }) {
    return _users
        .where('role', isEqualTo: 'student')
        .where('branch', isEqualTo: branch)
        .where('semester', isEqualTo: semester)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();
        });
  }

  /// Get single student by email. Returns null if not found.
  Future<UserModel?> getStudentByEmail(String email) async {
    final snapshot =
        await _users.where('email', isEqualTo: email).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  /// Update student fields by uid
  FutureEither<void> updateStudent(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _users.doc(uid).update(updates);
      return right(null);
    } catch (e) {
      return left(Failure('Error updating student: ${e.toString()}'));
    }
  }

  /// Bulk update semester for all students with `fromSemester` to `toSemester`.
  /// If `batchYear` is provided, only students of that batch are updated.
  /// Uses batched writes (500 ops per batch) to minimize round-trips.
  FutureEither<int> bulkUpdateSemester({
    required int fromSemester,
    required int toSemester,
    int? batchYear,
  }) async {
    try {
      final querySnap =
          await _users
              .where('role', isEqualTo: 'student')
              .where('semester', isEqualTo: fromSemester)
              .get();

      var docs = querySnap.docs;

      // Filter by batch if specified (client-side since Firestore can't do 3 where clauses easily)
      if (batchYear != null) {
        docs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['batch'] == batchYear;
        }).toList();
      }

      if (docs.isEmpty) return right(0);

      const batchLimit = 500;
      int updated = 0;
      for (var i = 0; i < docs.length; i += batchLimit) {
        final batch = _firestore.batch();
        final chunk = docs.sublist(i, (i + batchLimit).clamp(0, docs.length));
        for (final doc in chunk) {
          final shouldPassOut = toSemester == 9;
          batch.update(doc.reference, {
            'semester': shouldPassOut ? 9 : toSemester,
            'passOut': shouldPassOut,
            'submittedFormIds': [], // Clear so students can submit new semester's forms
          });
        }
        await batch.commit();
        updated += chunk.length;
      }

      return right(updated);
    } catch (e) {
      return left(Failure('Bulk update error: ${e.toString()}'));
    }
  }

  /// Count students with a given semester (optionally filtered by batch)
  Future<int> countStudentsBySemester(int semester, {int? batchYear}) async {
    try {
      final snap =
          await _users
              .where('role', isEqualTo: 'student')
              .where('semester', isEqualTo: semester)
              .get();
      if (batchYear == null) return snap.docs.length;
      return snap.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['batch'] == batchYear;
      }).length;
    } catch (e) {
      return 0;
    }
  }

  /// Get counts of students grouped by semester (only semesters with students)
  Future<Map<int, int>> getActiveSemesterCounts() async {
    try {
      final snap = await _users.where('role', isEqualTo: 'student').get();
      final Map<int, int> counts = {};
      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final sem = data['semester'] as int?;
        if (sem != null) {
          counts[sem] = (counts[sem] ?? 0) + 1;
        }
      }
      return counts;
    } catch (e) {
      return {};
    }
  }

  /// Get available batch years from all students
  Future<List<int>> getAvailableBatches() async {
    try {
      final snap = await _users.where('role', isEqualTo: 'student').get();
      final Set<int> batches = {};
      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final batch = data['batch'];
        if (batch != null) {
          batches.add((batch as num).toInt());
        }
      }
      final list = batches.toList()..sort((a, b) => b.compareTo(a));
      return list;
    } catch (e) {
      return [];
    }
  }

  /// Delete a student account
  FutureEither<void> deleteStudent(String uid, String email) async {
    try {
      // Delete from Firestore
      await _users.doc(uid).delete();

      // Note: Deleting from Firebase Auth requires the user to be the current user
      // For admin deletion, we can only delete from Firestore
      // The auth account should be deleted separately or through Firebase Console

      return right(null);
    } catch (e) {
      return left(Failure('Error deleting student: ${e.toString()}'));
    }
  }

  /// Delete a student from Firestore and optionally call an admin endpoint to delete from Auth.
  /// If `adminDeleteUrl` is empty, only Firestore deletion is performed.
  FutureEither<void> deleteStudentCompletely({
    required String uid,
    required String email,
    String adminDeleteUrl = '',
  }) async {
    try {
      // Delete Firestore doc
      await _users.doc(uid).delete();

      if (adminDeleteUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(adminDeleteUrl);
          // POST uid to admin endpoint. The endpoint should authenticate the request.
          await http.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'uid': uid}),
          );
        } catch (e) {
          // Log but do not fail the whole operation if admin delete fails
        }
      }

      return right(null);
    } catch (e) {
      return left(Failure('Error deleting student: ${e.toString()}'));
    }
  }

  /// Get student count
  Future<int> getStudentCount() async {
    try {
      final snapshot =
          await _users.where('role', isEqualTo: 'student').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Bulk create students from parsed rows.
  /// Each row must contain: rollNumber, name, semester, branch
  /// Returns a summary: created, skipped (already exists), failed and errors list
  FutureEither<Map<String, dynamic>> bulkCreateStudents(
    List<Map<String, dynamic>> rows,
  ) async {
    try {
      int created = 0;
      int skipped = 0;
      int failed = 0;
      final List<Map<String, String>> errors = [];

      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        final roll =
            (row['rollNumber'] ?? row['roll_no'] ?? row['roll'] ?? '')
                .toString()
                .trim();
        final name = (row['name'] ?? '').toString().trim();
        final branch = (row['branch'] ?? '').toString().trim();
        final semRaw = (row['semester'] ?? row['sem'] ?? '').toString().trim();

        if (roll.isEmpty || name.isEmpty || branch.isEmpty || semRaw.isEmpty) {
          failed++;
          errors.add({'row': '${i + 1}', 'error': 'Missing required fields'});
          continue;
        }

        final sem = int.tryParse(semRaw);
        if (sem == null) {
          failed++;
          errors.add({'row': '${i + 1}', 'error': 'Invalid semester: $semRaw'});
          continue;
        }

        final result = await createStudent(
          studentName: name,
          rollNumber: roll,
          semester: sem,
          branch: branch,
        );

        await result.match(
          (l) async {
            final msg = l.message;
            if (msg.toLowerCase().contains('already exists')) {
              skipped++;
            } else {
              failed++;
              errors.add({'row': '${i + 1}', 'error': msg});
            }
          },
          (r) async {
            created++;
          },
        );
      }

      return right({
        'created': created,
        'skipped': skipped,
        'failed': failed,
        'errors': errors,
      });
    } catch (e) {
      return left(Failure('Bulk import error: ${e.toString()}'));
    }
  }

  /// Derive batch year (e.g. 2024) from roll number prefix (e.g. "24EMBCS001")
  int? _batchFromRollNumber(String rollNumber) {
    try {
      if (rollNumber.length < 2) return null;
      final prefix = rollNumber.substring(0, 2);
      final code = int.tryParse(prefix);
      if (code == null) return null;
      return 2000 + code;
    } catch (_) {
      return null;
    }
  }
}
