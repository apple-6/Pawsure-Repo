import 'package:flutter/material.dart';
import '../../models/sitter.dart';

class SitterCard extends StatelessWidget {
  final Sitter sitter;
  final VoidCallback? onTap;

  const SitterCard({super.key, required this.sitter, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: sitter.avatarUrl != null
              ? NetworkImage(sitter.avatarUrl!)
              : null,
          child: sitter.avatarUrl == null
              ? Text(sitter.name.isNotEmpty ? sitter.name[0] : '?')
              : null,
        ),
        title: Text(sitter.name),
        subtitle: Row(
          children: [
            const Icon(Icons.star, size: 14, color: Colors.amber),
            const SizedBox(width: 4),
            Text(sitter.rating.toStringAsFixed(1)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
