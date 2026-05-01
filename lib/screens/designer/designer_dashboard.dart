import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/show.dart';
import '../../services/firebase_service.dart';
import '../../services/session_service.dart';
import 'trace_viewer_dialog.dart';
import 'event_trace_viewer_dialog.dart';

class DesignerDashboard extends StatefulWidget {
  const DesignerDashboard({super.key});

  @override
  State<DesignerDashboard> createState() => _DesignerDashboardState();
}

class _DesignerDashboardState extends State<DesignerDashboard> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _designerEvents = [];
  List<Show> _shows = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final shows = await _firebaseService.getShows();
      final showIds = shows.map((show) => show.id!).toList();
      final events = await _firebaseService.getEventsForDesignerShows(showIds);

      setState(() {
        _shows = shows;
        _designerEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erreur lors du chargement: $e');
    }
  }

  void _onMenuSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.orange[800],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.orange[900],
            ),
            child: Row(
              children: [
                Icon(Icons.design_services, size: 32, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Smart Jump Judge',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Espace Designer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[200],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  index: 0,
                  icon: Icons.sports_gymnastics,
                  label: 'Épreuves',
                ),
              ],
            ),
          ),

          // Logout
          Divider(color: Colors.orange[600], height: 1),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onMenuSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          border: isSelected
              ? Border(left: BorderSide(color: Colors.white, width: 4))
              : Border(left: BorderSide(color: Colors.transparent, width: 4)),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.orange[200]),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.orange[200],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _logout,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.logout, size: 20, color: Colors.red[300]),
            const SizedBox(width: 12),
            Text(
              'Déconnexion',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return _buildEventsContent();
  }

  Widget _buildShowsContent() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.event, size: 28, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Text(
                  'Shows',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadData,
                  color: Colors.orange[700],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _shows.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('Aucun show trouvé',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _shows.length,
                          itemBuilder: (context, index) {
                            return _buildShowCard(_shows[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowCard(Show show) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    show.nom,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<bool>(
                  future: _firebaseService.hasTrace(show.id!),
                  builder: (context, snapshot) {
                    final hasTrace = snapshot.data ?? false;
                    return Icon(
                      hasTrace ? Icons.check_circle : Icons.upload_file,
                      size: 20,
                      color: hasTrace ? Colors.green : Colors.orange,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(show.region,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${show.date.day}/${show.date.month}/${show.date.year}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    show.reglement,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _uploadTrace(show),
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('Upload Tracé'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                ),
                const SizedBox(width: 8),
                FutureBuilder<bool>(
                  future: _firebaseService.hasTrace(show.id!),
                  builder: (context, snapshot) {
                    final hasTrace = snapshot.data ?? false;
                    return ElevatedButton.icon(
                      onPressed: hasTrace ? () => _viewTrace(show) : null,
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Voir Tracé'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            hasTrace ? Colors.blue[700] : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsContent() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.sports_gymnastics,
                    size: 28, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Text(
                  'Épreuves',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadData,
                  color: Colors.orange[700],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _designerEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sports_gymnastics_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('Aucune épreuve',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _designerEvents.length,
                          itemBuilder: (context, index) {
                            return _buildEventCard(_designerEvents[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final String eventName = event['nom'] ?? 'Épreuve sans nom';
    final String showId = event['showId'] ?? '';
    final String competitionId = event['competitionId'] ?? '';
    final String eventId = event['id'] ?? '';
    final DateTime eventDate = (event['date'] as Timestamp).toDate();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    eventName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<bool>(
                  future: _firebaseService.hasEventTrace(eventId),
                  builder: (context, snapshot) {
                    final hasTrace = snapshot.data ?? false;
                    return Icon(
                      hasTrace ? Icons.check_circle : Icons.upload_file,
                      size: 20,
                      color: hasTrace ? Colors.green : Colors.orange,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${eventDate.day}/${eventDate.month}/${eventDate.year}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FutureBuilder<String?>(
                  future: _firebaseService.getShowNameById(showId),
                  builder: (context, snapshot) {
                    final showName = snapshot.data ?? 'Show inconnu';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        showName,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                FutureBuilder<String?>(
                  future:
                      _firebaseService.getCompetitionNameById(competitionId),
                  builder: (context, snapshot) {
                    final competitionName =
                        snapshot.data ?? 'Compétition inconnue';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        competitionName,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _uploadEventTrace(event),
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: const Text('Upload Tracé'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FutureBuilder<bool>(
                  future: _firebaseService.hasEventTrace(eventId),
                  builder: (context, snapshot) {
                    final hasTrace = snapshot.data ?? false;
                    return Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            hasTrace ? () => _viewEventTrace(event) : null,
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Voir Tracé'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              hasTrace ? Colors.blue[700] : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadTrace(Show show) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        setState(() {
          _isLoading = true;
        });

        final success = await _firebaseService.uploadTrace(file, show.id!);

        if (success) {
          _showSuccess('Tracé uploadé avec succès!');
        } else {
          _showError('Erreur lors de l\'upload du tracé');
        }
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _viewTrace(Show show) async {
    try {
      final traceData = await _firebaseService.getTraceWithMetadata(show.id!);

      if (traceData == null) {
        _showError('Aucun tracé trouvé pour ce show');
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return TraceViewerDialog(
            traceData: traceData,
            showName: show.nom,
          );
        },
      );
    } catch (e) {
      _showError('Erreur lors de l\'ouverture du tracé: $e');
    }
  }

  Future<void> _uploadEventTrace(Map<String, dynamic> event) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final eventId = event['id'] ?? '';

        if (eventId.isEmpty) {
          _showError('ID d\'épreuve invalide');
          return;
        }

        setState(() {
          _isLoading = true;
        });

        final success = await _firebaseService.uploadEventTrace(file, eventId);

        if (success) {
          _showSuccess('Tracé uploadé avec succès pour ${event['nom']}!');
          _loadData();
        } else {
          _showError('Erreur lors de l\'upload du tracé');
        }
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _viewEventTrace(Map<String, dynamic> event) async {
    try {
      final eventId = event['id'] ?? '';

      if (eventId.isEmpty) {
        _showError('ID d\'épreuve invalide');
        return;
      }

      final traceData = await _firebaseService.getEventTraceData(eventId);

      if (traceData == null) {
        _showError('Aucun tracé trouvé pour cette épreuve');
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return EventTraceViewerDialog(
            traceData: traceData,
            eventName: event['nom'] ?? 'Épreuve',
          );
        },
      );
    } catch (e) {
      _showError('Erreur lors de l\'ouverture du tracé: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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

  Future<void> _logout() async {
    try {
      await SessionService.clearSession();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print('Erreur lors du logout: $e');
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    }
  }
}
