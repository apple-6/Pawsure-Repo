import 'package:flutter/material.dart';
import 'package:pawsure_app/models/comment_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/services/auth_service.dart'; // 1. Import Auth Service
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
  
  // 2. Access Auth Service to get ID
  final AuthService _authService = Get.find<AuthService>(); 

  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _currentUserId; // Store your ID

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser(); // 3. Fetch ID on init
    _fetchComments();
  }

  // Helper to get your ID
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
                          
                          // 4. Check if the comment belongs to the current user
                          final isMe = comment.userId == _currentUserId;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // If isMe -> Align End (Right). If Not -> Align Start (Left)
                              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                
                                // --- A. OTHER PEOPLE (Avatar on Left) ---
                                if (!isMe) ...[
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.blueAccent.withOpacity(0.2),
                                    child: Text(
                                      comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?',
                                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],

                                // --- B. THE BUBBLE ---
                                Flexible( 
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      // Blue for me, Grey for others
                                      color: isMe ? Colors.blue[100] : Colors.grey[100], 
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      // Align text to right if it's me
                                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(comment.content),
                                      ],
                                    ),
                                  ),
                                ),

                                // --- C. ME (Avatar on Right) ---
                                if (isMe) ...[
                                  const SizedBox(width: 10),
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.blueAccent.withOpacity(0.2),
                                    child: Text(
                                      comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?',
                                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
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