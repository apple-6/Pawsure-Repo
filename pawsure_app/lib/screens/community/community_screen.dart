import 'package:flutter/material.dart';
// Ensure these files exist in your project:
// import 'find_sitter_tab.dart'; 
// import 'post_card.dart'; 
// import 'create_post_modal.dart'; 

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
  // Mock posts data
  List<Post> _posts = [
    Post(
      id: "1",
      userId: "user1",
      userName: "Sarah Johnson",
      userAvatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah",
      petName: "Luna",
      image: "https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400",
      caption: "Luna enjoying her morning walk at the park! 🌞 She absolutely loves the fresh air.",
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
      image: "https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400",
      caption: "URGENT: Max needs an emergency blood donation (Type A-). Please contact me if your dog is eligible!",
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
      image: "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400",
      caption: "URGENT: Bella went missing this morning near Permas Jaya. Please help us find her!",
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

  void _handleSitterClick(String sitterId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to Sitter Profile: $sitterId'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  List<Post> _getFilteredPosts(String feedTab) {
    if (feedTab == "urgent") {
      return _posts.where((post) => post.isUrgentAlert || post.isLostPetAlert).toList();
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
        // You must implement CreatePostModal
        // return CreatePostModal(onPostCreated: _handlePostCreated);
        return Container(height: 300, color: Colors.white, child: Center(child: Text("CreatePostModal Placeholder")));
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Outer DefaultTabController for 'Feed' / 'Find a Sitter'
    return DefaultTabController(
      length: 2, // Main tabs
      // FIX 1: Use Builder to get a context that is a descendant of DefaultTabController
      child: Builder(
        builder: (BuildContext innerContext) {
          final TabController tabController = DefaultTabController.of(innerContext);
          
          return Scaffold(
            // FIX 2: Prevents bottom overflow caused by system navigation bar
            extendBody: true,
            
            body: SafeArea( // Ensures body respects system boundaries
              top: false, // Allows SliverAppBar to utilize the top padding
              child: NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    // Header Title
                    SliverList(
                      delegate: SliverChildListDelegate([
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                          child: Text(
                            'Community',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]),
                    ),
                    // Sticky Tab Bar
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      pinned: true,
                      toolbarHeight: 0,
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(48.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
                            ),
                          ),
                          child: TabBar(
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorWeight: 3.0,
                            labelColor: Theme.of(context).primaryColor,
                            unselectedLabelColor: Colors.grey.shade600,
                            dividerColor: Colors.grey.shade300,
                            tabs: const [
                              Tab(text: 'Feed'),
                              Tab(text: 'Find a Sitter'),
                            ],
                            onTap: (index) {
                              // Force update FAB visibility
                              setState(() {}); 
                            },
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                // Body contains the TabBarView for the main tabs
                body: TabBarView(
                  children: [
                    // 1. Feed Tab Content
                    const FeedTabView(),

                    // 2. Find a Sitter Tab Content
                    // You must implement FindSitterTab
                    // FindSitterTab(onSitterClick: _handleSitterClick),
                    const Center(child: Text('FindSitterTab Placeholder')),
                  ],
                ),
              ),
            ),

            // Floating Action Button (FAB)
            floatingActionButton: tabController.index == 0 
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

// --- Feed Tab View (for the nested tabs) ---

class FeedTabView extends StatelessWidget {
  const FeedTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the state object from the ancestor
    final _CommunityScreenState? parentState = context.findAncestorStateOfType<_CommunityScreenState>();
    
    // DefaultTabController for the Feed Sub-tabs
    return DefaultTabController(
      length: 4, // Sub-tabs: For You, Urgent, Nearby, Topics
      child: Column(
        children: [
          // Feed Sub-tabs Bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
            ),
            child: const TabBar(
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3.0,
              labelColor: Color(0xFF4CAF50), // Green/Primary color
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: 'For You'),
                Tab(text: 'Urgent 🚨'), // The new tab
                Tab(text: 'Nearby'),
                Tab(text: 'Topics'),
              ],
            ),
          ),

          // Tab Content Area (Expanded ensures TabBarView takes remaining space)
          Expanded(
            child: TabBarView(
              children: [
                // 1. For You Tab Content
                _buildPostList(context, 'for-you', parentState),

                // 2. Urgent Tab Content
                _buildPostList(context, 'urgent', parentState),

                // 3. Nearby Tab Content
                _buildPostList(context, 'nearby', parentState),

                // 4. Topics Tab Content (Placeholder)
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

  Widget _buildPostList(BuildContext context, String tabValue, _CommunityScreenState? parentState) {
    if (parentState == null) {
      return const Center(child: Text("Error: State not found"));
    }
    
    final posts = parentState._getFilteredPosts(tabValue);

    if (posts.isEmpty && tabValue == 'urgent') {
        return const Center(
            child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No urgent alerts right now. Stay safe!', style: TextStyle(color: Colors.grey)),
            ),
        );
    }

    return ListView.builder(
      // FIX 3: Explicitly set scroll constraints for nested scrollables (fixes the 2.0px overflow)
      primary: false, 
      shrinkWrap: true,

      padding: const EdgeInsets.all(16.0),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        // You must implement PostCard
        // return Padding(
        //   padding: const EdgeInsets.only(bottom: 16.0),
        //   child: PostCard(
        //     post: post,
        //     onLike: parentState._handleLike,
        //     onComment: parentState._handleComment,
        //     onShare: parentState._handleShare,
        //   ),
        // );
        return const ListTile(title: Text("PostCard Placeholder"), subtitle: Text("Implemented in post_card.dart"));
      },
    );
  }
}