import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/models/post_model.dart';
import 'dart:convert';
import 'post_card.dart';
import 'create_post_modal.dart';
import 'find_sitter_tab.dart';
import 'sitter_details.dart';
import 'vacancy_post_card.dart';

// --- POST MODEL ---
class Post {
  final String id;
  final String userId;
  final String userName;
  final String profilePicture;
  final String content;
  final List<String> mediaUrls;
  final String? location;
  final DateTime createdAt;
  int likes;
  bool isLiked;
  final bool isUrgent;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.profilePicture,
    required this.content,
    required this.mediaUrls,
    this.location,
    required this.createdAt,
    this.likes = 0,
    this.isLiked = false,
    this.isUrgent = false,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    final userData = map['user'] ?? map['owner'];
    final List<dynamic> mediaList = map['post_media'] ?? [];

    return Post(
      id: map['id'].toString(),
      userId:
          (map['userId'] ?? map['user_id'] ?? userData?['id'])?.toString() ??
          '',
      userName: userData?['name'] ?? 'Unknown User',
      profilePicture:
          userData?['profile_picture'] ??
          "https://cdn-icons-png.flaticon.com/512/194/194279.png",
      content: map['content'] ?? '',
      mediaUrls: mediaList
          .map(
            (m) => (m is String)
                ? m
                : (m['url'] ?? m['media_url'] ?? '').toString(),
          )
          .where((url) => url.isNotEmpty)
          .toList()
          .cast<String>(),
      location: map['location_name'] ?? map['location'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      isUrgent: map['is_urgent'] ?? false,
      likes: map['likes_count'] ?? 0,
    );
  }
}

// --- COMMUNITY SCREEN ---
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => CommunityScreenState(); // Removed underscore to allow access
}

class CommunityScreenState extends State<CommunityScreen> {
  final String baseUrl = "http://localhost:3000";
  int _currentSubTabIndex = 0; // 0: For You, 1: Urgent, 2: Vacancy

  // Change Post to PostModel here
  Future<List<PostModel>> fetchFilteredPosts(String tab) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts?tab=$tab'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        // Ensure you are using PostModel.fromJson here
        return data.map((map) => PostModel.fromJson(map)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      debugPrint("Error fetching posts: $e");
      return [];
    }
  }

  void _handlePostCreated() {
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post created successfully!')));
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        // Logic for different forms
        if (_currentSubTabIndex == 2) {
          // Placeholder for your Sitter Vacancy Form
          return Container(
            padding: const EdgeInsets.all(24),
            height: MediaQuery.of(context).size.height * 0.8,
            child: const Center(child: Text("Sitter Vacancy Form Coming Soon")),
          );
        } else {
          return CreatePostModal(onPostCreated: _handlePostCreated);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Community',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline),
                            onPressed: () => debugPrint("Navigate to Chat"),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 0,
                  bottom: TabBar(
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Theme.of(context).primaryColor,
                    tabs: const [
                      Tab(text: 'Feed'),
                      Tab(text: 'Find a Sitter'),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                FeedTabView(
                  parentState: this,
                  onSubTabChanged: (index) {
                    setState(() {
                      _currentSubTabIndex = index;
                    });
                  },
                ),
                FindSitterTab(
                  onSitterClick: (sitterId, startDate, endDate) {
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
        ),
        floatingActionButton: Builder(
          builder: (context) {
            bool isFeedTab = DefaultTabController.of(context).index == 0;
            return isFeedTab
                ? FloatingActionButton(
                    onPressed: _showCreatePostModal,
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.add),
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// --- FEED TAB VIEW ---
class FeedTabView extends StatefulWidget {
  final CommunityScreenState parentState; // Changed type to public version
  final Function(int) onSubTabChanged;

  const FeedTabView({
    super.key,
    required this.parentState,
    required this.onSubTabChanged,
  });

  @override
  State<FeedTabView> createState() => _FeedTabViewState();
}

class _FeedTabViewState extends State<FeedTabView>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 3, vsync: this);
    _subTabController.addListener(() {
      if (!_subTabController.indexIsChanging) {
        widget.onSubTabChanged(_subTabController.index);
      }
    });
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _subTabController,
          isScrollable: true,
          labelColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'For You'),
            Tab(text: 'Urgent 🚨'),
            Tab(text: 'Sitter Vacancy'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildDynamicPostList('for-you'),
              _buildDynamicPostList('urgent'),
              _buildDynamicPostList('vacancy'),
            ],
          ),
        ),
      ],
    );
  }

  // 1. PLACE THE METHOD HERE
  void _handleBooking(PostModel post) async {
    // Show a confirmation dialog before proceeding
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Apply for Job"),
        content: Text(
          "Are you sure you want to apply to pet sit for ${post.userName}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Apply"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Execute the logic to save to the 'bookings' table
      debugPrint("Booking confirmed for Post ID: ${post.id}");
      // Add your http.post logic here
    }
  }

  Widget _buildDynamicPostList(String tab) {
    return FutureBuilder<List<PostModel>>(
      // 1. Use updated PostModel type
      future: widget.parentState.fetchFilteredPosts(tab),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No posts found.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final posts = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => widget.parentState.setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              // IF WE ARE IN THE VACANCY TAB
              if (tab == 'vacancy') {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: VacancyPostCard(
                    post: post,
                    onApply: () =>
                        _handleBooking(post), // Passes post to booking handler
                  ),
                );
              }

              // IF WE ARE IN 'FOR YOU' OR 'URGENT'
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: PostCard(
                  post: post,
                  onLike: (id) {},
                  onComment: (id) {},
                  onShare: (id) {},
                ),
              );
            }, // Fixed closing brace for itemBuilder
          ),
        );
      },
    );
  }
}
