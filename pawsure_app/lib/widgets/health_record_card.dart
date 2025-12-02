//pawsure_app\lib\widgets\health_record_card.dart
import 'package:flutter/material.dart';
import 'package:pawsure_app/models/health_record_model.dart';

class HealthRecordCard extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback? onDelete;

  const HealthRecordCard({super.key, required this.record, this.onDelete});

  Color _getRecordTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'vaccination':
        return Colors.blue;
      case 'checkup':
        return Colors.green;
      case 'medication':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.recordType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getRecordTypeColor(record.recordType),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
