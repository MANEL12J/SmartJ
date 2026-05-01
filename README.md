# 🏇 Application de Gestion des Concours Équestres

Application Flutter complète pour la gestion des concours équestres avec Firebase.

## 🚀 Fonctionnalités

- 🔐 **Authentification multi-rôles** (Admin/Judge/Designer)
- 👥 **Gestion du personnel** (Juges, Designers, Cavaliers, Chevaux)
- 🎪 **Gestion des shows** et concours
- 🏆 **Gestion des épreuves** avec barèmes et hauteurs
- 📋 **Système de participations** avec ordre de passage
- 📊 **Tableaux de bord** spécialisés par rôle

## 📦 Installation

1. **Cloner le projet**
```bash
git clone <repository-url>
cd equitation
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer Firebase**
   - Le projet est déjà configuré avec Firebase
   - Les identifiants sont dans `lib/main.dart`

4. **Lancer l'application**
```bash
flutter run
```

## 🔐 Identifiants

### **Admin**
- **Licence**: `admin`
- **Mot de passe**: `admin123`

### **Judge & Designer**
- Format: `nom + 3 derniers chiffres licence`
- Exemples créés automatiquement:
  - **Judge**: `dupont001` / `dupont001`
  - **Designer**: `bernard001` / `bernard001`

## 🏗️ Architecture

```
lib/
├── models/          # Modèles de données
│   ├── user.dart
│   ├── rider.dart
│   ├── horse.dart
│   ├── show.dart
│   ├── competition.dart
│   ├── event.dart
│   └── participation.dart
├── services/        # Services Firebase
│   ├── firebase_service.dart
│   └── init_service.dart
├── screens/         # Écrans
│   ├── auth/
│   │   └── login_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard.dart
│   │   ├── add_judge_screen.dart
│   │   ├── add_designer_screen.dart
│   │   ├── add_rider_screen.dart
│   │   ├── add_horse_screen.dart
│   │   ├── show_list_screen.dart
│   │   ├── add_show_screen.dart
│   │   ├── competition_list_screen.dart
│   │   ├── add_competition_screen.dart
│   │   ├── event_list_screen.dart
│   │   ├── add_event_screen.dart
│   │   └── participation_management_screen.dart
│   ├── judge/
│   │   └── judge_dashboard.dart
│   └── designer/
│       └── designer_dashboard.dart
└── main.dart
```

## 🗄️ Base de Données Firestore

### Collections
- `users` - Utilisateurs (admin/judge/designer)
- `riders` - Cavaliers
- `horses` - Chevaux
- `shows` - Shows/Compétitions principales
- `competitions` - Compétitions individuelles
- `events` - Épreuves
- `participations` - Participations et ordres de passage

## 🎯 Rôles et Permissions

### **Admin**
- ✅ Accès complet à toutes les fonctionnalités
- ✅ Gestion du personnel
- ✅ Gestion des shows et concours
- ✅ Gestion des participations

### **Judge**
- ✅ Consulter les shows assignés
- ✅ Gérer les épreuves
- ✅ Valider les participations

### **Designer**
- ✅ Consulter les shows assignés
- ✅ Upload des tracés
- ✅ Voir les détails des shows

## 📱 Utilisation

1. **Premier lancement**
   - Le compte admin est créé automatiquement
   - Optionnel: Décommentez `InitService.createSampleData()` dans `main.dart` pour créer des données de test

2. **Connexion**
   - Utilisez les identifiants admin pour commencer
   - Créez des comptes judge/designer via le dashboard admin

3. **Gestion**
   - Ajoutez du personnel (juges, designers, cavaliers, chevaux)
   - Créez des shows avec juge et designer assignés
   - Ajoutez des compétitions et épreuves
   - Gérez les participations avec ordre de passage automatique

## 🔧 Personnalisation

### **Modifier les identifiants admin**
Dans `lib/services/firebase_service.dart`:
```dart
Future<bool> isAdminLogin(String licence, String password) async {
  return licence == 'VOTRE_LICENCE' && password == 'VOTRE_MOT_DE_PASSE';
}
```

### **Ajouter des données de test**
Décommentez cette ligne dans `main.dart`:
```dart
await InitService.createSampleData();
```

## 🐛 Dépannage

### **Problèmes courants**
1. **Erreur de connexion Firebase**
   - Vérifiez la connexion internet
   - Assurez-vous que les identifiants Firebase sont corrects

2. **Données ne s'affichent pas**
   - Vérifiez les règles Firestore dans la console Firebase
   - Assurez-vous que les collections existent

3. **Erreur de compilation**
   - Exécutez `flutter clean` puis `flutter pub get`
   - Vérifiez que toutes les dépendances sont à jour

## 📝 Notes de Développement

- Architecture MVVM avec séparation des responsabilités
- Gestion d'erreurs robuste
- Interface Material Design 3
- Support Web avec Flutter
- Code commenté et documenté

## 🤝 Contribuer

1. Fork le projet
2. Créer une branche feature
3. Commit les changements
4. Push vers la branche
5. Créer une Pull Request

## 📄 Licence

Ce projet est sous licence MIT.
