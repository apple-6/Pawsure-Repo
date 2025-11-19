// lib/screens/community/find_sitter_tab.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
// CORRECTED IMPORT PATH: Since sitter_model.dart is in the same directory,
// a simple relative import is used.
import 'sitter_model.dart';

class FindSitterTab extends StatefulWidget {
  final Function(String sitterId) onSitterClick;

  const FindSitterTab({super.key, required this.onSitterClick});

  @override
  State<FindSitterTab> createState() => _FindSitterTabState();
}

class _FindSitterTabState extends State<FindSitterTab> {
  // State variables for search
  String selectedLocation = 'Johor Bahru';
  DateTime? selectedDate;
  List<Sitter> availableSitters = [];
  bool isLoading = false;

  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationController.text = selectedLocation;
    // Load all sitters on initial build
    _fetchAndFilterSitters();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  // --- CORE FILTERING LOGIC ---
  Future<void> _fetchAndFilterSitters() async {
    setState(() {
      isLoading = true;
    });

    // 1. Fetch all sitters (Simulated)
    List<Sitter> allSitters = mockSitters;

    // 2. Filter by Location/City/State
    List<Sitter> locationFilteredSitters = allSitters.where((sitter) {
      final search = selectedLocation.toLowerCase();

      // If search is empty or default ('Johor Bahru'), skip location filter
      if (search.isEmpty || search == 'johor bahru') {
        return true;
      }

      // Check if the sitter's location (address) contains the search term
      return sitter.location.toLowerCase().contains(search);
    }).toList();

    // 3. Filter by Available Dates (Uses the new unavailableDates field)
    List<Sitter> finalFilteredList = locationFilteredSitters.where((sitter) {
      // If NO date is selected, all sitters pass the date filter.
      if (selectedDate == null) return true;

      // Check if the selected date (date-only) is in the sitter's unavailable list.
      // We must compare the year, month, and day components only.
      return !sitter.unavailableDates.any((unavailableDate) {
        return unavailableDate.year == selectedDate!.year &&
            unavailableDate.month == selectedDate!.month &&
            unavailableDate.day == selectedDate!.day;
      });
    }).toList();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // 4. Update UI
    setState(() {
      availableSitters = finalFilteredList;
      isLoading = false;
    });
  }

  // --- DATE PICKER HANDLER ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      // Keep only the date part (no time components) for accurate comparison
      final pickedDateOnly = DateTime(picked.year, picked.month, picked.day);

      setState(() {
        selectedDate = pickedDateOnly;
      });
      // Automatically trigger search after a date is selected
      _fetchAndFilterSitters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar Row
          _SearchBarsRow(
            locationController: _locationController,
            selectedDate: selectedDate,
            onSearch: () {
              // Update location state from controller before searching
              selectedLocation = _locationController.text;
              _fetchAndFilterSitters();
            },
            onDateTap: () => _selectDate(context),
          ),
          const SizedBox(height: 16),

          // 2. Map View Placeholder
          const _MapViewPlaceholder(),
          const SizedBox(height: 24),

          // 3. Available Sitters Header
          Text(
            'Available Sitters (${availableSitters.length})',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 4. List of Sitters
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : availableSitters.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Text(
                      'No sitters found matching your criteria.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: availableSitters.map((sitter) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SitterCard(
                        sitter: sitter,
                        onClick: widget.onSitterClick,
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// -----------------------------------------------------------------------------

class _SearchBarsRow extends StatelessWidget {
  final TextEditingController locationController;
  final DateTime? selectedDate;
  final VoidCallback onSearch;
  final VoidCallback onDateTap;

  const _SearchBarsRow({
    required this.locationController,
    required this.selectedDate,
    required this.onSearch,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    String dateText = selectedDate != null
        ? DateFormat('dd MMM').format(selectedDate!)
        : 'Dates';

    return Row(
      children: [
        // Location Input (TextField)
        Expanded(
          child: _SitterLocationInput(
            controller: locationController,
            onSubmitted: onSearch,
          ),
        ),
        const SizedBox(width: 8),

        // Dates Input (InkWell to trigger date picker)
        Expanded(
          child: _SitterDateInput(
            text: dateText,
            onTap: onDateTap,
            isActive: selectedDate != null,
          ),
        ),
        const SizedBox(width: 8),

        // Search Button
        ElevatedButton(
          onPressed: onSearch, // Calls the filter function
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: const Icon(LucideIcons.search, color: Colors.white),
        ),
      ],
    );
  }
}

class _SitterLocationInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  const _SitterLocationInput({
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onSubmitted(),
        decoration: InputDecoration(
          prefixIcon: Icon(
            LucideIcons.mapPin,
            size: 20,
            color: Colors.grey.shade600,
          ),
          hintText: 'State/City',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          isDense: true,
        ),
        style: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SitterDateInput extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isActive;

  const _SitterDateInput({
    required this.text,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.calendar,
              size: 20,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapViewPlaceholder extends StatelessWidget {
  const _MapViewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.mapPin, size: 32, color: Colors.grey.shade500),
          const SizedBox(height: 8),
          Text(
            'Map view coming soon',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Will show sitter locations',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class SitterCard extends StatelessWidget {
  final Sitter sitter;
  final Function(String id) onClick;

  const SitterCard({super.key, required this.sitter, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onClick(sitter.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sitter Image (40% width)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.network(
                sitter.imageUrl,
                width: MediaQuery.of(context).size.width * 0.4 - 16,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            // Sitter Details (60% width)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sitter.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Rating
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sitter.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${sitter.reviewCount} reviews)',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Services
                    Text(
                      sitter.services,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Text.rich(
                      TextSpan(
                        text: 'RM${sitter.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        children: [
                          TextSpan(
                            text: '/night',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
