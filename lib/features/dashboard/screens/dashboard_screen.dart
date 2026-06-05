import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:facultyfeed/core/constants.dart';
import 'package:facultyfeed/core/loader.dart';
import 'package:facultyfeed/core/models/user_model.dart';
import 'package:facultyfeed/core/no_internet_widget.dart';
import 'package:facultyfeed/features/auth/controller/auth_controller.dart';
import 'package:facultyfeed/features/feedback/screen/add_feedback_screen.dart';
import 'package:facultyfeed/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int activeIndex = 0;

  String _firstName(UserModel user) {
    final parts = user.name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? user.name : parts.first;
  }

  bool _isPassOutStudent(UserModel user) {
    return user.role != 'admin' && user.semester == 9;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    final isHome = activeIndex == 0;
    final title = isHome ? 'Welcome, ${_firstName(user)}' : 'My Profile';

    return AppBar(
      titleSpacing: 20,
      elevation: 0,
      centerTitle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha((0.08 * 255).toInt()),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            onPressed: () {
              ref.read(authControllerProvider).signOut(context);
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ),
      ],
    );
  }

  Widget _buildPassOutDashboard(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _buildAppBar(context, user),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Card(
                elevation: 10,
                shadowColor: theme.colorScheme.primary.withAlpha(
                  (0.18 * 255).toInt(),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: theme.colorScheme.primary.withAlpha(
                          (0.12 * 255).toInt(),
                        ),
                        child: Icon(
                          Icons.celebration,
                          size: 46,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Congratulations, ${user.name}!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You have officially passed out from ${user.branch}.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'This marks the end of your academic journey in this app.\nWe are proud of your achievement and wish you great success ahead.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(
                            (0.08 * 255).toInt(),
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Roll Number',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email.split('@').first,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Branch: ${user.branch}  •  Semester: Pass Out',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void onTap(int index) {
      setState(() {
        activeIndex = index;
      });
    }

    final user = ref.watch(userProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ref.watch(getUserDataProvider(user.uid)).when(
      loading: () => const Scaffold(body: Loader()),
      error: (error, _) {
        return Scaffold(
          body: NoInternetWidget(
            message: 'Unable to load your dashboard.\nPlease check your connection.',
            onRetry: () => ref.invalidate(getUserDataProvider(user.uid)),
          ),
        );
      },
      data: (hydratedUser) {
        if (_isPassOutStudent(hydratedUser)) {
          return _buildPassOutDashboard(context, hydratedUser);
        }

        final isAdmin = hydratedUser.role == 'admin';
        final constants = Constants(hydratedUser);

        return Scaffold(
          appBar: _buildAppBar(context, hydratedUser),
          body: constants.pages[activeIndex],
          floatingActionButton:
              !isAdmin
                  ? null
                  : FloatingActionButton(
                    backgroundColor: AppTheme.light.cardColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                    ),
                    elevation: 6,
                    child: Icon(Icons.add, color: AppTheme.light.iconTheme.color),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddFeedbackScreen(),
                        ),
                      );
                    },
                  ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: AnimatedBottomNavigationBar(
            icons: constants.icons,
            activeIndex: activeIndex,
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.softEdge,
            leftCornerRadius: 28,
            rightCornerRadius: 28,
            backgroundColor: AppTheme.light.scaffoldBackgroundColor,
            activeColor: AppTheme.light.colorScheme.primary,
            inactiveColor: AppTheme.light.hintColor.withAlpha(
              (0.4 * 255).toInt(),
            ),
            splashColor: AppTheme.light.colorScheme.primary.withAlpha(
              (0.3 * 255).toInt(),
            ),
            elevation: 12,
            iconSize: 26,
            onTap: onTap,
            shadow: const BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              spreadRadius: 1,
              offset: Offset(0, -2),
            ),
          ),
        );
      },
    );
  }
}
