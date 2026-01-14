import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/models/post_model.dart';
import 'package:pawsure_app/screens/community/create_vacancy_modal.dart';
import 'package:pawsure_app/screens/sitter_setup/chat_screen.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'post_card.dart';
import 'create_post_modal.dart';
import 'find_sitter_tab.dart';
import 'sitter_details.dart';
import 'vacancy_post_card.dart';
import 'owner_inbox.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/screens/sitter_setup/sitter_dashboard.dart';
import 'package:pawsure_app/screens/sitter_setup/sitter_calendar.dart';
import 'package:pawsure_app/screens/sitter_setup/sitter_inbox.dart';
import 'package:pawsure_app/screens/sitter_setup/sitter_setting_screen.dart';
import 'package:pawsure_app/constants/api_config.dart';

// --- POST MODEL (Left as provided) ---
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

    String rawAvatar = userData?['profile_picture'] ?? '';
    String finalAvatarUrl;

    if (rawAvatar.isNotEmpty) {
      if (rawAvatar.startsWith('http')) {
        finalAvatarUrl = rawAvatar;
      } else {
        finalAvatarUrl = '${ApiConfig.baseUrl}/$rawAvatar';
      }
    } else {
      finalAvatarUrl = "https://cdn-icons-png.flaticon.com/512/194/194279.png";
    }

    return Post(
      id: map['id'].toString(),
      userId:
          (map['userId'] ?? map['user_id'] ?? userData?['id'])?.toString() ??
          '',
      userName: userData?['name'] ?? 'Unknown User',
      profilePicture: finalAvatarUrl,
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
  State<CommunityScreen> createState() => CommunityScreenState();
}

class CommunityScreenState extends State<CommunityScreen> {
  final ApiService _apiService = ApiService();
  int _currentSubTabIndex = 0;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    try {
      final authService = Get.find<AuthService>();
      final role = await authService.getUserRole();
      if (mounted) {
        setState(() {
          _userRole = role;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching user role: $e");
    }
  }

  Future<List<PostModel>> fetchFilteredPosts(String tab) async {
    try {
      final List<dynamic> data = await _apiService.getPosts(tab: tab);
      return data.map((map) => PostModel.fromJson(map)).toList();
    } catch (e) {
      debugPrint("Error fetching posts: $e");
      return [];
    }
  }

  void _handlePostCreated() {
    setState(() {}); // This triggers a rebuild to refresh the list
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post created successfully!')));
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        if (_currentSubTabIndex == 2) {
          return CreateVacancyModal(onVacancyCreated: _handlePostCreated);
        } else {
          return CreatePostModal(onPostCreated: _handlePostCreated);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int tabCount = _userRole == 'sitter' ? 1 : 2;

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        backgroundColor: Colors.white,
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
                          _userRole == 'owner'
                              ? IconButton(
                                  icon: const Icon(Icons.chat_bubble_outline),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OwnerInbox(),
                                      ),
                                    );
                                  },
                                )
                              : const SizedBox.shrink(),
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
                    tabs: _userRole == 'sitter'
                        ? const [Tab(text: 'Feed')]
                        : const [Tab(text: 'Feed'), Tab(text: 'Find a Sitter')],
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: _userRole == 'sitter'
                  ? [
                      FeedTabView(
                        parentState: this,
                        onSubTabChanged: (index) {
                          setState(() => _currentSubTabIndex = index);
                        },
                      ),
                    ]
                  : [
                      FeedTabView(
                        parentState: this,
                        onSubTabChanged: (index) {
                          setState(() => _currentSubTabIndex = index);
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
            final TabController? tabController = DefaultTabController.of(
              context,
            );
            if (tabController == null) return const SizedBox.shrink();

            return AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                final bool isFeedTab = tabController.index == 0;
                return isFeedTab
                    ? FloatingActionButton(
                        onPressed: _showCreatePostModal,
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.add),
                      )
                    : const SizedBox.shrink();
              },
            );
          },
        ),
        bottomNavigationBar: _userRole == 'sitter'
            ? BottomNavigationBar(
                currentIndex: 1,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color(0xFF2ECA6A),
                unselectedItemColor: Colors.grey.shade600,
                onTap: (index) {
                  if (index == 0) Get.offAll(() => const SitterDashboard());
                  if (index == 1) Get.offAll(() => const CommunityScreen());
                  if (index == 2) Get.to(() => const SitterCalendar());
                  if (index == 3) Get.to(() => const SitterInbox());
                  if (index == 4) Get.to(() => const SitterSettingScreen());
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_filled),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people),
                    label: 'Community',
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
              )
            : null,
      ),
    );
  }
}

// --- FEED TAB VIEW ---
class FeedTabView extends StatefulWidget {
  final CommunityScreenState parentState;
  final Function(int) onSubTabChanged;

  const FeedTabView({
    super.key,
    required this.parentState,
    required this.onSubTabChanged,
  });

  @override
  State<FeedTabView> createState() => _FeedTabViewState();
}

// ✅ FIXED: Added AutomaticKeepAliveClientMixin to prevent Tabs from reloading
class _FeedTabViewState extends State<FeedTabView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _subTabController;

  @override
  bool get wantKeepAlive => true; // ✅ Keeps this widget alive in memory

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
    super.build(context); // ✅ Required for KeepAlive

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            child: TabBar(
              controller: _subTabController,
              isScrollable: false,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.label,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              tabs: const [
                Tab(text: 'For You'),
                Tab(text: 'Urgent 🚨'),
                Tab(text: 'Vacancy'),
              ],
            ),
          ),
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

  Future<void> _deletePost(PostModel post) async {
    bool confirm =
        await Get.dialog(
          AlertDialog(
            title: const Text("Delete Post?"),
            content: const Text("Are you sure you want to remove this?"),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      final authService = Get.find<AuthService>();
      final token = await authService.getToken();
      final String baseUrl = ApiConfig.baseUrl;

      final response = await http.delete(
        Uri.parse('$baseUrl/posts/${post.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar(
          "Success",
          "Post deleted",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        widget.parentState.setState(() {});
      } else {
        Get.snackbar("Error", "Failed to delete post");
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed");
    }
  }

  void _editStandardPost(PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CreatePostModal(
          onPostCreated: () => widget.parentState.setState(() {}),
          postToEdit: post,
        );
      },
    );
  }

  void _handleChat(PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          ownerName: post.userName,
          petName: post.petNames.join(", "),
          dates:
              "${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}",
          isRequest: false,
          room: 'booking-${post.id}',
          currentUserId: int.tryParse(post.userId.toString()) ?? 0,
          bookingId: int.tryParse(post.id.toString()) ?? 0,
        ),
      ),
    );
  }

  Widget _buildDynamicPostList(String tab) {
    final authService = Get.find<AuthService>();

    return FutureBuilder<List<PostModel>>(
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

        return FutureBuilder<Map<String, dynamic>>(
          future: Future.wait([
            authService.getUserRole(),
            authService.getUserId(),
          ]).then((values) => {'role': values[0], 'id': values[1]}),
          builder: (context, authSnapshot) {
            if (!authSnapshot.hasData) return const SizedBox();

            final String? currentUserRole = authSnapshot.data!['role'];
            final String? currentUserId = authSnapshot.data!['id']?.toString();
            final bool isSitter = currentUserRole == 'sitter';

            return RefreshIndicator(
              onRefresh: () async => widget.parentState.setState(() {}),
              child: ListView.builder(
                // ✅ FIXED: Increase cache extent to load images before they scroll into view
                cacheExtent: 2000.0,
                // ✅ FIXED: Add RepaintBoundary for performance
                addRepaintBoundaries: true,
                padding: const EdgeInsets.all(16.0),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final bool isMyPost =
                      currentUserId != null &&
                      currentUserId == post.userId.toString();
                  final bool canManagePost = !isSitter && isMyPost;

                  if (tab == 'vacancy') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: VacancyPostCard(
                        post: post,
                        isUserSitter: isSitter,
                        showMenuOptions: canManagePost,
                        onApply: () => _handleChat(post),
                        onDelete: (p) => _deletePost(p),
                        onEdit: (p) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => CreateVacancyModal(
                              postToEdit: p,
                              onVacancyCreated: () =>
                                  widget.parentState.setState(() {}),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: PostCard(
                      post: post,
                      onLike: (id) => _handleLike(id),
                      onComment: (id) {},
                      onDelete: canManagePost ? () => _deletePost(post) : null,
                      onEdit: canManagePost
                          ? () => _editStandardPost(post)
                          : null,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _handleLike(String postId) async {
    try {
      final apiService = ApiService();
      await apiService.toggleLike(postId);
    } catch (e) {
      debugPrint("Error liking post: $e");
    }
  }
}
