class Participation {
  final String? id;
  final String riderId;
  final String horseId;
  final String eventId;
  final int ordrePassage;
  final String statut; // en_attente | passe
  final double score;

  Participation({
    this.id,
    required this.riderId,
    required this.horseId,
    required this.eventId,
    required this.ordrePassage,
    required this.statut,
    required this.score,
  });

  // Convert Participation to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'riderId': riderId,
      'horseId': horseId,
      'eventId': eventId,
      'ordrePassage': ordrePassage,
      'statut': statut,
      'score': score,
    };
  }

  // Create Participation from Firestore document
  factory Participation.fromFirestore(Map<String, dynamic> data, String? id) {
    return Participation(
      id: id,
      riderId: data['riderId'] ?? '',
      horseId: data['horseId'] ?? '',
      eventId: data['eventId'] ?? '',
      ordrePassage: data['ordrePassage'] ?? 0,
      statut: data['statut'] ?? 'en_attente',
      score: (data['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Create copy with updated fields
  Participation copyWith({
    String? id,
    String? riderId,
    String? horseId,
    String? eventId,
    int? ordrePassage,
    String? statut,
    double? score,
  }) {
    return Participation(
      id: id ?? this.id,
      riderId: riderId ?? this.riderId,
      horseId: horseId ?? this.horseId,
      eventId: eventId ?? this.eventId,
      ordrePassage: ordrePassage ?? this.ordrePassage,
      statut: statut ?? this.statut,
      score: score ?? this.score,
    );
  }
}
