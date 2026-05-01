import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/firebase_service.dart';
import '../../services/email_service.dart';

class AddJudgeScreen extends StatefulWidget {
  const AddJudgeScreen({super.key});

  @override
  State<AddJudgeScreen> createState() => _AddJudgeScreenState();
}

class _AddJudgeScreenState extends State<AddJudgeScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _licenceController = TextEditingController();

  bool _isLoading = false;
  String _generatedPassword = '';

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _licenceController.dispose();
    super.dispose();
  }

  String _generatePassword() {
    return _firebaseService.generatePassword(
      _nomController.text.trim(),
      _licenceController.text.trim(),
    );
  }

  Future<void> _addJudge() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Vérifier si l'email existe déjà
      final emailTaken =
          await _firebaseService.emailExists(_emailController.text.trim());
      if (emailTaken) {
        _showError('Cet email est déjà utilisé par un autre utilisateur.');
        return;
      }

      // Vérifier si la licence existe déjà
      final licenceTaken =
          await _firebaseService.licenceExists(_licenceController.text.trim());
      if (licenceTaken) {
        _showError(
            'Ce numéro de licence est déjà utilisé par un autre utilisateur.');
        return;
      }

      _generatedPassword = _generatePassword();

      final judge = User(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        role: 'judge',
        email: _emailController.text.trim(),
        licence: _licenceController.text.trim(),
        password: _generatedPassword,
      );

      await _firebaseService.addUser(judge);

      // Envoyer l'email de validation
      await EmailService.sendJudgeEmail({
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'email': _emailController.text.trim(),
        'licence': _licenceController.text.trim(),
      });

      _showSuccess('Juge ajouté avec succès! Email de connexion envoyé.');
      _clearForm();
    } catch (e) {
      _showError('Erreur lors de l\'ajout du juge: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();
    _licenceController.clear();
    setState(() {
      _generatedPassword = '';
    });
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
        title: const Text('Ajouter un Juge'),
        backgroundColor: Colors.green[700],
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
                        Icons.gavel,
                        size: 32,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Informations du Juge',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Nom
                  TextFormField(
                    controller: _nomController,
                    decoration: _buildInputDecoration('Nom', Icons.person),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Prénom
                  TextFormField(
                    controller: _prenomController,
                    decoration:
                        _buildInputDecoration('Prénom', Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le prénom est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration('Email', Icons.email),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'L\'email est requis';
                      }
                      if (!value.contains('@')) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Licence
                  TextFormField(
                    controller: _licenceController,
                    decoration:
                        _buildInputDecoration('Numéro de licence', Icons.badge),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le numéro de licence est requis';
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
                          onPressed: _isLoading ? null : _addJudge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
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
                              : const Text('Ajouter le Juge'),
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
        borderSide: BorderSide(color: Colors.green[700]!),
      ),
    );
  }
}
