import 'package:facultyfeed/main.dart';
import 'package:flutter/material.dart';

void showPrettySnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final theme = Theme.of(context);

  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: isError ? Colors.redAccent : Colors.green,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.white,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 8,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  );

  scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
}
