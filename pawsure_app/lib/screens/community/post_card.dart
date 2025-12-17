import 'package:flutter/material.dart';
import 'community_screen.dart'; // Import Post model

class PostCard extends StatelessWidget {
  final Post post;
  final Function(String) onLike;
  final Function(String) onComment;
  final Function(String) onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(post.userAvatar)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (post.location != null)
                      Text(
                        post.location!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Post Image
          Image.network(
            post.image,
            fit: BoxFit.cover,
            height: 250,
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              height: 250,
              child: Center(child: Text('Image Load Error')),
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(post.caption),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: post.isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => onLike(post.id),
                    ),
                    Text('${post.likes}'),
                    IconButton(
                      icon: const Icon(
                        Icons.comment_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () => onComment(post.id),
                    ),
                    Text('${post.comments}'),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.grey),
                  onPressed: () => onShare(post.id),
                ),
              ],
            ),
          ),
          if (post.isLostPetAlert)
            Container(
              color: Colors.orange.shade100,
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🚨 Lost Pet Alert',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  Text(
                    'Last Seen: ${post.lostPetDetails!['lastSeenLocation']} at ${post.lostPetDetails!['lastSeenTime']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Contact: ${post.lostPetDetails!['contactInfo']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
