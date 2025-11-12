import 'package:flutter/material.dart';
import '../../models/sitter.dart';
import '../../services/sitter_service.dart';
import '../../widgets/sitter/sitter_card.dart';

class SitterListScreen extends StatefulWidget {
  const SitterListScreen({super.key});

  @override
  State<SitterListScreen> createState() => _SitterListScreenState();
}

class _SitterListScreenState extends State<SitterListScreen> {
  late Future<List<Sitter>> _future;

  @override
  void initState() {
    super.initState();
    _future = SitterService.fetchSitters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Sitters')),
      body: FutureBuilder<List<Sitter>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final list = snapshot.data ?? <Sitter>[];
          if (list.isEmpty) {
            return const Center(child: Text('No sitters found'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final s = list[i];
              return SitterCard(
                sitter: s,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/sitter/dashboard',
                    arguments: s,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
