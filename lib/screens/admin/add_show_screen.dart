import 'package:flutter/material.dart';
import '../../models/show.dart';
import '../../models/user.dart';
import '../../services/firebase_service.dart';

class AddShowScreen extends StatefulWidget {
  const AddShowScreen({super.key});

  @override
  State<AddShowScreen> createState() => _AddShowScreenState();
}

class _AddShowScreenState extends State<AddShowScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  final _nomController = TextEditingController();
  final _regionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isFEI = true;

  List<User> _judges = [];
  List<User> _designers = [];
  User? _selectedJudge;
  User? _selectedDesigner;

  bool _isLoading = false;
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final judges = await _firebaseService.getUsersByRole('judge');
      final designers = await _firebaseService.getUsersByRole('designer');
      setState(() {
        _judges = List<User>.from(judges);
        _designers = List<User>.from(designers);
        _isLoadingUsers = false;
        if (judges.isNotEmpty) _selectedJudge = judges.first;
        if (designers.isNotEmpty) _selectedDesigner = designers.first;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      _showError('Erreur lors du chargement des utilisateurs: $e');
    }
  }

  Future<void> _addShow() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedJudge == null || _selectedDesigner == null) {
      _showError('Veuillez sélectionner un juge et un designer');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if a show already exists on this date
      final showExists =
          await _firebaseService.checkShowExistsByDate(_selectedDate);
      if (showExists) {
        _showError(
            'Un show existe déjà à cette date! Veuillez choisir une autre date.');
        return;
      }

      final show = Show(
        nom: _nomController.text.trim(),
        region: _regionController.text.trim(),
        date: _selectedDate,
        reglement: _isFEI ? 'FEI' : 'FEA',
        judgeId: _selectedJudge!.id!,
        designerId: _selectedDesigner!.id!,
      );

      await _firebaseService.addShow(show);

      _showSuccess('Show ajouté avec succès!');
      _clearForm();
    } catch (e) {
      _showError('Erreur lors de l\'ajout du show: $e');
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
    setState(() {
      _selectedDate = DateTime.now();
      _isFEI = true;
      if (_judges.isNotEmpty) _selectedJudge = _judges.first;
      if (_designers.isNotEmpty) _selectedDesigner = _designers.first;
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
        backgroundColor: Colors.orange,
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
        title: const Text('Ajouter un Show'),
        backgroundColor: Colors.orange[700],
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
                        Icons.event,
                        size: 32,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Informations du Show',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      // Nom
                      Expanded(
                        child: TextFormField(
                          controller: _nomController,
                          decoration:
                              _buildInputDecoration('Nom du show', Icons.event),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom du show est requis';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Région
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
                  const SizedBox(height: 20),

                  // Règlement
                  Row(
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
                            _isFEI = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: _isFEI
                                ? Colors.orange[700]
                                : Colors.transparent,
                            border: Border.all(
                              color: _isFEI
                                  ? Colors.orange[700]!
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
                              color: _isFEI ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFEI = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                !_isFEI ? Colors.blue[700] : Colors.transparent,
                            border: Border.all(
                              color: !_isFEI
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
                              color: !_isFEI ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      // Juge
                      Expanded(
                        child: _isLoadingUsers
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<User>(
                                initialValue: _selectedJudge,
                                decoration:
                                    _buildInputDecoration('Juge', Icons.gavel),
                                items: _judges.map((judge) {
                                  return DropdownMenuItem(
                                    value: judge,
                                    child: Text('${judge.prenom} ${judge.nom}'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedJudge = value;
                                  });
                                },
                              ),
                      ),

                      const SizedBox(width: 16),

                      // Designer
                      Expanded(
                        child: _isLoadingUsers
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<User>(
                                initialValue: _selectedDesigner,
                                decoration: _buildInputDecoration(
                                    'Designer', Icons.design_services),
                                items: _designers.map((designer) {
                                  return DropdownMenuItem(
                                    value: designer,
                                    child: Text(
                                        '${designer.prenom} ${designer.nom}'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDesigner = value;
                                  });
                                },
                              ),
                      ),
                    ],
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
                          onPressed: _isLoading ? null : _addShow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
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
                              : const Text('Ajouter le Show'),
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
        borderSide: BorderSide(color: Colors.orange[700]!),
      ),
    );
  }
}
