import 'package:flutter/material.dart';
import '../../models/competition.dart';
import '../../services/firebase_service.dart';
import 'add_competition_screen.dart';

class CompetitionListScreen extends StatefulWidget {
  const CompetitionListScreen({super.key});

  @override
  State<CompetitionListScreen> createState() => _CompetitionListScreenState();
}

class _CompetitionListScreenState extends State<CompetitionListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Competition> _competitions = [];
  bool _isLoading = true;

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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.purple,
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
        title: const Text('Liste des Compétitions'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCompetitions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _competitions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune compétition trouvée',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez votre première compétition pour commencer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCompetitions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _competitions.length,
                    itemBuilder: (context, index) {
                      final competition = _competitions[index];
                      return _buildCompetitionCard(competition);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddCompetitionScreen(),
            ),
          );
          _loadCompetitions();
        },
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCompetitionCard(Competition competition) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          _showCompetitionDetails(competition);
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
                      competition.nom,
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
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      competition.reglement,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[700],
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
                    Icons.home,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    competition.club,
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
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    competition.region,
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
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${competition.date.day}/${competition.date.month}/${competition.date.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<String?>(
                future: _firebaseService.getShowNameById(competition.showId),
                builder: (context, snapshot) {
                  return Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 16,
                        color: Colors.orange[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Show: ${snapshot.data ?? 'Chargement...'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[600],
                          ),
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
    );
  }

  void _showCompetitionDetails(Competition competition) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(competition.nom),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Club: ${competition.club}'),
                Text('Région: ${competition.region}'),
                Text(
                    'Date: ${competition.date.day}/${competition.date.month}/${competition.date.year}'),
                Text('Règlement: ${competition.reglement}'),
                FutureBuilder<String?>(
                  future: _firebaseService.getShowNameById(competition.showId),
                  builder: (context, snapshot) {
                    return Text('Show: ${snapshot.data ?? 'Chargement...'}');
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Actions disponibles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Voir les épreuves associées\n• Gérer les participations\n• Modifier les détails',
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
