import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../services/session_service.dart';
import '../../models/competition.dart';
import '../../models/event.dart';
import '../../models/participation.dart';
import '../designer/trace_viewer_dialog.dart';
// ignore: unused_import
import 'judge_event_screen.dart';
import 'judge_event_running_screen.dart';

class JudgeDashboard extends StatefulWidget {
  const JudgeDashboard({super.key});

  @override
  State<JudgeDashboard> createState() => _JudgeDashboardState();
}

class _JudgeDashboardState extends State<JudgeDashboard> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Competition> _competitions = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  // Selected competition for events view
  Competition? _selectedCompetition;
  List<Event> _selectedCompetitionEvents = [];

  @override
  void initState() {
    super.initState();
    _loadCompetitions();
  }

  Future<void> _loadCompetitions() async {
    try {
      final competitions = await _firebaseService.getCompetitions();
      setState(() {
        _competitions = competitions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erreur lors du chargement des compétitions: $e');
    }
  }

  Future<void> _selectCompetition(Competition competition) async {
    try {
      final events =
          await _firebaseService.getEventsByCompetition(competition.id ?? '');
      events.sort((a, b) {
        int dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return a.heure.compareTo(b.heure);
      });
      setState(() {
        _selectedCompetition = competition;
        _selectedCompetitionEvents = events;
        _selectedIndex = 1;
      });
    } catch (e) {
      _showError('Erreur lors du chargement des épreuves: $e');
    }
  }

  void _onMenuSelected(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _selectedCompetition = null;
      }
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
        color: Colors.green[800],
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
              color: Colors.green[900],
            ),
            child: Row(
              children: [
                Icon(Icons.gavel, size: 32, color: Colors.white),
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
                        'Espace Juge',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[200],
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
                  icon: Icons.emoji_events,
                  label: 'Compétitions',
                ),
                _buildMenuItem(
                  index: 1,
                  icon: Icons.sports_gymnastics,
                  label: 'Épreuves',
                ),
              ],
            ),
          ),

          // Logout
          Divider(color: Colors.green[600], height: 1),
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
                size: 20, color: isSelected ? Colors.white : Colors.green[200]),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.green[200],
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
    switch (_selectedIndex) {
      case 0:
        return _buildCompetitionsContent();
      case 1:
        return _selectedCompetition != null
            ? _buildEventsContent()
            : _buildNoCompetitionSelected();
      default:
        return _buildCompetitionsContent();
    }
  }

  Widget _buildCompetitionsContent() {
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
                Icon(Icons.emoji_events, size: 28, color: Colors.green[700]),
                const SizedBox(width: 12),
                Text(
                  'Compétitions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadCompetitions,
                  color: Colors.green[700],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _competitions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('Aucune compétition trouvée',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCompetitions,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _competitions.length,
                          itemBuilder: (context, index) {
                            return _buildCompetitionCard(_competitions[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionCard(Competition competition) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _selectCompetition(competition),
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
                      competition.nom,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey[600]),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(competition.region,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(width: 16),
                  Icon(Icons.home, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(competition.club,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${competition.date.day}/${competition.date.month}/${competition.date.year}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: competition.reglement == 'FEI'
                          ? Colors.orange[100]
                          : Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      competition.reglement,
                      style: TextStyle(
                        fontSize: 12,
                        color: competition.reglement == 'FEI'
                            ? Colors.orange[700]
                            : Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildEventsContent() {
    final competition = _selectedCompetition!;
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
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _onMenuSelected(0),
                  color: Colors.green[700],
                ),
                const SizedBox(width: 8),
                Icon(Icons.sports_gymnastics,
                    size: 28, color: Colors.green[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        competition.nom,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        '${competition.region} — ${competition.club}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: competition.reglement == 'FEI'
                        ? Colors.orange[100]
                        : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    competition.reglement,
                    style: TextStyle(
                      fontSize: 14,
                      color: competition.reglement == 'FEI'
                          ? Colors.orange[700]
                          : Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Events list
          Expanded(
            child: _selectedCompetitionEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_gymnastics_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Aucune épreuve dans cette compétition',
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _selectedCompetitionEvents.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(_selectedCompetitionEvents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
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
                    event.nom,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.bareme,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${event.date.day}/${event.date.month}/${event.date.year}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(event.heure,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.height, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${event.hauteur}m',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(width: 16),
                Icon(Icons.stadium, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(event.carriere,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                if (event.avecBarage) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Barage',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber[800],
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // Badges: tracé + engagés
            FutureBuilder<bool>(
              future: _firebaseService.hasEventTrace(event.id ?? ''),
              builder: (context, traceSnapshot) {
                return FutureBuilder<bool>(
                  future: _firebaseService.hasEngagesList(event.id ?? ''),
                  builder: (context, engagesSnapshot) {
                    final hasTrace = traceSnapshot.data ?? false;
                    final hasEngages = engagesSnapshot.data ?? false;

                    if (!hasTrace && !hasEngages) {
                      return const SizedBox.shrink();
                    }

                    return Row(
                      children: [
                        if (hasTrace)
                          InkWell(
                            onTap: () async {
                              final traceData = await _firebaseService
                                  .getEventTraceData(event.id ?? '');
                              if (traceData != null && mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => TraceViewerDialog(
                                    traceData: traceData,
                                    showName: event.nom,
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[300]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility,
                                      size: 14, color: Colors.blue[700]),
                                  const SizedBox(width: 4),
                                  Text('Voir tracé',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        if (hasTrace && hasEngages) const SizedBox(width: 6),
                        if (hasEngages)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.list_alt,
                                    size: 12, color: Colors.orange[700]),
                                const SizedBox(width: 3),
                                Text('Engagés',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Participation>>(
              future: _firebaseService.getParticipationsByEvent(event.id ?? ''),
              builder: (context, snapshot) {
                final participations = snapshot.data ?? [];
                final isFinished = participations.isNotEmpty &&
                    participations.every((p) =>
                        p.statut == 'passe' || p.statut == 'disqualifie');
                final hasStarted = participations.any(
                    (p) => p.statut == 'passe' || p.statut == 'disqualifie');

                if (isFinished) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                JudgeEventRunningScreen(event: event),
                          ),
                        );
                      },
                      icon: const Icon(Icons.emoji_events),
                      label: const Text('Épreuve terminée - Résultats'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              JudgeEventRunningScreen(event: event),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(hasStarted
                        ? 'Continuer l\'épreuve'
                        : 'Lancer l\'épreuve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          hasStarted ? Colors.orange[700] : Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCompetitionSelected() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Sélectionnez une compétition d\'abord',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _onMenuSelected(0),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white),
              child: const Text('Voir les compétitions'),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
