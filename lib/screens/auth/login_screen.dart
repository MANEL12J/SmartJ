import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../services/session_service.dart';
import '../admin/admin_dashboard.dart';
import '../judge/judge_dashboard.dart';
import '../designer/designer_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licenceController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _licenceController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final licence = _licenceController.text.trim();
      final password = _passwordController.text;

      print('LOGIN DEBUG: Licence: $licence, Password: $password');

      // Check for admin login first (local check, no Firebase)
      if (licence == 'admin' && password == 'admin123') {
        print('LOGIN DEBUG: Admin login détecté');
        // Sauvegarder la session admin
        await SessionService.saveSession(
          isLoggedIn: true,
          role: 'admin',
          userName: 'Admin System',
          userEmail: 'admin@equitation.com',
        );
        _navigateToDashboard('admin');
        return;
      }

      print('LOGIN DEBUG: Tentative auth Firestore pour judge/designer');
      // Try Firestore authentication for judges and designers
      final user = await _firebaseService.authenticateUser(licence, password);

      if (user != null) {
        print('LOGIN DEBUG: User trouvé avec rôle: ${user.role}');
        // Sauvegarder la session utilisateur
        await SessionService.saveUserSession(user);
        // Navigate based on role
        _navigateToDashboard(user.role);
      } else {
        print('LOGIN DEBUG: User null - auth échouée');
        _showError('Numéro de licence ou mot de passe incorrect');
      }
    } catch (e) {
      print('LOGIN DEBUG: Exception: $e');
      _showError('Erreur de connexion: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDashboard(String role) {
    Widget dashboard;
    switch (role) {
      case 'admin':
        dashboard = const AdminDashboard();
        break;
      case 'judge':
        dashboard = const JudgeDashboard();
        break;
      case 'designer':
        dashboard = const DesignerDashboard();
        break;
      default:
        _showError('Rôle non reconnu');
        return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => dashboard),
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
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Smart Jump Judge',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gestion des Concours',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Licence Field
                        TextFormField(
                          controller: _licenceController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Numéro de licence',
                            hintText: 'Entrez votre numéro de licence',
                            prefixIcon: const Icon(Icons.badge),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue[700]!),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le numéro de licence est requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            hintText: 'Entrez votre mot de passe',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue[700]!),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le mot de passe est requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
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
                                : const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Info text
                        Text(
                          'Judge & Designer: nom + 3 derniers chiffres licence',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
