import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  void showSnackBar(String message, {Color color = Colors.blue}) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
