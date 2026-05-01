import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id;
  final String nom;
  final DateTime date;
  final String heure;
  final String bareme; // A | A chrono | C
  final double hauteur;
  final String carriere; // indoor | outdoor
  final String competitionId;
  final int nombreManches; // Nombre de manches (1, 2, 3...)
  final bool avecBarage; // Avec ou sans barage

  Event({
    this.id,
    required this.nom,
    required this.date,
    required this.heure,
    required this.bareme,
    required this.hauteur,
    required this.carriere,
    required this.competitionId,
    required this.nombreManches,
    required this.avecBarage,
  });

  // Convert Event to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'date': date,
      'heure': heure,
      'bareme': bareme,
      'hauteur': hauteur,
      'carriere': carriere,
      'competitionId': competitionId,
      'nombreManches': nombreManches,
      'avecBarage': avecBarage,
    };
  }

  // Create Event from Firestore document
  factory Event.fromFirestore(Map<String, dynamic> data, String? id) {
    return Event(
      id: id,
      nom: data['nom'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      heure: data['heure'] ?? '',
      bareme: data['bareme'] ?? '',
      hauteur: (data['hauteur'] as num?)?.toDouble() ?? 0.0,
      carriere: data['carriere'] ?? '',
      competitionId: data['competitionId'] ?? '',
      nombreManches: data['nombreManches'] ?? 1,
      avecBarage: data['avecBarage'] ?? false,
    );
  }

  // Create copy with updated fields
  Event copyWith({
    String? id,
    String? nom,
    DateTime? date,
    String? heure,
    String? bareme,
    double? hauteur,
    String? carriere,
    String? competitionId,
    int? nombreManches,
    bool? avecBarage,
  }) {
    return Event(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      date: date ?? this.date,
      heure: heure ?? this.heure,
      bareme: bareme ?? this.bareme,
      hauteur: hauteur ?? this.hauteur,
      carriere: carriere ?? this.carriere,
      competitionId: competitionId ?? this.competitionId,
      nombreManches: nombreManches ?? this.nombreManches,
      avecBarage: avecBarage ?? this.avecBarage,
    );
  }
}
