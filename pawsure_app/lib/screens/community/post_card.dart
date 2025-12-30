import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart'; // 🆕 Import carousel
import 'package:pawsure_app/models/post_model.dart';
import 'community_screen.dart';

class PostCard extends StatefulWidget {
  // 🆕 Changed to StatefulWidget for index tracking
  final PostModel post;
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
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _currentMediaIndex = 0; // Tracks which image is being viewed

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
                      widget.post.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.post.isLiked ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => widget.onLike(widget.post.id),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ),
                Flexible(child: Text('${widget.post.likes}')),
                const SizedBox(width: 16),
                const Flexible(
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 22,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                const Flexible(child: Text('0')),
                const Spacer(),
                Flexible(
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.grey),
                    onPressed: () => widget.onShare(widget.post.id),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
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
}
