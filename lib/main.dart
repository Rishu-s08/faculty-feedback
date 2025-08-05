import 'package:facultyfeed/app_router.dart';
import 'package:facultyfeed/features/auth/repository/auth_repository.dart';
import 'package:facultyfeed/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: FacultyFeedbackApp()));
}

class FacultyFeedbackApp extends ConsumerWidget {
  const FacultyFeedbackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.maybeWhen(data: (user) => user, orElse: () => null);
    return MaterialApp.router(
      // scrollBehavior: ScrollBehavior(),
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Cartelle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.getRouter(user, ref),
    );
  }
}
