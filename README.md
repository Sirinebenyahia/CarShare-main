# CarShare Tunisie

 Application mobile de covoiturage (Flutter + Firebase) :

 - Recherche de trajets
 - Publication de trajets (côté chauffeur)
 - Réservation + paiement (MVP)
 - Historique / trajets à venir
 - Profil utilisateur + vérification CIN (upload Firebase Storage)

## Fonctionnalités

### Authentification
 - Connexion / Inscription par **email + mot de passe** (Firebase Auth)
 - Redirection automatique vers `/home` si connecté, sinon `/welcome`

### Trajets (rides)
 - Liste des trajets disponibles depuis Firestore (`rides`)
 - Recherche simple `from/to` via écran Résultats
 - Détails d’un trajet
 - Publication d’un trajet (création d’un doc `rides`)

### Réservations (bookings)
 - Écran Paiement (MVP) : choix de méthode + création d’un doc `bookings`
 - Trajets à venir : liste des bookings du user
 - Historique : liste des bookings du user
 - Détails réservation : affiche booking + trajet associé

### Vérification CIN
 - Écran Vérification CIN
 - Upload du fichier CIN (JPG/PNG/PDF) vers Firebase Storage
 - Sauvegarde des métadonnées dans `users/{uid}`

## Stack technique
 - **Flutter** / **Dart**
 - Navigation : **go_router**
 - Firebase :
   - **firebase_core**
   - **firebase_auth**
   - **cloud_firestore**
   - **firebase_storage**
 - Upload fichier : **file_picker**

## Écrans & routes
 Les routes sont définies dans `lib/router/app_router.dart`.

 - `/welcome`
   - Connexion / Inscription
 - `/verification`
   - Upload CIN + sauvegarde dans Firestore
 - `/home`
   - Recherche (form) + liste des trajets disponibles
 - `/search?from=...&to=...`
   - Résultats de recherche
 - `/ride/:rideId`
   - Détails trajet + bouton Réserver
 - `/payment/:rideId`
   - Choix méthode paiement + création booking
 - `/booking/:bookingId`
   - Détails réservation + lien vers trajet
 - `/publish`
   - Publier un trajet (création ride)
 - `/upcoming-rides`
   - Trajets à venir (bookings)
 - `/history`
   - Historique (bookings)
 - `/profile`
   - Profil + statut CIN + actions

## Collections Firestore (schéma MVP)

### `users/{uid}`
 Champs utilisés :
 - `uid`: string
 - `email`: string
 - `createdAt`: timestamp
 - `cinNumber`: string (optionnel)
 - `cinFileUrl`: string (optionnel)
 - `cinUpdatedAt`: timestamp (optionnel)

 Création/seed : `RideService.ensureUserDoc()`.

### `rides/{rideId}`
 Champs utilisés :
 - `from`: string
 - `to`: string
 - `priceTnd`: number
 - `womenOnly`: bool
 - `seatsAvailable`: number
 - `driverName`: string
 - `rating`: number
 - `departureTime`: timestamp
 - `createdAt`: timestamp
 - `driverId`: string (uid)

 Création : `RideService.createRide()`.

### `bookings/{bookingId}`
 Champs utilisés :
 - `rideId`: string
 - `userId`: string (uid)
 - `paymentMethod`: string (`card`, `orange_money`, `ooredoo_money`, `cash`)
 - `status`: string (par défaut `confirmed`)
 - `createdAt`: timestamp

 Création : `RideService.createBooking()`.

## Storage (CIN)
 Chemin d’upload :
 - `users/{uid}/cin/{fileName}`

 Implémentation : `lib/services/storage_service.dart`.

## Structure du projet (dossiers clés)
 - `lib/main.dart` : init Firebase + router
 - `lib/firebase_options.dart` : config Firebase générée
 - `lib/router/` : configuration go_router
 - `lib/screens/` : écrans UI
 - `lib/services/` : Auth / Firestore / Storage
 - `lib/widgets/` : composants (BottomNav)

## Pré-requis
 - Flutter SDK installé (`flutter doctor` OK)
 - Android Studio + Android SDK
 - Compte Firebase + projet Firebase configuré

## Configuration Firebase

### Android
 - Package name : `com.carshare.tunisie.carshare_tunisie`
 - Fichier requis : `android/app/google-services.json`
 - Activer Email/Password : Firebase Console → Authentication → Sign-in method
 - Ajouter SHA-1/SHA-256 (debug/release) : Firebase Console → Project settings → Your apps (Android)

### iOS
 - Config via FlutterFire CLI (génère `firebase_options.dart`)
 - Nécessite macOS + Xcode pour builder iOS

## Lancer le projet

### Installer les dépendances
```bash
flutter pub get
```

### Analyse statique
```bash
flutter analyze
```

### Run Android
```bash
flutter run
```

### Release (Android)
```bash
flutter run --release
```

## Troubleshooting

### Inscription Firebase échoue (ex: `CONFIGURATION_NOT_FOUND`)
 - Vérifier que l’émulateur/appareil a **Internet**
 - Vérifier SHA-256 ajouté sur la bonne app Android dans Firebase
 - Vérifier que `google-services.json` correspond au bon `project_id` et `package_name`

### Build Android échoue avec “Espace insuffisant sur le disque”
 - Libérer de l’espace sur le disque (Gradle peut consommer plusieurs Go)
 - Relancer :
   - `flutter clean`
   - `flutter pub get`

## Roadmap (idées)
 - Filtres recherche (date, prix max, places, women only)
 - Chat driver/passager
 - Gestion des places (décrément sur booking)
 - Statuts booking (pending/cancelled/completed)
 - Validation CIN côté admin
