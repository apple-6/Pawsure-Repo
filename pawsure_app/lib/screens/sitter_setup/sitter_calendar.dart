import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/constants/api_config.dart';
import 'package:pawsure_app/services/auth_service.dart';
// Note: Ensure these imports point to your actual file locations
import 'sitter_dashboard.dart';
import 'sitter_inbox.dart';

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

class SitterCalendar extends StatefulWidget {
  const SitterCalendar({super.key});

  @override
  State<SitterCalendar> createState() => _SitterCalendarState();
}

class _SitterCalendarState extends State<SitterCalendar> {
  DateTime _currentDate = DateTime.now();
  bool _isEditMode = false;
  bool _isLoading = true;
  List<DateTime> _selectedDates = [];
  List<int> _recurringUnavailableDays = [];

  // FIXED: Diagnostic recommended making this final if it's not reassigned
  final Map<String, DateInfo> _dateStatuses = {};

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

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  // --- API Logic ---

  // Inside _SitterCalendarState class in sitter_calendar.dart

  Future<String> _getAuthToken() async {
    try {
      // 1. Initialize the AuthService
      final AuthService authService = AuthService();

      // 2. Use the existing getToken() method from your AuthService
      final String? token = await authService.getToken();

      if (token == null || token.isEmpty) {
        debugPrint("❌ No token found in storage.");
        return '';
      }

      return token;
    } catch (e) {
      debugPrint("❌ Error retrieving token: $e");
      return '';
    }
  }

  Future<void> _fetchAvailability() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // 1. Get the real token (make sure this is implemented)
      final token = await _getAuthToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/sitters/me');

      debugPrint("Fetching from: $url");

      final response = await http
          .get(
            url,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          )
          .timeout(
            const Duration(seconds: 10),
          ); // Add a timeout so it doesn't spin forever

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> dbDates = data['unavailable_dates'] ?? [];
        final List<dynamic> dbDays = data['unavailable_days'] ?? [];

        setState(() {
          _dateStatuses.clear();
          for (var dateStr in dbDates) {
            DateTime parsed = DateTime.parse(dateStr);
            _dateStatuses[dateStr] = DateInfo(
              date: parsed,
              status: DateStatus.unavailable,
            );
          }
          _recurringUnavailableDays = dbDays
              .map((dayName) => _daysOfWeek.indexOf(dayName))
              .where((index) => index != -1)
              .cast<int>()
              .toList();
        });
      } else {
        debugPrint("Server Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Connection Error: $e");
    } finally {
      // This runs no matter what, stopping the loading spinner
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _syncWithBackend() async {
    try {
      final token = await _getAuthToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/sitters/availability');
      List<String> unavailableDates = _dateStatuses.entries
          .where((e) => e.value.status == DateStatus.unavailable)
          .map((e) => e.key)
          .toList();
      List<String> unavailableDays = _recurringUnavailableDays
          .map((index) => _daysOfWeek[index])
          .toList();

      await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "unavailable_dates": unavailableDates,
          "unavailable_days": unavailableDays,
        }),
      );
    } catch (e) {
      debugPrint("Sync Error: $e");
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
      _selectedDates = [];
      _isEditMode = false;
    });
    if (singleDate != null) Navigator.pop(context);
    await _syncWithBackend();
  }

  // --- UI Methods ---

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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMonthControls(),
                _buildLegend(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildWeeklySettingsButton(),
                          const SizedBox(height: 20),
                          _buildCalendarGrid(
                            daysInMonth,
                            firstDayOffset,
                            firstDayOfMonth,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Highlight "calendar"
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _accentColor,
        unselectedItemColor: Colors.grey.shade600,
        onTap: (index) {
          if (index == 0) Get.offAll(() => const SitterDashboard());
          // Add other navigation logic here if needed
        
          if (index == 2) { // Index 2 is Calendar
            Get.to(() => const SitterCalendar());
          }
          // Index 3: Go to Inbox 
          if (index == 3) {
            Get.to(() => const SitterInbox());
          }
          
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Setting'),
        ],
      ),      
      bottomSheet: _isEditMode && _selectedDates.isNotEmpty
          ? _buildBulkEditBar()
          : null,
    );
  }

  // --- FIXED: Added Missing Methods ---

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
                  style: TextStyle(color: Colors.white),
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

  // --- UI Helpers with Deprecation Fixes ---

  Widget _buildDayCell(DateTime date) {
    final statusInfo = _getDateStatus(date);
    final isSelected = _selectedDates.any((d) => _isSameDay(d, date));
    final isToday = _isSameDay(date, DateTime.now());

    // FIXED: Use .withValues(alpha: ...) instead of .withOpacity(...)
    Color bgColor = isSelected
        ? _accentColor.withValues(alpha: 0.15)
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
          ),
        ),
      ),
    );
  }

  // (Remaining UI helper methods like _buildMonthControls, _buildLegend, _buildCalendarGrid go here...)
  // Note: Inside _showWeeklySettingsSheet and _buildBulkEditBar,
  // also update .withOpacity to .withValues(alpha: 0.1) as indicated in your diagnostics.

  Widget _buildBulkEditBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              child: const Text("Unavailable"),
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
                  // FIXED: Used single underscore for unused parameter
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
                              ? _accentColor.withValues(alpha: 0.1)
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
              ElevatedButton(
                onPressed: () async {
                  setState(() => _recurringUnavailableDays = tempRecurring);
                  Navigator.pop(context);
                  await _syncWithBackend();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Save Settings",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (Include _buildMonthControls, _buildLegend, _buildWeeklySettingsButton, _buildCalendarGrid, _changeMonth, _legendItem)
  // These were omitted here for brevity but are required for the full UI.

  void _changeMonth(int offset) {
    setState(() {
      _currentDate = DateTime(
        _currentDate.year,
        _currentDate.month + offset,
        1,
      );
    });
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
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.white, "Available", hasBorder: true),
        const SizedBox(width: 16),
        _legendItem(_accentColor, "Booked"),
        const SizedBox(width: 16),
        _legendItem(Colors.grey.shade300, "Unavailable"),
      ],
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
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildWeeklySettingsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showWeeklySettingsSheet,
        icon: const Icon(Icons.tune),
        label: const Text("Set Weekly Availability"),
      ),
    );
  }

  Widget _buildCalendarGrid(
    int daysInMonth,
    int firstDayOffset,
    DateTime firstDayOfMonth,
  ) {
    return GridView.builder(
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
    );
  }
}
