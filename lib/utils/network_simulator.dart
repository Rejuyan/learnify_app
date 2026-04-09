import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NetworkSimulator {
  /// Shows a loading overlay, waits for [milliseconds], then dismisses the overlay.
  static Future<void> delay(BuildContext context, {int milliseconds = 800}) async {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: const CircularProgressIndicator(
            color: AppTheme.primaryPurple,
            strokeWidth: 3,
          ),
        ),
      ),
    );
    await Future.delayed(Duration(milliseconds: milliseconds));
    if (context.mounted) {
      Navigator.pop(context); // Pop the dialog
    }
  }
}
