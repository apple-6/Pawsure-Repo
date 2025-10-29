class Pet {
  final int id;
  final String name;
  final String species;

  Pet({required this.id, required this.name, required this.species});

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int,
      name: json['name'] as String,
      species: json['species'] as String,
    );
  }
}
