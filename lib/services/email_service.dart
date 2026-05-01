import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static Future<void> sendValidationEmail(
      Map<String, dynamic> doc, String role) async {
    // Générer l'email et le mot de passe
    String toEmail = "${doc['nom']}${doc['prenom']}@matierelink.com"
        .toLowerCase()
        .replaceAll(' ', '');
    String licenceStr = doc['licence']?.toString() ?? '';
    String last3Digits = licenceStr.length >= 3
        ? licenceStr.substring(licenceStr.length - 3)
        : licenceStr;
    String password = "${doc['nom']}$last3Digits";

    final service_id = 'service_2vo192r';
    final template_id = 'template_dnk1x57';
    final user_id = 'dszsPiAZMlDaS5mob';
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      print("Envoi email à: email=${doc['email']}, toEmail=$toEmail");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': service_id,
          'template_id': template_id,
          'user_id': user_id,
          'template_params': {
            'user_subject': "Information de connexion - Compte $role",
            'to_name': "${doc['nom']} ${doc['prenom']}",
            'from_name': "Smart Jump Judge",
            'user_message': """
Bonjour ${doc['nom']} ${doc['prenom']},

Votre compte $role a été créé avec succès.

Voici vos informations de connexion :
- Numéro de licence : ${doc['licence']}
- Mot de passe : $password


Veuillez vous connecter.

Cordialement,
L'équipe Smart Jump Judge
            """,
            'to_email': doc['email'] ?? '',
            'email': doc['email'] ?? '',
            'user_email': "manelbensalah95@gmail.com",
            'reply_to': "manelbensalah95@gmail.com",
          }
        }),
      );

      if (response.statusCode == 200) {
        print("Email envoyé avec succès à ${doc['email']}");
      } else {
        print("Échec de l'envoi d'email. Code statut: ${response.statusCode}");
        print("Réponse: ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de l'envoi d'email: $e");
    }
  }

  static Future<void> sendDesignerEmail(Map<String, dynamic> designer) async {
    await sendValidationEmail(designer, "Designer");
  }

  static Future<void> sendJudgeEmail(Map<String, dynamic> judge) async {
    await sendValidationEmail(judge, "Juge");
  }

  // Méthode de test pour vérifier l'envoi d'email
  static Future<void> testEmail() async {
    try {
      final testData = {
        'nom': 'Test',
        'prenom': 'User',
        'email': 'manelbensalah95@gmail.com',
        'licence': 'TEST123',
      };

      await sendValidationEmail(testData, "Test");
      print("Email de test envoyé avec succès!");
    } catch (e) {
      print("Erreur lors de l'envoi de l'email de test: $e");
    }
  }
}
