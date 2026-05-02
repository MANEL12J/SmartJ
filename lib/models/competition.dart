import 'package:cloud_firestore/cloud_firestore.dart';

class Competition {
  final String? id;
  final String nom;
  final DateTime date;
  final String region;
  final String club;
  final String reglement;
  final String showId;

  Competition({
    this.id,
    required this.nom,
    required this.date,
    required this.region,
    required this.club,
    required this.reglement,
    required this.showId,
  });

  // Convert Competition to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'date': date,
      'region': region,
      'club': club,
      'reglement': reglement,
      'showId': showId,
    };
  }

  // Create Competition from Firestore document
  factory Competition.fromFirestore(Map<String, dynamic> data, String? id) {
    return Competition(
      id: id,
      nom: data['nom'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      region: data['region'] ?? '',
      club: data['club'] ?? '',
      reglement: data['reglement'] ?? '',
      showId: data['showId'] ?? '',
    );
  }

  // Create copy with updated fields
  Competition copyWith({
    String? id,
    String? nom,
    DateTime? date,
    String? region,
    String? club,
    String? reglement,
    String? showId,
  }) {
    return Competition(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      date: date ?? this.date,
      region: region ?? this.region,
      club: club ?? this.club,
      reglement: reglement ?? this.reglement,
      showId: showId ?? this.showId,
    );
  }
}
