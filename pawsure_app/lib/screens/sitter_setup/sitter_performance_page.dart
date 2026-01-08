import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class SitterPerformancePage extends StatefulWidget {
  const SitterPerformancePage({super.key});

  @override
  State<SitterPerformancePage> createState() => _SitterPerformancePageState();
}

class _SitterPerformancePageState extends State<SitterPerformancePage> {
  bool isLoading = true;
  List<Map<String, dynamic>> allBookings = [];
  List<Map<String, dynamic>> filteredBookings = [];

  // --- FILTERS STATE ---
  String selectedService = 'All Services';
  String filterType = 'Monthly';
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedWeekRange;
  bool showAllHistory = true; // Default: Show all history on load

  final List<String> serviceTypes = [
    'All Services',
    'Pet Boarding',
    'Dog Walking',
    'Pet Sitting',
    'Pet Taxi',
    'Pet Daycare',
  ];

  final List<String> filterOptions = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _resetDateRanges();
    _fetchBookingHistory();
  }

  void _resetDateRanges() {
    DateTime now = DateTime.now();
    selectedDate = now;
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    selectedWeekRange = DateTimeRange(start: startOfWeek, end: endOfWeek);
  }

  Future<void> _fetchBookingHistory() async {
    try {
      final apiService = Get.find<ApiService>();
      final bookings = await apiService.getSitterBookings();

      if (bookings.isNotEmpty) {
        print("API Booking Data: ${bookings.first}");
      }

      // 👇 FORCE MOCK DATA FOR TESTING
      setState(() {
        allBookings = _getMockData();
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching bookings: $e");
      setState(() {
        allBookings = _getMockData();
        _applyFilters();
        isLoading = false;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      selectedService = 'All Services';
      filterType = 'Monthly';
      showAllHistory = true;
      _resetDateRanges();
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      filteredBookings = allBookings.where((booking) {
        // --- 1. Service Filter ---
        String bookingService =
            booking['serviceTypes'] ??
            booking['serviceType'] ??
            booking['service'] ??
            booking['type'] ??
            'Pet Care Service';

        bool serviceMatch =
            selectedService == 'All Services' ||
            bookingService == selectedService;

        // 👇 FIXED: If showing all history, skip date filtering
        if (showAllHistory) {
          return serviceMatch; // Only apply service filter
        }

        // --- 2. Date Filter (only when NOT showing all history) ---
        if (booking['startDate'] == null) return false;
        DateTime bookingDate;
        try {
          bookingDate = DateTime.parse(booking['startDate'].toString());
        } catch (e) {
          return false;
        }

        bool dateMatch = false;

        if (filterType == 'Daily') {
          dateMatch = isSameDay(bookingDate, selectedDate);
        } else if (filterType == 'Weekly') {
          if (selectedWeekRange != null) {
            DateTime dateOnly = DateTime(
              bookingDate.year,
              bookingDate.month,
              bookingDate.day,
            );
            DateTime start = DateTime(
              selectedWeekRange!.start.year,
              selectedWeekRange!.start.month,
              selectedWeekRange!.start.day,
            );
            DateTime end = DateTime(
              selectedWeekRange!.end.year,
              selectedWeekRange!.end.month,
              selectedWeekRange!.end.day,
            );

            // 👇 Simplified date range check
            dateMatch =
                (dateOnly.isAfter(start.subtract(const Duration(days: 1))) &&
                dateOnly.isBefore(end.add(const Duration(days: 1))));
          }
        } else if (filterType == 'Monthly') {
          dateMatch =
              bookingDate.year == selectedDate.year &&
              bookingDate.month == selectedDate.month;
        }

        return serviceMatch && dateMatch;
      }).toList();
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _pickDate() async {
    // If showing all history, turn it off when user opens calendar
    if (showAllHistory) {
      // Just visually open the calendar, selection logic handles the rest
    }

    if (filterType == 'Monthly') {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Select Month",
              style: TextStyle(
                color: Color(0xFF2ECA6A),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: 320,
              height: 300,
              child: _MonthPicker(
                initialDate: selectedDate,
                onSelected: (date) {
                  setState(() {
                    selectedDate = date;
                    showAllHistory = false;
                  });
                  _applyFilters();
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(10),
            title: Text(
              filterType == 'Weekly' ? "Select Week" : "Select Date",
              style: const TextStyle(
                color: Color(0xFF2ECA6A),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: 320,
              height: filterType == 'Weekly'
                  ? 440
                  : 380, // 👈 Add extra height for weekly mode
              child: Column(
                children: [
                  Expanded(
                    child: _CustomCalendarPicker(
                      initialDate: selectedDate,
                      mode: filterType,
                      selectedRange: selectedWeekRange,
                      onDateSelected: (date) {
                        setState(() {
                          selectedDate = date;
                          showAllHistory = false;
                        });
                        _applyFilters();
                        Navigator.pop(context); // Only for Daily mode
                      },
                      onRangeSelected: (range) {
                        setState(() {
                          selectedWeekRange = range;
                          showAllHistory = false;
                        });
                        _applyFilters();
                        // Don't close dialog - let user confirm
                      },
                    ),
                  ),
                  // 👇 Add Confirm button only for Weekly mode
                  if (filterType == 'Weekly') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ECA6A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Confirm Selection",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }
  }

  String _getDateButtonText() {
    if (showAllHistory) return "All Dates";

    if (filterType == 'Daily') {
      return DateFormat('d MMM yyyy').format(selectedDate);
    } else if (filterType == 'Weekly') {
      if (selectedWeekRange == null) return "Select Range";
      return "${DateFormat('d MMM').format(selectedWeekRange!.start)} - ${DateFormat('d MMM').format(selectedWeekRange!.end)}";
    } else {
      return DateFormat('MMMM yyyy').format(selectedDate);
    }
  }

  double _calculateTotalEarnings() {
    double total = 0;
    for (var b in filteredBookings) {
      if (b['totalPrice'] != null) {
        total += num.tryParse(b['totalPrice'].toString())?.toDouble() ?? 0.0;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF2ECA6A);
    const bgColor = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: bgColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: brandColor))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 50,
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        color: brandColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                const Text(
                                  "My Performance",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Text(
                                "Track your success and achievements",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                label: "Total Jobs",
                                value: "${filteredBookings.length}",
                                icon: Icons.check_circle_outline,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildSummaryCard(
                                label: "Earnings",
                                value:
                                    "RM ${_calculateTotalEarnings().toStringAsFixed(0)}",
                                icon: Icons.monetization_on_outlined,
                                color: brandColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyFilterDelegate(
                    height: 170,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 20,
                                    color: Colors.black87,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Booking History",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: _resetFilters,
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                label: const Text(
                                  "Clear Filter",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildDropdown(filterType, filterOptions, (
                                  val,
                                ) {
                                  setState(() {
                                    filterType = val!;
                                    // Keep current showAllHistory state until they pick a date
                                  });
                                }, icon: Icons.tune,
                                isFiltered: !showAllHistory,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: InkWell(
                                  onTap: _pickDate,
                                  child: Container(
                                    height: 45,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: showAllHistory
                                          ? Colors.grey.shade100
                                          : brandColor.withOpacity(0.1),
                                      border: Border.all(
                                        color: showAllHistory
                                            ? Colors.grey.shade300
                                            : brandColor,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          size: 18,
                                          color: showAllHistory
                                              ? Colors.grey
                                              : brandColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _getDateButtonText(),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: showAllHistory
                                                  ? Colors.grey
                                                  : brandColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildDropdown(
                            selectedService,
                            serviceTypes,
                            (val) {
                              setState(() => selectedService = val!);
                              _applyFilters();
                            },
                            icon: Icons.keyboard_arrow_down,
                            isFiltered: selectedService != 'All Services',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                filteredBookings.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState())
                    : SliverPadding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: 50,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final booking = filteredBookings[index];
                            return _buildBookingCard(booking, brandColor);
                          }, childCount: filteredBookings.length),
                        ),
                      ),
              ],
            ),
    );
  }

  // --- WIDGET HELPER METHODS ---
  Widget _buildDropdown(
    String value,
    List<String> items,
    Function(String?) onChanged, {
    IconData? icon,
    bool isFiltered = false, // 👈 Add parameter to indicate if filtered
  }) {
    const brandColor = Color(0xFF2ECA6A); // 👈 Define brandColor here
    
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isFiltered
            ? brandColor.withOpacity(0.1) // 👈 Green background when filtered
            : Colors.grey.shade50,
        border: Border.all(
          color: isFiltered
              ? brandColor // 👈 Green border when filtered
              : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, // 👈 Use the passed value parameter
          isExpanded: true,
          icon: Icon(
            icon ?? Icons.arrow_drop_down, // 👈 Use the passed icon parameter
            size: 18,
            color: isFiltered
                ? brandColor // 👈 Green icon when filtered
                : Colors.black87,
          ),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isFiltered
                ? brandColor // 👈 Green text when filtered
                : Colors.black87,
          ),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(
                val,
                style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black87, fontSize: 13,),
              ),
            );
          }).toList(),
          onChanged: onChanged, // 👈 Use the passed onChanged parameter
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, Color brandColor) {
    // 1. Safe Date Parsing
    DateTime date;
    try {
      if (booking['startDate'] != null) {
        date = DateTime.parse(booking['startDate'].toString());
      } else {
        date = DateTime.now();
      }
    } catch (e) {
      date = DateTime.now();
    }
    String formattedDate = DateFormat('d MMM yyyy').format(date);

    // 2. Safe Field Access (Checks multiple common keys)
    final serviceName =
        booking['serviceTypes'] ??
        booking['serviceType'] ??
        booking['service'] ??
        booking['type'] ??
        'Pet Care Service';
    final petName = booking['petName']?.toString() ?? 'Unknown Pet';
    final price = booking['totalPrice']?.toString() ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getServiceIcon(serviceName.toString()),
              color: brandColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Pet: $petName • $formattedDate",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "RM $price",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "Completed",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No bookings found",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String? type) {
    if (type == null) return Icons.pets;
    if (type.contains("Walking")) return Icons.directions_walk;
    if (type.contains("Taxi")) return Icons.local_taxi;
    if (type.contains("Daycare")) return Icons.wb_sunny;
    if (type.contains("Sitting")) return Icons.chair;
    return Icons.home;
  }

  List<Map<String, dynamic>> _getMockData() {
    return [
      {
        "id": 1,
        "serviceTypes": "Dog Walking",
        "startDate": "2026-01-02T10:00:00Z",
        "petName": "Buddy",
        "totalPrice": 50,
        "status": "completed",
      },
      {
        "id": 2,
        "serviceTypes": "Pet Boarding",
        "startDate": "2026-01-05T10:00:00Z",
        "petName": "Luna",
        "totalPrice": 120,
        "status": "completed",
      },
      {
        "id": 3,
        "serviceTypes": "Pet Sitting",
        "startDate": "2025-12-25T14:00:00Z",
        "petName": "Milo",
        "totalPrice": 60,
        "status": "completed",
      },
    ];
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyFilterDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(_StickyFilterDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

// --- 🌟 UNIFIED CALENDAR PICKER (DAILY & WEEKLY) ---
class _CustomCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  final String mode;
  final DateTimeRange? selectedRange;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTimeRange>? onRangeSelected;

  const _CustomCalendarPicker({
    required this.initialDate,
    required this.mode,
    required this.onDateSelected,
    this.selectedRange,
    this.onRangeSelected,
  });

  @override
  State<_CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<_CustomCalendarPicker> {
  late DateTime _currentMonth;
  DateTime? _tempStartDate;
  DateTime? _tempEndDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);

    if (widget.mode == 'Weekly' && widget.selectedRange != null) {
      _tempStartDate = widget.selectedRange!.start;
      _tempEndDate = widget.selectedRange!.end;
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF2ECA6A);

    final int daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final int firstWeekday = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    ).weekday;
    final int emptySlots = firstWeekday - 1;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(
                () => _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month - 1,
                ),
              ),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_currentMonth),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(
                () => _currentMonth = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                ),
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map(
                (d) => SizedBox(
                  width: 35,
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),

        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            itemCount: daysInMonth + emptySlots,
            itemBuilder: (context, index) {
              if (index < emptySlots) return const SizedBox();

              final day = index - emptySlots + 1;
              final date = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                day,
              );

              bool isStartDate = false;
              bool isEndDate = false;
              bool isInRange = false;

              if (widget.mode == 'Daily') {
                isStartDate = _isSameDay(date, widget.initialDate);
              } else if (widget.mode == 'Weekly') {
                // 👇 Check against temporary selection
                if (_tempStartDate != null) {
                  isStartDate = _isSameDay(date, _tempStartDate!);
                }
                if (_tempEndDate != null) {
                  isEndDate = _isSameDay(date, _tempEndDate!);
                }

                // 👇 Highlight dates in between
                if (_tempStartDate != null && _tempEndDate != null) {
                  final start = DateTime(
                    _tempStartDate!.year,
                    _tempStartDate!.month,
                    _tempStartDate!.day,
                  );
                  final end = DateTime(
                    _tempEndDate!.year,
                    _tempEndDate!.month,
                    _tempEndDate!.day,
                  );
                  final current = DateTime(date.year, date.month, date.day);

                  isInRange =
                      (current.isAfter(
                        start.subtract(const Duration(days: 1)),
                      ) &&
                      current.isBefore(end.add(const Duration(days: 1))));
                }
              }

              return InkWell(
                onTap: () {
                  if (widget.mode == 'Daily') {
                    widget.onDateSelected(date);
                  } else {
                    // 👇 MANUAL RANGE SELECTION LOGIC
                    setState(() {
                      if (_tempStartDate == null ||
                          (_tempStartDate != null && _tempEndDate != null)) {
                        // Start new selection
                        _tempStartDate = date;
                        _tempEndDate = null;
                      } else if (_tempStartDate != null &&
                          _tempEndDate == null) {
                        // Set end date
                        if (date.isBefore(_tempStartDate!)) {
                          // If end date is before start, swap them
                          _tempEndDate = _tempStartDate;
                          _tempStartDate = date;
                        } else {
                          _tempEndDate = date;
                        }

                        // Notify parent with the complete range
                        if (widget.onRangeSelected != null) {
                          widget.onRangeSelected!(
                            DateTimeRange(
                              start: _tempStartDate!,
                              end: _tempEndDate!,
                            ),
                          );
                        }
                      }
                    });
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (isStartDate || isEndDate)
                        ? brandColor
                        : (isInRange
                              ? brandColor.withOpacity(0.3)
                              : Colors.transparent),
                    borderRadius: BorderRadius.circular(
                      (isStartDate || isEndDate) ? 30 : 8,
                    ),
                  ),
                  child: Text(
                    "$day",
                    style: TextStyle(
                      color: (isStartDate || isEndDate)
                          ? Colors.white
                          : (isInRange ? brandColor : Colors.black87),
                      fontWeight: (isStartDate || isEndDate || isInRange)
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MonthPicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onSelected;

  const _MonthPicker({required this.initialDate, required this.onSelected});

  @override
  State<_MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => _selectedYear--),
            ),
            Text(
              "$_selectedYear",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => _selectedYear++),
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final monthDate = DateTime(_selectedYear, index + 1);
              final isSelected =
                  _selectedYear == widget.initialDate.year &&
                  (index + 1) == widget.initialDate.month;
              return InkWell(
                onTap: () => widget.onSelected(monthDate),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2ECA6A)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('MMM').format(monthDate),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
