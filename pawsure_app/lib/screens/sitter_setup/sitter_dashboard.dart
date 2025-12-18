import 'package:flutter/material.dart';
import 'package:get/get.dart'; // <--- Import GetX
import 'sitter_calendar.dart';
import 'sitter_inbox.dart';
import 'sitter_setting_screen.dart';

class SitterDashboard extends StatelessWidget {
  const SitterDashboard({super.key});

  static const Color _accent = Color(0xFF1CCA5B);
  static const Color _lightAccent = Color(0xFFEFFAF4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 12),
              Text(
                'Hey Anya Forger,',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _buildStatsGrid(context),
              const SizedBox(height: 20),
              _buildSectionHeader('New Requests'),
              const SizedBox(height: 8),
              _buildRequests(),
              const SizedBox(height: 20),
              _buildSectionHeader('Current & Upcoming Stays'),
              const SizedBox(height: 8),
              _buildUpcomingStays(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _accent,
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: 0,
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

  Widget _buildStatsGrid(BuildContext context) {
    final stats = [
      _StatCard(title: 'Earnings', value: 'RM 0.00', icon: Icons.attach_money),
      _StatCard(title: 'Pending', value: '0', icon: Icons.timer_outlined),
      _StatCard(title: 'Active', value: '0', icon: Icons.calendar_month),
      _StatCard(title: 'Rating', value: '0.00', icon: Icons.star_rate_rounded),
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

  Widget _buildRequests() {
    final requests = List.generate(
      2,
      (_) => _Request(
        petName: 'Lucky',
        requester: 'Bill',
        dateRange: 'Oct 22 - Oct 28',
        estEarning: 'RM 360',
      ),
    );

    return Column(
      children: requests
          .map(
            (req) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RequestCard(request: req),
            ),
          )
          .toList(),
    );
  }

  Widget _buildUpcomingStays() {
    final stays = [
      _StayCard(
        petName: 'Lucky',
        dateRange: 'Oct 22 - Oct 28',
        statusLabel: 'In Progress',
        statusColor: _accent,
      ),
      _StayCard(
        petName: 'Coco',
        dateRange: 'Oct 16 - Oct 20',
        statusLabel: 'Upcoming',
        statusColor: Colors.blue.shade400,
      ),
    ];

    return Row(
      children:
          stays
              .map(
                (stay) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: stay,
                  ),
                ),
              )
              .toList()
            ..removeLast(), // remove padding after last item
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stat.title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                stat.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Request {
  final String petName;
  final String requester;
  final String dateRange;
  final String estEarning;

  _Request({
    required this.petName,
    required this.requester,
    required this.dateRange,
    required this.estEarning,
  });
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final _Request request;

  @override
  Widget build(BuildContext context) {
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
                      request.petName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Requested by ${request.requester}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          request.dateRange,
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
                          'Est. Earning: ${request.estEarning}',
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
                  onPressed: () {},
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text('Decline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StayCard extends StatelessWidget {
  const _StayCard({
    required this.petName,
    required this.dateRange,
    required this.statusLabel,
    required this.statusColor,
  });

  final String petName;
  final String dateRange;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
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
          ),
          const SizedBox(height: 6),
          Text(
            petName,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
              statusLabel,
              style: TextStyle(
                fontSize: 11,
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
