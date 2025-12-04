class ActivityModel {
  final String id;
  final String petId;
  final String activityType; // walk, play, exercise, etc.
  final String title;
  final String description;
  final DateTime activityDate;
  final int durationMinutes;
  final double? distanceKm;
  final int? caloriesBurned;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityModel({
    required this.id,
    required this.petId,
    required this.activityType,
    required this.title,
    required this.description,
    required this.activityDate,
    required this.durationMinutes,
    this.distanceKm,
    this.caloriesBurned,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      petId: json['petId'] as String,
      activityType: json['activityType'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      activityDate: DateTime.parse(json['activityDate'] as String),
      durationMinutes: json['durationMinutes'] as int,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      caloriesBurned: json['caloriesBurned'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'activityType': activityType,
      'title': title,
      'description': description,
      'activityDate': activityDate.toIso8601String(),
      'durationMinutes': durationMinutes,
      'distanceKm': distanceKm,
      'caloriesBurned': caloriesBurned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ActivityModel copyWith({
    String? id,
    String? petId,
    String? activityType,
    String? title,
    String? description,
    DateTime? activityDate,
    int? durationMinutes,
    double? distanceKm,
    int? caloriesBurned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      description: description ?? this.description,
      activityDate: activityDate ?? this.activityDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
