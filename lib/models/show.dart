import 'package:cloud_firestore/cloud_firestore.dart';

class Show {
  final String? id;
  final String nom;
  final String region;
  final DateTime date;
  final String reglement; // FEI | FEA
  final String judgeId;
  final String designerId;

  Show({
    this.id,
    required this.nom,
    required this.region,
    required this.date,
    required this.reglement,
    required this.judgeId,
    required this.designerId,
  });

  // Convert Show to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'region': region,
      'date': date,
      'reglement': reglement,
      'judgeId': judgeId,
      'designerId': designerId,
    };
  }

  // Create Show from Firestore document
  factory Show.fromFirestore(Map<String, dynamic> data, String? id) {
    return Show(
      id: id,
      nom: data['nom'] ?? '',
      region: data['region'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reglement: data['reglement'] ?? '',
      judgeId: data['judgeId'] ?? '',
      designerId: data['designerId'] ?? '',
    );
  }

  // Create copy with updated fields
  Show copyWith({
    String? id,
    String? nom,
    String? region,
    DateTime? date,
    String? reglement,
    String? judgeId,
    String? designerId,
  }) {
    return Show(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      region: region ?? this.region,
      date: date ?? this.date,
      reglement: reglement ?? this.reglement,
      judgeId: judgeId ?? this.judgeId,
      designerId: designerId ?? this.designerId,
    );
  }
}
