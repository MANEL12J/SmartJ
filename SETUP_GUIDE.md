# SmartJ - Guide d'installation sur un nouveau PC

## 1. Prérequis système

| Outil | Version | Lien |
|-------|---------|------|
| **Flutter SDK** | 3.14.0-0.2.pre (channel beta) | https://docs.flutter.dev/get-started/install |
| **Dart SDK** | 3.2.0 (build 3.2.0-42.2.beta) | Inclus avec Flutter |
| **Git** | Dernière version | https://git-scm.com/downloads |
| **IDE** | VS Code ou Android Studio | https://code.visualstudio.com/ ou https://developer.android.com/studio |
| **Chrome** | Dernière version | Requis pour le debug web |

## 2. Cloner le projet

```bash
git clone https://github.com/MANEL12J/SmartJ.git
cd SmartJ
```

## 3. Installer Flutter (si pas déjà installé)

```bash
# Installer Flutter via Git
git clone https://github.com/flutter/flutter.git -b beta
# Ajouter flutter/bin au PATH système
flutter doctor
```

## 4. Installer les dépendances

```bash
flutter pub get
```

## 5. Configuration Firebase

Le projet utilise Firebase. Les fichiers de configuration sont déjà inclus :
- `web/index.html` — contient la config Firebase Web
- `android/app/google-services.json` — config Android
- `ios/Runner/GoogleService-Info.plist` — config iOS

**Projet Firebase** : `equitation-a2bee`

## 6. Lancer l'application

```bash
# Sur le web (Chrome)
flutter run -d chrome

# Sur Windows
flutter run -d windows

# Sur Android (si émulateur/appareil connecté)
flutter run -d android
```

## 7. Dépendances du projet (pubspec.yaml)

| Package | Version | Usage |
|---------|---------|-------|
| `flutter` | SDK | Framework UI |
| `cupertino_icons` | ^1.0.2 | Icônes iOS |
| `firebase_core` | ^2.24.2 | Initialisation Firebase |
| `firebase_auth` | ^4.15.3 | Authentification |
| `cloud_firestore` | ^4.13.6 | Base de données Firestore |
| `file_picker` | ^6.1.1 | Sélection de fichiers |
| `shared_preferences` | ^2.2.2 | Stockage local |
| `http` | ^1.1.0 | Requêtes HTTP |
| `font_awesome_flutter` | 10.5.0 | Icônes Font Awesome |
| `excel` | ^4.0.6 | Parsing fichiers Excel |
| `archive` | ^3.6.1 | Décompression ZIP (fallback xlsx) |
| `xml` | ^6.4.2 | Parsing XML (fallback xlsx) |

### Dev dependencies

| Package | Version | Usage |
|---------|---------|-------|
| `flutter_test` | SDK | Tests unitaires |
| `flutter_lints` | ^2.0.0 | Linting |

## 8. Versions résolues (pubspec.lock)

Ces versions exactes sont verrouillées dans `pubspec.lock` :

| Package | Version exacte |
|---------|---------------|
| `_flutterfire_internals` | 1.3.16 |
| `archive` | 3.6.1 |
| `async` | 2.11.0 |
| `boolean_selector` | 2.1.1 |
| `characters` | 1.3.0 |
| `clock` | 1.1.1 |
| `cloud_firestore` | 4.14.0 |
| `cloud_firestore_platform_interface` | 6.1.0 |
| `cloud_firestore_web` | 3.9.0 |
| `collection` | 1.18.0 |
| `crypto` | 3.0.3 |
| `cupertino_icons` | 1.0.8 |
| `excel` | 4.0.6 |
| `fake_async` | 1.3.1 |
| `ffi` | 2.1.0 |
| `file_picker` | 6.2.1 |
| `firebase_auth` | 4.16.0 |
| `firebase_auth_platform_interface` | 7.0.9 |
| `firebase_auth_web` | 5.8.13 |
| `firebase_core` | 2.24.2 |
| `firebase_core_platform_interface` | 5.1.0 |
| `firebase_core_web` | 2.10.0 |
| `flutter_lints` | 2.0.3 |
| `font_awesome_flutter` | 10.5.0 |
| `http` | 1.1.0 |
| `petitparser` | 6.0.1 |
| `shared_preferences` | 2.2.3 |
| `xml` | 6.4.2 |

## 9. Structure du projet

```
lib/
├── main.dart                          # Point d'entrée
├── models/                            # Modèles de données
│   ├── user.dart
│   ├── rider.dart
│   ├── horse.dart
│   ├── show.dart
│   ├── competition.dart
│   ├── event.dart
│   └── participation.dart
├── services/                          # Services
│   ├── firebase_service.dart          # CRUD Firestore + Auth
│   └── session_service.dart           # Gestion de session
└── screens/                           # Écrans UI
    ├── auth/                          # Connexion
    ├── admin/                         # Dashboard admin
    ├── judge/                         # Dashboard juge + scoring
    └── designer/                      # Dashboard designer
```

## 10. Vérification

Après installation, vérifier avec :
```bash
flutter doctor
flutter pub get
flutter analyze
```
