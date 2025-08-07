import 'package:facultyfeed/core/models/user_model.dart';
import 'package:facultyfeed/features/admin/screens/admin_screen.dart';
import 'package:facultyfeed/features/admin/screens/stats_screen.dart';
import 'package:facultyfeed/features/auth/controller/auth_controller.dart';
import 'package:facultyfeed/features/dashboard/screens/dashboard_screen.dart';
import 'package:facultyfeed/features/dashboard/screens/feed_screen.dart';
import 'package:facultyfeed/features/student/screens/student_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Constants {
  final List<IconData> icons = [Icons.home, Icons.person];
  late final List<Widget> pages;

  Constants(UserModel user) {
    pages = [
      FeedScreen(),
      user.role == 'admin' ? AdminProfileScreen() : StudentProfileScreen(),
    ];
  }

  static const String userImage = "assets/images/user-icon.png";
}
