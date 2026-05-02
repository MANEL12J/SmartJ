import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/competition.dart';
import '../../services/firebase_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  final _nomController = TextEditingController();
  final _heureController = TextEditingController();
  final _hauteurController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedBareme = 'A';
  String _selectedCarriere = 'indoor';
  int _selectedNombreManches = 1;
  bool _avecBarage = false;

  List<Competition> _competitions = [];
  Competition? _selectedCompetition;

  bool _isLoading = false;
  bool _isLoadingCompetitions = true;

  final List<String> _baremes = ['A', 'A chrono', 'C'];
  final List<String> _carrieres = ['indoor', 'outdoor'];
  final List<int> _nombreManchesOptions = [1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    _loadCompetitions();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _heureController.dispose();
    _hauteurController.dispose();
    super.dispose();
  }

  Future<void> _loadCompetitions() async {
    try {
      final competitions = await _firebaseService.getCompetitions();
      setState(() {
        _competitions = competitions;
        _isLoadingCompetitions = false;
        if (competitions.isNotEmpty) _selectedCompetition = competitions.first;
      });
    } catch (e) {
      setState(() {
        _isLoadingCompetitions = false;
      });
      _showError('Erreur lors du chargement des compétitions: $e');
    }
  }

  Future<void> _addEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCompetition == null) {
      _showError('Veuillez sélectionner une compétition');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final event = Event(
        nom: _nomController.text.trim(),
        date: _selectedDate,
        heure: _heureController.text.trim(),
        bareme: _selectedBareme,
        hauteur: double.parse(_hauteurController.text),
        carriere: _selectedCarriere,
        competitionId: _selectedCompetition!.id!,
        nombreManches: _selectedNombreManches,
        avecBarage: _avecBarage,
      );

      await _firebaseService.addEvent(event);
      Navigator.of(context).pop();
      _showSuccess('Épreuve ajoutée avec succès!');
      _clearForm();
    } catch (e) {
      _showError('Erreur lors de l\'ajout de l\'épreuve: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nomController.clear();
    _heureController.clear();
    _hauteurController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedBareme = 'A';
      _selectedCarriere = 'indoor';
      _selectedNombreManches = 1;
      _avecBarage = false;
      if (_competitions.isNotEmpty) _selectedCompetition = _competitions.first;
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (picked != null) {
      setState(() {
        _heureController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
        title: const Text('Ajouter une Épreuve'),
        backgroundColor: Colors.red[700],
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
                        Icons.sports_gymnastics,
                        size: 32,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Informations de l\'Épreuve',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Competition Selection
                  Row(
                    children: [
                      Expanded(
                        child: _isLoadingCompetitions
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<Competition>(
                                initialValue: _selectedCompetition,
                                decoration: _buildInputDecoration(
                                    'Compétition associée', Icons.emoji_events),
                                items: _competitions.map((competition) {
                                  return DropdownMenuItem(
                                    value: competition,
                                    child: Text(competition.nom),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCompetition = value;
                                  });
                                },
                              ),
                      ),
                      const SizedBox(width: 16),

                      // Nom
                      Expanded(
                        child: TextFormField(
                          controller: _nomController,
                          decoration: _buildInputDecoration(
                              'Nom de l\'épreuve', Icons.sports_gymnastics),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom de l\'épreuve est requis';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Date
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          child: InputDecorator(
                            decoration: _buildInputDecoration(
                                'Date', Icons.calendar_today),
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
                      ),
                      const SizedBox(width: 16),

                      // Heure
                      Expanded(
                        child: InkWell(
                          onTap: _selectTime,
                          child: InputDecorator(
                            decoration: _buildInputDecoration(
                                'Heure', Icons.access_time),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _heureController.text.isEmpty
                                      ? 'Sélectionner l\'heure'
                                      : _heureController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _heureController.text.isEmpty
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Barème
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBareme,
                    decoration:
                        _buildInputDecoration('Barème', Icons.calculate),
                    items: _baremes.map((bareme) {
                      return DropdownMenuItem(
                        value: bareme,
                        child: Text(bareme),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBareme = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Hauteur
                      Expanded(
                        child: TextFormField(
                          controller: _hauteurController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration(
                              'Hauteur (mètres)', Icons.height),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La hauteur est requise';
                            }
                            if (double.tryParse(value) == null ||
                                double.parse(value) <= 0) {
                              return 'Veuillez entrer une hauteur valide';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Carrière
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCarriere,
                          decoration:
                              _buildInputDecoration('Carrière', Icons.stadium),
                          items: _carrieres.map((carriere) {
                            return DropdownMenuItem(
                              value: carriere,
                              child: Text(carriere),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCarriere = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Nombre de manches
                  DropdownButtonFormField<int>(
                    initialValue: _selectedNombreManches,
                    decoration: _buildInputDecoration(
                        'Nombre de manches', Icons.repeat),
                    items: _nombreManchesOptions.map((nombre) {
                      return DropdownMenuItem(
                        value: nombre,
                        child: Text('$nombre manche${nombre > 1 ? 's' : ''}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedNombreManches = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Avec ou sans barage
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag,
                            color: Colors.red[700],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Barage',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  'L\'épreuve comprend-elle un barage?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _avecBarage,
                            onChanged: (value) {
                              setState(() {
                                _avecBarage = value;
                              });
                            },
                            activeThumbColor: Colors.red[700],
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
                          onPressed: _isLoading ? null : _addEvent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
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
                              : const Text('Ajouter l\'Épreuve'),
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
        borderSide: BorderSide(color: Colors.red[700]!),
      ),
    );
  }
}
