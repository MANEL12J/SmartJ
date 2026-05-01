import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class SessionService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';

  // Sauvegarder la session utilisateur
  static Future<void> saveSession({
    required bool isLoggedIn,
    String? role,
    String? userId,
    String? userName,
    String? userEmail,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
      
      if (role != null) {
        await prefs.setString(_keyUserRole, role);
      }
      if (userId != null) {
        await prefs.setString(_keyUserId, userId);
      }
      if (userName != null) {
        await prefs.setString(_keyUserName, userName);
      }
      if (userEmail != null) {
        await prefs.setString(_keyUserEmail, userEmail);
      }
      
      print('Session sauvegardée: $isLoggedIn, role: $role');
    } catch (e) {
      print('Erreur lors de la sauvegarde de la session: $e');
    }
  }

  // Sauvegarder les informations de l'utilisateur connecté
  static Future<void> saveUserSession(User user) async {
    await saveSession(
      isLoggedIn: true,
      role: user.role,
      userId: user.id,
      userName: '${user.prenom} ${user.nom}',
      userEmail: user.email,
    );
  }

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e) {
      print('Erreur lors de la vérification de la session: $e');
      return false;
    }
  }

  // Obtenir le rôle de l'utilisateur
  static Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserRole);
    } catch (e) {
      print('Erreur lors de la récupération du rôle: $e');
      return null;
    }
  }

  // Obtenir l'ID de l'utilisateur
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserId);
    } catch (e) {
      print('Erreur lors de la récupération de l\'ID utilisateur: $e');
      return null;
    }
  }

  // Obtenir le nom de l'utilisateur
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserName);
    } catch (e) {
      print('Erreur lors de la récupération du nom utilisateur: $e');
      return null;
    }
  }

  // Obtenir l'email de l'utilisateur
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserEmail);
    } catch (e) {
      print('Erreur lors de la récupération de l\'email utilisateur: $e');
      return null;
    }
  }

  // Obtenir toutes les informations de la session
  static Future<Map<String, dynamic>?> getSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      
      if (!isLoggedIn) {
        return null;
      }

      return {
        'isLoggedIn': isLoggedIn,
        'role': prefs.getString(_keyUserRole),
        'userId': prefs.getString(_keyUserId),
        'userName': prefs.getString(_keyUserName),
        'userEmail': prefs.getString(_keyUserEmail),
      };
    } catch (e) {
      print('Erreur lors de la récupération des données de session: $e');
      return null;
    }
  }

  // Effacer la session (logout)
  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserRole);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserEmail);
      
      print('Session effacée');
    } catch (e) {
      print('Erreur lors de l\'effacement de la session: $e');
    }
  }

  // Effacer toutes les données (pour le debugging)
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('Toutes les données effacées');
    } catch (e) {
      print('Erreur lors de l\'effacement de toutes les données: $e');
    }
  }
}
