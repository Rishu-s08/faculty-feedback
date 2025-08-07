import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facultyfeed/core/models/user_model.dart';
import 'package:facultyfeed/features/auth/controller/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  // final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? studentData;
  late UserModel user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    try {
      user = ref.read(userProvider)!;

      setState(() => isLoading = false);
    } catch (e) {
      print('Error fetching student data: $e');
      setState(() => isLoading = false);
    }
  }

  void logout() async {
    ref.read(authControllerProvider).signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "👤 Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Name: ${user.name}"),
                    Text("Email: ${user.email}"),
                    Text("Semester: ${user.semester}"),
                    Text("Branch: ${user.branch}"),
                    const SizedBox(height: 20),
                    const Divider(),

                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
