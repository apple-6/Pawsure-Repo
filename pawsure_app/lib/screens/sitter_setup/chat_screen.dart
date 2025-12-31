import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String ownerName;
  final String petName;
  final String dates;
  final bool isRequest;

  const ChatScreen({
    super.key,
    required this.ownerName,
    required this.petName,
    required this.dates,
    required this.isRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ownerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("$petName • $dates", style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Center(
        child: Text("Chat with $ownerName about $petName"),
      ),
    );
  }
}