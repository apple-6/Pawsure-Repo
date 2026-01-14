import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/constants/api_config.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String profilePicture; // This will now always be a valid URL
  final String content;
  final List<String> mediaUrls;
  final String? location;
  final bool isUrgent;
  bool isLiked;
  int likes;
  final DateTime createdAt;
  int commentsCount;

  // Updated Vacancy fields for Multi-Pet support
  final bool isVacancy;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> petIds;
  final List<String> petNames;
  final double ratePerNight;
  final List<Pet> pets;

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
    this.petIds = const [],
    this.petNames = const [],
    this.ratePerNight = 0.0,
    this.pets = const [],
    this.commentsCount = 0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // 1. Handle nested user data
    final userData = json['user'] ?? json['owner'] ?? {};

    // 2. Extract media
    final List<dynamic> rawMedia =
        json['post_media'] ?? json['mediaUrls'] ?? [];

    // 3. Extract Pets
    final List<dynamic> rawPets = json['pets'] ?? [];

    // --- 🔧 HELPER: URL CLEANER (Fixes Android Emulator Localhost) ---
    String cleanUrl(String url) {
      if (url.isEmpty) return url;
      // If the database gives us 'localhost', we swap it with the correct
      // Base URL for the current device (10.0.2.2 for Android, etc.)
      if (url.contains('localhost:3000')) {
        return url.replaceAll('http://localhost:3000', ApiConfig.baseUrl);
      }
      return url;
    }

    // --- 4. IMAGE FIX LOGIC START ---
    String rawAvatar = userData['profile_picture'] ?? '';
    String finalAvatarUrl;

    if (rawAvatar.isNotEmpty) {
      if (rawAvatar.startsWith('http')) {
        // It is a full URL, but might be 'localhost'. Clean it.
        finalAvatarUrl = cleanUrl(rawAvatar);
      } else {
        // It is a relative path (e.g., uploads/avatar.jpg) -> Add Base URL
        finalAvatarUrl = '${ApiConfig.baseUrl}/$rawAvatar';
      }
    } else {
      // Default image
      finalAvatarUrl = "https://cdn-icons-png.flaticon.com/512/194/194279.png";
    }
    // --- IMAGE FIX LOGIC END ---

    return PostModel(
      id: json['id'].toString(),
      userId: (json['userId'] ?? userData['id'] ?? '').toString(),
      userName: userData['name'] ?? 'Unknown User',

      // ✅ ASSIGN THE FIXED URL
      profilePicture: finalAvatarUrl,

      content: json['content'] ?? '',

      // ✅ APPLY CLEANER TO MEDIA URLS
      mediaUrls: rawMedia
          .map((m) {
            String url;
            if (m is String) {
              url = m;
            } else {
              url = (m['url'] ?? m['media_url'] ?? '').toString();
            }
            return cleanUrl(url); // Fix localhost links here
          })
          .where((url) => url.isNotEmpty)
          .toList()
          .cast<String>(),

      location: json['location_name'] ?? json['location'],
      isUrgent: json['is_urgent'] ?? false,
      likes: json['likesCount'] ?? json['likes_count'] ?? json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),

      // Vacancy Mapping
      isVacancy: json['is_vacancy'] ?? false,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'])
          : null,

      // Multi-Pet Mapping
      petIds: rawPets.map((p) => p['id'].toString()).toList(),
      petNames: rawPets.map((p) => p['name'].toString()).toList(),
      pets: rawPets
          .map((p) => Pet.fromJson(p))
          .toList(), // Pet.fromJson already cleans its own URLs
      ratePerNight: json['rate_per_night'] != null
          ? double.tryParse(json['rate_per_night'].toString()) ?? 0.0
          : 0.0,
      commentsCount: json['commentsCount'] ?? json['comments_count'] ?? 0,
    );
  }
}
