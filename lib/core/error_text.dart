import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String message;
  const ErrorText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(message, textAlign: TextAlign.center);
  }
}
