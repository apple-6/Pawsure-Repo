class Sitter {
  final String id;
  final String name;
  final String? avatarUrl;
  final double rating;

  Sitter({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.rating = 0,
  });

  factory Sitter.fromJson(Map<String, dynamic> json) {
    return Sitter(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      rating: (json['rating'] != null)
          ? double.tryParse(json['rating'].toString()) ?? 0
          : 0,
    );
  }
}

class BookingRequest {
  final String id;
  final String petName;
  final String petType;
  final String dates;
  final String location;
  final String description;
  final String status; // 'Pending', 'Confirmed', 'Ongoing'
  final double ratePerDay;

  BookingRequest({
    required this.id,
    required this.petName,
    required this.petType,
    required this.dates,
    required this.location,
    required this.description,
    required this.status,
    required this.ratePerDay,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      id: json['id']?.toString() ?? '',
      petName: json['petName'] ?? '',
      petType: json['petType'] ?? '',
      dates: json['dates'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Pending',
      ratePerDay: (json['ratePerDay'] != null)
          ? double.tryParse(json['ratePerDay'].toString()) ?? 0
          : 0,
    );
  }
}
