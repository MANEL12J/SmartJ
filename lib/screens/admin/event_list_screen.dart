import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _firebaseService.getEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erreur lors du chargement des épreuves: $e');
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _events.isEmpty
              ? Center(
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
                )
              : RefreshIndicator(
                  onRefresh: _loadEvents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return _buildEventCard(event);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEventScreen(),
            ),
          );
          _loadEvents();
        },
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          _showEventDetails(event);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.nom,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.bareme,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${event.date.day}/${event.date.month}/${event.date.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event.heure,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.height,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${event.hauteur}m',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.stadium,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event.carriere,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<bool>(
                future: _firebaseService.hasEventTrace(event.id ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton.icon(
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
                        icon: const Icon(Icons.map, size: 16),
                        label: const Text('Voir le tracé'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange[700],
                          side: BorderSide(color: Colors.orange[700]!),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              FutureBuilder<String>(
                future: _firebaseService
                    .getCompetitionNameById(event.competitionId),
                builder: (context, snapshot) {
                  return Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: Colors.purple[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Compétition: ${snapshot.data ?? 'Chargement...'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.purple[600],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              // Boutons Upload et Voir liste des engagés (alignés à droite)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Bouton Voir liste des engagés
                  FutureBuilder<bool>(
                    future: _firebaseService.hasEngagesList(event.id ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: OutlinedButton.icon(
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
                            icon: const Icon(Icons.table_chart, size: 16),
                            label: const Text('Voir'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue[700],
                              side: BorderSide(color: Colors.blue[700]!),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // Bouton Upload liste des engagés
                  OutlinedButton.icon(
                    onPressed: () => _uploadEngagesList(event),
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: const Text('Engagés'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: BorderSide(color: Colors.green[700]!),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
          setState(() {});
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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
