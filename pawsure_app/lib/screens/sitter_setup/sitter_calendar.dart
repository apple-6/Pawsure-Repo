import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sitter_dashboard.dart';
import 'sitter_inbox.dart';

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
  bool _isLoading = true;
  List<DateTime> _selectedDates = [];
  List<int> _recurringUnavailableDays = [];
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
  final Color _accentColor = const Color(0xFF1CCA5B);

  // --- Configuration (Update these to match your environment) ---
  final String _baseUrl =
      "http://your-api-url.com"; // e.g., http://10.0.2.2:3000 for Android Emulator
  final String _token =
      "YOUR_JWT_TOKEN"; // Get this from your Auth storage/GetX controller

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  // --- API Logic ---

  Future<void> _fetchAvailability() async {
    setState(() => _isLoading = true);
    try {
      // Endpoint to get the sitter's profile based on the JWT token
      final response = await http.get(
        Uri.parse('$_baseUrl/sitter/me'),
        headers: {"Authorization": "Bearer $_token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> dbDates = data['unavailable_dates'] ?? [];
        final List<dynamic> dbDays = data['unavailable_days'] ?? [];

        setState(() {
          _dateStatuses.clear();
          // 1. Specific Dates
          for (var dateStr in dbDates) {
            DateTime parsed = DateTime.parse(dateStr);
            _dateStatuses[dateStr] = DateInfo(
              date: parsed,
              status: DateStatus.unavailable,
            );
          }
          // 2. Weekly Recurring (Map "Mon" back to index 1)
          _recurringUnavailableDays = dbDays
              .map((dayName) => _daysOfWeek.indexOf(dayName))
              .where((index) => index != -1)
              .cast<int>()
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Fetch Error: $e");
    }
  }

  Future<void> _syncWithBackend() async {
    // Collect all dates manually marked as unavailable
    List<String> unavailableDates = _dateStatuses.entries
        .where((e) => e.value.status == DateStatus.unavailable)
        .map((e) => e.key)
        .toList();

    // Map weekly indices to Strings for the backend ["Sun", "Mon"]
    List<String> unavailableDays = _recurringUnavailableDays
        .map((index) => _daysOfWeek[index])
        .toList();

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/sitter/availability'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode({
          "unavailable_dates": unavailableDates,
          "unavailable_days": unavailableDays,
        }),
      );

      if (response.statusCode != 200) throw Exception();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cloud sync failed. Saved locally.")),
      );
    }
  }

  // --- Logic Helpers ---

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateInfo _getDateStatus(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    if (_dateStatuses.containsKey(key)) return _dateStatuses[key]!;
    final dayIndex = date.weekday % 7;
    if (_recurringUnavailableDays.contains(dayIndex)) {
      return DateInfo(date: date, status: DateStatus.unavailable);
    }
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
      final info = _getDateStatus(date);
      if (info.status == DateStatus.booked) {
        _showBookingDetailSheet(info);
      } else {
        _showDateActionSheet(date);
      }
    }
  }

  void _handleMarkDates(DateStatus status, {DateTime? singleDate}) async {
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

    if (!_isEditMode && singleDate != null) Navigator.pop(context);

    // Auto-sync after changes
    await _syncWithBackend();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Schedule updated"),
        backgroundColor: _accentColor,
        duration: const Duration(seconds: 1),
      ),
    );
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                            const SizedBox(height: 100),
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
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Get.offAll(() => const SitterDashboard());
          if (index == 3) Get.to(() => const SitterInbox());
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
            icon: Icon(Icons.calendar_today),
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
      bottomSheet: _isEditMode && _selectedDates.isNotEmpty
          ? _buildBulkEditBar()
          : null,
    );
  }

  // --- Helper Widgets ---

  Widget _buildBulkEditBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _handleMarkDates(DateStatus.unavailable),
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
              style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
              child: const Text(
                "Available",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                  onPressed: () => setState(() {
                    _isEditMode = false;
                    _selectedDates = [];
                  }),
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
              final date = DateTime(
                firstDayOfMonth.year,
                firstDayOfMonth.month,
                index - firstDayOffset + 1,
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

    Color bgColor = isSelected
        ? _accentColor.withOpacity(0.15)
        : (statusInfo.status == DateStatus.booked
              ? _accentColor
              : (statusInfo.status == DateStatus.unavailable
                    ? Colors.grey.shade200
                    : Colors.transparent));
    Color textColor = isSelected
        ? _accentColor
        : (statusInfo.status == DateStatus.booked
              ? Colors.white
              : (statusInfo.status == DateStatus.unavailable
                    ? Colors.grey.shade400
                    : Colors.black87));

    return GestureDetector(
      onTap: () => _handleDateClick(date),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isSelected || isToday
              ? Border.all(color: _accentColor, width: isSelected ? 2 : 1)
              : null,
        ),
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            decoration: statusInfo.status == DateStatus.unavailable
                ? TextDecoration.lineThrough
                : null,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // --- Sheets ---

  void _showDateActionSheet(DateTime date) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
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
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () =>
                    _handleMarkDates(DateStatus.unavailable, singleDate: date),
                child: const Text(
                  "Mark as Unavailable",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    _handleMarkDates(DateStatus.available, singleDate: date),
                style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
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
      ),
    );
  }

  void _showBookingDetailSheet(DateInfo info) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
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
              ListTile(
                tileColor: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.pets, color: Colors.orange),
                ),
                title: Text(
                  info.booking!.petName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Owned by ${info.booking!.ownerName}"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeeklySettingsSheet() {
    List<int> tempRecurring = List.from(_recurringUnavailableDays);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(24.0),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Set Weekly Availability",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _daysOfWeek.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final isChecked = tempRecurring.contains(index);
                    return InkWell(
                      onTap: () => setSheetState(
                        () => isChecked
                            ? tempRecurring.remove(index)
                            : tempRecurring.add(index),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Icon(
                              isChecked
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isChecked
                                  ? _accentColor
                                  : Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  setState(() => _recurringUnavailableDays = tempRecurring);
                  Navigator.pop(context);
                  await _syncWithBackend();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  minimumSize: const Size(double.infinity, 50),
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
            ],
          ),
        ),
      ),
    );
  }
}
