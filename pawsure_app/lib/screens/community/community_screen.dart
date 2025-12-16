import 'package:flutter/material.dart';
import 'find_sitter_tab.dart'; // Ensure this path is correct
// import 'feed_tab.dart'; // You will create this for the Feed content
import 'sitter_details.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  void _handleSitterClick(BuildContext context, String sitterId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to Sitter Profile: $sitterId'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF9FAFB),
          elevation: 0,
          toolbarHeight: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Community',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Search functionality
                          },
                          icon: const Icon(
                            Icons.search,
                            size: 20,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Notifications
                          },
                          icon: const Icon(
                            Icons.notifications_outlined,
                            size: 20,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: const Color(0xFF1F2937),
                  unselectedLabelColor: const Color(0xFF9CA3AF),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Feed'),
                    Tab(text: 'Find a Sitter'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  // Feed Tab
                  _FeedTab(),

                  // Find a Sitter Tab
                  FindSitterTab(
                    onSitterClick: (String sitterId) {
                      // This is the "Bridge" that connects the two files
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SitterDetailsScreen(sitterId: sitterId),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Sub-tabs for Feed
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FeedFilterChip(label: 'For You', isSelected: true),
              const SizedBox(width: 8),
              _FeedFilterChip(label: 'Following', isSelected: false),
              const SizedBox(width: 8),
              _FeedFilterChip(label: 'Nearby', isSelected: false),
              const SizedBox(width: 8),
              _FeedFilterChip(label: 'Topics', isSelected: false),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Sample Feed Posts
        _FeedPostCard(
          userName: 'Sarah M.',
          userAvatar: 'S',
          timeAgo: '2h ago',
          content:
              'Just got back from an amazing hike with Max! 🐕 He loved exploring the trails. Any recommendations for dog-friendly parks nearby?',
          likes: 24,
          comments: 8,
          petEmoji: '🐕',
        ),

        _FeedPostCard(
          userName: 'Mike T.',
          userAvatar: 'M',
          timeAgo: '5h ago',
          content:
              'Luna finally learned to shake hands! 🎉 So proud of her progress. Training tips really helped.',
          likes: 56,
          comments: 12,
          petEmoji: '🐈',
        ),

        _FeedPostCard(
          userName: 'Emma K.',
          userAvatar: 'E',
          timeAgo: '1d ago',
          content:
              'Looking for a reliable pet sitter for next weekend. Any recommendations in the downtown area?',
          likes: 8,
          comments: 15,
          petEmoji: '🐾',
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

class _FeedFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FeedFilterChip({
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF22C55E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFE5E7EB),
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF22C55E).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _FeedPostCard extends StatelessWidget {
  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String content;
  final int likes;
  final int comments;
  final String petEmoji;

  const _FeedPostCard({
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
    required this.petEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    userAvatar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          petEmoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_horiz,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF374151),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              _PostAction(
                icon: Icons.favorite_border,
                label: '$likes',
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(width: 24),
              _PostAction(
                icon: Icons.chat_bubble_outline,
                label: '$comments',
                color: const Color(0xFF3B82F6),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.bookmark_border,
                  color: Color(0xFF9CA3AF),
                  size: 22,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share_outlined,
                  color: Color(0xFF9CA3AF),
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PostAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
