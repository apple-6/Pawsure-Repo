import 'dart:io';
import 'package:flutter/foundation.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String profilePicture;
  final String content;
  final List<String> mediaUrls; // This name must match PostCard
  final String? location;
  final bool isUrgent;
  bool isLiked;
  int likes; //remove final
  final DateTime createdAt;

  // Vacancy fields for the new Sitter Vacancy logic
  final bool isVacancy;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? petId;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.profilePicture,
    required this.content,
    required this.mediaUrls,
    this.location,
    this.isUrgent = false,
    this.isLiked = false,
    this.likes = 0,
    required this.createdAt,
    this.isVacancy = false,
    this.startDate,
    this.endDate,
    this.petId,
  });

  /// Fix localhost URLs for Android emulator
  static String _fixImageUrl(String url) {
    if (url.isEmpty) return url;
    
    // On Android emulator, replace localhost with 10.0.2.2
    if (!kIsWeb && Platform.isAndroid) {
      return url
          .replaceAll('http://localhost:', 'http://10.0.2.2:')
          .replaceAll('https://localhost:', 'https://10.0.2.2:');
    }
    return url;
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // 1. Handle nested user data from your NestJS/Prisma backend
    final userData = json['user'] ?? json['owner'] ?? {};

    // 2. Extract media: Checks both potential API keys
    final List<dynamic> rawMedia =
        json['post_media'] ?? json['mediaUrls'] ?? [];

    return PostModel(
      id: json['id'].toString(),
      userId: (json['userId'] ?? userData['id'] ?? '').toString(),
      userName: userData['name'] ?? 'Unknown User',
      profilePicture: _fixImageUrl(
          userData['profile_picture'] ??
          "https://cdn-icons-png.flaticon.com/512/194/194279.png"),
      content: json['content'] ?? '',

      // 3. Mapping the images correctly so they show up in your Carousel
      // Also fix localhost URLs for Android emulator
      mediaUrls: rawMedia
          .map((m) {
            String url;
            if (m is String) {
              url = m;
            } else {
              url = (m['url'] ?? m['media_url'] ?? '').toString();
            }
            return _fixImageUrl(url);
          })
          .where((url) => url.isNotEmpty)
          .toList()
          .cast<String>(),

      location: json['location_name'] ?? json['location'],
      isUrgent: json['is_urgent'] ?? false,
      //likes: json['likes_count'] ?? json['likes'] ?? 0,
      likes: json['likesCount'] ?? json['likes_count'] ?? json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),

      // Vacancy fields mapping
      isVacancy: json['is_vacancy'] ?? false,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'])
          : null,
      petId: json['petId']?.toString(),
    );
  }
}
