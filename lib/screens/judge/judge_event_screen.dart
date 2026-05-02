import 'package:flutter/material.dart';
import '../../models/competition.dart';
import '../../models/event.dart';
import '../../services/firebase_service.dart';

class JudgeEventScreen extends StatefulWidget {
  final Competition competition;
  final List<Event> events;

  const JudgeEventScreen({
    super.key,
    required this.competition,
    required this.events,
  });

  @override
  State<JudgeEventScreen> createState() => _JudgeEventScreenState();
}

class _JudgeEventScreenState extends State<JudgeEventScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late List<Event> _events;

  @override
  void initState() {
    super.initState();
    _events = List<Event>.from(widget.events);
    _events.sort((a, b) {
      int dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.heure.compareTo(b.heure);
    });
  }

  Future<void> _launchEvent(Event event) async {
    try {
      // TODO: Navigate to the event scoring/judging screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lancement de l\'épreuve: ${event.nom}'),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.competition.nom),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Competition Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emoji_events,
                            color: Colors.green[700], size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.competition.nom,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(widget.competition.region,
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 16),
                        Icon(Icons.home, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(widget.competition.club,
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.competition.date.day}/${widget.competition.date.month}/${widget.competition.date.year}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.competition.reglement == 'FEI'
                                ? Colors.orange[100]
                                : Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.competition.reglement,
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.competition.reglement == 'FEI'
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
            const SizedBox(height: 16),

            // Events List
            Expanded(
              child: Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.sports_gymnastics,
                              color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Épreuves (${_events.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _events.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.sports_gymnastics_outlined,
                                      size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text('Aucune épreuve dans cette compétition',
                                      style:
                                          TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _events.length,
                              itemBuilder: (context, index) {
                                final event = _events[index];
                                return _buildEventCard(event);
                              },
                            ),
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

  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.nom,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${event.date.day}/${event.date.month}/${event.date.year}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
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
                const SizedBox(width: 16),
                if (event.avecBarage)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Barage',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber[800],
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchEvent(event),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Lancer l\'épreuve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
