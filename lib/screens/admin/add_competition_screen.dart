import 'package:flutter/material.dart';
import '../../models/competition.dart';
import '../../models/show.dart';
import '../../services/firebase_service.dart';

class AddCompetitionScreen extends StatefulWidget {
  const AddCompetitionScreen({super.key});

  @override
  State<AddCompetitionScreen> createState() => _AddCompetitionScreenState();
}

class _AddCompetitionScreenState extends State<AddCompetitionScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  final _nomController = TextEditingController();
  final _regionController = TextEditingController();
  final _clubController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedReglement = 'FEI';

  List<Show> _shows = [];
  Show? _selectedShow;

  bool _isLoading = false;
  bool _isLoadingShows = true;

  @override
  void initState() {
    super.initState();
    _loadShows();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _regionController.dispose();
    _clubController.dispose();
    super.dispose();
  }

  Future<void> _loadShows() async {
    try {
      final shows = await _firebaseService.getShows();
      setState(() {
        _shows = shows;
        _isLoadingShows = false;
        if (shows.isNotEmpty) _selectedShow = shows.first;
      });
    } catch (e) {
      setState(() {
        _isLoadingShows = false;
      });
      _showError('Erreur lors du chargement des shows: $e');
    }
  }

  Future<void> _addCompetition() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedShow == null) {
      _showError('Veuillez sélectionner un show');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final competition = Competition(
        nom: _nomController.text.trim(),
        date: _selectedDate,
        region: _regionController.text.trim(),
        club: _clubController.text.trim(),
        reglement: _selectedReglement,
        showId: _selectedShow!.id!,
      );

      await _firebaseService.addCompetition(competition);

      _showSuccess('Compétition ajoutée avec succès!');
      _clearForm();
    } catch (e) {
      _showError('Erreur lors de l\'ajout de la compétition: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nomController.clear();
    _regionController.clear();
    _clubController.clear();
    setState(() {
      _selectedReglement = 'FEI';
      _selectedShow = _shows.isNotEmpty ? _shows.first : null;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.purple,
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
        title: const Text('Ajouter une Compétition'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 32,
                        color: Colors.purple[700],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Informations de la Compétition',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Show Selection
                  _isLoadingShows
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<Show>(
                          initialValue: _selectedShow,
                          decoration: _buildInputDecoration(
                              'Show associé', Icons.event),
                          items: _shows.map((show) {
                            return DropdownMenuItem(
                              value: show,
                              child: Text(show.nom),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedShow = value;
                            });
                          },
                        ),
                  const SizedBox(height: 16),

                  // Nom + Région
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nomController,
                          decoration: _buildInputDecoration(
                              'Nom de la compétition', Icons.emoji_events),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom est requis';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _regionController,
                          decoration: _buildInputDecoration(
                              'Région', Icons.location_on),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La région est requise';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Club + Règlement
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _clubController,
                          decoration: _buildInputDecoration(
                              'Club organisateur', Icons.home),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le club est requis';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.gavel, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            const Text(
                              'Règlement :',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedReglement = 'FEI';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedReglement == 'FEI'
                                      ? Colors.purple[700]
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _selectedReglement == 'FEI'
                                        ? Colors.purple[700]!
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'FEI',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedReglement == 'FEI'
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedReglement = 'FEA';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedReglement == 'FEA'
                                      ? Colors.blue[700]
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _selectedReglement == 'FEA'
                                        ? Colors.blue[700]!
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'FEA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedReglement == 'FEA'
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration:
                          _buildInputDecoration('Date', Icons.calendar_today),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _clearForm,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Effacer'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addCompetition,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text('Ajouter la Compétition'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
        borderSide: BorderSide(color: Colors.purple[700]!),
      ),
    );
  }
}
