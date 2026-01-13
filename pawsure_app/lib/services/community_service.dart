// pawsure_app/lib/services/community_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/models/post_model.dart';
import 'package:pawsure_app/models/comment_model.dart';
import 'package:pawsure_app/constants/api_endpoints.dart';

class CommunityService {
  // ✅ Helper to keep headers consistent in this file
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true', // ✅ The Magic Header
  };

  Future<List<PostModel>> getAllPosts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.posts}'),
        headers: _headers, // ✅ ADDED
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        return jsonList.map((post) => PostModel.fromJson(post)).toList();
      }
      throw Exception('Failed to load posts (${response.statusCode})');
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      rethrow;
    }
  }

  Future<PostModel> addPost({
    required String title,
    required String content,
    List<String>? tags,
    String? imageUrl,
  }) async {
    try {
      final payload = {
        'title': title,
        'content': content,
        'tags': tags ?? [],
        'imageUrl': imageUrl,
      };

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.addPost}'),
        headers: _headers, // ✅ ADDED
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return PostModel.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to add post (${response.statusCode})');
    } catch (e) {
      debugPrint('Error adding post: $e');
      rethrow;
    }
  }

  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getComments(postId)}'),
        headers: _headers, // ✅ ADDED
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        return jsonList.map((c) => CommentModel.fromJson(c)).toList();
      }
      throw Exception('Failed to load comments (${response.statusCode})');
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      rethrow;
    }
  }

  Future<CommentModel> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      final payload = {'postId': postId, 'content': content};

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.addComment}'),
        headers: _headers, // ✅ ADDED
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return CommentModel.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to add comment (${response.statusCode})');
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.posts}/$postId/like'),
        headers: _headers, // ✅ ADDED
      );
    } catch (e) {
      debugPrint('Error liking post: $e');
      rethrow;
    }
  }
}
