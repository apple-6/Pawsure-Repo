// lib/screens/community/sitter_model.dart

// 1. Add the Review Class required by your Details Screen
class Review {
  final String userName;
  final String date;
  final int rating;
  final String comment;

  Review({
    required this.userName,
    required this.date,
    required this.rating,
    required this.comment,
  });
}

class Sitter {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final String services;
  final double price;
  final String location;
  final String imageUrl;
  final List<DateTime> unavailableDates;
  final List<String> availableDates;

  // NEW FIELDS REQUIRED BY YOUR ERROR LOG
  final bool isVerified;
  final String bio;
  final String bookingsCompleted;
  final String houseType;
  final List<String> petTypes;
  final List<Review> reviews;

  Sitter({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.services,
    required this.price,
    required this.location,
    required this.imageUrl,
    required this.unavailableDates, // Required in the constructor
    required this.availableDates,
    // Initialize new fields
    required this.isVerified,
    required this.bio,
    required this.bookingsCompleted,
    required this.houseType,
    required this.petTypes,
    required this.reviews,
  });

  factory Sitter.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};

    List<DateTime> _parseUnavailableDates(List? list) {
      return list
              ?.map((e) => DateTime.tryParse(e.toString()))
              .whereType<DateTime>()
              .toList() ??
          [];
    }

    List<String> _parseStringList(List? list) {
      return list?.map((e) => e.toString()).toList() ?? [];
    }

    return Sitter(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (user['name'] ?? json['name'] ?? 'Unknown').toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      services:
          (json['services'] ?? json['servicesOffered'] ?? 'Services not set')
              .toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      location: (json['address'] ?? json['location'] ?? 'Location not set')
          .toString(),
      imageUrl:
          (json['imageUrl'] ??
                  user['avatar'] ??
                  'https://images.unsplash.com/photo-1544005313-94ddf0286df2')
              .toString(),
      unavailableDates: _parseUnavailableDates(
        json['unavailableDates'] as List?,
      ),
      availableDates: _parseStringList(json['availableDates'] as List?),
      isVerified: json['isVerified'] == true,
      bio: (json['bio'] ?? '').toString(),
      bookingsCompleted: (json['bookingsCompleted'] ?? '').toString(),
      houseType: (json['houseType'] ?? '').toString(),
      petTypes: _parseStringList(json['petTypes'] as List?),
      reviews: const [],
    );
  }
}

// Mock Data List
List<Sitter> mockSitters = [
  Sitter(
    id: 'sitter1',
    name: 'Jane Doe',
    rating: 4.9,
    reviewCount: 85,
    services: 'Boarding, House Sitting',
    price: 45.0,
    location: 'Taman Century, Johor Bahru',
    imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80',
    // 'https://images.unsplash.com/photo-1543660641-768f51528657?w=400&auto=format&fit=crop',
    // Example: Unavailable next week
    unavailableDates: [
      DateTime.now().add(const Duration(days: 7)),
      DateTime.now().add(const Duration(days: 8)),
    ],
    availableDates: const [],
    // New Data
    isVerified: true,
    bio:
        "Hi, I'm Sarah! I've been a pet lover my whole life. I have a spacious fenced backyard and two friendly Golden Retrievers who love to play.",
    bookingsCompleted: "150+ Bookings Completed",
    houseType: "Landed House with Garden",
    petTypes: ["Dogs", "Cats", "Birds"],
    reviews: [
      Review(
        userName: "John Doe",
        date: "12 Oct 2023",
        rating: 5,
        comment: "Sarah was amazing with my husky!",
      ),
      Review(
        userName: "Jane Smith",
        date: "05 Sep 2023",
        rating: 5,
        comment: "Very professional and sent lots of updates.",
      ),
    ],
  ),
  Sitter(
    id: 'sitter2',
    name: 'Ramesh Kumar',
    rating: 4.7,
    reviewCount: 52,
    services: 'Drop-In Visits, Dog Walking',
    price: 20.0,
    location: 'KSL, Johor Bahru',
    imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
    //'https://images.unsplash.com/photo-1583344652240-5e5d3261a843?w=400&auto=format&fit=crop',
    // Example: Always available
    unavailableDates: [],
    availableDates: const [],
    // New Data
    isVerified: true,
    bio:
        "Active dog walker who loves long hikes. I ensure your energetic pups get the exercise they need!",
    bookingsCompleted: "80+ Bookings Completed",
    houseType: "Apartment (Pet Friendly)",
    petTypes: ["Dogs"],
    reviews: [
      Review(
        userName: "Ali Ahmad",
        date: "20 Nov 2023",
        rating: 4,
        comment: "Great walker, very punctual.",
      ),
    ],
  ),
  Sitter(
    id: 'sitter3',
    name: 'Alice Tan',
    rating: 5.0,
    reviewCount: 120,
    services: 'Boarding (Cats Only)',
    price: 50.0,
    location: 'Permas Jaya, Johor Bahru',
    imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
    // 'https://images.unsplash.com/photo-1629851722839-2e987c264a4c?w=400&auto=format&fit=crop',
    // Example: Unavailable in two weeks
    unavailableDates: [DateTime.now().add(const Duration(days: 14))],
    availableDates: const [],
    // New Data
    isVerified: false,
    bio:
        "Professional groomer with 5 years experience. I provide a calm and spa-like experience for your pets.",
    bookingsCompleted: "300+ Bookings Completed",
    houseType: "Shop Lot Studio",
    petTypes: ["Cats", "Small Dogs"],
    reviews: [
      Review(
        userName: "Mei Ling",
        date: "01 Dec 2023",
        rating: 5,
        comment: "My cat usually hates grooming but loved Jessica!",
      ),
    ],
  ),
];
