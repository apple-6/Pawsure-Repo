// lib/models/sitter_model.dart

class Sitter {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final String services;
  final double price;
  final String location;
  final String imageUrl;

  Sitter({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.services,
    required this.price,
    required this.location,
    required this.imageUrl,
  });
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
    imageUrl:
        'https://images.unsplash.com/photo-1543660641-768f51528657?w=400&auto=format&fit=crop',
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
  ),
];
