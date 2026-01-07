import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sitter_dashboard.dart';
import 'chat_screen.dart';
import 'sitter_calendar.dart';
import 'sitter_setting_screen.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/services/auth_service.dart';


// --- Data Models ---


class SitterInboxItem {
  final int id;
  final String petName;
  final String ownerName;
  final String petType; // 'dog' or 'cat'
  final String startDate;
  final String endDate;
  final double estimatedEarnings;
  final String status;
  final String? message;


  SitterInboxItem({
    required this.id,
    required this.petName,
    required this.ownerName,
    required this.petType,
    required this.startDate,
    required this.endDate,
    required this.estimatedEarnings,
    required this.status,
    this.message,
  });


  factory SitterInboxItem.fromJson(Map<String, dynamic> json) {
    final pet = json['pet'] as Map<String, dynamic>?;
    final owner = json['owner'] as Map<String, dynamic>?;

    return SitterInboxItem(
      id: json['id'] as int,
      petName: pet?['name'] ?? 'Unknown Pet',
      ownerName: owner?['name'] ?? 'Unknown Owner',
      petType: (pet?['species'] ?? 'dog').toString().toLowerCase(),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      estimatedEarnings: (json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      message: json['message'],
    );
  }
}




// ✅ RENAMED CLASS TO MATCH DASHBOARD
class SitterInbox extends StatefulWidget {
  const SitterInbox({super.key});
  

  @override
  State<SitterInbox> createState() => _SitterInboxState();
}

class _SitterInboxState extends State<SitterInbox>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color _accentColor = const Color(0xFF1CCA5B);
  final ApiService _apiService = ApiService();

  final AuthService _authService = AuthService(); // Add this
  int? _currentUserId;

  List<SitterInboxItem> _allBookings = [];
  bool _isLoading = true;
  String? _error;

  // Filtered lists
  List<SitterInboxItem> get _pendingRequests =>
      _allBookings.where((b) => b.status.toLowerCase() == 'pending').toList();

  List<SitterInboxItem> get _confirmedBookings =>
      _allBookings.where((b) => b.status.toLowerCase() != 'pending').toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUser();
    _loadBookings();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = await _authService.getUserId();
      if (userId != null) {
        setState(() {
          _currentUserId = userId;
        });
        print("✅ Inbox loaded for User ID: $userId");
      } else {
        print("⚠️ No User ID found. User might not be logged in.");
      }
    } catch (e) {
      print("Error loading user ID: $e");
    }
  }

  // 2. UPDATE THE NAVIGATION FUNCTION
  void _openChat(
    String ownerName,
    String petName,
    String dates,
    bool isRequest,
    int bookingId,
  ) async {
    // We need the current user ID for the socket.
    // If _currentUserId is null, fetch it quickly or grab from storage
    int myId = _currentUserId ?? 0;
    if (myId == 0) {
      // Try fetching one last time
      final fetchedId = await _authService.getUserId();
      if (fetchedId != null) {
        myId = fetchedId;
        setState(() => _currentUserId = myId);
      } else {
        // Stop here if we still don't have an ID
        Get.snackbar(
          "Error",
          "Could not identify user. Please log in again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    Get.to(
      () => ChatScreen(
        ownerName: ownerName,
        petName: petName,
        dates: dates,
        isRequest: isRequest,
        room: 'booking-$bookingId', // ✅ Generates unique room ID
        currentUserId: myId, // ✅ Passes required ID
        bookingId: bookingId,
      ),
    );
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookingsJson = await _apiService.getSitterBookings();
      setState(() {
        _allBookings = bookingsJson
            .map((json) => SitterInboxItem.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('❌ Error loading bookings: $e');
    }
  }

  Future<void> _handleAccept(int bookingId) async {
    try {
      await _apiService.updateBookingStatus(bookingId, 'accepted');
      Get.snackbar(
        'Success',
        'Booking accepted!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _loadBookings(); // Refresh the list
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept booking: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleDecline(int bookingId) async {
    try {
      await _apiService.updateBookingStatus(bookingId, 'declined');
      Get.snackbar(
        'Declined',
        'Booking declined',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      _loadBookings(); // Refresh the list
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to decline booking: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Inbox',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // No back button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: _loadBookings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _accentColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _accentColor,
          tabs: [
            Tab(text: "Requests (${_pendingRequests.length})"),
            Tab(text: "Bookings (${_confirmedBookings.length})"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_error', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBookings,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Pending Requests
                _pendingRequests.isEmpty
                    ? const Center(
                        child: Text(
                          'No pending requests',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pendingRequests.length,
                        itemBuilder: (context, index) {
                          final request = _pendingRequests[index];
                          return NewInboxCard(
                            inbox: request,
                            onTap: () => _openChat(
                              request.ownerName,
                              request.petName,
                              "${request.startDate} - ${request.endDate}",
                              true,
                              request.id,
                            ),
                            onAccept: () => _handleAccept(request.id),
                            onDecline: () => _handleDecline(request.id),
                          );
                        },
                      ),

                // Tab 2: Confirmed Bookings
                _confirmedBookings.isEmpty
                    ? const Center(
                        child: Text(
                          'No confirmed bookings',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _confirmedBookings.length,
                        itemBuilder: (context, index) {
                          final booking = _confirmedBookings[index];
                          return ConfirmedBookingCard(
                            inbox: booking,
                            onTap: () => _openChat(
                              booking.ownerName,
                              booking.petName,
                              "${booking.startDate} - ${booking.endDate}",
                              false,
                              booking.id,
                            ),
                          );
                        },
                      ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Highlight "Inbox"
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _accentColor,
        unselectedItemColor: Colors.grey.shade600,
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
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}

// --- Component: New Request Card (with Accept/Decline) ---

class NewInboxCard extends StatelessWidget {
  final SitterInboxItem inbox;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const NewInboxCard({
    super.key,
    required this.inbox,
    required this.onTap,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final isDog = inbox.petType == 'dog';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  child: Icon(
                    isDog ? Icons.pets : Icons.cruelty_free,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inbox.petName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Owner: ${inbox.ownerName}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${inbox.startDate} - ${inbox.endDate}",
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  "Est: RM${inbox.estimatedEarnings.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1CCA5B),
                  ),
                ),
              ],
            ),
            if (inbox.message != null && inbox.message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '"${inbox.message}"',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            // Accept / Decline buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1CCA5B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Component: Confirmed Booking Card ---

class ConfirmedBookingCard extends StatelessWidget {
  final SitterInboxItem inbox;
  final VoidCallback onTap;

  const ConfirmedBookingCard({
    super.key,
    required this.inbox,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDog = inbox.petType == 'dog';
    final statusColor = _getStatusColor(inbox.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  child: Icon(
                    isDog ? Icons.pets : Icons.cruelty_free,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inbox.petName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Owner: ${inbox.ownerName}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    inbox.status.substring(0, 1).toUpperCase() +
                        inbox.status.substring(1),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${inbox.startDate} - ${inbox.endDate}",
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  "RM${inbox.estimatedEarnings.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1CCA5B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
