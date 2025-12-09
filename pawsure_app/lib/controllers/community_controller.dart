import 'package:get/get.dart';

class CommunityController extends GetxController {
  // Placeholder posts list. Replace with CommunityService API calls.
  var posts = <Map<String, dynamic>>[
    {
      'id': 'p1',
      'userId': 'u1',
      'title': 'Pawsome walk today',
      'content': 'Max loved the park! Highly recommend the new trail.',
      'likes': 5,
      'comments': 2,
    }
  ].obs;

  Future<void> loadPosts() async {
    // TODO: Replace with CommunityService.getAllPosts()
    await Future.delayed(const Duration(milliseconds: 200));
    // posts are already populated as placeholders
  }

  Future<void> addPost(Map<String, dynamic> payload) async {
    // TODO: Replace with CommunityService.addPost(...) call
    final newPost = Map<String, dynamic>.from(payload);
    newPost['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    newPost['likes'] = 0;
    newPost['comments'] = 0;
    posts.insert(0, newPost);
  }

  Future<void> likePost(String postId) async {
    // TODO: Replace with CommunityService.likePost(postId)
    final idx = posts.indexWhere((p) => p['id'] == postId);
    if (idx >= 0) {
      posts[idx]['likes'] = (posts[idx]['likes'] ?? 0) + 1;
      posts.refresh();
    }
  }
}
