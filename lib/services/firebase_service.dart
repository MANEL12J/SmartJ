// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../models/user.dart';
import '../models/rider.dart';
import '../models/horse.dart';
import '../models/show.dart';
import '../models/competition.dart';
import '../models/event.dart';
import '../models/participation.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // AUTHENTICATION METHODS
  Future<auth.UserCredential?> signIn(String licence, String password) async {
    try {
      // For demo purposes, we'll use email authentication with licence as email
      String email = '$licence@equitation.com';
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Get user details from Firestore
        final doc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          return User.fromFirestore(doc.data()!, doc.id);
        }
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // USER METHODS
  Future<bool> emailExists(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  Future<bool> licenceExists(String licence) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('licence', isEqualTo: licence)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking licence: $e');
      return false;
    }
  }

  Future<String> addUser(User user) async {
    try {
      final docRef = await _firestore.collection('users').add(user.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding user: $e');
      throw e;
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => User.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  Future<List<User>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();
      return snapshot.docs
          .map((doc) => User.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => User.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  Future<List<Participation>> getAllParticipations() async {
    try {
      final snapshot = await _firestore.collection('participations').get();

      return snapshot.docs
          .map((doc) => Participation.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting all participations: $e');
      return [];
    }
  }

  // RIDER METHODS
  Future<String> addRider(Rider rider) async {
    try {
      final docRef = await _firestore.collection('riders').add(rider.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding rider: $e');
      throw e;
    }
  }

  Future<List<Rider>> getRiders() async {
    try {
      final snapshot = await _firestore.collection('riders').get();
      return snapshot.docs
          .map((doc) => Rider.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting riders: $e');
      return [];
    }
  }

  // HORSE METHODS
  Future<String> addHorse(Horse horse) async {
    try {
      final docRef = await _firestore.collection('horses').add(horse.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding horse: $e');
      throw e;
    }
  }

  Future<List<Horse>> getHorses() async {
    try {
      final snapshot = await _firestore.collection('horses').get();
      return snapshot.docs
          .map((doc) => Horse.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting horses: $e');
      return [];
    }
  }

  // SHOW METHODS
  Future<String> addShow(Show show) async {
    try {
      final docRef = await _firestore.collection('shows').add(show.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding show: $e');
      throw e;
    }
  }

  Future<List<Show>> getShows() async {
    try {
      final snapshot = await _firestore.collection('shows').get();
      return snapshot.docs
          .map((doc) => Show.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting shows: $e');
      return [];
    }
  }

  // COMPETITION METHODS
  Future<String> addCompetition(Competition competition) async {
    try {
      final docRef =
          await _firestore.collection('competitions').add(competition.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding competition: $e');
      throw e;
    }
  }

  Future<List<Competition>> getCompetitions() async {
    try {
      final snapshot = await _firestore.collection('competitions').get();
      return snapshot.docs
          .map((doc) => Competition.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting competitions: $e');
      return [];
    }
  }

  Future<List<Competition>> getCompetitionsByShow(String showId) async {
    try {
      final snapshot = await _firestore
          .collection('competitions')
          .where('showId', isEqualTo: showId)
          .get();
      return snapshot.docs
          .map((doc) => Competition.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting competitions by show: $e');
      return [];
    }
  }

  // EVENT METHODS
  Future<String> addEvent(Event event) async {
    try {
      final docRef = await _firestore.collection('events').add(event.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding event: $e');
      throw e;
    }
  }

  Future<List<Event>> getEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      return snapshot.docs
          .map((doc) => Event.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting events: $e');
      return [];
    }
  }

  Future<List<Event>> getEventsByCompetition(String competitionId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('competitionId', isEqualTo: competitionId)
          .get();
      return snapshot.docs
          .map((doc) => Event.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting events by competition: $e');
      return [];
    }
  }

  // PARTICIPATION METHODS
  Future<String> addParticipation(Participation participation) async {
    try {
      final docRef = await _firestore
          .collection('participations')
          .add(participation.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding participation: $e');
      throw e;
    }
  }

  Future<List<Participation>> getParticipations() async {
    try {
      final snapshot = await _firestore.collection('participations').get();
      return snapshot.docs
          .map((doc) => Participation.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting participations: $e');
      return [];
    }
  }

  Future<List<Participation>> getParticipationsByEvent(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('participations')
          .where('eventId', isEqualTo: eventId)
          .get();
      final participations = snapshot.docs
          .map((doc) => Participation.fromFirestore(doc.data(), doc.id))
          .toList();
      // Sort by ordrePassage in Dart to avoid needing a Firestore composite index
      participations.sort((a, b) => a.ordrePassage.compareTo(b.ordrePassage));
      return participations;
    } catch (e) {
      print('Error getting participations by event: $e');
      return [];
    }
  }

  Future<void> updateParticipationStatus(
      String participationId, String status) async {
    try {
      await _firestore
          .collection('participations')
          .doc(participationId)
          .update({
        'statut': status,
      });
    } catch (e) {
      print('Error updating participation status: $e');
      throw e;
    }
  }

  Future<void> updateParticipationScore(
      String participationId, double score) async {
    try {
      await _firestore
          .collection('participations')
          .doc(participationId)
          .update({
        'score': score,
      });
    } catch (e) {
      print('Error updating participation score: $e');
      throw e;
    }
  }

  Future<void> updateParticipationScoreAndStatus(
      String participationId, double score, String status) async {
    try {
      await _firestore
          .collection('participations')
          .doc(participationId)
          .update({
        'score': score,
        'statut': status,
      });
    } catch (e) {
      print('Error updating participation score and status: $e');
      throw e;
    }
  }

  Future<Rider?> getRiderById(String riderId) async {
    try {
      final doc = await _firestore.collection('riders').doc(riderId).get();
      if (doc.exists) {
        return Rider.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting rider by id: $e');
      return null;
    }
  }

  Future<Horse?> getHorseById(String horseId) async {
    try {
      final doc = await _firestore.collection('horses').doc(horseId).get();
      if (doc.exists) {
        return Horse.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting horse by id: $e');
      return null;
    }
  }

  // ADMIN INITIALIZATION
  Future<void> createDefaultAdmin() async {
    try {
      // Quick check if admin already exists (limit to 1 result for speed)
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        print('Admin user already exists');
        return;
      }

      // Create default admin user
      final adminUser = User(
        nom: 'Admin',
        prenom: 'System',
        role: 'admin',
        email: 'admin@equitation.com',
        licence: 'admin',
        password: 'admin123',
      );

      await addUser(adminUser);
      print('Default admin user created successfully');
    } catch (e) {
      print('Error creating default admin: $e');
      // Don't rethrow - allow app to continue
    }
  }

  Future<bool> isAdminLogin(String licence, String password) async {
    return licence == 'admin' && password == 'admin123';
  }

  Future<User?> authenticateUser(String licence, String password) async {
    try {
      print(
          'DEBUG: Tentative auth pour licence: $licence, password: $password');

      final snapshot = await _firestore
          .collection('users')
          .where('licence', isEqualTo: licence)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      print('DEBUG: Snapshot docs trouvés: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        print('DEBUG: User data trouvée: $userData');
        final user = User.fromFirestore(userData, snapshot.docs.first.id);
        print('DEBUG: User créé avec rôle: ${user.role}');
        return user;
      }

      print('DEBUG: Aucun utilisateur trouvé');
      return null;
    } catch (e) {
      print('Error authenticating user: $e');
      return null;
    }
  }

  // UTILITY METHODS
  String generatePassword(String nom, String licence) {
    // Generate password: nom + last 3 digits of licence
    String lastThreeDigits =
        licence.length >= 3 ? licence.substring(licence.length - 3) : licence;
    return '${nom.toLowerCase()}$lastThreeDigits';
  }

  Future<String> getUserNameById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        final nom = userData['nom'] ?? '';
        final prenom = userData['prenom'] ?? '';
        return '$prenom $nom';
      }
      return 'Utilisateur inconnu';
    } catch (e) {
      print('Error getting user name: $e');
      return 'Erreur';
    }
  }

  Future<String> getCompetitionNameById(String competitionId) async {
    try {
      final doc =
          await _firestore.collection('competitions').doc(competitionId).get();
      if (doc.exists) {
        final competitionData = doc.data() as Map<String, dynamic>;
        return competitionData['nom'] ?? 'Compétition inconnue';
      }
      return 'Compétition inconnue';
    } catch (e) {
      print('Error getting competition name: $e');
      return 'Erreur';
    }
  }

  Future<bool> checkShowExistsByDate(DateTime date) async {
    try {
      // Create date boundaries for the entire day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('shows')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking show exists by date: $e');
      return false;
    }
  }

  Future<int> getNextOrdrePassage(String eventId) async {
    try {
      final participations = await getParticipationsByEvent(eventId);
      if (participations.isEmpty) {
        return 1;
      }
      return participations
              .map((p) => p.ordrePassage)
              .reduce((a, b) => a > b ? a : b) +
          1;
    } catch (e) {
      print('Error getting next ordre passage: $e');
      return 1;
    }
  }

  Future<bool> canRiderPassAgain(String riderId, String eventId) async {
    try {
      final participations = await getParticipationsByEvent(eventId);
      final riderParticipations =
          participations.where((p) => p.riderId == riderId).toList();

      if (riderParticipations.isEmpty) {
        return true;
      }

      final lastPassage = riderParticipations
          .where((p) => p.statut == 'passe')
          .map((p) => p.ordrePassage)
          .toList();

      if (lastPassage.isEmpty) {
        return true;
      }

      final maxOrdre = participations
          .map((p) => p.ordrePassage)
          .reduce((a, b) => a > b ? a : b);
      final lastRiderOrdre = lastPassage.reduce((a, b) => a > b ? a : b);

      return (maxOrdre - lastRiderOrdre) >= 10;
    } catch (e) {
      print('Error checking if rider can pass again: $e');
      return false;
    }
  }

  // TRACE UPLOAD METHODS (GRATUIT - Base64 dans Firestore)
  Future<bool> uploadTrace(PlatformFile file, String showId) async {
    try {
      // Convertir le fichier en base64
      String base64String;
      if (file.bytes != null) {
        base64String = base64Encode(file.bytes!);
      } else if (file.path != null) {
        final bytes = await File(file.path!).readAsBytes();
        base64String = base64Encode(bytes);
      } else {
        throw Exception('Aucune donnée de fichier disponible');
      }

      // Vérifier la taille du fichier (limite de 1MB pour Firestore)
      if (base64String.length > 1400000) {
        // ~1MB en base64
        throw Exception('Le fichier est trop volumineux (max 1MB)');
      }

      // Sauvegarder dans Firestore
      await _firestore.collection('shows').doc(showId).update({
        'traceData': base64String,
        'traceFileName': file.name,
        'traceExtension': file.extension?.toLowerCase() ?? 'pdf',
        'traceUploadedAt': DateTime.now(),
      });

      return true;
    } catch (e) {
      print('Error uploading trace: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTraceData(String showId) async {
    try {
      final doc = await _firestore.collection('shows').doc(showId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('traceData') && data['traceData'] != null) {
          return {
            'data': data['traceData'],
            'fileName': data['traceFileName'] ?? 'tracé',
            'extension': data['traceExtension'] ?? 'pdf',
          };
        }
      }
      return null;
    } catch (e) {
      print('Error getting trace data: $e');
      return null;
    }
  }

  Future<bool> hasTrace(String showId) async {
    final traceData = await getTraceData(showId);
    return traceData != null;
  }

  Future<String?> downloadTraceAsBase64(String showId) async {
    final traceData = await getTraceData(showId);
    return traceData?['data'];
  }

  Future<Map<String, dynamic>?> getTraceWithMetadata(String showId) async {
    return await getTraceData(showId);
  }

  // Récupérer les épreuves des shows assignés à un designer (Shows → Compétitions → Épreuves)
  Future<List<Map<String, dynamic>>> getEventsForDesignerShows(
      List<String> showIds) async {
    try {
      if (showIds.isEmpty) {
        return [];
      }

      List<Map<String, dynamic>> allEvents = [];

      // Pour chaque show, récupérer les compétitions puis les épreuves
      for (String showId in showIds) {
        // Récupérer les compétitions du show
        final competitionsSnapshot = await _firestore
            .collection('competitions')
            .where('showId', isEqualTo: showId)
            .get();

        // Pour chaque compétition, récupérer les épreuves (sans orderBy pour éviter l'erreur d'index)
        for (var competitionDoc in competitionsSnapshot.docs) {
          final competitionId = competitionDoc.id;

          final eventsSnapshot = await _firestore
              .collection('events')
              .where('competitionId', isEqualTo: competitionId)
              .get();

          // Ajouter les épreuves avec les informations du show et de la compétition
          for (var eventDoc in eventsSnapshot.docs) {
            final eventData = eventDoc.data();
            eventData['id'] = eventDoc.id;
            eventData['showId'] = showId;
            eventData['competitionId'] = competitionId;
            allEvents.add(eventData);
          }
        }
      }

      // Trier toutes les épreuves par date (coté client)
      allEvents.sort((a, b) {
        final dateA = (a['date'] as Timestamp).toDate();
        final dateB = (b['date'] as Timestamp).toDate();
        return dateA.compareTo(dateB);
      });

      return allEvents;
    } catch (e) {
      print('Error getting events for designer shows: $e');
      return [];
    }
  }

  // Récupérer le nom du show par son ID
  Future<String?> getShowNameById(String showId) async {
    try {
      final doc = await _firestore.collection('shows').doc(showId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['nom'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting show name: $e');
      return null;
    }
  }

  // Upload un tracé pour une épreuve spécifique
  Future<bool> uploadEventTrace(PlatformFile file, String eventId) async {
    try {
      // Vérifier la taille du fichier (limite ~1MB pour base64)
      if (file.size > 1024 * 1024) {
        print('File too large: ${file.size} bytes');
        return false;
      }

      // Lire le fichier et le convertir en base64
      Uint8List? bytes;
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      } else {
        print('No file data available');
        return false;
      }

      final base64String = base64Encode(bytes);
      final extension = file.extension?.toLowerCase() ?? 'pdf';

      // Mettre à jour le document de l'épreuve avec les données du tracé
      await _firestore.collection('events').doc(eventId).update({
        'trace': {
          'data': base64String,
          'fileName': file.name,
          'extension': extension,
          'uploadedAt': Timestamp.now(),
        }
      });

      print('Event trace uploaded successfully for event: $eventId');
      return true;
    } catch (e) {
      print('Error uploading event trace: $e');
      return false;
    }
  }

  // Récupérer les données du tracé d'une épreuve
  Future<Map<String, dynamic>?> getEventTraceData(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['trace'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting event trace data: $e');
      return null;
    }
  }

  // Vérifier si une épreuve a un tracé
  Future<bool> hasEventTrace(String eventId) async {
    final traceData = await getEventTraceData(eventId);
    return traceData != null;
  }

  // Télécharger le tracé d'une épreuve en base64
  Future<String?> downloadEventTraceAsBase64(String eventId) async {
    final traceData = await getEventTraceData(eventId);
    return traceData?['data'];
  }

  // Upload la liste des engagés pour une épreuve et créer les Participation records
  Future<bool> uploadEngagesList(PlatformFile file, String eventId) async {
    try {
      if (file.size > 1024 * 1024) {
        print('File too large: ${file.size} bytes');
        return false;
      }

      Uint8List? bytes;
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      } else {
        print('No file data available');
        return false;
      }

      final base64String = base64Encode(bytes);
      final extension = file.extension?.toLowerCase() ?? 'xlsx';

      // Save the raw file to the event document
      await _firestore.collection('events').doc(eventId).update({
        'engagesList': {
          'data': base64String,
          'fileName': file.name,
          'extension': extension,
          'uploadedAt': Timestamp.now(),
        }
      });

      // Parse the file and create Participation records
      await _parseAndCreateParticipations(bytes, extension, eventId);

      print('Engagés list uploaded successfully for event: $eventId');
      return true;
    } catch (e) {
      print('Error uploading engagés list: $e');
      return false;
    }
  }

  // Parse Excel/CSV file and create Participation records
  Future<void> _parseAndCreateParticipations(
      Uint8List bytes, String extension, String eventId) async {
    try {
      // Delete existing participations for this event first
      final existingSnapshot = await _firestore
          .collection('participations')
          .where('eventId', isEqualTo: eventId)
          .get();

      for (var doc in existingSnapshot.docs) {
        await doc.reference.delete();
      }

      List<List<String>> rows = [];

      if (extension == 'csv') {
        // Parse CSV
        final content = utf8.decode(bytes);
        final lines = content.split('\n');
        for (var line in lines) {
          final row = line.split(',').map((e) => e.trim()).toList();
          if (row.any((e) => e.isNotEmpty)) {
            rows.add(row);
          }
        }
      } else {
        // Parse Excel (xlsx, xls)
        try {
          final excel = Excel.decodeBytes(bytes);
          for (var table in excel.tables.keys) {
            final sheet = excel.tables[table];
            if (sheet == null) continue;
            for (var row in sheet.rows) {
              final rowData =
                  row.map((cell) => cell?.value?.toString() ?? '').toList();
              if (rowData.any((e) => e.isNotEmpty)) {
                rows.add(rowData);
              }
            }
            break; // Only use first sheet
          }
        } catch (excelError) {
          print('Excel package error, trying manual xlsx parser: $excelError');
          // Manual xlsx parser: xlsx is a ZIP file containing XML
          try {
            rows = _parseXlsxManually(bytes);
          } catch (manualError) {
            print('Manual xlsx parser also failed: $manualError');
          }
        }
      }

      if (rows.isEmpty) return;

      // Determine column indices from header row
      // Expected columns: Ordre, Nom Cavalier, Prénom, Cheval, Club (or similar)
      int ordreIdx = 0;
      int nomIdx = 1;
      int prenomIdx = 2;
      int chevalIdx = 3;
      int clubIdx = 4;
      bool hasHeader = false;

      if (rows.isNotEmpty) {
        final firstRow = rows[0].map((e) => e.toLowerCase()).toList();
        // Try to detect header
        for (int i = 0; i < firstRow.length; i++) {
          final col = firstRow[i];
          if (col.contains('ordre') ||
              col.contains('num') ||
              col.contains('n°') ||
              col.contains('#')) ordreIdx = i;
          if (col.contains('nom') &&
              !col.contains('cheval') &&
              !col.contains('prenom')) nomIdx = i;
          if (col.contains('prenom') || col.contains('prénom')) prenomIdx = i;
          if (col.contains('cheval') || col.contains('horse')) chevalIdx = i;
          if (col.contains('club')) clubIdx = i;
        }
        // Check if first row looks like a header
        hasHeader = firstRow.any((e) =>
            e.contains('ordre') ||
            e.contains('nom') ||
            e.contains('prenom') ||
            e.contains('cheval') ||
            e.contains('club'));
      }

      final dataRows = hasHeader ? rows.sublist(1) : rows;

      // Get existing riders and horses for matching
      final riders = await getRiders();
      final horses = await getHorses();

      int ordrePassage = 1;
      for (var row in dataRows) {
        if (row.isEmpty || row.every((e) => e.isEmpty)) continue;

        // Extract data from row
        final ordreStr = ordreIdx < row.length ? row[ordreIdx] : '';
        final nomCavalier = nomIdx < row.length ? row[nomIdx] : '';
        final prenomCavalier = prenomIdx < row.length ? row[prenomIdx] : '';
        final nomCheval = chevalIdx < row.length ? row[chevalIdx] : '';
        final clubCavalier = clubIdx < row.length ? row[clubIdx] : '';

        if (nomCavalier.isEmpty && prenomCavalier.isEmpty) continue;

        // Try to find existing rider by name
        String riderId = '';
        Rider? existingRider = riders.firstWhere(
          (r) =>
              r.nom.toLowerCase() == nomCavalier.toLowerCase() &&
              r.prenom.toLowerCase() == prenomCavalier.toLowerCase(),
          orElse: () => Rider(nom: '', prenom: '', club: '', telephone: ''),
        );

        if (existingRider.nom.isNotEmpty) {
          riderId = existingRider.id!;
        } else {
          // Create new rider
          final newRider = Rider(
            nom: nomCavalier,
            prenom: prenomCavalier,
            club: clubCavalier,
            telephone: '',
          );
          riderId = await addRider(newRider);
          riders.add(newRider.copyWith(id: riderId));
        }

        // Try to find existing horse by name
        String horseId = '';
        Horse? existingHorse = horses.firstWhere(
          (h) => h.nom.toLowerCase() == nomCheval.toLowerCase(),
          orElse: () => Horse(nom: '', sexe: '', age: 0, race: ''),
        );

        if (existingHorse.nom.isNotEmpty) {
          horseId = existingHorse.id!;
        } else if (nomCheval.isNotEmpty) {
          // Create new horse
          final newHorse = Horse(
            nom: nomCheval,
            sexe: '',
            age: 0,
            race: '',
          );
          horseId = await addHorse(newHorse);
          horses.add(newHorse.copyWith(id: horseId));
        }

        // Parse ordre de passage
        int passageOrder = int.tryParse(ordreStr) ?? ordrePassage;

        // Create participation record
        final participation = Participation(
          riderId: riderId,
          horseId: horseId,
          eventId: eventId,
          ordrePassage: passageOrder,
          statut: 'en_attente',
          score: 0.0,
        );

        await addParticipation(participation);
        ordrePassage++;
      }

      print('Participations created from engagés list for event: $eventId');
    } catch (e) {
      print('Error parsing engagés list: $e');
    }
  }

  // Manual xlsx parser: decompress ZIP and read sheet1.xml
  List<List<String>> _parseXlsxManually(Uint8List bytes) {
    final rows = <List<String>>[];

    // xlsx is a ZIP archive
    final archive = ZipDecoder().decodeBytes(bytes);

    // Find the first sheet file: xl/worksheets/sheet1.xml
    String sheetPath = '';
    for (var file in archive.files) {
      final name = file.name.toLowerCase();
      if (name.startsWith('xl/worksheets/sheet') && name.endsWith('.xml')) {
        sheetPath = file.name;
        break;
      }
    }

    if (sheetPath.isEmpty) {
      print('No sheet found in xlsx archive');
      return rows;
    }

    // Read shared strings (xl/sharedStrings.xml)
    final sharedStrings = <String>[];
    for (var file in archive.files) {
      if (file.name.toLowerCase() == 'xl/sharedstrings.xml') {
        final content = String.fromCharCodes(file.content as List<int>);
        final doc = XmlDocument.parse(content);
        final siElements = doc.findAllElements('si');
        for (var si in siElements) {
          // Get all <t> text elements within <si> (handles rich text)
          final tElements = si.findAllElements('t');
          final text = tElements.map((t) => t.innerText).join('');
          sharedStrings.add(text);
        }
        break;
      }
    }

    // Parse sheet1.xml
    final sheetFile = archive.files.firstWhere((f) => f.name == sheetPath);
    final sheetContent = String.fromCharCodes(sheetFile.content as List<int>);
    final sheetDoc = XmlDocument.parse(sheetContent);

    final rowElements = sheetDoc.findAllElements('row');
    for (var rowElem in rowElements) {
      final rowData = <String>[];
      final cellElements = rowElem.findAllElements('c');

      for (var cellElem in cellElements) {
        // Get cell reference like "A1", "B3" to determine column index
        final ref = cellElem.getAttribute('r') ?? '';
        int colIndex = _colFromRef(ref);

        // Fill gaps with empty strings
        while (rowData.length < colIndex) {
          rowData.add('');
        }

        // Get cell value
        final type = cellElem.getAttribute('t');
        String value = '';

        if (type == 's') {
          // Shared string
          final vElem = cellElem.findElements('v').firstOrNull;
          if (vElem != null) {
            final idx = int.tryParse(vElem.innerText) ?? -1;
            if (idx >= 0 && idx < sharedStrings.length) {
              value = sharedStrings[idx];
            }
          }
        } else {
          // Inline string or number
          final vElem = cellElem.findElements('v').firstOrNull;
          if (vElem != null) {
            value = vElem.innerText;
          } else {
            // Check for inline string <is><t>
            final isElem = cellElem.findElements('is').firstOrNull;
            if (isElem != null) {
              final tElem = isElem.findElements('t').firstOrNull;
              if (tElem != null) {
                value = tElem.innerText;
              }
            }
          }
        }

        if (rowData.length == colIndex) {
          rowData.add(value);
        } else if (colIndex < rowData.length) {
          rowData[colIndex] = value;
        }
      }

      if (rowData.any((e) => e.isNotEmpty)) {
        rows.add(rowData);
      }
    }

    return rows;
  }

  // Convert cell reference like "A1" to column index (0-based)
  int _colFromRef(String ref) {
    final letters = ref.replaceAll(RegExp(r'[0-9]'), '');
    int col = 0;
    for (int i = 0; i < letters.length; i++) {
      col = col * 26 + (letters.codeUnitAt(i) - 'A'.codeUnitAt(0) + 1);
    }
    return col - 1; // 0-based
  }

  // Récupérer les données de la liste des engagés d'une épreuve
  Future<Map<String, dynamic>?> getEngagesListData(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['engagesList'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting engagés list data: $e');
      return null;
    }
  }

  // Vérifier si une épreuve a une liste des engagés
  Future<bool> hasEngagesList(String eventId) async {
    final data = await getEngagesListData(eventId);
    return data != null;
  }
}
