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
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int,
      name: json['name'] as String,
      species: json['species'] as String?,
      breed: json['breed'] as String?,
      dob: json['dob'] as String?,
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
      allergies: json['allergies'] as String?,
      vaccinationDates: json['vaccination_dates'] != null
          ? List<String>.from(json['vaccination_dates'] as List)
          : null,
      lastVetVisit: json['last_vet_visit'] as String?,
      moodRating: json['mood_rating'] != null
          ? (json['mood_rating'] as num).toDouble()
          : null,
      streak: json['streak'] as int? ?? 0,
    );
  }
}
