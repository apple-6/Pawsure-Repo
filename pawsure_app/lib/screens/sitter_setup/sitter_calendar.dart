import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart'; // <--- Import GetX for navigation
import 'sitter_dashboard.dart';
import 'sitter_inbox.dart';
import 'sitter_setting_screen.dart';
// --- Data Models ---

enum DateStatus { available, booked, unavailable }

class BookingInfo {
  final String petName;
  final String ownerName;
  final int id;

  BookingInfo({
    required this.petName,
    required this.ownerName,
    required this.id,
  });
}

class DateInfo {
  final DateTime date;
  final DateStatus status;
  final BookingInfo? booking;

  DateInfo({required this.date, required this.status, this.booking});
}

// --- Main Widget ---

class SitterCalendar extends StatefulWidget {
  const SitterCalendar({super.key});

  @override
  State<SitterCalendar> createState() => _SitterCalendarState();
}

class _SitterCalendarState extends State<SitterCalendar> {
  // --- State Variables ---
  DateTime _currentDate = DateTime.now();
  bool _isEditMode = false;
  List<DateTime> _selectedDates = [];

  // 0 = Sunday, 1 = Monday, ... 6 = Saturday
  List<int> _recurringUnavailableDays = [];

  // Map Key: "yyyy-MM-dd"
  Map<String, DateInfo> _dateStatuses = {};

  final List<String> _daysOfWeek = [
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
  ];

  // Your App's Green Color
  final Color _accentColor = const Color(0xFF1CCA5B);

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    // Create sample data for the CURRENT month so you can see it immediately
    _dateStatuses = {
      // Bookings on 15th and 16th
      DateFormat('yyyy-MM-dd').format(DateTime(year, month, 15)): DateInfo(
        date: DateTime(year, month, 15),
        status: DateStatus.booked,
        booking: BookingInfo(petName: "Max", ownerName: "Bill", id: 1),
      ),
      DateFormat('yyyy-MM-dd').format(DateTime(year, month, 16)): DateInfo(
        date: DateTime(year, month, 16),
        status: DateStatus.booked,
        booking: BookingInfo(petName: "Max", ownerName: "Bill", id: 1),
      ),
      // Unavailable on 20th and 21st
      DateFormat('yyyy-MM-dd').format(DateTime(year, month, 20)): DateInfo(
        date: DateTime(year, month, 20),
        status: DateStatus.unavailable,
      ),
      DateFormat('yyyy-MM-dd').format(DateTime(year, month, 21)): DateInfo(
        date: DateTime(year, month, 21),
        status: DateStatus.unavailable,
      ),
    };
  }

  // --- Logic Helpers ---

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateInfo _getDateStatus(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);

    // 1. Check specific overrides (Manual settings/Bookings)
    if (_dateStatuses.containsKey(key)) {
      return _dateStatuses[key]!;
    }

    // 2. Check recurring unavailability
    // Dart weekday: 1=Mon...7=Sun. Convert to 0=Sun...6=Sat
    final dayIndex = date.weekday % 7;
    if (_recurringUnavailableDays.contains(dayIndex)) {
      return DateInfo(date: date, status: DateStatus.unavailable);
    }

    // 3. Default is available
    return DateInfo(date: date, status: DateStatus.available);
  }

  void _handleDateClick(DateTime date) {
    if (_isEditMode) {
      setState(() {
        if (_selectedDates.any((d) => _isSameDay(d, date))) {
          _selectedDates.removeWhere((d) => _isSameDay(d, date));
        } else {
          _selectedDates.add(date);
        }
      });
    } else {
      // View Mode
      final info = _getDateStatus(date);
      if (info.status == DateStatus.booked) {
        _showBookingDetailSheet(info);
      } else {
        _showDateActionSheet(date);
      }
    }
  }

  void _handleMarkDates(DateStatus status, {DateTime? singleDate}) {
    final datesToUpdate = _isEditMode
        ? _selectedDates
        : (singleDate != null ? [singleDate] : []);

    setState(() {
      for (var date in datesToUpdate) {
        final key = DateFormat('yyyy-MM-dd').format(date);
        _dateStatuses[key] = DateInfo(date: date, status: status);
      }

      if (_isEditMode) {
        _selectedDates = [];
        _isEditMode = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Marked ${datesToUpdate.length} date(s) as ${status.name}",
        ),
        backgroundColor: _accentColor,
        duration: const Duration(seconds: 1),
      ),
    );

    // Close bottom sheet if open (for single date mode)
    if (!_isEditMode && singleDate != null) Navigator.pop(context);
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentDate = DateTime(
        _currentDate.year,
        _currentDate.month + offset,
        1,
      );
    });
  }

  // --- UI Build ---

  @override
  Widget build(BuildContext context) {
    // Calendar Math
    final daysInMonth = DateTime(
      _currentDate.year,
      _currentDate.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final firstDayOffset = firstDayOfMonth.weekday % 7;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Availability',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildMonthControls(),
            _buildLegend(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildWeeklySettingsButton(),
                      const SizedBox(height: 20),
                      _buildCalendarGrid(
                        daysInMonth,
                        firstDayOffset,
                        firstDayOfMonth,
                      ),
                      const SizedBox(height: 100), // Spacing
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _accentColor,
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: 2, // <--- Highlight "Calendar" (Index 2)
        onTap: (index) {
          if (index == 0) {
            // Navigate back to Dashboard (clears stack so no back button loop)
            Get.offAll(() => const SitterDashboard());
          }
          if (index == 1) {
            // Navigate to Discover Screen
          }
          if (index == 2) {
            Get.to(() => const SitterCalendar());
          }
          if (index == 3) {
            Get.to(() => const SitterInbox());
          }
          if (index == 4) {
            Get.to(() => const SitterSettingScreen());
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today,
            ), // Filled version for active state if preferred
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Setting',
          ),
        ],
      ),
      // Action Bar for Bulk Edit
      bottomSheet: _isEditMode && _selectedDates.isNotEmpty
          ? Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleMarkDates(DateStatus.unavailable),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Unavailable",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleMarkDates(DateStatus.available),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Available",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  // --- Sub-Widgets ---

  Widget _buildMonthControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeMonth(-1),
              ),
              SizedBox(
                width: 140,
                child: Text(
                  DateFormat('MMMM yyyy').format(_currentDate),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          _isEditMode
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditMode = false;
                      _selectedDates = [];
                    });
                  },
                  child: Text(
                    "Done",
                    style: TextStyle(
                      color: _accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: () => setState(() => _isEditMode = true),
                  icon: const Icon(Icons.edit, size: 16, color: Colors.black),
                  label: const Text(
                    "Edit",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Colors.white, "Available", hasBorder: true),
          const SizedBox(width: 16),
          _legendItem(_accentColor, "Booked"),
          const SizedBox(width: 16),
          _legendItem(Colors.grey.shade300, "Unavailable"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, {bool hasBorder = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: hasBorder ? Border.all(color: Colors.grey.shade300) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildWeeklySettingsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showWeeklySettingsSheet,
        icon: const Icon(Icons.tune, size: 18, color: Colors.grey),
        label: const Text(
          "Set Weekly Availability",
          style: TextStyle(color: Colors.black87),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.grey.shade50,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(
    int daysInMonth,
    int firstDayOffset,
    DateTime firstDayOfMonth,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _daysOfWeek
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + firstDayOffset,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (index < firstDayOffset) return const SizedBox();

              final dayNumber = index - firstDayOffset + 1;
              final date = DateTime(
                firstDayOfMonth.year,
                firstDayOfMonth.month,
                dayNumber,
              );
              return _buildDayCell(date);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final statusInfo = _getDateStatus(date);
    final isSelected = _selectedDates.any((d) => _isSameDay(d, date));
    final isToday = _isSameDay(date, DateTime.now());

    Color bgColor = Colors.transparent;
    Color textColor = Colors.black87;
    BoxBorder? border;
    TextDecoration? textDeco;

    // Logic for cell styling
    if (isSelected) {
      bgColor = _accentColor.withOpacity(0.15);
      border = Border.all(color: _accentColor, width: 2);
      textColor = _accentColor;
    } else if (statusInfo.status == DateStatus.booked) {
      bgColor = _accentColor;
      textColor = Colors.white;
    } else if (statusInfo.status == DateStatus.unavailable) {
      bgColor = Colors.grey.shade200;
      textColor = Colors.grey.shade400;
      textDeco = TextDecoration.lineThrough;
    }

    if (isToday && !isSelected && statusInfo.status != DateStatus.booked) {
      border = Border.all(color: _accentColor, width: 1);
    }

    return GestureDetector(
      onTap: () => _handleDateClick(date),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            decoration: textDeco,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // --- Bottom Sheets ---

  void _showDateActionSheet(DateTime date) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(date),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Set availability for this day",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => _handleMarkDates(
                    DateStatus.unavailable,
                    singleDate: date,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Mark as Unavailable",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      _handleMarkDates(DateStatus.available, singleDate: date),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Mark as Available",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBookingDetailSheet(DateInfo info) {
    if (info.booking == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Booking Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.pets,
                          size: 28,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.booking!.petName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Owned by ${info.booking!.ownerName}",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWeeklySettingsSheet() {
    // Create a copy so we can cancel without saving
    List<int> tempRecurring = List.from(_recurringUnavailableDays);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Set Weekly Availability",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Select days you are always unavailable.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _daysOfWeek.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 12),
                        itemBuilder: (c, index) {
                          final isChecked = tempRecurring.contains(index);
                          return InkWell(
                            onTap: () {
                              setSheetState(() {
                                if (isChecked) {
                                  tempRecurring.remove(index);
                                } else {
                                  tempRecurring.add(index);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? _accentColor.withOpacity(0.1)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isChecked
                                      ? _accentColor
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _daysOfWeek[index],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isChecked
                                          ? _accentColor
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (isChecked)
                                    Icon(
                                      Icons.check_circle,
                                      color: _accentColor,
                                      size: 20,
                                    )
                                  else
                                    Icon(
                                      Icons.circle_outlined,
                                      color: Colors.grey.shade400,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _recurringUnavailableDays = tempRecurring;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Weekly availability saved"),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save Settings",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
