import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pawsure_app/models/post_model.dart';
import 'package:pawsure_app/screens/community/comment_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final Function(String) onLike;
  final Function(String) onComment;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _currentMediaIndex = 0;

  late bool _isLiked;
  late int _likesCount;
  late int _commentsCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likes;
    _commentsCount = widget.post.commentsCount ?? 0;
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the post object passed from the parent changes (e.g. after a refresh or edit),
    // we need to sync our local state variables with the new data.
    if (widget.post != oldWidget.post) {
      setState(() {
        _isLiked = widget.post.isLiked;
        _likesCount = widget.post.likes;
        _commentsCount = widget.post.commentsCount ?? 0;
      });
    }
  }

  void _handleLikePress() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    widget.onLike(widget.post.id);
  }

  void _handleCommentPress() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentModal(
        postId: widget.post.id,
        // 🆕 Pass a callback that increments BOTH the model and the UI
        onCommentPosted: () {
          // 1. Update the Memory Model (This makes it persist like Likes)
          widget.post.commentsCount++;

          // 2. Update the Local UI
          setState(() {
            _commentsCount = widget.post.commentsCount;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- User Header ---
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.post.profilePicture),
              backgroundColor: Colors.grey[200],
            ),
            title: Text(
              widget.post.userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: widget.post.location != null
                ? Text(widget.post.location!)
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.post.isUrgent)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Badge(
                      label: Text('URGENT'),
                      backgroundColor: Colors.red,
                    ),
                  ),
                if (widget.onDelete != null || widget.onEdit != null)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') widget.onEdit?.call();
                      if (value == 'delete') widget.onDelete?.call();
                    },
                    itemBuilder: (context) => [
                      if (widget.onEdit != null)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                      if (widget.onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),

          // --- Media Carousel ---
          if (widget.post.mediaUrls.isNotEmpty)
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() => _currentMediaIndex = index);
                    },
                  ),
                  items: widget.post.mediaUrls.map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(Icons.broken_image, size: 50),
                              ),
                        );
                      },
                    );
                  }).toList(),
                ),
                if (widget.post.mediaUrls.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widget.post.mediaUrls.asMap().entries.map((
                        entry,
                      ) {
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(
                              _currentMediaIndex == entry.key ? 0.9 : 0.4,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),

          // --- Content ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.post.content,
              style: const TextStyle(fontSize: 15),
            ),
          ),

          // --- Actions Row (Like/Comment) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                // 1. Like Button (Removed Flexible)
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: _handleLikePress,
                  // Ensure touch target is big enough
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                Text('$_likesCount'),
                const SizedBox(width: 16),

                // 2. Comment Button (Removed Flexible)
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    size: 22,
                    color: Colors.grey,
                  ),
                  onPressed: _handleCommentPress,
                  // Ensure touch target is big enough
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                const SizedBox(width: 4),
                Text('$_commentsCount'),

                const Spacer(), // Pushes everything to the left
              ],
            ),
          ),
        ],
      ),
    );
  }
}
