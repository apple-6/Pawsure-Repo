import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart'; // 🆕 Import carousel
import 'package:pawsure_app/models/post_model.dart';
import 'community_screen.dart';
import 'package:pawsure_app/screens/community/comment_model.dart';

class PostCard extends StatefulWidget {
  // 🆕 Changed to StatefulWidget for index tracking
  final PostModel post;
  final Function(String) onLike;
  final Function(String) onComment;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _currentMediaIndex = 0; // Tracks which image is being viewed

  // Local state for optimistic updates
  late bool _isLiked;
  late int _likesCount;
  late int _commentsCount;
  bool _isLikeAnimating = false; // Prevent spamming

  @override
  void initState() {
    super.initState();
    // Initialize local state from the passed model
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likes;
    _commentsCount = widget.post.commentsCount;
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

  // Handle the logic internally in the card for instant feedback
  // 1. UPDATE THIS METHOD
  void _handleLikePress() async {
    if (_isLikeAnimating) return;

    // --- KEY FIX: Update the Source Model directly ---
    // This ensures that when ListView rebuilds this widget,
    // it reads the updated values from the memory object.
    widget.post.isLiked = !widget.post.isLiked;
    widget.post.likes = widget.post.isLiked
        ? widget.post.likes + 1
        : widget.post.likes - 1;

    // Update Local UI state to reflect changes immediately
    setState(() {
      _isLiked = widget.post.isLiked;
      _likesCount = widget.post.likes;
      _isLikeAnimating = true;
    });

    try {
      // Call Parent/API
      await widget.onLike(widget.post.id);
    } catch (e) {
      // Revert if API fails
      if (mounted) {
        // Revert model
        widget.post.isLiked = !widget.post.isLiked;
        widget.post.likes = widget.post.isLiked
            ? widget.post.likes + 1
            : widget.post.likes - 1;

        // Revert UI
        setState(() {
          _isLiked = widget.post.isLiked;
          _likesCount = widget.post.likes;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to update like")));
      }
    } finally {
      if (mounted) setState(() => _isLikeAnimating = false);
    }
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
            trailing: widget.post.isUrgent
                ? const Badge(
                    label: Text('URGENT'),
                    backgroundColor: Colors.red,
                  )
                : null,
          ),

          // --- Media Carousel ---
          if (widget.post.mediaUrls.isNotEmpty)
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 1.0, // Full width
                    enableInfiniteScroll: false, // Don't loop if only 1 image
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
                // Indicator Dots (Only show if more than 1 image)
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

          // --- Content & Actions ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.post.content,
              style: const TextStyle(fontSize: 15),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                // ✅ FIXED: Wrap in Flexible to prevent overflow
                Flexible(
                  child: IconButton(
                    icon: Icon(
                      //widget.post.isLiked
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.grey,
                    ),
                    onPressed: _handleLikePress,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ),
                Flexible(child: Text('$_likesCount')),
                const SizedBox(width: 16),
                // --- 🆕 FIXED COMMENT BUTTON SECTION ---
                Flexible(
                  // removed 'const' here because onPressed uses a function
                  child: IconButton(
                    // Wrapped Icon in IconButton so it can be clicked
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      size: 22,
                      color: Colors.grey,
                    ),
                    onPressed: _handleCommentPress, // Connected the handler
                  ),
                ),

                // --- END FIX ---
                const SizedBox(width: 4),
                //const Flexible(child: Text('0')),
                Flexible(child: Text('$_commentsCount')),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
