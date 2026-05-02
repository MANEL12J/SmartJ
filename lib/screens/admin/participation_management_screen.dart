import 'package:flutter/material.dart';
import '../../models/participation.dart';
import '../../models/rider.dart';
import '../../models/horse.dart';
import '../../models/event.dart';
import '../../services/firebase_service.dart';

class ParticipationManagementScreen extends StatefulWidget {
  const ParticipationManagementScreen({super.key});

  @override
  State<ParticipationManagementScreen> createState() =>
      _ParticipationManagementScreenState();
}

class _ParticipationManagementScreenState
    extends State<ParticipationManagementScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  List<Participation> _participations = [];
  List<Rider> _riders = [];
  List<Horse> _horses = [];
  List<Event> _events = [];

  Rider? _selectedRider;
  Horse? _selectedHorse;
  Event? _selectedEvent;

  bool _isLoading = true;
  bool _isLoadingData = true;
  bool _isAddingParticipation = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _firebaseService.getParticipations(),
        _firebaseService.getRiders(),
        _firebaseService.getHorses(),
        _firebaseService.getEvents(),
      ]);

      setState(() {
        _participations = List<Participation>.from(results[0]);
        _riders = List<Rider>.from(results[1]);
        _horses = List<Horse>.from(results[2]);
        _events = List<Event>.from(results[3]);
        _isLoadingData = false;
        _isLoading = false;

        if (_riders.isNotEmpty) _selectedRider = _riders.first;
        if (_horses.isNotEmpty) _selectedHorse = _horses.first;
        if (_events.isNotEmpty) _selectedEvent = _events.first;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
        _isLoading = false;
      });
      _showError('Erreur lors du chargement des données: $e');
    }
  }

  Future<void> _addParticipation() async {
    if (_selectedRider == null ||
        _selectedHorse == null ||
        _selectedEvent == null) {
      _showError('Veuillez sélectionner un cavalier, un cheval et une épreuve');
      return;
    }

    // Check if rider can pass again
    final canPass = await _firebaseService.canRiderPassAgain(
      _selectedRider!.id!,
      _selectedEvent!.id!,
    );

    if (!canPass) {
      _showError('Ce cavalier ne peut pas repasser avant 10 passages minimum');
      return;
    }

    setState(() {
      _isAddingParticipation = true;
    });

    try {
      final nextOrdre =
          await _firebaseService.getNextOrdrePassage(_selectedEvent!.id!);

      final participation = Participation(
        riderId: _selectedRider!.id!,
        horseId: _selectedHorse!.id!,
        eventId: _selectedEvent!.id!,
        ordrePassage: nextOrdre,
        statut: 'en_attente',
        score: 0.0,
      );

      await _firebaseService.addParticipation(participation);

      _showSuccess(
          'Participation ajoutée avec succès! Ordre de passage: $nextOrdre');
      _loadData(); // Reload data
    } catch (e) {
      _showError('Erreur lors de l\'ajout de la participation: $e');
    } finally {
      setState(() {
        _isAddingParticipation = false;
      });
    }
  }

  Future<void> _updateParticipationStatus(
      Participation participation, String status) async {
    try {
      await _firebaseService.updateParticipationStatus(
          participation.id!, status);
      _showSuccess('Statut mis à jour avec succès');
      _loadData();
    } catch (e) {
      _showError('Erreur lors de la mise à jour du statut: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
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
        title: const Text('Gestion des Participations'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Add Participation Section
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ajouter une Participation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _isLoadingData
                            ? const CircularProgressIndicator()
                            : Column(
                                children: [
                                  // Rider Selection
                                  DropdownButtonFormField<Rider>(
                                    initialValue: _selectedRider,
                                    decoration: _buildInputDecoration(
                                        'Cavalier', Icons.person),
                                    items: _riders.map((rider) {
                                      return DropdownMenuItem(
                                        value: rider,
                                        child: Text(
                                            '${rider.prenom} ${rider.nom}'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRider = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Horse Selection
                                  DropdownButtonFormField<Horse>(
                                    initialValue: _selectedHorse,
                                    decoration: _buildInputDecoration(
                                        'Cheval', Icons.pets),
                                    items: _horses.map((horse) {
                                      return DropdownMenuItem(
                                        value: horse,
                                        child: Text(
                                            '${horse.nom} (${horse.sexe})'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedHorse = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Event Selection
                                  DropdownButtonFormField<Event>(
                                    initialValue: _selectedEvent,
                                    decoration: _buildInputDecoration(
                                        'Épreuve', Icons.sports_gymnastics),
                                    items: _events.map((event) {
                                      return DropdownMenuItem(
                                        value: event,
                                        child: Text(event.nom),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedEvent = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Add Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isAddingParticipation
                                          ? null
                                          : _addParticipation,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal[700],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                      ),
                                      child: _isAddingParticipation
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Ajouter la Participation'),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),

                // Participations List
                Expanded(
                  child: _participations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list_alt,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune participation trouvée',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _participations.length,
                          itemBuilder: (context, index) {
                            final participation = _participations[index];
                            return _buildParticipationCard(participation);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildParticipationCard(Participation participation) {
    final rider = _riders.firstWhere(
      (r) => r.id == participation.riderId,
      orElse: () => Rider(nom: 'Inconnu', prenom: '', club: '', telephone: ''),
    );

    final horse = _horses.firstWhere(
      (h) => h.id == participation.horseId,
      orElse: () => Horse(nom: 'Inconnu', sexe: '', age: 0, race: ''),
    );

    final event = _events.firstWhere(
      (e) => e.id == participation.eventId,
      orElse: () => Event(
        nom: 'Inconnu',
        date: DateTime.now(),
        heure: '',
        bareme: '',
        hauteur: 0,
        carriere: '',
        competitionId: '',
        nombreManches: 1,
        avecBarage: false,
      ),
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${participation.ordrePassage}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${rider.prenom} ${rider.nom}',
                    style: const TextStyle(
                      fontSize: 16,
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
                    color: participation.statut == 'passe'
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    participation.statut == 'passe' ? 'Passé' : 'En attente',
                    style: TextStyle(
                      fontSize: 12,
                      color: participation.statut == 'passe'
                          ? Colors.green[700]
                          : Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Cheval: ${horse.nom}'),
            Text('Épreuve: ${event.nom}'),
            if (participation.score > 0) Text('Score: ${participation.score}'),
            const SizedBox(height: 12),
            if (participation.statut == 'en_attente')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateParticipationStatus(participation, 'passe'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Marquer comme passé'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.teal[700]!),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
