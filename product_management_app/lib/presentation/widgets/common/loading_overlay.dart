import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;

  const LoadingOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (true) // Replace with actual loading state
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
