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
  String name;
  String location;
  String bio;
  int experienceYears;
  int staysCompleted;
  List<ServiceModel> services;

  UserProfile({
    required this.name,
    required this.location,
    required this.bio,
    required this.experienceYears,
    required this.staysCompleted,
    required this.services,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    var list = json['services'] as List? ?? [];
    List<ServiceModel> servicesList = list.map((i) => ServiceModel.fromJson(i)).toList();

    return UserProfile(
      name: json['name'] ?? 'Unknown',
      location: json['location'] ?? '',
      bio: json['bio'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      staysCompleted: json['staysCompleted'] ?? 0,
      services: servicesList,
    );
  }
}