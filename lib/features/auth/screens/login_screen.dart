import 'dart:ui';

import 'package:facultyfeed/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    await ref
        .read(authControllerProvider)
        .signInWithEmailAndPassword(
          email: email,
          password: password,
          context: context,
        );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  PreferredSizeWidget fancyAppBar(ThemeData theme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AppBar(
            title: Text(
              'Faculty Feedback',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white.withOpacity(0.5),
            elevation: 10,
            shadowColor: Colors.black.withOpacity(0.1),
            surfaceTintColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: fancyAppBar(theme),
      // Gradient background for a fresh look
      body: Stack(
        children: [
          // Container(
          //   decoration: const BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
          //       begin: Alignment.topCenter,
          //       end: Alignment.bottomCenter,
          //     ),
          //   ),
          // ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // const SizedBox(height: 48),
                    // Optional logo / illustration
                    // const FlutterLogo(size: 80),
                    const SizedBox(height: 24),
                    Text(
                      'Login',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Login Card – clean, solid white with rounded corners
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) => val != null && val.contains('@')
                                  ? null
                                  : 'Enter a valid email',
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                              obscureText: true,
                              validator: (val) => val != null && val.isNotEmpty
                                  ? null
                                  : 'Enter your roll number',
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(fontSize: 18),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text('Login'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Forgot password hint (non‑clickable for now)
                            // TextButton(
                            //   onPressed: null,
                            //   style: TextButton.styleFrom(
                            //     foregroundColor: theme.colorScheme.primary.withOpacity(0.7),
                            //     textStyle: const TextStyle(decoration: TextDecoration.underline),
                            //   ),
                            //   child: const Text('Forgot password?'),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Non‑clickable instruction container
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Students: login with your college email ID and use your roll number as the password.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Footer note
                    Text(
                      '© 2026 Faculty Feedback',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
