import 'package:flutter/material.dart';
import '../../models/sitter.dart';

class SitterDashboardScreen extends StatefulWidget {
  const SitterDashboardScreen({super.key});

  @override
  State<SitterDashboardScreen> createState() => _SitterDashboardScreenState();
}

class _SitterDashboardScreenState extends State<SitterDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sitter = ModalRoute.of(context)!.settings.arguments as Sitter?;
    final sitterName = sitter?.name ?? 'Sitter';

    // Mock data for new requests
    final newRequests = [
      {
        'petName': 'Max',
        'requestedBy': 'Bil',
        'dates': 'Oct 20 - Oct 25',
        'earnings': 'RM 300',
      },
      {
        'petName': 'Luna',
        'requestedBy': 'Sarah',
        'dates': 'Oct 22 - Oct 28',
        'earnings': 'RM 360',
      },
    ];

    // Mock data for calendar section (Current & Upcoming Stays)
    final stays = [
      {'petName': 'Simba', 'dates': 'Oct 10 - Oct 15', 'status': 'In Progress'},
      {'petName': 'Coco', 'dates': 'Oct 16 - Oct', 'status': 'Upcoming'},
    ];

    return Scaffold(
      body: _currentIndex == 0
          ? _buildDashboardView(sitterName, newRequests, stays)
          : _currentIndex == 1
          ? _buildCalendarView(stays)
          : _currentIndex == 2
          ? _buildInboxView()
          : _buildProfileView(sitter),
      //navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2ECC71),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Dashboard View
  Widget _buildDashboardView(
    String sitterName,
    List<Map<String, String>> newRequests,
    List<Map<String, String>> stays,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Text(
            'Welcome back, $sitterName',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // New Requests section
          const Text(
            'New Requests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: newRequests.length,
            itemBuilder: (context, index) {
              final req = newRequests[index];
              return _buildNewRequestCard(
                petName: req['petName']!,
                requestedBy: req['requestedBy']!,
                dates: req['dates']!,
                earnings: req['earnings']!,
              );
            },
          ),
          const SizedBox(height: 32),

          // Current & Upcoming Stays section
          const Text(
            'Current & Upcoming Stays',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stays.length,
              itemBuilder: (context, index) {
                final stay = stays[index];
                return _buildStayCard(
                  petName: stay['petName']!,
                  dates: stay['dates']!,
                  status: stay['status']!,
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          // Overview section
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.attach_money,
                  iconColor: const Color(0xFF2ECC71),
                  title: 'October Earnings',
                  value: 'RM 1,250',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.star,
                  iconColor: const Color(0xFFFFA500),
                  title: 'Your Rating',
                  value: '4.9',
                  withStarIcon: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCalendarNotificationCard(),
        ],
      ),
    );
  }

  // New Request Card
  Widget _buildNewRequestCard({
    required String petName,
    required String requestedBy,
    required String dates,
    required String earnings,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          // Pet avatar placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.pets, size: 40, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  petName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Requested by $requestedBy',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dates,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  earnings,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2ECC71),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Stay Card
  Widget _buildStayCard({
    required String petName,
    required String dates,
    required String status,
  }) {
    final isInProgress = status.toLowerCase() == 'in progress';
    final statusColor = isInProgress
        ? const Color(0xFF2ECC71)
        : const Color(0xFF748FFC);
    final bgColor = isInProgress
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFE3F2FD);

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet avatar placeholder
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.pets, size: 50, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            petName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                dates,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Overview Card
  Widget _buildOverviewCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    bool withStarIcon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (withStarIcon) ...[
                const SizedBox(width: 4),
                const Icon(Icons.star, color: Color(0xFFFFA500), size: 16),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Calendar Notification Card
  Widget _buildCalendarNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2ECC71).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Color(0xFF2ECC71),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keep your calendar updated to\nreceive the right requests.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Manage Availability',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Calendar View
  Widget _buildCalendarView(List<Map<String, String>> stays) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calendar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            padding: const EdgeInsets.all(16),
            child: const Center(child: Text('Calendar widget coming soon')),
          ),
        ],
      ),
    );
  }

  // Inbox View
  Widget _buildInboxView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inbox',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            padding: const EdgeInsets.all(16),
            child: const Center(child: Text('Inbox feature coming soon')),
          ),
        ],
      ),
    );
  }

  // Profile View
  Widget _buildProfileView(Sitter? sitter) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            padding: const EdgeInsets.all(16),
            child: Center(child: Text('Profile for ${sitter?.name ?? "User"}')),
          ),
        ],
      ),
    );
  }
}
