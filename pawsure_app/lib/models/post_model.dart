class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String profilePicture;
  final String content;
  final List<String> mediaUrls;
  final String? location;
  final bool isUrgent;
  final bool isLiked;
  final int likes;
  final DateTime createdAt;

  // Updated Vacancy fields for Multi-Pet support
  final bool isVacancy;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> petIds; // Changed from String? petId
  final List<String> petNames; // Added to display tags (e.g., "Buddy", "Luna")

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
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // 1. Handle nested user data
    final userData = json['user'] ?? json['owner'] ?? {};

    // 2. Extract media
    final List<dynamic> rawMedia =
        json['post_media'] ?? json['mediaUrls'] ?? [];

    // 3. Extract Pets (Mapped from the @ManyToMany relation in TypeORM)
    final List<dynamic> rawPets = json['pets'] ?? [];

    return PostModel(
      id: json['id'].toString(),
      userId: (json['userId'] ?? userData['id'] ?? '').toString(),
      userName: userData['name'] ?? 'Unknown User',
      profilePicture:
          userData['profile_picture'] ??
          "https://cdn-icons-png.flaticon.com/512/194/194279.png",
      content: json['content'] ?? '',

      // Media mapping logic
      mediaUrls: rawMedia
          .map((m) {
            if (m is String) return m;
            return (m['url'] ?? m['media_url'] ?? '').toString();
          })
          .where((url) => url.isNotEmpty)
          .toList()
          .cast<String>(),

      location: json['location_name'] ?? json['location'],
      isUrgent: json['is_urgent'] ?? false,
      likes: json['likes_count'] ?? json['likes'] ?? 0,
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
    );
  }
}
