// pawsure_app/lib/widgets/health/health_record_card.dart
import 'package:flutter/material.dart';
import 'package:pawsure_app/models/health_record_model.dart';

class HealthRecordCard extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback? onTap; // 🆕 Add onTap callback

  const HealthRecordCard({
    super.key,
    required this.record,
    this.onTap, // 🆕 Make it tappable
  });

  static Color _iconColorForType(String recordType) {
    switch (recordType) {
      case 'Vet Visit':
        return Colors.blue;
      case 'Vaccination':
        return Colors.green;
      case 'Medication':
        return Colors.red;
      case 'Allergy':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static IconData _iconDataForType(String recordType) {
    switch (recordType) {
      case 'Vet Visit':
        return Icons.medical_services_outlined;
      case 'Vaccination':
        return Icons.health_and_safety_outlined;
      case 'Medication':
        return Icons.medication_outlined;
      case 'Allergy':
        return Icons.block_outlined;
      default:
        return Icons.notes_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconColor = _iconColorForType(record.recordType);
    final iconData = _iconDataForType(record.recordType);

    List<Widget> subtitleChildren = [];

    if (record.clinic != null && record.clinic!.isNotEmpty) {
      subtitleChildren.add(
        Text('Clinic: ${record.clinic!}', style: textTheme.bodyMedium),
      );
    }

    if (record.description != null && record.description!.isNotEmpty) {
      subtitleChildren.add(
        Text(record.description!, style: textTheme.bodyMedium),
      );
    }

    if (record.nextDueDate != null) {
      subtitleChildren.add(
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Chip(
            label: Text(
              'Next due: ${record.nextDueDate!.day}/${record.nextDueDate!.month}/${record.nextDueDate!.year}',
            ),
            labelStyle: const TextStyle(fontSize: 12),
            backgroundColor: Colors.blue[50],
          ),
        ),
      );
    }

    // 🆕 Wrap with InkWell to make it tappable
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColor.withAlpha(26),
            child: Icon(iconData, color: iconColor),
          ),
          title: Text(
            record.recordType,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: subtitleChildren.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: subtitleChildren,
                )
              : null,
          trailing: Text(
            '${record.recordDate.day}/${record.recordDate.month}/${record.recordDate.year}',
            style: textTheme.labelMedium,
          ),
        ),
      ),
    );
  }
}
