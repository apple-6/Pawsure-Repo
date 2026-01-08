import 'package:flutter/material.dart';
import 'package:pawsure_app/models/comment_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'package:get/get.dart';

class CommentModal extends StatefulWidget {
  final String postId;
  final VoidCallback? onCommentPosted;

  const CommentModal({
    super.key,
    required this.postId,
    this.onCommentPosted,
  });

  @override
  State<CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends State<CommentModal> {
  final TextEditingController _commentController = TextEditingController();
  final ApiService _apiService = ApiService();
  final AuthService _authService = Get.find<AuthService>();

  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchComments();
  }

  Future<void> _fetchCurrentUser() async {
    final userId = await _authService.getUserId();
    if (mounted) {
      setState(() {
        _currentUserId = userId?.toString();
      });
    }
  }

  Future<void> _fetchComments() async {
    try {
      final comments = await _apiService.getComments(widget.postId);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final newComment = await _apiService.addComment(widget.postId, text);

      setState(() {
        _comments.add(newComment);
        _commentController.clear();
        _isSending = false;
      });

      if (widget.onCommentPosted != null) {
        widget.onCommentPosted!();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to post comment")),
        );
      }
    }
  }

  // 🆕 Helper to format Date and Time
  String _formatDateTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(localTime.year, localTime.month, localTime.day);

    String timeString = "${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}";

    if (dateToCheck == today) {
      return "Today, $timeString";
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return "Yesterday, $timeString";
    } else {
      return "${localTime.day}/${localTime.month}/${localTime.year} $timeString";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),

          // Comments List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(child: Text("No comments yet.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          final isMe = comment.userId == _currentUserId;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar (Always Left)
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                                  child: Text(
                                    comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Comment Bubble (Always Expanded)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isMe ? Colors.blue[50] : Colors.grey[100], 
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, // Left aligned
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(comment.content),
                                        const SizedBox(height: 4),
                                        
                                        // 🆕 Date & Time Text
                                        Text(
                                          _formatDateTime(comment.createdAt),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSending 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Icon(Icons.send, color: Colors.blue),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}