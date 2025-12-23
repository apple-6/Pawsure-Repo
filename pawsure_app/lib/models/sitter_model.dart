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
}