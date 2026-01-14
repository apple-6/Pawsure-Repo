// pawsure_app/lib/models/sitter_model.dart

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
    // Extract owner name safely
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
  int bookingsCompleted; // ✅ RENAMED (was staysCompleted)
  List<ServiceModel> services;
  double rating;
  int reviewCount;
  List<ReviewModel> reviews;
  final String? profilePicture;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.bio,
    required this.experienceYears,
    required this.bookingsCompleted, // ✅ UPDATED CONSTRUCTOR
    required this.services,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.reviews = const [],
    this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;

    // --- HELPER 1: Extract number from "8 years" string ---
    int parseExperience(dynamic value) {
      if (value == null) return 0;
      final String str = value.toString();
      final RegExp regExp = RegExp(r'\d+'); // Finds the first number
      final match = regExp.firstMatch(str);
      if (match != null) {
        return int.tryParse(match.group(0)!) ?? 0;
      }
      return 0;
    }

    // --- HELPER 2: Calculate booking list length ---
    int calculateBookings(dynamic bookingsData) {
      if (bookingsData != null && bookingsData is List) {
        return bookingsData.length;
      }
      return 0;
    }

    return UserProfile(
      // ID: fallback checks
      id: json['userId'] ?? json['id'] ?? 0,
      
      // User Info
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      phone: userData['phone_number'] ?? '',
      profilePicture: userData['profile_picture'] ?? userData['profilePicture'],

      // Sitter Info
      location: json['address'] ?? json['location'] ?? '',
      bio: json['bio'] ?? '',

      // ✅ FIX 1: Use helper to parse 'experience' column from DB
      experienceYears: parseExperience(json['experience']),

      // ✅ FIX 2: Calculate bookings from the list length
      bookingsCompleted: calculateBookings(json['bookings']),

      // Services
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceModel.fromJson(e))
              .toList() ??
          [],

      // Ratings
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0,
      
      // Reviews
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}