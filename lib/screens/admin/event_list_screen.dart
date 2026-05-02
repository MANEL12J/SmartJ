import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event.dart';
import '../../services/firebase_service.dart';
import 'add_event_screen.dart'; 
import '../designer/event_trace_viewer_dialog.dart';
import 'engages_list_viewer_dialog.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  Stream<List<Event>> _getEventsStream() {
    return FirebaseFirestore.instance
        .collection('events')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Épreuves'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Event>>(
        stream: _getEventsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_gymnastics_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune épreuve trouvée',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez votre première épreuve pour commencer',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Le StreamBuilder se mettra à jour automatiquement
            },
            child: Column(
              children: [
                // En-tête du tableau
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        // Colonne Nom
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.3))),
                            ),
                            child: const Text(
                              'Nom',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        // Colonne Date
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.3))),
                            ),
                            child: const Text(
                              'Date',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        // Colonne Heure
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.3))),
                            ),
                            child: const Text(
                              'Heure',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        // Colonne Hauteur
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.3))),
                            ),
                            child: const Text(
                              'Hauteur',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        // Colonne Carrière
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.3))),
                            ),
                            child: const Text(
                              'Carrière',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        // Colonne Barème
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.3))),
                            ),
                            child: const Text(
                              'Barème',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        // Colonne Compétition
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.3))),
                            ),
                            child: const Text(
                              'Compétition',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        // Colonne Actions
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Text(
                              'Actions',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Liste des épreuves
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _buildEventListCard(event);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEventScreen(),
            ),
          );
          // Pas besoin de recharger manuellement, le StreamBuilder le fera automatiquement
        },
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventListCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colonne Nom
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Colonne Date
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${event.date.day}/${event.date.month}/${event.date.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            
            // Colonne Heure
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event.heure,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            
            // Colonne Hauteur
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${event.hauteur}m',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            
            // Colonne Carrière
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event.carriere,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Colonne Barème
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.bareme,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Colonne Compétition
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder<String>(
                      future: _firebaseService.getCompetitionNameById(event.competitionId),
                      builder: (context, snapshot) {
                        return Row(
                          children: [
                            Icon(Icons.emoji_events, size: 14, color: Colors.purple[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                snapshot.data ?? 'Chargement...',
                                style: TextStyle(fontSize: 12, color: Colors.purple[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Colonne Actions
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  alignment: WrapAlignment.start,
                  children: [
                    // Bouton Voir liste des engagés
                    FutureBuilder<bool>(
                      future: _firebaseService.hasEngagesList(event.id ?? ''),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return ElevatedButton.icon(
                            onPressed: () async {
                              final engagesData = await _firebaseService
                                  .getEngagesListData(event.id ?? '');
                              if (engagesData != null && mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => EngagesListViewerDialog(
                                    engagesData: engagesData,
                                    eventName: event.nom,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.table_chart, size: 12),
                            label: const Text('Voir', style: TextStyle(fontSize: 10)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              minimumSize: const Size(40, 24),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    // Bouton Upload liste des engagés
                    FutureBuilder<bool>(
                      future: _firebaseService.hasEngagesList(event.id ?? ''),
                      builder: (context, snapshot) {
                        final hasEngages = snapshot.data ?? false;
                        return ElevatedButton.icon(
                          onPressed: () => _uploadEngagesList(event),
                          icon: const Icon(Icons.upload_file, size: 12),
                          label: Text(
                            hasEngages ? 'Modifier Engager' : 'Importer Engager',
                            style: const TextStyle(fontSize: 10),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasEngages ? Colors.orange[700] : Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            minimumSize: const Size(80, 24),
                          ),
                        );
                      },
                    ),
                    // Bouton Voir tracé
                    FutureBuilder<bool>(
                      future: _firebaseService.hasEventTrace(event.id ?? ''),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return ElevatedButton.icon(
                            onPressed: () async {
                              final traceData = await _firebaseService
                                  .getEventTraceData(event.id ?? '');
                              if (traceData != null && mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => EventTraceViewerDialog(
                                    traceData: traceData,
                                    eventName: event.nom,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.map, size: 12),
                            label: const Text('Tracé', style: TextStyle(fontSize: 10)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 75, 73, 122),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              minimumSize: const Size(45, 24),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildEventDataRow(Event event) {
    return DataRow(
      color: WidgetStateProperty.all(Colors.white),
      cells: [
        DataCell(
          SizedBox(
            width: 150,
            child: Text(
              event.nom,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 120,
            child: Text(
              '${event.date.day}/${event.date.month}/${event.date.year}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 80,
            child: Text(
              event.heure,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 80,
            child: Text(
              '${event.hauteur}m',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Text(
              event.carriere,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                event.bareme,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 120,
            child: FutureBuilder<String>(
              future: _firebaseService.getCompetitionNameById(event.competitionId),
              builder: (context, snapshot) {
                return Row(
                  children: [
                    Icon(Icons.emoji_events, size: 14, color: Colors.purple[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        snapshot.data ?? 'Chargement...',
                        style: TextStyle(fontSize: 12, color: Colors.purple[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 280,
            child: Wrap(
              spacing: 4,
              runSpacing: 2,
              children: [
                // Bouton Voir liste des engagés
                FutureBuilder<bool>(
                  future: _firebaseService.hasEngagesList(event.id ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return ElevatedButton.icon(
                        onPressed: () async {
                          final engagesData = await _firebaseService
                              .getEngagesListData(event.id ?? '');
                          if (engagesData != null && mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => EngagesListViewerDialog(
                                engagesData: engagesData,
                                eventName: event.nom,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.table_chart, size: 12),
                        label: const Text('Voir', style: TextStyle(fontSize: 10)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          minimumSize: const Size(40, 24),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                // Bouton Upload liste des engagés
                ElevatedButton.icon(
                  onPressed: () => _uploadEngagesList(event),
                  icon: const Icon(Icons.upload_file, size: 12),
                  label: const Text('Importer Engager', style: TextStyle(fontSize: 10)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    minimumSize: const Size(80, 24),
                  ),
                ),
                // Bouton Voir tracé
                FutureBuilder<bool>(
                  future: _firebaseService.hasEventTrace(event.id ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return ElevatedButton.icon(
                        onPressed: () async {
                          final traceData = await _firebaseService
                              .getEventTraceData(event.id ?? '');
                          if (traceData != null && mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => EventTraceViewerDialog(
                                traceData: traceData,
                                eventName: event.nom,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.map, size: 12),
                        label: const Text('Tracé', style: TextStyle(fontSize: 10)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          minimumSize: const Size(45, 24),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _uploadEngagesList(Event event) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv', 'pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final success =
            await _firebaseService.uploadEngagesList(file, event.id ?? '');

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Liste des engagés uploadée pour ${event.nom}'),
              backgroundColor: Colors.green,
            ),
          );
          // Le StreamBuilder détectera automatiquement les changements
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'upload de la liste des engagés'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event.nom),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Date: ${event.date.day}/${event.date.month}/${event.date.year}'),
                Text('Heure: ${event.heure}'),
                Text('Barème: ${event.bareme}'),
                Text('Hauteur: ${event.hauteur}m'),
                Text('Carrière: ${event.carriere}'),
                FutureBuilder<String>(
                  future: _firebaseService
                      .getCompetitionNameById(event.competitionId),
                  builder: (context, snapshot) {
                    return Text(
                        'Compétition: ${snapshot.data ?? 'Chargement...'}');
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Actions disponibles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Gérer les participations\n• Voir l\'ordre de passage\n• Saisir les résultats',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
