import 'package:flutter/material.dart';

void showTaskMessage(BuildContext context, String text) {
  final completed = text == 'Task completed! Great job!';
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        text,
        textAlign: completed ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          color: Colors.white,
          fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: completed
          ? const Color(0xff10b981)
          : const Color(0xff334155),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(completed ? 32 : 12),
      ),
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      duration: const Duration(seconds: 3),
      elevation: 6,
    ),
  );
}
