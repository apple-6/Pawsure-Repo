// lib/screens/community/sitter_model.dart

const _fallbackImage =
    'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=400&q=80';

class Sitter {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final String services;
  final double price;
  final String location;
  final String imageUrl;
  final List<DateTime> availableDates;
  final List<DateTime> unavailableDates;

  const Sitter({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.services,
    required this.price,
    required this.location,
    required this.imageUrl,
    this.availableDates = const [],
    this.unavailableDates = const [],
  });

  factory Sitter.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    final List<DateTime> parsedAvailableDates = _parseDateList(
      json['available_dates'],
    );
    final List<DateTime> parsedUnavailableDates = _parseDateList(
      json['unavailable_dates'],
    );

    final photoGallery = json['photo_gallery'] as String?;
    final galleryImage = _extractFirstPhoto(photoGallery);
    final profileImage = userJson != null ? userJson['profile_picture'] : null;

    return Sitter(
      id: (json['id'] ?? '').toString(),
      name:
          (userJson != null ? userJson['name'] : json['name']) as String? ??
          'Pet Sitter',
      rating: _toDouble(json['rating']) ?? _toDouble(json['avgRating']) ?? 0.0,
      reviewCount:
          _toInt(json['reviews_count']) ?? _toInt(json['reviewCount']) ?? 0,
      services:
          json['experience'] as String? ??
          json['services'] as String? ??
          'Pet care services',
      price: _toDouble(json['ratePerNight']) ??
          _toDouble(json['price']) ??
          0.0,
      location:
          json['address'] as String? ??
          json['location'] as String? ??
          'Unknown location',
      imageUrl: galleryImage ?? profileImage ?? _fallbackImage,
      availableDates: parsedAvailableDates,
      unavailableDates: parsedUnavailableDates,
    );
  }

  static List<Sitter> fromJsonList(List<dynamic> data) {
    return data
        .map((raw) => Sitter.fromJson(raw as Map<String, dynamic>))
        .toList();
  }

  static List<DateTime> _parseDateList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => _parseDate(item))
          .whereType<DateTime>()
          .toList();
    }
    if (value is String) {
      final maybeDate = _parseDate(value);
      return maybeDate != null ? [maybeDate] : [];
    }
    return [];
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      if (value is String && value.isNotEmpty) {
        return DateTime.parse(value).toLocal();
      }
      if (value is DateTime) return value;
    } catch (_) {
      return null;
    }
    return null;
  }

  static String? _extractFirstPhoto(String? gallery) {
    if (gallery == null || gallery.isEmpty) return null;
    final parts = gallery.split(',');
    return parts.isNotEmpty ? parts.first.trim() : null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String && value.trim().isNotEmpty) {
      return double.tryParse(value.trim());
    }
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String && value.trim().isNotEmpty) {
      return int.tryParse(value.trim());
    }
    return null;
  }
}

// Mock Data List used as a fallback when API calls fail
List<Sitter> mockSitters = [
  Sitter(
    id: 'sitter1',
    name: 'Jane Doe',
    rating: 4.9,
    reviewCount: 85,
    services: 'Boarding, House Sitting',
    price: 45.0,
    location: 'Taman Century, Johor Bahru',
    imageUrl:
        'https://images.unsplash.com/photo-1543660641-768f51528657?w=400&auto=format&fit=crop',
    unavailableDates: [
      DateTime.now().add(const Duration(days: 7)),
      DateTime.now().add(const Duration(days: 8)),
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
    imageUrl:
        'https://images.unsplash.com/photo-1583344652240-5e5d3261a843?w=400&auto=format&fit=crop',
    availableDates: [
      DateTime.now().add(const Duration(days: 1)),
      DateTime.now().add(const Duration(days: 2)),
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
    imageUrl:
        'https://images.unsplash.com/photo-1629851722839-2e987c264a4c?w=400&auto=format&fit=crop',
    availableDates: [DateTime.now().add(const Duration(days: 14))],
  ),
];
