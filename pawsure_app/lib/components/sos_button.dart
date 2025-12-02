import 'package:flutter/material.dart';

class SOSButton extends StatelessWidget {
  const SOSButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(Icons.warning_amber_rounded,
          color: Colors.red.shade600, size: 28),
      style: IconButton.styleFrom(
        backgroundColor: Colors.red.shade50,
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}
