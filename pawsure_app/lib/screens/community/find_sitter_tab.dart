// lib/screens/community/find_sitter_tab.dart

import 'package:flutter/material.dart';
// Removed 'package:lucide_icons/lucide_icons.dart';
// Removed 'package:intl/intl.dart';

class FindSitterTab extends StatefulWidget {
  final Function(String sitterId) onSitterClick;

  const FindSitterTab({super.key, required this.onSitterClick});

  @override
  State<FindSitterTab> createState() => _FindSitterTabState();
}

class _FindSitterTabState extends State<FindSitterTab> {
  String selectedLocation = 'Johor Bahru';
  DateTime? selectedDate;
  List<Sitter> availableSitters = [];
  bool isLoading = false;

  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationController.text = selectedLocation;
    _fetchAndFilterSitters();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndFilterSitters() async {
    setState(() {
      isLoading = true;
    });

    // 1. Use the local mock data (No external dependency)
    List<Sitter> allSitters = mockSitters;

    // 2. Filter by Location
    List<Sitter> locationFilteredSitters = allSitters.where((sitter) {
      final search = selectedLocation.toLowerCase();
      if (search.isEmpty || search == 'johor bahru') {
        return true;
      }
      return sitter.location.toLowerCase().contains(search);
    }).toList();

    // 3. Filter by Available Dates
    List<Sitter> finalFilteredList = locationFilteredSitters.where((sitter) {
      if (selectedDate == null) return true;
      return !sitter.unavailableDates.any((unavailableDate) {
        return unavailableDate.year == selectedDate!.year &&
            unavailableDate.month == selectedDate!.month &&
            unavailableDate.day == selectedDate!.day;
      });
    }).toList();

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        availableSitters = finalFilteredList;
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final pickedDateOnly = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        selectedDate = pickedDateOnly;
      });
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
          _SearchBarsRow(
            locationController: _locationController,
            selectedDate: selectedDate,
            onSearch: () {
              selectedLocation = _locationController.text;
              _fetchAndFilterSitters();
            },
            onDateTap: () => _selectDate(context),
          ),
          const SizedBox(height: 16),
          const _MapViewPlaceholder(),
          const SizedBox(height: 24),
          Text(
            'Available Sitters (${availableSitters.length})',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
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
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: locationController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
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
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: onDateTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: selectedDate != null
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  width: selectedDate != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 20,
                    color: selectedDate != null
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateText,
                    style: TextStyle(
                      color: selectedDate != null
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onSearch,
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
        border: Border.all(color: Colors.grey.shade300),
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
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                errorBuilder: (context, error, stackTrace) => Container(
                  width: MediaQuery.of(context).size.width * 0.4 - 16,
                  height: 120,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),
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
                    Text(
                      'RM${sitter.price.toStringAsFixed(0)}/night',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
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

// -----------------------------------------------------------------------------
// DATA MODELS & MOCK DATA (Added here to prevent crashes)
// -----------------------------------------------------------------------------

class Sitter {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final String services;
  final double price;
  final String imageUrl;
  final String location;
  final List<DateTime> unavailableDates;

  Sitter({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.services,
    required this.price,
    required this.imageUrl,
    required this.location,
    required this.unavailableDates,
  });
}

final List<Sitter> mockSitters = [
  Sitter(
    id: '1',
    name: 'Sarah Jenkins',
    rating: 4.9,
    reviewCount: 124,
    services: 'Boarding, House Sitting',
    price: 45,
    imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80',
    location: 'Johor Bahru, Johor',
    unavailableDates: [
      DateTime.now().add(const Duration(days: 2)),
      DateTime.now().add(const Duration(days: 3)),
    ],
  ),
  Sitter(
    id: '2',
    name: 'Mike Ross',
    rating: 4.7,
    reviewCount: 89,
    services: 'Dog Walking, Drop-in',
    price: 30,
    imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
    location: 'Skudai, Johor',
    unavailableDates: [],
  ),
  Sitter(
    id: '3',
    name: 'Jessica Pearson',
    rating: 5.0,
    reviewCount: 210,
    services: 'Boarding, Grooming',
    price: 60,
    imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
    location: 'Johor Bahru, Johor',
    unavailableDates: [DateTime.now().add(const Duration(days: 5))],
  ),
];
