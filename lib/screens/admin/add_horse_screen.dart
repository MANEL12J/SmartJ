import 'package:flutter/material.dart';
import '../../models/horse.dart';
import '../../services/firebase_service.dart';

class AddHorseScreen extends StatefulWidget {
  const AddHorseScreen({super.key});

  @override
  State<AddHorseScreen> createState() => _AddHorseScreenState();
}

class _AddHorseScreenState extends State<AddHorseScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  
  final _nomController = TextEditingController();
  final _ageController = TextEditingController();
  final _raceController = TextEditingController();
  
  String _selectedSexe = 'Mâle';
  bool _isLoading = false;

  final List<String> _sexes = ['Mâle', 'Femelle', 'Hongre'];

  @override
  void dispose() {
    _nomController.dispose();
    _ageController.dispose();
    _raceController.dispose();
    super.dispose();
  }

  Future<void> _addHorse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final horse = Horse(
        nom: _nomController.text.trim(),
        sexe: _selectedSexe,
        age: int.parse(_ageController.text),
        race: _raceController.text.trim(),
      );

      await _firebaseService.addHorse(horse);
      
      _showSuccess('Cheval ajouté avec succès!');
      _clearForm();
    } catch (e) {
      _showError('Erreur lors de l\'ajout du cheval: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nomController.clear();
    _ageController.clear();
    _raceController.clear();
    setState(() {
      _selectedSexe = 'Mâle';
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.brown,
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
        title: const Text('Ajouter un Cheval'),
        backgroundColor: Colors.brown[700],
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
                        Icons.pets,
                        size: 32,
                        color: Colors.brown[700],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Informations du Cheval',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Nom
                  TextFormField(
                    controller: _nomController,
                    decoration: _buildInputDecoration('Nom du cheval', Icons.pets),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom du cheval est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Sexe
                  DropdownButtonFormField<String>(
                    value: _selectedSexe,
                    decoration: _buildInputDecoration('Sexe', Icons.male),
                    items: _sexes.map((sexe) {
                      return DropdownMenuItem(
                        value: sexe,
                        child: Text(sexe),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSexe = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Âge
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('Âge (années)', Icons.cake),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'L\'âge est requis';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Veuillez entrer un âge valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Race
                  TextFormField(
                    controller: _raceController,
                    decoration: _buildInputDecoration('Race', Icons.category),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La race est requise';
                      }
                      return null;
                    },
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
                          onPressed: _isLoading ? null : _addHorse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Ajouter le Cheval'),
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
        borderSide: BorderSide(color: Colors.brown[700]!),
      ),
    );
  }
}
