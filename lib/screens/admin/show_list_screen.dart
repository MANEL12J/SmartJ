import 'package:flutter/material.dart';
import '../../models/show.dart';
import '../../services/firebase_service.dart';
import 'add_show_screen.dart';

class ShowListScreen extends StatefulWidget {
  const ShowListScreen({super.key});

  @override
  State<ShowListScreen> createState() => _ShowListScreenState();
}

class _ShowListScreenState extends State<ShowListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Show> _shows = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShows();
  }

  Future<void> _loadShows() async {
    try {
      final shows = await _firebaseService.getShows();
      setState(() {
        _shows = shows;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erreur lors du chargement des shows: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Shows'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadShows,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _shows.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun show trouvé',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez votre premier show pour commencer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadShows,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _shows.length,
                    itemBuilder: (context, index) {
                      final show = _shows[index];
                      return _buildShowCard(show);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddShowScreen(),
            ),
          );
          _loadShows();
        },
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShowCard(Show show) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          _showShowDetails(show);
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
                      show.nom,
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
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      show.reglement,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
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
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    show.region,
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
                    '${show.date.day}/${show.date.month}/${show.date.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: _firebaseService.getUserNameById(show.judgeId),
                builder: (context, snapshot) {
                  return Row(
                    children: [
                      Icon(
                        Icons.gavel,
                        size: 16,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Juge: ${snapshot.data ?? 'Chargement...'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[600],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 4),
              FutureBuilder<String>(
                future: _firebaseService.getUserNameById(show.designerId),
                builder: (context, snapshot) {
                  return Row(
                    children: [
                      Icon(
                        Icons.design_services,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Designer: ${snapshot.data ?? 'Chargement...'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
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

  void _showShowDetails(Show show) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(show.nom),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Région: ${show.region}'),
                Text(
                    'Date: ${show.date.day}/${show.date.month}/${show.date.year}'),
                Text('Règlement: ${show.reglement}'),
                FutureBuilder<String>(
                  future: _firebaseService.getUserNameById(show.judgeId),
                  builder: (context, snapshot) {
                    return Text('Juge: ${snapshot.data ?? 'Chargement...'}');
                  },
                ),
                FutureBuilder<String>(
                  future: _firebaseService.getUserNameById(show.designerId),
                  builder: (context, snapshot) {
                    return Text(
                        'Designer: ${snapshot.data ?? 'Chargement...'}');
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Actions disponibles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
