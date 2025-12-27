import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'post_card.dart';
import 'create_post_modal.dart';
import 'find_sitter_tab.dart';
import 'sitter_details.dart'; // Ensure this is imported for navigation

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
    // 1. Handle User Data (Logs show 'user' key, not 'owner')
    final userData = map['user'] ?? map['owner'];

    // 2. Handle Media (Logs show 'post_media' as an empty list [])
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

      // 3. Robust Media Mapping
      mediaUrls: mediaList
          .map((m) {
            if (m is String) return m;
            // Check for 'url' or 'media_url' (Common in NestJS/Prisma setups)
            return (m['url'] ?? m['media_url'] ?? '').toString();
          })
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

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final String baseUrl = "http://localhost:3000/posts";

  Future<List<Post>> _fetchFilteredPosts(String tab) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/community?tab=$tab'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((map) => Post.fromMap(map)).toList();
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
      builder: (context) => CreatePostModal(onPostCreated: _handlePostCreated),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
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
              FeedTabView(parentState: this),
              // ✅ FIXED: Added the required onSitterClick argument
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
        floatingActionButton: Builder(
          builder: (context) {
            return DefaultTabController.of(context).index == 0
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

class FeedTabView extends StatelessWidget {
  final _CommunityScreenState parentState;
  const FeedTabView({super.key, required this.parentState});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'For You'),
              Tab(text: 'Urgent 🚨'),
              Tab(text: 'Nearby'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDynamicPostList('for-you'),
                _buildDynamicPostList('urgent'),
                _buildDynamicPostList('nearby'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicPostList(String tab) {
    return FutureBuilder<List<Post>>(
      key: ValueKey(tab + DateTime.now().millisecondsSinceEpoch.toString()),
      future: parentState._fetchFilteredPosts(tab),
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
          onRefresh: () async => parentState.setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: posts.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: PostCard(
                post: posts[index],
                onLike: (id) {},
                onComment: (id) {},
                onShare: (id) {},
              ),
            ),
          ),
        );
      },
    );
  }
}
