import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'owner_chat_screen.dart'; // ✅ Import your new Owner Chat Screen
import 'review_modal.dart'; // Adjust path if needed

// --- Data Model for Owner ---

class OwnerInboxItem {
  final int id;
  final String petName;
  final String sitterName;
  final String petType;
  final String startDate;
  final String endDate;
  final double estimatedCost;
  final String status;
  final String? message;
  final String room; // Added room for chat

  OwnerInboxItem({
    required this.id,
    required this.petName,
    required this.sitterName,
    required this.petType,
    required this.startDate,
    required this.endDate,
    required this.estimatedCost,
    required this.status,
    required this.room,
    this.message,
  });

  factory OwnerInboxItem.fromJson(Map<String, dynamic> json) {
    final petsList = json['pets'] as List<dynamic>?;
    // Owners see the SITTER'S name
    final sitter = json['sitter'] as Map<String, dynamic>?;

    // 1. Logic to extract Sitter Name correctly
    // The name is usually inside sitter['user']['name']
    String parsedSitterName = 'Waiting for Sitter...';

    String displayPetName = 'Unknown Pet';
    String displayPetType = 'dog';

    if (petsList != null && petsList.isNotEmpty) {
      final bookingPet = petsList[0] as Map<String, dynamic>;
      displayPetName = bookingPet['name'] ?? 'Unknown Pet';
      displayPetType = (bookingPet['species'] ?? 'dog').toString().toLowerCase();
    }
    
    if (sitter != null) {
      if (sitter['user'] != null && sitter['user']['name'] != null) {
        parsedSitterName = sitter['user']['name'];
      } else if (sitter['name'] != null) {
        // Fallback in case your backend structure is flat
        parsedSitterName = sitter['name'];
      }
    }

    return OwnerInboxItem(
      id: json['id'] as int,
      petName: displayPetName,
      sitterName: parsedSitterName,
      petType: displayPetType,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      estimatedCost: (json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      room: 'booking-${json['id']}', // Unique room ID based on booking
      message: json['message'],
    );
  }
}

// --- Main Screen ---

class OwnerInbox extends StatefulWidget {
  const OwnerInbox({super.key});

  @override
  State<OwnerInbox> createState() => _OwnerInboxState();
}

class _OwnerInboxState extends State<OwnerInbox>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color _accentColor = const Color(0xFF1CCA5B);
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  int? _currentUserId;
  List<OwnerInboxItem> _allBookings = [];
  bool _isLoading = true;
  String? _error;

  // Filtered lists
  List<OwnerInboxItem> get _pendingRequests =>
      _allBookings.where((b) => b.status.toLowerCase() == 'pending').toList();

  // 2. Confirmed Tab: 'accepted', 'cancelled', 'declined'
  List<OwnerInboxItem> get _confirmedBookings => _allBookings.where((b) {
    final s = b.status.toLowerCase();
    return s == 'accepted' || s == 'cancelled' || s == 'declined';
  }).toList();

  // 3. Completed Tab: 'completed', 'paid'
  List<OwnerInboxItem> get _completedBookings => _allBookings.where((b) {
    final s = b.status.toLowerCase();
    return s == 'completed' || s == 'paid';
  }).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCurrentUser();
    _loadBookings();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = await _authService.getUserId();
      if (userId != null) {
        setState(() => _currentUserId = userId);
      }
    } catch (e) {
      debugPrint("Error loading user ID: $e");
    }
  }

  // Inside _OwnerInboxState class...

  void _openReviewDialog(int bookingId, String sitterName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReviewModal(
        sitterName: sitterName,
        onSubmit: (rating, comment) async {
          Navigator.pop(context); // Close dialog immediately

          try {
            // Show simple loading overlay
            Get.dialog(
              const Center(child: CircularProgressIndicator(color: Colors.white)), 
              barrierDismissible: false
            );
            
            await _apiService.createReview(
              bookingId: bookingId,
              rating: rating,
              comment: comment,
            );
            
            if (Get.isDialogOpen ?? false) Get.back(); // Close loading

            Get.snackbar(
              'Thank you!', 
              'Review submitted successfully',
              backgroundColor: _accentColor,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            );
          } catch (e) {
            if (Get.isDialogOpen ?? false) Get.back(); // Close loading on error
            Get.snackbar(
              'Error', 
              'Failed to submit review',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            );
          }
        },
      ),
    );
  }
  
  // ✅ Navigate to OWNER Chat Screen
  void _openChat(OwnerInboxItem item) async {
    int myId = _currentUserId ?? 0;

    // Safety check for ID
    if (myId == 0) {
      final fetchedId = await _authService.getUserId();
      if (fetchedId != null) {
        myId = fetchedId;
        setState(() => _currentUserId = myId);
      } else {
        Get.snackbar(
          "Error",
          "Please log in again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OwnerChatScreen(
          sitterName: item.sitterName, // Pass Sitter Name
          petName: item.petName,
          dates: "${item.startDate} - ${item.endDate}",
          isRequest: item.status == 'pending', // If pending, show Cancel button
          room: item.room,
          currentUserId: myId,
          bookingId: item.id,
        ),
      ),
    );
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Ensure ApiService has a method 'getOwnerBookings()'
      // which calls GET /bookings/owner
      final bookingsJson = await _apiService.getOwnerBookings();
      if (mounted) {
        setState(() {
          _allBookings = bookingsJson
              .map((json) => OwnerInboxItem.fromJson(json))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleCancel(int bookingId) async {
    try {
      await _apiService.updateBookingStatus(bookingId, 'cancelled');
      Get.snackbar(
        'Success',
        'Request cancelled.',
        backgroundColor: Colors.grey,
        colorText: Colors.white,
      );
      _loadBookings();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel: $e',
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
          'My Bookings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(
          color: Colors.black,
        ), // Back button to return to Community/Feed
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
            Tab(text: "Pending (${_pendingRequests.length})"),
            Tab(text: "Confirmed (${_confirmedBookings.length})"),
            Tab(text: "Completed (${_completedBookings.length})"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Pending Requests
                _pendingRequests.isEmpty
                    ? const Center(
                        child: Text(
                          'No pending requests',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pendingRequests.length,
                        itemBuilder: (context, index) {
                          final request = _pendingRequests[index];
                          return OwnerPendingCard(
                            inbox: request,
                            onTap: () => _openChat(request),
                            onCancel: () => _handleCancel(request.id),
                          );
                        },
                      ),

                // Tab 2: Confirmed Bookings
                _confirmedBookings.isEmpty
                    ? const Center(
                        child: Text(
                          'No upcoming bookings',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _confirmedBookings.length,
                        itemBuilder: (context, index) {
                          final booking = _confirmedBookings[index];
                          return OwnerConfirmedCard(
                            inbox: booking,
                            onTap: () => _openChat(booking),
                          );
                        },
                      ),
                _completedBookings.isEmpty
                    ? const Center(
                        child: Text(
                          'No completed history',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _completedBookings.length,
                        itemBuilder: (context, index) {
                          final booking = _completedBookings[index];
                          return OwnerConfirmedCard(
                            inbox: booking,
                            onTap: () => _openChat(booking),

                            // ✅ Pass the review action here
                            onReview: () => _openReviewDialog(
                              booking.id, 
                              booking.sitterName
                            ),
                          );
                        },
                      ),
              ],
            ),
    );
  }
}

// --- Component: Owner Pending Card ---

class OwnerPendingCard extends StatelessWidget {
  final OwnerInboxItem inbox;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const OwnerPendingCard({
    super.key,
    required this.inbox,
    required this.onTap,
    required this.onCancel,
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
                        "Sitter: ${inbox.sitterName}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "For: ${inbox.petName}",
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
                  "RM${inbox.estimatedCost.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1CCA5B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Component: Owner Confirmed Card ---

class OwnerConfirmedCard extends StatelessWidget {
  final OwnerInboxItem inbox;
  final VoidCallback onTap;
  final VoidCallback? onReview;

  const OwnerConfirmedCard({
    super.key,
    required this.inbox,
    required this.onTap,
    this.onReview,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return Colors.blue;
      case 'paid':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDog = inbox.petType == 'dog';
    final statusColor = _getStatusColor(inbox.status);
    final canReview = [
      'completed',
      'paid',
    ].contains(inbox.status.toLowerCase());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
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
                        "Sitter: ${inbox.sitterName}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Pet: ${inbox.petName}",
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
                    inbox.status.toUpperCase(),
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
                  "RM${inbox.estimatedCost.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1CCA5B),
                  ),
                ),
              ],
            ),
            if (canReview) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onReview,
                  icon: const Icon(Icons.star_rate_rounded, size: 18),
                  label: const Text('Review'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber[800],
                    side: BorderSide(color: Colors.amber.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
