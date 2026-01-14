// lib/screens/community/find_sitter_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pawsure_app/screens/community/sitter_model.dart';
import 'package:pawsure_app/services/sitter_service.dart';

class FindSitterTab extends StatefulWidget {
  final Function(String sitterId, DateTime? start, DateTime? end) onSitterClick;

  const FindSitterTab({super.key, required this.onSitterClick});

  @override
  State<FindSitterTab> createState() => _FindSitterTabState();
}

class _FindSitterTabState extends State<FindSitterTab> {
  String selectedLocation = '';
  // --- UPDATED: Track both start and end dates ---
  DateTime? startDate;
  DateTime? endDate;
  // ------------------------------------------------

  List<Sitter> availableSitters = [];
  bool isLoading = false;
  String? errorMessage;

  final TextEditingController _locationController = TextEditingController();
  final SitterService _sitterService = SitterService();

  // ✅ ADDED: ScrollController to fix desktop crash
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _locationController.text = '';
    // Call the fetching method after initialization
    _fetchAndFilterSitters();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _sitterService.dispose();
    _scrollController.dispose(); // ✅ Dispose the controller
    super.dispose();
  }

  Future<void> _fetchAndFilterSitters() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // --- UPDATED: Check for a valid date range before calling the service ---
    if (startDate == null || endDate == null) {
      // If dates are not selected, fetch all sitters (or apply location filter only)
      try {
        final fetchedSitters = await _sitterService
            .fetchSitters(); // Assuming fetchSitters() without args gets all sitters
        final filteredSitters = _applyFilters(fetchedSitters);
        if (mounted) {
          setState(() {
            availableSitters = filteredSitters;
          });
        }
      } catch (e) {
        // Existing error handling with mock data fallback
        final fallbackSitters = _applyFilters(mockSitters);
        if (mounted) {
          setState(() {
            availableSitters = fallbackSitters;
            errorMessage =
                'Unable to load sitters from the server. Showing sample data instead.\n$e';
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
      return; // Exit here if dates are not fully selected
    }

    // Call the backend service with the date range
    try {
      // NOTE: Your SitterService needs to be updated to accept two dates.
      // We assume a new method or updated signature like:
      // fetchSitters(startDate: String, endDate: String)
      final fetchedSitters = await _sitterService.fetchSittersByRange(
        startDate: startDate!,
        endDate: endDate!,
      );
      // Backend handles availability filtering, so only location filter is applied here.
      final filteredSitters = _applyFilters(fetchedSitters);
      if (mounted) {
        setState(() {
          availableSitters = filteredSitters;
        });
      }
    } catch (e) {
      // Existing error handling with mock data fallback
      final fallbackSitters = _applyFilters(mockSitters);
      if (mounted) {
        setState(() {
          availableSitters = fallbackSitters;
          errorMessage =
              'Unable to load sitters from the server. Showing sample data instead.\n$e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<Sitter> _applyFilters(List<Sitter> sitters) {
    final search = selectedLocation.trim().toLowerCase();
    var filtered = sitters;

    // Filter by location
    if (search.isNotEmpty) {
      filtered = filtered
          .where((sitter) => sitter.location.toLowerCase().contains(search))
          .toList();
    }

    // --- Removed Client-Side Date Filtering ---
    // The availability filtering logic is now handled by the backend
    // using the unavailable_dates and unavailable_days array checks.

    return filtered;
  }

  // --- Removed _matchesSelectedDate and _isSameDay as they are no longer needed for client-side date filtering ---

  // --- UPDATED: Function to select the date range ---
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: (startDate != null && endDate != null)
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null, // Initial range is null if not set
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Start and End Dates',
      saveText: 'Apply',
    );

    if (picked != null) {
      // Use date-only versions to match the backend comparison (no time component)
      final start = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      );
      final end = DateTime(picked.end.year, picked.end.month, picked.end.day);

      if (mounted) {
        setState(() {
          startDate = start;
          endDate = end;
        });
        _fetchAndFilterSitters();
      }
    } else {
      // Option to clear the selected date range
      if (startDate != null || endDate != null) {
        if (mounted) {
          setState(() {
            startDate = null;
            endDate = null;
          });
          _fetchAndFilterSitters();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ WRAP in Scrollbar with controller
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController, // ✅ Attach controller to scroll view
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- UPDATED: Pass both dates to the helper widget ---
            _SearchBarsRow(
              locationController: _locationController,
              startDate: startDate,
              endDate: endDate,
              onSearch: () {
                selectedLocation = _locationController.text;
                _fetchAndFilterSitters();
              },
              onDateTap: () => _selectDateRange(context),
            ),
            // ----------------------------------------------------
            // REMOVED: const SizedBox(height: 16),
            // REMOVED: const _MapViewPlaceholder(),
            const SizedBox(
              height: 24,
            ), // Retained/Adjusted for spacing after search row
            Text(
              'Available Sitters (${availableSitters.length})',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
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
                          onClick: (id) {
                            widget.onSitterClick(id, startDate, endDate);
                          },
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// -----------------------------------------------------------------------------

class _SearchBarsRow extends StatelessWidget {
  final TextEditingController locationController;
  // --- UPDATED: Accept start and end dates ---
  final DateTime? startDate;
  final DateTime? endDate;
  // -------------------------------------------
  final VoidCallback onSearch;
  final VoidCallback onDateTap;

  const _SearchBarsRow({
    required this.locationController,
    // --- UPDATED: Require start and end dates ---
    required this.startDate,
    required this.endDate,
    // --------------------------------------------
    required this.onSearch,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- UPDATED: Logic to display the date range ---
    String dateText;
    if (startDate != null && endDate != null) {
      final startFmt = DateFormat('dd MMM').format(startDate!);
      final endFmt = DateFormat('dd MMM').format(endDate!);
      dateText = '$startFmt - $endFmt';
    } else {
      dateText = 'Dates';
    }
    // ------------------------------------------------

    final isDateSelected = startDate != null && endDate != null;

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
                hintText: 'City',
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
                  color: isDateSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  width: isDateSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 20,
                    color: isDateSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  // --- UPDATED: Display the range text ---
                  Expanded(
                    // Use Expanded to ensure long date range text fits
                    child: Text(
                      dateText,
                      style: TextStyle(
                        color: isDateSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow:
                          TextOverflow.ellipsis, // Add ellipsis for overflow
                    ),
                  ),
                  // ---------------------------------------
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

// REMOVED: class _MapViewPlaceholder

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
              // Using withValues as requested previously
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
            // --- Sitter Image ---
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

            // --- Content ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Name
                    Text(
                      sitter.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 2. Rating & Reviews Row
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

                    // 3. Experience (MOVED HERE - Below Rating)
                    Text(
                      '${sitter.yearsExperience} Years Experience',
                      style: const TextStyle(
                        color: Color(0xFF059669), // Green color
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // 4. Services
                    Text(
                      sitter.services.isEmpty
                          ? 'No services listed'
                          : sitter.services.replaceAll(', ', ' • '),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
