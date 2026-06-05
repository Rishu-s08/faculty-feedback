import 'package:connectivity_plus/connectivity_plus.dart';
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
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Faculty Performance Evaluation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.getRouter(user, ref),
      builder: (context, child) => _ConnectivityGuard(child: child!),
    );
  }
}

class _ConnectivityGuard extends StatefulWidget {
  final Widget child;
  const _ConnectivityGuard({required this.child});

  @override
  State<_ConnectivityGuard> createState() => _ConnectivityGuardState();
}

class _ConnectivityGuardState extends State<_ConnectivityGuard> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    // Check initial state
    Connectivity().checkConnectivity().then(_updateStatus);
    // Listen for changes
    Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(dynamic result) {
    // result can be ConnectivityResult or List<ConnectivityResult>
    final List<ConnectivityResult> results =
        result is List ? List<ConnectivityResult>.from(result) : [result as ConnectivityResult];
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (mounted && offline != _isOffline) setState(() => _isOffline = offline);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off_rounded, size: 56, color: Colors.redAccent),
                          SizedBox(height: 16),
                          Text(
                            'No Internet Connection',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please check your network.\nThe app will resume automatically when connected.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
