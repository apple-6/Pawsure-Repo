// pawsure_app/lib/models/sitter_model.dart

// 1. ADD THIS NEW CLASS
class ReviewModel {
  final int id;
  final double rating;
  final String comment;
  final String ownerName;
  final String date;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.ownerName,
    required this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Extract owner name safely (backend usually sends 'owner': { 'name': '...' })
    String extractedName = "Anonymous";
    if (json['owner'] != null && json['owner']['name'] != null) {
      extractedName = json['owner']['name'];
    }

    // Format Date (Simple YYYY-MM-DD)
    String formattedDate = "";
    if (json['created_at'] != null) {
      DateTime dt = DateTime.parse(json['created_at']);
      formattedDate = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    }

    return ReviewModel(
      id: json['id'] ?? 0,
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      comment: json['comment'] ?? '',
      ownerName: extractedName,
      date: formattedDate,
    );
  }
}

class ServiceModel {
  String name;
  bool isActive;
  String price;
  String unit;

  ServiceModel({
    required this.name,
    required this.isActive,
    required this.price,
    required this.unit,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      name: json['name'] ?? '',
      isActive: json['isActive'] ?? false,
      price: json['price'].toString(),
      unit: json['unit'] ?? '',
    );
  }

  ServiceModel copy() {
    return ServiceModel(
      name: name,
      isActive: isActive,
      price: price,
      unit: unit,
    );
  }
}

class UserProfile {
  final int id;
  String name;
  String email; 
  String phone;
  String location;
  String bio;
  int experienceYears;
  int staysCompleted;
  List<ServiceModel> services;
  double rating;
  int reviewCount;
  List<ReviewModel> reviews; // ✅ ADD THIS
  final String? profilePicture;

  UserProfile({
    required this.id,
    required this.name,
    required this.email, 
    required this.phone,
    required this.location,
    required this.bio,
    required this.experienceYears,
    required this.staysCompleted,
    required this.services,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.reviews = const [], 
    this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    return UserProfile(
      // ✅ MAP USER ID to 'id'
      // The backend response for a Sitter object usually has 'userId' field
      id: json['userId'] ?? 0, 
      name: json['user']?['name'] ?? '',
      email: json['user']?['email'] ?? '', 
      phone: json['user']?['phone_number'] ?? '',
      location: json['address'] ?? json['location'] ?? '',
      bio: json['bio'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      staysCompleted: json['staysCompleted'] ?? 0,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceModel.fromJson(e))
              .toList() ??
          [],

          // ✅ Capture dynamic rating and review count from backend
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0,
    reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e))
              .toList() ??
          [],

    profilePicture: userData['profile_picture'] ?? userData['profilePicture'],
    );
    
  }
}