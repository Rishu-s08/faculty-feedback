import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:facultyfeed/core/constants.dart';
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
  @override
  Widget build(BuildContext context) {
    void onTap(int index) {
      setState(() {
        activeIndex = index;
      });
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title:
            activeIndex == 0
                ? const Text('Dashboard')
                : const Text('User Profile'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authControllerProvider).signOut(context);
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Constants(ref).pages[activeIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.light.cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        elevation: 6,
        child: Icon(Icons.add, color: AppTheme.light.iconTheme.color),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddFeedbackScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: Constants(ref).icons,
        activeIndex: activeIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 28,
        rightCornerRadius: 28,
        backgroundColor: AppTheme.light.scaffoldBackgroundColor,
        activeColor: AppTheme.light.iconTheme.color,
        inactiveColor: AppTheme.light.hintColor.withAlpha((0.4 * 255).toInt()),
        splashColor: AppTheme.light.colorScheme.primary.withAlpha(
          (0.3 * 255).toInt(),
        ),
        elevation: 12,
        iconSize: 26,
        onTap: onTap,
        shadow: BoxShadow(
          color: Colors.black12,
          blurRadius: 12,
          spreadRadius: 1,
          offset: const Offset(0, -2),
        ),
      ),
    );
  }
}
