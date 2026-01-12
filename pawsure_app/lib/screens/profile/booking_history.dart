import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // Uncomment if using Supabase directly
import '../../services/api_service.dart'; // Ensure this path is correct

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> allBookings = [];
  List<Map<String, dynamic>> filteredBookings = [];

  // --- FILTERS STATE ---
  String selectedService = 'All Services';
  String filterType = 'Monthly';
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedWeekRange;
  bool showAllHistory = true;

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

  void _showBookingDetails(Map<String, dynamic> booking) {
    // Helper to format dates nicely
    String formatDate(String? dateStr) {
      if (dateStr == null) return 'N/A';
      try {
        final date = DateTime.parse(dateStr);
        return DateFormat('EEE, d MMM yyyy').format(date);
      } catch (e) {
        return dateStr;
      }
    }

    // Determine color based on status
    Color statusColor;
    String status = booking['status'].toString().toLowerCase();
    if (status == 'paid' || status == 'accepted') statusColor = Colors.green;
    else if (status == 'pending') statusColor = Colors.orange;
    else statusColor = Colors.red;

    // 👇 CHANGED: using showDialog instead of showModalBottomSheet
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20), // Keeps space from screen edges
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 650), // Limit height so it doesn't fill screen
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content height
            children: [
              
              // --- 1. HEADER (Fixed at top) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['petName'],
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Care by ${booking['sitterName']}",
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 30),

              // --- 2. SCROLLABLE CONTENT AREA ---
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Schedule Section
                      const Text("Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.calendar_today, "Start Date", formatDate(booking['startDate'])),
                      _buildDetailRow(Icons.event_busy, "End Date", formatDate(booking['endDate'])),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildDetailRow(Icons.arrow_forward, "Drop-off", booking['dropoffTime'])),
                          Expanded(child: _buildDetailRow(Icons.arrow_back, "Pick-up", booking['pickupTime'])),
                        ],
                      ),
                      const Divider(height: 30),

                      // Instructions Section
                      const Text("Special Instructions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          booking['message'].toString().isEmpty ? "No instructions provided." : booking['message'],
                          style: const TextStyle(color: Colors.black87, height: 1.5),
                        ),
                      ),
                      const Divider(height: 30),

                      // Price Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          Text(
                            "RM ${booking['totalPrice']}",
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2ECA6A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // --- 3. FOOTER (Close Button) ---
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text("Close Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
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
      final List<Map<String, dynamic>> rawData = await apiService.getOwnerBookings();

      // 🔍 DEBUG: Check the first item in your console to verify structure
      if (rawData.isNotEmpty) {
        print("🔍 First Booking Data: ${rawData[0]}");
      }

      setState(() {
        allBookings = rawData.map<Map<String, dynamic>>((item) {
          
          // --- 1. PET NAME (Robust Parsing) ---
          String petName = 'Unknown Pet';
          var petsData = item['pets'] ?? item['pet'];
          if (petsData != null) {
            if (petsData is List && petsData.isNotEmpty) {
              petName = petsData.map((p) => p['name'].toString()).join(', ');
            } else if (petsData is Map) {
              petName = petsData['name']?.toString() ?? 'Unknown Pet';
            }
          }

          // --- 2. SITTER NAME (NestJS Structure Fix) ---
          String sitterName = 'Unknown Sitter';
          var sitterData = item['sitter']; // TypeORM usually returns singular 'sitter'
          
          if (sitterData != null) {
            // Check if name is nested inside 'user' (Standard TypeORM structure)
            if (sitterData['user'] != null && sitterData['user']['name'] != null) {
               sitterName = sitterData['user']['name'].toString();
            } 
            // Fallback: Check if name is directly on sitter object
            else if (sitterData['name'] != null) {
               sitterName = sitterData['name'].toString();
            }
          }

          return {
            "id": item['id'],
            "startDate": item['start_date'] ?? item['startDate'], 
            "endDate": item['end_date'] ?? item['endDate'],
            "status": item['status'] ?? 'pending',
            "totalPrice": item['total_amount']?.toString() ?? item['totalPrice']?.toString() ?? '0',
            
            "message": item['message'] ?? 'No special instructions',
            "pickupTime": item['pick_up_time'] ?? 'Not set',
            "dropoffTime": item['drop_off_time'] ?? 'Not set',
            
            "petName": petName,
            "sitterName": sitterName, // 👈 Now correctly grabs nested user.name
            "serviceType": item['service_type'] ?? 'Pet Service', 
          };
        }).toList();
        
        // Sort Newest First
        allBookings.sort((a, b) {
            DateTime dateA = DateTime.tryParse(a['startDate'].toString()) ?? DateTime(2000);
            DateTime dateB = DateTime.tryParse(b['startDate'].toString()) ?? DateTime(2000);
            return dateB.compareTo(dateA);
        });

        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching bookings: $e");
      setState(() {
        isLoading = false;
        allBookings = []; 
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
        
        // --- 1. Status Filter (Strict History Only) ---
        // We only show finalized bookings. 
        // Note: We include 'declined' because your UI shows them as 'CANCELLED'
        String status = booking['status']?.toString().toLowerCase() ?? '';
        const allowedStatuses = ['completed', 'paid', 'cancelled', 'declined'];
        
        if (!allowedStatuses.contains(status)) {
          return false; // Hide Pending, Accepted, etc.
        }

        // --- 2. Service Filter ---
        String bookingService = booking['serviceType'] ?? 'Pet Service';
        bool serviceMatch = selectedService == 'All Services' ||
            bookingService == selectedService;

        // If "Show All" is active, we stop here (ignoring date, but keeping status/service checks)
        if (showAllHistory) {
          return serviceMatch;
        }

        // --- 3. Date Filter (Overlap Logic) ---
        if (booking['startDate'] == null) return false;

        DateTime start;
        DateTime end;

        try {
          start = DateTime.parse(booking['startDate'].toString());
          // If endDate is missing, assume it's a 1-day booking
          if (booking['endDate'] != null) {
            end = DateTime.parse(booking['endDate'].toString());
          } else {
            end = start; 
          }
        } catch (e) {
          return false;
        }

        // Remove time for accurate date comparison
        DateTime safeSelected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        DateTime safeStart = DateTime(start.year, start.month, start.day);
        DateTime safeEnd = DateTime(end.year, end.month, end.day);

        bool dateMatch = false;

        if (filterType == 'Daily') {
          // Check if Selected Date falls within [Start, End]
          dateMatch = (safeSelected.isAtSameMomentAs(safeStart) || safeSelected.isAfter(safeStart)) && 
                      (safeSelected.isAtSameMomentAs(safeEnd) || safeSelected.isBefore(safeEnd));
                      
        } else if (filterType == 'Weekly') {
          if (selectedWeekRange != null) {
            DateTime rangeStart = DateTime(selectedWeekRange!.start.year, selectedWeekRange!.start.month, selectedWeekRange!.start.day);
            DateTime rangeEnd = DateTime(selectedWeekRange!.end.year, selectedWeekRange!.end.month, selectedWeekRange!.end.day);

            // Check for Overlap: (StartA <= EndB) and (EndA >= StartB)
            dateMatch = (safeStart.isBefore(rangeEnd.add(const Duration(days: 1))) && 
                         safeEnd.isAfter(rangeStart.subtract(const Duration(days: 1))));
          }
        } else if (filterType == 'Monthly') {
           // Check if booking touches the selected month
           bool startsInMonth = start.year == selectedDate.year && start.month == selectedDate.month;
           bool endsInMonth = end.year == selectedDate.year && end.month == selectedDate.month;
           bool spansMonth = start.isBefore(DateTime(selectedDate.year, selectedDate.month, 1)) && 
                             end.isAfter(DateTime(selectedDate.year, selectedDate.month + 1, 0));

           dateMatch = startsInMonth || endsInMonth || spansMonth;
        }

        return serviceMatch && dateMatch;
      }).toList();
    });
  }
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _pickDate() async {
    // Logic matches your provided template
    if (filterType == 'Monthly') {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Select Month", style: TextStyle(color: Color(0xFF2ECA6A))),
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
            title: Text(filterType == 'Weekly' ? "Select Week" : "Select Date", style: const TextStyle(color: Color(0xFF2ECA6A))),
            content: SizedBox(
              width: 320,
              height: filterType == 'Weekly' ? 440 : 380,
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
                        Navigator.pop(context);
                      },
                      onRangeSelected: (range) {
                        setState(() {
                          selectedWeekRange = range;
                          showAllHistory = false;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                  if (filterType == 'Weekly') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ECA6A),
                        ),
                        child: const Text("Confirm Selection", style: TextStyle(color: Colors.white)),
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
    if (filterType == 'Daily') return DateFormat('d MMM yyyy').format(selectedDate);
    if (filterType == 'Weekly') {
      if (selectedWeekRange == null) return "Select Range";
      return "${DateFormat('d MMM').format(selectedWeekRange!.start)} - ${DateFormat('d MMM').format(selectedWeekRange!.end)}";
    }
    return DateFormat('MMMM yyyy').format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF2ECA6A);
    const bgColor = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Booking History', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: brandColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: brandColor))
          : CustomScrollView(
              slivers: [
                // Filter Header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyFilterDelegate(
                    height: 130, // Reduced height since summary cards are gone
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Your Bookings (${filteredBookings.length})",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              TextButton.icon(
                                onPressed: _resetFilters,
                                icon: const Icon(Icons.refresh, size: 16, color: Colors.grey),
                                label: const Text("Clear Filter", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Dropdowns and Date Picker Row
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildDropdown(filterType, filterOptions, (val) {
                                  setState(() => filterType = val!);
                                }, icon: Icons.tune, isFiltered: !showAllHistory),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: InkWell(
                                  onTap: _pickDate,
                                  child: Container(
                                    height: 45,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: showAllHistory ? Colors.grey.shade100 : brandColor.withOpacity(0.1),
                                      border: Border.all(color: showAllHistory ? Colors.grey.shade300 : brandColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.calendar_month, size: 18, color: showAllHistory ? Colors.grey : brandColor),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _getDateButtonText(),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: showAllHistory ? Colors.grey : brandColor,
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
                        ],
                      ),
                    ),
                  ),
                ),

                // Booking List
                filteredBookings.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState())
                    : SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final booking = filteredBookings[index];
                              return _buildBookingCard(booking, brandColor);
                            },
                            childCount: filteredBookings.length,
                          ),
                        ),
                      ),
              ],
            ),
    );
  }

  // --- WIDGET HELPERS ---
  
  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged, {IconData? icon, bool isFiltered = false}) {
    const brandColor = Color(0xFF2ECA6A);
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isFiltered ? brandColor.withOpacity(0.1) : Colors.grey.shade50,
        border: Border.all(color: isFiltered ? brandColor : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(icon ?? Icons.arrow_drop_down, size: 18, color: isFiltered ? brandColor : Colors.black87),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isFiltered ? brandColor : Colors.black87),
          items: items.map((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black87, fontSize: 13)));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

 Widget _buildBookingCard(Map<String, dynamic> booking, Color brandColor) {
    DateTime date;
    try {
      date = DateTime.parse(booking['startDate'].toString());
    } catch (e) {
      date = DateTime.now();
    }
    String formattedDate = DateFormat('d MMM yyyy').format(date);
    
    // 👇 CHANGED: We now prioritize Pet Name for the main title
    final petName = booking['petName'] ?? 'My Pet';
    final serviceName = booking['serviceType'] ?? 'Pet Service';
    final price = booking['totalPrice']?.toString() ?? '0';
    final status = booking['status']?.toString().toLowerCase() ?? 'pending';

    // Status styling
    Color statusColor;
    String statusText;
    switch(status) {
      case 'paid':
      case 'accepted':
      case 'completed':
        statusColor = Colors.green;
        statusText = status.toUpperCase();
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'PENDING';
        break;
      case 'declined':
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'CANCELLED';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status.toUpperCase();
    }

    return GestureDetector( // 👇 ADDED: Makes the whole card clickable
      onTap: () => _showBookingDetails(booking), // 👇 TRIGGER THE POPUP
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: brandColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getServiceIcon(serviceName), color: brandColor, size: 24),
            ),
            const SizedBox(width: 16),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👇 CHANGED: Main title is now Pet Name
                  Text(
                    petName, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  // Subtitle shows Service Type + Date
                  Text(
                    "$serviceName • $formattedDate", 
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            
            // Right Side (Price + Status)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("RM $price", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
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
          Text("No bookings found", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
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
}

// Reuse the Header Delegate
class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  _StickyFilterDelegate({required this.child, required this.height});
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox(height: height, child: child);
  @override
  bool shouldRebuild(_StickyFilterDelegate oldDelegate) => oldDelegate.child != child || oldDelegate.height != height;
}

// ... (Paste this at the bottom of booking_history.dart)

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
                if (_tempStartDate != null) {
                  isStartDate = _isSameDay(date, _tempStartDate!);
                }
                if (_tempEndDate != null) {
                  isEndDate = _isSameDay(date, _tempEndDate!);
                }

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
                    setState(() {
                      if (_tempStartDate == null ||
                          (_tempStartDate != null && _tempEndDate != null)) {
                        _tempStartDate = date;
                        _tempEndDate = null;
                      } else if (_tempStartDate != null &&
                          _tempEndDate == null) {
                        if (date.isBefore(_tempStartDate!)) {
                          _tempEndDate = _tempStartDate;
                          _tempStartDate = date;
                        } else {
                          _tempEndDate = date;
                        }

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