//pawsure_app\lib\models\pet_model.dart
import 'dart:convert';

class Pet {
  final int id;
  final String name;
  final String? species;
  final String? breed;
  final String? dob;
  final double? weight;
  final double? height;
  final int? bodyConditionScore;
  final List<WeightRecord>? weightHistory;
  final String? allergies;
  final String? foodBrand;
  final String? dailyFoodAmount;
  final List<String>? vaccinationDates;
  final String? lastVetVisit;
  final double? moodRating;
  final int streak;
  final String? photoUrl;
  final String? sterilizationStatus;

  Pet({
    required this.id,
    required this.name,
    this.species,
    this.breed,
    this.dob,
    this.weight,
    this.height,
    this.bodyConditionScore,
    this.weightHistory,
    this.allergies,
    this.foodBrand,
    this.dailyFoodAmount,
    this.vaccinationDates,
    this.lastVetVisit,
    this.moodRating,
    this.streak = 0,
    this.photoUrl,
    this.sterilizationStatus,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int,
      name: json['name'] as String,
      species: json['species'] as String?,
      breed: json['breed'] as String?,
      dob: json['dob'] as String?,
      weight: json['weight'] != null ? _parseDouble(json['weight']) : null,
      height: json['height'] != null ? _parseDouble(json['height']) : null,
      bodyConditionScore: _parseInt(json['body_condition_score']),
      weightHistory: _parseWeightHistory(json['weight_history']),
      allergies: json['allergies'] as String?,
      foodBrand: json['food_brand'] as String?,
      dailyFoodAmount: json['daily_food_amount'] as String?,
      vaccinationDates: json['vaccination_dates'] != null
          ? List<String>.from(json['vaccination_dates'] as List)
          : null,
      lastVetVisit: json['last_vet_visit'] as String?,
      moodRating: json['mood_rating'] != null
          ? _parseDouble(json['mood_rating'])
          : null,
      streak: json['streak'] as int? ?? 0,
      photoUrl: json['photoUrl'] as String?,
      sterilizationStatus: json['sterilization_status'] as String?,
    );
  }

  /// Parse int from various types (int, double, string)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    } else if (value is double) {
      return value.toInt();
    } else if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  /// Parse double from various types
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }

  /// Parse weight history from List or JSON string
  static List<WeightRecord>? _parseWeightHistory(dynamic value) {
    if (value == null) return null;

    try {
      List<dynamic> list;

      // Handle if it's a JSON string
      if (value is String) {
        if (value.isEmpty) return null;
        list = jsonDecode(value) as List<dynamic>;
      } else if (value is List) {
        list = value;
      } else {
        return null;
      }

      return list
          .map((e) => WeightRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return null
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'dob': dob,
      'weight': weight,
      'height': height,
      'body_condition_score': bodyConditionScore,
      'weight_history': weightHistory?.map((e) => e.toJson()).toList(),
      'allergies': allergies,
      'food_brand': foodBrand,
      'daily_food_amount': dailyFoodAmount,
      'vaccination_dates': vaccinationDates,
      'last_vet_visit': lastVetVisit,
      'mood_rating': moodRating,
      'streak': streak,
      'photoUrl': photoUrl,
      'sterilization_status': sterilizationStatus,
    };
  }
}

class WeightRecord {
  final String date;
  final double weight;

  WeightRecord({required this.date, required this.weight});

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      date: json['date'] as String,
      weight: (json['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'weight': weight,
    };
  }
}
