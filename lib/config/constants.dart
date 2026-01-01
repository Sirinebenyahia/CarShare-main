class AppConstants {
  // App Info
  static const String appName = 'CarShare Tunisie';
  static const String appVersion = '1.0.0';
  
  // API
  static const String baseUrl = 'https://api.carshare-tunisie.tn/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  
  // Tunisian Cities
  static const List<String> tunisianCities = [
    'Tunis',
    'Sfax',
    'Sousse',
    'Kairouan',
    'Bizerte',
    'Gabès',
    'Ariana',
    'Gafsa',
    'Monastir',
    'Ben Arous',
    'Kasserine',
    'Médenine',
    'Nabeul',
    'Tataouine',
    'Béja',
    'Jendouba',
    'Mahdia',
    'Sidi Bouzid',
    'Tozeur',
    'Kébili',
    'Siliana',
    'Le Kef',
    'Zaghouan',
    'Manouba',
  ];
  
  // Vehicle Brands
  static const List<String> vehicleBrands = [
    'Peugeot',
    'Renault',
    'Citroën',
    'Volkswagen',
    'Toyota',
    'Hyundai',
    'Kia',
    'Nissan',
    'Ford',
    'Opel',
    'Fiat',
    'Mercedes-Benz',
    'BMW',
    'Audi',
    'Seat',
    'Skoda',
    'Dacia',
    'Suzuki',
    'Mazda',
    'Honda',
  ];
  
  // Vehicle Colors
  static const List<String> vehicleColors = [
    'Blanc',
    'Noir',
    'Gris',
    'Argent',
    'Bleu',
    'Rouge',
    'Vert',
    'Jaune',
    'Orange',
    'Marron',
    'Beige',
  ];
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Wallet
  static const double minRechargeAmount = 10.0;
  static const double maxRechargeAmount = 1000.0;
  
  // Ride
  static const int maxSeatsPerRide = 8;
  static const int minPricePerSeat = 1;
  static const int maxPricePerSeat = 500;
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxBioLength = 200;
}
