import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/screens/community/community_screen.dart';
import 'sitter_dashboard.dart';
import 'chat_screen.dart';
import 'sitter_calendar.dart';
import 'sitter_setting_screen.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/services/auth_service.dart';

// --- Data Models ---

class SitterInboxItem {
  final int id;
  //final String petName;
  final List<Map<String, String>> pets;
  final String ownerName;
  final String petType; // 'dog' or 'cat'
  final String startDate;
  final String endDate;
  final double estimatedEarnings;
  final String status;
  final String? message;

  SitterInboxItem({
    required this.id,
    required this.pets,
    required this.ownerName,
    required this.petType,
    required this.startDate,
    required this.endDate,
    required this.estimatedEarnings,
    required this.status,
    this.message,
  });

  // ✅ Helper to get comma-separated names: "Coco, Max"
  String get petNames {
    if (pets.isEmpty) return 'Unknown Pet';
    return pets.map((p) => p['name']).join(', ');
  }

  // ✅ Helper to get primary type for icon
  String get primaryPetType {
    if (pets.isEmpty) return 'dog';
    // Use the stored petType or fallback to the first pet's type
    return petType.isNotEmpty ? petType : (pets.first['type'] ?? 'dog');
  }

  // factory SitterInboxItem.fromJson(Map<String, dynamic> json) {
  //   final pet = json['pet'] as Map<String, dynamic>?;
  //   final owner = json['owner'] as Map<String, dynamic>?;

  factory SitterInboxItem.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;

    String primaryType = 'dog'; // Default
    List<Map<String, String>> parsedPets = [];

    // ✅ 1. Try parsing the 'pets' array (New Many-to-Many structure)
    if (json['pets'] != null && json['pets'] is List) {
      final petsList = json['pets'] as List;
      if (petsList.isNotEmpty) {
        parsedPets = petsList.map((p) {
          // Safely access properties
          final name = p['name']?.toString() ?? 'Unknown';
          final species = (p['species'] ?? 'dog').toString().toLowerCase();
          return {'name': name, 'type': species};
        }).toList();

        // Set primary type from the first pet
        if (parsedPets.isNotEmpty) {
          primaryType = parsedPets.first['type']!;
        }
      }
    }
    // ✅ 2. Fallback for 'pet' object (Old structure or specific endpoints)
    else if (json['pet'] != null && json['pet'] is Map) {
      final p = json['pet'];
      final name = p['name']?.toString() ?? 'Unknown';
      final species = (p['species'] ?? 'dog').toString().toLowerCase();

      parsedPets.add({'name': name, 'type': species});
      primaryType = species;
    }

    return SitterInboxItem(
      id: json['id'] as int,
      pets: parsedPets,
      ownerName: owner?['name'] ?? 'Unknown Owner',
      petType: primaryType,
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

  // ✅ FIX: Use GetX singletons instead of creating new instances
  ApiService get _apiService => Get.find<ApiService>();
  AuthService get _authService => Get.find<AuthService>();

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
    String petNames,
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
        petName: petNames,
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
                              request.petNames,
                              //request.petName,
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
                              booking.petNames,
                              "${booking.startDate} - ${booking.endDate}",
                              false,
                              booking.id,
                            ),
                            onComplete: () =>
                                _loadBookings(), // Refresh after completing
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
            Get.offAll(() => const CommunityScreen());
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
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
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
                        inbox.petNames,
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
  final VoidCallback? onComplete;

  const ConfirmedBookingCard({
    super.key,
    required this.inbox,
    required this.onTap,
    this.onComplete,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'paid':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleComplete(BuildContext context) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Completed'),
        content: const Text(
          'Have you completed this service?\n\nThis will notify the owner and allow them to process payment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final apiService = Get.find<ApiService>();
      await apiService.completeService(inbox.id);

      if (context.mounted) {
        Navigator.pop(context); // Close loading

        Get.snackbar(
          '✅ Service Completed',
          'Booking has been marked as completed. Owner will be notified!',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        onComplete?.call();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading

        Get.snackbar(
          '❌ Error',
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
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
                        inbox.petNames,
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

            // ✅ MARK AS COMPLETED BUTTON (Show only if status is "accepted")
            if (inbox.status.toLowerCase() == 'accepted') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleComplete(context),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text(
                    'Mark as Completed',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],

            // Show status messages for completed/paid bookings
            if (inbox.status.toLowerCase() == 'completed') ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Awaiting payment from owner',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (inbox.status.toLowerCase() == 'paid') ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '✅ Payment received!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
