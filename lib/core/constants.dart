import 'package:facultyfeed/core/models/user_model.dart';
import 'package:facultyfeed/features/admin/screens/admin_home_screen.dart';
import 'package:facultyfeed/features/admin/screens/admin_screen.dart';
import 'package:facultyfeed/features/dashboard/screens/feed_screen.dart';
import 'package:facultyfeed/features/student/screens/student_profile_screen.dart';
import 'package:flutter/material.dart';

class Constants {
  final List<IconData> icons = [Icons.home, Icons.person];
  late final List<Widget> pages;

  Constants(UserModel user) {
    pages = [
      user.role == 'admin' ? const AdminHomeScreen() : const FeedScreen(),
      user.role == 'admin' ? const AdminProfileScreen() : const StudentProfileScreen(),
    ];
  }

  static const String userImage = "assets/images/user-icon.png";

  /// Standard branch list used across the app.
  static const List<String> branches = ['CSE', 'IT', 'TT', 'TC', 'ME', 'ECE'];
}
