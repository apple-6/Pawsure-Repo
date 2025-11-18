import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/community_controller.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CommunityController controller = Get.find<CommunityController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Community'),
        backgroundColor: Colors.purple[100],
      ),
      body: Obx(() {
        final posts = controller.posts;
        if (posts.isEmpty) {
          return const Center(child: Text('No posts yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final p = posts[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(p['content'] ?? ''),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${p['likes']} likes • ${p['comments']} comments',
                            style: const TextStyle(color: Colors.grey)),
                        IconButton(
                          icon: const Icon(Icons.thumb_up_alt_outlined),
                          onPressed: () =>
                              controller.likePost(p['id'] as String),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // TODO: Replace with a create-post dialog and CommunityService.addPost
          final payload = {
            'userId': 'u1',
            'title': 'New post',
            'content': 'Hello from Pawsure (placeholder)'
          };
          await controller.addPost(payload);
          Get.snackbar('Posted', 'Your post was added (placeholder)');
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
