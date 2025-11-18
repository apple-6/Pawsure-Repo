import 'package:flutter/material.dart';

class FilterChipRow extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const FilterChipRow({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  static const List<String> _filters = [
    'All',
    'Vet Visit',
    'Vaccination',
    'Medication',
    'Allergy',
    'Note',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: _filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: selectedFilter == filter,
              onSelected: (isSelected) {
                if (isSelected) {
                  onFilterSelected(filter);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
