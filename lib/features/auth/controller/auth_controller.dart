import 'package:facultyfeed/core/models/user_model.dart';
import 'package:facultyfeed/core/remaining_form_dialog.dart';
import 'package:facultyfeed/core/snackbar.dart';
import 'package:facultyfeed/features/auth/repository/auth_repository.dart';
import 'package:facultyfeed/features/feedback/controller/give_feedback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final authControllerProvider = Provider(
  (ref) => AuthController(
    authRepository: ref.read(authRepositoryProvider),
    ref: ref,
  ),
);

final userProvider = StateProvider<UserModel?>((ref) => null);

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  return ref.read(authControllerProvider).getUserData(uid);
});

class AuthController {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
    : _authRepository = authRepository,
      _ref = ref;

  void signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final res = await _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    res.fold(
      (l) {
        showPrettySnackBar(context, l.message, isError: true);
        return;
      },
      (r) {
        print(r.name);
        _ref.read(userProvider.notifier).update((state) => r);
        context.go('/dashboard');
      },
    );
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  void signOut(BuildContext context) async {
    if (_ref.read(isFormRemainingProvider)) {
      await showRemainingFormsDialog(context);
      return;
    } else {
      final result = await _authRepository.signOut();
      result.fold(
        (l) => showPrettySnackBar(context, l.message),
        (r) => _ref.read(userProvider.notifier).update((state) => null),
      );
    }
  }
}
