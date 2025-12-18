import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sitter_dashboard.dart'; // Adjust path if needed
import 'chat_screen.dart'; 
import 'sitter_calendar.dart'; // Import SitterCalendar screen
import 'sitter_setting_screen.dart'; // Import SitterSettingPage screen
// --- Mock Data Models ---

// Renamed from SitterInbox to SitterInboxItem to avoid conflict with the Screen class
class SitterInboxItem {
  final int id;
  final String petName;
  final String ownerName;
  final String petType; // 'dog' or 'cat'
  final String startDate;
  final String endDate;
  final int estimatedEarnings;
  final String status;

  SitterInboxItem({
    required this.id,
    required this.petName,
    required this.ownerName,
    required this.petType,
    required this.startDate,
    required this.endDate,
    required this.estimatedEarnings,
    required this.status,
  });
}

class BookingConversation {
  final int id;
  final String ownerName;
  final String? ownerPhoto;
  final String petName;
  final String lastMessage;
  final String time;
  final String dates;
  final bool unread;

  BookingConversation({
    required this.id,
    required this.ownerName,
    this.ownerPhoto,
    required this.petName,
    required this.lastMessage,
    required this.time,
    required this.dates,
    required this.unread,
  });
}

// ✅ RENAMED CLASS TO MATCH DASHBOARD
class SitterInbox extends StatefulWidget {
  const SitterInbox({super.key});

  @override
  State<SitterInbox> createState() => _SitterInboxState();
}

class _SitterInboxState extends State<SitterInbox> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color _accentColor = const Color(0xFF1CCA5B);

  // Mock Data
  final List<SitterInboxItem> _newInbox = [
    SitterInboxItem(
      id: 1,
      petName: "Lucky",
      ownerName: "Bill",
      petType: "dog",
      startDate: "18 Oct 2025",
      endDate: "20 Oct 2025",
      estimatedEarnings: 50,
      status: "Pending",
    ),
    SitterInboxItem(
      id: 2,
      petName: "Coco",
      ownerName: "Sarah",
      petType: "cat",
      startDate: "19-20 Oct 2025",
      endDate: "20 Oct 2025",
      estimatedEarnings: 50,
      status: "Confirmed",
    ),
    SitterInboxItem(
      id: 3,
      petName: "Simba",
      ownerName: "Mike",
      petType: "cat",
      startDate: "12-13 Oct 2025",
      endDate: "13 Oct 2025",
      estimatedEarnings: 50,
      status: "Ongoing",
    ),
  ];

  final List<BookingConversation> _bookings = [
    BookingConversation(
      id: 3,
      ownerName: "John",
      petName: "Buddy",
      lastMessage: "Great! Looking forward to it. Here's Buddy's favorite toy.",
      time: "2h ago",
      dates: "Oct 15-18",
      unread: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openChat(String ownerName, String petName, String dates, bool isRequest) {
    Get.to(() => ChatScreen(
      ownerName: ownerName,
      petName: petName,
      dates: dates,
      isRequest: isRequest,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Inbox', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // No back button
        bottom: TabBar(
          controller: _tabController,
          labelColor: _accentColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _accentColor,
          tabs: const [
            Tab(text: "Requests"),
            Tab(text: "Bookings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Requests
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _newInbox.length,
            itemBuilder: (context, index) {
              return NewInboxCard(
                inbox: _newInbox[index],
                onTap: () => _openChat(
                  _newInbox[index].ownerName,
                  _newInbox[index].petName,
                  "${_newInbox[index].startDate} - ${_newInbox[index].endDate}",
                  true,
                ),
              );
            },
          ),

          // Tab 2: Bookings
          ListView.builder(
            itemCount: _bookings.length,
            itemBuilder: (context, index) {
              return ConversationCard(
                conversation: _bookings[index],
                onTap: () => _openChat(
                  _bookings[index].ownerName,
                  _bookings[index].petName,
                  _bookings[index].dates,
                  false,
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
            // Index 3 is Inbox
            Get.to(() => const SitterInbox());
          }
          if (index == 4) {
            Get.to(() => const SitterSettingScreen());
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Setting'),
        ],
      ),
    );
  }
}

// --- Component: New Request Card ---

class NewInboxCard extends StatelessWidget {
  final SitterInboxItem inbox; // Using the renamed data class
  final VoidCallback onTap;

  const NewInboxCard({super.key, required this.inbox, required this.onTap});

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
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  child: Icon(isDog ? Icons.pets : Icons.cruelty_free, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inbox.petName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Owner: ${inbox.ownerName}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: inbox.status == 'Pending' ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    inbox.status,
                    style: TextStyle(
                      color: inbox.status == 'Pending' ? Colors.orange : Colors.green,
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
                Text("${inbox.startDate} - ${inbox.endDate}", style: const TextStyle(fontSize: 13)),
                Text("Est: RM${inbox.estimatedEarnings}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1CCA5B))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Component: Conversation Card ---

class ConversationCard extends StatelessWidget {
  final BookingConversation conversation;
  final VoidCallback onTap;

  const ConversationCard({super.key, required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: conversation.ownerPhoto != null ? NetworkImage(conversation.ownerPhoto!) : null,
        child: conversation.ownerPhoto == null ? const Icon(Icons.person, color: Colors.grey) : null,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(conversation.ownerName, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(conversation.time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            "${conversation.petName} • ${conversation.dates}",
            style: TextStyle(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            conversation.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: conversation.unread ? Colors.black : Colors.grey.shade600,
              fontWeight: conversation.unread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}