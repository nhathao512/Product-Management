import 'package:flutter/material.dart';

void showCustomSnackBar(
  BuildContext context,
  String message, {
  Color color = Colors.blue,
  IconData icon = Icons.info,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(message),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ),
  );
}
