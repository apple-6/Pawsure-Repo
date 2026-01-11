import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/screens/community/community_screen.dart';
import 'package:pawsure_app/screens/sitter_setup/view_pet_profile.dart';
import 'package:pawsure_app/controllers/sitter_controller.dart';
import 'package:intl/intl.dart';
import 'sitter_calendar.dart';
import 'sitter_inbox.dart';
import 'sitter_setting_screen.dart';

class SitterDashboard extends StatelessWidget {
  const SitterDashboard({super.key});

  static const Color _accent = Color(0xFF1CCA5B);
  static const Color _lightAccent = Color(0xFFEFFAF4);

  @override
  Widget build(BuildContext context) {
    final SitterController controller = Get.find<SitterController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: _accent));
          }

          return RefreshIndicator(
            onRefresh: controller.refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 12),
                  Text(
                    'Hey ${controller.sitterName},',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
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
        selectedItemColor: _accent,
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

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.menu, size: 24),
            const SizedBox(width: 8),
            Text(
              'Dashboard - pet sitter',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(Icons.pets, color: Colors.grey),
        ),
      ],
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
        childAspectRatio: 3.2,
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
              (stay) => Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: _StayCard(booking: stay),
              ),
            )
            .toList(),
      ),
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
  });

  final dynamic booking;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

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
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SitterDashboard._accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to Pet Profile View if needed, or handle accept
                    if (pets.isNotEmpty) {
                      Get.to(
                        () => const PetProfileView(),
                        arguments: {
                          'bookingId': booking['id'],
                          'pet': Pet.fromJson(pets.first),
                          'dateRange': dateRange,
                          'estEarning': earnings,
                        },
                      );
                    }
                  },
                  child: const Text('View Details'),
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
