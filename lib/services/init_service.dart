// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'firebase_service.dart';
import '../models/user.dart';
import '../models/rider.dart';
import '../models/horse.dart';

class InitService {
  static final FirebaseService _firebaseService = FirebaseService();

  static Future<void> initializeApp() async {
    try {
      // Just initialize Firebase, no admin creation
      await Firebase.initializeApp();
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      // Continue even if Firebase fails
    }
  }

  static Future<void> createSampleData() async {
    try {
      // Create sample judges
      await _createSampleJudge('Dupont', 'Jean', 'judge001');
      await _createSampleJudge('Martin', 'Sophie', 'judge002');

      // Create sample designers
      await _createSampleDesigner('Bernard', 'Pierre', 'designer001');
      await _createSampleDesigner('Petit', 'Marie', 'designer002');

      // Create sample riders
      await _createSampleRider('Durand', 'Paul', 'Equestre Club', '0123456789');
      await _createSampleRider(
          'Lefebvre', 'Claire', 'Horse Center', '0234567890');

      // Create sample horses
      await _createSampleHorse('Jolly Jumper', 'Mâle', 8, 'Selle Français');
      await _createSampleHorse('Bella', 'Femelle', 6, 'Anglo-Arabe');

      print('Sample data created successfully');
    } catch (e) {
      print('Error creating sample data: $e');
    }
  }

  static Future<void> _createSampleJudge(
      String nom, String prenom, String licence) async {
    try {
      final existingJudges = await _firebaseService.getUsersByRole('judge');
      final exists = existingJudges.any((user) => user.licence == licence);

      if (!exists) {
        final judge = User(
          nom: nom,
          prenom: prenom,
          role: 'judge',
          email: '$licence@equitation.com',
          licence: licence,
          password:
              '${nom.toLowerCase()}${licence.substring(licence.length - 3)}',
        );
        await _firebaseService.addUser(judge);
        print('Sample judge $prenom $nom created');
      }
    } catch (e) {
      print('Error creating sample judge: $e');
    }
  }

  static Future<void> _createSampleDesigner(
      String nom, String prenom, String licence) async {
    try {
      final existingDesigners =
          await _firebaseService.getUsersByRole('designer');
      final exists = existingDesigners.any((user) => user.licence == licence);

      if (!exists) {
        final designer = User(
          nom: nom,
          prenom: prenom,
          role: 'designer',
          email: '$licence@equitation.com',
          licence: licence,
          password:
              '${nom.toLowerCase()}${licence.substring(licence.length - 3)}',
        );
        await _firebaseService.addUser(designer);
        print('Sample designer $prenom $nom created');
      }
    } catch (e) {
      print('Error creating sample designer: $e');
    }
  }

  static Future<void> _createSampleRider(
      String nom, String prenom, String club, String telephone) async {
    try {
      final rider = Rider(
        nom: nom,
        prenom: prenom,
        club: club,
        telephone: telephone,
      );
      await _firebaseService.addRider(rider);
      print('Sample rider $prenom $nom created');
    } catch (e) {
      print('Error creating sample rider: $e');
    }
  }

  static Future<void> _createSampleHorse(
      String nom, String sexe, int age, String race) async {
    try {
      final horse = Horse(
        nom: nom,
        sexe: sexe,
        age: age,
        race: race,
      );
      await _firebaseService.addHorse(horse);
      print('Sample horse $nom created');
    } catch (e) {
      print('Error creating sample horse: $e');
    }
  }
}
