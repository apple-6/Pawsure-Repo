import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/screens/community/community_screen.dart';
import 'package:pawsure_app/screens/sitter_setup/view_pet_profile.dart';
import 'package:pawsure_app/controllers/sitter_controller.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';
import 'package:intl/intl.dart';
import 'sitter_calendar.dart';
import 'sitter_inbox.dart';
import 'sitter_setting_screen.dart';
import 'chat_screen.dart';

class SitterDashboard extends StatefulWidget {
  const SitterDashboard({super.key});

  static const Color _accent = Color(0xFF1CCA5B);
  static const Color _lightAccent = Color(0xFFEFFAF4);

  @override
  State<SitterDashboard> createState() => _SitterDashboardState();
}

class _SitterDashboardState extends State<SitterDashboard> {
  final SitterController controller = Get.find<SitterController>();

  @override
  void initState() {
    super.initState();
    // Force refresh when entering dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: SitterDashboard._accent));
          }

          return RefreshIndicator(
            onRefresh: controller.refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Combined Top Bar with Name and Profile Pic
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hey ${controller.sitterName},',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.grey),
                        // TODO: Use NetworkImage if profile pic exists
                        // backgroundImage: controller.profilePicUrl != null ? NetworkImage(controller.profilePicUrl!) : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildStatsGrid(controller),
                  const SizedBox(height: 20),
                  _buildSectionHeader('New Requests'),
                  const SizedBox(height: 8),
                  _buildRequests(controller),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Current & Upcoming Stays'),
                  const SizedBox(height: 8),
                  _buildUpcomingStays(controller),
                ],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: SitterDashboard._accent,
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
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
            icon: Icon(Icons.chat_bubble_outline),
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

  Widget _buildStatsGrid(SitterController controller) {
    final stats = [
      _StatCard(
        title: 'Earnings',
        value: 'RM ${controller.earnings.value.toStringAsFixed(2)}',
        icon: Icons.attach_money,
      ),
      _StatCard(
        title: 'Pending',
        value: controller.pendingRequestsCount.value.toString(),
        icon: Icons.timer_outlined,
      ),
      _StatCard(
        title: 'Active',
        value: controller.activeStaysCount.value.toString(),
        icon: Icons.calendar_month,
      ),
      _StatCard(
        title: 'Rating',
        value: controller.avgRating.value.toStringAsFixed(2),
        icon: Icons.star_rate_rounded,
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => _StatTile(stat: stats[index]),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildRequests(SitterController controller) {
    debugPrint('🔍 Dashboard Bookings: ${controller.bookings.length}');
    if (controller.bookings.isNotEmpty) {
      debugPrint('🔍 First booking status: ${controller.bookings.first['status']}');
    }

    final pendingBookings = controller.bookings
        .where((b) => b['status']?.toString().toLowerCase() == 'pending')
        .toList();

    if (pendingBookings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No new requests',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: pendingBookings
          .map(
            (booking) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RequestCard(
                booking: booking,
                onAccept: () => controller.updateBookingStatus(booking['id'], 'accepted'),
                onDecline: () => controller.updateBookingStatus(booking['id'], 'declined'),
                onChat: () {
                  final ownerName = booking['owner']?['name'] ?? 'Owner';
                  final pets = booking['pets'] as List? ?? [];
                  final petNames = pets.map((p) => p['name']).join(', ');
                  final startDate = DateTime.parse(booking['start_date']);
                  final endDate = DateTime.parse(booking['end_date']);
                  final dateRange = "${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}";
                  final currentUserId = Get.find<ProfileController>().user['id'];
                  
                  if (currentUserId == null) {
                    Get.snackbar("Error", "Could not identify user", backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
                    return;
                  }

                  Get.to(() => ChatScreen(
                    ownerName: ownerName,
                    petName: petNames,
                    dates: dateRange,
                    isRequest: true,
                    room: 'booking-${booking['id']}',
                    currentUserId: currentUserId,
                    bookingId: booking['id'],
                  ));
                },
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildUpcomingStays(SitterController controller) {
    final stays = controller.bookings
        .where((b) => ['accepted', 'in progress', 'upcoming'].contains(
          b['status']?.toString().toLowerCase(),
        ))
        .toList();

    if (stays.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No upcoming stays',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: stays
            .map(
              (stay) => GestureDetector(
                onTap: () => _showBookingDetails(context, stay),
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  child: _StayCard(booking: stay),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _showBookingDetails(BuildContext context, dynamic booking) {
    final pets = booking['pets'] as List? ?? [];
    final petNames = pets.map((p) => p['name']).join(', ');
    final ownerName = booking['owner']?['name'] ?? 'Unknown Owner';
    final startDate = DateTime.parse(booking['start_date']);
    final endDate = DateTime.parse(booking['end_date']);
    final dateRange = "${DateFormat('MMM d, yyyy').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}";
    final remarks = booking['message'] ?? 'No remarks provided.';
    final earnings = "RM ${booking['total_amount']}";
    final status = booking['status']?.toString().toUpperCase() ?? 'UNKNOWN';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Booking Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: SitterDashboard._accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: SitterDashboard._accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.pets, 'Pets', petNames),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.person, 'Owner', ownerName),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.calendar_today, 'Date', dateRange),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.monetization_on, 'Earnings', earnings),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Remarks / Message',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  remarks,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _StatCard {
  final String title;
  final String value;
  final IconData icon;

  _StatCard({required this.title, required this.value, required this.icon});
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final _StatCard stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SitterDashboard._lightAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, color: SitterDashboard._accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat.title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  stat.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.booking,
    required this.onAccept,
    required this.onDecline,
    required this.onChat,
  });

  final dynamic booking;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final pets = booking['pets'] as List? ?? [];
    final petNames = pets.map((p) => p['name']).join(', ');
    final ownerName = booking['owner']?['name'] ?? 'Someone';
    final startDate = DateTime.parse(booking['start_date']);
    final endDate = DateTime.parse(booking['end_date']);
    final dateRange = "${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}";
    final earnings = "RM ${booking['total_amount']}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SitterDashboard._lightAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pets, color: SitterDashboard._accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petNames,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Requested by $ownerName',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          dateRange,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          size: 16,
                          color: SitterDashboard._accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Est. Earning: $earnings',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: SitterDashboard._accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // View Details Button (Replaced logic to just print or do nothing as per user request to focus on chat)
              // Actually, user said "wanna chat with owner". I will replace "View Details" with "Chat" or add it.
              // Let's add a Chat icon button and keep View Details or just make the whole card clickable for details?
              // The prompt says "When I click in and wanna chat... it does not link".
              // I'll replace "View Details" with "Chat with Owner" to be explicit.
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: SitterDashboard._accent,
                    elevation: 0,
                    side: const BorderSide(color: SitterDashboard._accent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onAccept,
                icon: const Icon(Icons.check_circle, color: SitterDashboard._accent),
                tooltip: 'Accept',
              ),
              IconButton(
                onPressed: onDecline,
                icon: const Icon(Icons.cancel, color: Colors.redAccent),
                tooltip: 'Decline',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StayCard extends StatelessWidget {
  const _StayCard({required this.booking});

  final dynamic booking;

  @override
  Widget build(BuildContext context) {
    final pets = booking['pets'] as List? ?? [];
    final petNames = pets.map((p) => p['name']).join(', ');
    final startDate = DateTime.parse(booking['start_date']);
    final endDate = DateTime.parse(booking['end_date']);
    final dateRange = "${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}";
    final status = booking['status']?.toString() ?? 'Upcoming';
    
    Color statusColor = Colors.blue.shade400;
    if (status.toLowerCase() == 'accepted') statusColor = SitterDashboard._accent;
    if (status.toLowerCase() == 'in progress') statusColor = Colors.orange;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: SitterDashboard._lightAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.pets,
                size: 28,
                color: SitterDashboard._accent,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            petNames,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            dateRange,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
