class Rider {
  final String? id;
  final String nom;
  final String prenom;
  final String club;
  final String telephone;

  Rider({
    this.id,
    required this.nom,
    required this.prenom,
    required this.club,
    required this.telephone,
  });

  // Convert Rider to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'club': club,
      'telephone': telephone,
    };
  }

  // Create Rider from Firestore document
  factory Rider.fromFirestore(Map<String, dynamic> data, String? id) {
    return Rider(
      id: id,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      club: data['club'] ?? '',
      telephone: data['telephone'] ?? '',
    );
  }

  // Create copy with updated fields
  Rider copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? club,
    String? telephone,
  }) {
    return Rider(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      club: club ?? this.club,
      telephone: telephone ?? this.telephone,
    );
  }
}
