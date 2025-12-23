import 'package:flutter/material.dart';
import 'find_sitter_tab.dart';
import 'post_card.dart';
import 'create_post_modal.dart';
import 'sitter_details.dart';

// --- Mock Data Structure ---
class Post {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String petName;
  final String image;
  final String caption;
  final String? location;
  int likes;
  final int comments;
  bool isLiked;
  final bool isLostPetAlert;
  final bool isUrgentAlert;
  final Map<String, String>? lostPetDetails;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.petName,
    required this.image,
    required this.caption,
    this.location,
    required this.likes,
    required this.comments,
    required this.isLiked,
    this.isLostPetAlert = false,
    this.isUrgentAlert = false,
    this.lostPetDetails,
  });
}

// --- Main Screen Widget (Stateful) ---
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Retained the mock data
  List<Post> _posts = [
    Post(
      id: "1",
      userId: "user1",
      userName: "Sarah Johnson",
      userAvatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah",
      petName: "Luna",
      image:
          "https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400",
      caption:
          "Luna enjoying her morning walk at the park! 🌞 She absolutely loves the fresh air.",
      location: "Taman Merdeka Park, Johor Bahru",
      likes: 24,
      comments: 5,
      isLiked: false,
    ),
    Post(
      id: "2",
      userId: "user2",
      userName: "Michael Chen",
      userAvatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Michael",
      petName: "Max",
      image:
          "https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400",
      caption:
          "URGENT: Max needs an emergency blood donation (Type A-). Please contact me if your dog is eligible!",
      location: "Mount Austin Vet Clinic",
      likes: 18,
      comments: 3,
      isLiked: true,
      isUrgentAlert: true,
    ),
    Post(
      id: "3",
      userId: "user3",
      userName: "Emily Rodriguez",
      userAvatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Emily",
      petName: "Bella",
      image:
          "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400",
      caption:
          "URGENT: Bella went missing this morning near Permas Jaya. Please help us find her!",
      location: "Permas Jaya, Johor Bahru",
      likes: 156,
      comments: 42,
      isLiked: false,
      isLostPetAlert: true,
      isUrgentAlert: true,
      lostPetDetails: {
        "lastSeenLocation": "Permas Jaya Mall parking area",
        "lastSeenTime": "Today, 8:30 AM",
        "contactInfo": "+60 12-345 6789",
      },
    ),
    Post(
      id: "4",
      userId: "user4",
      userName: "David Lim",
      userAvatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=David",
      petName: "Charlie",
      image: "https://images.unsplash.com/photo-1558788353-f76d92427f16?w=400",
      caption: "Sleepy Sunday vibes 😴 Charlie has been napping all day!",
      likes: 32,
      comments: 8,
      isLiked: false,
    ),
  ];

  List<Post> _getFilteredPosts(String feedTab) {
    if (feedTab == "urgent") {
      return _posts
          .where((post) => post.isUrgentAlert || post.isLostPetAlert)
          .toList();
    }

    if (feedTab == "nearby") {
      List<Post> sortedPosts = [..._posts];
      sortedPosts.sort((a, b) {
        if (a.isLostPetAlert && !b.isLostPetAlert) return -1;
        if (!a.isLostPetAlert && b.isLostPetAlert) return 1;
        return 0;
      });
      return sortedPosts;
    }

    return _posts;
  }

  void _handleLike(String postId) {
    setState(() {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        Post post = _posts[postIndex];
        post.isLiked = !post.isLiked;
        post.likes += post.isLiked ? 1 : -1;
      }
    });
  }

  void _handleComment(String postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment feature coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleShare(String postId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post shared successfully!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handlePostCreated() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Success! Your post has been created'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CreatePostModal(onPostCreated: _handlePostCreated);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Only two tabs: Feed and Find a Sitter
      child: Builder(
        builder: (BuildContext innerContext) {
          final TabController tabController = DefaultTabController.of(
            innerContext,
          );

          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate([
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                            child: Text(
                              'Community',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ]),
                      ),
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        pinned: true,
                        toolbarHeight: 0,
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(50.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: TabBar(
                              indicatorSize: TabBarIndicatorSize.label,
                              indicatorWeight: 3.0,
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor: Colors.grey.shade600,
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: 'Feed'),
                                Tab(text: 'Find a Sitter'),
                              ],
                              onTap: (index) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
              body: TabBarView(
                // We only need 2 children here, matching the length of the TabBar.
                children: [
                  // 1. Feed Tab Content
                  FeedTabView(parentState: this),

                  // 2. Find a Sitter Tab Content (Corrected and implemented)
                  FindSitterTab(
                    onSitterClick:
                        (
                          String sitterId,
                          DateTime? startDate,
                          DateTime? endDate,
                        ) {
                          print(
                            "Navigating to Sitter Profile: $sitterId",
                          ); // Retained for debug
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SitterDetailsScreen(
                                sitterId: sitterId,
                                startDate: startDate,
                                endDate: endDate,
                              ),
                            ),
                          );
                        },
                  ),
                ],
              ),
            ),
            floatingActionButton:
                DefaultTabController.of(innerContext).index == 0
                ? FloatingActionButton(
                    onPressed: _showCreatePostModal,
                    backgroundColor: Theme.of(innerContext).primaryColor,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add),
                  )
                : null,
          );
        },
      ),
    );
  }
}

// --- Feed Tab View ---
class FeedTabView extends StatelessWidget {
  final _CommunityScreenState parentState;

  const FeedTabView({super.key, required this.parentState});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3.0,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey.shade600,
            dividerColor: Colors.grey.shade300,
            tabs: const [
              Tab(text: 'For You'),
              Tab(text: 'Urgent 🚨'),
              Tab(text: 'Nearby'),
              Tab(text: 'Topics'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPostList(context, 'for-you'),
                _buildPostList(context, 'urgent'),
                _buildPostList(context, 'nearby'),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Discover posts by topics like #TrainingTips, #HealthQ&A, #ParkMeetups',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Coming soon!',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList(BuildContext context, String tabValue) {
    final posts = parentState._getFilteredPosts(tabValue);

    if (posts.isEmpty && tabValue == 'urgent') {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No urgent alerts right now. Stay safe!',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: PostCard(
            post: post,
            onLike: parentState._handleLike,
            onComment: parentState._handleComment,
            onShare: parentState._handleShare,
          ),
        );
      },
    );
  }
}
