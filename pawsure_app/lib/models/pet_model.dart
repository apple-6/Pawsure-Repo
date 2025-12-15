//pawsure_app\lib\models\pet_model.dart
class Pet {
  final int id;
  final String name;
  final String? species;
  final String? breed;
  final String? dob;
  final double? weight;
  final String? allergies;
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
    this.allergies,
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
      // 🔧 FIX: Handle both string and number types for weight
      weight: json['weight'] != null ? _parseDouble(json['weight']) : null,
      allergies: json['allergies'] as String?,
      vaccinationDates: json['vaccination_dates'] != null
          ? List<String>.from(json['vaccination_dates'] as List)
          : null,
      lastVetVisit: json['last_vet_visit'] as String?,
      // 🔧 FIX: Handle both string and number types for mood_rating
      moodRating: json['mood_rating'] != null
          ? _parseDouble(json['mood_rating'])
          : null,
      streak: json['streak'] as int? ?? 0,
      photoUrl: json['photoUrl'] as String?,
      sterilizationStatus: json['sterilization_status'] as String?,
    );
  }

  // 🆕 Helper method to safely parse doubles from both strings and numbers
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'dob': dob,
      'weight': weight,
      'allergies': allergies,
      'vaccination_dates': vaccinationDates,
      'last_vet_visit': lastVetVisit,
      'mood_rating': moodRating,
      'streak': streak,
      'photoUrl': photoUrl,
      'sterilization_status': sterilizationStatus,
    };
  }
}
