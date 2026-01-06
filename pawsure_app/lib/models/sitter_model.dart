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
  String location;
  String bio;
  int experienceYears;
  int staysCompleted;
  List<ServiceModel> services;

  UserProfile({
    required this.id,
    required this.name,
    required this.location,
    required this.bio,
    required this.experienceYears,
    required this.staysCompleted,
    required this.services,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      // ✅ MAP USER ID to 'id'
      // The backend response for a Sitter object usually has 'userId' field
      id: json['userId'] ?? 0, 
      
      name: json['user']?['name'] ?? 'Unknown',
      location: json['address'] ?? json['location'] ?? '',
      bio: json['bio'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      staysCompleted: json['staysCompleted'] ?? 0,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}