import 'package:facultyfeed/core/models/feedback_form.dart';
import 'package:facultyfeed/features/admin/screens/form_select_screen.dart';
import 'package:facultyfeed/features/admin/screens/stats_screen.dart';
import 'package:facultyfeed/features/auth/controller/auth_controller.dart';
import 'package:facultyfeed/features/feedback/screen/give_feedback_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

class AppRouter {
  static GoRouter getRouter(User? user, WidgetRef ref) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) async {
        // await user?.reload();
        final refreshedUser = FirebaseAuth.instance.currentUser;
        user = refreshedUser;
        final isOnPublicRoutes = ['/login'].contains(state.matchedLocation);

        if (user == null && !isOnPublicRoutes) return '/login';

        // If user is logged in and verified and tries to visit login/signup, send them to home
        if (user != null && (state.matchedLocation == '/login')) {
          final uid = user!.uid;
          try {
            final userModel =
                await ref.read(authControllerProvider).getUserData(uid).first;
            ref.read(userProvider.notifier).state = userModel;
          } catch (e) {
            // Handle error or fallback
          }
          return '/dashboard';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) {
            final form = state.extra as FeedbackForm;
            return StatsScreen(form: form);
          },
        ),
        GoRoute(
          path: '/stats-form',
          builder: (context, state) => const FormSelectScreen(),
        ),
        GoRoute(
          path: '/give-feedback',
          builder: (context, state) {
            final form = state.extra as FeedbackForm;
            return GiveFeedbackScreen(form: form);
          },
        ),
      ],
    );
  }
}
