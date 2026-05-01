import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/session_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/judge/judge_dashboard.dart';
import '../screens/designer/designer_dashboard.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Firebase quickly
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCongUs-jJLZDZ6MZ5l3itqotXOUXkYckY",
            authDomain: "equitation-a2bee.firebaseapp.com",
            projectId: "equitation-a2bee",
            storageBucket: "equitation-a2bee.firebasestorage.app",
            messagingSenderId: "464890461070",
            appId: "1:464890461070:web:be017c8c826bf09fcd02df",
            measurementId: "G-973PCL7JEW"),
      ).timeout(const Duration(seconds: 5));

      // Vérifier la session utilisateur
      await _checkSessionAndNavigate();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage =
              'Impossible de se connecter à Firebase. Vérifiez votre connexion internet et réessayez.';
        });
      }
    }
  }

  Future<void> _checkSessionAndNavigate() async {
    try {
      final sessionData = await SessionService.getSessionData();

      if (sessionData != null && sessionData['isLoggedIn'] == true) {
        final role = sessionData['role'] as String?;
        print('Session trouvée, rôle: $role');

        if (role != null && mounted) {
          // Naviguer directement vers le dashboard approprié
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
              return; // Si le rôle n'est pas reconnu, rester sur login
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => dashboard),
          );
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification de session: $e');
      // En cas d'erreur, continuer vers l'écran de login
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[700],
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur d\'initialisation',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'Erreur inconnue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _errorMessage = null;
                    });
                    _initializeApp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.blue[700],
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_gymnastics,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'Concours Équestres',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Application de Gestion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Initialisation de Firebase...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Once initialized, show the login screen
    return const LoginScreen();
  }
}
