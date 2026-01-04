# 🚗 CarShare Tunisie

Application mobile de covoiturage moderne pour la Tunisie, développée avec **Flutter + Firebase**.

## ✨ Fonctionnalités principales

### 🔐 Authentification & Sécurité
- **Inscription/Connexion** par email et mot de passe (Firebase Auth)
- **Vérification d'identité** avec upload CIN/Permis de conduire
- **Rôles flexibles** : Passager ou Conducteur (switch possible)
- **Sécurité renforcée** : contact d'urgence, signalement de problèmes

### 🚗 Trajets & Réservations
- **Recherche intelligente** de trajets (départ → destination)
- **Filtres avancés** : date, prix max, places disponibles, préférences
- **Publication de trajets** (côté conducteur) avec gestion des véhicules
- **Réservation en 1-clic** avec paiement intégré
- **Historique complet** : trajets à venir et passés

### 💰 Portefeuille & Paiements
- **Portefeuille virtuel** avec recharge en ligne
- **Transactions détaillées** : recharge, paiement, gains, remboursements
- **Méthodes de paiement** multiples (Carte, Orange Money, Ooredoo Money, Espèces)

### 👥 Social & Communication
- **Groupes de covoiturage** : publics ou privés
- **Chat intégré** : discussions de groupe et chat trajet
- **Système d'avis** : évaluation des conducteurs et passagers
- **Notifications push** : bookings, acceptations, messages

### 🌍 Internationalisation
- **Multilingue** : Français, Arabe, Anglais
- **Interface adaptative** : RTL/LTR selon la langue
- **Localisation complète** : dates, devises, formats

## 🛠 Stack technique

### Frontend (Flutter)
- **Framework** : Flutter 3.x avec Dart
- **State Management** : Provider
- **Navigation** : MaterialApp avec routes nommées
- **UI/UX** : Material Design 3, thèmes personnalisés
- **Internationalisation** : AppLocalizations custom

### Backend (Firebase)
- **Authentication** : Firebase Auth (email/password)
- **Database** : Cloud Firestore (NoSQL)
- **Storage** : Firebase Storage (images, documents)
- **Cloud Functions** : FCM notifications, triggers
- **Hosting** : Firebase Hosting (optionnel)

### Packages principaux
```yaml
dependencies:
  firebase_core: latest
  firebase_auth: latest
  cloud_firestore: latest
  firebase_storage: latest
  firebase_messaging: latest
  provider: latest
  file_picker: latest
  image_picker: latest
```

## 📱 Architecture & Structure

```
lib/
├── main.dart                 # Point d'entrée, init Firebase
├── config/
│   ├── theme.dart           # Thème de l'application
│   └── routes.dart          # Routes et navigation
├── l10n/
│   └── app_localizations.dart # Internationalisation
├── providers/
│   ├── auth_provider.dart   # État authentification
│   ├── booking_provider.dart # Gestion réservations
│   └── locale_provider.dart  # Gestion langue
├── services/
│   ├── fcm_service.dart     # Notifications push
│   ├── auth_service.dart    # Services Firebase Auth
│   └── storage_service.dart # Upload fichiers
├── screens/
│   ├── auth/               # Écrans authentification
│   ├── dashboard/          # Tableau de bord
│   ├── rides/              # Gestion trajets
│   ├── booking/            # Réservations
│   ├── wallet/             # Portefeuille
│   ├── groups/             # Groupes
│   └── profile/            # Profil utilisateur
└── widgets/                # Composants réutilisables
```

## 🗄 Base de données (Firestore)

### Collections principales

#### `users/{uid}`
```dart
{
  'uid': string,
  'email': string,
  'fullName': string,
  'phone': string,
  'role': 'passenger' | 'driver',
  'createdAt': Timestamp,
  'isVerified': bool,
  'cinUrl': string,        // URL CIN uploadé
  'licenseUrl': string,    // URL permis uploadé
  'fcmToken': string,      // Token notifications
  'walletBalance': double,
  'rating': double,
  'memberSince': Timestamp,
}
```

#### `rides/{rideId}`
```dart
{
  'driverId': string,
  'driverName': string,
  'departure': string,
  'destination': string,
  'departureDate': Timestamp,
  'departureTime': string,
  'pricePerSeat': double,
  'availableSeats': int,
  'totalSeats': int,
  'vehicle': {
    'brand': string,
    'model': string,
    'color': string,
    'licensePlate': string,
  },
  'preferences': {
    'smokingAllowed': bool,
    'petsAllowed': bool,
    'luggageAllowed': bool,
    'musicAllowed': bool,
    'chattingAllowed': bool,
  },
  'status': 'active' | 'completed' | 'cancelled',
  'createdAt': Timestamp,
}
```

#### `bookings/{bookingId}`
```dart
{
  'rideId': string,
  'userId': string,
  'driverId': string,
  'seatsBooked': int,
  'totalPrice': double,
  'paymentMethod': 'card' | 'orange_money' | 'ooredoo_money' | 'cash',
  'status': 'pending' | 'confirmed' | 'cancelled' | 'completed',
  'bookingDate': Timestamp,
  'paymentStatus': 'paid' | 'pending' | 'refunded',
}
```

#### `groups/{groupId}`
```dart
{
  'name': string,
  'description': string,
  'type': 'public' | 'private',
  'creatorId': string,
  'memberIds': List<string>,
  'createdAt': Timestamp,
  'memberCount': int,
}
```

## 🔧 Configuration requise

### Prérequis
- **Flutter SDK** 3.0+ (`flutter doctor`)
- **Android Studio** avec Android SDK
- **Node.js** 16+ (pour Cloud Functions)
- **Compte Firebase** avec projet configuré

### Configuration Firebase

#### 1. Créer le projet Firebase
```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter
firebase login

# Initialiser le projet
firebase init
```

#### 2. Configuration Android
- **Package Name** : `com.carshare.tunisie.carshare_tunisie`
- **Fichier requis** : `android/app/google-services.json`
- **Activer Authentication** → Email/Password
- **Ajouter SHA-1/SHA-256** dans Project Settings

#### 3. Configuration iOS
- Générer `firebase_options.dart` avec FlutterFire CLI
- Nécessite macOS + Xcode

#### 4. Cloud Functions
```bash
cd functions
npm install
firebase deploy --only functions
```

## 🚀 Lancement du projet

### Installation des dépendances
```bash
# Flutter dependencies
flutter pub get

# Cloud Functions dependencies
cd functions && npm install
```

### Développement local
```bash
# Lancer l'app Flutter
flutter run

# Lancer les Cloud Functions en local
firebase emulators:start
```

### Build pour production
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (nécessite macOS)
flutter build ios --release
```

### Déploiement
```bash
# Déployer les Cloud Functions
firebase deploy --only functions

# Déployer l'hébergement (optionnel)
firebase deploy --only hosting
```

## 🌐 Internationalisation

### Langues supportées
- **Français** (par défaut)
- **العربية** (Arabe)
- **English** (Anglais)

### Ajouter une nouvelle langue
1. Modifier `lib/l10n/app_localizations.dart`
2. Ajouter les traductions dans `_localizedValues`
3. Mettre à jour `isSupported` dans `_AppLocalizationsDelegate`

### Utilisation dans le code
```dart
final t = AppLocalizations.of(context);
Text(t.t('welcome_message'))
```

## 🔔 Notifications Push (FCM)

### Types de notifications
- **Nouvelle réservation** (pour le conducteur)
- **Réservation acceptée** (pour le passager)
- **Messages de groupe**
- **Messages de chat trajet**
- **Demande de trajet acceptée**

### Configuration
1. Activer **Cloud Messaging** dans Firebase Console
2. Configurer les **Cloud Functions** pour les triggers
3. Le service `FcmService` gère automatiquement :
   - Permission utilisateur
   - Token registration
   - Handlers foreground/background
   - Navigation sur notification tap

## 🎨 Personnalisation

### Thème de l'application
Modifier `lib/config/theme.dart` :
```dart
static const Color primaryBlue = Color(0xFF1976D2);
static const Color warningOrange = Color(0xFFFF9800);
static const Color successGreen = Color(0xFF4CAF50);
static const Color errorRed = Color(0xFFF44336);
```

### Icônes et Splash
```bash
# Générer les icônes
flutter pub run flutter_launcher_icons:main

# Générer le splash screen
flutter pub run flutter_native_splash:create
```

## 🐛 Dépannage

### Problèmes courants

#### Firebase Auth ne fonctionne pas
- **Vérifier Internet** sur l'émulateur/appareil
- **Ajouter SHA-256** dans Firebase Console
- **Vérifier `google-services.json`** (project_id, package_name)

#### Build Android échoue
```bash
# Nettoyer le projet
flutter clean
flutter pub get

# Augmenter la mémoire Gradle
export GRADLE_OPTS="-Xmx4g -XX:MaxPermSize=512m"
```

#### Notifications push non reçues
- **Vérifier permission** notification sur l'appareil
- **Vérifier FCM token** dans Firestore
- **Déployer les Cloud Functions**

## 🗺 Roadmap

### Fonctionnalités à venir
- [ ] **Carte interactive** avec itinéraire en temps réel
- [ ] ** Paiement en ligne** intégré (Stripe, PayPal)
- [ ] **Système de points** et programme de fidélité
- [ ] **Modération** automatique du contenu
- [ ] **API REST** pour partenaires externes
- [ ] **Version web** (Flutter Web)

### Améliorations techniques
- [ ] **Tests unitaires** et integration tests
- [ ] **CI/CD** avec GitHub Actions
- [ ] **Monitoring** et analytics (Firebase Analytics)
- [ ] **Offline mode** avec cache local

## 📝 License

Ce projet est sous license **MIT** - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👥 Contributeurs

- **[Sirine Ben Yahia](https://github.com/Sirinebenyahia)** - Lead Developer
- **[Eya](https://github.com/eya)** - Frontend Developer

## 📞 Contact

- **Email** : contact@carshare.tn
- **Site web** : https://carshare.tn
- **GitHub** : https://github.com/Sirinebenyahia/CarShare-main

---

⭐ **N'oubliez pas de mettre une étoile si ce projet vous aide !**
