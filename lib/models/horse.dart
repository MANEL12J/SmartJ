class Horse {
  final String? id;
  final String nom;
  final String sexe;
  final int age;
  final String race;

  Horse({
    this.id,
    required this.nom,
    required this.sexe,
    required this.age,
    required this.race,
  });

  // Convert Horse to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'sexe': sexe,
      'age': age,
      'race': race,
    };
  }

  // Create Horse from Firestore document
  factory Horse.fromFirestore(Map<String, dynamic> data, String? id) {
    return Horse(
      id: id,
      nom: data['nom'] ?? '',
      sexe: data['sexe'] ?? '',
      age: data['age'] ?? 0,
      race: data['race'] ?? '',
    );
  }

  // Create copy with updated fields
  Horse copyWith({
    String? id,
    String? nom,
    String? sexe,
    int? age,
    String? race,
  }) {
    return Horse(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      sexe: sexe ?? this.sexe,
      age: age ?? this.age,
      race: race ?? this.race,
    );
  }
}
