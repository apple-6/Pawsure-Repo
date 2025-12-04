import 'package:flutter/material.dart';

class SOSButton extends StatelessWidget {
  const SOSButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {}, // Future: Open Emergency Modal
      icon: Icon(Icons.warning_amber_rounded,
          color: Colors.red.shade600, size: 28),
      // style property isn't available on IconButton in older Flutter versions; using padding
      padding: const EdgeInsets.all(8),
      tooltip: 'Emergency',
    );
  }
}
